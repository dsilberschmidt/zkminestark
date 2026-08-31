#!/usr/bin/env python3
"""
EXPERIMENTO 2F - flood-fill refinement horizon.

Implementa un estado generalizado explícito para celdas safe con clues
parciales, un contador exacto por VE con constraints de allowed sums y un
harness teacher-forced para comparar CELL/WAVE/FULL-REGION sobre flood-fills
reconstruibles del corpus histórico congelado.

Instrumentación:
- `dense_factor_capacity_touched`: suma de capacidades densas de los factores
  tocados por joins y marginalizations.
- `nonzero_factor_entries_processed`: entradas sparse realmente recorridas en
  joins y marginalizations.
- `peak_nonzero_factor_entries`: máximo número de entradas no nulas en un
  factor sparse.
- `max_factor_scope_variables`: máximo scope de variables de un factor.
- `max_induced_or_min_fill_width`: máximo entre el ancho min-fill del plan y
  el ancho efectivo inducido durante joins.

Los coeficientes binomiales de celdas unconstrained se toman como coste común
precomputable y no se cuentan como aritmética bigint diferencial.
"""

from __future__ import annotations

import argparse
import json
import math
import signal
import statistics
import sys
import time
from collections import defaultdict
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2e2_variable_elimination as e2
import conditional_sampling_2e3_history_aware_ve as e3
import conditional_sampling_exact as cs


POLICY_CELL = "CELL"
POLICY_WAVE = "WAVE"
POLICY_FULL_REGION = "FULL-REGION"
ALL_POLICIES = (POLICY_CELL, POLICY_WAVE, POLICY_FULL_REGION)
OFFICIAL_TIMEOUT_S = 150.0
SMOKE_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2f-smoke-20260831.jsonl"
SMOKE_SUMMARY_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2f-smoke-20260831-summary.json"
STRUCTURE_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "flood-fill-structure-30x16-20260831.jsonl"
HISTORIES_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-histories-30x16-20260831.jsonl"

CountState = tuple[int, int]


class OfficialTimeout(RuntimeError):
    pass


class _SignalTimeout:
    def __init__(self, timeout_s: float):
        self.timeout_s = timeout_s
        self.previous_handler = None

    def _raise(self, _signum, _frame):
        raise OfficialTimeout(f"official timeout after {self.timeout_s:.0f}s")

    def __enter__(self):
        self.previous_handler = signal.getsignal(signal.SIGALRM)
        signal.signal(signal.SIGALRM, self._raise)
        signal.setitimer(signal.ITIMER_REAL, self.timeout_s)
        return self

    def __exit__(self, exc_type, exc, tb):
        signal.setitimer(signal.ITIMER_REAL, 0.0)
        if self.previous_handler is not None:
            signal.signal(signal.SIGALRM, self.previous_handler)
        return False


@dataclass(frozen=True)
class AllowedSumConstraint:
    variables: tuple[int, ...]
    allowed_sums: tuple[int, ...]


@dataclass(frozen=True)
class QuerySpec:
    neighbor_vars: frozenset[int] = frozenset()


@dataclass(frozen=True)
class GeneralizedComponentSignature:
    variables: tuple[int, ...]
    constraints: tuple[tuple[tuple[int, ...], tuple[int, ...]], ...]


@dataclass(frozen=True)
class GeneralizedState:
    width: int
    height: int
    total_mines: int
    known_mines: frozenset[int]
    known_safe: frozenset[int]
    allowed_clues: tuple[tuple[int, tuple[int, ...]], ...]
    label: str = ""

    @property
    def cell_count(self) -> int:
        return self.width * self.height

    def allowed_clue_map(self) -> dict[int, tuple[int, ...]]:
        return {index: allowed for index, allowed in self.allowed_clues}

    def closed_unknown_cells(self) -> list[int]:
        out: list[int] = []
        for index in range(self.cell_count):
            if index in self.known_mines or index in self.known_safe:
                continue
            out.append(index)
        return out

    def to_json(self) -> dict[str, object]:
        return {
            "width": self.width,
            "height": self.height,
            "total_mines": self.total_mines,
            "known_mines": sorted(self.known_mines),
            "known_safe": sorted(self.known_safe),
            "allowed_clues": [
                {"index": index, "allowed_clues": list(allowed)}
                for index, allowed in self.allowed_clues
            ],
            "label": self.label,
        }


@dataclass
class VEInstrumentation:
    factors_created: int = 0
    joins: int = 0
    marginalizations: int = 0
    dense_factor_capacity_touched: int = 0
    nonzero_factor_entries_processed: int = 0
    peak_factor_entries: int = 0
    peak_nonzero_factor_entries: int = 0
    peak_live_entries: int = 0
    bigint_additions: int = 0
    bigint_multiplications: int = 0
    max_factor_scope_variables: int = 0
    min_fill_width: int = 0
    induced_width: int = 0
    max_induced_or_min_fill_width: int = 0
    max_integer_bit_length: int = 0


@dataclass
class GeneralizedSparseFactor:
    scope: tuple[int, ...]
    table: dict[int, dict[CountState, int]]
    mine_capacity: int
    neighbor_capacity: int

    def nonzero_entries(self) -> int:
        return sum(len(states) for states in self.table.values())

    def dense_capacity(self) -> int:
        return (1 << len(self.scope)) * (self.mine_capacity + 1) * (self.neighbor_capacity + 1)


def degree(width: int, height: int, cell_index: int) -> int:
    return len(cs.neighbors(width, height, cell_index))


def clue_domain(width: int, height: int, cell_index: int) -> tuple[int, ...]:
    return tuple(range(degree(width, height, cell_index) + 1))


def positive_clue_domain(width: int, height: int, cell_index: int) -> tuple[int, ...]:
    return tuple(range(1, degree(width, height, cell_index) + 1))


def canonical_allowed_map(raw: dict[int, set[int] | tuple[int, ...] | list[int]]) -> tuple[tuple[int, tuple[int, ...]], ...]:
    items: list[tuple[int, tuple[int, ...]]] = []
    for index, values in raw.items():
        allowed = tuple(sorted(set(int(value) for value in values)))
        if not allowed:
            raise ValueError(f"allowed_clues vacío para {index}")
        items.append((int(index), allowed))
    return tuple(sorted(items))


def state_from_transcript(transcript: cs.Transcript) -> GeneralizedState:
    return GeneralizedState(
        width=transcript.width,
        height=transcript.height,
        total_mines=transcript.total_mines,
        known_mines=transcript.known_mines,
        known_safe=frozenset(transcript.revealed_clues),
        allowed_clues=canonical_allowed_map({index: {clue} for index, clue in transcript.revealed_clues.items()}),
        label=transcript.label,
    )


def with_known_safe(state: GeneralizedState, safe_cells: set[int] | list[int] | tuple[int, ...], label: str | None = None) -> GeneralizedState:
    allowed = state.allowed_clue_map()
    next_safe = set(state.known_safe)
    for cell in safe_cells:
        if cell in state.known_mines:
            raise ValueError(f"celda {cell} ya marcada como mina")
        next_safe.add(int(cell))
    return GeneralizedState(
        width=state.width,
        height=state.height,
        total_mines=state.total_mines,
        known_mines=state.known_mines,
        known_safe=frozenset(next_safe),
        allowed_clues=canonical_allowed_map({index: set(values) for index, values in allowed.items()}),
        label=state.label if label is None else label,
    )


def with_allowed_clues(
    state: GeneralizedState,
    cell_index: int,
    allowed_values: set[int] | tuple[int, ...] | list[int],
    label: str | None = None,
) -> GeneralizedState:
    if cell_index in state.known_mines:
        raise ValueError("una celda conocida como mina no puede recibir allowed_clues")
    next_safe = set(state.known_safe)
    next_safe.add(cell_index)
    domain = set(clue_domain(state.width, state.height, cell_index))
    next_allowed = set(int(value) for value in allowed_values)
    if not next_allowed:
        raise ValueError("allowed_clues no puede quedar vacío")
    if not next_allowed.issubset(domain):
        raise ValueError(f"allowed_clues fuera de dominio para {cell_index}: {sorted(next_allowed - domain)}")
    allowed_map = {index: set(values) for index, values in state.allowed_clue_map().items()}
    allowed_map[cell_index] = next_allowed
    return GeneralizedState(
        width=state.width,
        height=state.height,
        total_mines=state.total_mines,
        known_mines=state.known_mines,
        known_safe=frozenset(next_safe),
        allowed_clues=canonical_allowed_map(allowed_map),
        label=state.label if label is None else label,
    )


