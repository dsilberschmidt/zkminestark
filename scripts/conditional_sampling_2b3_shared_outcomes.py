#!/usr/bin/env python3
"""
EXPERIMENTO 2B3 — shared exact outcomes.

Cuenta el transcript una sola vez y produce directamente:
- N_mine
- N_0..N_8

Comparte trabajo entre outcomes clasificando cada completacion global por el
outcome observable de la celda x, en lugar de resolver 10 problemas
independientes.
"""

from __future__ import annotations

import argparse
import json
import math
import time
from dataclasses import dataclass
from pathlib import Path

import conditional_sampling_2b2_exact_outcomes as naive10
import conditional_sampling_exact as cs


@dataclass
class JointComponentProfile:
    variable_count: int
    constraint_count: int
    joint_counts: dict[tuple[int, int, int], int]
    search_nodes: int
    branch_ops: int
    leaf_solutions: int
    memo_entries: int
    dp_states_explored: int


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


def local_hidden_sets(transcript: cs.Transcript, cell_index: int) -> tuple[set[int], set[int], int]:
    local_hidden = {cell_index}
    hidden_neighbors: set[int] = set()
    adjacent_known_mines = 0
    for neighbor in cs.neighbors(transcript.width, transcript.height, cell_index):
        if neighbor in transcript.known_mines:
            adjacent_known_mines += 1
        elif neighbor in transcript.revealed_clues:
            continue
        else:
            hidden_neighbors.add(neighbor)
            local_hidden.add(neighbor)
    return local_hidden, hidden_neighbors, adjacent_known_mines


def count_component_joint(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    x_var: int | None,
    neighbor_vars: set[int],
    budget: cs.BudgetContext | None = None,
) -> JointComponentProfile:
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
    joint_counts: dict[tuple[int, int, int], int] = {}
    search_nodes = 0
    branch_ops = 0
    leaf_solutions = 0

    def dfs(pos: int, mines_used: int, x_mine: int, neighbor_mines: int):
        nonlocal search_nodes, branch_ops, leaf_solutions
        search_nodes += 1
        if budget is not None:
            budget.consume(search_nodes_delta=1)
        if pos == len(component_vars):
            for c_idx, (_scope, rhs) in enumerate(local_constraints):
                if partial_sum[c_idx] != rhs:
                    return
            joint_counts[(mines_used, x_mine, neighbor_mines)] = joint_counts.get((mines_used, x_mine, neighbor_mines), 0) + 1
            leaf_solutions += 1
            return

        current_var = component_vars[pos]
        is_x = current_var == x_var
        is_neighbor = current_var in neighbor_vars
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
                dfs(
                    pos + 1,
                    mines_used + value,
                    value if is_x else x_mine,
                    neighbor_mines + value if is_neighbor else neighbor_mines,
                )
            for c_idx in changed:
                partial_sum[c_idx] -= value
                unassigned[c_idx] += 1

    dfs(0, 0, 0, 0)
    return JointComponentProfile(
        variable_count=len(component_vars),
        constraint_count=len(component_constraints),
        joint_counts=joint_counts,
        search_nodes=search_nodes,
        branch_ops=branch_ops,
        leaf_solutions=leaf_solutions,
        memo_entries=0,
        dp_states_explored=0,
    )


def ordinary_component_factor(profile: cs.ComponentProfile) -> dict[tuple[int, int, int], int]:
    out: dict[tuple[int, int, int], int] = {}
    for mines_used, ways in enumerate(profile.solution_vector):
        if ways:
            out[(mines_used, 0, 0)] = ways
    return out


