#!/usr/bin/env python3
"""
EXPERIMENTO 2A — baseline exacto de conditional sampling para Minesweeper.

Este módulo implementa:
- un oracle exhaustivo independiente para tableros pequeños
- un contador exacto por constraints/componentes
- instrumentación por evaluación
- un smoke reproducible para 30x16/99 con salida JSONL

El baseline 2A recalcula desde cero cada outcome de cada click. No reutiliza
cálculos entre clicks ni entre outcomes, por diseño.
"""

from __future__ import annotations

import argparse
import json
import math
import random
import statistics
import time
from dataclasses import dataclass
from itertools import combinations
from pathlib import Path
from typing import Iterable


Coord = tuple[int, int]

MINE_OUTCOME = "mine"
CLUE_OUTCOMES = tuple(str(i) for i in range(9))
ALL_OUTCOMES = (MINE_OUTCOME,) + CLUE_OUTCOMES

DEFAULT_SMOKE_SEEDS = (20260830, 20260831)
DEFAULT_BENCHMARK_SEEDS = tuple(range(20260840, 20260900))


class BudgetExceededError(RuntimeError):
    pass


class EvaluationAbortedError(RuntimeError):
    def __init__(self, kind: str, partial_result: dict[str, object], message: str):
        super().__init__(message)
        self.kind = kind
        self.partial_result = partial_result


def index_of(width: int, x: int, y: int) -> int:
    return y * width + x


