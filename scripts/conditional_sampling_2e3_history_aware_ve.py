#!/usr/bin/env python3
"""
EXPERIMENTO 2E3 - history-aware / incremental variable elimination exacta.

Preserva 2E2 como baseline frozen por snapshot y agrega:
- cache global content-addressed de mensajes ordinarios
- estado persistente por transcript y componente
- overlay special query-aware que reutiliza mensajes ordinarios fuera del
  cono exacto de dependencias de x y sus vecinos
- accounting honesto separado entre startup, transition, maintenance y
  evaluation
"""

from __future__ import annotations

import argparse
import json
import math
import random
import signal
import statistics
import time
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import conditional_sampling_2b2_exact_outcomes as b2
import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2d_incremental as d1
import conditional_sampling_2e2_variable_elimination as e2
import conditional_sampling_exact as cs
import conditional_sampling_history_smoke as hs
import conditional_sampling_locality as b


StateKey = e2.StateKey
OFFICIAL_TIMEOUT_S = 150.0


@dataclass(frozen=True)
class FactorKey:
    kind: str
    payload: tuple[object, ...]


@dataclass
class RuntimeFactor:
    factor: e2.SparseCountFactor
    key: FactorKey
    dependency_vars: frozenset[int]
    base_entry_kind: str


@dataclass
class StepTrace:
    variable: int
    cache_key: FactorKey
    separator: tuple[int, ...]
    dependency_vars: frozenset[int]
    related_keys: tuple[FactorKey, ...]
    nonzero_entries: int
    dense_entries: int
    cache_hit: bool


@dataclass
class OrdinaryBuildSummary:
    hits: int = 0
    misses: int = 0
    base_reused: int = 0
    base_built: int = 0
    messages_reused: int = 0
    messages_recomputed: int = 0
    factor_entries_reused: int = 0
    factor_entries_recomputed: int = 0
    peak_live_entries: int = 0
    factors_created: int = 0
    joins: int = 0
    marginalizations: int = 0
    bigint_additions: int = 0
    bigint_multiplications: int = 0
    total_entries_processed: int = 0
    total_nonzero_entries_processed: int = 0
    peak_factor_entries: int = 0
    peak_nonzero_entries: int = 0
    effective_width: int = 0
    peak_scope_size: int = 0
    plan_reuse: str = "rebuilt"


@dataclass
class OrdinaryComponentState:
    signature: e2.ComponentSignature
    plan: e2.ComponentEliminationPlan
    variables: tuple[int, ...]
    constraints: tuple[cs.Constraint, ...]
    base_factors: tuple[RuntimeFactor, ...]
    step_traces: tuple[StepTrace, ...]
    final_factor: RuntimeFactor
    solution_vector: list[int]
    satisfiable: bool
    build_summary: OrdinaryBuildSummary
    wall_clock_ms: float
    active_keys: frozenset[FactorKey]


@dataclass
class TranscriptFeatures:
    frontier_variables: int
    constraint_count: int
    unconstrained_closed_cells: int
    component_count: int
    component_sizes: list[int]
    largest_component: int
    max_scope: int
    mean_scope: float
    degree_min: int
    degree_mean: float
    degree_max: int
    min_fill_width_max: int
    constraint_density: float
    rhs_zero_count: int
    rhs_full_scope_count: int
    phase: str


@dataclass
class TranscriptState:
    transcript: cs.Transcript
    consistent: bool
    constraints: tuple[cs.Constraint, ...]
    variables: tuple[int, ...]
    remaining_mines: int
    unconstrained_closed_cells: int
    component_states: tuple[OrdinaryComponentState, ...]
    active_keys: frozenset[FactorKey]
    cache_peak_entries: int
    cache_peak_messages: int
    build_wall_ms: float
    build_summary: OrdinaryBuildSummary
    features: TranscriptFeatures
    overlap_to_previous: dict[int, list[int]]


@dataclass
class CacheEntry:
    factor: e2.SparseCountFactor
    dependency_vars: frozenset[int]
    nonzero_entries: int


@dataclass
class GlobalMessageCache:
    entries: dict[FactorKey, CacheEntry] = field(default_factory=dict)
    peak_entries: int = 0
    peak_messages: int = 0

    def update_peaks(self) -> None:
        live_entries = sum(entry.nonzero_entries for entry in self.entries.values())
        self.peak_entries = max(self.peak_entries, live_entries)
        self.peak_messages = max(self.peak_messages, len(self.entries))


@dataclass
class StateBuildContext:
    mode: str
    whole_component_hits: int = 0
    partial_component_hits: int = 0
    rebuilt_components: int = 0


@dataclass
class ReuseAccounting:
    messages_available_before: int = 0
    messages_reused: int = 0
    messages_invalidated: int = 0
    messages_recomputed: int = 0
    factor_entries_available_before: int = 0
    factor_entries_reused: int = 0
    factor_entries_invalidated: int = 0
    factor_entries_recomputed: int = 0
    whole_component_hits: int = 0
    subdag_hits: int = 0
    reuse_fraction: float = 0.0
    fallback_snapshot: bool = False
    fallback_reason: str | None = None


@dataclass
class WorkAccounting:
    startup_ms: float = 0.0
    transition_ms: float = 0.0
    maintenance_ms: float = 0.0
    evaluation_ms: float = 0.0

    def total_ms(self) -> float:
        return self.startup_ms + self.transition_ms + self.maintenance_ms + self.evaluation_ms


@dataclass
class TransitionSummary:
    classification: str
    vars_added: int
    vars_removed: int
    constraints_added: int
    constraints_removed: int
    constraints_changed: int
    plan_reused: int
    plan_partial: int
    plan_rebuilt: int
    cache_available_before: int
    reuse: ReuseAccounting
    work: WorkAccounting
    current_features: TranscriptFeatures
    previous_features: TranscriptFeatures | None
    structural_delta: dict[str, int | float | str | None]


@dataclass
class HistoryAwareEngine:
    cache: GlobalMessageCache = field(default_factory=GlobalMessageCache)
    state: TranscriptState | None = None
    force_fallback_min_fill_width: int | None = None


class OfficialTimeout(RuntimeError):
    pass


def _constraint_key(constraint: cs.Constraint) -> FactorKey:
    return FactorKey("constraint", (constraint.variables, constraint.rhs))


def _message_key(variable: int, related_keys: tuple[FactorKey, ...]) -> FactorKey:
    payload = (variable, tuple((key.kind, key.payload) for key in related_keys))
    return FactorKey("message", payload)


def _component_active_keys(component: OrdinaryComponentState) -> frozenset[FactorKey]:
    keys = {factor.key for factor in component.base_factors}
    keys.update(trace.cache_key for trace in component.step_traces)
    return frozenset(keys)


def _copy_factor(factor: e2.SparseCountFactor) -> e2.SparseCountFactor:
    return e2.SparseCountFactor(
        scope=factor.scope,
        table={mask: dict(states) for mask, states in factor.table.items()},
        mine_capacity=factor.mine_capacity,
        x_capacity=factor.x_capacity,
        neighbor_capacity=factor.neighbor_capacity,
    )


def _factor_from_cache(entry: CacheEntry, key: FactorKey, kind: str) -> RuntimeFactor:
    return RuntimeFactor(
        factor=_copy_factor(entry.factor),
        key=key,
        dependency_vars=entry.dependency_vars,
        base_entry_kind=kind,
    )


def _combine_stats(target: OrdinaryBuildSummary, stats: e2.VEInstrumentation) -> None:
    target.factors_created += stats.factors_created
    target.joins += stats.joins
    target.marginalizations += stats.marginalizations
    target.bigint_additions += stats.bigint_additions
    target.bigint_multiplications += stats.bigint_multiplications
    target.total_entries_processed += stats.total_entries_processed
    target.total_nonzero_entries_processed += stats.total_nonzero_entries_processed
    target.peak_factor_entries = max(target.peak_factor_entries, stats.peak_factor_entries)
    target.peak_nonzero_entries = max(target.peak_nonzero_entries, stats.peak_nonzero_entries)
    target.effective_width = max(target.effective_width, stats.effective_width)
    target.peak_scope_size = max(target.peak_scope_size, stats.peak_scope_size)


def _observe_live(summary: OrdinaryBuildSummary, factors: list[RuntimeFactor]) -> None:
    summary.peak_live_entries = max(summary.peak_live_entries, sum(f.factor.nonzero_entries() for f in factors))


def _degree_stats(component_vars: list[int], constraints: list[cs.Constraint]) -> tuple[int, float, int]:
    if not component_vars:
        return 0, 0.0, 0
    primal = e2.build_primal_graph(component_vars, constraints)
    degrees = [len(primal[var]) for var in component_vars]
    return min(degrees), (sum(degrees) / len(degrees)), max(degrees)


