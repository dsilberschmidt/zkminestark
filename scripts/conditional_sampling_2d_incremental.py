#!/usr/bin/env python3
"""
EXPERIMENTO 2D — history-aware / incremental.

Mantiene estado exacto entre transcripts consecutivos y compara el coste de:
- 2B3 desde cero en T_i
- 2D incremental llegando a T_i desde T_{i-1}
"""

from __future__ import annotations

import math
import time
from collections import defaultdict
from dataclasses import dataclass

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_exact as cs


@dataclass(frozen=True)
class ComponentSignature:
    variables: tuple[int, ...]
    constraints: tuple[tuple[tuple[int, ...], int], ...]


@dataclass
class CachedComponent:
    signature: ComponentSignature
    variables: tuple[int, ...]
    constraints: tuple[cs.Constraint, ...]
    profile: cs.ComponentProfile | None
    profile_source: str


@dataclass
class IncrementalTransition:
    mode: str
    kind: str
    reused_components: int
    invalidated_components: int
    changed_components: int
    eagerly_counted_components: int
    deferred_components: int
    reused_component_sizes: list[int]
    changed_component_sizes: list[int]
    eagerly_counted_component_sizes: list[int]
    deferred_component_sizes: list[int]
    search_nodes: int
    branch_ops: int
    memo_entries: int
    dp_states_explored: int
    persistent_state_size: int


@dataclass
class IncrementalState:
    transcript: cs.Transcript
    consistent: bool
    remaining_mines: int
    constraints: list[cs.Constraint]
    variables: list[int]
    unconstrained_closed_cells: int
    component_variables: list[list[int]]
    component_constraints: list[list[cs.Constraint]]
    components: list[CachedComponent]
    last_transition: IncrementalTransition


def component_signature(component_vars: list[int], component_constraints: list[cs.Constraint]) -> ComponentSignature:
    return ComponentSignature(
        variables=tuple(component_vars),
        constraints=tuple((constraint.variables, constraint.rhs) for constraint in component_constraints),
    )


def persistent_state_size(
    constraints: list[cs.Constraint],
    variables: list[int],
    components: list[CachedComponent],
) -> int:
    return (
        len(constraints)
        + len(variables)
        + sum(len(component.profile.solution_vector) for component in components if component.profile is not None)
        + sum(len(component.variables) for component in components)
    )


