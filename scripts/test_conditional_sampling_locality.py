#!/usr/bin/env python3

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_exact as cs
import conditional_sampling_locality as loc


CORPUS_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2a-corpus-20260830.jsonl"
RAW_2A_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2a-benchmark-20260830.jsonl"


def load_corpus_case(case_id: str) -> dict[str, object]:
    for line in CORPUS_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row["case_id"] == case_id:
            return row
    raise KeyError(case_id)


def load_raw_case(case_id: str) -> dict[str, object]:
    corpus_case = load_corpus_case(case_id)
    for line in RAW_2A_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if (
            row["generator_seed"] == corpus_case["generator_seed"]
            and row["transcript_id"] == corpus_case["transcript_id"]
            and row["clicked_cell"]["index"] == corpus_case["clicked_cell"]["index"]
        ):
            return row
    raise KeyError(case_id)


class ConditionalSamplingLocalityTests(unittest.TestCase):
    def assert_same_discrete_result(self, transcript: cs.Transcript, cell_index: int):
        baseline = cs.evaluate_cell_baseline(transcript, cell_index)
        locality = loc.evaluate_cell_locality(transcript, cell_index)
        for key in (
            "counts",
            "sum_counts",
            "compatible_total_before_click",
            "partition_ok",
            "frontier_variables",
            "constraint_count",
            "component_count",
            "component_sizes",
            "largest_component",
            "component_vector_lengths",
            "outcomes_positive",
            "max_count_bit_length",
        ):
            self.assertEqual(locality[key], baseline[key], key)

    def test_manual_fixture_matches_2a(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        self.assert_same_discrete_result(transcript, 3)

    def test_first_corpus_case_matches_2a(self):
        case = load_corpus_case("2a-001")
        transcript = loc.transcript_from_corpus_row(case)
        self.assert_same_discrete_result(transcript, case["clicked_cell"]["index"])

    def test_multi_component_corpus_case_reuses_untouched_component(self):
        case = load_corpus_case("2a-046")
        transcript = loc.transcript_from_corpus_row(case)
        locality = loc.evaluate_cell_locality(transcript, case["clicked_cell"]["index"])
        raw = load_raw_case("2a-046")
        self.assertEqual(locality["counts"], raw["result"]["counts"])
        self.assertGreater(locality["locality"]["components_reused_total"], 0)
        self.assertEqual(locality["locality"]["merged_base_components_total"], 0)

    def test_verify_helper_matches_full_requested_invariants_on_sample(self):
        summary = loc.verify_against_2a(CORPUS_PATH, RAW_2A_PATH, limit_cases=12)
        self.assertTrue(summary["ok"])
        self.assertEqual(summary["checked"], 12)


if __name__ == "__main__":
    unittest.main()