def exact_clue_map(state: GeneralizedState) -> dict[int, int]:
    exact: dict[int, int] = {}
    for index, allowed in state.allowed_clues:
        if len(allowed) == 1:
            exact[index] = allowed[0]
    return exact


def board_matches_generalized_state(state: GeneralizedState, mines: frozenset[int]) -> bool:
    if len(mines) != state.total_mines:
        return False
    if not state.known_mines.issubset(mines):
        return False
    if set(state.known_safe).intersection(mines):
        return False
    for cell_index, allowed in state.allowed_clues:
        clue = cs.clue_for_board(state.width, state.height, mines, cell_index)
        if clue not in allowed:
            return False
    return True


def exhaustive_compatible_boards(state: GeneralizedState) -> list[frozenset[int]]:
    return [
        mines
        for mines in cs.enumerate_all_boards(state.width, state.height, state.total_mines)
        if board_matches_generalized_state(state, mines)
    ]


def transcript_from_history_row(row: dict[str, object]) -> cs.Transcript:
    return b3.transcript_from_corpus_row({"transcript": row["transcript"]})


def build_after_transcript(
    row: dict[str, object],
    next_row: dict[str, object] | None,
) -> tuple[cs.Transcript | None, str]:
    transcript = transcript_from_history_row(row)
    outcome = str(row["observed_outcome"])
    if next_row is not None:
        return transcript_from_history_row(next_row), "next-transcript"
    if outcome == cs.MINE_OUTCOME:
        return transcript, "terminal-mine-no-reveal"
    if outcome != "0":
        return cs.with_outcome(transcript, int(row["clicked_cell"]["index"]), outcome), "synthetic-single-reveal"
    return None, "terminal-zero-without-next-transcript"


def build_generalized_constraints(
    state: GeneralizedState,
) -> tuple[bool, list[AllowedSumConstraint], list[int], int, int]:
    known_safe = set(state.known_safe)
    known_mines = set(state.known_mines)
    remaining_mines = state.total_mines - len(known_mines)
    if remaining_mines < 0:
        return False, [], [], remaining_mines, 0

    allowed_map = state.allowed_clue_map()
    variable_set: set[int] = set()
    constraints: list[AllowedSumConstraint] = []
    total_unknown_cells = 0
    for index in range(state.cell_count):
        if index in known_safe or index in known_mines:
            continue
        total_unknown_cells += 1

    for clue_index, allowed_clues in sorted(allowed_map.items()):
        known_neighbor_mines = 0
        unknown_neighbors: list[int] = []
        for neighbor in cs.neighbors(state.width, state.height, clue_index):
            if neighbor in known_mines:
                known_neighbor_mines += 1
            elif neighbor in known_safe:
                continue
            else:
                unknown_neighbors.append(neighbor)
        residual = sorted({
            clue - known_neighbor_mines
            for clue in allowed_clues
            if 0 <= clue - known_neighbor_mines <= len(unknown_neighbors)
        })
        if not residual:
            return False, [], [], remaining_mines, total_unknown_cells
        if unknown_neighbors:
            scope = tuple(sorted(unknown_neighbors))
            constraints.append(AllowedSumConstraint(scope, tuple(residual)))
            variable_set.update(scope)
        elif 0 not in residual:
            return False, [], [], remaining_mines, total_unknown_cells

    if remaining_mines > total_unknown_cells:
        return False, [], [], remaining_mines, total_unknown_cells

    variables = sorted(variable_set)
    unconstrained_unknown_count = total_unknown_cells - len(variable_set)
    return True, constraints, variables, remaining_mines, unconstrained_unknown_count


def connected_components(
    variables: list[int],
    constraints: list[AllowedSumConstraint],
) -> tuple[list[list[int]], list[list[AllowedSumConstraint]]]:
    if not variables:
        return [], []
    adjacency: dict[int, set[int]] = {var: set() for var in variables}
    constraint_map: dict[int, list[AllowedSumConstraint]] = {var: [] for var in variables}
    for constraint in constraints:
        for var in constraint.variables:
            constraint_map[var].append(constraint)
            adjacency[var].update(constraint.variables)

    seen: set[int] = set()
    variable_components: list[list[int]] = []
    constraint_components: list[list[AllowedSumConstraint]] = []
    for start in variables:
        if start in seen:
            continue
        stack = [start]
        comp_vars: list[int] = []
        comp_constraints: set[AllowedSumConstraint] = set()
        seen.add(start)
        while stack:
            var = stack.pop()
            comp_vars.append(var)
            for constraint in constraint_map[var]:
                comp_constraints.add(constraint)
            for nxt in adjacency[var]:
                if nxt not in seen:
                    seen.add(nxt)
                    stack.append(nxt)
        variable_components.append(sorted(comp_vars))
        constraint_components.append(sorted(comp_constraints, key=lambda item: (item.variables, item.allowed_sums)))
    return variable_components, constraint_components


def component_signature(
    component_vars: list[int],
    component_constraints: list[AllowedSumConstraint],
) -> GeneralizedComponentSignature:
    return GeneralizedComponentSignature(
        variables=tuple(component_vars),
        constraints=tuple((constraint.variables, constraint.allowed_sums) for constraint in component_constraints),
    )


def build_primal_graph(
    component_vars: list[int],
    component_constraints: list[AllowedSumConstraint],
) -> dict[int, set[int]]:
    adj = {var: set() for var in component_vars}
    for constraint in component_constraints:
        scope = [var for var in constraint.variables if var in adj]
        for i, left in enumerate(scope):
            for right in scope[i + 1:]:
                adj[left].add(right)
                adj[right].add(left)
    return adj


def build_generalized_plan(
    component_vars: list[int],
    component_constraints: list[AllowedSumConstraint],
) -> e2.ComponentEliminationPlan:
    signature = component_signature(component_vars, component_constraints)
    adj = build_primal_graph(component_vars, component_constraints)
    sim_adj = {var: set(neighbors) for var, neighbors in adj.items()}
    remaining = set(component_vars)
    ordering: list[int] = []
    steps: list[e2.EliminationStep] = []
    width = 0
    while remaining:
        var = e2._choose_min_fill_variable(sim_adj, remaining)
        separator = tuple(sorted(sim_adj[var] & remaining - {var}))
        step_width = len(separator)
        width = max(width, step_width)
        ordering.append(var)
        steps.append(e2.EliminationStep(variable=var, separator=separator, width=step_width))
        for i, left in enumerate(separator):
            for right in separator[i + 1:]:
                sim_adj[left].add(right)
                sim_adj[right].add(left)
        remaining.remove(var)
    return e2.ComponentEliminationPlan(
        signature=signature,  # type: ignore[arg-type]
        variables=tuple(component_vars),
        constraints=tuple(component_constraints),  # type: ignore[arg-type]
        ordering=tuple(ordering),
        steps=tuple(steps),
        min_fill_width=width,
    )


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


def _remove_bit(mask: int, pos: int) -> int:
    lower = mask & ((1 << pos) - 1)
    upper = mask >> (pos + 1)
    return lower | (upper << pos)


def _observe_factor(stats: VEInstrumentation, factor: GeneralizedSparseFactor) -> None:
    stats.peak_factor_entries = max(stats.peak_factor_entries, factor.dense_capacity())
    stats.peak_nonzero_factor_entries = max(stats.peak_nonzero_factor_entries, factor.nonzero_entries())
    stats.max_factor_scope_variables = max(stats.max_factor_scope_variables, len(factor.scope))


