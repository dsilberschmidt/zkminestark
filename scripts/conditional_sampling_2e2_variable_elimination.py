#!/usr/bin/env python3
"""
EXPERIMENTO 2E2 - exact variable elimination por snapshot.

Reemplaza el contador DFS por componente con VE exacta sobre el primal
constraint graph, preservando la semántica global validada en 2B3:
  - ordinary components -> F_C[k]
  - special component -> ways[k, x_is_mine, neighbor_mines]

La implementación es modular para una futura 2E3 history-aware:
  - firma de componente persistible
  - plan de eliminación persistible
  - factores sparse con estado intermedio reusable
"""

from __future__ import annotations

import argparse
import json
import math
import statistics
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_exact as cs


StateKey = tuple[int, int, int]


@dataclass(frozen=True)
class ComponentSignature:
    variables: tuple[int, ...]
    constraints: tuple[tuple[tuple[int, ...], int], ...]


@dataclass(frozen=True)
class QuerySpec:
    x_var: int | None = None
    neighbor_vars: frozenset[int] = frozenset()


@dataclass(frozen=True)
class EliminationStep:
    variable: int
    separator: tuple[int, ...]
    width: int


@dataclass(frozen=True)
class ComponentEliminationPlan:
    signature: ComponentSignature
    variables: tuple[int, ...]
    constraints: tuple[cs.Constraint, ...]
    ordering: tuple[int, ...]
    steps: tuple[EliminationStep, ...]
    min_fill_width: int


@dataclass
class VEInstrumentation:
    factors_created: int = 0
    joins: int = 0
    marginalizations: int = 0
    peak_factor_entries: int = 0
    peak_nonzero_entries: int = 0
    total_entries_processed: int = 0
    total_nonzero_entries_processed: int = 0
    peak_live_entries: int = 0
    bigint_additions: int = 0
    bigint_multiplications: int = 0
    effective_width: int = 0
    peak_scope_size: int = 0


@dataclass
class ComponentVEProfile:
    variable_count: int
    constraint_count: int
    solution_vector: list[int] | None
    joint_counts: dict[tuple[int, int, int], int] | None
    signature: ComponentSignature
    plan: ComponentEliminationPlan
    instrumentation: VEInstrumentation
    satisfiable: bool


@dataclass
class SparseCountFactor:
    scope: tuple[int, ...]
    table: dict[int, dict[StateKey, int]]
    mine_capacity: int
    x_capacity: int
    neighbor_capacity: int

    def nonzero_entries(self) -> int:
        return sum(len(state_counts) for state_counts in self.table.values())

    def dense_capacity(self) -> int:
        return (
            (1 << len(self.scope))
            * (self.mine_capacity + 1)
            * (self.x_capacity + 1)
            * (self.neighbor_capacity + 1)
        )


def component_signature(component_vars: list[int], component_constraints: list[cs.Constraint]) -> ComponentSignature:
    return ComponentSignature(
        variables=tuple(component_vars),
        constraints=tuple((constraint.variables, constraint.rhs) for constraint in component_constraints),
    )


def build_primal_graph(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
) -> dict[int, set[int]]:
    adj = {var: set() for var in component_vars}
    for constraint in component_constraints:
        scope = [var for var in constraint.variables if var in adj]
        for i, left in enumerate(scope):
            for right in scope[i + 1:]:
                adj[left].add(right)
                adj[right].add(left)
    return adj


def _choose_min_fill_variable(adj: dict[int, set[int]], remaining: set[int]) -> int:
    best_var: int | None = None
    best_fill = float("inf")
    best_degree = float("inf")
    for var in sorted(remaining):
        neighbors = sorted(adj[var] & remaining)
        fill = 0
        for i, left in enumerate(neighbors):
            for right in neighbors[i + 1:]:
                if right not in adj[left]:
                    fill += 1
        degree = len(neighbors)
        candidate = (fill, degree, var)
        if candidate < (best_fill, best_degree, best_var if best_var is not None else float("inf")):
            best_fill, best_degree, best_var = candidate
    assert best_var is not None
    return best_var


def build_elimination_plan(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
) -> ComponentEliminationPlan:
    signature = component_signature(component_vars, component_constraints)
    adj = build_primal_graph(component_vars, component_constraints)
    sim_adj = {var: set(neighbors) for var, neighbors in adj.items()}
    remaining = set(component_vars)
    ordering: list[int] = []
    steps: list[EliminationStep] = []
    width = 0

    while remaining:
        var = _choose_min_fill_variable(sim_adj, remaining)
        separator = tuple(sorted(sim_adj[var] & remaining - {var}))
        step_width = len(separator)
        width = max(width, step_width)
        ordering.append(var)
        steps.append(EliminationStep(variable=var, separator=separator, width=step_width))
        for i, left in enumerate(separator):
            for right in separator[i + 1:]:
                sim_adj[left].add(right)
                sim_adj[right].add(left)
        remaining.remove(var)

    return ComponentEliminationPlan(
        signature=signature,
        variables=tuple(component_vars),
        constraints=tuple(component_constraints),
        ordering=tuple(ordering),
        steps=tuple(steps),
        min_fill_width=width,
    )


def _bit(mask: int, pos: int) -> int:
    return (mask >> pos) & 1


def _remove_bit(mask: int, pos: int) -> int:
    lower = mask & ((1 << pos) - 1)
    upper = mask >> (pos + 1)
    return lower | (upper << pos)


def _expand_mask(mask: int, positions: tuple[int, ...]) -> int:
    expanded = 0
    for src_pos, dst_pos in enumerate(positions):
        if (mask >> src_pos) & 1:
            expanded |= 1 << dst_pos
    return expanded