def phase_for_transcript(transcript: cs.Transcript) -> str:
    return hs.phase_for_transcript(transcript)


def transcript_features(
    transcript: cs.Transcript,
    constraints: list[cs.Constraint],
    variables: list[int],
    component_variables: list[list[int]],
    component_constraints: list[list[cs.Constraint]],
) -> TranscriptFeatures:
    unconstrained_closed = len([cell for cell in transcript.closed_cells() if cell not in set(variables)])
    scopes = [len(constraint.variables) for constraint in constraints]
    max_scope = max(scopes, default=0)
    mean_scope = (sum(scopes) / len(scopes)) if scopes else 0.0
    all_degrees = [_degree_stats(vars_group, cons_group) for vars_group, cons_group in zip(component_variables, component_constraints)]
    degree_values = [value for group in all_degrees for value in (group[0], group[2])] if all_degrees else []
    degree_mean_num = sum(group[1] * len(vars_group) for group, vars_group in zip(all_degrees, component_variables))
    degree_den = sum(len(vars_group) for vars_group in component_variables)
    min_fill_width_max = max(
        (e2.build_elimination_plan(vars_group, cons_group).min_fill_width for vars_group, cons_group in zip(component_variables, component_constraints)),
        default=0,
    )
    variable_count = len(variables)
    possible_edges = (variable_count * (variable_count - 1)) / 2 if variable_count >= 2 else 1
    actual_edges = 0
    for constraint in constraints:
        scope = list(constraint.variables)
        for idx, _var in enumerate(scope):
            actual_edges += len(scope[idx + 1:])
    density = actual_edges / possible_edges if possible_edges else 0.0
    return TranscriptFeatures(
        frontier_variables=len(variables),
        constraint_count=len(constraints),
        unconstrained_closed_cells=unconstrained_closed,
        component_count=len(component_variables),
        component_sizes=[len(component) for component in component_variables],
        largest_component=max((len(component) for component in component_variables), default=0),
        max_scope=max_scope,
        mean_scope=mean_scope,
        degree_min=min((group[0] for group in all_degrees), default=0),
        degree_mean=(degree_mean_num / degree_den) if degree_den else 0.0,
        degree_max=max((group[2] for group in all_degrees), default=0),
        min_fill_width_max=min_fill_width_max,
        constraint_density=density,
        rhs_zero_count=sum(1 for constraint in constraints if constraint.rhs == 0),
        rhs_full_scope_count=sum(1 for constraint in constraints if constraint.rhs == len(constraint.variables)),
        phase=phase_for_transcript(transcript),
    )


def _build_overlap_map(
    component_variables: list[list[int]],
    previous_state: TranscriptState | None,
) -> dict[int, list[int]]:
    overlap: dict[int, list[int]] = {}
    if previous_state is None:
        return overlap
    previous_sets = [set(component.variables) for component in previous_state.component_states]
    for idx, variables in enumerate(component_variables):
        var_set = set(variables)
        overlap[idx] = [
            prev_idx
            for prev_idx, prev_set in enumerate(previous_sets)
            if var_set.intersection(prev_set)
        ]
    return overlap


def _build_ordinary_component_state(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    cache: GlobalMessageCache,
    previous_state: TranscriptState | None,
    build_context: StateBuildContext,
) -> OrdinaryComponentState:
    started = time.perf_counter()
    summary = OrdinaryBuildSummary()
    signature = e2.component_signature(component_vars, component_constraints)
    plan = e2.build_elimination_plan(component_vars, component_constraints)
    previous_component = None
    if previous_state is not None:
        previous_lookup = {component.signature: component for component in previous_state.component_states}
        previous_component = previous_lookup.get(signature)

    base_factors: list[RuntimeFactor] = []
    for constraint in component_constraints:
        key = _constraint_key(constraint)
        cached = cache.entries.get(key)
        if cached is None:
            factor = e2.constraint_factor(constraint, e2.QuerySpec())
            cache.entries[key] = CacheEntry(
                factor=_copy_factor(factor),
                dependency_vars=frozenset(constraint.variables),
                nonzero_entries=factor.nonzero_entries(),
            )
            cache.update_peaks()
            base_factors.append(RuntimeFactor(
                factor=factor,
                key=key,
                dependency_vars=frozenset(constraint.variables),
                base_entry_kind="base-built",
            ))
            summary.base_built += 1
            summary.factor_entries_recomputed += factor.nonzero_entries()
            summary.factors_created += 1
        else:
            base_factors.append(_factor_from_cache(cached, key, "base-reused"))
            summary.base_reused += 1
            summary.factor_entries_reused += cached.nonzero_entries

    factors = list(base_factors)
    traces: list[StepTrace] = []
    _observe_live(summary, factors)

    for variable in plan.ordering:
        related = [factor for factor in factors if variable in factor.factor.scope]
        if not related:
            continue
        factors = [factor for factor in factors if variable not in factor.factor.scope]
        related_sorted = sorted(related, key=lambda item: (item.key.kind, item.key.payload))
        related_keys = tuple(item.key for item in related_sorted)
        cache_key = _message_key(variable, related_keys)
        cached = cache.entries.get(cache_key)
        if cached is not None:
            summary.hits += 1
            summary.messages_reused += 1
            summary.factor_entries_reused += cached.nonzero_entries
            runtime = _factor_from_cache(cached, cache_key, "message-reused")
            traces.append(
                StepTrace(
                    variable=variable,
                    cache_key=cache_key,
                    separator=runtime.factor.scope,
                    dependency_vars=runtime.dependency_vars,
                    related_keys=related_keys,
                    nonzero_entries=cached.nonzero_entries,
                    dense_entries=runtime.factor.dense_capacity(),
                    cache_hit=True,
                )
            )
            factors.append(runtime)
            _observe_live(summary, factors)
            continue

        stats = e2.VEInstrumentation()
        joined = e2._join_related_factors([item.factor for item in related_sorted], stats)
        reduced = e2.eliminate_variable(joined, variable, e2.QuerySpec(), stats)
        dependency_vars = frozenset().union(*(item.dependency_vars for item in related_sorted))
        runtime = RuntimeFactor(
            factor=reduced,
            key=cache_key,
            dependency_vars=dependency_vars,
            base_entry_kind="message-built",
        )
        cache.entries[cache_key] = CacheEntry(
            factor=_copy_factor(reduced),
            dependency_vars=dependency_vars,
            nonzero_entries=reduced.nonzero_entries(),
        )
        cache.update_peaks()
        summary.misses += 1
        summary.messages_recomputed += 1
        summary.factor_entries_recomputed += reduced.nonzero_entries()
        _combine_stats(summary, stats)
        traces.append(
            StepTrace(
                variable=variable,
                cache_key=cache_key,
                separator=reduced.scope,
                dependency_vars=dependency_vars,
                related_keys=related_keys,
                nonzero_entries=reduced.nonzero_entries(),
                dense_entries=reduced.dense_capacity(),
                cache_hit=False,
            )
        )
        factors.append(runtime)
        _observe_live(summary, factors)

    if len(factors) != 1:
        raise AssertionError("El componente ordinario debe colapsar a un único factor final")

    final_factor = factors[0]
    counts = [0] * (len(component_vars) + 1)
    for states in final_factor.factor.table.values():
        for (k, x_mine, neighbor_mines), ways in states.items():
            if x_mine or neighbor_mines:
                raise AssertionError("El estado ordinario no debe tener overlay special")
            counts[k] += ways

    if previous_component is not None:
        summary.plan_reuse = "reused"
        build_context.whole_component_hits += 1
    elif summary.hits > 0:
        summary.plan_reuse = "partial"
        build_context.partial_component_hits += 1
    else:
        summary.plan_reuse = "rebuilt"
        build_context.rebuilt_components += 1

    component_state = OrdinaryComponentState(
        signature=signature,
        plan=plan,
        variables=tuple(component_vars),
        constraints=tuple(component_constraints),
        base_factors=tuple(base_factors),
        step_traces=tuple(traces),
        final_factor=final_factor,
        solution_vector=counts,
        satisfiable=any(counts),
        build_summary=summary,
        wall_clock_ms=(time.perf_counter() - started) * 1000.0,
        active_keys=frozenset(),
    )
    component_state.active_keys = _component_active_keys(component_state)
    return component_state