def _observe_live(stats: VEInstrumentation, factors: list[GeneralizedSparseFactor]) -> None:
    stats.peak_live_entries = max(stats.peak_live_entries, sum(f.nonzero_entries() for f in factors))


def _accumulate_state(out_states: dict[CountState, int], state_key: CountState, addend: int, stats: VEInstrumentation) -> None:
    previous = out_states.get(state_key, 0)
    if previous:
        stats.bigint_additions += 1
    updated = previous + addend
    out_states[state_key] = updated
    if updated:
        stats.max_integer_bit_length = max(stats.max_integer_bit_length, updated.bit_length())
    if addend:
        stats.max_integer_bit_length = max(stats.max_integer_bit_length, addend.bit_length())


def constraint_factor(constraint: AllowedSumConstraint, query: QuerySpec) -> GeneralizedSparseFactor:
    scope = tuple(constraint.variables)
    table: dict[int, dict[CountState, int]] = {}
    allowed = set(constraint.allowed_sums)
    for mask in range(1 << len(scope)):
        if mask.bit_count() not in allowed:
            continue
        table[mask] = {(0, 0): 1}
    return GeneralizedSparseFactor(
        scope=scope,
        table=table,
        mine_capacity=0,
        neighbor_capacity=sum(1 for var in scope if var in query.neighbor_vars),
    )


def join_factors(left: GeneralizedSparseFactor, right: GeneralizedSparseFactor, stats: VEInstrumentation) -> GeneralizedSparseFactor:
    if not left.scope:
        stats.joins += 1
        stats.dense_factor_capacity_touched += left.dense_capacity() + right.dense_capacity()
        stats.nonzero_factor_entries_processed += left.nonzero_entries() + right.nonzero_entries()
        merged = GeneralizedSparseFactor(
            scope=right.scope,
            table={mask: dict(states) for mask, states in right.table.items()},
            mine_capacity=left.mine_capacity + right.mine_capacity,
            neighbor_capacity=left.neighbor_capacity + right.neighbor_capacity,
        )
        stats.factors_created += 1
        _observe_factor(stats, merged)
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

    right_buckets: dict[int, list[tuple[int, dict[CountState, int]]]] = {}
    for right_mask, right_states in right.table.items():
        bucket = _project_mask(right_mask, right_overlap)
        right_buckets.setdefault(bucket, []).append((right_mask, right_states))

    out: dict[int, dict[CountState, int]] = {}
    stats.joins += 1
    stats.dense_factor_capacity_touched += left.dense_capacity() + right.dense_capacity()
    stats.nonzero_factor_entries_processed += left.nonzero_entries() + right.nonzero_entries()
    for left_mask, left_states in left.table.items():
        bucket = _project_mask(left_mask, left_overlap)
        candidates = right_buckets.get(bucket, [])
        left_expanded = _expand_mask(left_mask, left_expand)
        for right_mask, right_states in candidates:
            merged_mask = left_expanded | _expand_mask(right_mask, right_expand)
            out_states = out.setdefault(merged_mask, {})
            for (left_mines, left_neighbors), left_count in left_states.items():
                for (right_mines, right_neighbors), right_count in right_states.items():
                    stats.bigint_multiplications += 1
                    _accumulate_state(
                        out_states,
                        (left_mines + right_mines, left_neighbors + right_neighbors),
                        left_count * right_count,
                        stats,
                    )
    merged = GeneralizedSparseFactor(
        scope=merged_scope,
        table={mask: states for mask, states in out.items() if states},
        mine_capacity=left.mine_capacity + right.mine_capacity,
        neighbor_capacity=left.neighbor_capacity + right.neighbor_capacity,
    )
    stats.factors_created += 1
    stats.induced_width = max(stats.induced_width, max(0, len(merged.scope) - 1))
    stats.max_induced_or_min_fill_width = max(stats.max_induced_or_min_fill_width, stats.induced_width, stats.min_fill_width)
    _observe_factor(stats, merged)
    return merged


def eliminate_variable(factor: GeneralizedSparseFactor, variable: int, query: QuerySpec, stats: VEInstrumentation) -> GeneralizedSparseFactor:
    pos = factor.scope.index(variable)
    out_scope = factor.scope[:pos] + factor.scope[pos + 1 :]
    out: dict[int, dict[CountState, int]] = {}
    stats.marginalizations += 1
    stats.dense_factor_capacity_touched += factor.dense_capacity()
    stats.nonzero_factor_entries_processed += factor.nonzero_entries()
    for mask, states in factor.table.items():
        value = (mask >> pos) & 1
        new_mask = _remove_bit(mask, pos)
        out_states = out.setdefault(new_mask, {})
        for (mines_used, neighbor_mines), count in states.items():
            next_state = (
                mines_used + value,
                neighbor_mines + (value if variable in query.neighbor_vars else 0),
            )
            _accumulate_state(out_states, next_state, count, stats)
    reduced = GeneralizedSparseFactor(
        scope=out_scope,
        table={mask: states for mask, states in out.items() if states},
        mine_capacity=factor.mine_capacity + 1,
        neighbor_capacity=factor.neighbor_capacity,
    )
    stats.factors_created += 1
    _observe_factor(stats, reduced)
    return reduced


def _join_related_factors(factors: list[GeneralizedSparseFactor], stats: VEInstrumentation) -> GeneralizedSparseFactor:
    ordered = sorted(factors, key=lambda factor: (len(factor.scope), factor.nonzero_entries(), factor.scope))
    joined = ordered[0]
    for factor in ordered[1:]:
        joined = join_factors(joined, factor, stats)
    return joined


def execute_component_plan(
    plan: e2.ComponentEliminationPlan,
    query: QuerySpec,
) -> tuple[GeneralizedSparseFactor, VEInstrumentation]:
    stats = VEInstrumentation(min_fill_width=plan.min_fill_width, max_induced_or_min_fill_width=plan.min_fill_width)
    factors = [constraint_factor(constraint, query) for constraint in plan.constraints]  # type: ignore[arg-type]
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
        reduced = eliminate_variable(joined, variable, query, stats)
        factors.append(reduced)
        _observe_live(stats, factors)
    if not factors:
        identity = GeneralizedSparseFactor(scope=(), table={0: {(0, 0): 1}}, mine_capacity=0, neighbor_capacity=0)
        _observe_factor(stats, identity)
        return identity, stats
    final_factor = _join_related_factors(factors, stats)
    _observe_live(stats, [final_factor])
    return final_factor, stats


def ordinary_component_factor(counts: list[int]) -> dict[CountState, int]:
    return {(mines_used, 0): ways for mines_used, ways in enumerate(counts) if ways}


def convolve_joint(
    left: dict[CountState, int],
    right: dict[CountState, int],
    stats: VEInstrumentation | None = None,
) -> dict[CountState, int]:
    out: dict[CountState, int] = {}
    for (left_mines, left_neighbors), left_ways in left.items():
        if left_ways == 0:
            continue
        for (right_mines, right_neighbors), right_ways in right.items():
            if right_ways == 0:
                continue
            key = (left_mines + right_mines, left_neighbors + right_neighbors)
            if stats is not None:
                stats.bigint_multiplications += 1
            product = left_ways * right_ways
            previous = out.get(key, 0)
            if stats is not None and previous:
                stats.bigint_additions += 1
            out[key] = previous + product
            if stats is not None and out[key]:
                stats.max_integer_bit_length = max(stats.max_integer_bit_length, out[key].bit_length())
    return out


def unconstrained_local_factor(unconstrained_neighbor_count: int) -> dict[CountState, int]:
    return {
        (neighbor_mines, neighbor_mines): math.comb(unconstrained_neighbor_count, neighbor_mines)
        for neighbor_mines in range(unconstrained_neighbor_count + 1)
    }


def unconstrained_other_vector(total_cells: int) -> list[int]:
    return [math.comb(total_cells, mines_used) for mines_used in range(total_cells + 1)]


