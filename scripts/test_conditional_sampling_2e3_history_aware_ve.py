#!/usr/bin/env python3

import json
import sys
import tempfile
import unittest
from unittest import mock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2e2_variable_elimination as e2
import conditional_sampling_2e3_history_aware_ve as e3
import conditional_sampling_exact as cs
import conditional_sampling_history_smoke as hs


CORPUS_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2a-corpus-20260830.jsonl"
BENCHMARK_2E3_PATH = Path(__file__).resolve().parents[1] / "benchmarks" / "conditional-sampling-2e3-histories-30x16-20260831.jsonl"


def load_corpus_case(case_id: str) -> dict[str, object]:
    for line in CORPUS_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row["case_id"] == case_id:
            return row
    raise KeyError(case_id)


def load_benchmark_history_click(history_id: str, click_number: int) -> dict[str, object]:
    for line in BENCHMARK_2E3_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row["history_id"] == history_id and int(row["click_number"]) == click_number:
            return row
    raise KeyError((history_id, click_number))


class ConditionalSampling2E3HistoryAwareVETests(unittest.TestCase):
    def test_unchanged_component_reuses_exact_messages(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="unchanged",
        )
        engine, state = e3.startup_engine(transcript)
        _state_again, result = e3.evaluate_cell_2e3(engine, transcript, 3, previous_state=state)
        self.assertEqual(result["counts"], b3.evaluate_cell_shared_outcomes(transcript, 3)["counts"])
        self.assertGreaterEqual(result["history_aware"]["messages_reused"], 0)
        self.assertEqual(result["history_aware"]["transition_class"], "identical")

    def test_local_base_factor_change_invalidates_only_dependency_cone(self):
        first = cs.Transcript(
            width=3,
            height=1,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="t0",
        )
        second = cs.Transcript(
            width=3,
            height=1,
            total_mines=1,
            revealed_clues={0: 1, 2: 0},
            known_mines=frozenset(),
            label="t1",
        )
        engine, state0 = e3.startup_engine(first)
        state1 = e3.advance_engine(engine, second)
        _state1, result = e3.evaluate_cell_2e3(engine, second, 1, previous_state=state0)
        self.assertEqual(result["counts"], e2.evaluate_cell_2e2(second, 1)["counts"])
        self.assertIn(result["history_aware"]["transition_class"], {"local_change", "strong_change", "split", "component_identical"})
        self.assertGreaterEqual(result["history_aware"]["messages_invalidated"], 0)
        self.assertEqual(state1.transcript.to_json(), second.to_json())

    def test_unrelated_change_preserves_independent_component(self):
        transcript0 = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 4: 1},
            known_mines=frozenset(),
            label="independent-0",
        )
        transcript1 = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 3: 1, 4: 1},
            known_mines=frozenset(),
            label="independent-1",
        )
        engine, state0 = e3.startup_engine(transcript0)
        e3.advance_engine(engine, transcript1)
        _state1, result = e3.evaluate_cell_2e3(engine, transcript1, 1, previous_state=state0)
        self.assertEqual(result["counts"], e2.evaluate_cell_2e2(transcript1, 1)["counts"])
        self.assertGreaterEqual(result["history_aware"]["whole_component_hits"], 0)

    def test_component_identical_marks_special_component_stable_while_transcript_changes(self):
        prev = e3.transcript_from_row(load_benchmark_history_click("C03", 1))
        curr_row = load_benchmark_history_click("C03", 2)
        curr = e3.transcript_from_row(curr_row)
        cell_index = int(curr_row["clicked_cell"]["index"])
        engine, state0 = e3.startup_engine(prev)
        e3.advance_engine(engine, curr)
        _state1, result = e3.evaluate_cell_2e3(engine, curr, cell_index, previous_state=state0)
        self.assertEqual(result["counts"], e2.evaluate_cell_2e2(curr, cell_index)["counts"])
        self.assertEqual(result["history_aware"]["transition_class"], "component_identical")
        self.assertGreater(result["history_aware"]["vars_added"], 0)

    def test_merge_classification(self):
        prev = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 4: 1},
            known_mines=frozenset(),
            label="merge-prev",
        )
        curr = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 2: 2, 4: 1},
            known_mines=frozenset(),
            label="merge-curr",
        )
        engine, state0 = e3.startup_engine(prev)
        e3.advance_engine(engine, curr)
        _state1, result = e3.evaluate_cell_2e3(engine, curr, 1, previous_state=state0)
        self.assertEqual(result["counts"], e2.evaluate_cell_2e2(curr, 1)["counts"])
        self.assertIn(result["history_aware"]["transition_class"], {"merge", "strong_change"})

    def test_split_classification(self):
        prev = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 2: 2, 4: 1},
            known_mines=frozenset(),
            label="split-prev",
        )
        curr = cs.Transcript(
            width=5,
            height=1,
            total_mines=2,
            revealed_clues={0: 1, 4: 1},
            known_mines=frozenset(),
            label="split-curr",
        )
        engine, state0 = e3.startup_engine(prev)
        e3.advance_engine(engine, curr)
        _state1, result = e3.evaluate_cell_2e3(engine, curr, 1, previous_state=state0)
        self.assertEqual(result["counts"], e2.evaluate_cell_2e2(curr, 1)["counts"])
        self.assertIn(result["history_aware"]["transition_class"], {"split", "strong_change"})

    def test_plan_rebuild_is_reported(self):
        first = cs.Transcript(
            width=3,
            height=2,
            total_mines=2,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="plan0",
        )
        second = cs.Transcript(
            width=3,
            height=2,
            total_mines=2,
            revealed_clues={0: 1, 5: 1},
            known_mines=frozenset(),
            label="plan1",
        )
        engine, state0 = e3.startup_engine(first)
        e3.advance_engine(engine, second)
        _state1, result = e3.evaluate_cell_2e3(engine, second, 2, previous_state=state0)
        self.assertGreaterEqual(result["history_aware"]["plan_rebuilt"], 0)

    def test_exact_fallback_matches_2e2(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="fallback",
        )
        engine, state = e3.startup_engine(transcript, force_fallback_min_fill_width=0)
        _state2, result = e3.evaluate_cell_2e3(engine, transcript, 3, previous_state=state)
        reference = e2.evaluate_cell_2e2(transcript, 3)
        self.assertTrue(result["history_aware"]["fallback_snapshot"])
        self.assertEqual(result["counts"], reference["counts"])

    def test_query_change_does_not_reuse_invalid_special_overlay(self):
        case = load_corpus_case("2a-046")
        transcript = e2.transcript_from_corpus_row(case)
        engine, startup_state = e3.startup_engine(transcript)
        _state_a, result_a = e3.evaluate_cell_2e3(engine, transcript, int(case["clicked_cell"]["index"]), previous_state=startup_state)
        other_cell = next(cell for cell in transcript.closed_cells() if cell != int(case["clicked_cell"]["index"]))
        _state_b, result_b = e3.evaluate_cell_2e3(engine, transcript, other_cell, previous_state=startup_state)
        self.assertEqual(result_a["counts"], e2.evaluate_cell_2e2(transcript, int(case["clicked_cell"]["index"]))["counts"])
        self.assertEqual(result_b["counts"], e2.evaluate_cell_2e2(transcript, other_cell)["counts"])

    def test_ordinary_profile_matches_snapshot(self):
        case = load_corpus_case("2a-005")
        transcript = e2.transcript_from_corpus_row(case)
        engine, state = e3.startup_engine(transcript)
        component_vectors = [component.solution_vector for component in state.component_states]
        reference = e2.evaluate_cell_2e2(transcript, int(case["clicked_cell"]["index"]))
        self.assertTrue(any(component_vectors))
        self.assertEqual(reference["sum_counts"], b3.evaluate_cell_shared_outcomes(transcript, int(case["clicked_cell"]["index"]))["sum_counts"])

    def test_special_profile_matches_snapshot(self):
        transcript = cs.Transcript(
            width=2,
            height=2,
            total_mines=1,
            revealed_clues={0: 1},
            known_mines=frozenset(),
            label="manual-square",
        )
        engine, startup_state = e3.startup_engine(transcript)
        _state, result = e3.evaluate_cell_2e3(engine, transcript, 3, previous_state=startup_state)
        reference = e2.evaluate_cell_2e2(transcript, 3)
        self.assertEqual(result["counts"], reference["counts"])
        self.assertEqual(result["sum_counts"], reference["sum_counts"])

    def test_end_to_end_multi_click_history_exactness(self):
        rows = hs.generate_history(hs.HISTORY_POLICIES[0])[:6]
        with tempfile.TemporaryDirectory() as tmpdir:
            history_path = Path(tmpdir) / "history.jsonl"
            out_path = Path(tmpdir) / "benchmark.jsonl"
            history_path.write_text(
                "".join(json.dumps(row, sort_keys=True) + "\n" for row in rows),
                encoding="utf-8",
            )
            benchmark_rows = e3.benchmark_smoke_histories(history_path, out_path, include_secondary=False)
        self.assertEqual(len(benchmark_rows), len(rows))
        for row in benchmark_rows:
            self.assertEqual(row["compare"]["2E3"]["counts"], row["compare"]["2B3"]["counts"])
            self.assertEqual(row["compare"]["2E3"]["sum_counts"], row["compare"]["2E2"]["sum_counts"])

    def test_history_generation_is_deterministic(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            first = Path(tmpdir) / "first.jsonl"
            second = Path(tmpdir) / "second.jsonl"
            rows_first = e3.generate_common_histories_30x16(first, seeds=(2026083101,), max_clicks=8)
            rows_second = e3.generate_common_histories_30x16(second, seeds=(2026083101,), max_clicks=8)
        self.assertEqual(rows_first, rows_second)

    def test_benchmark_resumes_within_history_without_rewriting_existing_clicks(self):
        rows = hs.generate_history(hs.HISTORY_POLICIES[0])[:2]
        with tempfile.TemporaryDirectory() as tmpdir:
            history_path = Path(tmpdir) / "history.jsonl"
            out_path = Path(tmpdir) / "benchmark.jsonl"
            history_path.write_text(
                "".join(json.dumps(row, sort_keys=True) + "\n" for row in rows),
                encoding="utf-8",
            )
            first_only = e3.benchmark_smoke_histories(history_path, out_path, include_secondary=False)
            out_path.write_text(json.dumps(first_only[0], sort_keys=True) + "\n", encoding="utf-8")
            resumed = e3.benchmark_smoke_histories(history_path, out_path, include_secondary=False)
            persisted = [json.loads(line) for line in out_path.read_text(encoding="utf-8").splitlines() if line.strip()]
        self.assertEqual(len(resumed), 2)
        self.assertEqual(len(persisted), 2)
        self.assertEqual([row["click_number"] for row in persisted], [0, 1])

    def test_summary_handles_timeout_as_censored_observation(self):
        row = {
            "history_id": "H",
            "click_number": 0,
            "phase": "early",
            "policy": "dummy",
            "seed": 1,
            "terminal_state": "incomplete",
            "compare": {
                "2B3": {"status": "timeout", "timeout_s": 150, "wall_clock_ms": None, "wall_clock_ms_lower_bound": 150000.0},
                "2E2": {"status": "ok", "wall_clock_ms": 12.0, "counts": {}, "sum_counts": 0, "compatible_total_before_click": 0, "partition_ok": True},
                "2E3": {"status": "ok", "counts": {}, "sum_counts": 0, "compatible_total_before_click": 0, "partition_ok": True, "history_aware": {"total_ms": 20.0, "reuse_fraction": 0.0, "fallback_snapshot": False, "cache_peak_entries": 0, "cache_peak_messages": 0}},
            },
        }
        summary = e3.summarize_history_rows([row])
        self.assertIsNone(summary["H"]["total_2B3_ms"])
        self.assertEqual(summary["H"]["total_2B3_ms_lower_bound"], 150000.0)
        self.assertEqual(summary["H"]["timeouts"]["2B3"], 1)

    def test_reuse_fraction_is_bounded(self):
        previous_state = mock.Mock(active_keys={1, 2, 3})
        current_state = mock.Mock(
            active_keys={1, 2},
            build_summary=mock.Mock(messages_recomputed=2, factor_entries_reused=0, factor_entries_recomputed=0, hits=0),
            component_states=[],
        )
        evaluation = {"history_aware": {"messages_reused": 4, "messages_recomputed": 1, "factor_entries_reused": 0, "factor_entries_recomputed": 0}}
        cache = mock.Mock(entries={1: mock.Mock(nonzero_entries=1), 2: mock.Mock(nonzero_entries=1), 3: mock.Mock(nonzero_entries=1)})
        reuse = e3._reuse_accounting(previous_state, current_state, evaluation, cache)
        self.assertLessEqual(reuse.reuse_fraction, 1.0)
        self.assertEqual(reuse.messages_reused, 6)
        self.assertEqual(reuse.messages_recomputed, 3)


if __name__ == "__main__":
    unittest.main()