def unconstrained_local_factor(
    x_is_unconstrained: bool,
    unconstrained_neighbor_count: int,
) -> dict[tuple[int, int, int], int]:
    out: dict[tuple[int, int, int], int] = {}
    if x_is_unconstrained:
        for x_mine in (0, 1):
            for neighbor_mines in range(unconstrained_neighbor_count + 1):
                mines_used = x_mine + neighbor_mines
                ways = math.comb(unconstrained_neighbor_count, neighbor_mines)
                out[(mines_used, x_mine, neighbor_mines)] = out.get((mines_used, x_mine, neighbor_mines), 0) + ways
        return out

    for neighbor_mines in range(unconstrained_neighbor_count + 1):
        ways = math.comb(unconstrained_neighbor_count, neighbor_mines)
        out[(neighbor_mines, 0, neighbor_mines)] = out.get((neighbor_mines, 0, neighbor_mines), 0) + ways
    return out


def unconstrained_other_vector(total_cells: int) -> list[int]:
    return [math.comb(total_cells, mines_used) for mines_used in range(total_cells + 1)]


def convolve_joint(
    left: dict[tuple[int, int, int], int],
    right: dict[tuple[int, int, int], int],
) -> dict[tuple[int, int, int], int]:
    out: dict[tuple[int, int, int], int] = {}
    for (left_mines, left_x_mine, left_neighbors), left_ways in left.items():
        if left_ways == 0:
            continue
        for (right_mines, right_x_mine, right_neighbors), right_ways in right.items():
            if right_ways == 0:
                continue
            x_mine = left_x_mine + right_x_mine
            if x_mine > 1:
                continue
            key = (left_mines + right_mines, x_mine, left_neighbors + right_neighbors)
            out[key] = out.get(key, 0) + (left_ways * right_ways)
    return out


def analyze_joint_problem(
    transcript: cs.Transcript,
    cell_index: int,
    budget: cs.BudgetContext | None = None,
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
            "search_nodes": 0,
            "branch_ops": 0,
            "leaf_solutions": 0,
            "memo_entries": 0,
            "dp_states_explored": 0,
        }

    local_hidden, local_neighbors, adjacent_known_mines = local_hidden_sets(transcript, cell_index)
    frontier_var_set = set(variables)
    unconstrained_local = sorted(local_hidden - frontier_var_set)
    unconstrained_closed_cells = len([cell for cell in transcript.closed_cells() if cell not in frontier_var_set])
    unconstrained_other_count = unconstrained_closed_cells - len(unconstrained_local)
    component_variables, component_constraints = cs.connected_components(variables, constraints)

    aggregate: dict[tuple[int, int, int], int] = {(0, 0, 0): 1}
    convolutions = 0
    search_nodes = 0
    branch_ops = 0
    leaf_solutions = 0
    memo_entries = 0
    dp_states_explored = 0
    ordinary_component_count = 0
    special_component_count = 0

    for component_vars, component_constraints in zip(component_variables, component_constraints):
        component_var_set = set(component_vars)
        if not component_var_set.intersection(local_hidden):
            component_profile = cs.count_component(component_vars, component_constraints, budget=budget)
            factor = ordinary_component_factor(component_profile)
            ordinary_component_count += 1
            search_nodes += component_profile.search_nodes
            branch_ops += component_profile.branch_ops
            leaf_solutions += component_profile.leaf_solutions
            memo_entries += component_profile.memo_entries
            dp_states_explored += component_profile.dp_states_explored
        else:
            factor_profile = count_component_joint(
                component_vars=component_vars,
                component_constraints=component_constraints,
                x_var=cell_index if cell_index in component_var_set else None,
                neighbor_vars=local_neighbors.intersection(component_var_set),
                budget=budget,
            )
            factor = factor_profile.joint_counts
            special_component_count += 1
            search_nodes += factor_profile.search_nodes
            branch_ops += factor_profile.branch_ops
            leaf_solutions += factor_profile.leaf_solutions
            memo_entries += factor_profile.memo_entries
            dp_states_explored += factor_profile.dp_states_explored
        aggregate = convolve_joint(aggregate, factor)
        convolutions += 1

    if unconstrained_local:
        aggregate = convolve_joint(
            aggregate,
            unconstrained_local_factor(
                x_is_unconstrained=cell_index in unconstrained_local,
                unconstrained_neighbor_count=sum(1 for var in unconstrained_local if var in local_neighbors),
            ),
        )
        convolutions += 1

    if unconstrained_other_count > 0:
        aggregate = convolve_joint(
            aggregate,
            {(mines, 0, 0): ways for mines, ways in enumerate(unconstrained_other_vector(unconstrained_other_count)) if ways},
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
        "search_nodes": search_nodes,
        "branch_ops": branch_ops,
        "leaf_solutions": leaf_solutions,
        "memo_entries": memo_entries,
        "dp_states_explored": dp_states_explored,
    }


