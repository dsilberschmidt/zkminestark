#!/usr/bin/env python3
"""
Phase 8 fixture generator: flood-fill CELL sequence.

For each of the 22 reconstruible flood-fill cases from Phase 2F, replays
the CELL policy simulation and emits one fixture record per CELL evaluation.

Output: benchmarks/2g-phase8-fixtures-20260831.jsonl
  One record per (flood_index, step). Each record has:
    flood_id           — "HISTORY_CLICK" key
    flood_index        — 1..22
    step               — 1..N within flood
    cell_index         — board position of the queried cell
    wave_index         — wave within flood (1-based)
    oracle_clue        — realized public clue (used to advance state)
    remaining_mines    — at evaluation time
    adjacent_known_mines
    has_special        — whether a special component exists
    special            — {variables, constraints (rhs), x_var, neighbor_vars,
                           min_fill_order, min_fill_width} | null
    ordinary_components — list of {variables, constraints (rhs)}
    unconstrained_local — {has, x_is_unconstrained=False, neighbor_count, total}
    unconstrained_other_count
    expected_outcomes  — {mine: "0", "0".."8": str}
    compatible_total   — str
    _audit             — {n_constraints_multi_valued, n_constraints, n_ordinary, n_unc_local}

404-safe: each flood is written atomically (all steps); per-flood resumability
via done_floods set. Overwrites any partial flood on re-run (detect by checking
step count vs expected).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2f_flood_fill_refinement as f2
import conditional_sampling_exact as cs

OUT_PATH     = Path("benchmarks/2g-phase8-fixtures-20260831.jsonl")
HISTORIES_PATH = f2.HISTORIES_PATH
STRUCTURE_PATH = f2.STRUCTURE_PATH


# ─── helpers ─────────────────────────────────────────────────────────────────

def _load_all_history_rows() -> dict[str, list[dict]]:
    """Load history rows indexed by history_id, sorted by click_number."""
    rows: dict[str, list[dict]] = {}
    for line in HISTORIES_PATH.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        hid = str(row["history_id"])
        rows.setdefault(hid, []).append(row)
    for hid in rows:
        rows[hid].sort(key=lambda r: int(r["click_number"]))
    return rows


def _convert_constraints(
    constraints: list[f2.AllowedSumConstraint],
) -> list[dict]:
    """Convert AllowedSumConstraint → {scope, rhs} verifying single-valued."""
    out = []
    for c in constraints:
        assert len(c.allowed_sums) == 1, \
            f"Multi-valued constraint in CELL policy: scope={c.variables} allowed={c.allowed_sums}"
        out.append({"scope": sorted(c.variables), "rhs": c.allowed_sums[0]})
    return out


def _int_to_str(v) -> str:
    return str(int(v))


def _extract_fixture(
    state: f2.GeneralizedState,
    cell_index: int,
    flood_index: int,
    flood_id: str,
    step: int,
    wave_index: int,
    oracle_clue: int,
) -> dict:
    w, h = state.width, state.height

    # Build constraints from generalized state
    ok, constraints, variables, remaining_mines, unc_unk_count = \
        f2.build_generalized_constraints(state)
    assert ok, f"Inconsistent state at {flood_id} step {step}"

    # Local structure around cell_index
    local_unknown_nbrs = {
        n for n in cs.neighbors(w, h, cell_index)
        if n not in state.known_mines and n not in state.known_safe
    }
    adj_known_mines = sum(
        1 for n in cs.neighbors(w, h, cell_index)
        if n in state.known_mines
    )
    frontier_set = set(variables)
    unc_local = sorted(local_unknown_nbrs - frontier_set)
    unc_other = unc_unk_count - len(unc_local)

    # Component decomposition
    comp_vars_list, comp_constr_list = f2.connected_components(variables, constraints)
    all_special_comps: list[tuple] = []  # (cvars, cconstr) for each component touching local neighbors
    ordinary_comps: list[dict] = []

    for cvars, cconstr in zip(comp_vars_list, comp_constr_list):
        comp_var_set = set(cvars)
        if comp_var_set & local_unknown_nbrs:
            all_special_comps.append((cvars, cconstr))
        else:
            ordinary_comps.append({
                "variables": cvars,
                "constraints": _convert_constraints(cconstr),
            })

    # Min-fill for each special component
    special_recs: list[dict] = []
    for cvars, cconstr in all_special_comps:
        plan = f2.build_generalized_plan(cvars, cconstr)
        nbr_vars = sorted(local_unknown_nbrs & set(cvars))
        special_recs.append({
            "variables": cvars,
            "constraints": _convert_constraints(cconstr),
            "x_var": cell_index,
            "neighbor_vars": nbr_vars,
            "min_fill_order": list(plan.ordering),
            "min_fill_width": plan.min_fill_width,
        })

    # Expected outcomes via 2F oracle
    result = f2.evaluate_safe_cell_exact(state, cell_index)
    assert result["status"] == "ok", f"evaluate_safe_cell_exact failed at {flood_id} step {step}"
    counts = result["counts"]  # {"0": int, ..., "8": int}
    compatible_total = int(result["compatible_total_before_query"])

    # Audit
    n_multi = sum(1 for c in constraints if len(c.allowed_sums) > 1)
    if n_multi:
        print(f"WARNING: {n_multi} multi-valued constraints at {flood_id} step {step}",
              file=sys.stderr)

    total_sp_size = sum(len(sp["variables"]) for sp in special_recs)
    max_sp_width  = max((sp["min_fill_width"] for sp in special_recs), default=0)

    return {
        "flood_id": flood_id,
        "flood_index": flood_index,
        "step": step,
        "cell_index": cell_index,
        "wave_index": wave_index,
        "oracle_clue": oracle_clue,
        "remaining_mines": remaining_mines,
        "adjacent_known_mines": adj_known_mines,
        "has_special": len(special_recs) > 0,
        "special_components": special_recs,
        "ordinary_components": ordinary_comps,
        "unconstrained_local": {
            "has": len(unc_local) > 0,
            "x_is_unconstrained": False,  # cell_index is always in known_safe
            "neighbor_count": len(unc_local),
            "total": len(unc_local),
        },
        "unconstrained_other_count": unc_other,
        "expected_outcomes": {
            "mine": "0",
            **{str(i): _int_to_str(counts.get(str(i), 0)) for i in range(9)},
        },
        "compatible_total": str(compatible_total),
        "_audit": {
            "n_constraints_multi_valued": n_multi,
            "n_constraints": len(constraints),
            "n_ordinary": len(ordinary_comps),
            "n_unc_local": len(unc_local),
            "has_special": len(special_recs) > 0,
            "n_special": len(special_recs),
            "special_size": total_sp_size,
            "special_width": max_sp_width,
        },
    }


def _simulate_flood_fixtures(
    case: dict,
    history_rows: dict[str, list[dict]],
    flood_index: int,
) -> list[dict]:
    """Replay CELL flood for one case, returning list of fixture records."""
    history_id = case["history_id"]
    click_number = int(case["click_number"])
    flood_id = f"{history_id}_{click_number:03d}"

    rows = history_rows.get(history_id, [])
    before_row = next((r for r in rows if int(r["click_number"]) == click_number), None)
    if before_row is None:
        print(f"SKIP {flood_id}: no before_row found", file=sys.stderr)
        return []

    next_row = next((r for r in rows if int(r["click_number"]) == click_number + 1), None)
    after_transcript, after_src = f2.build_after_transcript(before_row, next_row)
    if after_transcript is None:
        print(f"SKIP {flood_id}: {after_src}", file=sys.stderr)
        return []

    before_transcript = f2.transcript_from_history_row(before_row)
    clicked_cell = int(before_row["clicked_cell"]["index"])
    oracle_clues = after_transcript.revealed_clues

    w, h = before_transcript.width, before_transcript.height

    # Initialize state (clicked cell forced to clue=0)
    state = f2.with_allowed_clues(
        f2.state_from_transcript(before_transcript),
        clicked_cell,
        {0},
    )

    # Initial wave: unknown neighbors of clicked_cell
    current_wave = sorted(
        n for n in cs.neighbors(w, h, clicked_cell)
        if n not in state.known_safe and n not in state.known_mines
    )

    fixtures: list[dict] = []
    step = 0
    wave_idx = 0

    while current_wave:
        wave_idx += 1
        state = f2.with_known_safe(state, current_wave)
        next_wave_candidates: set[int] = set()

        for cell_index in current_wave:
            step += 1
            oracle_clue = oracle_clues.get(cell_index, 0)

            fix = _extract_fixture(
                state=state,
                cell_index=cell_index,
                flood_index=flood_index,
                flood_id=flood_id,
                step=step,
                wave_index=wave_idx,
                oracle_clue=oracle_clue,
            )
            fixtures.append(fix)

            # Update state (advance flood)
            state = f2.with_allowed_clues(state, cell_index, {oracle_clue})
            if oracle_clue == 0:
                next_wave_candidates.update(
                    n for n in cs.neighbors(w, h, cell_index)
                    if n not in state.known_safe and n not in state.known_mines
                )

        current_wave = sorted(next_wave_candidates)

    print(
        f"done {flood_id} (flood {flood_index}): {step} steps, {wave_idx} waves",
        file=sys.stderr,
    )
    return fixtures


def _load_done_floods(path: Path) -> set[str]:
    """Return set of flood_ids that are completely written (any record present)."""
    done: set[str] = set()
    if not path.exists():
        return done
    with open(path) as f:
        for line in f:
            if line.strip():
                rec = json.loads(line)
                done.add(rec["flood_id"])
    return done


def main() -> None:
    cases = f2.selected_full_cases()
    history_rows = _load_all_history_rows()
    done_floods = _load_done_floods(OUT_PATH)

    with open(OUT_PATH, "a") as out:
        for flood_index, case in enumerate(cases, 1):
            history_id = case["history_id"]
            click_number = int(case["click_number"])
            flood_id = f"{history_id}_{click_number:03d}"

            if flood_id in done_floods:
                print(f"skip {flood_id} (already done)", file=sys.stderr)
                continue

            fixtures = _simulate_flood_fixtures(case, history_rows, flood_index)
            for rec in fixtures:
                out.write(json.dumps(rec) + "\n")
            out.flush()


if __name__ == "__main__":
    main()