def build_transcript_state(
    transcript: cs.Transcript,
    cache: GlobalMessageCache,
    previous_state: TranscriptState | None = None,
) -> TranscriptState:
    started = time.perf_counter()
    consistent, constraints, variables, remaining_mines = cs.build_constraints(transcript)
    if not consistent:
        empty_features = TranscriptFeatures(0, 0, 0, 0, [], 0, 0, 0.0, 0, 0.0, 0, 0, 0.0, 0, 0, phase_for_transcript(transcript))
        return TranscriptState(
            transcript=transcript,
            consistent=False,
            constraints=tuple(),
            variables=tuple(),
            remaining_mines=remaining_mines,
            unconstrained_closed_cells=0,
            component_states=tuple(),
            active_keys=frozenset(),
            cache_peak_entries=cache.peak_entries,
            cache_peak_messages=cache.peak_messages,
            build_wall_ms=(time.perf_counter() - started) * 1000.0,
            build_summary=OrdinaryBuildSummary(),
            features=empty_features,
            overlap_to_previous={},
        )

    component_variables, component_constraints = cs.connected_components(variables, constraints)
    build_context = StateBuildContext(mode="ordinary-build")
    component_states = tuple(
        _build_ordinary_component_state(vars_group, cons_group, cache, previous_state, build_context)
        for vars_group, cons_group in zip(component_variables, component_constraints)
    )
    aggregate_summary = OrdinaryBuildSummary(
        hits=sum(component.build_summary.hits for component in component_states),
        misses=sum(component.build_summary.misses for component in component_states),
        base_reused=sum(component.build_summary.base_reused for component in component_states),
        base_built=sum(component.build_summary.base_built for component in component_states),
        messages_reused=sum(component.build_summary.messages_reused for component in component_states),
        messages_recomputed=sum(component.build_summary.messages_recomputed for component in component_states),
        factor_entries_reused=sum(component.build_summary.factor_entries_reused for component in component_states),
        factor_entries_recomputed=sum(component.build_summary.factor_entries_recomputed for component in component_states),
        peak_live_entries=max((component.build_summary.peak_live_entries for component in component_states), default=0),
        factors_created=sum(component.build_summary.factors_created for component in component_states),
        joins=sum(component.build_summary.joins for component in component_states),
        marginalizations=sum(component.build_summary.marginalizations for component in component_states),
        bigint_additions=sum(component.build_summary.bigint_additions for component in component_states),
        bigint_multiplications=sum(component.build_summary.bigint_multiplications for component in component_states),
        total_entries_processed=sum(component.build_summary.total_entries_processed for component in component_states),
        total_nonzero_entries_processed=sum(component.build_summary.total_nonzero_entries_processed for component in component_states),
        peak_factor_entries=max((component.build_summary.peak_factor_entries for component in component_states), default=0),
        peak_nonzero_entries=max((component.build_summary.peak_nonzero_entries for component in component_states), default=0),
        effective_width=max((component.build_summary.effective_width for component in component_states), default=0),
        peak_scope_size=max((component.build_summary.peak_scope_size for component in component_states), default=0),
        plan_reuse="mixed",
    )
    active_keys = frozenset().union(*(component.active_keys for component in component_states)) if component_states else frozenset()
    features = transcript_features(transcript, constraints, variables, component_variables, component_constraints)
    return TranscriptState(
        transcript=transcript,
        consistent=True,
        constraints=tuple(constraints),
        variables=tuple(variables),
        remaining_mines=remaining_mines,
        unconstrained_closed_cells=len([cell for cell in transcript.closed_cells() if cell not in set(variables)]),
        component_states=component_states,
        active_keys=active_keys,
        cache_peak_entries=cache.peak_entries,
        cache_peak_messages=cache.peak_messages,
        build_wall_ms=(time.perf_counter() - started) * 1000.0,
        build_summary=aggregate_summary,
        features=features,
        overlap_to_previous=_build_overlap_map(component_variables, previous_state),
    )


def _component_trace_by_variable(component: OrdinaryComponentState) -> dict[int, StepTrace]:
    return {trace.variable: trace for trace in component.step_traces}


def _query_constraint_factor(constraint: cs.Constraint, query: e2.QuerySpec) -> RuntimeFactor:
    factor = e2.constraint_factor(constraint, query)
    return RuntimeFactor(
        factor=factor,
        key=_constraint_key(constraint),
        dependency_vars=frozenset(constraint.variables),
        base_entry_kind="special-base",
    )


def _ordinary_runtime_factor(runtime: RuntimeFactor) -> RuntimeFactor:
    return RuntimeFactor(
        factor=_copy_factor(runtime.factor),
        key=runtime.key,
        dependency_vars=runtime.dependency_vars,
        base_entry_kind=runtime.base_entry_kind,
    )


def _evaluate_special_component(
    component: OrdinaryComponentState,
    cell_index: int,
    neighbor_vars: set[int],
    engine: HistoryAwareEngine,
) -> tuple[dict[StateKey, int], dict[str, object]]:
    tracked_vars = frozenset(
        var for var in component.variables if var == cell_index or var in neighbor_vars
    )
    if engine.force_fallback_min_fill_width is not None and component.plan.min_fill_width >= engine.force_fallback_min_fill_width:
        profile = e2.count_component_joint_ve(
            list(component.variables),
            list(component.constraints),
            x_var=cell_index if cell_index in set(component.variables) else None,
            neighbor_vars=neighbor_vars.intersection(component.variables),
        )
        return profile.joint_counts or {}, {
            "fallback_snapshot": True,
            "fallback_reason": f"forced-width-{component.plan.min_fill_width}",
            "messages_reused": 0,
            "messages_recomputed": len(component.step_traces),
            "factor_entries_reused": 0,
            "factor_entries_recomputed": sum(
                item.instrumentation.peak_nonzero_entries if hasattr(item, "instrumentation") else 0
                for item in [profile]
            ),
            "joins": profile.instrumentation.joins,
            "marginalizations": profile.instrumentation.marginalizations,
            "bigint_additions": profile.instrumentation.bigint_additions,
            "bigint_multiplications": profile.instrumentation.bigint_multiplications,
            "total_nonzero_entries_processed": profile.instrumentation.total_nonzero_entries_processed,
            "peak_live_entries": profile.instrumentation.peak_live_entries,
            "peak_factor_entries": profile.instrumentation.peak_factor_entries,
            "peak_nonzero_entries": profile.instrumentation.peak_nonzero_entries,
            "effective_width": profile.instrumentation.effective_width,
        }

    query = e2.QuerySpec(
        x_var=cell_index if cell_index in set(component.variables) else None,
        neighbor_vars=frozenset(neighbor_vars.intersection(component.variables)),
    )
    factors: list[RuntimeFactor] = []
    for base in component.base_factors:
        if base.dependency_vars.intersection(tracked_vars):
            factors.append(_query_constraint_factor(
                next(constraint for constraint in component.constraints if _constraint_key(constraint) == base.key),
                query,
            ))
        else:
            factors.append(_ordinary_runtime_factor(base))

    trace_by_variable = _component_trace_by_variable(component)
    overlay_stats = e2.VEInstrumentation()
    messages_reused = 0
    messages_recomputed = 0
    factor_entries_reused = 0
    factor_entries_recomputed = 0
    fallback_snapshot = False
    fallback_reason = None

    for variable in component.plan.ordering:
        related = [factor for factor in factors if variable in factor.factor.scope]
        if not related:
            continue
        factors = [factor for factor in factors if variable not in factor.factor.scope]
        trace = trace_by_variable[variable]
        if not frozenset().union(*(factor.dependency_vars for factor in related)).intersection(tracked_vars):
            cached = next(item for item in component.step_traces if item.variable == variable)
            cache_entry = engine.cache.entries[trace.cache_key]
            factors.append(_factor_from_cache(cache_entry, trace.cache_key, "overlay-reused"))
            messages_reused += 1
            factor_entries_reused += cache_entry.nonzero_entries
            continue

        related_sorted = sorted(related, key=lambda item: (item.key.kind, item.key.payload))
        joined = e2._join_related_factors([item.factor for item in related_sorted], overlay_stats)
        reduced = e2.eliminate_variable(joined, variable, query, overlay_stats)
        dependency_vars = frozenset().union(*(item.dependency_vars for item in related_sorted))
        factors.append(RuntimeFactor(
            factor=reduced,
            key=trace.cache_key,
            dependency_vars=dependency_vars,
            base_entry_kind="overlay-recomputed",
        ))
        messages_recomputed += 1
        factor_entries_recomputed += reduced.nonzero_entries()

    if len(factors) != 1:
        raise AssertionError("La overlay special debe colapsar a un único factor")

    final = factors[0]
    joint_counts: dict[StateKey, int] = {}
    for states in final.factor.table.values():
        for state, ways in states.items():
            joint_counts[state] = joint_counts.get(state, 0) + ways
    return joint_counts, {
        "fallback_snapshot": fallback_snapshot,
        "fallback_reason": fallback_reason,
        "messages_reused": messages_reused,
        "messages_recomputed": messages_recomputed,
        "factor_entries_reused": factor_entries_reused,
        "factor_entries_recomputed": factor_entries_recomputed,
        "joins": overlay_stats.joins,
        "marginalizations": overlay_stats.marginalizations,
        "bigint_additions": overlay_stats.bigint_additions,
        "bigint_multiplications": overlay_stats.bigint_multiplications,
        "total_nonzero_entries_processed": overlay_stats.total_nonzero_entries_processed,
        "peak_live_entries": overlay_stats.peak_live_entries,
        "peak_factor_entries": overlay_stats.peak_factor_entries,
        "peak_nonzero_entries": overlay_stats.peak_nonzero_entries,
        "effective_width": overlay_stats.effective_width,
    }