def counts_from_joint_distribution(
    transcript: cs.Transcript,
    cell_index: int,
    joint_distribution: dict[tuple[int, int, int], int],
    adjacent_known_mines: int,
) -> dict[str, int]:
    counts = {outcome: 0 for outcome in cs.ALL_OUTCOMES}
    remaining_mines = transcript.total_mines - len(transcript.known_mines)
    for (mines_used, x_mine, neighbor_mines), ways in joint_distribution.items():
        if mines_used != remaining_mines or ways == 0:
            continue
        if x_mine:
            counts[cs.MINE_OUTCOME] += ways
            continue
        clue_value = adjacent_known_mines + neighbor_mines
        if 0 <= clue_value <= 8:
            counts[str(clue_value)] += ways
    return counts


def evaluate_cell_shared_outcomes(
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
    try:
        analysis = analyze_joint_problem(transcript, cell_index, budget=budget)
    except TimeoutError as exc:
        raise cs.EvaluationAbortedError(
            "timeout",
            {
                "status": "timeout",
                "counts": {},
                "missing_outcomes": list(cs.ALL_OUTCOMES),
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
                "counts": {},
                "missing_outcomes": list(cs.ALL_OUTCOMES),
                "partition_ok": False,
                "error_message": str(exc),
            },
            str(exc),
        ) from exc

    counts = counts_from_joint_distribution(
        transcript=transcript,
        cell_index=cell_index,
        joint_distribution=analysis["joint_distribution"],
        adjacent_known_mines=int(analysis["adjacent_known_mines"]),
    )
    total_count = sum(counts.values())
    partition_ok = total_count == sum(counts.values())
    max_count = max(counts.values()) if counts else 0
    return {
        "status": "ok",
        "counts": counts,
        "sum_counts": total_count,
        "compatible_total_before_click": total_count,
        "partition_ok": partition_ok,
        "missing_outcomes": [],
        "outcomes_positive": sum(1 for value in counts.values() if value > 0),
        "problems_executed": 1,
        "shared_single_pass": True,
        "frontier_variables": len(analysis["variables"]),
        "constraint_count": len(analysis["constraints"]),
        "unconstrained_closed_cells": int(analysis["unconstrained_closed_cells"]),
        "total_search_nodes": int(analysis["search_nodes"]),
        "total_branch_ops": int(analysis["branch_ops"]),
        "total_leaf_solutions": int(analysis["leaf_solutions"]),
        "total_memo_entries": int(analysis["memo_entries"]),
        "total_dp_states_explored": int(analysis["dp_states_explored"]),
        "total_convolutions": int(analysis["convolutions_performed"]),
        "max_count_bit_length": max_count.bit_length() if max_count else 0,
        "wall_clock_ms": (time.perf_counter() - started) * 1000.0,
        "shared": {
            "ordinary_component_count": int(analysis["ordinary_component_count"]),
            "special_component_count": int(analysis["special_component_count"]),
            "unconstrained_local_cells": list(analysis["unconstrained_local_cells"]),
            "unconstrained_other_count": int(analysis["unconstrained_other_count"]),
            "adjacent_known_mines": int(analysis["adjacent_known_mines"]),
        },
    }


def compare_case(case: dict[str, object]) -> dict[str, object]:
    transcript = transcript_from_corpus_row(case)
    cell_index = int(case["clicked_cell"]["index"])
    baseline = cs.evaluate_cell_baseline(transcript, cell_index)
    naive = naive10.evaluate_cell_exact_outcomes(transcript, cell_index)
    shared = evaluate_cell_shared_outcomes(transcript, cell_index)
    return {
        "case_id": case["case_id"],
        "transcript_id": case["transcript_id"],
        "clicked_cell": case["clicked_cell"],
        "ok_vs_2a": (
            shared["counts"] == baseline["counts"]
            and shared["sum_counts"] == baseline["sum_counts"]
            and shared["compatible_total_before_click"] == baseline["compatible_total_before_click"]
            and shared["partition_ok"] == baseline["partition_ok"]
        ),
        "counts_2a": baseline["counts"],
        "counts_2b2": naive["counts"],
        "counts_2b3": shared["counts"],
        "metrics": {
            "2A": {
                "search_nodes": baseline["total_search_nodes"],
                "branch_ops": baseline["total_branch_ops"],
                "memo_entries": baseline["total_memo_entries"],
                "dp_states_explored": baseline["total_dp_states_explored"],
                "convolutions": baseline["total_convolutions"],
                "wall_clock_ms": baseline["wall_clock_ms"],
            },
            "2B2": {
                "search_nodes": naive["total_search_nodes"],
                "branch_ops": naive["total_branch_ops"],
                "memo_entries": naive["total_memo_entries"],
                "dp_states_explored": naive["total_dp_states_explored"],
                "convolutions": naive["total_convolutions"],
                "wall_clock_ms": naive["wall_clock_ms"],
            },
            "2B3": {
                "search_nodes": shared["total_search_nodes"],
                "branch_ops": shared["total_branch_ops"],
                "memo_entries": shared["total_memo_entries"],
                "dp_states_explored": shared["total_dp_states_explored"],
                "convolutions": shared["total_convolutions"],
                "wall_clock_ms": shared["wall_clock_ms"],
            },
        },
        "factor_2b2_over_2b3": {
            "search_nodes": naive["total_search_nodes"] / shared["total_search_nodes"] if shared["total_search_nodes"] else None,
            "branch_ops": naive["total_branch_ops"] / shared["total_branch_ops"] if shared["total_branch_ops"] else None,
            "wall_clock_ms": naive["wall_clock_ms"] / shared["wall_clock_ms"] if shared["wall_clock_ms"] else None,
        },
        "shared": shared["shared"],
    }


def manual_fixture_report() -> dict[str, object]:
    transcript = cs.Transcript(
        width=2,
        height=2,
        total_mines=1,
        revealed_clues={0: 1},
        known_mines=frozenset(),
        label="manual-square",
    )
    case = {
        "case_id": "manual-square",
        "transcript_id": transcript.label,
        "clicked_cell": {"coord": cs.coord_of(transcript.width, 3), "index": 3},
        "transcript": transcript.to_json(),
    }
    baseline = cs.evaluate_cell_baseline(transcript, 3)
    naive = naive10.evaluate_cell_exact_outcomes(transcript, 3)
    shared = evaluate_cell_shared_outcomes(transcript, 3)
    return {
        "case_id": case["case_id"],
        "transcript_id": case["transcript_id"],
        "clicked_cell": case["clicked_cell"],
        "ok_vs_2a": (
            shared["counts"] == baseline["counts"]
            and shared["sum_counts"] == baseline["sum_counts"]
            and shared["compatible_total_before_click"] == baseline["compatible_total_before_click"]
            and shared["partition_ok"] == baseline["partition_ok"]
        ),
        "counts_2a": baseline["counts"],
        "counts_2b2": naive["counts"],
        "counts_2b3": shared["counts"],
        "metrics": {
            "2A": {
                "search_nodes": baseline["total_search_nodes"],
                "branch_ops": baseline["total_branch_ops"],
                "memo_entries": baseline["total_memo_entries"],
                "dp_states_explored": baseline["total_dp_states_explored"],
                "convolutions": baseline["total_convolutions"],
                "wall_clock_ms": baseline["wall_clock_ms"],
            },
            "2B2": {
                "search_nodes": naive["total_search_nodes"],
                "branch_ops": naive["total_branch_ops"],
                "memo_entries": naive["total_memo_entries"],
                "dp_states_explored": naive["total_dp_states_explored"],
                "convolutions": naive["total_convolutions"],
                "wall_clock_ms": naive["wall_clock_ms"],
            },
            "2B3": {
                "search_nodes": shared["total_search_nodes"],
                "branch_ops": shared["total_branch_ops"],
                "memo_entries": shared["total_memo_entries"],
                "dp_states_explored": shared["total_dp_states_explored"],
                "convolutions": shared["total_convolutions"],
                "wall_clock_ms": shared["wall_clock_ms"],
            },
        },
        "factor_2b2_over_2b3": {
            "search_nodes": naive["total_search_nodes"] / shared["total_search_nodes"] if shared["total_search_nodes"] else None,
            "branch_ops": naive["total_branch_ops"] / shared["total_branch_ops"] if shared["total_branch_ops"] else None,
            "wall_clock_ms": naive["wall_clock_ms"] / shared["wall_clock_ms"] if shared["wall_clock_ms"] else None,
        },
        "shared": shared["shared"],
    }


def load_cases(corpus_path: Path, case_ids: list[str]) -> list[dict[str, object]]:
    wanted = set(case_ids)
    return [
        row
        for row in (
            json.loads(line)
            for line in corpus_path.read_text(encoding="utf-8").splitlines()
            if line.strip()
        )
        if row["case_id"] in wanted
    ]


def print_case_report(label: str, comparison: dict[str, object]):
    print(f"{label}: {comparison['case_id']} {comparison['transcript_id']} cell={tuple(comparison['clicked_cell']['coord'])}")
    print(f"  ok_vs_2A: {comparison['ok_vs_2a']}")
    print(
        "  shared: "
        f"special_components={comparison['shared']['special_component_count']} "
        f"ordinary_components={comparison['shared']['ordinary_component_count']} "
        f"unconstrained_local={comparison['shared']['unconstrained_local_cells']} "
        f"unconstrained_other={comparison['shared']['unconstrained_other_count']}"
    )
    print("  counts:")
    for outcome in cs.ALL_OUTCOMES:
        print(
            f"    {outcome}: "
            f"2A={comparison['counts_2a'][outcome]} "
            f"2B2={comparison['counts_2b2'][outcome]} "
            f"2B3={comparison['counts_2b3'][outcome]}"
        )
    print(
        "  metrics: "
        f"2A nodes/branches={comparison['metrics']['2A']['search_nodes']}/{comparison['metrics']['2A']['branch_ops']} | "
        f"2B2 nodes/branches={comparison['metrics']['2B2']['search_nodes']}/{comparison['metrics']['2B2']['branch_ops']} | "
        f"2B3 nodes/branches={comparison['metrics']['2B3']['search_nodes']}/{comparison['metrics']['2B3']['branch_ops']} | "
        f"factor 2B2/2B3={comparison['factor_2b2_over_2b3']['search_nodes']:.4f}"
    )
    print(
        "  extra metrics: "
        f"memo 2B3={comparison['metrics']['2B3']['memo_entries']} "
        f"dp_states 2B3={comparison['metrics']['2B3']['dp_states_explored']} "
        f"conv 2B3={comparison['metrics']['2B3']['convolutions']} "
        f"wall_ms 2B3={comparison['metrics']['2B3']['wall_clock_ms']:.2f}"
    )


def main():
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2B3 shared exact outcomes")
    subparsers = parser.add_subparsers(dest="command", required=True)

    smoke = subparsers.add_parser("smoke", help="Corre smoke 2B3")
    smoke.add_argument(
        "--corpus",
        default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl",
    )
    smoke.add_argument("--case-ids", required=True, help="Lista separada por comas")

    args = parser.parse_args()
    if args.command == "smoke":
        print_case_report("manual", manual_fixture_report())
        for case in load_cases(Path(args.corpus), [item for item in args.case_ids.split(",") if item]):
            print_case_report("corpus", compare_case(case))


if __name__ == "__main__":
    main()