def count_component_ordinary_ve(
    component_vars: list[int],
    component_constraints: list[AllowedSumConstraint],
) -> tuple[list[int], e2.ComponentEliminationPlan, VEInstrumentation]:
    plan = build_generalized_plan(component_vars, component_constraints)
    final_factor, stats = execute_component_plan(plan, QuerySpec())
    counts = [0] * (len(component_vars) + 1)
    for states in final_factor.table.values():
        for (mines_used, neighbor_mines), ways in states.items():
            if neighbor_mines:
                raise AssertionError("componente ordinario no debe acumular neighbor_mines")
            counts[mines_used] += ways
            if counts[mines_used]:
                stats.max_integer_bit_length = max(stats.max_integer_bit_length, counts[mines_used].bit_length())
    return counts, plan, stats


def count_component_query_ve(
    component_vars: list[int],
    component_constraints: list[AllowedSumConstraint],
    neighbor_vars: set[int],
) -> tuple[dict[CountState, int], e2.ComponentEliminationPlan, VEInstrumentation]:
    plan = build_generalized_plan(component_vars, component_constraints)
    final_factor, stats = execute_component_plan(plan, QuerySpec(neighbor_vars=frozenset(neighbor_vars)))
    joint_counts: dict[CountState, int] = {}
    for states in final_factor.table.values():
        for state_key, ways in states.items():
            joint_counts[state_key] = joint_counts.get(state_key, 0) + ways
            if joint_counts[state_key]:
                stats.max_integer_bit_length = max(stats.max_integer_bit_length, joint_counts[state_key].bit_length())
    return joint_counts, plan, stats


def analyze_query_problem_ve(
    state: GeneralizedState,
    cell_index: int,
) -> dict[str, object]:
    if cell_index in state.known_mines:
        raise ValueError("la celda query no puede ser mina conocida")
    if cell_index not in state.known_safe:
        raise ValueError("la celda query debe ser forced-safe / known_safe")

    consistent, constraints, variables, remaining_mines, unconstrained_unknown_count = build_generalized_constraints(state)
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
            "unconstrained_unknown_count": unconstrained_unknown_count,
            "convolutions_performed": 0,
            "components": [],
            "instrumentation": {},
        }

    local_unknown_neighbors = {
        neighbor
        for neighbor in cs.neighbors(state.width, state.height, cell_index)
        if neighbor not in state.known_mines and neighbor not in state.known_safe
    }
    adjacent_known_mines = sum(1 for neighbor in cs.neighbors(state.width, state.height, cell_index) if neighbor in state.known_mines)
    frontier_var_set = set(variables)
    unconstrained_local = sorted(local_unknown_neighbors - frontier_var_set)
    unconstrained_other_count = unconstrained_unknown_count - len(unconstrained_local)
    component_variables, component_constraints = connected_components(variables, constraints)

    aggregate: dict[CountState, int] = {(0, 0): 1}
    convolutions = 0
    components: list[dict[str, object]] = []
    ordinary_component_count = 0
    special_component_count = 0
    total_stats = VEInstrumentation()

    for index, (component_vars, component_constraint_group) in enumerate(zip(component_variables, component_constraints)):
        component_var_set = set(component_vars)
        if not component_var_set.intersection(local_unknown_neighbors):
            solution_vector, plan, stats = count_component_ordinary_ve(component_vars, component_constraint_group)
            factor = ordinary_component_factor(solution_vector)
            ordinary_component_count += 1
            role = "ordinary"
        else:
            factor, plan, stats = count_component_query_ve(
                component_vars=component_vars,
                component_constraints=component_constraint_group,
                neighbor_vars=local_unknown_neighbors.intersection(component_var_set),
            )
            special_component_count += 1
            role = "special"

        aggregate = convolve_joint(aggregate, factor, total_stats)
        convolutions += 1

        total_stats.factors_created += stats.factors_created
        total_stats.joins += stats.joins
        total_stats.marginalizations += stats.marginalizations
        total_stats.dense_factor_capacity_touched += stats.dense_factor_capacity_touched
        total_stats.nonzero_factor_entries_processed += stats.nonzero_factor_entries_processed
        total_stats.bigint_additions += stats.bigint_additions
        total_stats.bigint_multiplications += stats.bigint_multiplications
        total_stats.peak_factor_entries = max(total_stats.peak_factor_entries, stats.peak_factor_entries)
        total_stats.peak_nonzero_factor_entries = max(total_stats.peak_nonzero_factor_entries, stats.peak_nonzero_factor_entries)
        total_stats.peak_live_entries = max(total_stats.peak_live_entries, stats.peak_live_entries)
        total_stats.max_factor_scope_variables = max(total_stats.max_factor_scope_variables, stats.max_factor_scope_variables)
        total_stats.min_fill_width = max(total_stats.min_fill_width, stats.min_fill_width)
        total_stats.induced_width = max(total_stats.induced_width, stats.induced_width)
        total_stats.max_induced_or_min_fill_width = max(
            total_stats.max_induced_or_min_fill_width,
            stats.max_induced_or_min_fill_width,
        )
        total_stats.max_integer_bit_length = max(total_stats.max_integer_bit_length, stats.max_integer_bit_length)

        components.append(
            {
                "component_index": index,
                "role": role,
                "size": len(component_vars),
                "constraint_count": len(component_constraint_group),
                "ordering": list(plan.ordering),
                "min_fill_width": plan.min_fill_width,
                "effective_width": stats.induced_width,
                "peak_factor_entries": stats.peak_factor_entries,
                "peak_nonzero_factor_entries": stats.peak_nonzero_factor_entries,
            }
        )

    if unconstrained_local:
        aggregate = convolve_joint(aggregate, unconstrained_local_factor(len(unconstrained_local)), total_stats)
        convolutions += 1
    if unconstrained_other_count > 0:
        aggregate = convolve_joint(
            aggregate,
            {(mines_used, 0): ways for mines_used, ways in enumerate(unconstrained_other_vector(unconstrained_other_count)) if ways},
            total_stats,
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
        "unconstrained_unknown_count": unconstrained_unknown_count,
        "convolutions_performed": convolutions,
        "components": components,
        "instrumentation": {
            "factors_created": total_stats.factors_created,
            "joins": total_stats.joins,
            "marginalizations": total_stats.marginalizations,
            "dense_factor_capacity_touched": total_stats.dense_factor_capacity_touched,
            "nonzero_factor_entries_processed": total_stats.nonzero_factor_entries_processed,
            "peak_factor_entries": total_stats.peak_factor_entries,
            "peak_nonzero_factor_entries": total_stats.peak_nonzero_factor_entries,
            "peak_live_entries": total_stats.peak_live_entries,
            "bigint_additions": total_stats.bigint_additions,
            "bigint_multiplications": total_stats.bigint_multiplications,
            "max_factor_scope_variables": total_stats.max_factor_scope_variables,
            "max_induced_or_min_fill_width": total_stats.max_induced_or_min_fill_width,
            "max_integer_bit_length": total_stats.max_integer_bit_length,
        },
    }