def build_state(
    transcript: cs.Transcript,
    previous_state: IncrementalState | None = None,
    budget: cs.BudgetContext | None = None,
    mode: str = "2D0",
) -> IncrementalState:
    consistent, constraints, variables, remaining_mines = cs.build_constraints(transcript)
    if not consistent:
        transition = IncrementalTransition(
            mode=mode,
            kind="init" if previous_state is None else "update",
            reused_components=0,
            invalidated_components=0 if previous_state is None else len(previous_state.components),
            changed_components=0,
            eagerly_counted_components=0,
            deferred_components=0,
            reused_component_sizes=[],
            changed_component_sizes=[],
            eagerly_counted_component_sizes=[],
            deferred_component_sizes=[],
            search_nodes=0,
            branch_ops=0,
            memo_entries=0,
            dp_states_explored=0,
            persistent_state_size=0,
        )
        return IncrementalState(
            transcript=transcript,
            consistent=False,
            remaining_mines=remaining_mines,
            constraints=[],
            variables=[],
            unconstrained_closed_cells=0,
            component_variables=[],
            component_constraints=[],
            components=[],
            last_transition=transition,
        )

    component_variables, component_constraints = cs.connected_components(variables, constraints)
    closed_cells = transcript.closed_cells()
    unconstrained_closed_cells = len([cell for cell in closed_cells if cell not in set(variables)])

    previous_by_signature: dict[ComponentSignature, list[CachedComponent]] = defaultdict(list)
    if previous_state is not None:
        for component in previous_state.components:
            previous_by_signature[component.signature].append(component)

    components: list[CachedComponent] = []
    reused_component_sizes: list[int] = []
    changed_component_sizes: list[int] = []
    eagerly_counted_component_sizes: list[int] = []
    deferred_component_sizes: list[int] = []
    search_nodes = 0
    branch_ops = 0
    memo_entries = 0
    dp_states_explored = 0
    reused_components = 0

    for component_vars, component_constraint_group in zip(component_variables, component_constraints):
        signature = component_signature(component_vars, component_constraint_group)
        if previous_by_signature[signature]:
            cached = previous_by_signature[signature].pop()
            components.append(
                CachedComponent(
                    signature=signature,
                    variables=tuple(component_vars),
                    constraints=tuple(component_constraint_group),
                    profile=cached.profile,
                    profile_source=cached.profile_source,
                )
            )
            reused_components += 1
            reused_component_sizes.append(len(component_vars))
            continue

        changed_component_sizes.append(len(component_vars))
        if mode == "2D1":
            components.append(
                CachedComponent(
                    signature=signature,
                    variables=tuple(component_vars),
                    constraints=tuple(component_constraint_group),
                    profile=None,
                    profile_source="deferred",
                )
            )
            deferred_component_sizes.append(len(component_vars))
        else:
            profile = cs.count_component(component_vars, component_constraint_group, budget=budget)
            components.append(
                CachedComponent(
                    signature=signature,
                    variables=tuple(component_vars),
                    constraints=tuple(component_constraint_group),
                    profile=profile,
                    profile_source="transition",
                )
            )
            eagerly_counted_component_sizes.append(len(component_vars))
            search_nodes += profile.search_nodes
            branch_ops += profile.branch_ops
            memo_entries += profile.memo_entries
            dp_states_explored += profile.dp_states_explored

    invalidated_components = 0
    if previous_state is not None:
        invalidated_components = len(previous_state.components) - reused_components

    transition = IncrementalTransition(
        mode=mode,
        kind="init" if previous_state is None else "update",
        reused_components=reused_components,
        invalidated_components=invalidated_components,
        changed_components=len(changed_component_sizes),
        eagerly_counted_components=len(eagerly_counted_component_sizes),
        deferred_components=len(deferred_component_sizes),
        reused_component_sizes=reused_component_sizes,
        changed_component_sizes=changed_component_sizes,
        eagerly_counted_component_sizes=eagerly_counted_component_sizes,
        deferred_component_sizes=deferred_component_sizes,
        search_nodes=search_nodes,
        branch_ops=branch_ops,
        memo_entries=memo_entries,
        dp_states_explored=dp_states_explored,
        persistent_state_size=persistent_state_size(constraints, variables, components),
    )
    return IncrementalState(
        transcript=transcript,
        consistent=True,
        remaining_mines=remaining_mines,
        constraints=constraints,
        variables=variables,
        unconstrained_closed_cells=unconstrained_closed_cells,
        component_variables=component_variables,
        component_constraints=component_constraints,
        components=components,
        last_transition=transition,
    )


def ordinary_component_factor(profile: cs.ComponentProfile) -> dict[tuple[int, int, int], int]:
    return b3.ordinary_component_factor(profile)