def _project_mask(mask: int, positions: tuple[int, ...]) -> int:
    projected = 0
    for dst_pos, src_pos in enumerate(positions):
        if (mask >> src_pos) & 1:
            projected |= 1 << dst_pos
    return projected


def _accumulate_state(
    out_states: dict[StateKey, int],
    state: StateKey,
    addend: int,
    stats: VEInstrumentation,
) -> None:
    previous = out_states.get(state, 0)
    if previous:
        stats.bigint_additions += 1
    out_states[state] = previous + addend


def _observe_factor(stats: VEInstrumentation, factor: SparseCountFactor) -> None:
    stats.peak_factor_entries = max(stats.peak_factor_entries, factor.dense_capacity())
    stats.peak_nonzero_entries = max(stats.peak_nonzero_entries, factor.nonzero_entries())
    stats.peak_scope_size = max(stats.peak_scope_size, len(factor.scope))


def _observe_live(stats: VEInstrumentation, factors: list[SparseCountFactor]) -> None:
    stats.peak_live_entries = max(stats.peak_live_entries, sum(f.nonzero_entries() for f in factors))


def constraint_factor(
    constraint: cs.Constraint,
    query: QuerySpec,
) -> SparseCountFactor:
    scope = tuple(constraint.variables)
    table: dict[int, dict[StateKey, int]] = {}
    for mask in range(1 << len(scope)):
        if mask.bit_count() != constraint.rhs:
            continue
        table[mask] = {(0, 0, 0): 1}
    return SparseCountFactor(
        scope=scope,
        table=table,
        mine_capacity=0,
        x_capacity=1 if query.x_var is not None and query.x_var in scope else 0,
        neighbor_capacity=sum(1 for var in scope if var in query.neighbor_vars),
    )


def join_factors(
    left: SparseCountFactor,
    right: SparseCountFactor,
    stats: VEInstrumentation,
) -> SparseCountFactor:
    if not left.scope:
        stats.joins += 1
        stats.total_entries_processed += left.dense_capacity() + right.dense_capacity()
        stats.total_nonzero_entries_processed += left.nonzero_entries() + right.nonzero_entries()
        merged = SparseCountFactor(
            scope=right.scope,
            table={mask: dict(states) for mask, states in right.table.items()},
            mine_capacity=left.mine_capacity + right.mine_capacity,
            x_capacity=min(1, left.x_capacity + right.x_capacity),
            neighbor_capacity=left.neighbor_capacity + right.neighbor_capacity,
        )
        _observe_factor(stats, merged)
        stats.factors_created += 1
        return merged
    if not right.scope:
        return join_factors(right, left, stats)

    merged_scope = tuple(sorted(set(left.scope) | set(right.scope)))
    left_pos = {var: idx for idx, var in enumerate(left.scope)}
    right_pos = {var: idx for idx, var in enumerate(right.scope)}
    merged_pos = {var: idx for idx, var in enumerate(merged_scope)}

    left_expand = tuple(merged_pos[var] for var in left.scope)
    right_expand = tuple(merged_pos[var] for var in right.scope)
    overlap_vars = tuple(sorted(set(left.scope) & set(right.scope)))
    left_overlap = tuple(left_pos[var] for var in overlap_vars)
    right_overlap = tuple(right_pos[var] for var in overlap_vars)

    right_buckets: dict[int, list[tuple[int, dict[StateKey, int]]]] = {}
    for right_mask, right_states in right.table.items():
        key = _project_mask(right_mask, right_overlap)
        right_buckets.setdefault(key, []).append((right_mask, right_states))

    out: dict[int, dict[StateKey, int]] = {}
    stats.joins += 1
    stats.total_entries_processed += left.dense_capacity() + right.dense_capacity()
    stats.total_nonzero_entries_processed += left.nonzero_entries() + right.nonzero_entries()

    for left_mask, left_states in left.table.items():
        bucket_key = _project_mask(left_mask, left_overlap)
        candidates = right_buckets.get(bucket_key, [])
        left_expanded = _expand_mask(left_mask, left_expand)
        for right_mask, right_states in candidates:
            merged_mask = left_expanded | _expand_mask(right_mask, right_expand)
            out_states = out.setdefault(merged_mask, {})
            for (lk, lx, ln), left_count in left_states.items():
                for (rk, rx, rn), right_count in right_states.items():
                    x_sum = lx + rx
                    if x_sum > 1:
                        continue
                    stats.bigint_multiplications += 1
                    _accumulate_state(
                        out_states,
                        (lk + rk, x_sum, ln + rn),
                        left_count * right_count,
                        stats,
                    )

    merged = SparseCountFactor(
        scope=merged_scope,
        table={mask: states for mask, states in out.items() if states},
        mine_capacity=left.mine_capacity + right.mine_capacity,
        x_capacity=min(1, left.x_capacity + right.x_capacity),
        neighbor_capacity=left.neighbor_capacity + right.neighbor_capacity,
    )
    _observe_factor(stats, merged)
    stats.factors_created += 1
    stats.effective_width = max(stats.effective_width, max(0, len(merged.scope) - 1))
    return merged