def analyze_total_state_ve(state: GeneralizedState) -> dict[str, object]:
    consistent, constraints, variables, remaining_mines, unconstrained_unknown_count = build_generalized_constraints(state)
    if not consistent:
        return {
            "consistent": False,
            "remaining_mines": remaining_mines,
            "constraints": [],
            "variables": [],
            "ordinary_component_count": 0,
            "unconstrained_unknown_count": unconstrained_unknown_count,
            "convolutions_performed": 0,
            "instrumentation": {},
            "total_distribution": {},
        }

    component_variables, component_constraints = connected_components(variables, constraints)
    total_distribution: dict[int, int] = {0: 1}
    convolutions = 0
    total_stats = VEInstrumentation()
    for component_vars, component_constraint_group in zip(component_variables, component_constraints):
        solution_vector, _plan, stats = count_component_ordinary_ve(component_vars, component_constraint_group)
        next_distribution: dict[int, int] = {}
        for left_mines, left_ways in total_distribution.items():
            for right_mines, right_ways in enumerate(solution_vector):
                if right_ways == 0:
                    continue
                total_stats.bigint_multiplications += 1
                key = left_mines + right_mines
                previous = next_distribution.get(key, 0)
                if previous:
                    total_stats.bigint_additions += 1
                next_distribution[key] = previous + (left_ways * right_ways)
                total_stats.max_integer_bit_length = max(total_stats.max_integer_bit_length, next_distribution[key].bit_length())
        total_distribution = next_distribution
        convolutions += 1

        total_stats.factors_created += stats.factors_created
        total_stats.joins += stats.joins
        total_stats.marginalizations += stats.marginalizations
        total_stats.dense_factor_capacity_touched += stats.dense_factor_capacity_touched
        total_stats.nonzero_factor_entries_processed += stats.nonzero_factor_entries_processed
        total_stats.bigint_additions += stats.bigint_additions
        total_stats.bigint_multiplications += stats.bigint_multiplications
        total_stats.peak_factor_entries = max(total_stats.peak_factor_entries, stats.peak_factor_entries)
        total_stats.peak_nonzero_factor_entries = max(total_stats.peak_nonzero_factor_entries, stats.peak_nonzero_factor_entries)
        total_stats.peak_live_entries = max(total_stats.peak_live_entries, stats.peak_live_entries)
        total_stats.max_factor_scope_variables = max(total_stats.max_factor_scope_variables, stats.max_factor_scope_variables)
        total_stats.min_fill_width = max(total_stats.min_fill_width, stats.min_fill_width)
        total_stats.induced_width = max(total_stats.induced_width, stats.induced_width)
        total_stats.max_induced_or_min_fill_width = max(total_stats.max_induced_or_min_fill_width, stats.max_induced_or_min_fill_width)
        total_stats.max_integer_bit_length = max(total_stats.max_integer_bit_length, stats.max_integer_bit_length)

    if unconstrained_unknown_count > 0:
        next_distribution = {}
        for left_mines, left_ways in total_distribution.items():
            for right_mines, right_ways in enumerate(unconstrained_other_vector(unconstrained_unknown_count)):
                if right_ways == 0:
                    continue
                total_stats.bigint_multiplications += 1
                key = left_mines + right_mines
                previous = next_distribution.get(key, 0)
                if previous:
                    total_stats.bigint_additions += 1
                next_distribution[key] = previous + (left_ways * right_ways)
                total_stats.max_integer_bit_length = max(total_stats.max_integer_bit_length, next_distribution[key].bit_length())
        total_distribution = next_distribution
        convolutions += 1

    return {
        "consistent": True,
        "remaining_mines": remaining_mines,
        "constraints": constraints,
        "variables": variables,
        "ordinary_component_count": len(component_variables),
        "unconstrained_unknown_count": unconstrained_unknown_count,
        "convolutions_performed": convolutions,
        "total_distribution": total_distribution,
        "instrumentation": {
            "factors_created": total_stats.factors_created,
            "joins": total_stats.joins,
            "marginalizations": total_stats.marginalizations,
            "dense_factor_capacity_touched": total_stats.dense_factor_capacity_touched,
            "nonzero_factor_entries_processed": total_stats.nonzero_factor_entries_processed,
            "peak_factor_entries": total_stats.peak_factor_entries,
            "peak_nonzero_factor_entries": total_stats.peak_nonzero_factor_entries,
            "peak_live_entries": total_stats.peak_live_entries,
            "bigint_additions": total_stats.bigint_additions,
            "bigint_multiplications": total_stats.bigint_multiplications,
            "max_factor_scope_variables": total_stats.max_factor_scope_variables,
            "max_induced_or_min_fill_width": total_stats.max_induced_or_min_fill_width,
            "max_integer_bit_length": total_stats.max_integer_bit_length,
        },
    }


def compatible_total_from_joint_distribution(state: GeneralizedState, joint_distribution: dict[CountState, int]) -> int:
    remaining_mines = state.total_mines - len(state.known_mines)
    return sum(ways for (mines_used, _neighbor_mines), ways in joint_distribution.items() if ways and mines_used == remaining_mines)


def compatible_total_generalized_state(state: GeneralizedState) -> int:
    analysis = analyze_total_state_ve(state)
    if not analysis["consistent"]:
        return 0
    remaining_mines = int(analysis["remaining_mines"])
    return int(analysis["total_distribution"].get(remaining_mines, 0))


def compatible_total_generalized_state_profile(state: GeneralizedState) -> tuple[int, dict[str, object]]:
    analysis = analyze_total_state_ve(state)
    if not analysis["consistent"]:
        return 0, {
            "factors_created": 0,
            "joins": 0,
            "marginalizations": 0,
            "dense_factor_capacity_touched": 0,
            "nonzero_factor_entries_processed": 0,
            "peak_factor_entries": 0,
            "peak_nonzero_factor_entries": 0,
            "peak_live_entries": 0,
            "bigint_additions": 0,
            "bigint_multiplications": 0,
            "max_factor_scope_variables": 0,
            "max_induced_or_min_fill_width": 0,
            "max_integer_bit_length": 0,
            "frontier_variables": 0,
            "constraint_count": 0,
            "unconstrained_unknown_count": int(analysis["unconstrained_unknown_count"]),
            "components": [],
        }
    remaining_mines = int(analysis["remaining_mines"])
    return int(analysis["total_distribution"].get(remaining_mines, 0)), {
        **analysis["instrumentation"],
        "frontier_variables": len(analysis["variables"]),
        "constraint_count": len(analysis["constraints"]),
        "unconstrained_unknown_count": int(analysis["unconstrained_unknown_count"]),
        "components": [],
    }


def exact_clue_counts_from_joint_distribution(
    state: GeneralizedState,
    cell_index: int,
    joint_distribution: dict[CountState, int],
    adjacent_known_mines: int,
) -> dict[str, int]:
    counts = {str(clue): 0 for clue in clue_domain(state.width, state.height, cell_index)}
    remaining_mines = state.total_mines - len(state.known_mines)
    for (mines_used, neighbor_mines), ways in joint_distribution.items():
        if mines_used != remaining_mines or ways == 0:
            continue
        clue_value = adjacent_known_mines + neighbor_mines
        if 0 <= clue_value <= degree(state.width, state.height, cell_index):
            counts[str(clue_value)] += ways
    return counts


def evaluate_safe_cell_exact(state: GeneralizedState, cell_index: int) -> dict[str, object]:
    started = time.perf_counter()
    analysis = analyze_query_problem_ve(state, cell_index)
    if not analysis["consistent"]:
        degree_value = degree(state.width, state.height, cell_index)
        counts = {str(clue): 0 for clue in range(degree_value + 1)}
        return {
            "status": "inconsistent",
            "counts": counts,
            "compatible_total_before_query": 0,
            "sum_counts": 0,
            "partition_ok": True,
            "wall_clock_ms": (time.perf_counter() - started) * 1000.0,
            "query_kind": "exact",
            "instrumentation": {
                "total_solves": 1,
                "binary_classifications": 0,
                "exact_refinements": 1,
                "bigint_additions": 0,
                "bigint_multiplications": 0,
                "dense_factor_capacity_touched": 0,
                "nonzero_factor_entries_processed": 0,
                "peak_nonzero_factor_entries": 0,
                "peak_factor_entries": 0,
                "max_factor_scope_variables": 0,
                "max_induced_or_min_fill_width": 0,
                "max_integer_bit_length": 0,
            },
        }
    counts = exact_clue_counts_from_joint_distribution(
        state=state,
        cell_index=cell_index,
        joint_distribution=analysis["joint_distribution"],
        adjacent_known_mines=int(analysis["adjacent_known_mines"]),
    )
    compatible_total = compatible_total_from_joint_distribution(state, analysis["joint_distribution"])
    sum_counts = sum(counts.values())
    partition_ok = sum_counts == compatible_total
    instrumentation = dict(analysis["instrumentation"])
    instrumentation.update({
        "total_solves": 1,
        "binary_classifications": 0,
        "exact_refinements": 1,
    })
    return {
        "status": "ok",
        "counts": counts,
        "compatible_total_before_query": compatible_total,
        "sum_counts": sum_counts,
        "partition_ok": partition_ok,
        "query_kind": "exact",
        "frontier_variables": len(analysis["variables"]),
        "constraint_count": len(analysis["constraints"]),
        "unconstrained_unknown_count": int(analysis["unconstrained_unknown_count"]),
        "components": analysis["components"],
        "instrumentation": instrumentation,
        "wall_clock_ms": (time.perf_counter() - started) * 1000.0,
    }


