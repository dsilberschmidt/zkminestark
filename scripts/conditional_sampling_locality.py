#!/usr/bin/env python3
"""
EXPERIMENTO 2B — locality para conditional sampling exacto.

Parte del baseline 2A y evita recontar con DFS los componentes del grafo de
constraints que permanecen idénticos para un outcome dado.
"""

from __future__ import annotations

import argparse
import json
import statistics
import time
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

import conditional_sampling_exact as cs


@dataclass(frozen=True)
class ComponentSignature:
    variables: tuple[int, ...]
    constraints: tuple[tuple[tuple[int, ...], int], ...]


@dataclass(frozen=True)
class BaseComponentCatalogEntry:
    index: int
    signature: ComponentSignature
    variables: frozenset[int]
    constraints: tuple[cs.Constraint, ...]
    profile: cs.ComponentProfile


def component_signature(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
) -> ComponentSignature:
    return ComponentSignature(
        variables=tuple(component_vars),
        constraints=tuple((constraint.variables, constraint.rhs) for constraint in component_constraints),
    )


def constraint_vars(constraints: set[cs.Constraint]) -> set[int]:
    out: set[int] = set()
    for constraint in constraints:
        out.update(constraint.variables)
    return out


def base_component_catalog(profile: cs.ProblemProfile) -> list[BaseComponentCatalogEntry]:
    return [
        BaseComponentCatalogEntry(
            index=index,
            signature=component_signature(component_vars, component_constraints),
            variables=frozenset(component_vars),
            constraints=tuple(component_constraints),
            profile=component_profile,
        )
        for index, (component_vars, component_constraints, component_profile) in enumerate(
            zip(
                profile.component_variables,
                profile.component_constraints,
                profile.component_profiles,
            )
        )
    ]


def build_inconsistent_outcome_stats(total_remaining_mines: int) -> dict[str, object]:
    return {
        "count": 0,
        "total_remaining_mines": total_remaining_mines,
        "consistent": False,
        "frontier_variables": 0,
        "unconstrained_closed_cells": 0,
        "constraint_count": 0,
        "component_count": 0,
        "component_sizes": [],
        "largest_component": 0,
        "component_vector_lengths": [],
        "affected_components": [],
        "search_nodes": 0,
        "branch_ops": 0,
        "leaf_solutions": 0,
        "memo_entries": 0,
        "dp_states_explored": 0,
        "convolutions_performed": 0,
        "max_count_bit_length": 0,
        "components_reused": 0,
        "components_recomputed": 0,
        "reused_component_sizes": [],
        "recomputed_component_sizes": [],
        "largest_recomputed_component": 0,
        "reused_solution_vector_lengths": [],
        "recomputed_solution_vector_lengths": [],
        "merged_base_components": 0,
        "merged_base_component_sizes": [],
        "newly_constrained_vars": 0,
        "reused_component_indices": [],
    }


def summarize_counted_components(component_profiles: list[cs.ComponentProfile]) -> dict[str, int]:
    return {
        "search_nodes": sum(item.search_nodes for item in component_profiles),
        "branch_ops": sum(item.branch_ops for item in component_profiles),
        "leaf_solutions": sum(item.leaf_solutions for item in component_profiles),
        "memo_entries": sum(item.memo_entries for item in component_profiles),
        "dp_states_explored": sum(item.dp_states_explored for item in component_profiles),
    }