def eliminate_variable(
    factor: SparseCountFactor,
    variable: int,
    query: QuerySpec,
    stats: VEInstrumentation,
) -> SparseCountFactor:
    pos = factor.scope.index(variable)
    out_scope = factor.scope[:pos] + factor.scope[pos + 1:]
    out: dict[int, dict[StateKey, int]] = {}

    stats.marginalizations += 1
    stats.total_entries_processed += factor.dense_capacity()
    stats.total_nonzero_entries_processed += factor.nonzero_entries()
    for mask, states in factor.table.items():
        value = _bit(mask, pos)
        new_mask = _remove_bit(mask, pos)
        out_states = out.setdefault(new_mask, {})
        for (k, x_mine, neighbor_mines), count in states.items():
            next_state = (
                k + value,
                x_mine + (value if variable == query.x_var else 0),
                neighbor_mines + (value if variable in query.neighbor_vars else 0),
            )
            _accumulate_state(out_states, next_state, count, stats)

    reduced = SparseCountFactor(
        scope=out_scope,
        table={mask: states for mask, states in out.items() if states},
        mine_capacity=factor.mine_capacity + 1,
        x_capacity=factor.x_capacity,
        neighbor_capacity=factor.neighbor_capacity,
    )
    _observe_factor(stats, reduced)
    stats.factors_created += 1
    return reduced


def _join_related_factors(
    factors: list[SparseCountFactor],
    stats: VEInstrumentation,
) -> SparseCountFactor:
    ordered = sorted(
        factors,
        key=lambda factor: (len(factor.scope), factor.nonzero_entries(), factor.scope),
    )
    joined = ordered[0]
    for factor in ordered[1:]:
        joined = join_factors(joined, factor, stats)
    return joined


def execute_component_plan(
    plan: ComponentEliminationPlan,
    query: QuerySpec,
) -> tuple[SparseCountFactor, VEInstrumentation]:
    stats = VEInstrumentation()
    factors = [constraint_factor(constraint, query) for constraint in plan.constraints]
    stats.factors_created += len(factors)
    for factor in factors:
        _observe_factor(stats, factor)
    _observe_live(stats, factors)

    for variable in plan.ordering:
        related = [factor for factor in factors if variable in factor.scope]
        if not related:
            continue
        factors = [factor for factor in factors if variable not in factor.scope]
        joined = _join_related_factors(related, stats)
        stats.effective_width = max(stats.effective_width, max(0, len(joined.scope) - 1))
        reduced = eliminate_variable(joined, variable, query, stats)
        factors.append(reduced)
        _observe_live(stats, factors)

    if not factors:
        identity = SparseCountFactor(scope=(), table={0: {(0, 0, 0): 1}}, mine_capacity=0, x_capacity=0, neighbor_capacity=0)
        _observe_factor(stats, identity)
        return identity, stats

    final_factor = _join_related_factors(factors, stats)
    _observe_live(stats, [final_factor])
    return final_factor, stats


def count_component_ordinary_ve(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
) -> ComponentVEProfile:
    plan = build_elimination_plan(component_vars, component_constraints)
    final_factor, stats = execute_component_plan(plan, QuerySpec())
    counts = [0] * (len(component_vars) + 1)
    for states in final_factor.table.values():
        for (k, x_mine, neighbor_mines), ways in states.items():
            if x_mine or neighbor_mines:
                raise AssertionError("ordinary VE no debe producir dimensiones especiales")
            counts[k] += ways
    return ComponentVEProfile(
        variable_count=len(component_vars),
        constraint_count=len(component_constraints),
        solution_vector=counts,
        joint_counts=None,
        signature=plan.signature,
        plan=plan,
        instrumentation=stats,
        satisfiable=any(counts),
    )


def count_component_joint_ve(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    x_var: int | None,
    neighbor_vars: set[int],
) -> ComponentVEProfile:
    plan = build_elimination_plan(component_vars, component_constraints)
    final_factor, stats = execute_component_plan(
        plan,
        QuerySpec(x_var=x_var, neighbor_vars=frozenset(neighbor_vars)),
    )
    joint_counts: dict[tuple[int, int, int], int] = {}
    for states in final_factor.table.values():
        for state, ways in states.items():
            joint_counts[state] = joint_counts.get(state, 0) + ways
    return ComponentVEProfile(
        variable_count=len(component_vars),
        constraint_count=len(component_constraints),
        solution_vector=None,
        joint_counts=joint_counts,
        signature=plan.signature,
        plan=plan,
        instrumentation=stats,
        satisfiable=bool(joint_counts),
    )


def ordinary_component_factor(profile: ComponentVEProfile) -> dict[tuple[int, int, int], int]:
    assert profile.solution_vector is not None
    return {
        (mines_used, 0, 0): ways
        for mines_used, ways in enumerate(profile.solution_vector)
        if ways
    }