def evaluate_safe_cell_binary(state: GeneralizedState, cell_index: int) -> dict[str, object]:
    started = time.perf_counter()
    current_compatible_total = compatible_total_generalized_state(state)
    zero_state = with_allowed_clues(state, cell_index, {0})
    zero_total, zero_profile = compatible_total_generalized_state_profile(zero_state)
    positive_total = current_compatible_total - zero_total
    partition_ok = zero_total + positive_total == current_compatible_total
    counts = {"0": zero_total, ">0": positive_total}
    return {
        "status": "ok",
        "counts": counts,
        "compatible_total_before_query": current_compatible_total,
        "sum_counts": sum(counts.values()),
        "partition_ok": partition_ok,
        "query_kind": "binary",
        "frontier_variables": zero_profile["frontier_variables"],
        "constraint_count": zero_profile["constraint_count"],
        "unconstrained_unknown_count": zero_profile["unconstrained_unknown_count"],
        "components": zero_profile["components"],
        "instrumentation": {
            "total_solves": 1,
            "binary_classifications": 1,
            "exact_refinements": 0,
            "bigint_additions": int(zero_profile["bigint_additions"]),
            "bigint_multiplications": int(zero_profile["bigint_multiplications"]),
            "dense_factor_capacity_touched": int(zero_profile["dense_factor_capacity_touched"]),
            "nonzero_factor_entries_processed": int(zero_profile["nonzero_factor_entries_processed"]),
            "peak_nonzero_factor_entries": int(zero_profile["peak_nonzero_factor_entries"]),
            "peak_factor_entries": int(zero_profile["peak_factor_entries"]),
            "max_factor_scope_variables": int(zero_profile["max_factor_scope_variables"]),
            "max_induced_or_min_fill_width": int(zero_profile["max_induced_or_min_fill_width"]),
            "max_integer_bit_length": max(
                int(zero_profile["max_integer_bit_length"]),
                current_compatible_total.bit_length() if current_compatible_total else 0,
                zero_total.bit_length() if zero_total else 0,
                positive_total.bit_length() if positive_total else 0,
            ),
        },
        "wall_clock_ms": (time.perf_counter() - started) * 1000.0,
    }


def oracle_wave_structure(before_transcript: cs.Transcript, after_transcript: cs.Transcript, clicked_cell: int) -> list[list[int]]:
    before_revealed = set(before_transcript.revealed_clues)
    after_revealed = set(after_transcript.revealed_clues)
    new_revealed = after_revealed - before_revealed
    if clicked_cell not in new_revealed:
        raise AssertionError("el click inicial debe formar parte de la cascada reconstruida")
    seen = {clicked_cell}
    zero_sources = [clicked_cell]
    waves: list[list[int]] = []
    while zero_sources:
        frontier: set[int] = set()
        for zero_cell in zero_sources:
            for neighbor in cs.neighbors(after_transcript.width, after_transcript.height, zero_cell):
                if neighbor in new_revealed and neighbor not in seen:
                    frontier.add(neighbor)
        wave = sorted(frontier)
        if not wave:
            break
        waves.append(wave)
        seen.update(wave)
        zero_sources = [cell for cell in wave if after_transcript.revealed_clues[cell] == 0]
    if seen != new_revealed:
        missing = sorted(new_revealed - seen)
        raise AssertionError(f"wave structure incompleta: faltan {missing[:10]}")
    return waves


def validation_wave_structure_2f(before_transcript: cs.Transcript, after_transcript: cs.Transcript, clicked_cell: int) -> list[list[int]]:
    return oracle_wave_structure(before_transcript, after_transcript, clicked_cell)


def merge_policy_metrics(accum: dict[str, int], instrumentation: dict[str, object]) -> None:
    for key in (
        "bigint_additions",
        "bigint_multiplications",
        "dense_factor_capacity_touched",
        "nonzero_factor_entries_processed",
        "peak_nonzero_factor_entries",
        "peak_factor_entries",
        "max_factor_scope_variables",
        "max_induced_or_min_fill_width",
        "max_integer_bit_length",
        "total_solves",
        "binary_classifications",
        "exact_refinements",
    ):
        value = int(instrumentation.get(key, 0))
        if key.startswith("peak_") or key.startswith("max_"):
            accum[key] = max(accum.get(key, 0), value)
        else:
            accum[key] = accum.get(key, 0) + value


def final_state_as_exact_transcript(state: GeneralizedState) -> dict[int, int]:
    out: dict[int, int] = {}
    for cell_index, allowed in state.allowed_clues:
        if len(allowed) != 1:
            raise AssertionError(f"la celda {cell_index} no quedó con clue exacto")
        out[cell_index] = allowed[0]
    return out