def count_outcome_locality(
    outcome_transcript: cs.Transcript,
    cell_index: int,
    before_click_profile: cs.ProblemProfile,
    catalog: list[BaseComponentCatalogEntry],
    limits: cs.EvaluationLimits | None,
    started_at: float,
    budget: cs.BudgetContext,
) -> tuple[int, dict[str, object]]:
    consistent, constraints, variables, remaining_mines = cs.build_constraints(outcome_transcript)
    if not consistent:
        return 0, build_inconsistent_outcome_stats(remaining_mines)

    closed_cells = outcome_transcript.closed_cells()
    variable_set = set(variables)
    unconstrained_closed = sum(1 for cell in closed_cells if cell not in variable_set)
    outcome_component_vars, outcome_component_constraints = cs.connected_components(variables, constraints)

    base_constraint_set = set(before_click_profile.constraints)
    outcome_constraint_set = set(constraints)
    changed_base_constraints = base_constraint_set - outcome_constraint_set
    changed_outcome_constraints = outcome_constraint_set - base_constraint_set
    changed_base_vars = constraint_vars(changed_base_constraints)
    changed_outcome_vars = constraint_vars(changed_outcome_constraints)

    touched_base_indices = {
        entry.index
        for entry in catalog
        if cell_index in entry.variables or entry.variables.intersection(changed_base_vars)
    }
    untouched_entries = [entry for entry in catalog if entry.index not in touched_base_indices]
    reusable_by_signature = Counter(entry.signature for entry in untouched_entries)
    reusable_profiles = {
        entry.signature: entry.profile
        for entry in untouched_entries
    }
    reusable_indices = {
        entry.signature: entry.index
        for entry in untouched_entries
    }
    base_var_to_component = {
        variable: entry.index
        for entry in catalog
        for variable in entry.variables
    }

    counted_component_profiles: list[cs.ComponentProfile] = []
    all_component_vectors: list[list[int]] = []
    reused_component_sizes: list[int] = []
    reused_component_vector_lengths: list[int] = []
    reused_component_indices: list[int] = []
    recomputed_component_sizes: list[int] = []
    recomputed_component_vector_lengths: list[int] = []
    affected_outcome_components: list[int] = []
    merged_base_component_sizes: list[int] = []
    merged_base_components = 0
    newly_constrained_vars = 0

    for out_index, (component_vars, component_constraints) in enumerate(
        zip(outcome_component_vars, outcome_component_constraints)
    ):
        signature = component_signature(component_vars, component_constraints)
        component_var_set = set(component_vars)
        can_reuse = (
            reusable_by_signature.get(signature, 0) > 0
            and not component_var_set.intersection(changed_outcome_vars)
        )
        if can_reuse:
            reusable_by_signature[signature] -= 1
            profile = reusable_profiles[signature]
            all_component_vectors.append(profile.solution_vector)
            reused_component_sizes.append(len(component_vars))
            reused_component_vector_lengths.append(len(profile.solution_vector))
            reused_component_indices.append(reusable_indices[signature])
            continue

        affected_outcome_components.append(out_index)
        profile = cs.count_component(component_vars, component_constraints, budget=budget)
        counted_component_profiles.append(profile)
        all_component_vectors.append(profile.solution_vector)
        recomputed_component_sizes.append(len(component_vars))
        recomputed_component_vector_lengths.append(len(profile.solution_vector))

        touched_base = {base_var_to_component[var] for var in component_vars if var in base_var_to_component}
        if len(touched_base) > 1:
            merged_base_components += 1
            merged_base_component_sizes.append(len(touched_base))
        newly_constrained_vars += sum(1 for var in component_vars if var not in base_var_to_component)

    combined = [1]
    convolutions = 0
    for vector in all_component_vectors:
        combined = cs.convolve_counts(combined, vector)
        convolutions += 1

    total = 0
    for mines_in_frontier, ways in enumerate(combined):
        if ways == 0:
            continue
        mines_in_unconstrained = remaining_mines - mines_in_frontier
        if 0 <= mines_in_unconstrained <= unconstrained_closed:
            total += ways * cs.math.comb(unconstrained_closed, mines_in_unconstrained)

    counted_totals = summarize_counted_components(counted_component_profiles)
    max_vector_count = max(
        [max(vector) for vector in all_component_vectors if vector] + [total],
        default=0,
    )
    return total, {
        "count": total,
        "total_remaining_mines": remaining_mines,
        "consistent": True,
        "frontier_variables": len(variables),
        "unconstrained_closed_cells": unconstrained_closed,
        "constraint_count": len(constraints),
        "component_count": len(outcome_component_vars),
        "component_sizes": [len(component) for component in outcome_component_vars],
        "largest_component": max((len(component) for component in outcome_component_vars), default=0),
        "component_vector_lengths": [len(vector) for vector in all_component_vectors],
        "affected_components": affected_outcome_components,
        "search_nodes": counted_totals["search_nodes"],
        "branch_ops": counted_totals["branch_ops"],
        "leaf_solutions": counted_totals["leaf_solutions"],
        "memo_entries": counted_totals["memo_entries"],
        "dp_states_explored": counted_totals["dp_states_explored"],
        "convolutions_performed": convolutions,
        "max_count_bit_length": max_vector_count.bit_length() if max_vector_count else 0,
        "components_reused": len(reused_component_sizes),
        "components_recomputed": len(recomputed_component_sizes),
        "reused_component_sizes": reused_component_sizes,
        "recomputed_component_sizes": recomputed_component_sizes,
        "largest_recomputed_component": max(recomputed_component_sizes, default=0),
        "reused_solution_vector_lengths": reused_component_vector_lengths,
        "recomputed_solution_vector_lengths": recomputed_component_vector_lengths,
        "merged_base_components": merged_base_components,
        "merged_base_component_sizes": merged_base_component_sizes,
        "newly_constrained_vars": newly_constrained_vars,
        "reused_component_indices": sorted(reused_component_indices),
    }