def analyze_joint_problem_ve(
    transcript: cs.Transcript,
    cell_index: int,
) -> dict[str, object]:
    consistent, constraints, variables, remaining_mines = cs.build_constraints(transcript)
    if not consistent:
        return {
            "consistent": False,
            "remaining_mines": remaining_mines,
            "constraints": [],
            "variables": [],
            "joint_distribution": {},
            "adjacent_known_mines": 0,
            "ordinary_component_count": 0,
            "special_component_count": 0,
            "unconstrained_local_cells": [],
            "unconstrained_other_count": 0,
            "unconstrained_closed_cells": 0,
            "convolutions_performed": 0,
            "components": [],
            "instrumentation": {},
        }

    local_hidden, local_neighbors, adjacent_known_mines = b3.local_hidden_sets(transcript, cell_index)
    frontier_var_set = set(variables)
    unconstrained_local = sorted(local_hidden - frontier_var_set)
    unconstrained_closed_cells = len([cell for cell in transcript.closed_cells() if cell not in frontier_var_set])
    unconstrained_other_count = unconstrained_closed_cells - len(unconstrained_local)
    component_variables, component_constraints = cs.connected_components(variables, constraints)

    aggregate: dict[tuple[int, int, int], int] = {(0, 0, 0): 1}
    convolutions = 0
    components: list[dict[str, object]] = []
    ordinary_wall_ms = 0.0
    special_wall_ms = 0.0
    total_stats = {
        "factors_created": 0,
        "joins": 0,
        "marginalizations": 0,
        "peak_factor_entries": 0,
        "peak_nonzero_entries": 0,
        "total_entries_processed": 0,
        "total_nonzero_entries_processed": 0,
        "peak_live_entries": 0,
        "bigint_additions": 0,
        "bigint_multiplications": 0,
        "ordinary_min_fill_width_max": 0,
        "special_min_fill_width_max": 0,
        "effective_special_width_max": 0,
    }
    ordinary_component_count = 0
    special_component_count = 0

    for index, (component_vars, component_constraint_group) in enumerate(zip(component_variables, component_constraints)):
        component_var_set = set(component_vars)
        started = time.perf_counter()
        if not component_var_set.intersection(local_hidden):
            profile = count_component_ordinary_ve(component_vars, component_constraint_group)
            ordinary_wall_ms += (time.perf_counter() - started) * 1000.0
            factor = ordinary_component_factor(profile)
            ordinary_component_count += 1
            role = "ordinary"
            total_stats["ordinary_min_fill_width_max"] = max(
                total_stats["ordinary_min_fill_width_max"],
                profile.plan.min_fill_width,
            )
        else:
            profile = count_component_joint_ve(
                component_vars=component_vars,
                component_constraints=component_constraint_group,
                x_var=cell_index if cell_index in component_var_set else None,
                neighbor_vars=local_neighbors.intersection(component_var_set),
            )
            special_wall_ms += (time.perf_counter() - started) * 1000.0
            factor = profile.joint_counts or {}
            special_component_count += 1
            role = "special"
            total_stats["special_min_fill_width_max"] = max(
                total_stats["special_min_fill_width_max"],
                profile.plan.min_fill_width,
            )
            total_stats["effective_special_width_max"] = max(
                total_stats["effective_special_width_max"],
                profile.instrumentation.effective_width,
            )

        aggregate = b3.convolve_joint(aggregate, factor)
        convolutions += 1

        stats = profile.instrumentation
        total_stats["factors_created"] += stats.factors_created
        total_stats["joins"] += stats.joins
        total_stats["marginalizations"] += stats.marginalizations
        total_stats["total_entries_processed"] += stats.total_entries_processed
        total_stats["total_nonzero_entries_processed"] += stats.total_nonzero_entries_processed
        total_stats["bigint_additions"] += stats.bigint_additions
        total_stats["bigint_multiplications"] += stats.bigint_multiplications
        total_stats["peak_factor_entries"] = max(total_stats["peak_factor_entries"], stats.peak_factor_entries)
        total_stats["peak_nonzero_entries"] = max(total_stats["peak_nonzero_entries"], stats.peak_nonzero_entries)
        total_stats["peak_live_entries"] = max(total_stats["peak_live_entries"], stats.peak_live_entries)

        components.append(
            {
                "component_index": index,
                "role": role,
                "size": len(component_vars),
                "constraint_count": len(component_constraint_group),
                "signature": {
                    "variables": list(profile.signature.variables),
                    "constraints": [
                        {"scope": list(scope), "rhs": rhs}
                        for scope, rhs in profile.signature.constraints
                    ],
                },
                "ordering": list(profile.plan.ordering),
                "min_fill_width": profile.plan.min_fill_width,
                "effective_width": profile.instrumentation.effective_width,
                "peak_factor_entries": profile.instrumentation.peak_factor_entries,
                "peak_nonzero_entries": profile.instrumentation.peak_nonzero_entries,
            }
        )

    if unconstrained_local:
        aggregate = b3.convolve_joint(
            aggregate,
            b3.unconstrained_local_factor(
                x_is_unconstrained=cell_index in unconstrained_local,
                unconstrained_neighbor_count=sum(1 for var in unconstrained_local if var in local_neighbors),
            ),
        )
        convolutions += 1

    if unconstrained_other_count > 0:
        aggregate = b3.convolve_joint(
            aggregate,
            {
                (mines, 0, 0): ways
                for mines, ways in enumerate(b3.unconstrained_other_vector(unconstrained_other_count))
                if ways
            },
        )
        convolutions += 1

    return {
        "consistent": True,
        "remaining_mines": remaining_mines,
        "constraints": constraints,
        "variables": variables,
        "joint_distribution": aggregate,
        "adjacent_known_mines": adjacent_known_mines,
        "ordinary_component_count": ordinary_component_count,
        "special_component_count": special_component_count,
        "unconstrained_local_cells": unconstrained_local,
        "unconstrained_other_count": unconstrained_other_count,
        "unconstrained_closed_cells": unconstrained_closed_cells,
        "convolutions_performed": convolutions,
        "components": components,
        "instrumentation": {
            **total_stats,
            "wall_clock_ordinary_ms": ordinary_wall_ms,
            "wall_clock_special_ms": special_wall_ms,
        },
    }