def simulate_policy_on_oracle_flood_fill(
    before_transcript: cs.Transcript,
    after_transcript: cs.Transcript,
    clicked_cell: int,
    policy: str,
) -> dict[str, object]:
    if policy not in ALL_POLICIES:
        raise ValueError(policy)
    if after_transcript.revealed_clues[clicked_cell] != 0:
        raise ValueError("2F sólo aplica a flood-fills con click inicial exacto 0")

    initial_state = with_allowed_clues(state_from_transcript(before_transcript), clicked_cell, {0})
    initial_compatible = compatible_total_generalized_state(initial_state)
    oracle_clues = after_transcript.revealed_clues
    state = initial_state
    current_compatible_total = initial_compatible
    pending_positive_cells: set[int] = set()
    steps: list[dict[str, object]] = []
    path_probability = Fraction(1, 1)
    total_metrics: dict[str, int] = {
        "bigint_additions": 0,
        "bigint_multiplications": 0,
        "dense_factor_capacity_touched": 0,
        "nonzero_factor_entries_processed": 0,
        "peak_nonzero_factor_entries": 0,
        "peak_factor_entries": 0,
        "max_factor_scope_variables": 0,
        "max_induced_or_min_fill_width": 0,
        "max_integer_bit_length": 0,
        "total_solves": 0,
        "binary_classifications": 0,
        "exact_refinements": 0,
    }
    all_partitions_ok = True
    waves: list[list[int]] = []
    current_wave = sorted(
        neighbor
        for neighbor in cs.neighbors(state.width, state.height, clicked_cell)
        if neighbor not in state.known_safe and neighbor not in state.known_mines
    )

    while current_wave:
        waves.append(list(current_wave))
        wave_index = len(waves)
        wave_cells = current_wave
        state = with_known_safe(state, wave_cells)
        wave_positive_cells: list[int] = []
        next_wave_candidates: set[int] = set()
        for cell_index in wave_cells:
            if policy == POLICY_CELL:
                result = evaluate_safe_cell_exact(state, cell_index)
                chosen_key = str(oracle_clues[cell_index])
                chosen_count = int(result["counts"][chosen_key])
                if int(result["compatible_total_before_query"]) != current_compatible_total:
                    raise AssertionError("compatible_total_before_query exact no coincide con el invariante propagado")
                path_probability *= Fraction(chosen_count, current_compatible_total)
                state = with_allowed_clues(state, cell_index, {oracle_clues[cell_index]})
                current_compatible_total = chosen_count
                if oracle_clues[cell_index] == 0:
                    next_wave_candidates.update(
                        neighbor
                        for neighbor in cs.neighbors(state.width, state.height, cell_index)
                        if neighbor not in state.known_safe and neighbor not in state.known_mines
                    )
            else:
                result = evaluate_safe_cell_binary(state, cell_index)
                observed_positive = oracle_clues[cell_index] > 0
                chosen_key = ">0" if observed_positive else "0"
                chosen_count = int(result["counts"][chosen_key])
                if int(result["compatible_total_before_query"]) != current_compatible_total:
                    raise AssertionError("compatible_total_before_query binary no coincide con el invariante propagado")
                path_probability *= Fraction(chosen_count, current_compatible_total)
                if observed_positive:
                    positive_domain = positive_clue_domain(state.width, state.height, cell_index)
                    state = with_allowed_clues(state, cell_index, positive_domain)
                    wave_positive_cells.append(cell_index)
                    pending_positive_cells.add(cell_index)
                    current_compatible_total = chosen_count
                else:
                    state = with_allowed_clues(state, cell_index, {0})
                    current_compatible_total = chosen_count
                    next_wave_candidates.update(
                        neighbor
                        for neighbor in cs.neighbors(state.width, state.height, cell_index)
                        if neighbor not in state.known_safe and neighbor not in state.known_mines
                    )

            merge_policy_metrics(total_metrics, result["instrumentation"])
            all_partitions_ok = all_partitions_ok and bool(result["partition_ok"])
            steps.append(
                {
                    "policy": policy,
                    "wave_index": wave_index,
                    "stage": "classify",
                    "cell_index": cell_index,
                    "oracle_clue": oracle_clues[cell_index],
                    "query_kind": result["query_kind"],
                    "counts": result["counts"],
                    "compatible_total_before_solve": result["compatible_total_before_query"],
                    "partition_ok": result["partition_ok"],
                    "chosen_key": chosen_key,
                    "chosen_count": chosen_count,
                    "path_probability_numerator": path_probability.numerator,
                    "path_probability_denominator": path_probability.denominator,
                    "wall_clock_ms": result["wall_clock_ms"],
                }
            )

        if policy == POLICY_WAVE:
            for cell_index in sorted(wave_positive_cells):
                result = evaluate_safe_cell_exact(state, cell_index)
                chosen_key = str(oracle_clues[cell_index])
                chosen_count = int(result["counts"][chosen_key])
                if int(result["compatible_total_before_query"]) != current_compatible_total:
                    raise AssertionError("compatible_total_before_query refine no coincide con el invariante propagado")
                path_probability *= Fraction(chosen_count, current_compatible_total)
                state = with_allowed_clues(state, cell_index, {oracle_clues[cell_index]})
                current_compatible_total = chosen_count
                pending_positive_cells.remove(cell_index)
                merge_policy_metrics(total_metrics, result["instrumentation"])
                all_partitions_ok = all_partitions_ok and bool(result["partition_ok"])
                steps.append(
                    {
                        "policy": policy,
                        "wave_index": wave_index,
                        "stage": "refine-positive",
                        "cell_index": cell_index,
                        "oracle_clue": oracle_clues[cell_index],
                        "query_kind": result["query_kind"],
                        "counts": result["counts"],
                        "compatible_total_before_solve": result["compatible_total_before_query"],
                        "partition_ok": result["partition_ok"],
                        "chosen_key": chosen_key,
                        "chosen_count": chosen_count,
                        "path_probability_numerator": path_probability.numerator,
                        "path_probability_denominator": path_probability.denominator,
                        "wall_clock_ms": result["wall_clock_ms"],
                    }
                )

        current_wave = sorted(
            neighbor
            for neighbor in next_wave_candidates
            if neighbor not in state.known_safe and neighbor not in state.known_mines
        )

    if policy == POLICY_FULL_REGION and pending_positive_cells:
        for cell_index in sorted(pending_positive_cells):
            result = evaluate_safe_cell_exact(state, cell_index)
            chosen_key = str(oracle_clues[cell_index])
            chosen_count = int(result["counts"][chosen_key])
            if int(result["compatible_total_before_query"]) != current_compatible_total:
                raise AssertionError("compatible_total_before_query region refine no coincide con el invariante propagado")
            path_probability *= Fraction(chosen_count, current_compatible_total)
            state = with_allowed_clues(state, cell_index, {oracle_clues[cell_index]})
            current_compatible_total = chosen_count
            merge_policy_metrics(total_metrics, result["instrumentation"])
            all_partitions_ok = all_partitions_ok and bool(result["partition_ok"])
            steps.append(
                {
                    "policy": policy,
                    "wave_index": None,
                    "stage": "refine-region-positive",
                    "cell_index": cell_index,
                    "oracle_clue": oracle_clues[cell_index],
                    "query_kind": result["query_kind"],
                    "counts": result["counts"],
                    "compatible_total_before_solve": result["compatible_total_before_query"],
                    "partition_ok": result["partition_ok"],
                    "chosen_key": chosen_key,
                    "chosen_count": chosen_count,
                    "path_probability_numerator": path_probability.numerator,
                    "path_probability_denominator": path_probability.denominator,
                    "wall_clock_ms": result["wall_clock_ms"],
                }
            )

    final_counts = final_state_as_exact_transcript(state)
    final_analysis = build_generalized_constraints(state)
    final_consistent = final_analysis[0]
    policy_wall_clock_ms = sum(float(step["wall_clock_ms"]) for step in steps)
    validation_started = time.perf_counter()
    compatible_final_validation = 0 if not final_consistent else compatible_total_generalized_state(state)
    expected_waves = validation_wave_structure_2f(before_transcript, after_transcript, clicked_cell)
    final_transcript_match = final_counts == after_transcript.revealed_clues
    path_identity_ok = Fraction(path_probability.numerator, path_probability.denominator) == Fraction(
        compatible_final_validation,
        initial_compatible,
    )
    validation_wave_match = len(waves) == len(expected_waves)
    validation_wall_clock_ms = (time.perf_counter() - validation_started) * 1000.0
    status = "ok" if all_partitions_ok and final_transcript_match and path_identity_ok else "invalid"

    return {
        "status": status,
        "policy": policy,
        "wave_count": len(waves),
        "waves": waves,
        "validation_expected_wave_count": len(expected_waves),
        "step_count": len(steps),
        "steps": steps,
        "path_probability_numerator": path_probability.numerator,
        "path_probability_denominator": path_probability.denominator,
        "path_probability": f"{path_probability.numerator}/{path_probability.denominator}",
        "compatible_initial_after_clicked_zero": initial_compatible,
        "compatible_final": current_compatible_total,
        "compatible_final_validation": compatible_final_validation,
        "all_partitions_ok": all_partitions_ok,
        "final_transcript_match": final_transcript_match,
        "path_identity_ok": path_identity_ok,
        "validation_wave_match": validation_wave_match,
        "final_exact_clues": [{"index": index, "clue": clue} for index, clue in sorted(final_counts.items())],
        "final_known_safe": sorted(state.known_safe),
        "instrumentation": total_metrics,
        "policy_wall_clock_ms": policy_wall_clock_ms,
        "validation": {
            "wall_clock_ms": validation_wall_clock_ms,
            "compatible_initial_after_clicked_zero": initial_compatible,
            "compatible_final": compatible_final_validation,
            "expected_wave_count": len(expected_waves),
            "final_transcript_match": final_transcript_match,
            "path_identity_ok": path_identity_ok,
            "wave_count_match": validation_wave_match,
        },
    }


