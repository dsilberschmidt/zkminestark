#!/usr/bin/env python3
"""
Phase 6 fixture generator for 2G corpus-scale min-fill campaign.

Reads the 2A corpus (transcripts) + 2E2 JSONL (component signatures + orderings)
and writes one fixture record per special component to a JSONL file.

Each fixture contains everything needed for a Cairo test:
  variables, constraints, x_var, neighbor_vars, min_fill_order,
  min_fill_width, expected joint_counts (computed by Python VE).

Resumable: skips records already written to the output file.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2e2_variable_elimination as ve2e2
import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_exact as cs

CORPUS_PATH = Path("benchmarks/conditional-sampling-2a-corpus-20260830.jsonl")
E2_PATH = Path("benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl")
OUT_PATH = Path("benchmarks/2g-phase6-fixtures-20260831.jsonl")


def load_corpus_by_transcript_id(path: Path) -> dict[str, dict]:
    index: dict[str, dict] = {}
    with open(path) as f:
        for line in f:
            row = json.loads(line)
            tid = row["transcript_id"]
            index[tid] = row
    return index


def load_already_done(path: Path) -> set[str]:
    done: set[str] = set()
    if not path.exists():
        return done
    with open(path) as f:
        for line in f:
            rec = json.loads(line)
            done.add(rec["fixture_id"])
    return done


def transcript_from_row(row: dict) -> cs.Transcript:
    return b3.transcript_from_corpus_row(row)


def build_constraint(c: dict) -> cs.Constraint:
    return cs.Constraint(variables=tuple(sorted(c["scope"])), rhs=c["rhs"])


def run_ve(vars_: list[int], constraints: list[cs.Constraint], x_var: int | None, neighbor_vars: set[int]) -> dict[str, int]:
    profile = ve2e2.count_component_joint_ve(vars_, constraints, x_var, neighbor_vars)
    jc = profile.joint_counts or {}
    return {f"{k},{xm},{nm}": v for (k, xm, nm), v in sorted(jc.items())}


def main() -> None:
    corpus_by_tid = load_corpus_by_transcript_id(CORPUS_PATH)
    already_done = load_already_done(OUT_PATH)

    with open(E2_PATH) as ef, open(OUT_PATH, "a") as out:
        for line in ef:
            case = json.loads(line)
            case_id: str = case["case_id"]
            tid: str = case["transcript_id"]
            cell_index: int = int(case["clicked_cell"]["index"])

            corpus_row = corpus_by_tid.get(tid)
            if corpus_row is None:
                print(f"SKIP {case_id}: transcript {tid} not in corpus", file=sys.stderr)
                continue

            transcript = transcript_from_row(corpus_row)
            local_hidden, local_neighbors, _ = b3.local_hidden_sets(transcript, cell_index)

            ve = case["result"]["ve"]
            for comp in ve.get("components", []):
                if comp.get("role") != "special":
                    continue

                comp_idx: int = comp["component_index"]
                fixture_id = f"{case_id}__c{comp_idx}"
                if fixture_id in already_done:
                    print(f"skip {fixture_id} (done)", file=sys.stderr)
                    continue

                sig = comp["signature"]
                vars_ = sig["variables"]
                raw_constraints = sig["constraints"]
                constraints = [build_constraint(c) for c in raw_constraints]
                ordering: list[int] = comp["ordering"]
                min_fill_width: int = comp["min_fill_width"]

                var_set = set(vars_)
                x_var: int | None = cell_index if cell_index in var_set else None
                neighbor_vars: list[int] = sorted(local_neighbors & var_set)

                joint_counts = run_ve(vars_, constraints, x_var, set(neighbor_vars))

                record = {
                    "fixture_id": fixture_id,
                    "case_id": case_id,
                    "transcript_id": tid,
                    "component_index": comp_idx,
                    "size": comp["size"],
                    "constraint_count": comp["constraint_count"],
                    "min_fill_width": min_fill_width,
                    "variables": vars_,
                    "constraints": raw_constraints,
                    "x_var": x_var,
                    "neighbor_vars": neighbor_vars,
                    "min_fill_order": ordering,
                    "joint_counts": joint_counts,
                    "joint_entry_count": len(joint_counts),
                }
                out.write(json.dumps(record) + "\n")
                out.flush()
                print(f"done {fixture_id}: size={comp['size']} entries={len(joint_counts)}", file=sys.stderr)


if __name__ == "__main__":
    main()
