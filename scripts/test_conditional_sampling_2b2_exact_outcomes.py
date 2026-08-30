#!/usr/bin/env python3

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b2_exact_outcomes as exact10
import conditional_sampling_exact as cs


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


class ConditionalSampling2B2ExactOutcomesTests(unittest.TestCase):
    def assert_exact_match(self, transcript: cs.Transcript, cell_index: int):
        baseline = cs.evaluate_cell_baseline(transcript, cell_index)
        result = exact10.evaluate_cell_exact_outcomes(transcript, cell_index)
        for key in (
            "counts",
            "sum_counts",
            "compatible_total_before_click",
            "partition_ok",
            "missing_outcomes",
            "outcomes_positive",
        ):
            self.assertEqual(result[key], baseline[key], key)
        self.assertEqual(result["problems_executed"], 10)
        self.assertEqual(result["problems_expected"], 10)
        self.assertEqual(result["additional_top_level_subproblems"], 0)

    def test_manual_square_fixture_matches_2a(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        self.assert_exact_match(transcript, 3)

    def test_selected_corpus_case_matches_2a(self):
        case = load_corpus_case("2a-046")
        transcript = exact10.transcript_from_corpus_row(case)
        self.assert_exact_match(transcript, int(case["clicked_cell"]["index"]))


if __name__ == "__main__":
    unittest.main()