def load_history_rows(path: Path) -> list[dict[str, object]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def index_history_rows(rows: list[dict[str, object]]) -> dict[tuple[str, int], dict[str, object]]:
    return {(str(row["history_id"]), int(row["click_number"])): row for row in rows}


def selected_smoke_cases(structure_path: Path = STRUCTURE_PATH) -> list[dict[str, object]]:
    rows = [json.loads(line) for line in structure_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    candidates = [row for row in rows if row["flood_fill"] and row["after_transcript_reconstructable"]]
    by_reason: list[tuple[str, dict[str, object]]] = []
    by_reason.append(("min_cascade", min(candidates, key=lambda row: (row["new_revealed"], row["history_id"], row["click_number"]))))
    by_reason.append(("median_cascade", min(candidates, key=lambda row: (abs(row["new_revealed"] - 14.5), row["new_revealed"], row["history_id"], row["click_number"]))))
    by_reason.append(("max_cascade", max(candidates, key=lambda row: (row["new_revealed"], row["history_id"], row["click_number"]))))
    by_reason.append(("max_wave_count", max(candidates, key=lambda row: (row["wave_count"], row["history_id"], row["click_number"]))))
    dedup: dict[tuple[str, int], dict[str, object]] = {}
    for reason, row in by_reason:
        key = (str(row["history_id"]), int(row["click_number"]))
        if key not in dedup:
            dedup[key] = {
                "history_id": key[0],
                "click_number": key[1],
                "reasons": [reason],
                "new_revealed": int(row["new_revealed"]),
                "wave_count": int(row["wave_count"]),
            }
        else:
            dedup[key]["reasons"].append(reason)
    return list(dedup.values())


def existing_smoke_rows(path: Path) -> dict[tuple[str, int, str], dict[str, object]]:
    existing: dict[tuple[str, int, str], dict[str, object]] = {}
    if not path.exists():
        return existing
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        key = (str(row["history_id"]), int(row["click_number"]), str(row["policy"]))
        existing[key] = row
    return existing


def _timeout_row(history_id: str, click_number: int, policy: str, timeout_s: float, reasons: list[str], elapsed_ms: float) -> dict[str, object]:
    return {
        "history_id": history_id,
        "click_number": click_number,
        "policy": policy,
        "status": "timeout",
        "timeout_s": timeout_s,
        "wall_clock_ms": None,
        "wall_clock_ms_lower_bound": max(timeout_s * 1000.0, elapsed_ms),
        "wall_clock_observation": "right_censored",
        "selection_reasons": reasons,
    }


def _smoke_case_result(case_row: dict[str, object], next_row: dict[str, object] | None, policy: str, timeout_s: float) -> dict[str, object]:
    before_transcript = transcript_from_history_row(case_row)
    after_transcript, after_source = build_after_transcript(case_row, next_row)
    if after_transcript is None:
        return {
            "history_id": str(case_row["history_id"]),
            "click_number": int(case_row["click_number"]),
            "policy": policy,
            "status": "skipped",
            "skip_reason": after_source,
        }
    started = time.perf_counter()
    try:
        with _SignalTimeout(timeout_s):
            result = simulate_policy_on_oracle_flood_fill(
                before_transcript=before_transcript,
                after_transcript=after_transcript,
                clicked_cell=int(case_row["clicked_cell"]["index"]),
                policy=policy,
            )
    except OfficialTimeout:
        elapsed_ms = (time.perf_counter() - started) * 1000.0
        return _timeout_row(
            history_id=str(case_row["history_id"]),
            click_number=int(case_row["click_number"]),
            policy=policy,
            timeout_s=timeout_s,
            reasons=[],
            elapsed_ms=elapsed_ms,
        )
    result.update(
        {
            "history_id": str(case_row["history_id"]),
            "click_number": int(case_row["click_number"]),
            "clicked_cell": int(case_row["clicked_cell"]["index"]),
            "after_source": after_source,
            "timeout_s": timeout_s,
            "wall_clock_ms": float(result["policy_wall_clock_ms"]),
            "validation_wall_clock_ms": float(result["validation"]["wall_clock_ms"]),
            "history_label_before": before_transcript.label,
            "history_label_after": after_transcript.label,
        }
    )
    return result


def run_smoke(
    benchmark_path: Path = SMOKE_PATH,
    summary_path: Path = SMOKE_SUMMARY_PATH,
    timeout_s: float = OFFICIAL_TIMEOUT_S,
) -> dict[str, object]:
    cases = selected_smoke_cases()
    rows = load_history_rows(HISTORIES_PATH)
    indexed = index_history_rows(rows)
    existing = existing_smoke_rows(benchmark_path)
    benchmark_path.parent.mkdir(parents=True, exist_ok=True)
    written = 0
    with benchmark_path.open("a", encoding="utf-8") as handle:
        for case in cases:
            key = (case["history_id"], case["click_number"])
            case_row = indexed[(case["history_id"], case["click_number"])]
            next_row = indexed.get((case["history_id"], case["click_number"] + 1))
            for policy in ALL_POLICIES:
                row_key = (case["history_id"], case["click_number"], policy)
                if row_key in existing:
                    continue
                result = _smoke_case_result(case_row, next_row, policy, timeout_s)
                result["selection_reasons"] = list(case["reasons"])
                result["new_revealed"] = int(case["new_revealed"])
                result["wave_count_oracle"] = int(case["wave_count"])
                handle.write(json.dumps(result, sort_keys=True) + "\n")
                handle.flush()
                existing[row_key] = result
                written += 1
    summary = smoke_summary(benchmark_path)
    summary_path.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return {
        "benchmark_path": str(benchmark_path),
        "summary_path": str(summary_path),
        "selected_cases": cases,
        "rows_written": written,
        "total_rows_available": len(existing),
    }


def smoke_summary(path: Path = SMOKE_PATH) -> dict[str, object]:
    rows = list(existing_smoke_rows(path).values())
    by_policy: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_policy[str(row["policy"])].append(row)
    summary: dict[str, object] = {"rows": len(rows), "policies": {}}
    for policy, policy_rows in sorted(by_policy.items()):
        ok_rows = [row for row in policy_rows if row["status"] == "ok"]
        wall = [float(row["wall_clock_ms"]) for row in ok_rows if row.get("wall_clock_ms") is not None]
        summary["policies"][policy] = {
            "rows": len(policy_rows),
            "ok": len(ok_rows),
            "timeouts": sum(1 for row in policy_rows if row["status"] == "timeout"),
            "invalid": sum(1 for row in policy_rows if row["status"] == "invalid"),
            "wall_clock_ms_median": statistics.median(wall) if wall else None,
            "wall_clock_ms_max": max(wall) if wall else None,
            "solve_count_sum": sum(int(row.get("instrumentation", {}).get("total_solves", 0)) for row in ok_rows),
            "binary_classifications_sum": sum(int(row.get("instrumentation", {}).get("binary_classifications", 0)) for row in ok_rows),
            "exact_refinements_sum": sum(int(row.get("instrumentation", {}).get("exact_refinements", 0)) for row in ok_rows),
            "bigint_additions_sum": sum(int(row.get("instrumentation", {}).get("bigint_additions", 0)) for row in ok_rows),
            "bigint_multiplications_sum": sum(int(row.get("instrumentation", {}).get("bigint_multiplications", 0)) for row in ok_rows),
            "nonzero_factor_entries_processed_sum": sum(int(row.get("instrumentation", {}).get("nonzero_factor_entries_processed", 0)) for row in ok_rows),
            "dense_factor_capacity_touched_sum": sum(int(row.get("instrumentation", {}).get("dense_factor_capacity_touched", 0)) for row in ok_rows),
            "peak_nonzero_factor_entries_max": max((int(row.get("instrumentation", {}).get("peak_nonzero_factor_entries", 0)) for row in ok_rows), default=0),
            "max_factor_scope_variables_max": max((int(row.get("instrumentation", {}).get("max_factor_scope_variables", 0)) for row in ok_rows), default=0),
            "max_induced_or_min_fill_width_max": max((int(row.get("instrumentation", {}).get("max_induced_or_min_fill_width", 0)) for row in ok_rows), default=0),
            "max_integer_bit_length_max": max((int(row.get("instrumentation", {}).get("max_integer_bit_length", 0)) for row in ok_rows), default=0),
        }
    return summary


def main() -> int:
    parser = argparse.ArgumentParser(description="2F flood-fill refinement horizon")
    parser.add_argument("--run-smoke", action="store_true")
    parser.add_argument("--smoke-path", type=Path, default=SMOKE_PATH)
    parser.add_argument("--summary-path", type=Path, default=SMOKE_SUMMARY_PATH)
    parser.add_argument("--timeout-s", type=float, default=OFFICIAL_TIMEOUT_S)
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()

    if args.run_smoke:
        print(json.dumps(run_smoke(benchmark_path=args.smoke_path, summary_path=args.summary_path, timeout_s=args.timeout_s), indent=2, sort_keys=True))
        return 0
    if args.summary:
        print(json.dumps(smoke_summary(args.smoke_path), indent=2, sort_keys=True))
        return 0
    parser.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
