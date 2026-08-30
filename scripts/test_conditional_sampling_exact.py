#!/usr/bin/env python3

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_exact as cs


ALL_5X5_2 = cs.enumerate_all_boards(5, 5, 2)


def transcript_from_revealed(mines, revealed, label):
    return cs.transcript_from_board(5, 5, 2, mines, set(revealed), label)


def deterministic_transcripts_for_board(mines):
    safe = sorted(set(range(25)) - set(mines))
    center_first = sorted(safe, key=lambda idx: (cs.manhattan_to_center(5, 5, idx), idx))

    variants = [tuple()]
    variants.append(tuple(center_first[:1]))
    variants.append(tuple(center_first[:2]))
    variants.append(tuple(center_first[:4]))

    transcripts = []
    seen = set()
    for variant in variants:
        transcript = transcript_from_revealed(mines, variant, f"board-{sorted(mines)}-{variant}")
        key = tuple(sorted(transcript.revealed_clues))
        if key not in seen:
            seen.add(key)
            transcripts.append(transcript)
    return transcripts


class ConditionalSamplingExactTests(unittest.TestCase):
    def test_manual_line_fixture_has_exact_corner_weights(self):
        transcript = cs.Transcript(
            width=3,
            height=1,
            total_mines=1,
            revealed_clues={1: 1},
            known_mines=frozenset(),
            label="manual-line",
        )
        result = cs.evaluate_cell_baseline(transcript, 0)
        self.assertEqual(
            result["counts"],
            {"mine": 1, "0": 1, "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "7": 0, "8": 0},
        )
        self.assertEqual(result["compatible_total_before_click"], 2)
        self.assertTrue(result["partition_ok"])

    def test_manual_square_fixture_has_exact_interior_weights(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        result = cs.evaluate_cell_baseline(transcript, 3)
        self.assertEqual(
            result["counts"],
            {"mine": 1, "0": 0, "1": 2, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "7": 0, "8": 0},
        )
        self.assertEqual(result["compatible_total_before_click"], 3)
        self.assertTrue(result["partition_ok"])

    def test_known_mine_reduces_global_remaining_mines_exactly(self):
        transcript = cs.Transcript(
            width=3,
            height=1,
            total_mines=1,
            revealed_clues={1: 1},
            known_mines=frozenset({0}),
            label="manual-known-mine",
        )
        result = cs.evaluate_cell_baseline(transcript, 2)
        self.assertEqual(
            result["counts"],
            {"mine": 0, "0": 1, "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "7": 0, "8": 0},
        )
        self.assertEqual(result["mines_remaining"], 0)
        self.assertEqual(result["compatible_total_before_click"], 1)

    def test_exhaustive_oracle_matches_counter_on_generated_transcripts(self):
        checked = 0
        for mines in ALL_5X5_2:
            for transcript in deterministic_transcripts_for_board(mines):
                oracle_total = cs.transcript_total_count(transcript, ALL_5X5_2)
                closed = transcript.closed_cells()
                candidates = sorted(
                    closed,
                    key=lambda idx: (cs.manhattan_to_center(5, 5, idx), idx),
                )[:3]
                for cell in candidates:
                    oracle = cs.exhaustive_outcome_counts(transcript, cell, ALL_5X5_2)
                    baseline = cs.evaluate_cell_baseline(transcript, cell)
                    self.assertEqual(oracle, baseline["counts"])
                    self.assertEqual(sum(oracle.values()), oracle_total)
                    self.assertTrue(baseline["partition_ok"])
                    self.assertEqual(baseline["sum_counts"], oracle_total)
                    checked += 1
        self.assertGreaterEqual(checked, 1000)

    def test_impossible_outcomes_are_zero(self):
        mines = ALL_5X5_2[0]
        transcript = transcript_from_revealed(mines, [0], "impossible")
        cell = 24
        result = cs.evaluate_cell_baseline(transcript, cell)
        degree = len(cs.neighbors(5, 5, cell))
        for clue in range(degree + 1, 9):
            self.assertEqual(result["counts"][str(clue)], 0)

    def test_incompatible_transcript_has_zero_space(self):
        transcript = cs.Transcript(
            width=5,
            height=5,
            total_mines=2,
            revealed_clues={12: 9},
            known_mines=frozenset(),
            label="incompatible",
        )
        result = cs.evaluate_cell_baseline(transcript, 0)
        self.assertEqual(result["compatible_total_before_click"], 0)
        self.assertEqual(result["sum_counts"], 0)
        self.assertTrue(result["partition_ok"])

    def test_forced_mine_and_unique_configuration_exist(self):
        mines = ALL_5X5_2[0]
        safe = sorted(set(range(25)) - set(mines))
        transcript = transcript_from_revealed(mines, safe, "unique-forced-mine")
        closed = transcript.closed_cells()
        self.assertEqual(len(closed), 2)
        for cell in closed:
            result = cs.evaluate_cell_baseline(transcript, cell)
            self.assertEqual(result["compatible_total_before_click"], 1)
            self.assertEqual(result["counts"]["mine"], 1)
            self.assertEqual(result["sum_counts"], 1)

    def test_forced_safe_case_exists(self):
        found = False
        for mines in ALL_5X5_2:
            for transcript in deterministic_transcripts_for_board(mines):
                for cell in transcript.closed_cells():
                    result = cs.evaluate_cell_baseline(transcript, cell)
                    total = result["compatible_total_before_click"]
                    if total > 0 and result["counts"]["mine"] == 0:
                        found = True
                        for outcome, count in result["counts"].items():
                            if outcome != "mine":
                                self.assertGreaterEqual(count, 0)
                        break
                if found:
                    break
            if found:
                break
        self.assertTrue(found, "No se encontró ningún caso de celda forzada safe.")

    def test_benchmark_timeout_returns_partial_result_instead_of_error(self):
        transcript = cs.generate_benchmark_transcripts(30, 16, 99, 20260840)[0]
        candidate = cs.pick_diverse_candidates(transcript, limit=1)[0]
        status, result, error = cs.safe_evaluate_for_benchmark(
            transcript,
            candidate,
            timeout_s=0.0,
            max_search_nodes=100000,
            max_branch_ops=200000,
        )
        self.assertEqual(status, "timeout")
        self.assertIn("timeout", error)
        self.assertEqual(result["status"], "timeout")
        self.assertEqual(result["counts"], {})
        self.assertEqual(result["missing_outcomes"], list(cs.ALL_OUTCOMES))
        self.assertFalse(result["partition_ok"])

    def test_benchmark_budget_returns_partial_result_instead_of_error(self):
        transcript = cs.generate_benchmark_transcripts(30, 16, 99, 20260840)[0]
        candidate = cs.pick_diverse_candidates(transcript, limit=1)[0]
        status, result, error = cs.safe_evaluate_for_benchmark(
            transcript,
            candidate,
            timeout_s=2.0,
            max_search_nodes=1,
            max_branch_ops=200000,
        )
        self.assertEqual(status, "budget_exceeded")
        self.assertIn("budget exceeded", error)
        self.assertEqual(result["status"], "budget_exceeded")
        self.assertEqual(result["counts"], {})
        self.assertEqual(result["missing_outcomes"], list(cs.ALL_OUTCOMES))
        self.assertFalse(result["partition_ok"])

    def test_small_benchmark_run_never_demotes_abortions_to_generic_error(self):
        rows = cs.run_benchmark(
            out_path=Path("/tmp/conditional-sampling-2a-hardening-test.jsonl"),
            width=30,
            height=16,
            total_mines=99,
            seeds=(20260840,),
            timeout_s=0.0,
            max_search_nodes=100000,
            max_branch_ops=200000,
            max_evaluations=2,
        )
        self.assertEqual(len(rows), 2)
        self.assertTrue(all(row["status"] == "timeout" for row in rows))
        self.assertTrue(all(row["result"]["status"] == "timeout" for row in rows))
        self.assertTrue(all(row["error"] is not None for row in rows))

    def test_total_metrics_include_before_click_and_all_outcomes(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-metrics",
        )
        result = cs.evaluate_cell_baseline(transcript, 3)
        per_outcome = result["per_outcome"]
        self.assertEqual(
            result["total_search_nodes"],
            result["before_click_search_nodes"] + sum(item["search_nodes"] for item in per_outcome.values()),
        )
        self.assertEqual(
            result["total_branch_ops"],
            result["before_click_branch_ops"] + sum(item["branch_ops"] for item in per_outcome.values()),
        )
        self.assertEqual(
            result["total_convolutions"],
            result["before_click_convolutions"] + sum(item["convolutions_performed"] for item in per_outcome.values()),
        )


if __name__ == "__main__":
    unittest.main()
