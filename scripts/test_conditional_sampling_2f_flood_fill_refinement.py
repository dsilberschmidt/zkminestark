#!/usr/bin/env python3

from __future__ import annotations

import unittest
from fractions import Fraction
from pathlib import Path
import sys
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2f_flood_fill_refinement as f2
import conditional_sampling_exact as cs


def exhaustive_clue_counts(state: f2.GeneralizedState, cell_index: int) -> dict[str, int]:
    counts = {str(clue): 0 for clue in f2.clue_domain(state.width, state.height, cell_index)}
    for mines in f2.exhaustive_compatible_boards(state):
        clue = cs.clue_for_board(state.width, state.height, mines, cell_index)
        counts[str(clue)] += 1
    return counts


def exhaustive_binary_counts(state: f2.GeneralizedState, cell_index: int) -> dict[str, int]:
    exact = exhaustive_clue_counts(state, cell_index)
    return {"0": exact["0"], ">0": sum(count for clue, count in exact.items() if clue != "0")}


class ConditionalSampling2FFloodFillRefinementTests(unittest.TestCase):
    def setUp(self):
        self.transcript_3x3 = cs.Transcript(
            width=3,
            height=3,
            total_mines=2,
            revealed_clues={4: 2},
            known_mines=frozenset(),
            label="3x3-center-2",
        )

    def test_compatible_total_matches_exhaustive_on_generalized_state(self):
        state = f2.with_allowed_clues(f2.state_from_transcript(self.transcript_3x3), 1, f2.positive_clue_domain(3, 3, 1))
        oracle_total = len(f2.exhaustive_compatible_boards(state))
        result = f2.evaluate_safe_cell_exact(state, 1)
        self.assertEqual(result["compatible_total_before_query"], oracle_total)

    def test_binary_query_matches_exhaustive(self):
        state = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1})
        result = f2.evaluate_safe_cell_binary(state, 1)
        self.assertEqual(result["counts"], exhaustive_binary_counts(state, 1))

    def test_binary_query_does_not_depend_on_exact_evaluator(self):
        state = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1})
        with mock.patch.object(f2, "evaluate_safe_cell_exact", side_effect=AssertionError("must not be called")):
            result = f2.evaluate_safe_cell_binary(state, 1)
        self.assertEqual(result["counts"], exhaustive_binary_counts(state, 1))

    def test_binary_partition_matches_compatible_total(self):
        state = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1})
        result = f2.evaluate_safe_cell_binary(state, 1)
        self.assertEqual(result["counts"]["0"] + result["counts"][">0"], result["compatible_total_before_query"])
        self.assertTrue(result["partition_ok"])

    def test_exact_query_matches_exhaustive(self):
        state = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1})
        result = f2.evaluate_safe_cell_exact(state, 1)
        self.assertEqual(result["counts"], exhaustive_clue_counts(state, 1))

    def test_refinement_from_positive_condition_preserves_partition(self):
        base = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1})
        positive_state = f2.with_allowed_clues(base, 1, f2.positive_clue_domain(3, 3, 1))
        result = f2.evaluate_safe_cell_exact(positive_state, 1)
        oracle = exhaustive_clue_counts(positive_state, 1)
        self.assertEqual(result["counts"], oracle)
        self.assertEqual(sum(result["counts"].values()), result["compatible_total_before_query"])
        self.assertEqual(result["counts"]["0"], 0)

    def test_multiple_positive_constraints_can_overlap(self):
        transcript = cs.Transcript(
            width=3,
            height=3,
            total_mines=2,
            revealed_clues={1: 1, 3: 1, 4: 2},
            known_mines=frozenset(),
            label="3x3-overlap",
        )
        state = f2.state_from_transcript(transcript)
        state = f2.with_allowed_clues(state, 0, f2.positive_clue_domain(3, 3, 0))
        state = f2.with_allowed_clues(state, 2, f2.positive_clue_domain(3, 3, 2))
        result = f2.evaluate_safe_cell_exact(state, 0)
        self.assertEqual(result["counts"], exhaustive_clue_counts(state, 0))

    def test_exact_and_positive_constraints_can_mix(self):
        transcript = cs.Transcript(
            width=3,
            height=3,
            total_mines=2,
            revealed_clues={4: 2},
            known_mines=frozenset(),
            label="3x3-mix",
        )
        state = f2.state_from_transcript(transcript)
        state = f2.with_allowed_clues(state, 0, {1})
        state = f2.with_allowed_clues(state, 1, f2.positive_clue_domain(3, 3, 1))
        state = f2.with_known_safe(state, {2})
        result = f2.evaluate_safe_cell_binary(state, 2)
        self.assertEqual(result["counts"], exhaustive_binary_counts(state, 2))

    def test_inconsistent_states_are_detected(self):
        state = f2.GeneralizedState(
            width=1,
            height=1,
            total_mines=0,
            known_mines=frozenset(),
            known_safe=frozenset({0}),
            allowed_clues=((0, (1,)),),
            label="inconsistent",
        )
        consistent, _constraints, _variables, _remaining, _unconstrained = f2.build_generalized_constraints(state)
        self.assertFalse(consistent)
        result = f2.evaluate_safe_cell_exact(state, 0)
        self.assertEqual(result["compatible_total_before_query"], 0)

    def test_total_mine_coupling_is_preserved(self):
        transcript = cs.Transcript(
            width=4,
            height=1,
            total_mines=2,
            revealed_clues={1: 1},
            known_mines=frozenset(),
            label="1x4-coupled",
        )
        state = f2.state_from_transcript(transcript)
        state = f2.with_known_safe(state, {2})
        result = f2.evaluate_safe_cell_exact(state, 2)
        self.assertEqual(result["compatible_total_before_query"], len(f2.exhaustive_compatible_boards(state)))
        self.assertEqual(result["counts"], exhaustive_clue_counts(state, 2))

    def test_known_safe_without_exact_clue_leaves_cell_out_of_mine_universe(self):
        state = f2.with_known_safe(f2.state_from_transcript(self.transcript_3x3), {1, 2})
        result = f2.evaluate_safe_cell_exact(state, 2)
        for mines in f2.exhaustive_compatible_boards(state):
            self.assertNotIn(2, mines)
        self.assertEqual(result["counts"], exhaustive_clue_counts(state, 2))

    def test_teacher_forced_flood_fill_policies_share_final_distribution_and_probability(self):
        mines = frozenset({0, 15})
        before = cs.Transcript(
            width=4,
            height=4,
            total_mines=2,
            revealed_clues={},
            known_mines=frozenset(),
            label="teacher-before",
        )
        clicked_cell = 6
        revealed = cs.reveal_from_board(4, 4, mines, set(), clicked_cell)
        after = cs.transcript_from_board(4, 4, 2, mines, revealed, "teacher-after")
        initial_state = f2.with_allowed_clues(f2.state_from_transcript(before), clicked_cell, {0})
        initial_compatible = len(f2.exhaustive_compatible_boards(initial_state))

        results = {
            policy: f2.simulate_policy_on_oracle_flood_fill(before, after, clicked_cell, policy)
            for policy in f2.ALL_POLICIES
        }
        final_board_sets = {}
        final_probabilities = {}
        for policy, result in results.items():
            self.assertEqual(result["status"], "ok")
            self.assertTrue(result["all_partitions_ok"])
            self.assertTrue(result["final_transcript_match"])
            self.assertTrue(result["path_identity_ok"])
            final_state = f2.GeneralizedState(
                width=after.width,
                height=after.height,
                total_mines=after.total_mines,
                known_mines=after.known_mines,
                known_safe=frozenset(item["index"] for item in result["final_exact_clues"]),
                allowed_clues=f2.canonical_allowed_map({item["index"]: {item["clue"]} for item in result["final_exact_clues"]}),
                label=policy,
            )
            final_boards = f2.exhaustive_compatible_boards(final_state)
            final_board_sets[policy] = set(final_boards)
            final_probabilities[policy] = Fraction(result["path_probability_numerator"], result["path_probability_denominator"])
            self.assertEqual(final_probabilities[policy], Fraction(len(final_boards), initial_compatible))
            self.assertEqual(result["wave_count"], len(result["waves"]))
            self.assertEqual(result["validation_expected_wave_count"], len(result["waves"]))
            self.assertEqual(result["compatible_final"], len(final_boards))
            self.assertEqual(result["compatible_final_validation"], len(final_boards))
            metrics = result["instrumentation"]
            self.assertGreaterEqual(metrics["dense_factor_capacity_touched"], metrics["nonzero_factor_entries_processed"])
            self.assertGreaterEqual(metrics["peak_factor_entries"], metrics["peak_nonzero_factor_entries"])
            self.assertGreaterEqual(metrics["total_solves"], metrics["binary_classifications"] + metrics["exact_refinements"])

        self.assertEqual(final_board_sets[f2.POLICY_CELL], final_board_sets[f2.POLICY_WAVE])
        self.assertEqual(final_board_sets[f2.POLICY_CELL], final_board_sets[f2.POLICY_FULL_REGION])
        self.assertEqual(final_probabilities[f2.POLICY_CELL], final_probabilities[f2.POLICY_WAVE])
        self.assertEqual(final_probabilities[f2.POLICY_CELL], final_probabilities[f2.POLICY_FULL_REGION])


if __name__ == "__main__":
    unittest.main()