def _state_key_total_count(
    transcript: cs.Transcript,
    joint_distribution: dict[StateKey, int],
) -> int:
    return b3.compatible_total_from_joint_distribution(transcript, joint_distribution)


def evaluate_with_state(
    engine: HistoryAwareEngine,
    transcript_state: TranscriptState,
    cell_index: int,
) -> dict[str, object]:
    if not transcript_state.consistent:
        return {
            "status": "inconsistent",
            "counts": {outcome: 0 for outcome in cs.ALL_OUTCOMES},
            "sum_counts": 0,
            "compatible_total_before_click": 0,
            "partition_ok": True,
            "history_aware": {
                "ordinary_component_count": 0,
                "special_component_count": 0,
                "special_component_size": 0,
                "structural_width": 0,
                "effective_query_width": 0,
                "messages_reused": 0,
                "messages_recomputed": 0,
                "factor_entries_reused": 0,
                "factor_entries_recomputed": 0,
                "fallback_snapshot": False,
                "fallback_reason": None,
                "joins": 0,
                "marginalizations": 0,
                "bigint_additions": 0,
                "bigint_multiplications": 0,
                "total_nonzero_entries_processed": 0,
                "peak_live_entries": 0,
                "peak_factor_entries": 0,
                "peak_nonzero_entries": 0,
                "wall_clock_ms": 0.0,
            },
        }

    started = time.perf_counter()
    local_hidden, local_neighbors, adjacent_known_mines = b3.local_hidden_sets(transcript_state.transcript, cell_index)
    aggregate: dict[StateKey, int] = {(0, 0, 0): 1}
    ordinary_components = 0
    special_components = 0
    overlay_reused_messages = 0
    overlay_recomputed_messages = 0
    overlay_factor_entries_reused = 0
    overlay_factor_entries_recomputed = 0
    overlay_joins = 0
    overlay_marginalizations = 0
    overlay_bigint_additions = 0
    overlay_bigint_multiplications = 0
    overlay_total_nonzero_entries = 0
    overlay_peak_live_entries = 0
    overlay_peak_factor_entries = 0
    overlay_peak_nonzero_entries = 0
    overlay_effective_width = 0
    fallback_snapshot = False
    fallback_reason = None
    special_component_size = 0
    structural_width = 0
    effective_query_width = 0

    for component in transcript_state.component_states:
        component_var_set = set(component.variables)
        if not component_var_set.intersection(local_hidden):
            aggregate = b3.convolve_joint(
                aggregate,
                {(mines_used, 0, 0): ways for mines_used, ways in enumerate(component.solution_vector) if ways},
            )
            ordinary_components += 1
            continue

        joint_counts, overlay = _evaluate_special_component(component, cell_index, local_neighbors, engine)
        aggregate = b3.convolve_joint(aggregate, joint_counts)
        special_components += 1
        overlay_reused_messages += overlay["messages_reused"]
        overlay_recomputed_messages += overlay["messages_recomputed"]
        overlay_factor_entries_reused += overlay["factor_entries_reused"]
        overlay_factor_entries_recomputed += overlay["factor_entries_recomputed"]
        overlay_joins += overlay["joins"]
        overlay_marginalizations += overlay["marginalizations"]
        overlay_bigint_additions += overlay["bigint_additions"]
        overlay_bigint_multiplications += overlay["bigint_multiplications"]
        overlay_total_nonzero_entries += overlay["total_nonzero_entries_processed"]
        overlay_peak_live_entries = max(overlay_peak_live_entries, overlay["peak_live_entries"])
        overlay_peak_factor_entries = max(overlay_peak_factor_entries, overlay["peak_factor_entries"])
        overlay_peak_nonzero_entries = max(overlay_peak_nonzero_entries, overlay["peak_nonzero_entries"])
        overlay_effective_width = max(overlay_effective_width, overlay["effective_width"])
        structural_width = max(structural_width, component.plan.min_fill_width)
        effective_query_width = max(effective_query_width, overlay["effective_width"])
        special_component_size = max(special_component_size, len(component.variables))
        fallback_snapshot = fallback_snapshot or overlay["fallback_snapshot"]
        fallback_reason = fallback_reason or overlay["fallback_reason"]

    frontier_var_set = set(transcript_state.variables)
    unconstrained_local = sorted(local_hidden - frontier_var_set)
    unconstrained_other_count = transcript_state.unconstrained_closed_cells - len(unconstrained_local)
    if unconstrained_local:
        aggregate = b3.convolve_joint(
            aggregate,
            b3.unconstrained_local_factor(
                x_is_unconstrained=cell_index in unconstrained_local,
                unconstrained_neighbor_count=sum(1 for cell in unconstrained_local if cell in local_neighbors),
            ),
        )
    if unconstrained_other_count > 0:
        aggregate = b3.convolve_joint(
            aggregate,
            {(mines_used, 0, 0): ways for mines_used, ways in enumerate(b3.unconstrained_other_vector(unconstrained_other_count)) if ways},
        )

    counts = b3.counts_from_joint_distribution(
        transcript=transcript_state.transcript,
        cell_index=cell_index,
        joint_distribution=aggregate,
        adjacent_known_mines=adjacent_known_mines,
    )
    compatible_total = _state_key_total_count(transcript_state.transcript, aggregate)
    total_ms = (time.perf_counter() - started) * 1000.0
    return {
        "status": "ok",
        "counts": counts,
        "sum_counts": sum(counts.values()),
        "compatible_total_before_click": compatible_total,
        "partition_ok": sum(counts.values()) == compatible_total,
        "outcomes_positive": sum(1 for value in counts.values() if value > 0),
        "history_aware": {
            "ordinary_component_count": ordinary_components,
            "special_component_count": special_components,
            "special_component_size": special_component_size,
            "structural_width": structural_width,
            "effective_query_width": effective_query_width,
            "messages_reused": overlay_reused_messages,
            "messages_recomputed": overlay_recomputed_messages,
            "factor_entries_reused": overlay_factor_entries_reused,
            "factor_entries_recomputed": overlay_factor_entries_recomputed,
            "fallback_snapshot": fallback_snapshot,
            "fallback_reason": fallback_reason,
            "joins": overlay_joins,
            "marginalizations": overlay_marginalizations,
            "bigint_additions": overlay_bigint_additions,
            "bigint_multiplications": overlay_bigint_multiplications,
            "total_nonzero_entries_processed": overlay_total_nonzero_entries,
            "peak_live_entries": overlay_peak_live_entries,
            "peak_factor_entries": overlay_peak_factor_entries,
            "peak_nonzero_entries": overlay_peak_nonzero_entries,
            "wall_clock_ms": total_ms,
        },
    }


def _reuse_accounting(
    previous_state: TranscriptState | None,
    current_state: TranscriptState,
    evaluation: dict[str, object],
    cache: GlobalMessageCache,
) -> ReuseAccounting:
    if previous_state is None:
        return ReuseAccounting(
            messages_recomputed=current_state.build_summary.messages_recomputed,
            factor_entries_recomputed=current_state.build_summary.factor_entries_recomputed,
        )
    reused_keys = previous_state.active_keys.intersection(current_state.active_keys)
    invalidated_keys = previous_state.active_keys - current_state.active_keys
    available_before = len(previous_state.active_keys)
    reused = len(reused_keys)
    invalidated = len(invalidated_keys)
    history_metrics = evaluation.get("history_aware", {})
    overlay_reused = int(history_metrics.get("messages_reused", 0))
    overlay_recomputed = int(history_metrics.get("messages_recomputed", 0))
    recomputed = current_state.build_summary.messages_recomputed + overlay_recomputed
    available_entries = sum(cache.entries[key].nonzero_entries for key in previous_state.active_keys if key in cache.entries)
    reused_entries = sum(cache.entries[key].nonzero_entries for key in reused_keys if key in cache.entries)
    invalidated_entries = sum(cache.entries[key].nonzero_entries for key in invalidated_keys if key in cache.entries)
    total_reused = reused + overlay_reused
    total_messages = total_reused + recomputed
    return ReuseAccounting(
        messages_available_before=available_before,
        messages_reused=total_reused,
        messages_invalidated=invalidated,
        messages_recomputed=recomputed,
        factor_entries_available_before=available_entries,
        factor_entries_reused=reused_entries + current_state.build_summary.factor_entries_reused + int(history_metrics.get("factor_entries_reused", 0)),
        factor_entries_invalidated=invalidated_entries,
        factor_entries_recomputed=current_state.build_summary.factor_entries_recomputed + int(history_metrics.get("factor_entries_recomputed", 0)),
        whole_component_hits=sum(1 for component in current_state.component_states if component.build_summary.plan_reuse == "reused"),
        subdag_hits=current_state.build_summary.hits + overlay_reused,
        reuse_fraction=(total_reused / total_messages) if total_messages else 0.0,
        fallback_snapshot=bool(history_metrics.get("fallback_snapshot", False)),
        fallback_reason=history_metrics.get("fallback_reason"),
    )


