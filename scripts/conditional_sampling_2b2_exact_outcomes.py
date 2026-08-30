#!/usr/bin/env python3
"""
EXPERIMENTO 2B2 — contador exacto de los 10 outcomes observables.

Para una celda cerrada x solo resuelve exactamente estos 10 problemas:
- x = mine
- x = safe con sum(minas en vecinos cerrados de x) = j, para j en 0..8

No enumera configuraciones binarias de vecinos ni crea subproblemas por
patrones locales.
"""

from __future__ import annotations

import argparse
import json
import math
import time
from pathlib import Path

import conditional_sampling_exact as cs


def transcript_from_corpus_row(row: dict[str, object]) -> cs.Transcript:
    transcript = row["transcript"]
    return cs.Transcript(
        width=int(transcript["width"]),
        height=int(transcript["height"]),
        total_mines=int(transcript["total_mines"]),
        revealed_clues={int(item["index"]): int(item["clue"]) for item in transcript["revealed_clues"]},
        known_mines=frozenset(int(item["index"]) for item in transcript["known_mines"]),
        label=str(transcript["label"]),
        generator_seed=transcript["generator_seed"],
    )


def build_constraints_for_hypothesis(
    transcript: cs.Transcript,
    cell_index: int,
    outcome: str,
) -> tuple[bool, list[cs.Constraint], list[int], int]:
    known_safe = set(transcript.revealed_clues)
    known_mines = set(transcript.known_mines)
    extra_constraints: list[cs.Constraint] = []

    if outcome == cs.MINE_OUTCOME:
        known_mines.add(cell_index)
    else:
        clue = int(outcome)
        known_safe.add(cell_index)
        rhs = clue
        unknown_neighbors: list[int] = []
        for neighbor in cs.neighbors(transcript.width, transcript.height, cell_index):
            if neighbor in known_mines:
                rhs -= 1
            elif neighbor in known_safe:
                continue
            else:
                unknown_neighbors.append(neighbor)
        if rhs < 0 or rhs > len(unknown_neighbors):
            return False, [], [], transcript.total_mines - len(known_mines)
        if unknown_neighbors:
            extra_constraints.append(cs.Constraint(tuple(sorted(unknown_neighbors)), rhs))
        elif rhs != 0:
            return False, [], [], transcript.total_mines - len(known_mines)

    remaining_mines = transcript.total_mines - len(known_mines)
    if remaining_mines < 0:
        return False, [], [], remaining_mines

    variable_set: set[int] = set()
    constraints: list[cs.Constraint] = []
    cell_count = transcript.width * transcript.height

    for clue_index, clue_value in transcript.revealed_clues.items():
        rhs = clue_value
        unknown_neighbors: list[int] = []
        for neighbor in cs.neighbors(transcript.width, transcript.height, clue_index):
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
            constraints.append(cs.Constraint(scope, rhs))
            variable_set.update(scope)
        elif rhs != 0:
            return False, [], [], remaining_mines

    for constraint in extra_constraints:
        if constraint.rhs < 0 or constraint.rhs > len(constraint.variables):
            return False, [], [], remaining_mines
        constraints.append(constraint)
        variable_set.update(constraint.variables)

    variables = sorted(variable_set)
    unconstrained_closed = sum(
        1
        for index in range(cell_count)
        if index not in known_safe and index not in known_mines and index not in variable_set
    )
    if remaining_mines > len(variables) + unconstrained_closed:
        return False, [], [], remaining_mines
    return True, constraints, variables, remaining_mines


