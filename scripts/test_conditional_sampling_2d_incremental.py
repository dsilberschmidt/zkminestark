#!/usr/bin/env python3

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_history_smoke as hs


class ConditionalSampling2DIncrementalTests(unittest.TestCase):
    def test_smoke_histories_have_expected_terminal_shapes(self):
        histories = {
            policy.history_id: hs.generate_history(policy)
            for policy in hs.HISTORY_POLICIES
        }
        self.assertEqual(histories["H1"][-1]["final_result"], "victory")
        self.assertEqual(histories["H2"][-1]["final_result"], "victory")
        self.assertEqual(histories["H3"][-1]["final_result"], "loss")
        self.assertGreaterEqual(len(histories["H1"]), 20)
        self.assertGreaterEqual(len(histories["H2"]), 20)
        self.assertGreaterEqual(len(histories["H3"]), 4)

    def test_incremental_matches_all_variants_on_history_prefix(self):
        rows = hs.generate_history(hs.HISTORY_POLICIES[0])[:6]
        with tempfile.TemporaryDirectory() as tmpdir:
            history_path = Path(tmpdir) / "history.jsonl"
            out_path = Path(tmpdir) / "benchmark.jsonl"
            history_path.write_text(
                "".join(json.dumps(row, sort_keys=True) + "\n" for row in rows),
                encoding="utf-8",
            )
            benchmark_rows = hs.benchmark_histories(history_path, out_path, modes=("2D0", "2D1"))
        self.assertEqual(len(benchmark_rows), len(rows))
        for row in benchmark_rows:
            for mode in ("2D0", "2D1"):
                self.assertEqual(row["compare"][mode]["counts"], row["compare"]["2A"]["counts"])
                self.assertEqual(row["compare"][mode]["sum_counts"], row["compare"]["2A"]["sum_counts"])
                self.assertEqual(
                    row["compare"][mode]["compatible_total_before_click"],
                    row["compare"]["2A"]["compatible_total_before_click"],
                )
                self.assertEqual(row["compare"][mode]["partition_ok"], row["compare"]["2A"]["partition_ok"])


if __name__ == "__main__":
    unittest.main()
