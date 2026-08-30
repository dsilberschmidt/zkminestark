#!/usr/bin/env python3
"""
EXPERIMENTO 2D — corpus histórico de smoke y benchmark longitudinal.
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

import conditional_sampling_2b2_exact_outcomes as b2
import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2d_incremental as inc
import conditional_sampling_exact as cs
import conditional_sampling_locality as b


BOARD_WIDTH = 12
BOARD_HEIGHT = 12
TOTAL_MINES = 20


@dataclass(frozen=True)
class HistoryPolicy:
    history_id: str
    policy_name: str
    start_mode: str
    move_mode: str
    seed: int


HISTORY_POLICIES = (
    HistoryPolicy("H1", "oracle_safe_local_center", "center", "local_safe", 2026083001),
    HistoryPolicy("H2", "oracle_safe_jump_edge", "corner", "jump_safe", 2026083003),
    HistoryPolicy("H3", "public_risky_aggressive", "lower_right", "risk_max_mine", 2026083109),
)


def board_from_seed(seed: int) -> frozenset[int]:
    return cs.random_board(BOARD_WIDTH, BOARD_HEIGHT, TOTAL_MINES, seed)


def transcript_from_revealed(mines: frozenset[int], revealed: set[int], label: str, seed: int) -> cs.Transcript:
    return cs.transcript_from_board(BOARD_WIDTH, BOARD_HEIGHT, TOTAL_MINES, mines, revealed, label, generator_seed=seed)


def is_victory(revealed: set[int]) -> bool:
    return len(revealed) == BOARD_WIDTH * BOARD_HEIGHT - TOTAL_MINES


def phase_for_transcript(transcript: cs.Transcript) -> str:
    safe_total = transcript.cell_count - transcript.total_mines
    progress = transcript.revealed_count / safe_total if safe_total else 1.0
    if progress < (1 / 3):
        return "early"
    if progress < (2 / 3):
        return "mid"
    return "late"


def manhattan(a: int, b: int) -> int:
    ax, ay = cs.coord_of(BOARD_WIDTH, a)
    bx, by = cs.coord_of(BOARD_WIDTH, b)
    return abs(ax - bx) + abs(ay - by)


def min_distance_to_revealed(cell: int, revealed: set[int]) -> int:
    if not revealed:
        return 0
    return min(manhattan(cell, other) for other in revealed)


def choose_start_safe(board_safe: set[int], mode: str) -> int:
    if mode == "center":
        return min(board_safe, key=lambda idx: (cs.manhattan_to_center(BOARD_WIDTH, BOARD_HEIGHT, idx), idx))
    if mode == "corner":
        return min(board_safe, key=lambda idx: (sum(cs.coord_of(BOARD_WIDTH, idx)), idx))
    if mode == "lower_right":
        return min(
            board_safe,
            key=lambda idx: (
                abs(cs.coord_of(BOARD_WIDTH, idx)[0] - (BOARD_WIDTH - 1))
                + abs(cs.coord_of(BOARD_WIDTH, idx)[1] - (BOARD_HEIGHT - 1)),
                idx,
            ),
        )
    raise ValueError(mode)


def frontier_candidates(transcript: cs.Transcript) -> list[int]:
    frontier = cs.frontier_closed_cells(transcript)
    return frontier if frontier else transcript.closed_cells()


def choose_local_safe(transcript: cs.Transcript, board_safe: set[int], previous_click: int | None) -> int:
    safe_closed = [cell for cell in transcript.closed_cells() if cell in board_safe]
    frontier_safe = [cell for cell in frontier_candidates(transcript) if cell in board_safe]
    source = frontier_safe if frontier_safe else safe_closed
    revealed = set(transcript.revealed_clues)
    return min(
        source,
        key=lambda idx: (
            min_distance_to_revealed(idx, revealed),
            0 if previous_click is None else manhattan(idx, previous_click),
            cs.manhattan_to_center(BOARD_WIDTH, BOARD_HEIGHT, idx),
            idx,
        ),
    )


def choose_jump_safe(transcript: cs.Transcript, board_safe: set[int], previous_click: int | None) -> int:
    safe_closed = [cell for cell in transcript.closed_cells() if cell in board_safe]
    border_safe = [
        cell
        for cell in safe_closed
        if cs.coord_of(BOARD_WIDTH, cell)[0] in (0, BOARD_WIDTH - 1)
        or cs.coord_of(BOARD_WIDTH, cell)[1] in (0, BOARD_HEIGHT - 1)
    ]
    source = border_safe if border_safe else safe_closed
    revealed = set(transcript.revealed_clues)
    return min(
        source,
        key=lambda idx: (
            -(0 if previous_click is None else manhattan(idx, previous_click)),
            -min_distance_to_revealed(idx, revealed),
            len([n for n in cs.neighbors(BOARD_WIDTH, BOARD_HEIGHT, idx) if n in transcript.revealed_clues]),
            idx,
        ),
    )


def choose_risky_public(transcript: cs.Transcript, previous_click: int | None) -> int:
    candidates = frontier_candidates(transcript)
    scored: list[tuple[float, int, int, int]] = []
    for cell in candidates:
        result = b3.evaluate_cell_shared_outcomes(transcript, cell)
        total = result["compatible_total_before_click"]
        mine_count = result["counts"][cs.MINE_OUTCOME]
        mine_prob = (mine_count / total) if total else -1.0
        scored.append(
            (
                -mine_prob,
                -result["outcomes_positive"],
                0 if previous_click is None else manhattan(cell, previous_click),
                cell,
            )
        )
    return min(scored)[-1]


def choose_next_click(
    policy: HistoryPolicy,
    transcript: cs.Transcript,
    board_safe: set[int],
    previous_click: int | None,
) -> int:
    if transcript.revealed_count == 0:
        return choose_start_safe(board_safe, policy.start_mode)
    if policy.move_mode == "local_safe":
        return choose_local_safe(transcript, board_safe, previous_click)
    if policy.move_mode == "jump_safe":
        return choose_jump_safe(transcript, board_safe, previous_click)
    if policy.move_mode == "risk_max_mine":
        return choose_risky_public(transcript, previous_click)
    raise ValueError(policy.move_mode)


def oracle_outcome(mines: frozenset[int], click: int) -> str:
    if click in mines:
        return cs.MINE_OUTCOME
    return str(cs.clue_for_board(BOARD_WIDTH, BOARD_HEIGHT, mines, click))


def advance_revealed(mines: frozenset[int], revealed: set[int], click: int) -> set[int]:
    updated = set(revealed)
    cs.reveal_from_board(BOARD_WIDTH, BOARD_HEIGHT, mines, updated, click)
    return updated


def history_step_record(
    policy: HistoryPolicy,
    transcript: cs.Transcript,
    click_number: int,
    click: int,
    outcome: str,
    previous_click: int | None,
    final_result: str,
    terminal: bool,
) -> dict[str, object]:
    profile = cs.problem_profile(transcript)
    b3_result = b3.evaluate_cell_shared_outcomes(transcript, click)
    return {
        "history_id": policy.history_id,
        "seed": policy.seed,
        "policy": policy.policy_name,
        "board": {
            "width": BOARD_WIDTH,
            "height": BOARD_HEIGHT,
            "total_mines": TOTAL_MINES,
        },
        "click_number": click_number,
        "phase": phase_for_transcript(transcript),
        "transcript_id": f"{policy.history_id}-step-{click_number:03d}",
        "transcript": transcript.to_json(),
        "clicked_cell": {
            "index": click,
            "coord": cs.coord_of(BOARD_WIDTH, click),
        },
        "real_outcome": outcome,
        "distance_from_previous_click": None if previous_click is None else manhattan(click, previous_click),
        "revealed_cells": transcript.revealed_count,
        "frontier_variables": len(profile.variables),
        "largest_component": max((len(component) for component in profile.component_variables), default=0),
        "outcomes_positive": b3_result["outcomes_positive"],
        "terminal": terminal,
        "final_result": final_result,
    }


def generate_history(policy: HistoryPolicy, max_clicks: int | None = None) -> list[dict[str, object]]:
    if max_clicks is None:
        max_clicks = 50 if policy.history_id == "H1" else 40
    mines = board_from_seed(policy.seed)
    board_safe = set(range(BOARD_WIDTH * BOARD_HEIGHT)) - set(mines)
    revealed: set[int] = set()
    previous_click: int | None = None
    rows: list[dict[str, object]] = []

    for click_number in range(max_clicks):
        transcript = transcript_from_revealed(mines, revealed, f"{policy.history_id}-t{click_number}", policy.seed)
        click = choose_next_click(policy, transcript, board_safe, previous_click)
        outcome = oracle_outcome(mines, click)
        if outcome == cs.MINE_OUTCOME:
            rows.append(
                history_step_record(
                    policy=policy,
                    transcript=transcript,
                    click_number=click_number,
                    click=click,
                    outcome=outcome,
                    previous_click=previous_click,
                    final_result="loss",
                    terminal=True,
                )
            )
            return rows

        revealed = advance_revealed(mines, revealed, click)
        final_result = "victory" if is_victory(revealed) else "in_progress"
        terminal = final_result == "victory"
        rows.append(
            history_step_record(
                policy=policy,
                transcript=transcript,
                click_number=click_number,
                click=click,
                outcome=outcome,
                previous_click=previous_click,
                final_result=final_result,
                terminal=terminal,
            )
        )
        previous_click = click
        if terminal:
            return rows

    if rows:
        rows[-1]["final_result"] = "incomplete"
    return rows


def generate_histories(out_path: Path) -> list[dict[str, object]]:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    rows: list[dict[str, object]] = []
    with out_path.open("w", encoding="utf-8") as handle:
        for policy in HISTORY_POLICIES:
            history = generate_history(policy)
            for row in history:
                handle.write(json.dumps(row, sort_keys=True) + "\n")
                rows.append(row)
    return rows


def _build_mode_result_row(
    mode: str,
    evaluation: dict[str, object],
    startup_transition: inc.IncrementalTransition,
    idx: int,
    next_transition: inc.IncrementalTransition | None,
    current_persistent_state_size: int,
) -> dict[str, object]:
    ev = evaluation["evaluation"]
    row: dict[str, object] = {
        "mode": mode,
        "status": "ok",
        "counts": evaluation["counts"],
        "sum_counts": evaluation["sum_counts"],
        "compatible_total_before_click": evaluation["compatible_total_before_click"],
        "partition_ok": evaluation["partition_ok"],
        "outcomes_positive": evaluation["outcomes_positive"],
        "frontier_variables": evaluation["frontier_variables"],
        "largest_component": evaluation["largest_component"],
        # Eval cost breakdown (transition NOT included)
        "eval_search_nodes": evaluation["total_search_nodes"],
        "eval_branch_ops": evaluation["total_branch_ops"],
        "eval_ordinary_materialization_nodes": ev["ordinary_materialization_search_nodes"],
        "eval_ordinary_materialization_branch_ops": ev["ordinary_materialization_branch_ops"],
        "eval_special_nodes": ev["special_evaluation_search_nodes"],
        "eval_special_branch_ops": ev["special_evaluation_branch_ops"],
        # Eval component classification
        "eval_reused_components": ev["reused_components"],
        "eval_materialized_ordinary_components": ev["materialized_ordinary_components"],
        "eval_materialized_ordinary_sizes": ev["materialized_ordinary_component_sizes"],
        "eval_recomputed_special_components": ev["recomputed_special_components"],
        "eval_recomputed_special_sizes": ev["recomputed_component_sizes"],
        "eval_special_from_transition": ev["special_from_transition_count"],
        "eval_special_from_deferred": ev["special_from_deferred_count"],
        "eval_unconstrained_local": ev["unconstrained_local_count"],
        "eval_unconstrained_other": ev["unconstrained_other_count"],
        # Startup cost (only non-zero at idx==0)
        "startup_search_nodes": startup_transition.search_nodes if idx == 0 else 0,
        "startup_branch_ops": startup_transition.branch_ops if idx == 0 else 0,
        "startup_persistent_state_size": startup_transition.persistent_state_size if idx == 0 else 0,
    }
    # Transition to next transcript (T_i -> T_{i+1})
    if next_transition is not None:
        row.update({
            "transition_search_nodes": next_transition.search_nodes,
            "transition_branch_ops": next_transition.branch_ops,
            "transition_reused_components": next_transition.reused_components,
            "transition_invalidated_components": next_transition.invalidated_components,
            "transition_changed_components": next_transition.changed_components,
            "transition_eagerly_counted_components": next_transition.eagerly_counted_components,
            "transition_deferred_components": next_transition.deferred_components,
            "transition_changed_component_sizes": next_transition.changed_component_sizes,
            "transition_eagerly_counted_sizes": next_transition.eagerly_counted_component_sizes,
            "transition_deferred_sizes": next_transition.deferred_component_sizes,
            "persistent_state_size": next_transition.persistent_state_size,
        })
    else:
        row.update({
            "transition_search_nodes": 0,
            "transition_branch_ops": 0,
            "transition_reused_components": 0,
            "transition_invalidated_components": 0,
            "transition_changed_components": 0,
            "transition_eagerly_counted_components": 0,
            "transition_deferred_components": 0,
            "transition_changed_component_sizes": [],
            "transition_eagerly_counted_sizes": [],
            "transition_deferred_sizes": [],
            "persistent_state_size": current_persistent_state_size,
        })
    return row


def benchmark_histories(
    history_path: Path,
    out_path: Path,
    modes: tuple[str, ...] = ("2D0", "2D1"),
) -> list[dict[str, object]]:
    rows = [json.loads(line) for line in history_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)

    all_rows: list[dict[str, object]] = []
    with out_path.open("w", encoding="utf-8") as handle:
        for history_id in sorted(by_history):
            history_rows = sorted(by_history[history_id], key=lambda item: int(item["click_number"]))
            first_transcript = b3.transcript_from_corpus_row({"transcript": history_rows[0]["transcript"]})

            # Separate state chain per mode
            states: dict[str, inc.IncrementalState] = {}
            startup_transitions: dict[str, inc.IncrementalTransition] = {}
            for mode in modes:
                s = inc.build_state(first_transcript, previous_state=None, mode=mode)
                states[mode] = s
                startup_transitions[mode] = s.last_transition

            for idx, row in enumerate(history_rows):
                transcript = b3.transcript_from_corpus_row({"transcript": row["transcript"]})
                cell_index = int(row["clicked_cell"]["index"])

                for mode in modes:
                    if transcript.to_json() != states[mode].transcript.to_json():
                        raise AssertionError(
                            f"Estado incremental desalineado ({mode}) en {history_id} click {row['click_number']}"
                        )

                result_2a = cs.evaluate_cell_baseline(transcript, cell_index)
                result_2b = b.evaluate_cell_locality(transcript, cell_index)
                result_2b2 = b2.evaluate_cell_exact_outcomes(transcript, cell_index)
                result_2b3 = b3.evaluate_cell_shared_outcomes(transcript, cell_index)

                mode_evaluations: dict[str, dict[str, object]] = {
                    mode: inc.evaluate_candidate_with_state(states[mode], cell_index)
                    for mode in modes
                }

                # Exact correctness check for all variants
                for variant_name, result in [("2B", result_2b), ("2B2", result_2b2), ("2B3", result_2b3)]:
                    if (
                        result["counts"] != result_2a["counts"]
                        or result["sum_counts"] != result_2a["sum_counts"]
                        or result["compatible_total_before_click"] != result_2a["compatible_total_before_click"]
                        or result["partition_ok"] != result_2a["partition_ok"]
                    ):
                        raise AssertionError(f"Mismatch {variant_name} en {history_id} click {row['click_number']}")

                for mode in modes:
                    ev = mode_evaluations[mode]
                    if (
                        ev["counts"] != result_2a["counts"]
                        or ev["sum_counts"] != result_2a["sum_counts"]
                        or ev["compatible_total_before_click"] != result_2a["compatible_total_before_click"]
                        or ev["partition_ok"] != result_2a["partition_ok"]
                    ):
                        raise AssertionError(
                            f"Mismatch {mode} en {history_id} click {row['click_number']}"
                        )

                # Build transitions to T_{i+1} (mutates states[mode] in place for deferred ordinary profiles)
                next_transitions: dict[str, inc.IncrementalTransition] = {}
                if idx + 1 < len(history_rows):
                    next_transcript = b3.transcript_from_corpus_row(
                        {"transcript": history_rows[idx + 1]["transcript"]}
                    )
                    for mode in modes:
                        next_state = inc.build_state(next_transcript, previous_state=states[mode], mode=mode)
                        next_transitions[mode] = next_state.last_transition
                        states[mode] = next_state

                compare: dict[str, object] = {
                    "2A": result_2a,
                    "2B": result_2b,
                    "2B2": result_2b2,
                    "2B3": result_2b3,
                }
                for mode in modes:
                    compare[mode] = _build_mode_result_row(
                        mode=mode,
                        evaluation=mode_evaluations[mode],
                        startup_transition=startup_transitions[mode],
                        idx=idx,
                        next_transition=next_transitions.get(mode),
                        current_persistent_state_size=states[mode].last_transition.persistent_state_size,
                    )

                # Pointwise eval-only factors (for reference; official metric is history sum)
                factors: dict[str, object] = {}
                for mode in modes:
                    eval_n = compare[mode]["eval_search_nodes"]
                    eval_b = compare[mode]["eval_branch_ops"]
                    factors[f"2b3_over_{mode.lower()}_eval"] = {
                        "search_nodes": result_2b3["total_search_nodes"] / eval_n if eval_n else None,
                        "branch_ops": result_2b3["total_branch_ops"] / eval_b if eval_b else None,
                    }

                out_row = {**row, "compare": compare, "factors": factors}
                handle.write(json.dumps(out_row, sort_keys=True) + "\n")
                all_rows.append(out_row)
    return all_rows


def summarize_histories(rows: list[dict[str, object]]) -> dict[str, object]:
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)
    summary: dict[str, object] = {}
    for history_id, items in sorted(by_history.items()):
        items = sorted(items, key=lambda row: int(row["click_number"]))
        summary[history_id] = {
            "policy": items[0]["policy"],
            "seed": items[0]["seed"],
            "clicks": len(items),
            "final_result": items[-1]["final_result"],
            "phases": {phase: sum(1 for row in items if row["phase"] == phase) for phase in ("early", "mid", "late")},
        }
    return summary


def main():
    parser = argparse.ArgumentParser(description="EXPERIMENTO 2D history smoke")
    subparsers = parser.add_subparsers(dest="command", required=True)

    histories = subparsers.add_parser("histories", help="Genera historias de smoke")
    histories.add_argument(
        "--out",
        default="benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl",
    )

    benchmark = subparsers.add_parser("benchmark", help="Corre benchmark longitudinal de smoke")
    benchmark.add_argument(
        "--histories",
        default="benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl",
    )
    benchmark.add_argument(
        "--out",
        default="benchmarks/conditional-sampling-2d-smoke-20260830.jsonl",
    )
    benchmark.add_argument(
        "--modes",
        default="2D0,2D1",
        help="Variantes incrementales a comparar, separadas por coma (default: 2D0,2D1)",
    )

    args = parser.parse_args()
    if args.command == "histories":
        rows = generate_histories(Path(args.out))
        print(json.dumps(summarize_histories(rows), indent=2, sort_keys=True))
    elif args.command == "benchmark":
        modes = tuple(m.strip() for m in args.modes.split(","))
        rows = benchmark_histories(Path(args.histories), Path(args.out), modes=modes)
        print(json.dumps(summarize_histories(rows), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
