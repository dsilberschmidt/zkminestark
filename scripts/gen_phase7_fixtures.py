#!/usr/bin/env python3
"""
Phase 7 fixture generator: full CELL evaluation.

Produces benchmarks/2g-phase7-fixtures-20260831.jsonl with one record per
corpus case.  Each record contains the complete canonical problem structure
(no precooked counts) plus expected outcomes for correctness checking.

Public fixture fields (problem structure — no solutions precooked):
  special component: variables, constraints, x_var, neighbor_vars, min_fill_order
  ordinary_components: list of {variables, constraints}
  unconstrained_local:
    has_unc_local, x_is_unconstrained, unc_local_neighbor_count
  unconstrained_other_count
  remaining_mines
  adjacent_known_mines

Expected outcomes (from Python VE — for correctness only):
  outcomes: {mine: str, "0"..str, "8": str}  (large ints as strings)
  compatible_total: str (sum of all outcome counts)

Pre-phase-7 intermediate (for breakdown analysis, NOT for feeding into Cairo):
  agg_before_uncother: list of (mines, x_mine, nbrs, count) — aggregate
    after special VE + ordinary VE + unc_local convolution.
    Used only to audit that max count fits in u32 before binom multiplication.

Resumable: skips case_ids already written to output.
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
E2_PATH     = Path("benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl")
PHASE6_PATH = Path("benchmarks/2g-phase6-fixtures-20260831.jsonl")
OUT_PATH    = Path("benchmarks/2g-phase7-fixtures-20260831.jsonl")


def load_corpus(path: Path) -> dict[str, dict]:
    idx: dict[str, dict] = {}
    with open(path) as f:
        for line in f:
            row = json.loads(line)
            idx[row["transcript_id"]] = row
    return idx


def load_phase6(path: Path) -> dict[str, dict]:
    idx: dict[str, dict] = {}
    with open(path) as f:
        for line in f:
            rec = json.loads(line)
            idx[rec["case_id"]] = rec
    return idx


def load_already_done(path: Path) -> set[str]:
    done: set[str] = set()
    if not path.exists():
        return done
    with open(path) as f:
        for line in f:
            rec = json.loads(line)
            done.add(rec["case_id"])
    return done


def build_constraint_obj(c: dict) -> cs.Constraint:
    return cs.Constraint(variables=tuple(sorted(c["scope"])), rhs=c["rhs"])


def main() -> None:
    corpus = load_corpus(CORPUS_PATH)
    phase6 = load_phase6(PHASE6_PATH)
    already_done = load_already_done(OUT_PATH)

    with open(E2_PATH) as ef, open(OUT_PATH, "a") as out:
        for line in ef:
            case = json.loads(line)
            case_id: str = case["case_id"]
            if case_id in already_done:
                print(f"skip {case_id}", file=sys.stderr)
                continue

            tid: str = case["transcript_id"]
            cell_index: int = int(case["clicked_cell"]["index"])

            row = corpus.get(tid)
            if row is None:
                print(f"SKIP {case_id}: transcript {tid} not in corpus", file=sys.stderr)
                continue

            transcript = b3.transcript_from_corpus_row(row)
            consistent, constraints, variables, remaining_mines = cs.build_constraints(transcript)
            if not consistent:
                print(f"SKIP {case_id}: inconsistent", file=sys.stderr)
                continue

            local_hidden, local_neighbors, adj_known = b3.local_hidden_sets(transcript, cell_index)
            frontier = set(variables)
            unc_local = sorted(local_hidden - frontier)
            unc_closed = len([c for c in transcript.closed_cells() if c not in frontier])
            unc_other = unc_closed - len(unc_local)

            comp_vars, comp_constr = cs.connected_components(variables, constraints)

            # Identify special vs ordinary components
            special_comp_vars: list[int] | None = None
            special_comp_constr: list[cs.Constraint] | None = None
            special_x_var: int | None = None
            special_nbr_vars: list[int] = []
            ordinary_components: list[dict] = []

            for cvars, cconstr in zip(comp_vars, comp_constr):
                comp_var_set = set(cvars)
                if comp_var_set.intersection(local_hidden):
                    special_comp_vars = cvars
                    special_comp_constr = cconstr
                    special_x_var = cell_index if cell_index in comp_var_set else None
                    special_nbr_vars = sorted(local_neighbors & comp_var_set)
                else:
                    ordinary_components.append({
                        "variables": cvars,
                        "constraints": [{"scope": list(c.variables), "rhs": c.rhs} for c in cconstr],
                    })

            if special_comp_vars is None:
                print(f"SKIP {case_id}: no special component found", file=sys.stderr)
                continue

            # Get min-fill order from Phase 6 fixture
            p6 = phase6.get(case_id)
            if p6 is None:
                print(f"SKIP {case_id}: no phase6 fixture", file=sys.stderr)
                continue
            min_fill_order: list[int] = p6["min_fill_order"]

            # Compute full CELL to get expected outcomes
            # (This is Python's truth — Cairo must produce the same)
            analysis = ve2e2.analyze_joint_problem_ve(transcript, cell_index)
            counts = b3.counts_from_joint_distribution(
                transcript=transcript,
                cell_index=cell_index,
                joint_distribution=analysis["joint_distribution"],
                adjacent_known_mines=adj_known,
            )
            compatible_total = b3.compatible_total_from_joint_distribution(
                transcript=transcript,
                joint_distribution=analysis["joint_distribution"],
            )

            # Compute pre-binom aggregate for audit (not fed into Cairo)
            agg_pre: dict[tuple[int,int,int], int] = {(0, 0, 0): 1}
            for cvars, cconstr in zip(comp_vars, comp_constr):
                comp_var_set = set(cvars)
                if comp_var_set.intersection(local_hidden):
                    profile = ve2e2.count_component_joint_ve(
                        component_vars=cvars,
                        component_constraints=cconstr,
                        x_var=special_x_var,
                        neighbor_vars=set(special_nbr_vars),
                    )
                    factor = profile.joint_counts or {}
                else:
                    profile = ve2e2.count_component_ordinary_ve(cvars, cconstr)
                    factor = b3.ordinary_component_factor(profile)
                agg_pre = b3.convolve_joint(agg_pre, factor)
            if unc_local:
                x_unc = cell_index in unc_local
                nbr_unc_count = sum(1 for v in unc_local if v in local_neighbors)
                agg_pre = b3.convolve_joint(agg_pre, b3.unconstrained_local_factor(x_unc, nbr_unc_count))

            max_pre_count = max(v for v in agg_pre.values() if v > 0)
            fits_u32 = max_pre_count <= (1 << 32) - 1

            record = {
                "case_id": case_id,
                "transcript_id": tid,
                "remaining_mines": remaining_mines,
                "adjacent_known_mines": adj_known,
                # Special component (public problem structure)
                "special": {
                    "variables": special_comp_vars,
                    "constraints": [{"scope": list(c.variables), "rhs": c.rhs} for c in special_comp_constr],
                    "x_var": special_x_var,
                    "neighbor_vars": special_nbr_vars,
                    "min_fill_order": min_fill_order,
                    "min_fill_width": p6["min_fill_width"],
                },
                # Ordinary components (public problem structure)
                "ordinary_components": ordinary_components,
                # Unconstrained cells (public counts)
                "unconstrained_local": {
                    "has": len(unc_local) > 0,
                    "x_is_unconstrained": cell_index in unc_local,
                    "neighbor_count": sum(1 for v in unc_local if v in local_neighbors),
                    "total": len(unc_local),
                },
                "unconstrained_other_count": unc_other,
                # Expected outcomes (for correctness only)
                "expected_outcomes": {
                    "mine": str(counts.get("mine", 0)),
                    **{str(i): str(counts.get(str(i), 0)) for i in range(9)},
                },
                "compatible_total": str(compatible_total),
                # Audit fields
                "_audit": {
                    "agg_before_uncother_size": len([v for v in agg_pre.values() if v > 0]),
                    "max_agg_count_before_uncother": max_pre_count,
                    "fits_u32": fits_u32,
                    "n_ordinary": len(ordinary_components),
                    "n_unc_local": len(unc_local),
                },
            }
            out.write(json.dumps(record) + "\n")
            out.flush()
            print(
                f"done {case_id}: ord={len(ordinary_components)} unc_loc={len(unc_local)} "
                f"unc_oth={unc_other} max_agg={max_pre_count} fits_u32={fits_u32}",
                file=sys.stderr,
            )


if __name__ == "__main__":
    main()