def evaluate_cell_2e2(
    transcript: cs.Transcript,
    cell_index: int,
) -> dict[str, object]:
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        raise ValueError("La celda evaluada debe estar cerrada.")

    started = time.perf_counter()
    analysis = analyze_joint_problem_ve(transcript, cell_index)
    counts = b3.counts_from_joint_distribution(
        transcript=transcript,
        cell_index=cell_index,
        joint_distribution=analysis["joint_distribution"],
        adjacent_known_mines=int(analysis["adjacent_known_mines"]),
    )
    total_count = sum(counts.values())
    compatible_total = b3.compatible_total_from_joint_distribution(
        transcript=transcript,
        joint_distribution=analysis["joint_distribution"],
    )
    partition_ok = total_count == compatible_total
    max_count = max(counts.values()) if counts else 0
    instrumentation = dict(analysis["instrumentation"])
    total_ms = (time.perf_counter() - started) * 1000.0
    instrumentation["wall_clock_total_ms"] = total_ms
    return {
        "status": "ok",
        "counts": counts,
        "sum_counts": total_count,
        "compatible_total_before_click": compatible_total,
        "partition_ok": partition_ok,
        "outcomes_positive": sum(1 for value in counts.values() if value > 0),
        "problems_executed": 1,
        "shared_single_pass": True,
        "frontier_variables": len(analysis["variables"]),
        "constraint_count": len(analysis["constraints"]),
        "unconstrained_closed_cells": int(analysis["unconstrained_closed_cells"]),
        "max_count_bit_length": max_count.bit_length() if max_count else 0,
        "wall_clock_ms": total_ms,
        "ve": {
            "ordinary_component_count": int(analysis["ordinary_component_count"]),
            "special_component_count": int(analysis["special_component_count"]),
            "unconstrained_local_cells": list(analysis["unconstrained_local_cells"]),
            "unconstrained_other_count": int(analysis["unconstrained_other_count"]),
            "adjacent_known_mines": int(analysis["adjacent_known_mines"]),
            "components": analysis["components"],
            "instrumentation": instrumentation,
        },
    }


def transcript_from_corpus_row(row: dict[str, object]) -> cs.Transcript:
    return b3.transcript_from_corpus_row(row)


def compare_case(case: dict[str, object]) -> dict[str, object]:
    transcript = transcript_from_corpus_row(case)
    cell_index = int(case["clicked_cell"]["index"])
    baseline = b3.evaluate_cell_shared_outcomes(transcript, cell_index)
    candidate = evaluate_cell_2e2(transcript, cell_index)
    return {
        "case_id": case["case_id"],
        "transcript_id": case["transcript_id"],
        "clicked_cell": case["clicked_cell"],
        "ok_vs_2b3": (
            candidate["counts"] == baseline["counts"]
            and candidate["sum_counts"] == baseline["sum_counts"]
            and candidate["compatible_total_before_click"] == baseline["compatible_total_before_click"]
            and candidate["partition_ok"] == baseline["partition_ok"]
        ),
        "counts_2b3": baseline["counts"],
        "counts_2e2": candidate["counts"],
        "metrics": {
            "2B3": {
                "search_nodes": baseline["total_search_nodes"],
                "branch_ops": baseline["total_branch_ops"],
                "wall_clock_ms": baseline["wall_clock_ms"],
            },
            "2E2": {
                "factors_created": candidate["ve"]["instrumentation"]["factors_created"],
                "joins": candidate["ve"]["instrumentation"]["joins"],
                "marginalizations": candidate["ve"]["instrumentation"]["marginalizations"],
                "peak_factor_entries": candidate["ve"]["instrumentation"]["peak_factor_entries"],
                "peak_nonzero_entries": candidate["ve"]["instrumentation"]["peak_nonzero_entries"],
                "total_entries_processed": candidate["ve"]["instrumentation"]["total_entries_processed"],
                "total_nonzero_entries_processed": candidate["ve"]["instrumentation"]["total_nonzero_entries_processed"],
                "peak_live_entries": candidate["ve"]["instrumentation"]["peak_live_entries"],
                "bigint_additions": candidate["ve"]["instrumentation"]["bigint_additions"],
                "bigint_multiplications": candidate["ve"]["instrumentation"]["bigint_multiplications"],
                "ordinary_min_fill_width_max": candidate["ve"]["instrumentation"]["ordinary_min_fill_width_max"],
                "special_min_fill_width_max": candidate["ve"]["instrumentation"]["special_min_fill_width_max"],
                "effective_special_width_max": candidate["ve"]["instrumentation"]["effective_special_width_max"],
                "wall_clock_ordinary_ms": candidate["ve"]["instrumentation"]["wall_clock_ordinary_ms"],
                "wall_clock_special_ms": candidate["ve"]["instrumentation"]["wall_clock_special_ms"],
                "wall_clock_total_ms": candidate["ve"]["instrumentation"]["wall_clock_total_ms"],
            },
        },
        "ve": candidate["ve"],
    }