def evaluate_candidate_with_state(
    state: IncrementalState,
    cell_index: int,
    budget: cs.BudgetContext | None = None,
) -> dict[str, object]:
    local_hidden, local_neighbors, adjacent_known_mines = b3.local_hidden_sets(state.transcript, cell_index)
    aggregate: dict[tuple[int, int, int], int] = {(0, 0, 0): 1}
    convolutions = 0
    search_nodes = 0
    branch_ops = 0
    leaf_solutions = 0
    memo_entries = 0
    dp_states_explored = 0
    reused_components = 0
    materialized_ordinary_components = 0
    materialized_ordinary_component_sizes: list[int] = []
    ordinary_materialization_nodes = 0
    ordinary_materialization_branch_ops = 0
    recomputed_special_components = 0
    recomputed_component_sizes: list[int] = []
    special_evaluation_nodes = 0
    special_evaluation_branch_ops = 0
    special_from_transition_count = 0
    special_from_deferred_count = 0

    for idx, (cached, component_vars, component_constraint_group) in enumerate(zip(
        state.components,
        state.component_variables,
        state.component_constraints,
    )):
        component_var_set = set(component_vars)
        if component_var_set.intersection(local_hidden):
            joint_profile = b3.count_component_joint(
                component_vars=component_vars,
                component_constraints=component_constraint_group,
                x_var=cell_index if cell_index in component_var_set else None,
                neighbor_vars=local_neighbors.intersection(component_var_set),
                budget=budget,
            )
            factor = joint_profile.joint_counts
            recomputed_special_components += 1
            recomputed_component_sizes.append(len(component_vars))
            if cached.profile_source == "transition":
                special_from_transition_count += 1
            elif cached.profile_source == "deferred":
                special_from_deferred_count += 1
            search_nodes += joint_profile.search_nodes
            branch_ops += joint_profile.branch_ops
            leaf_solutions += joint_profile.leaf_solutions
            memo_entries += joint_profile.memo_entries
            dp_states_explored += joint_profile.dp_states_explored
            special_evaluation_nodes += joint_profile.search_nodes
            special_evaluation_branch_ops += joint_profile.branch_ops
        else:
            if cached.profile is None:
                profile = cs.count_component(component_vars, component_constraint_group, budget=budget)
                state.components[idx] = CachedComponent(
                    signature=cached.signature,
                    variables=cached.variables,
                    constraints=cached.constraints,
                    profile=profile,
                    profile_source="evaluation-ordinary",
                )
                factor = ordinary_component_factor(profile)
                materialized_ordinary_components += 1
                materialized_ordinary_component_sizes.append(len(component_vars))
                search_nodes += profile.search_nodes
                branch_ops += profile.branch_ops
                leaf_solutions += profile.leaf_solutions
                memo_entries += profile.memo_entries
                dp_states_explored += profile.dp_states_explored
                ordinary_materialization_nodes += profile.search_nodes
                ordinary_materialization_branch_ops += profile.branch_ops
            else:
                factor = ordinary_component_factor(cached.profile)
                reused_components += 1
        aggregate = b3.convolve_joint(aggregate, factor)
        convolutions += 1

    frontier_var_set = set(state.variables)
    unconstrained_local = sorted(local_hidden - frontier_var_set)
    unconstrained_other_count = state.unconstrained_closed_cells - len(unconstrained_local)
    if unconstrained_local:
        aggregate = b3.convolve_joint(
            aggregate,
            b3.unconstrained_local_factor(
                x_is_unconstrained=cell_index in unconstrained_local,
                unconstrained_neighbor_count=sum(1 for cell in unconstrained_local if cell in local_neighbors),
            ),
        )
        convolutions += 1

    if unconstrained_other_count > 0:
        aggregate = b3.convolve_joint(
            aggregate,
            {
                (mines_used, 0, 0): ways
                for mines_used, ways in enumerate(b3.unconstrained_other_vector(unconstrained_other_count))
                if ways
            },
        )
        convolutions += 1

    counts = b3.counts_from_joint_distribution(
        transcript=state.transcript,
        cell_index=cell_index,
        joint_distribution=aggregate,
        adjacent_known_mines=adjacent_known_mines,
    )
    compatible_total = b3.compatible_total_from_joint_distribution(
        transcript=state.transcript,
        joint_distribution=aggregate,
    )
    return {
        "status": "ok",
        "counts": counts,
        "sum_counts": sum(counts.values()),
        "compatible_total_before_click": compatible_total,
        "partition_ok": sum(counts.values()) == compatible_total,
        "outcomes_positive": sum(1 for value in counts.values() if value > 0),
        "total_search_nodes": search_nodes,
        "total_branch_ops": branch_ops,
        "total_leaf_solutions": leaf_solutions,
        "total_memo_entries": memo_entries,
        "total_dp_states_explored": dp_states_explored,
        "total_convolutions": convolutions,
        "frontier_variables": len(state.variables),
        "largest_component": max((len(component) for component in state.component_variables), default=0),
        "evaluation": {
            "reused_components": reused_components,
            "materialized_ordinary_components": materialized_ordinary_components,
            "materialized_ordinary_component_sizes": materialized_ordinary_component_sizes,
            "ordinary_materialization_search_nodes": ordinary_materialization_nodes,
            "ordinary_materialization_branch_ops": ordinary_materialization_branch_ops,
            "recomputed_special_components": recomputed_special_components,
            "recomputed_component_sizes": recomputed_component_sizes,
            "special_evaluation_search_nodes": special_evaluation_nodes,
            "special_evaluation_branch_ops": special_evaluation_branch_ops,
            "special_from_transition_count": special_from_transition_count,
            "special_from_deferred_count": special_from_deferred_count,
            "unconstrained_local_count": len(unconstrained_local),
            "unconstrained_other_count": unconstrained_other_count,
        },
    }