def evaluate_cell_locality(
    transcript: cs.Transcript,
    cell_index: int,
    timeout_s: float | None = None,
    max_search_nodes: int | None = None,
    max_branch_ops: int | None = None,
) -> dict[str, object]:
    started = time.perf_counter()
    if cell_index in transcript.revealed_clues or cell_index in transcript.known_mines:
        raise ValueError("La celda evaluada debe estar cerrada.")

    limits = cs.EvaluationLimits(
        wall_clock_s=timeout_s,
        max_search_nodes=max_search_nodes,
        max_branch_ops=max_branch_ops,
    )
    budget = cs.BudgetContext(
        started_at=started,
        wall_clock_s=limits.wall_clock_s,
        max_search_nodes=limits.max_search_nodes,
        max_branch_ops=limits.max_branch_ops,
    )
    try:
        total_count, total_profile = cs.count_outcome(transcript, limits=limits, started_at=started, budget=budget)
    except TimeoutError as exc:
        raise cs.EvaluationAbortedError(
            "timeout",
            cs.build_aborted_total_result(
                transcript=transcript,
                cell_index=cell_index,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="timeout",
                error_message=str(exc),
                budget=budget,
            ),
            str(exc),
        ) from exc
    except cs.BudgetExceededError as exc:
        raise cs.EvaluationAbortedError(
            "budget_exceeded",
            cs.build_aborted_total_result(
                transcript=transcript,
                cell_index=cell_index,
                wall_clock_ms=(time.perf_counter() - started) * 1000.0,
                final_status="budget_exceeded",
                error_message=str(exc),
                budget=budget,
            ),
            str(exc),
        ) from exc

    catalog = base_component_catalog(total_profile)
    counts: dict[str, int] = {}
    per_outcome: dict[str, dict[str, object]] = {}
    max_count = 0

    try:
        for outcome in cs.ALL_OUTCOMES:
            if timeout_s is not None and time.perf_counter() - started > timeout_s:
                raise TimeoutError(f"timeout evaluando celda {cs.coord_of(transcript.width, cell_index)}")
            outcome_transcript = cs.with_outcome(transcript, cell_index, outcome)
            count, stats = count_outcome_locality(
                outcome_transcript=outcome_transcript,
                cell_index=cell_index,
                before_click_profile=total_profile,
                catalog=catalog,
                limits=limits,
                started_at=started,
                budget=budget,
            )
            counts[outcome] = count
            max_count = max(max_count, count)
            per_outcome[outcome] = stats
    except TimeoutError as exc:
        raise cs.EvaluationAbortedError(
            "timeout",
            cs.build_partial_evaluation_result(
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
    except cs.BudgetExceededError as exc:
        raise cs.EvaluationAbortedError(
            "budget_exceeded",
            cs.build_partial_evaluation_result(
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

    result = cs.build_partial_evaluation_result(
        transcript=transcript,
        cell_index=cell_index,
        total_count=total_count,
        total_profile=total_profile,
        counts=counts,
        per_outcome=per_outcome,
        max_count=max_count,
        wall_clock_ms=(time.perf_counter() - started) * 1000.0,
        final_status="ok",
        error_message=None,
    )

    result["locality"] = {
        "components_available_before_click": len(catalog),
        "components_reused_total": sum(stats["components_reused"] for stats in per_outcome.values()),
        "components_recomputed_total": sum(stats["components_recomputed"] for stats in per_outcome.values()),
        "largest_recomputed_component": max(
            (int(stats["largest_recomputed_component"]) for stats in per_outcome.values()),
            default=0,
        ),
        "merged_base_components_total": sum(int(stats["merged_base_components"]) for stats in per_outcome.values()),
        "outcomes_with_component_merge": [
            outcome
            for outcome, stats in per_outcome.items()
            if int(stats["merged_base_components"]) > 0
        ],
        "outcomes_with_no_reuse": [
            outcome
            for outcome, stats in per_outcome.items()
            if int(stats["components_reused"]) == 0 and bool(stats["consistent"])
        ],
        "outcomes_with_full_reuse_of_untouched_components": [
            outcome
            for outcome, stats in per_outcome.items()
            if int(stats["components_reused"]) > 0
        ],
    }
    return result


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


def safe_evaluate_locality(
    transcript: cs.Transcript,
    candidate: int,
    timeout_s: float,
    max_search_nodes: int | None,
    max_branch_ops: int | None,
) -> tuple[str, dict[str, object], str | None]:
    try:
        result = evaluate_cell_locality(
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


def benchmark_row_from_corpus(
    case: dict[str, object],
    status: str,
    error: str | None,
    result: dict[str, object],
) -> dict[str, object]:
    return {
        "experiment": "2B-locality",
        "corpus": case["corpus"],
        "case_id": case["case_id"],
        "generator_seed": case["generator_seed"],
        "transcript_id": case["transcript_id"],
        "board": case["board"],
        "transcript": case["transcript"],
        "clicked_cell": case["clicked_cell"],
        "status": status,
        "error": error,
        "result": result,
    }


def run_corpus_benchmark(
    corpus_path: Path,
    out_path: Path,
    timeout_s: float,
    max_search_nodes: int | None,
    max_branch_ops: int | None,
    limit_cases: int | None = None,
) -> list[dict[str, object]]:
    cases = [
        json.loads(line)
        for line in corpus_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if limit_cases is not None:
        cases = cases[:limit_cases]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    rows: list[dict[str, object]] = []
    with out_path.open("w", encoding="utf-8") as handle:
        for idx, case in enumerate(cases, start=1):
            transcript = transcript_from_corpus_row(case)
            status, result, error = safe_evaluate_locality(
                transcript=transcript,
                candidate=int(case["clicked_cell"]["index"]),
                timeout_s=timeout_s,
                max_search_nodes=max_search_nodes,
                max_branch_ops=max_branch_ops,
            )
            row = benchmark_row_from_corpus(case, status, error, result)
            handle.write(json.dumps(row, sort_keys=True) + "\n")
            handle.flush()
            rows.append(row)
            print(
                f"[{idx:04d}/{len(cases)}] {case['case_id']} {case['transcript_id']} "
                f"cell={tuple(case['clicked_cell']['coord'])} status={status} "
                f"t={result.get('wall_clock_ms', 0):.1f}ms "
                f"nodes={result.get('total_search_nodes', 0)} "
                f"reuse={result.get('locality', {}).get('components_reused_total', 0)}"
            )
    return rows


def verify_against_2a(
    corpus_path: Path,
    raw_2a_path: Path,
    limit_cases: int | None = None,
) -> dict[str, object]:
    cases = [
        json.loads(line)
        for line in corpus_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    raws = [
        json.loads(line)
        for line in raw_2a_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if limit_cases is not None:
        cases = cases[:limit_cases]
        raws = raws[:limit_cases]
    checked = 0
    mismatches: list[dict[str, object]] = []
    for case, raw in zip(cases, raws):
        transcript = transcript_from_corpus_row(case)
        result = evaluate_cell_locality(transcript, int(case["clicked_cell"]["index"]))
        expected = raw["result"]
        for key in ("counts", "sum_counts", "compatible_total_before_click", "partition_ok"):
            if result[key] != expected[key]:
                mismatches.append({"case_id": case["case_id"], "key": key})
                break
        else:
            for key in (
                "frontier_variables",
                "constraint_count",
                "component_count",
                "component_sizes",
                "largest_component",
                "component_vector_lengths",
                "outcomes_positive",
                "max_count_bit_length",
            ):
                if result[key] != expected[key]:
                    mismatches.append({"case_id": case["case_id"], "key": key})
                    break
            else:
                checked += 1
    return {
        "checked": checked,
        "cases": len(cases),
        "mismatches": mismatches[:20],
        "ok": not mismatches,
    }


def percentile(values: list[float], p: float) -> float:
    return cs.percentile(values, p)


def summarize_rows(rows: list[dict[str, object]]) -> dict[str, object]:
    ok_rows = [row for row in rows if row["status"] == "ok"]
    if not ok_rows:
        return {"n": len(rows), "ok": 0}

    def stats(metric: str) -> dict[str, float]:
        values = [float(row["result"][metric]) for row in ok_rows]
        return {
            "min": min(values),
            "mean": statistics.mean(values),
            "p50": percentile(values, 50),
            "p95": percentile(values, 95),
            "p99": percentile(values, 99),
            "max": max(values),
        }

    return {
        "n": len(rows),
        "ok": len(ok_rows),
        "wall_clock_ms": stats("wall_clock_ms"),
        "total_search_nodes": stats("total_search_nodes"),
        "total_branch_ops": stats("total_branch_ops"),
        "largest_recomputed_component": {
            "max": max(float(row["result"]["locality"]["largest_recomputed_component"]) for row in ok_rows),
        },
        "components_reused_total": {
            "mean": statistics.mean(float(row["result"]["locality"]["components_reused_total"]) for row in ok_rows),
            "max": max(float(row["result"]["locality"]["components_reused_total"]) for row in ok_rows),
        },
        "merged_component_cases": sum(
            1
            for row in ok_rows
            if row["result"]["locality"]["merged_base_components_total"] > 0
        ),
    }


def main():
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2B locality")
    subparsers = parser.add_subparsers(dest="command", required=True)

    verify = subparsers.add_parser("verify", help="Verifica igualdad 2A vs 2B sobre corpus")
    verify.add_argument(
        "--corpus",
        default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl",
    )
    verify.add_argument(
        "--raw-2a",
        default="benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl",
    )
    verify.add_argument("--limit-cases", type=int, default=None)

    bench = subparsers.add_parser("benchmark", help="Corre 2B sobre corpus congelado")
    bench.add_argument(
        "--corpus",
        default="benchmarks/conditional-sampling-2a-corpus-20260830.jsonl",
    )
    bench.add_argument(
        "--out",
        default="benchmarks/conditional-sampling-2b-locality-20260830.jsonl",
    )
    bench.add_argument("--timeout-s", type=float, default=2.0)
    bench.add_argument("--max-search-nodes", type=int, default=100000)
    bench.add_argument("--max-branch-ops", type=int, default=200000)
    bench.add_argument("--limit-cases", type=int, default=None)

    args = parser.parse_args()
    if args.command == "verify":
        print(
            json.dumps(
                verify_against_2a(
                    corpus_path=Path(args.corpus),
                    raw_2a_path=Path(args.raw_2a),
                    limit_cases=args.limit_cases,
                ),
                indent=2,
                sort_keys=True,
            )
        )
    elif args.command == "benchmark":
        rows = run_corpus_benchmark(
            corpus_path=Path(args.corpus),
            out_path=Path(args.out),
            timeout_s=args.timeout_s,
            max_search_nodes=args.max_search_nodes,
            max_branch_ops=args.max_branch_ops,
            limit_cases=args.limit_cases,
        )
        print()
        print(json.dumps(summarize_rows(rows), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