def load_cases(corpus_path: Path, case_ids: list[str] | None = None) -> list[dict[str, object]]:
    rows = [
        json.loads(line)
        for line in corpus_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if case_ids is None:
        return rows
    wanted = set(case_ids)
    return [row for row in rows if row["case_id"] in wanted]


def _percentile(values: list[float], p: int) -> float:
    if not values:
        return float("nan")
    values = sorted(values)
    idx = p / 100 * (len(values) - 1)
    lo = int(idx)
    hi = min(lo + 1, len(values) - 1)
    return values[lo] + (idx - lo) * (values[hi] - values[lo])


def benchmark_corpus(corpus_path: Path, out_path: Path) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for case in load_cases(corpus_path):
        comparison = compare_case(case)
        row = {
            "case_id": comparison["case_id"],
            "transcript_id": comparison["transcript_id"],
            "clicked_cell": comparison["clicked_cell"],
            "status": "ok" if comparison["ok_vs_2b3"] else "mismatch",
            "result": comparison,
        }
        rows.append(row)
    out_path.write_text(
        "".join(json.dumps(row, sort_keys=True) + "\n" for row in rows),
        encoding="utf-8",
    )
    return rows


def _median(values: list[float]) -> float:
    return statistics.median(values)


def _max_with_nan(values: list[float]) -> float:
    return max(values) if values else float("nan")


def evaluate_case_repeated(case: dict[str, object], repeats: int, warmup: int = 1) -> dict[str, object]:
    transcript = transcript_from_corpus_row(case)
    cell_index = int(case["clicked_cell"]["index"])

    baseline_reference = b3.evaluate_cell_shared_outcomes(transcript, cell_index)
    candidate_reference = evaluate_cell_2e2(transcript, cell_index)
    exact_match = (
        candidate_reference["counts"] == baseline_reference["counts"]
        and candidate_reference["sum_counts"] == baseline_reference["sum_counts"]
        and candidate_reference["compatible_total_before_click"] == baseline_reference["compatible_total_before_click"]
        and candidate_reference["partition_ok"] == baseline_reference["partition_ok"]
    )

    for _ in range(warmup):
        b3.evaluate_cell_shared_outcomes(transcript, cell_index)
        evaluate_cell_2e2(transcript, cell_index)

    wall_2b3_ms: list[float] = []
    wall_2e2_ms: list[float] = []
    for repeat in range(repeats):
        if repeat % 2 == 0:
            wall_2b3_ms.append(b3.evaluate_cell_shared_outcomes(transcript, cell_index)["wall_clock_ms"])
            wall_2e2_ms.append(evaluate_cell_2e2(transcript, cell_index)["wall_clock_ms"])
        else:
            wall_2e2_ms.append(evaluate_cell_2e2(transcript, cell_index)["wall_clock_ms"])
            wall_2b3_ms.append(b3.evaluate_cell_shared_outcomes(transcript, cell_index)["wall_clock_ms"])

    median_2b3 = _median(wall_2b3_ms)
    median_2e2 = _median(wall_2e2_ms)
    return {
        "case_id": case["case_id"],
        "transcript_id": case["transcript_id"],
        "clicked_cell": case["clicked_cell"],
        "repeats": repeats,
        "warmup": warmup,
        "timing_scope": {
            "2B3": "evaluate_cell_shared_outcomes(T,x) only",
            "2E2": "evaluate_cell_2e2(T,x) only",
            "excluded": [
                "corpus loading",
                "JSONL writing",
                "correctness comparison",
                "summary aggregation",
                "test execution",
            ],
            "sampling_order": "alternating per repeat: even=2B3->2E2, odd=2E2->2B3",
        },
        "exact_match_vs_2b3": exact_match,
        "reference": {
            "counts_2b3": baseline_reference["counts"],
            "counts_2e2": candidate_reference["counts"],
            "sum_counts_2b3": baseline_reference["sum_counts"],
            "sum_counts_2e2": candidate_reference["sum_counts"],
            "compatible_total_2b3": baseline_reference["compatible_total_before_click"],
            "compatible_total_2e2": candidate_reference["compatible_total_before_click"],
            "partition_ok_2b3": baseline_reference["partition_ok"],
            "partition_ok_2e2": candidate_reference["partition_ok"],
            "search_nodes_2b3": baseline_reference["total_search_nodes"],
            "branch_ops_2b3": baseline_reference["total_branch_ops"],
            "peak_factor_entries_2e2": candidate_reference["ve"]["instrumentation"]["peak_factor_entries"],
            "peak_nonzero_entries_2e2": candidate_reference["ve"]["instrumentation"]["peak_nonzero_entries"],
            "effective_special_width_max_2e2": candidate_reference["ve"]["instrumentation"]["effective_special_width_max"],
            "special_min_fill_width_max_2e2": candidate_reference["ve"]["instrumentation"]["special_min_fill_width_max"],
            "component_sizes_2e2": [component["size"] for component in candidate_reference["ve"]["components"]],
        },
        "wall_clock_ms": {
            "2B3_samples": wall_2b3_ms,
            "2E2_samples": wall_2e2_ms,
            "2B3_median": median_2b3,
            "2E2_median": median_2e2,
            "2B3_min": min(wall_2b3_ms),
            "2B3_max": max(wall_2b3_ms),
            "2E2_min": min(wall_2e2_ms),
            "2E2_max": max(wall_2e2_ms),
            "ratio_2e2_over_2b3_median": median_2e2 / median_2b3 if median_2b3 else None,
            "speedup_2b3_over_2e2_median": median_2b3 / median_2e2 if median_2e2 else None,
        },
    }


def benchmark_corpus_repeated(
    corpus_path: Path,
    out_path: Path,
    repeats: int,
    warmup: int = 1,
) -> list[dict[str, object]]:
    rows = [
        evaluate_case_repeated(case, repeats=repeats, warmup=warmup)
        for case in load_cases(corpus_path)
    ]
    out_path.write_text(
        "".join(json.dumps(row, sort_keys=True) + "\n" for row in rows),
        encoding="utf-8",
    )
    return rows


def _wins_ties_losses(rows: list[dict[str, object]]) -> tuple[int, int, int]:
    wins = 0
    ties = 0
    losses = 0
    for row in rows:
        wall = row["wall_clock_ms"]
        if wall["2E2_median"] < wall["2B3_median"]:
            wins += 1
        elif wall["2E2_median"] > wall["2B3_median"]:
            losses += 1
        else:
            ties += 1
    return wins, ties, losses


def _safe_correlation(xs: list[float], ys: list[float]) -> float | None:
    if len(xs) < 2 or len(ys) < 2:
        return None
    if min(xs) == max(xs) or min(ys) == max(ys):
        return None
    return statistics.correlation(xs, ys)


def repeated_summary(rows: list[dict[str, object]]) -> dict[str, object]:
    median_2b3 = [row["wall_clock_ms"]["2B3_median"] for row in rows]
    median_2e2 = [row["wall_clock_ms"]["2E2_median"] for row in rows]
    ratio_2e2_over_2b3 = [row["wall_clock_ms"]["ratio_2e2_over_2b3_median"] for row in rows]
    speedup_2b3_over_2e2 = [row["wall_clock_ms"]["speedup_2b3_over_2e2_median"] for row in rows]
    search_nodes = [row["reference"]["search_nodes_2b3"] for row in rows]
    component_size = [max(row["reference"]["component_sizes_2e2"], default=0) for row in rows]
    effective_width = [row["reference"]["effective_special_width_max_2e2"] for row in rows]

    buckets = [
        ("lt250", lambda n: n < 250),
        ("250_499", lambda n: 250 <= n <= 499),
        ("500_999", lambda n: 500 <= n <= 999),
        ("1000_1999", lambda n: 1000 <= n <= 1999),
        ("ge2000", lambda n: n >= 2000),
    ]
    bucket_rows: list[dict[str, object]] = []
    for label, predicate in buckets:
        group = [row for row in rows if predicate(row["reference"]["search_nodes_2b3"])]
        if not group:
            continue
        group_nodes = [row["reference"]["search_nodes_2b3"] for row in group]
        group_wall_2b3 = [row["wall_clock_ms"]["2B3_median"] for row in group]
        group_wall_2e2 = [row["wall_clock_ms"]["2E2_median"] for row in group]
        group_speedup = [row["wall_clock_ms"]["speedup_2b3_over_2e2_median"] for row in group]
        wins, ties, losses = _wins_ties_losses(group)
        bucket_rows.append(
            {
                "bucket": label,
                "count": len(group),
                "median_search_nodes_2b3": _median(group_nodes),
                "median_wall_2b3_ms": _median(group_wall_2b3),
                "median_wall_2e2_ms": _median(group_wall_2e2),
                "median_speedup_2b3_over_2e2": _median(group_speedup),
                "p90_speedup_2b3_over_2e2": _percentile(group_speedup, 90),
                "wins_2e2": wins,
                "ties": ties,
                "losses_2e2": losses,
            }
        )

    wins, ties, losses = _wins_ties_losses(rows)
    return {
        "case_count": len(rows),
        "exact_match_count": sum(1 for row in rows if row["exact_match_vs_2b3"]),
        "wall_clock_2b3_ms": {
            "p50": _percentile(median_2b3, 50),
            "p90": _percentile(median_2b3, 90),
            "p95": _percentile(median_2b3, 95),
            "p99": _percentile(median_2b3, 99),
            "max": _max_with_nan(median_2b3),
        },
        "wall_clock_2e2_ms": {
            "p50": _percentile(median_2e2, 50),
            "p90": _percentile(median_2e2, 90),
            "p95": _percentile(median_2e2, 95),
            "p99": _percentile(median_2e2, 99),
            "max": _max_with_nan(median_2e2),
        },
        "ratio_2e2_over_2b3_per_case": {
            "definition": "percentile over per-case medians: median_2e2_i / median_2b3_i",
            "p50": _percentile(ratio_2e2_over_2b3, 50),
            "p90": _percentile(ratio_2e2_over_2b3, 90),
            "p95": _percentile(ratio_2e2_over_2b3, 95),
            "p99": _percentile(ratio_2e2_over_2b3, 99),
            "max": _max_with_nan(ratio_2e2_over_2b3),
        },
        "speedup_2b3_over_2e2_per_case": {
            "definition": "percentile over per-case medians: median_2b3_i / median_2e2_i",
            "p50": _percentile(speedup_2b3_over_2e2, 50),
            "p90": _percentile(speedup_2b3_over_2e2, 90),
            "p95": _percentile(speedup_2b3_over_2e2, 95),
            "p99": _percentile(speedup_2b3_over_2e2, 99),
            "max": _max_with_nan(speedup_2b3_over_2e2),
        },
        "wins_ties_losses_2e2": {
            "wins": wins,
            "ties": ties,
            "losses": losses,
        },
        "crossover_buckets": bucket_rows,
        "correlations": {
            "search_nodes_2b3_vs_speedup_2b3_over_2e2": _safe_correlation(search_nodes, speedup_2b3_over_2e2),
            "max_component_size_vs_speedup_2b3_over_2e2": _safe_correlation(component_size, speedup_2b3_over_2e2),
            "effective_width_vs_speedup_2b3_over_2e2": _safe_correlation(effective_width, speedup_2b3_over_2e2),
        },
    }


def print_repeated_summary(summary: dict[str, object]) -> None:
    print(f"casos={summary['case_count']} exact_match={summary['exact_match_count']}")
    print(
        "2B3 median wall-clock per case "
        f"p50={summary['wall_clock_2b3_ms']['p50']:.3f} p90={summary['wall_clock_2b3_ms']['p90']:.3f} "
        f"p95={summary['wall_clock_2b3_ms']['p95']:.3f} p99={summary['wall_clock_2b3_ms']['p99']:.3f} max={summary['wall_clock_2b3_ms']['max']:.3f}"
    )
    print(
        "2E2 median wall-clock per case "
        f"p50={summary['wall_clock_2e2_ms']['p50']:.3f} p90={summary['wall_clock_2e2_ms']['p90']:.3f} "
        f"p95={summary['wall_clock_2e2_ms']['p95']:.3f} p99={summary['wall_clock_2e2_ms']['p99']:.3f} max={summary['wall_clock_2e2_ms']['max']:.3f}"
    )
    print(
        "ratio 2E2/2B3 per-case medians "
        f"p50={summary['ratio_2e2_over_2b3_per_case']['p50']:.3f} "
        f"p90={summary['ratio_2e2_over_2b3_per_case']['p90']:.3f} "
        f"p95={summary['ratio_2e2_over_2b3_per_case']['p95']:.3f} "
        f"p99={summary['ratio_2e2_over_2b3_per_case']['p99']:.3f} "
        f"max={summary['ratio_2e2_over_2b3_per_case']['max']:.3f}"
    )
    print(
        "speedup 2B3/2E2 per-case medians "
        f"p50={summary['speedup_2b3_over_2e2_per_case']['p50']:.3f} "
        f"p90={summary['speedup_2b3_over_2e2_per_case']['p90']:.3f} "
        f"p95={summary['speedup_2b3_over_2e2_per_case']['p95']:.3f} "
        f"p99={summary['speedup_2b3_over_2e2_per_case']['p99']:.3f} "
        f"max={summary['speedup_2b3_over_2e2_per_case']['max']:.3f}"
    )
    wins = summary["wins_ties_losses_2e2"]
    print(f"wins_ties_losses_2e2 wins={wins['wins']} ties={wins['ties']} losses={wins['losses']}")
    print("crossover buckets:")
    for bucket in summary["crossover_buckets"]:
        print(
            f"  {bucket['bucket']:10s} n={bucket['count']:3d} "
            f"nodes_med={bucket['median_search_nodes_2b3']:.1f} "
            f"wall_2b3_med={bucket['median_wall_2b3_ms']:.3f} "
            f"wall_2e2_med={bucket['median_wall_2e2_ms']:.3f} "
            f"speedup_med={bucket['median_speedup_2b3_over_2e2']:.3f} "
            f"speedup_p90={bucket['p90_speedup_2b3_over_2e2']:.3f} "
            f"wins/ties/losses={bucket['wins_2e2']}/{bucket['ties']}/{bucket['losses_2e2']}"
        )
    print("correlations:")
    for key, value in summary["correlations"].items():
        if value is None:
            print(f"  {key}=None")
        else:
            print(f"  {key}={value:.4f}")


def print_benchmark_summary(rows: list[dict[str, object]]) -> None:
    ok_rows = [row for row in rows if row["status"] == "ok"]
    if not ok_rows:
        print("sin filas ok")
        return
    wall = [row["result"]["metrics"]["2E2"]["wall_clock_total_ms"] for row in ok_rows]
    peak_entries = [row["result"]["metrics"]["2E2"]["peak_factor_entries"] for row in ok_rows]
    peak_nonzero = [row["result"]["metrics"]["2E2"]["peak_nonzero_entries"] for row in ok_rows]
    effective_width = [row["result"]["metrics"]["2E2"]["effective_special_width_max"] for row in ok_rows]
    print(f"casos={len(rows)} ok={len(ok_rows)}")
    print(
        "wall_clock_total_ms "
        f"p50={_percentile(wall,50):.3f} p90={_percentile(wall,90):.3f} "
        f"p95={_percentile(wall,95):.3f} p99={_percentile(wall,99):.3f} max={max(wall):.3f}"
    )
    print(
        "peak_factor_entries "
        f"p50={_percentile(peak_entries,50):.0f} p90={_percentile(peak_entries,90):.0f} "
        f"max={max(peak_entries):.0f}"
    )
    print(
        "peak_nonzero_entries "
        f"p50={_percentile(peak_nonzero,50):.0f} p90={_percentile(peak_nonzero,90):.0f} "
        f"max={max(peak_nonzero):.0f}"
    )
    print(
        "effective_special_width_max "
        f"p50={_percentile(effective_width,50):.0f} p90={_percentile(effective_width,90):.0f} "
        f"max={max(effective_width):.0f}"
    )
    most_expensive = sorted(ok_rows, key=lambda row: row["result"]["metrics"]["2E2"]["wall_clock_total_ms"], reverse=True)[:12]
    print("top12 wall_clock_total_ms:")
    for row in most_expensive:
        metrics = row["result"]["metrics"]["2E2"]
        print(
            f"  {row['case_id']} wall={metrics['wall_clock_total_ms']:.3f} "
            f"peak_entries={metrics['peak_factor_entries']} "
            f"width={metrics['effective_special_width_max']}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2E2 exact variable elimination")
    subparsers = parser.add_subparsers(dest="command", required=True)

    smoke = subparsers.add_parser("smoke")
    smoke.add_argument("--corpus", default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl")
    smoke.add_argument("--case-ids", required=True)

    bench = subparsers.add_parser("benchmark")
    bench.add_argument("--corpus", default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl")
    bench.add_argument("--out", default="benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl")

    repeated = subparsers.add_parser("benchmark-repeated")
    repeated.add_argument("--corpus", default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl")
    repeated.add_argument("--out", default="benchmarks/conditional-sampling-2e2-variable-elimination-repeated-20260830.jsonl")
    repeated.add_argument("--repeats", type=int, default=20)
    repeated.add_argument("--warmup", type=int, default=1)

    args = parser.parse_args()
    if args.command == "smoke":
        for case in load_cases(Path(args.corpus), [item for item in args.case_ids.split(",") if item]):
            print(json.dumps(compare_case(case), indent=2, sort_keys=True))
        return

    if args.command == "benchmark":
        rows = benchmark_corpus(Path(args.corpus), Path(args.out))
        print_benchmark_summary(rows)
        return

    rows = benchmark_corpus_repeated(
        Path(args.corpus),
        Path(args.out),
        repeats=args.repeats,
        warmup=args.warmup,
    )
    print_repeated_summary(repeated_summary(rows))


if __name__ == "__main__":
    main()