def coord_of(width: int, index: int) -> Coord:
    return (index % width, index // width)


def neighbors(width: int, height: int, index: int) -> list[int]:
    x, y = coord_of(width, index)
    out: list[int] = []
    for dy in (-1, 0, 1):
      for dx in (-1, 0, 1):
        if dx == 0 and dy == 0:
          continue
        nx = x + dx
        ny = y + dy
        if 0 <= nx < width and 0 <= ny < height:
          out.append(index_of(width, nx, ny))
    return out


def clue_for_board(width: int, height: int, mines: frozenset[int], index: int) -> int:
    return sum(1 for n in neighbors(width, height, index) if n in mines)


def reveal_from_board(
    width: int,
    height: int,
    mines: frozenset[int],
    revealed: set[int],
    start: int,
) -> set[int]:
    if start in mines:
        raise ValueError("El generador de transcripts no debe clickear minas.")
    stack = [start]
    while stack:
        index = stack.pop()
        if index in revealed:
            continue
        revealed.add(index)
        if clue_for_board(width, height, mines, index) == 0:
            for nxt in neighbors(width, height, index):
                if nxt not in revealed and nxt not in mines:
                    stack.append(nxt)
    return revealed


@dataclass(frozen=True)
class Transcript:
    width: int
    height: int
    total_mines: int
    revealed_clues: dict[int, int]
    known_mines: frozenset[int] = frozenset()
    label: str = ""
    generator_seed: int | None = None

    @property
    def revealed_count(self) -> int:
        return len(self.revealed_clues)

    @property
    def cell_count(self) -> int:
        return self.width * self.height

    def closed_cells(self) -> list[int]:
        closed = []
        for index in range(self.cell_count):
            if index in self.revealed_clues or index in self.known_mines:
                continue
            closed.append(index)
        return closed

    def to_json(self) -> dict[str, object]:
        return {
            "width": self.width,
            "height": self.height,
            "total_mines": self.total_mines,
            "revealed_clues": [
                {"index": index, "coord": coord_of(self.width, index), "clue": clue}
                for index, clue in sorted(self.revealed_clues.items())
            ],
            "known_mines": [
                {"index": index, "coord": coord_of(self.width, index)}
                for index in sorted(self.known_mines)
            ],
            "label": self.label,
            "generator_seed": self.generator_seed,
        }


@dataclass(frozen=True)
class Constraint:
    variables: tuple[int, ...]
    rhs: int


@dataclass
class ComponentProfile:
    variable_count: int
    constraint_count: int
    solution_vector: list[int]
    search_nodes: int
    branch_ops: int
    leaf_solutions: int
    memo_entries: int
    dp_states_explored: int
    abort_reason: str | None = None


@dataclass
class ProblemProfile:
    consistent: bool
    total_remaining_mines: int
    constraints: list[Constraint]
    variables: list[int]
    unconstrained_closed_cells: int
    component_variables: list[list[int]]
    component_constraints: list[list[Constraint]]
    component_profiles: list[ComponentProfile]
    convolutions_performed: int
    total_count: int
    max_count_bit_length: int
    abort_reason: str | None = None


@dataclass
class EvaluationLimits:
    wall_clock_s: float | None = None
    max_search_nodes: int | None = None
    max_branch_ops: int | None = None


@dataclass
class BudgetContext:
    started_at: float
    wall_clock_s: float | None
    max_search_nodes: int | None
    max_branch_ops: int | None
    search_nodes_used: int = 0
    branch_ops_used: int = 0

    def consume(self, search_nodes_delta: int = 0, branch_ops_delta: int = 0):
        self.search_nodes_used += search_nodes_delta
        self.branch_ops_used += branch_ops_delta
        if self.wall_clock_s is not None and time.perf_counter() - self.started_at > self.wall_clock_s:
            raise TimeoutError("wall-clock timeout dentro de DFS")
        if self.max_search_nodes is not None and self.search_nodes_used > self.max_search_nodes:
            raise BudgetExceededError("search_nodes budget exceeded")
        if self.max_branch_ops is not None and self.branch_ops_used > self.max_branch_ops:
            raise BudgetExceededError("branch_ops budget exceeded")


def board_matches_transcript(transcript: Transcript, mines: frozenset[int]) -> bool:
    if len(mines) != transcript.total_mines:
        return False
    if not transcript.known_mines.issubset(mines):
        return False
    for index in transcript.revealed_clues:
        if index in mines:
            return False
    for index, clue in transcript.revealed_clues.items():
        if clue_for_board(transcript.width, transcript.height, mines, index) != clue:
            return False
    return True


def enumerate_all_boards(width: int, height: int, total_mines: int) -> list[frozenset[int]]:
    return [
        frozenset(combo)
        for combo in combinations(range(width * height), total_mines)
    ]


def exhaustive_outcome_counts(
    transcript: Transcript,
    cell_index: int,
    boards: list[frozenset[int]] | None = None,
) -> dict[str, int]:
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        return {outcome: 0 for outcome in ALL_OUTCOMES}
    if boards is None:
        boards = enumerate_all_boards(transcript.width, transcript.height, transcript.total_mines)

    counts = {outcome: 0 for outcome in ALL_OUTCOMES}
    for mines in boards:
        if not board_matches_transcript(transcript, mines):
            continue
        if cell_index in mines:
            counts[MINE_OUTCOME] += 1
        else:
            clue = clue_for_board(transcript.width, transcript.height, mines, cell_index)
            counts[str(clue)] += 1
    return counts


def transcript_total_count(
    transcript: Transcript,
    boards: list[frozenset[int]] | None = None,
) -> int:
    if boards is None:
        boards = enumerate_all_boards(transcript.width, transcript.height, transcript.total_mines)
    return sum(1 for mines in boards if board_matches_transcript(transcript, mines))


def with_outcome(transcript: Transcript, cell_index: int, outcome: str) -> Transcript:
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        raise ValueError("La celda evaluada debe estar cerrada.")
    if outcome == MINE_OUTCOME:
        known_mines = set(transcript.known_mines)
        known_mines.add(cell_index)
        return Transcript(
            width=transcript.width,
            height=transcript.height,
            total_mines=transcript.total_mines,
            revealed_clues=dict(transcript.revealed_clues),
            known_mines=frozenset(known_mines),
            label=transcript.label,
            generator_seed=transcript.generator_seed,
        )

    clue = int(outcome)
    revealed = dict(transcript.revealed_clues)
    revealed[cell_index] = clue
    return Transcript(
        width=transcript.width,
        height=transcript.height,
        total_mines=transcript.total_mines,
        revealed_clues=revealed,
        known_mines=transcript.known_mines,
        label=transcript.label,
        generator_seed=transcript.generator_seed,
    )


def build_constraints(transcript: Transcript) -> tuple[bool, list[Constraint], list[int], int]:
    known_safe = set(transcript.revealed_clues)
    known_mines = set(transcript.known_mines)
    remaining_mines = transcript.total_mines - len(known_mines)
    if remaining_mines < 0:
        return False, [], [], remaining_mines

    variable_set: set[int] = set()
    constraints: list[Constraint] = []
    cell_count = transcript.width * transcript.height

    for index in range(cell_count):
        if index in known_safe or index in known_mines:
            continue
        if index < 0:
            raise AssertionError("unreachable")

    for clue_index, clue in transcript.revealed_clues.items():
        rhs = clue
        unknown_neighbors: list[int] = []
        for neighbor in neighbors(transcript.width, transcript.height, clue_index):
            if neighbor in known_mines:
                rhs -= 1
            elif neighbor in known_safe:
                continue
            else:
                unknown_neighbors.append(neighbor)
        if rhs < 0 or rhs > len(unknown_neighbors):
            return False, [], [], remaining_mines
        if unknown_neighbors:
            scope = tuple(sorted(unknown_neighbors))
            constraints.append(Constraint(scope, rhs))
            variable_set.update(scope)
        elif rhs != 0:
            return False, [], [], remaining_mines

    variables = sorted(variable_set)
    if remaining_mines > len(variables) + sum(
        1
        for index in range(cell_count)
        if index not in known_safe and index not in known_mines and index not in variable_set
    ):
        return False, [], [], remaining_mines
    return True, constraints, variables, remaining_mines


def connected_components(
    variables: list[int],
    constraints: list[Constraint],
) -> tuple[list[list[int]], list[list[Constraint]]]:
    if not variables:
        return [], []
    adjacency: dict[int, set[int]] = {var: set() for var in variables}
    constraint_map: dict[int, list[Constraint]] = {var: [] for var in variables}

    for constraint in constraints:
        scope = constraint.variables
        for var in scope:
            constraint_map[var].append(constraint)
            adjacency[var].update(scope)

    seen: set[int] = set()
    variable_components: list[list[int]] = []
    constraint_components: list[list[Constraint]] = []

    for start in variables:
        if start in seen:
            continue
        stack = [start]
        comp_vars: list[int] = []
        comp_constraints: set[Constraint] = set()
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
        constraint_components.append(sorted(comp_constraints, key=lambda item: (item.variables, item.rhs)))
    return variable_components, constraint_components


def count_component(
    component_vars: list[int],
    component_constraints: list[Constraint],
    budget: BudgetContext | None = None,
) -> ComponentProfile:
    local_index = {var: i for i, var in enumerate(component_vars)}
    local_constraints = [
        ([local_index[var] for var in constraint.variables], constraint.rhs)
        for constraint in component_constraints
    ]
    constraints_by_var: list[list[int]] = [[] for _ in component_vars]
    for c_idx, (scope, _rhs) in enumerate(local_constraints):
        for local_var in scope:
            constraints_by_var[local_var].append(c_idx)

    partial_sum = [0] * len(local_constraints)
    unassigned = [len(scope) for scope, _rhs in local_constraints]
    counts = [0] * (len(component_vars) + 1)
    search_nodes = 0
    branch_ops = 0
    leaf_solutions = 0

    def dfs(pos: int, mines_used: int):
        nonlocal search_nodes, branch_ops, leaf_solutions
        search_nodes += 1
        if budget is not None:
            budget.consume(search_nodes_delta=1)
        if pos == len(component_vars):
            for c_idx, (_scope, rhs) in enumerate(local_constraints):
                if partial_sum[c_idx] != rhs:
                    return
            counts[mines_used] += 1
            leaf_solutions += 1
            return

        for value in (0, 1):
            branch_ops += 1
            if budget is not None:
                budget.consume(branch_ops_delta=1)
            changed: list[int] = []
            ok = True
            for c_idx in constraints_by_var[pos]:
                partial_sum[c_idx] += value
                unassigned[c_idx] -= 1
                changed.append(c_idx)
                rhs = local_constraints[c_idx][1]
                if partial_sum[c_idx] > rhs:
                    ok = False
                    break
                if partial_sum[c_idx] + unassigned[c_idx] < rhs:
                    ok = False
                    break
            if ok:
                dfs(pos + 1, mines_used + value)
            for c_idx in changed:
                partial_sum[c_idx] -= value
                unassigned[c_idx] += 1

    dfs(0, 0)
    return ComponentProfile(
        variable_count=len(component_vars),
        constraint_count=len(component_constraints),
        solution_vector=counts,
        search_nodes=search_nodes,
        branch_ops=branch_ops,
        leaf_solutions=leaf_solutions,
        memo_entries=0,
        dp_states_explored=0,
    )


def convolve_counts(left: list[int], right: list[int]) -> list[int]:
    result = [0] * (len(left) + len(right) - 1)
    for i, left_value in enumerate(left):
        if left_value == 0:
            continue
        for j, right_value in enumerate(right):
            if right_value == 0:
                continue
            result[i + j] += left_value * right_value
    return result


def problem_profile(
    transcript: Transcript,
    limits: EvaluationLimits | None = None,
    started_at: float | None = None,
    budget: BudgetContext | None = None,
) -> ProblemProfile:
    consistent, constraints, variables, remaining_mines = build_constraints(transcript)
    if not consistent:
        return ProblemProfile(
            consistent=False,
            total_remaining_mines=remaining_mines,
            constraints=[],
            variables=[],
            unconstrained_closed_cells=0,
            component_variables=[],
            component_constraints=[],
            component_profiles=[],
            convolutions_performed=0,
            total_count=0,
            max_count_bit_length=0,
        )

    closed_cells = transcript.closed_cells()
    unconstrained_closed = len([cell for cell in closed_cells if cell not in set(variables)])
    variable_components, constraint_components = connected_components(variables, constraints)
    if budget is None and limits is not None:
        budget = BudgetContext(
            started_at=started_at if started_at is not None else time.perf_counter(),
            wall_clock_s=limits.wall_clock_s,
            max_search_nodes=limits.max_search_nodes,
            max_branch_ops=limits.max_branch_ops,
        )
    component_profiles = [
        count_component(comp_vars, comp_constraints, budget=budget)
        for comp_vars, comp_constraints in zip(variable_components, constraint_components)
    ]

    combined = [1]
    convolutions = 0
    for component in component_profiles:
        combined = convolve_counts(combined, component.solution_vector)
        convolutions += 1

    total = 0
    for mines_in_frontier, ways in enumerate(combined):
        if ways == 0:
            continue
        mines_in_unconstrained = remaining_mines - mines_in_frontier
        if 0 <= mines_in_unconstrained <= unconstrained_closed:
            total += ways * math.comb(unconstrained_closed, mines_in_unconstrained)

    max_count = max((max(profile.solution_vector) for profile in component_profiles), default=total)
    return ProblemProfile(
        consistent=True,
        total_remaining_mines=remaining_mines,
        constraints=constraints,
        variables=variables,
        unconstrained_closed_cells=unconstrained_closed,
        component_variables=variable_components,
        component_constraints=constraint_components,
        component_profiles=component_profiles,
        convolutions_performed=convolutions,
        total_count=total,
        max_count_bit_length=max(total.bit_length(), max_count.bit_length() if max_count else 0),
    )


def count_outcome(
    transcript: Transcript,
    limits: EvaluationLimits | None = None,
    started_at: float | None = None,
    budget: BudgetContext | None = None,
) -> tuple[int, ProblemProfile]:
    profile = problem_profile(transcript, limits=limits, started_at=started_at, budget=budget)
    return profile.total_count, profile


def affected_components_for_cell(
    transcript: Transcript,
    cell_index: int,
    profile: ProblemProfile,
) -> list[int]:
    affected: list[int] = []
    neighbor_set = set(neighbors(transcript.width, transcript.height, cell_index))
    for idx, component in enumerate(profile.component_variables):
        if neighbor_set.intersection(component) or cell_index in component:
            affected.append(idx)
    return affected


def evaluate_cell_baseline(
    transcript: Transcript,
    cell_index: int,
    timeout_s: float | None = None,
    max_search_nodes: int | None = None,
    max_branch_ops: int | None = None,
) -> dict[str, object]:
    started = time.perf_counter()
    cell_coord = coord_of(transcript.width, cell_index)
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        raise ValueError("La celda evaluada debe estar cerrada.")

    limits = EvaluationLimits(
        wall_clock_s=timeout_s,
        max_search_nodes=max_search_nodes,
        max_branch_ops=max_branch_ops,
    )
    budget = BudgetContext(
        started_at=started,
        wall_clock_s=limits.wall_clock_s,
        max_search_nodes=limits.max_search_nodes,
        max_branch_ops=limits.max_branch_ops,
    )
    try:
        total_count, total_profile = count_outcome(transcript, limits=limits, started_at=started, budget=budget)
    except TimeoutError as exc:
        raise EvaluationAbortedError(
            "timeout",
            build_aborted_total_result(
                transcript=transcript,
                cell_index=cell_index,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="timeout",
                error_message=str(exc),
                budget=budget,
            ),
            str(exc),
        ) from exc
    except BudgetExceededError as exc:
        raise EvaluationAbortedError(
            "budget_exceeded",
            build_aborted_total_result(
                transcript=transcript,
                cell_index=cell_index,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="budget_exceeded",
                error_message=str(exc),
                budget=budget,
            ),
            str(exc),
        ) from exc
    counts: dict[str, int] = {}
    per_outcome: dict[str, dict[str, object]] = {}
    max_count = 0

    try:
        for outcome in ALL_OUTCOMES:
            if timeout_s is not None and time.perf_counter() - started > timeout_s:
                raise TimeoutError(f"timeout evaluando celda {cell_coord}")
            outcome_transcript = with_outcome(transcript, cell_index, outcome)
            count, profile = count_outcome(outcome_transcript, limits=limits, started_at=started, budget=budget)
            counts[outcome] = count
            max_count = max(max_count, count)
            per_outcome[outcome] = {
                "count": count,
                "total_remaining_mines": profile.total_remaining_mines,
                "consistent": profile.consistent,
                "frontier_variables": len(profile.variables),
                "unconstrained_closed_cells": profile.unconstrained_closed_cells,
                "constraint_count": len(profile.constraints),
                "component_count": len(profile.component_profiles),
                "component_sizes": [item.variable_count for item in profile.component_profiles],
                "largest_component": max((item.variable_count for item in profile.component_profiles), default=0),
                "component_vector_lengths": [len(item.solution_vector) for item in profile.component_profiles],
                "affected_components": affected_components_for_cell(outcome_transcript, cell_index, profile),
                "search_nodes": sum(item.search_nodes for item in profile.component_profiles),
                "branch_ops": sum(item.branch_ops for item in profile.component_profiles),
                "leaf_solutions": sum(item.leaf_solutions for item in profile.component_profiles),
                "memo_entries": sum(item.memo_entries for item in profile.component_profiles),
                "dp_states_explored": sum(item.dp_states_explored for item in profile.component_profiles),
                "convolutions_performed": profile.convolutions_performed,
                "max_count_bit_length": profile.max_count_bit_length,
            }
    except TimeoutError as exc:
        raise EvaluationAbortedError(
            "timeout",
            build_partial_evaluation_result(
                transcript=transcript,
                cell_index=cell_index,
                total_count=total_count,
                total_profile=total_profile,
                counts=counts,
                per_outcome=per_outcome,
                max_count=max_count,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="timeout",
                error_message=str(exc),
            ),
            str(exc),
        ) from exc
    except BudgetExceededError as exc:
        raise EvaluationAbortedError(
            "budget_exceeded",
            build_partial_evaluation_result(
                transcript=transcript,
                cell_index=cell_index,
                total_count=total_count,
                total_profile=total_profile,
                counts=counts,
                per_outcome=per_outcome,
                max_count=max_count,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="budget_exceeded",
                error_message=str(exc),
            ),
            str(exc),
        ) from exc

    wall_clock_ms = (time.perf_counter() - started) * 1000.0
    outcome_positive = sum(1 for value in counts.values() if value > 0)
    counts_sum = sum(counts.values())

    return build_partial_evaluation_result(
        transcript=transcript,
        cell_index=cell_index,
        total_count=total_count,
        total_profile=total_profile,
        counts=counts,
        per_outcome=per_outcome,
        max_count=max_count,
        wall_clock_ms=wall_clock_ms,
        final_status="ok",
        error_message=None,
    )


def profile_metric_sums(profile: ProblemProfile) -> dict[str, int]:
    return {
        "search_nodes": sum(item.search_nodes for item in profile.component_profiles),
        "branch_ops": sum(item.branch_ops for item in profile.component_profiles),
        "leaf_solutions": sum(item.leaf_solutions for item in profile.component_profiles),
        "memo_entries": sum(item.memo_entries for item in profile.component_profiles),
        "dp_states_explored": sum(item.dp_states_explored for item in profile.component_profiles),
        "convolutions": profile.convolutions_performed,
    }


def outcome_metric_sums(per_outcome: dict[str, dict[str, object]]) -> dict[str, int]:
    totals = {
        "search_nodes": 0,
        "branch_ops": 0,
        "leaf_solutions": 0,
        "memo_entries": 0,
        "dp_states_explored": 0,
        "convolutions": 0,
    }
    for stats in per_outcome.values():
        totals["search_nodes"] += int(stats.get("search_nodes", 0))
        totals["branch_ops"] += int(stats.get("branch_ops", 0))
        totals["leaf_solutions"] += int(stats.get("leaf_solutions", 0))
        totals["memo_entries"] += int(stats.get("memo_entries", 0))
        totals["dp_states_explored"] += int(stats.get("dp_states_explored", 0))
        totals["convolutions"] += int(stats.get("convolutions_performed", 0))
    return totals


def build_aborted_total_result(
    transcript: Transcript,
    cell_index: int,
    wall_clock_ms: float,
    final_status: str,
    error_message: str,
    budget: BudgetContext,
) -> dict[str, object]:
    return {
        "status": final_status,
        "error_message": error_message,
        "cell_index": cell_index,
        "cell_coord": coord_of(transcript.width, cell_index),
        "board_width": transcript.width,
        "board_height": transcript.height,
        "total_mines": transcript.total_mines,
        "mines_remaining": transcript.total_mines - len(transcript.known_mines),
        "revealed_cells": transcript.revealed_count,
        "closed_cells": len(transcript.closed_cells()),
        "frontier_variables": 0,
        "unconstrained_closed_cells": 0,
        "constraint_count": 0,
        "component_count": 0,
        "component_sizes": [],
        "largest_component": 0,
        "component_vector_lengths": [],
        "total_search_nodes": budget.search_nodes_used,
        "total_branch_ops": budget.branch_ops_used,
        "total_leaf_solutions": 0,
        "total_memo_entries": 0,
        "total_dp_states_explored": 0,
        "total_convolutions": 0,
        "counts": {},
        "missing_outcomes": list(ALL_OUTCOMES),
        "outcomes_positive": 0,
        "sum_counts": 0,
        "compatible_total_before_click": 0,
        "partition_ok": False,
        "max_count_bit_length": 0,
        "wall_clock_ms": wall_clock_ms,
        "per_outcome": {},
    }


def build_partial_evaluation_result(
    transcript: Transcript,
    cell_index: int,
    total_count: int,
    total_profile: ProblemProfile,
    counts: dict[str, int],
    per_outcome: dict[str, dict[str, object]],
    max_count: int,
    wall_clock_ms: float,
    final_status: str,
    error_message: str | None,
) -> dict[str, object]:
    outcome_positive = sum(1 for value in counts.values() if value > 0)
    counts_sum = sum(counts.values())
    missing_outcomes = [outcome for outcome in ALL_OUTCOMES if outcome not in counts]
    before_click = profile_metric_sums(total_profile)
    outcomes_total = outcome_metric_sums(per_outcome)
    return {
        "status": final_status,
        "error_message": error_message,
        "cell_index": cell_index,
        "cell_coord": coord_of(transcript.width, cell_index),
        "board_width": transcript.width,
        "board_height": transcript.height,
        "total_mines": transcript.total_mines,
        "mines_remaining": transcript.total_mines - len(transcript.known_mines),
        "revealed_cells": transcript.revealed_count,
        "closed_cells": len(transcript.closed_cells()),
        "frontier_variables": len(total_profile.variables),
        "unconstrained_closed_cells": total_profile.unconstrained_closed_cells,
        "constraint_count": len(total_profile.constraints),
        "component_count": len(total_profile.component_profiles),
        "component_sizes": [item.variable_count for item in total_profile.component_profiles],
        "largest_component": max((item.variable_count for item in total_profile.component_profiles), default=0),
        "component_vector_lengths": [len(item.solution_vector) for item in total_profile.component_profiles],
        "before_click_search_nodes": before_click["search_nodes"],
        "before_click_branch_ops": before_click["branch_ops"],
        "before_click_leaf_solutions": before_click["leaf_solutions"],
        "before_click_memo_entries": before_click["memo_entries"],
        "before_click_dp_states_explored": before_click["dp_states_explored"],
        "before_click_convolutions": before_click["convolutions"],
        "total_search_nodes": before_click["search_nodes"] + outcomes_total["search_nodes"],
        "total_branch_ops": before_click["branch_ops"] + outcomes_total["branch_ops"],
        "total_leaf_solutions": before_click["leaf_solutions"] + outcomes_total["leaf_solutions"],
        "total_memo_entries": before_click["memo_entries"] + outcomes_total["memo_entries"],
        "total_dp_states_explored": before_click["dp_states_explored"] + outcomes_total["dp_states_explored"],
        "total_convolutions": before_click["convolutions"] + outcomes_total["convolutions"],
        "counts": counts,
        "missing_outcomes": missing_outcomes,
        "outcomes_positive": outcome_positive,
        "sum_counts": counts_sum,
        "compatible_total_before_click": total_count,
        "partition_ok": not missing_outcomes and counts_sum == total_count,
        "max_count_bit_length": max_count.bit_length() if max_count else 0,
        "wall_clock_ms": wall_clock_ms,
        "per_outcome": per_outcome,
    }


def transcript_from_board(
    width: int,
    height: int,
    total_mines: int,
    mines: frozenset[int],
    revealed: set[int],
    label: str,
    generator_seed: int | None = None,
) -> Transcript:
    return Transcript(
        width=width,
        height=height,
        total_mines=total_mines,
        revealed_clues={
            index: clue_for_board(width, height, mines, index)
            for index in sorted(revealed)
        },
        known_mines=frozenset(),
        label=label,
        generator_seed=generator_seed,
    )


def random_board(width: int, height: int, total_mines: int, seed: int) -> frozenset[int]:
    rng = random.Random(seed)
    return frozenset(rng.sample(range(width * height), total_mines))


def choose_safe_click(board_safe: set[int], candidates: Iterable[int], fallback: Iterable[int]) -> int:
    for candidate in candidates:
        if candidate in board_safe:
            return candidate
    for candidate in fallback:
        if candidate in board_safe:
            return candidate
    raise ValueError("No hay celdas seguras disponibles.")


def frontier_closed_cells(transcript: Transcript) -> list[int]:
    revealed = set(transcript.revealed_clues)
    closed = transcript.closed_cells()
    frontier: list[int] = []
    for cell in closed:
        if any(neighbor in revealed for neighbor in neighbors(transcript.width, transcript.height, cell)):
            frontier.append(cell)
    return frontier


def manhattan_to_center(width: int, height: int, index: int) -> int:
    x, y = coord_of(width, index)
    cx = width // 2
    cy = height // 2
    return abs(x - cx) + abs(y - cy)


def generate_smoke_transcripts(
    width: int,
    height: int,
    total_mines: int,
    seed: int,
) -> list[Transcript]:
    mines = random_board(width, height, total_mines, seed)
    board_safe = set(range(width * height)) - set(mines)
    revealed: set[int] = set()

    center_order = sorted(range(width * height), key=lambda idx: (manhattan_to_center(width, height, idx), idx))
    first_click = choose_safe_click(board_safe, center_order, range(width * height))
    reveal_from_board(width, height, mines, revealed, first_click)
    transcripts = [
        transcript_from_board(width, height, total_mines, mines, set(revealed), f"seed-{seed}-early", seed)
    ]

    safe_clicks_done = 1
    stage_targets = [4, 10]
    for target in stage_targets:
        while safe_clicks_done < target:
            frontier = frontier_closed_cells(transcripts[-1])
            if frontier:
                ordered = sorted(frontier, key=lambda idx: (manhattan_to_center(width, height, idx), idx))
            else:
                ordered = center_order
            click = choose_safe_click(board_safe - revealed, ordered, center_order)
            reveal_from_board(width, height, mines, revealed, click)
            safe_clicks_done += 1
        label = "mid" if target == 4 else "late"
        transcripts.append(
            transcript_from_board(width, height, total_mines, mines, set(revealed), f"seed-{seed}-{label}", seed)
        )

    return transcripts


def pick_smoke_candidates(transcript: Transcript, limit: int = 2) -> list[int]:
    frontier = frontier_closed_cells(transcript)
    source = frontier if frontier else transcript.closed_cells()
    ordered = sorted(source, key=lambda idx: (manhattan_to_center(transcript.width, transcript.height, idx), idx))
    return ordered[:limit]


def pick_diverse_candidates(transcript: Transcript, limit: int = 4) -> list[int]:
    frontier = frontier_closed_cells(transcript)
    if not frontier:
        return transcript.closed_cells()[:limit]
    ordered_center = sorted(frontier, key=lambda idx: (manhattan_to_center(transcript.width, transcript.height, idx), idx))
    ordered_far = sorted(frontier, key=lambda idx: (-manhattan_to_center(transcript.width, transcript.height, idx), idx))
    ordered_degree = sorted(
        frontier,
        key=lambda idx: (-sum(1 for n in neighbors(transcript.width, transcript.height, idx) if n in transcript.revealed_clues), idx),
    )
    picks: list[int] = []
    for source in (ordered_center, ordered_far, ordered_degree, frontier):
        for candidate in source:
            if candidate not in picks:
                picks.append(candidate)
                break
        if len(picks) >= limit:
            break
    return picks[:limit]


def to_json_line(record: dict[str, object]) -> str:
    return json.dumps(record, sort_keys=True)


def run_smoke(
    out_path: Path,
    width: int,
    height: int,
    total_mines: int,
    seeds: tuple[int, ...],
    timeout_s: float,
) -> list[dict[str, object]]:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    rows: list[dict[str, object]] = []
    with out_path.open("w", encoding="utf-8") as handle:
        for seed in seeds:
            transcripts = generate_smoke_transcripts(width, height, total_mines, seed)
            for transcript in transcripts:
                for candidate in pick_smoke_candidates(transcript):
                    started = time.perf_counter()
                    status, result, error = safe_evaluate_for_benchmark(
                        transcript,
                        candidate,
                        timeout_s=timeout_s,
                        max_search_nodes=None,
                        max_branch_ops=None,
                    )
                    row = {
                        "experiment": "2A",
                        "generator_seed": seed,
                        "transcript_id": transcript.label,
                        "transcript": transcript.to_json(),
                        "clicked_cell": {
                            "index": candidate,
                            "coord": coord_of(width, candidate),
                        },
                        "status": status,
                        "error": error,
                        "wall_clock_ms_total": (time.perf_counter() - started) * 1000.0,
                        "result": result,
                    }
                    handle.write(to_json_line(row) + "\n")
                    handle.flush()
                    rows.append(row)
                    if status == "ok":
                        readable = result["wall_clock_ms"]
                        largest = result["largest_component"]
                        print(
                            f"[{transcript.label}] cell={coord_of(width, candidate)} "
                            f"t={readable:.1f}ms comps={result['component_count']} "
                            f"largest={largest} sumN={result['sum_counts']}"
                        )
                    else:
                        print(
                            f"[{transcript.label}] cell={coord_of(width, candidate)} status={status} error={error}"
                        )
    return rows


def summarize_smoke(rows: list[dict[str, object]]) -> dict[str, object]:
    successful = [row for row in rows if row["status"] == "ok"]
    if not successful:
        return {"ok": 0, "errors": len(rows)}
    times = [row["result"]["wall_clock_ms"] for row in successful]
    largest_components = [row["result"]["largest_component"] for row in successful]
    sum_counts_bits = [row["result"]["max_count_bit_length"] for row in successful]
    cheapest = min(successful, key=lambda row: row["result"]["wall_clock_ms"])
    costliest = max(successful, key=lambda row: row["result"]["wall_clock_ms"])
    return {
        "ok": len(successful),
        "errors": len(rows) - len(successful),
        "min_ms": min(times),
        "max_ms": max(times),
        "mean_ms": sum(times) / len(times),
        "largest_component_max": max(largest_components),
        "max_count_bit_length": max(sum_counts_bits),
        "cheapest_case": {
            "transcript_id": cheapest["transcript_id"],
            "clicked_cell": cheapest["clicked_cell"],
            "wall_clock_ms": cheapest["result"]["wall_clock_ms"],
            "largest_component": cheapest["result"]["largest_component"],
        },
        "costliest_case": {
            "transcript_id": costliest["transcript_id"],
            "clicked_cell": costliest["clicked_cell"],
            "wall_clock_ms": costliest["result"]["wall_clock_ms"],
            "largest_component": costliest["result"]["largest_component"],
        },
    }


def percentile(values: list[float], p: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    idx = (p / 100.0) * (len(ordered) - 1)
    lo = math.floor(idx)
    hi = math.ceil(idx)
    if lo == hi:
        return ordered[lo]
    frac = idx - lo
    return ordered[lo] + frac * (ordered[hi] - ordered[lo])


def generate_benchmark_transcripts(
    width: int,
    height: int,
    total_mines: int,
    seed: int,
) -> list[Transcript]:
    mines = random_board(width, height, total_mines, seed)
    board_safe = set(range(width * height)) - set(mines)
    revealed: set[int] = set()
    center_order = sorted(range(width * height), key=lambda idx: (manhattan_to_center(width, height, idx), idx))
    transcripts: list[Transcript] = []

    first_click = choose_safe_click(board_safe, center_order, range(width * height))
    reveal_from_board(width, height, mines, revealed, first_click)
    stages = [("early", 2), ("mid", 8), ("late", 18)]
    safe_clicks_done = 1
    for phase, target in stages:
        while safe_clicks_done < target:
            current = transcript_from_board(width, height, total_mines, mines, set(revealed), f"seed-{seed}-{phase}", seed)
            frontier = frontier_closed_cells(current)
            if frontier:
                ordered = sorted(
                    frontier,
                    key=lambda idx: (
                        -sum(1 for n in neighbors(width, height, idx) if n in revealed),
                        manhattan_to_center(width, height, idx),
                        idx,
                    ),
                )
            else:
                ordered = center_order
            click = choose_safe_click(board_safe - revealed, ordered, center_order)
            reveal_from_board(width, height, mines, revealed, click)
            safe_clicks_done += 1
        transcripts.append(
            transcript_from_board(width, height, total_mines, mines, set(revealed), f"seed-{seed}-{phase}", seed)
        )
    return transcripts


def safe_evaluate_for_benchmark(
    transcript: Transcript,
    candidate: int,
    timeout_s: float,
    max_search_nodes: int | None,
    max_branch_ops: int | None,
) -> tuple[str, dict[str, object], str | None]:
    try:
        result = evaluate_cell_baseline(
            transcript,
            candidate,
            timeout_s=timeout_s,
            max_search_nodes=max_search_nodes,
            max_branch_ops=max_branch_ops,
        )
        return "ok", result, None
    except EvaluationAbortedError as exc:
        return exc.kind, exc.partial_result, str(exc)
    except Exception as exc:
        return "error", {}, str(exc)


def benchmark_row(
    transcript: Transcript,
    candidate: int,
    phase: str,
    status: str,
    error: str | None,
    result: dict[str, object],
) -> dict[str, object]:
    return {
        "experiment": "2A-hardening",
        "generator_seed": transcript.generator_seed,
        "transcript_id": transcript.label,
        "phase": phase,
        "transcript": transcript.to_json(),
        "clicked_cell": {
            "index": candidate,
            "coord": coord_of(transcript.width, candidate),
        },
        "status": status,
        "error": error,
        "result": result,
    }


def run_benchmark(
    out_path: Path,
    width: int,
    height: int,
    total_mines: int,
    seeds: tuple[int, ...],
    timeout_s: float,
    max_search_nodes: int | None,
    max_branch_ops: int | None,
    max_evaluations: int,
) -> list[dict[str, object]]:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    rows: list[dict[str, object]] = []
    with out_path.open("w", encoding="utf-8") as handle:
        for seed in seeds:
            for transcript in generate_benchmark_transcripts(width, height, total_mines, seed):
                phase = transcript.label.rsplit("-", 1)[-1]
                for candidate in pick_diverse_candidates(transcript):
                    status, result, error = safe_evaluate_for_benchmark(
                        transcript,
                        candidate,
                        timeout_s=timeout_s,
                        max_search_nodes=max_search_nodes,
                        max_branch_ops=max_branch_ops,
                    )
                    row = benchmark_row(transcript, candidate, phase, status, error, result)
                    handle.write(to_json_line(row) + "\n")
                    handle.flush()
                    rows.append(row)
                    if result:
                        print(
                            f"[{len(rows):04d}/{max_evaluations}] {transcript.label} "
                            f"cell={coord_of(width, candidate)} status={status} "
                            f"t={result.get('wall_clock_ms', 0):.1f}ms "
                            f"largest={result.get('largest_component', 0)} "
                            f"nodes={result.get('total_search_nodes', 0)}"
                        )
                    else:
                        print(
                            f"[{len(rows):04d}/{max_evaluations}] {transcript.label} "
                            f"cell={coord_of(width, candidate)} status={status} error={error}"
                        )
                    if len(rows) >= max_evaluations:
                        return rows
    return rows


def summarize_benchmark(rows: list[dict[str, object]]) -> dict[str, object]:
    ok_rows = [row for row in rows if row["status"] == "ok"]
    timed_rows = [row for row in rows if row["status"] == "timeout"]
    budget_rows = [row for row in rows if row["status"] == "budget_exceeded"]
    error_rows = [row for row in rows if row["status"] == "error"]
    if not ok_rows:
        return {
            "n": len(rows),
            "ok": 0,
            "timeouts": len(timed_rows),
            "budget_exceeded": len(budget_rows),
            "errors": len(error_rows),
        }

    def collect(metric: str) -> list[float]:
        return [float(row["result"][metric]) for row in ok_rows]

    wall = collect("wall_clock_ms")
    nodes = collect("total_search_nodes")
    branches = collect("total_branch_ops")
    largest = collect("largest_component")
    bits = collect("max_count_bit_length")
    constraints = collect("constraint_count")
    outcomes = collect("outcomes_positive")
    top_cost = sorted(ok_rows, key=lambda row: row["result"]["wall_clock_ms"], reverse=True)[:10]
    return {
        "n": len(rows),
        "ok": len(ok_rows),
        "timeouts": len(timed_rows),
        "budget_exceeded": len(budget_rows),
        "errors": len(error_rows),
        "wall_clock_ms": {
            "p50": percentile(wall, 50),
            "p90": percentile(wall, 90),
            "p95": percentile(wall, 95),
            "p99": percentile(wall, 99),
            "max": max(wall),
            "mean": statistics.mean(wall),
        },
        "search_nodes": {
            "p50": percentile(nodes, 50),
            "p95": percentile(nodes, 95),
            "p99": percentile(nodes, 99),
            "max": max(nodes),
        },
        "branch_ops": {
            "p50": percentile(branches, 50),
            "p95": percentile(branches, 95),
            "p99": percentile(branches, 99),
            "max": max(branches),
        },
        "largest_component_distribution": {
            "min": min(largest),
            "p50": percentile(largest, 50),
            "p95": percentile(largest, 95),
            "max": max(largest),
        },
        "max_count_bit_length_distribution": {
            "min": min(bits),
            "p50": percentile(bits, 50),
            "p95": percentile(bits, 95),
            "max": max(bits),
        },
        "phase_counts": {
            phase: sum(1 for row in rows if row["phase"] == phase)
            for phase in ("early", "mid", "late")
        },
        "correlations_hint": {
            "largest_component_mean": statistics.mean(largest),
            "constraints_mean": statistics.mean(constraints),
            "outcomes_positive_mean": statistics.mean(outcomes),
        },
        "top_10_costliest": [
            {
                "seed": row["generator_seed"],
                "transcript_id": row["transcript_id"],
                "phase": row["phase"],
                "clicked_cell": row["clicked_cell"],
                "wall_clock_ms": row["result"]["wall_clock_ms"],
                "search_nodes": row["result"]["total_search_nodes"],
                "branch_ops": row["result"]["total_branch_ops"],
                "largest_component": row["result"]["largest_component"],
                "constraint_count": row["result"]["constraint_count"],
                "outcomes_positive": row["result"]["outcomes_positive"],
                "max_count_bit_length": row["result"]["max_count_bit_length"],
            }
            for row in top_cost
        ],
    }


def main():
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2A baseline exacto")
    subparsers = parser.add_subparsers(dest="command", required=True)

    smoke = subparsers.add_parser("smoke", help="Corre un smoke reproducible 30x16/99")
    smoke.add_argument("--width", type=int, default=30)
    smoke.add_argument("--height", type=int, default=16)
    smoke.add_argument("--mines", type=int, default=99)
    smoke.add_argument("--timeout-s", type=float, default=30.0)
    smoke.add_argument(
        "--out",
        default="benchmarks/conditional-sampling-2a-smoke-20260830.jsonl",
    )
    smoke.add_argument(
        "--seeds",
        default=",".join(str(seed) for seed in DEFAULT_SMOKE_SEEDS),
        help="Lista separada por comas",
    )

    bench = subparsers.add_parser("benchmark", help="Corre benchmark principal 2A-hardening")
    bench.add_argument("--width", type=int, default=30)
    bench.add_argument("--height", type=int, default=16)
    bench.add_argument("--mines", type=int, default=99)
    bench.add_argument("--timeout-s", type=float, default=2.0)
    bench.add_argument("--max-search-nodes", type=int, default=100000)
    bench.add_argument("--max-branch-ops", type=int, default=200000)
    bench.add_argument("--max-evaluations", type=int, default=1000)
    bench.add_argument(
        "--out",
        default="benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl",
    )
    bench.add_argument(
        "--seeds",
        default=",".join(str(seed) for seed in DEFAULT_BENCHMARK_SEEDS),
        help="Lista separada por comas",
    )

    args = parser.parse_args()

    if args.command == "smoke":
        seeds = tuple(int(item) for item in args.seeds.split(",") if item)
        rows = run_smoke(
            out_path=Path(args.out),
            width=args.width,
            height=args.height,
            total_mines=args.mines,
            seeds=seeds,
            timeout_s=args.timeout_s,
        )
        summary = summarize_smoke(rows)
        print()
        print(json.dumps(summary, indent=2, sort_keys=True))
    elif args.command == "benchmark":
        seeds = tuple(int(item) for item in args.seeds.split(",") if item)
        rows = run_benchmark(
            out_path=Path(args.out),
            width=args.width,
            height=args.height,
            total_mines=args.mines,
            seeds=seeds,
            timeout_s=args.timeout_s,
            max_search_nodes=args.max_search_nodes,
            max_branch_ops=args.max_branch_ops,
            max_evaluations=args.max_evaluations,
        )
        summary = summarize_benchmark(rows)
        print()
        print(json.dumps(summary, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