def _transition_class(
    previous_state: TranscriptState | None,
    current_state: TranscriptState,
    cell_index: int,
) -> tuple[str, dict[str, int]]:
    if previous_state is None:
        return "startup", {
            "vars_added": len(current_state.variables),
            "vars_removed": 0,
            "constraints_added": len(current_state.constraints),
            "constraints_removed": 0,
            "constraints_changed": 0,
        }
    current_constraints = Counter((constraint.variables, constraint.rhs) for constraint in current_state.constraints)
    previous_constraints = Counter((constraint.variables, constraint.rhs) for constraint in previous_state.constraints)
    if current_state.transcript.to_json() == previous_state.transcript.to_json():
        return "identical", {
            "vars_added": 0,
            "vars_removed": 0,
            "constraints_added": 0,
            "constraints_removed": 0,
            "constraints_changed": 0,
        }
    vars_added = len(set(current_state.variables) - set(previous_state.variables))
    vars_removed = len(set(previous_state.variables) - set(current_state.variables))
    constraints_added = sum((current_constraints - previous_constraints).values())
    constraints_removed = sum((previous_constraints - current_constraints).values())
    constraints_changed = min(constraints_added, constraints_removed)
    local_hidden, _neighbors, _adjacent = b3.local_hidden_sets(current_state.transcript, cell_index)
    overlaps = [
        len(local_hidden.intersection(component.variables))
        for component in current_state.component_states
    ]
    current_special = max(range(len(overlaps)), key=lambda idx: overlaps[idx], default=None) if overlaps else None
    prev_overlap = current_state.overlap_to_previous.get(current_special, []) if current_special is not None else []
    if current_special is None:
        classification = "strong_change"
    elif len(prev_overlap) == 0:
        classification = "strong_change"
    elif len(prev_overlap) > 1:
        classification = "merge"
    else:
        prev_idx = prev_overlap[0]
        split_count = sum(1 for overlap in current_state.overlap_to_previous.values() if prev_idx in overlap)
        if split_count > 1:
            classification = "split"
        else:
            prev_component = previous_state.component_states[prev_idx]
            curr_component = current_state.component_states[current_special]
            if prev_component.signature == curr_component.signature:
                classification = "component_identical"
            elif set(prev_component.variables) == set(curr_component.variables):
                classification = "local_change"
            else:
                classification = "strong_change"
    return classification, {
        "vars_added": vars_added,
        "vars_removed": vars_removed,
        "constraints_added": constraints_added,
        "constraints_removed": constraints_removed,
        "constraints_changed": constraints_changed,
    }


def startup_engine(
    transcript: cs.Transcript,
    force_fallback_min_fill_width: int | None = None,
) -> tuple[HistoryAwareEngine, TranscriptState]:
    engine = HistoryAwareEngine(force_fallback_min_fill_width=force_fallback_min_fill_width)
    state = build_transcript_state(transcript, engine.cache, previous_state=None)
    engine.state = state
    return engine, state


def advance_engine(
    engine: HistoryAwareEngine,
    transcript: cs.Transcript,
) -> TranscriptState:
    state = build_transcript_state(transcript, engine.cache, previous_state=engine.state)
    engine.state = state
    return state


def evaluate_cell_2e3(
    engine: HistoryAwareEngine,
    transcript: cs.Transcript,
    cell_index: int,
    previous_state: TranscriptState | None = None,
) -> tuple[TranscriptState, dict[str, object]]:
    if engine.state is None or engine.state.transcript.to_json() != transcript.to_json():
        current_state = build_transcript_state(transcript, engine.cache, previous_state=previous_state)
        engine.state = current_state
    else:
        current_state = engine.state
    evaluation = evaluate_with_state(engine, current_state, cell_index)
    transition_class, delta = _transition_class(previous_state, current_state, cell_index)
    reuse = _reuse_accounting(previous_state, current_state, evaluation, engine.cache)
    startup_ms = current_state.build_wall_ms if previous_state is None else 0.0
    transition_ms = current_state.build_wall_ms if previous_state is not None else 0.0
    maintenance_ms = 0.0
    evaluation_ms = evaluation["history_aware"]["wall_clock_ms"]
    result = {
        **evaluation,
        "wall_clock_ms": startup_ms + transition_ms + maintenance_ms + evaluation_ms,
        "history_aware": {
            **evaluation["history_aware"],
            "startup_ms": startup_ms,
            "transition_ms": transition_ms,
            "maintenance_ms": maintenance_ms,
            "evaluation_ms": evaluation_ms,
            "total_ms": startup_ms + transition_ms + maintenance_ms + evaluation_ms,
            "transition_class": transition_class,
            "vars_added": delta["vars_added"],
            "vars_removed": delta["vars_removed"],
            "constraints_added": delta["constraints_added"],
            "constraints_removed": delta["constraints_removed"],
            "constraints_changed": delta["constraints_changed"],
            "messages_available_before": reuse.messages_available_before,
            "messages_invalidated": reuse.messages_invalidated,
            "factor_entries_available_before": reuse.factor_entries_available_before,
            "factor_entries_invalidated": reuse.factor_entries_invalidated,
            "whole_component_hits": reuse.whole_component_hits,
            "subdag_hits": reuse.subdag_hits,
            "reuse_fraction": reuse.reuse_fraction,
            "cache_peak_entries": engine.cache.peak_entries,
            "cache_peak_messages": engine.cache.peak_messages,
            "plan_reused": sum(1 for component in current_state.component_states if component.build_summary.plan_reuse == "reused"),
            "plan_partial": sum(1 for component in current_state.component_states if component.build_summary.plan_reuse == "partial"),
            "plan_rebuilt": sum(1 for component in current_state.component_states if component.build_summary.plan_reuse == "rebuilt"),
            "phase": current_state.features.phase,
            "features": current_state.features.__dict__,
        },
    }
    return current_state, result


def transcript_from_row(row: dict[str, object]) -> cs.Transcript:
    return b3.transcript_from_corpus_row({"transcript": row["transcript"]})