def evaluate_incremental_step(
    transcript: cs.Transcript,
    cell_index: int,
    previous_state: IncrementalState | None,
    mode: str = "2D0",
) -> tuple[IncrementalState, dict[str, object]]:
    started = time.perf_counter()
    budget = None
    state = build_state(transcript, previous_state=previous_state, budget=budget, mode=mode)
    evaluation = evaluate_candidate_with_state(state, cell_index, budget=budget)
    wall_clock_ms = (time.perf_counter() - started) * 1000.0
    result = {
        "status": "ok",
        "counts": evaluation["counts"],
        "sum_counts": evaluation["sum_counts"],
        "compatible_total_before_click": evaluation["compatible_total_before_click"],
        "partition_ok": evaluation["partition_ok"],
        "outcomes_positive": evaluation["outcomes_positive"],
        "frontier_variables": evaluation["frontier_variables"],
        "largest_component": evaluation["largest_component"],
        "total_search_nodes": state.last_transition.search_nodes + evaluation["total_search_nodes"],
        "total_branch_ops": state.last_transition.branch_ops + evaluation["total_branch_ops"],
        "total_memo_entries": state.last_transition.memo_entries + evaluation["total_memo_entries"],
        "total_dp_states_explored": state.last_transition.dp_states_explored + evaluation["total_dp_states_explored"],
        "total_convolutions": evaluation["total_convolutions"],
        "wall_clock_ms": wall_clock_ms,
        "incremental": {
            "mode": state.last_transition.mode,
            "transition_kind": state.last_transition.kind,
            "transition_search_nodes": state.last_transition.search_nodes,
            "transition_branch_ops": state.last_transition.branch_ops,
            "transition_memo_entries": state.last_transition.memo_entries,
            "transition_dp_states_explored": state.last_transition.dp_states_explored,
            "reuse_count": state.last_transition.reused_components,
            "invalidation_count": state.last_transition.invalidated_components,
            "changed_component_count": state.last_transition.changed_components,
            "eagerly_counted_component_count": state.last_transition.eagerly_counted_components,
            "deferred_component_count": state.last_transition.deferred_components,
            "reused_component_sizes": state.last_transition.reused_component_sizes,
            "changed_component_sizes": state.last_transition.changed_component_sizes,
            "eagerly_counted_component_sizes": state.last_transition.eagerly_counted_component_sizes,
            "deferred_component_sizes": state.last_transition.deferred_component_sizes,
            "persistent_state_size": state.last_transition.persistent_state_size,
            "evaluation_reused_components": evaluation["evaluation"]["reused_components"],
            "evaluation_materialized_ordinary_components": evaluation["evaluation"]["materialized_ordinary_components"],
            "evaluation_materialized_ordinary_component_sizes": evaluation["evaluation"]["materialized_ordinary_component_sizes"],
            "evaluation_recomputed_special_components": evaluation["evaluation"]["recomputed_special_components"],
            "evaluation_recomputed_component_sizes": evaluation["evaluation"]["recomputed_component_sizes"],
            "evaluation_special_from_transition_count": evaluation["evaluation"]["special_from_transition_count"],
            "evaluation_special_from_deferred_count": evaluation["evaluation"]["special_from_deferred_count"],
            "unconstrained_local_count": evaluation["evaluation"]["unconstrained_local_count"],
            "unconstrained_other_count": evaluation["evaluation"]["unconstrained_other_count"],
        },
    }
    return state, result
