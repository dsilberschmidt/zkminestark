#!/usr/bin/env python3

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2e2_variable_elimination as e2
import conditional_sampling_exact as cs


CORPUS_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2a-corpus-20260830.jsonl"
ALL_5X5_2 = cs.enumerate_all_boards(5, 5, 2)


def load_corpus_case(case_id: str) -> dict[str, object]:
    for line in CORPUS_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row["case_id"] == case_id:
            return row
    raise KeyError(case_id)


class ConditionalSampling2E2VariableEliminationTests(unittest.TestCase):
    def test_constraint_factor_join_and_eliminate_counts_mines_exactly_once(self):
        constraints = [cs.Constraint((0, 1), 1), cs.Constraint((1, 2), 1)]
        profile = e2.count_component_ordinary_ve([0, 1, 2], constraints)
        self.assertEqual(profile.solution_vector, [0, 1, 1, 0])
        self.assertEqual(sum(profile.solution_vector), 2)

    def test_unsatisfiable_component_produces_zero_vector(self):
        constraints = [cs.Constraint((0,), 0), cs.Constraint((0,), 1)]
        profile = e2.count_component_ordinary_ve([0], constraints)
        self.assertEqual(profile.solution_vector, [0, 0])
        self.assertFalse(profile.satisfiable)

    def test_manual_square_ordinary_matches_dfs(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        consistent, constraints, variables, _ = cs.build_constraints(transcript)
        self.assertTrue(consistent)
        component_variables, component_constraints = cs.connected_components(variables, constraints)
        dfs = cs.count_component(component_variables[0], component_constraints[0])
        ve = e2.count_component_ordinary_ve(component_variables[0], component_constraints[0])
        self.assertEqual(ve.solution_vector, dfs.solution_vector)

    def test_special_joint_profile_matches_2b3_counter(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        consistent, constraints, variables, _ = cs.build_constraints(transcript)
        self.assertTrue(consistent)
        component_variables, component_constraints = cs.connected_components(variables, constraints)
        cell_index = 3
        _local_hidden, local_neighbors, _ = b3.local_hidden_sets(transcript, cell_index)
        dfs = b3.count_component_joint(
            component_variables[0],
            component_constraints[0],
            x_var=cell_index,
            neighbor_vars=local_neighbors.intersection(component_variables[0]),
        )
        ve = e2.count_component_joint_ve(
            component_variables[0],
            component_constraints[0],
            x_var=cell_index,
            neighbor_vars=local_neighbors.intersection(component_variables[0]),
        )
        self.assertEqual(ve.joint_counts, dfs.joint_counts)

    def test_small_oracle_matches_end_to_end_on_generated_transcripts(self):
        checked = 0
        for mines in ALL_5X5_2[:20]:
            safe = sorted(set(range(25)) - set(mines))
            transcript = cs.transcript_from_board(5, 5, 2, mines, set(safe[:2]), f"oracle-{sorted(mines)}")
            oracle_total = cs.transcript_total_count(transcript, ALL_5X5_2)
            for cell in transcript.closed_cells()[:3]:
                oracle = cs.exhaustive_outcome_counts(transcript, cell, ALL_5X5_2)
                ve = e2.evaluate_cell_2e2(transcript, cell)
                self.assertEqual(ve["counts"], oracle)
                self.assertEqual(ve["sum_counts"], oracle_total)
                self.assertTrue(ve["partition_ok"])
                checked += 1
        self.assertGreaterEqual(checked, 20)

    def test_end_to_end_matches_2b3_on_multi_component_corpus_case(self):
        case = load_corpus_case("2a-046")
        transcript = e2.transcript_from_corpus_row(case)
        cell_index = int(case["clicked_cell"]["index"])
        shared = b3.evaluate_cell_shared_outcomes(transcript, cell_index)
        ve = e2.evaluate_cell_2e2(transcript, cell_index)
        for key in ("counts", "sum_counts", "compatible_total_before_click", "partition_ok"):
            self.assertEqual(ve[key], shared[key], key)

    def test_component_plan_is_deterministic(self):
        constraints = [cs.Constraint((0, 1), 1), cs.Constraint((1, 2), 1), cs.Constraint((2, 3), 1)]
        first = e2.build_elimination_plan([0, 1, 2, 3], constraints)
        second = e2.build_elimination_plan([0, 1, 2, 3], constraints)
        self.assertEqual(first.ordering, second.ordering)
        self.assertEqual(first.min_fill_width, second.min_fill_width)

    def test_case_2a_005_matches_2b3_and_records_instrumentation(self):
        case = load_corpus_case("2a-005")
        comparison = e2.compare_case(case)
        self.assertTrue(comparison["ok_vs_2b3"])
        metrics = comparison["metrics"]["2E2"]
        self.assertGreater(metrics["factors_created"], 0)
        self.assertGreater(metrics["marginalizations"], 0)
        self.assertGreaterEqual(metrics["peak_factor_entries"], metrics["peak_nonzero_entries"])


if __name__ == "__main__":
    unittest.main()