def load_jsonl_rows(path: Path) -> list[dict[str, object]]:
    if not path.exists():
        return []
    rows: list[dict[str, object]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, raw_line in enumerate(handle, start=1):
            line = raw_line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                if line_number == sum(1 for _ in path.open("r", encoding="utf-8")):
                    break
                raise
    return rows


def completed_history_ids(path: Path, terminal_key: str) -> set[str]:
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in load_jsonl_rows(path):
        by_history[str(row["history_id"])].append(row)
    return {
        history_id
        for history_id, items in by_history.items()
        if items and bool(sorted(items, key=lambda item: int(item["click_number"]))[-1].get(terminal_key, False))
    }


def benchmark_completed_history_ids(path: Path) -> set[str]:
    return completed_history_ids(path, "terminal")


def benchmark_existing_rows(path: Path) -> dict[str, dict[int, dict[str, object]]]:
    existing: dict[str, dict[int, dict[str, object]]] = defaultdict(dict)
    for row in load_jsonl_rows(path):
        existing[str(row["history_id"])][int(row["click_number"])] = row
    return existing


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


def _censored_timeout_result(
    timeout_s: float,
    error_message: str | None = None,
    partial_result: dict[str, object] | None = None,
) -> dict[str, object]:
    result = {
        "status": "timeout",
        "timeout_s": timeout_s,
        "wall_clock_ms": None,
        "wall_clock_ms_lower_bound": timeout_s * 1000.0,
        "wall_clock_observation": "right_censored",
        "partition_ok": False,
        "counts": {},
        "missing_outcomes": list(cs.ALL_OUTCOMES),
        "error_message": error_message or f"official timeout after {timeout_s:.0f}s",
    }
    if partial_result:
        result.update(partial_result)
        result["status"] = "timeout"
        result["timeout_s"] = timeout_s
        result["wall_clock_ms"] = None
        result["wall_clock_ms_lower_bound"] = timeout_s * 1000.0
        result["wall_clock_observation"] = "right_censored"
    return result


def _safe_eval_2b3(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        return b3.evaluate_cell_shared_outcomes(transcript, cell_index, timeout_s=timeout_s)
    except cs.EvaluationAbortedError as exc:
        if exc.kind == "timeout":
            return _censored_timeout_result(timeout_s, str(exc), partial_result=exc.partial_result)
        raise


def _safe_eval_2e2(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        with _SignalTimeout(timeout_s):
            return e2.evaluate_cell_2e2(transcript, cell_index)
    except OfficialTimeout as exc:
        return _censored_timeout_result(timeout_s, str(exc))


def _safe_eval_2a(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        return cs.evaluate_cell_baseline(transcript, cell_index, timeout_s=timeout_s)
    except cs.EvaluationAbortedError as exc:
        if exc.kind == "timeout":
            return _censored_timeout_result(timeout_s, str(exc), partial_result=exc.partial_result)
        raise


def _safe_eval_2b(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        return b.evaluate_cell_locality(transcript, cell_index, timeout_s=timeout_s)
    except cs.EvaluationAbortedError as exc:
        if exc.kind == "timeout":
            return _censored_timeout_result(timeout_s, str(exc), partial_result=exc.partial_result)
        raise


def _safe_eval_2b2(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        return b2.evaluate_cell_exact_outcomes(transcript, cell_index, timeout_s=timeout_s)
    except cs.EvaluationAbortedError as exc:
        if exc.kind == "timeout":
            return _censored_timeout_result(timeout_s, str(exc), partial_result=exc.partial_result)
        raise


def _safe_eval_2d1(transcript: cs.Transcript, cell_index: int, timeout_s: float) -> dict[str, object]:
    try:
        with _SignalTimeout(timeout_s):
            return d1.evaluate_incremental_step(transcript, cell_index, previous_state=None, mode="2D1")[1]
    except OfficialTimeout as exc:
        return _censored_timeout_result(timeout_s, str(exc))


def _safe_eval_2e3(
    engine: HistoryAwareEngine,
    transcript: cs.Transcript,
    cell_index: int,
    previous_state: TranscriptState | None,
    timeout_s: float,
) -> tuple[TranscriptState | None, dict[str, object]]:
    try:
        with _SignalTimeout(timeout_s):
            return evaluate_cell_2e3(engine, transcript, cell_index, previous_state=previous_state)
    except OfficialTimeout as exc:
        return None, _censored_timeout_result(timeout_s, str(exc), partial_result={"history_aware": {
            "timeout_s": timeout_s,
            "wall_clock_ms": None,
            "wall_clock_ms_lower_bound": timeout_s * 1000.0,
            "wall_clock_observation": "right_censored",
            "fallback_snapshot": False,
            "fallback_reason": "official-timeout",
        }})


def _is_ok(result: dict[str, object]) -> bool:
    return result.get("status") == "ok"


def _history_rows_to_rebuild(
    history_rows: list[dict[str, object]],
    existing_clicks: set[int],
) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    skipped = [row for row in history_rows if int(row["click_number"]) in existing_clicks]
    pending = [row for row in history_rows if int(row["click_number"]) not in existing_clicks]
    return skipped, pending


def benchmark_smoke_histories(
    history_path: Path,
    out_path: Path,
    include_secondary: bool = True,
    force_fallback_min_fill_width: int | None = None,
    timeout_s: float = OFFICIAL_TIMEOUT_S,
) -> list[dict[str, object]]:
    rows = [json.loads(line) for line in history_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)

    all_rows: list[dict[str, object]] = []
    out_path.parent.mkdir(parents=True, exist_ok=True)
    existing_rows = load_jsonl_rows(out_path)
    existing_by_history = benchmark_existing_rows(out_path)
    all_rows.extend(existing_rows)
    with out_path.open("a", encoding="utf-8") as handle:
        for history_id in sorted(by_history):
            history_rows = sorted(by_history[history_id], key=lambda item: int(item["click_number"]))
            existing_clicks = set(existing_by_history.get(history_id, {}))
            if existing_clicks and existing_clicks.issuperset({int(row["click_number"]) for row in history_rows}):
                continue
            engine: HistoryAwareEngine | None = None
            previous_state: TranscriptState | None = None
            skipped_rows, pending_rows = _history_rows_to_rebuild(history_rows, existing_clicks)
            for row in skipped_rows:
                transcript = transcript_from_row(row)
                if engine is None:
                    engine, state = startup_engine(transcript, force_fallback_min_fill_width=force_fallback_min_fill_width)
                else:
                    state = advance_engine(engine, transcript)
                previous_state = state
            for row in pending_rows:
                transcript = transcript_from_row(row)
                cell_index = int(row["clicked_cell"]["index"])
                result_2b3 = _safe_eval_2b3(transcript, cell_index, timeout_s=timeout_s)
                result_2e2 = _safe_eval_2e2(transcript, cell_index, timeout_s=timeout_s)
                if include_secondary:
                    result_2a = _safe_eval_2a(transcript, cell_index, timeout_s=timeout_s)
                    result_2b = _safe_eval_2b(transcript, cell_index, timeout_s=timeout_s)
                    result_2b2 = _safe_eval_2b2(transcript, cell_index, timeout_s=timeout_s)
                    result_2d1 = _safe_eval_2d1(transcript, cell_index, timeout_s=timeout_s)
                if engine is None:
                    engine, state = startup_engine(transcript, force_fallback_min_fill_width=force_fallback_min_fill_width)
                else:
                    state = advance_engine(engine, transcript)
                current_state, result_2e3 = _safe_eval_2e3(
                    engine,
                    transcript,
                    cell_index,
                    previous_state=previous_state,
                    timeout_s=timeout_s,
                )

                if _is_ok(result_2e2) and _is_ok(result_2e3):
                    if (
                        result_2e3["counts"] != result_2e2["counts"]
                        or result_2e3["sum_counts"] != result_2e2["sum_counts"]
                        or result_2e3["compatible_total_before_click"] != result_2e2["compatible_total_before_click"]
                        or result_2e3["partition_ok"] != result_2e2["partition_ok"]
                    ):
                        raise AssertionError(f"Mismatch 2E3 vs 2E2 en {history_id} click {row['click_number']}")
                if _is_ok(result_2b3):
                    baseline = result_2b3
                    for candidate_name, candidate in (("2E2", result_2e2), ("2E3", result_2e3)):
                        if _is_ok(candidate) and (
                            candidate["counts"] != baseline["counts"]
                            or candidate["sum_counts"] != baseline["sum_counts"]
                            or candidate["compatible_total_before_click"] != baseline["compatible_total_before_click"]
                            or candidate["partition_ok"] != baseline["partition_ok"]
                        ):
                            raise AssertionError(f"Mismatch {candidate_name} en {history_id} click {row['click_number']}")
                if include_secondary:
                    for candidate_name, candidate in (("2A", result_2a), ("2B", result_2b), ("2B2", result_2b2), ("2D1", result_2d1)):
                        if _is_ok(result_2b3) and _is_ok(candidate) and (
                            candidate["counts"] != baseline["counts"]
                            or candidate["sum_counts"] != baseline["sum_counts"]
                            or candidate["compatible_total_before_click"] != baseline["compatible_total_before_click"]
                            or candidate["partition_ok"] != baseline["partition_ok"]
                        ):
                            raise AssertionError(f"Mismatch {candidate_name} en {history_id} click {row['click_number']}")

                out_row = {
                    **row,
                    "compare": {
                        "2B3": result_2b3,
                        "2E2": result_2e2,
                        "2E3": result_2e3,
                    },
                }
                if include_secondary:
                    out_row["compare"].update({
                        "2A": result_2a,
                        "2B": result_2b,
                        "2B2": result_2b2,
                        "2D1": result_2d1,
                    })
                handle.write(json.dumps(out_row, sort_keys=True) + "\n")
                handle.flush()
                all_rows.append(out_row)
                previous_state = state if current_state is None else current_state
    return all_rows


def _seeded_order(seed: int, cells: list[int]) -> list[int]:
    return sorted(cells, key=lambda cell: ((seed * 1103515245 + cell * 2654435761) & 0xFFFFFFFF, cell))


def choose_local_frontier_public(transcript: cs.Transcript, seed: int, previous_click: int | None) -> int:
    candidates = cs.frontier_closed_cells(transcript) or transcript.closed_cells()
    ordered = _seeded_order(seed + transcript.revealed_count, candidates)
    revealed = set(transcript.revealed_clues)
    return min(
        ordered,
        key=lambda cell: (
            hs.min_distance_to_revealed(cell, revealed),
            0 if previous_click is None else hs.manhattan(cell, previous_click),
            cs.manhattan_to_center(transcript.width, transcript.height, cell),
            ordered.index(cell),
        ),
    )


def choose_jump_exploration_public(transcript: cs.Transcript, seed: int, previous_click: int | None) -> int:
    candidates = transcript.closed_cells()
    ordered = _seeded_order(seed + 17 * transcript.revealed_count, candidates)
    revealed = set(transcript.revealed_clues)
    return min(
        ordered,
        key=lambda cell: (
            -(0 if previous_click is None else hs.manhattan(cell, previous_click)),
            -hs.min_distance_to_revealed(cell, revealed),
            -len([n for n in cs.neighbors(transcript.width, transcript.height, cell) if n in transcript.revealed_clues]),
            ordered.index(cell),
        ),
    )


def choose_exact_safest_public(transcript: cs.Transcript, seed: int, previous_click: int | None) -> int:
    candidates = cs.frontier_closed_cells(transcript) or transcript.closed_cells()
    ordered = _seeded_order(seed + 31 * transcript.revealed_count, candidates)
    scored: list[tuple[float, int, int, int]] = []
    for cell in ordered:
        result = b3.evaluate_cell_shared_outcomes(transcript, cell)
        total = result["compatible_total_before_click"]
        mine_count = result["counts"][cs.MINE_OUTCOME]
        mine_prob = (mine_count / total) if total else 1.0
        scored.append((
            mine_prob,
            -result["outcomes_positive"],
            0 if previous_click is None else hs.manhattan(cell, previous_click),
            cell,
        ))
    return min(scored)[-1]


@dataclass(frozen=True)
class HistoricalPolicy:
    history_id: str
    policy: str
    seed: int
    start_mode: str = "center"
    controlled: bool = False


PUBLIC_POLICIES = (
    ("local_frontier_public", "center"),
    ("jump_exploration_public", "corner"),
    ("exact_safest_public", "lower_right"),
)
CONTROLLED_POLICIES = (
    ("oracle_safe_local_center", "center"),
    ("oracle_safe_jump_edge", "corner"),
)


def random_board_excluding(
    width: int,
    height: int,
    total_mines: int,
    seed: int,
    excluded: set[int],
) -> frozenset[int]:
    rng = random.Random(seed)
    population = [index for index in range(width * height) if index not in excluded]
    if total_mines > len(population):
        raise ValueError("No hay suficientes celdas para muestrear minas con exclusiones")
    return frozenset(rng.sample(population, total_mines))


def _policy_click(
    policy: str,
    transcript: cs.Transcript,
    seed: int,
    previous_click: int | None,
    start_mode: str,
) -> int:
    if transcript.revealed_count == 0:
        return hs.choose_start_safe(set(range(transcript.cell_count)), start_mode)
    if policy == "local_frontier_public":
        return choose_local_frontier_public(transcript, seed, previous_click)
    if policy == "jump_exploration_public":
        return choose_jump_exploration_public(transcript, seed, previous_click)
    if policy == "exact_safest_public":
        return choose_exact_safest_public(transcript, seed, previous_click)
    raise ValueError(policy)


def _controlled_policy_click(
    policy: str,
    transcript: cs.Transcript,
    board_safe: set[int],
    previous_click: int | None,
    start_mode: str,
) -> int:
    if transcript.revealed_count == 0:
        return hs.choose_start_safe(board_safe, start_mode)
    if policy == "oracle_safe_local_center":
        return hs.choose_local_safe(transcript, board_safe, previous_click)
    if policy == "oracle_safe_jump_edge":
        return hs.choose_jump_safe(transcript, board_safe, previous_click)
    raise ValueError(policy)


def generate_common_histories_30x16(
    out_path: Path,
    seeds: tuple[int, ...] = (2026083101, 2026083102, 2026083103, 2026083104),
    max_clicks: int = 48,
    include_controlled: bool = True,
) -> list[dict[str, object]]:
    rows = load_jsonl_rows(out_path)
    done_ids = completed_history_ids(out_path, "terminal")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("a", encoding="utf-8") as handle:
        history_counter = 0
        for policy, start_mode in PUBLIC_POLICIES:
            for seed in seeds:
                history_counter += 1
                history_id = f"P{history_counter:02d}"
                if history_id in done_ids:
                    continue
                opening_click = hs.choose_start_safe(set(range(30 * 16)), start_mode)
                mines = random_board_excluding(30, 16, 99, seed, {opening_click})
                revealed: set[int] = set()
                previous_click: int | None = None
                final_result = "incomplete"
                history_rows: list[dict[str, object]] = []
                for click_number in range(max_clicks):
                    transcript = cs.transcript_from_board(30, 16, 99, mines, revealed, f"{history_id}-t{click_number}", generator_seed=seed)
                    click = _policy_click(policy, transcript, seed, previous_click, start_mode)
                    if click in mines:
                        outcome = cs.MINE_OUTCOME
                        terminal = True
                        final_result = "loss"
                    else:
                        outcome = str(cs.clue_for_board(30, 16, mines, click))
                        revealed = cs.reveal_from_board(30, 16, mines, set(revealed), click)
                        terminal = len(revealed) == transcript.cell_count - transcript.total_mines
                        final_result = "victory" if terminal else "in_progress"
                    row = {
                        "history_id": history_id,
                        "policy": policy,
                        "controlled": False,
                        "seed": seed,
                        "start_mode": start_mode,
                        "board": {"width": 30, "height": 16, "total_mines": 99},
                        "click_number": click_number,
                        "phase": phase_for_transcript(transcript),
                        "transcript_id": f"{history_id}-step-{click_number:03d}",
                        "transcript": transcript.to_json(),
                        "clicked_cell": {"index": click, "coord": cs.coord_of(30, click)},
                        "observed_outcome": outcome,
                        "terminal": terminal,
                        "terminal_state": final_result,
                        "max_clicks_cap": max_clicks,
                    }
                    history_rows.append(row)
                    previous_click = click
                    if terminal:
                        break
                if history_rows and history_rows[-1]["terminal_state"] == "in_progress":
                    history_rows[-1]["terminal"] = True
                    history_rows[-1]["terminal_state"] = "incomplete"
                for row in history_rows:
                    handle.write(json.dumps(row, sort_keys=True) + "\n")
                handle.flush()
                rows.extend(history_rows)
        if include_controlled:
            controlled_counter = 0
            for policy, start_mode in CONTROLLED_POLICIES:
                for seed in seeds[:2]:
                    controlled_counter += 1
                    history_id = f"C{controlled_counter:02d}"
                    if history_id in done_ids:
                        continue
                    opening_click = hs.choose_start_safe(set(range(30 * 16)), start_mode)
                    mines = random_board_excluding(30, 16, 99, seed, {opening_click})
                    board_safe = set(range(30 * 16)) - set(mines)
                    revealed: set[int] = set()
                    previous_click: int | None = None
                    history_rows = []
                    final_result = "incomplete"
                    for click_number in range(max_clicks):
                        transcript = cs.transcript_from_board(30, 16, 99, mines, revealed, f"{history_id}-t{click_number}", generator_seed=seed)
                        click = _controlled_policy_click(policy, transcript, board_safe, previous_click, start_mode)
                        outcome = str(cs.clue_for_board(30, 16, mines, click))
                        revealed = cs.reveal_from_board(30, 16, mines, set(revealed), click)
                        terminal = len(revealed) == transcript.cell_count - transcript.total_mines
                        final_result = "victory" if terminal else "in_progress"
                        row = {
                            "history_id": history_id,
                            "policy": policy,
                            "controlled": True,
                            "seed": seed,
                            "start_mode": start_mode,
                            "board": {"width": 30, "height": 16, "total_mines": 99},
                            "click_number": click_number,
                            "phase": phase_for_transcript(transcript),
                            "transcript_id": f"{history_id}-step-{click_number:03d}",
                            "transcript": transcript.to_json(),
                            "clicked_cell": {"index": click, "coord": cs.coord_of(30, click)},
                            "observed_outcome": outcome,
                            "terminal": terminal,
                            "terminal_state": final_result,
                            "max_clicks_cap": max_clicks,
                        }
                        history_rows.append(row)
                        previous_click = click
                        if terminal:
                            break
                    if history_rows and history_rows[-1]["terminal_state"] == "in_progress":
                        history_rows[-1]["terminal"] = True
                        history_rows[-1]["terminal_state"] = "incomplete"
                    for row in history_rows:
                        handle.write(json.dumps(row, sort_keys=True) + "\n")
                    handle.flush()
                    rows.extend(history_rows)
    return rows


def summarize_generated_histories(rows: list[dict[str, object]]) -> dict[str, object]:
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)
    return {
        history_id: {
            "policy": items[0]["policy"],
            "seed": items[0]["seed"],
            "controlled": items[0].get("controlled", False),
            "clicks": len(items),
            "terminal_state": items[-1]["terminal_state"],
            "phase_breakdown": {
                phase: sum(1 for row in items if row["phase"] == phase)
                for phase in ("early", "mid", "late")
            },
        }
        for history_id, items in sorted(by_history.items())
    }


def _runtime_exact_ms(result: dict[str, object], variant: str) -> float | None:
    if result.get("status") != "ok":
        return None
    if variant == "2E3":
        return result.get("history_aware", {}).get("total_ms")
    return result.get("wall_clock_ms")


def _runtime_lower_bound_ms(result: dict[str, object], variant: str) -> float | None:
    exact = _runtime_exact_ms(result, variant)
    if exact is not None:
        return exact
    if variant == "2E3":
        return result.get("history_aware", {}).get("wall_clock_ms_lower_bound")
    return result.get("wall_clock_ms_lower_bound")


def summarize_history_rows(rows: list[dict[str, object]], primary_variants: tuple[str, ...] = ("2B3", "2E2", "2E3")) -> dict[str, object]:
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)

    summary: dict[str, object] = {}
    for history_id, items in sorted(by_history.items()):
        ordered = sorted(items, key=lambda item: int(item["click_number"]))
        total_2b3_exact = [_runtime_exact_ms(item["compare"]["2B3"], "2B3") for item in ordered]
        total_2e2_exact = [_runtime_exact_ms(item["compare"]["2E2"], "2E2") for item in ordered]
        total_2e3_exact = [_runtime_exact_ms(item["compare"]["2E3"], "2E3") for item in ordered]
        total_2b3_lb = [_runtime_lower_bound_ms(item["compare"]["2B3"], "2B3") or 0.0 for item in ordered]
        total_2e2_lb = [_runtime_lower_bound_ms(item["compare"]["2E2"], "2E2") or 0.0 for item in ordered]
        total_2e3_lb = [_runtime_lower_bound_ms(item["compare"]["2E3"], "2E3") or 0.0 for item in ordered]
        comparable_pairs = [
            (
                _runtime_exact_ms(item["compare"]["2E3"], "2E3"),
                _runtime_exact_ms(item["compare"]["2E2"], "2E2"),
            )
            for item in ordered
        ]
        wins = sum(1 for left, right in comparable_pairs if left is not None and right is not None and left < right)
        ties = sum(1 for left, right in comparable_pairs if left is not None and right is not None and left == right)
        losses = sum(1 for left, right in comparable_pairs if left is not None and right is not None and left > right)
        reuse_values = [item["compare"]["2E3"].get("history_aware", {}).get("reuse_fraction", 0.0) for item in ordered]
        fallbacks = [item["compare"]["2E3"].get("history_aware", {}).get("fallback_snapshot", False) for item in ordered]
        exact_vs_2b3 = all(
            not _is_ok(ordered_row["compare"]["2B3"])
            or (
                _is_ok(ordered_row["compare"]["2E3"])
                and ordered_row["compare"]["2E3"]["counts"] == ordered_row["compare"]["2B3"]["counts"]
            )
            for ordered_row in ordered
        )
        summary[history_id] = {
            "policy": ordered[0]["policy"],
            "seed": ordered[0]["seed"],
            "clicks": len(ordered),
            "terminal_state": ordered[-1].get("terminal_state", ordered[-1].get("final_result")),
            "exact_vs_2b3_on_completed_points": exact_vs_2b3,
            "timeouts": {
                variant: sum(1 for item in ordered if item["compare"][variant].get("status") == "timeout")
                for variant in primary_variants
            },
            "total_2B3_ms": sum(value for value in total_2b3_exact if value is not None) if all(value is not None for value in total_2b3_exact) else None,
            "total_2E2_ms": sum(value for value in total_2e2_exact if value is not None) if all(value is not None for value in total_2e2_exact) else None,
            "total_2E3_ms": sum(value for value in total_2e3_exact if value is not None) if all(value is not None for value in total_2e3_exact) else None,
            "total_2B3_ms_lower_bound": sum(total_2b3_lb),
            "total_2E2_ms_lower_bound": sum(total_2e2_lb),
            "total_2E3_ms_lower_bound": sum(total_2e3_lb),
            "speedup_2E2_over_2E3": (
                (sum(value for value in total_2e2_exact if value is not None) / sum(value for value in total_2e3_exact if value is not None))
                if all(value is not None for value in total_2e2_exact + total_2e3_exact) and sum(value for value in total_2e3_exact if value is not None)
                else None
            ),
            "speedup_2B3_over_2E3": (
                (sum(value for value in total_2b3_exact if value is not None) / sum(value for value in total_2e3_exact if value is not None))
                if all(value is not None for value in total_2b3_exact + total_2e3_exact) and sum(value for value in total_2e3_exact if value is not None)
                else None
            ),
            "reuse_fraction_mean": statistics.mean(reuse_values) if reuse_values else 0.0,
            "fallback_fraction": sum(1 for value in fallbacks if value) / len(fallbacks) if fallbacks else 0.0,
            "pointwise_2E3_vs_2E2": {
                "wins": wins,
                "ties": ties,
                "losses": losses,
                "non_comparable": len(ordered) - wins - ties - losses,
            },
            "phase_breakdown": {
                phase: sum(1 for row in ordered if row["phase"] == phase)
                for phase in ("early", "mid", "late")
            },
            "cache_peak_entries": max(item["compare"]["2E3"].get("history_aware", {}).get("cache_peak_entries", 0) for item in ordered),
            "cache_peak_messages": max(item["compare"]["2E3"].get("history_aware", {}).get("cache_peak_messages", 0) for item in ordered),
        }
    return summary


def benchmark_common_histories(
    history_path: Path,
    out_path: Path,
    include_secondary: bool = False,
    timeout_s: float = OFFICIAL_TIMEOUT_S,
) -> list[dict[str, object]]:
    return benchmark_smoke_histories(
        history_path=history_path,
        out_path=out_path,
        include_secondary=include_secondary,
        force_fallback_min_fill_width=None,
        timeout_s=timeout_s,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2E3 history-aware VE")
    subparsers = parser.add_subparsers(dest="command", required=True)

    smoke = subparsers.add_parser("smoke")
    smoke.add_argument("--histories", default="benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl")
    smoke.add_argument("--out", default="benchmarks/conditional-sampling-2e3-smoke-20260831.jsonl")
    smoke.add_argument("--skip-secondary", action="store_true")
    smoke.add_argument("--timeout-s", type=float, default=OFFICIAL_TIMEOUT_S)

    histories = subparsers.add_parser("generate-histories-30x16")
    histories.add_argument("--out", default="benchmarks/conditional-sampling-histories-30x16-20260831.jsonl")
    histories.add_argument("--max-clicks", type=int, default=48)
    histories.add_argument("--skip-controlled", action="store_true")

    benchmark = subparsers.add_parser("benchmark-30x16")
    benchmark.add_argument("--histories", default="benchmarks/conditional-sampling-histories-30x16-20260831.jsonl")
    benchmark.add_argument("--out", default="benchmarks/conditional-sampling-2e3-histories-30x16-20260831.jsonl")
    benchmark.add_argument("--include-secondary", action="store_true")
    benchmark.add_argument("--timeout-s", type=float, default=OFFICIAL_TIMEOUT_S)

    args = parser.parse_args()
    if args.command == "smoke":
        rows = benchmark_smoke_histories(
            Path(args.histories),
            Path(args.out),
            include_secondary=not args.skip_secondary,
            timeout_s=args.timeout_s,
        )
        print(json.dumps(summarize_history_rows(rows), indent=2, sort_keys=True))
        return
    if args.command == "generate-histories-30x16":
        rows = generate_common_histories_30x16(
            Path(args.out),
            max_clicks=args.max_clicks,
            include_controlled=not args.skip_controlled,
        )
        print(json.dumps(summarize_generated_histories(rows), indent=2, sort_keys=True))
        return
    rows = benchmark_common_histories(
        Path(args.histories),
        Path(args.out),
        include_secondary=args.include_secondary,
        timeout_s=args.timeout_s,
    )
    print(json.dumps(summarize_history_rows(rows), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