def problem_profile_for_hypothesis(
    transcript: cs.Transcript,
    cell_index: int,
    outcome: str,
    budget: cs.BudgetContext | None = None,
) -> cs.ProblemProfile:
    consistent, constraints, variables, remaining_mines = build_constraints_for_hypothesis(
        transcript,
        cell_index,
        outcome,
    )
    if not consistent:
        return cs.ProblemProfile(
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

    excluded = set(transcript.revealed_clues) | set(transcript.known_mines) | {cell_index}
    if outcome == cs.MINE_OUTCOME:
        excluded = set(transcript.revealed_clues) | set(transcript.known_mines) | {cell_index}
    closed_cells = [index for index in range(transcript.cell_count) if index not in excluded]
    variable_set = set(variables)
    unconstrained_closed = sum(1 for cell in closed_cells if cell not in variable_set)
    component_variables, component_constraints = cs.connected_components(variables, constraints)
    component_profiles = [
        cs.count_component(component_vars, component_constraint_group, budget=budget)
        for component_vars, component_constraint_group in zip(component_variables, component_constraints)
    ]

    combined = [1]
    convolutions = 0
    for component in component_profiles:
        combined = cs.convolve_counts(combined, component.solution_vector)
        convolutions += 1

    total = 0
    for mines_in_frontier, ways in enumerate(combined):
        if ways == 0:
            continue
        mines_in_unconstrained = remaining_mines - mines_in_frontier
        if 0 <= mines_in_unconstrained <= unconstrained_closed:
            total += ways * math.comb(unconstrained_closed, mines_in_unconstrained)

    max_count = max((max(profile.solution_vector) for profile in component_profiles), default=total)
    return cs.ProblemProfile(
        consistent=True,
        total_remaining_mines=remaining_mines,
        constraints=constraints,
        variables=variables,
        unconstrained_closed_cells=unconstrained_closed,
        component_variables=component_variables,
        component_constraints=component_constraints,
        component_profiles=component_profiles,
        convolutions_performed=convolutions,
        total_count=total,
        max_count_bit_length=max(total.bit_length(), max_count.bit_length() if max_count else 0),
    )


def outcome_stats(profile: cs.ProblemProfile) -> dict[str, object]:
    return {
        "count": profile.total_count,
        "consistent": profile.consistent,
        "frontier_variables": len(profile.variables),
        "unconstrained_closed_cells": profile.unconstrained_closed_cells,
        "constraint_count": len(profile.constraints),
        "component_count": len(profile.component_profiles),
        "component_sizes": [item.variable_count for item in profile.component_profiles],
        "largest_component": max((item.variable_count for item in profile.component_profiles), default=0),
        "component_vector_lengths": [len(item.solution_vector) for item in profile.component_profiles],
        "search_nodes": sum(item.search_nodes for item in profile.component_profiles),
        "branch_ops": sum(item.branch_ops for item in profile.component_profiles),
        "leaf_solutions": sum(item.leaf_solutions for item in profile.component_profiles),
        "memo_entries": sum(item.memo_entries for item in profile.component_profiles),
        "dp_states_explored": sum(item.dp_states_explored for item in profile.component_profiles),
        "convolutions_performed": profile.convolutions_performed,
        "total_remaining_mines": profile.total_remaining_mines,
    }


def evaluate_cell_exact_outcomes(
    transcript: cs.Transcript,
    cell_index: int,
    timeout_s: float | None = None,
    max_search_nodes: int | None = None,
    max_branch_ops: int | None = None,
) -> dict[str, object]:
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        raise ValueError("La celda evaluada debe estar cerrada.")

    started = time.perf_counter()
    budget = cs.BudgetContext(
        started_at=started,
        wall_clock_s=timeout_s,
        max_search_nodes=max_search_nodes,
        max_branch_ops=max_branch_ops,
    )
    counts: dict[str, int] = {}
    per_outcome: dict[str, dict[str, object]] = {}
    problems_executed = 0

    try:
        for outcome in cs.ALL_OUTCOMES:
            profile = problem_profile_for_hypothesis(
                transcript=transcript,
                cell_index=cell_index,
                outcome=outcome,
                budget=budget,
            )
            counts[outcome] = profile.total_count
            per_outcome[outcome] = outcome_stats(profile)
            problems_executed += 1
    except TimeoutError as exc:
        raise cs.EvaluationAbortedError(
            "timeout",
            {
                "status": "timeout",
                "counts": counts,
                "per_outcome": per_outcome,
                "problems_executed": problems_executed,
                "problems_expected": len(cs.ALL_OUTCOMES),
                "missing_outcomes": [outcome for outcome in cs.ALL_OUTCOMES if outcome not in counts],
                "partition_ok": False,
                "error_message": str(exc),
            },
            str(exc),
        ) from exc
    except cs.BudgetExceededError as exc:
        raise cs.EvaluationAbortedError(
            "budget_exceeded",
            {
                "status": "budget_exceeded",
                "counts": counts,
                "per_outcome": per_outcome,
                "problems_executed": problems_executed,
                "problems_expected": len(cs.ALL_OUTCOMES),
                "missing_outcomes": [outcome for outcome in cs.ALL_OUTCOMES if outcome not in counts],
                "partition_ok": False,
                "error_message": str(exc),
            },
            str(exc),
        ) from exc

    total_count = sum(counts.values())
    return {
        "status": "ok",
        "counts": counts,
        "sum_counts": total_count,
        "compatible_total_before_click": total_count,
        "partition_ok": total_count == sum(counts.values()) and len(counts) == len(cs.ALL_OUTCOMES),
        "missing_outcomes": [outcome for outcome in cs.ALL_OUTCOMES if outcome not in counts],
        "outcomes_positive": sum(1 for value in counts.values() if value > 0),
        "problems_executed": problems_executed,
        "problems_expected": len(cs.ALL_OUTCOMES),
        "additional_top_level_subproblems": 0,
        "total_search_nodes": sum(int(stats["search_nodes"]) for stats in per_outcome.values()),
        "total_branch_ops": sum(int(stats["branch_ops"]) for stats in per_outcome.values()),
        "total_leaf_solutions": sum(int(stats["leaf_solutions"]) for stats in per_outcome.values()),
        "total_memo_entries": sum(int(stats["memo_entries"]) for stats in per_outcome.values()),
        "total_dp_states_explored": sum(int(stats["dp_states_explored"]) for stats in per_outcome.values()),
        "total_convolutions": sum(int(stats["convolutions_performed"]) for stats in per_outcome.values()),
        "wall_clock_ms": (time.perf_counter() - started) * 1000.0,
        "per_outcome": per_outcome,
    }


def safe_evaluate_exact_outcomes(
    transcript: cs.Transcript,
    candidate: int,
    timeout_s: float,
    max_search_nodes: int | None,
    max_branch_ops: int | None,
) -> tuple[str, dict[str, object], str | None]:
    try:
        result = evaluate_cell_exact_outcomes(
            transcript,
            candidate,
            timeout_s=timeout_s,
            max_search_nodes=max_search_nodes,
            max_branch_ops=max_branch_ops,
        )
        return "ok", result, None
    except cs.EvaluationAbortedError as exc:
        return exc.kind, exc.partial_result, str(exc)
    except Exception as exc:
        return "error", {}, str(exc)


def compare_case(case: dict[str, object], raw_2a: dict[str, object]) -> dict[str, object]:
    transcript = transcript_from_corpus_row(case)
    result = evaluate_cell_exact_outcomes(transcript, int(case["clicked_cell"]["index"]))
    expected = raw_2a["result"]
    return {
        "case_id": case["case_id"],
        "transcript_id": case["transcript_id"],
        "clicked_cell": case["clicked_cell"],
        "ok": (
            result["counts"] == expected["counts"]
            and result["sum_counts"] == expected["sum_counts"]
            and result["compatible_total_before_click"] == expected["compatible_total_before_click"]
            and result["partition_ok"] == expected["partition_ok"]
        ),
        "counts_2b2": result["counts"],
        "counts_2a": expected["counts"],
        "problems_executed": result["problems_executed"],
        "problems_expected": result["problems_expected"],
        "search_nodes_2b2": result["total_search_nodes"],
        "search_nodes_2a": expected["total_search_nodes"],
        "branch_ops_2b2": result["total_branch_ops"],
        "branch_ops_2a": expected["total_branch_ops"],
        "wall_clock_ms_2b2": result["wall_clock_ms"],
        "wall_clock_ms_2a": expected["wall_clock_ms"],
        "additional_top_level_subproblems": result["additional_top_level_subproblems"],
        "result": result,
    }


def load_jsonl(path: Path) -> list[dict[str, object]]:
    return [
        json.loads(line)
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def run_smoke(corpus_path: Path, raw_2a_path: Path, case_ids: list[str]) -> list[dict[str, object]]:
    cases = load_jsonl(corpus_path)
    raws = load_jsonl(raw_2a_path)
    raw_by_key = {
        (row["generator_seed"], row["transcript_id"], row["clicked_cell"]["index"]): row
        for row in raws
    }
    comparisons: list[dict[str, object]] = []
    for case in cases:
        if case["case_id"] not in set(case_ids):
            continue
        key = (case["generator_seed"], case["transcript_id"], case["clicked_cell"]["index"])
        comparisons.append(compare_case(case, raw_by_key[key]))
    return comparisons


def print_case_report(title: str, comparison: dict[str, object]):
    print(f"{title}: {comparison['case_id']} {comparison['transcript_id']} cell={tuple(comparison['clicked_cell']['coord'])}")
    print(f"  ok_vs_2A: {comparison['ok']}")
    print(
        "  problems: "
        f"{comparison['problems_executed']}/{comparison['problems_expected']} "
        f"(additional_top_level_subproblems={comparison['additional_top_level_subproblems']})"
    )
    print(
        "  metrics: "
        f"search_nodes 2A={comparison['search_nodes_2a']} 2B2={comparison['search_nodes_2b2']} | "
        f"branch_ops 2A={comparison['branch_ops_2a']} 2B2={comparison['branch_ops_2b2']} | "
        f"wall_ms 2A={comparison['wall_clock_ms_2a']:.2f} 2B2={comparison['wall_clock_ms_2b2']:.2f}"
    )
    print("  counts:")
    for outcome in cs.ALL_OUTCOMES:
        print(f"    {outcome}: 2A={comparison['counts_2a'][outcome]} 2B2={comparison['counts_2b2'][outcome]}")


def manual_fixture_report() -> dict[str, object]:
    transcript = cs.Transcript(
        width=2,
        height=2,
        total_mines=1,
        revealed_clues={0: 1},
        known_mines=frozenset(),
        label="manual-square",
    )
    baseline = cs.evaluate_cell_baseline(transcript, 3)
    result = evaluate_cell_exact_outcomes(transcript, 3)
    return {
        "case_id": "manual-square",
        "transcript_id": transcript.label,
        "clicked_cell": {"coord": cs.coord_of(transcript.width, 3), "index": 3},
        "ok": (
            result["counts"] == baseline["counts"]
            and result["sum_counts"] == baseline["sum_counts"]
            and result["compatible_total_before_click"] == baseline["compatible_total_before_click"]
            and result["partition_ok"] == baseline["partition_ok"]
        ),
        "counts_2b2": result["counts"],
        "counts_2a": baseline["counts"],
        "problems_executed": result["problems_executed"],
        "problems_expected": result["problems_expected"],
        "search_nodes_2b2": result["total_search_nodes"],
        "search_nodes_2a": baseline["total_search_nodes"],
        "branch_ops_2b2": result["total_branch_ops"],
        "branch_ops_2a": baseline["total_branch_ops"],
        "wall_clock_ms_2b2": result["wall_clock_ms"],
        "wall_clock_ms_2a": baseline["wall_clock_ms"],
        "additional_top_level_subproblems": result["additional_top_level_subproblems"],
        "result": result,
    }


def main():
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2B2 exact outcomes")
    subparsers = parser.add_subparsers(dest="command", required=True)

    smoke = subparsers.add_parser("smoke", help="Corre smoke manual + corpus corto")
    smoke.add_argument(
        "--corpus",
        default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl",
    )
    smoke.add_argument(
        "--raw-2a",
        default="benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl",
    )
    smoke.add_argument("--case-ids", required=True, help="Lista separada por comas")

    args = parser.parse_args()
    if args.command == "smoke":
        print_case_report("manual", manual_fixture_report())
        for comparison in run_smoke(
            corpus_path=Path(args.corpus),
            raw_2a_path=Path(args.raw_2a),
            case_ids=[item for item in args.case_ids.split(",") if item],
        ):
            print_case_report("corpus", comparison)


if __name__ == "__main__":
    main()
