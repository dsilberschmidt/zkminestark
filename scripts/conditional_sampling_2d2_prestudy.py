#!/usr/bin/env python3
"""
PRESTUDY 2D2 — carry-forward feasibility analysis.

Classifies every special-component transition across the 3 smoke histories:
  A: DIRECTLY_CONDITIONABLE
  B: SPLIT
  C: MERGE
  D: DISAPPEARED / FULLY_RESOLVED
  E: ALREADY_REUSABLE (2D1 exact-signature match)
  F: OTHER (merge+split, or uncategorised)

Then quantifies the upper-bound savings if A-cases could be carry-forwarded.
Does NOT modify any existing code.
"""

from __future__ import annotations

import sys
import json
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "scripts"))

import conditional_sampling_exact as cs
import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2d_incremental as inc
import conditional_sampling_history_smoke as hs

BOARD_WIDTH = hs.BOARD_WIDTH
BOARD_HEIGHT = hs.BOARD_HEIGHT
TOTAL_MINES = hs.TOTAL_MINES


# ---------------------------------------------------------------------------
# Core classification helpers
# ---------------------------------------------------------------------------

def classify_special_fate(
    comp_var_set: set[int],
    clicked_cell: int,
    state_next: inc.IncrementalState | None,
) -> tuple[str, int, list[int], set[int]]:
    """
    Return (classification, n_touching_next, next_sizes, extra_vars).

    extra_vars = variables in touching next-components that were NOT in this
                 component (i.e., variables that merged in from somewhere else).
    """
    if state_next is None:
        return "TERMINAL", 0, [], set()

    remaining = comp_var_set - {clicked_cell}  # x_i gets revealed
    next_frontier = set(state_next.variables)
    remaining_in_frontier = remaining & next_frontier

    if not remaining_in_frontier:
        return "D_DISAPPEARED", 0, [], set()

    touching_components: list[int] = []
    for c_idx, cvars in enumerate(state_next.component_variables):
        if set(cvars) & remaining_in_frontier:
            touching_components.append(c_idx)

    if not touching_components:
        return "D_DISAPPEARED", 0, [], set()

    all_touching_vars: set[int] = set()
    for c_idx in touching_components:
        all_touching_vars |= set(state_next.component_variables[c_idx])
    extra_vars = all_touching_vars - remaining_in_frontier

    next_sizes = [len(state_next.component_variables[c]) for c in touching_components]

    # Check if 2D1 already reuses all touching components via exact signature
    all_reused = all(
        state_next.components[c_idx].profile_source == "reused"
        for c_idx in touching_components
    )
    if all_reused:
        return "E_ALREADY_REUSABLE", len(touching_components), next_sizes, extra_vars

    n = len(touching_components)
    if n == 1 and not extra_vars:
        return "A_DIRECTLY_CONDITIONABLE", 1, next_sizes, extra_vars
    if n == 1 and extra_vars:
        return "C_MERGE", 1, next_sizes, extra_vars
    if n > 1 and not extra_vars:
        return "B_SPLIT", n, next_sizes, extra_vars
    # n > 1 AND extra_vars
    return "F_MERGE_SPLIT", n, next_sizes, extra_vars


def run_joint_for_component(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    clicked_cell: int,
    local_neighbors: set[int],
) -> b3.JointComponentProfile:
    comp_var_set = set(component_vars)
    return b3.count_component_joint(
        component_vars=component_vars,
        component_constraints=component_constraints,
        x_var=clicked_cell if clicked_cell in comp_var_set else None,
        neighbor_vars=local_neighbors.intersection(comp_var_set),
    )


# ---------------------------------------------------------------------------
# Per-history analysis
# ---------------------------------------------------------------------------

def analyze_history(policy: hs.HistoryPolicy) -> list[dict]:
    history = hs.generate_history(policy)
    records: list[dict] = []

    # Build state chain (2D1 mode)
    states: list[inc.IncrementalState] = []
    first_row = history[0]
    first_transcript = b3.transcript_from_corpus_row({"transcript": first_row["transcript"]})
    s0 = inc.build_state(first_transcript, previous_state=None, mode="2D1")
    states.append(s0)
    for row in history[1:]:
        t = b3.transcript_from_corpus_row({"transcript": row["transcript"]})
        s_next = inc.build_state(t, previous_state=states[-1], mode="2D1")
        states.append(s_next)

    # Pre-compute per-step next_clicked_cell (for "next click in same region" check)
    next_clicked: list[int | None] = [
        int(history[i + 1]["clicked_cell"]["index"]) if i + 1 < len(history) else None
        for i in range(len(history))
    ]

    for i, (row, state_i) in enumerate(zip(history, states)):
        transcript_i = state_i.transcript
        clicked_cell = int(row["clicked_cell"]["index"])
        real_outcome = str(row["real_outcome"])
        phase = str(row["phase"])
        click_number = int(row["click_number"])
        state_next = states[i + 1] if i + 1 < len(states) else None

        local_hidden, local_neighbors, adjacent_known_mines = b3.local_hidden_sets(
            transcript_i, clicked_cell
        )

        for comp_idx, (component_vars, component_constraints) in enumerate(
            zip(state_i.component_variables, state_i.component_constraints)
        ):
            comp_var_set = set(component_vars)
            if not comp_var_set.intersection(local_hidden):
                continue  # Not special

            x_in_comp = clicked_cell in comp_var_set
            comp_size = len(component_vars)
            cached = state_i.components[comp_idx]
            profile_source = cached.profile_source

            # Joint DFS cost for this specific component at this step
            jp = run_joint_for_component(
                list(component_vars), list(component_constraints),
                clicked_cell, local_neighbors
            )
            special_nodes = jp.search_nodes
            special_branch_ops = jp.branch_ops

            # Is carry-forward mathematically possible for this component?
            effective_clue: int | None = None
            conditioning_ok = False
            if real_outcome != cs.MINE_OUTCOME and x_in_comp:
                j = int(real_outcome)
                effective_clue = j - adjacent_known_mines
                conditioning_ok = 0 <= effective_clue <= 8

            # Ways derivable via conditioning (for A-cases only)
            conditioned_ways: dict[int, int] = {}  # k' -> ways[k', 0, m_eff]
            if conditioning_ok and jp.joint_counts:
                m_eff = effective_clue
                for (k_total, x_mine, n_mine), ways in jp.joint_counts.items():
                    if x_mine == 0 and n_mine == m_eff:
                        conditioned_ways[k_total] = conditioned_ways.get(k_total, 0) + ways

            # Classify the fate
            classification, n_touching, next_sizes, extra_vars = classify_special_fate(
                comp_var_set, clicked_cell, state_next
            )

            # Is the next click inside this component's region?
            next_click = next_clicked[i]
            next_in_region: bool | None = None
            if next_click is not None:
                next_in_region = next_click in comp_var_set or any(
                    next_click in set(state_next.component_variables[c])
                    for c in range(len(state_next.component_variables))
                    if set(state_next.component_variables[c]) & (comp_var_set - {clicked_cell})
                ) if state_next else False

            # If next click touches the same region, will it be special or ordinary?
            next_click_role: str | None = None
            if next_click is not None and state_next is not None and next_in_region:
                # Check if the next-step's component containing these vars is special for next_click
                nl_h, nl_n, _ = b3.local_hidden_sets(state_next.transcript, next_click)
                for cvars_next in state_next.component_variables:
                    if set(cvars_next) & (comp_var_set - {clicked_cell}):
                        if set(cvars_next) & nl_h:
                            next_click_role = "special"
                        else:
                            next_click_role = "ordinary"
                        break

            records.append({
                "history_id": policy.history_id,
                "click_number": click_number,
                "phase": phase,
                "real_outcome": real_outcome,
                "comp_size": comp_size,
                "x_in_comp": x_in_comp,
                "profile_source": profile_source,
                "special_nodes": special_nodes,
                "special_branch_ops": special_branch_ops,
                "effective_clue": effective_clue,
                "conditioning_ok": conditioning_ok,
                "conditioned_ways_count": len(conditioned_ways),
                "classification": classification,
                "n_next_components": n_touching,
                "next_comp_sizes": next_sizes,
                "next_in_region": next_in_region,
                "next_click_role": next_click_role,
            })

    return records


# ---------------------------------------------------------------------------
# Aggregate statistics
# ---------------------------------------------------------------------------

CATEGORIES = ["A_DIRECTLY_CONDITIONABLE", "B_SPLIT", "C_MERGE",
              "D_DISAPPEARED", "E_ALREADY_REUSABLE", "F_MERGE_SPLIT", "TERMINAL"]
CATEGORY_SHORT = {
    "A_DIRECTLY_CONDITIONABLE": "A",
    "B_SPLIT": "B",
    "C_MERGE": "C",
    "D_DISAPPEARED": "D",
    "E_ALREADY_REUSABLE": "E",
    "F_MERGE_SPLIT": "F",
    "TERMINAL": "T",
}


def aggregate(records: list[dict]) -> dict:
    by_history: dict[str, list[dict]] = defaultdict(list)
    for r in records:
        by_history[r["history_id"]].append(r)

    results: dict = {}
    total_special = 0
    total_special_nodes = 0
    total_a_nodes = 0
    total_a_count = 0
    total_a_next_ordinary = 0
    total_a_next_special = 0

    for hid in sorted(by_history):
        recs = by_history[hid]
        n = len(recs)
        total_special += n
        category_counts = defaultdict(int)
        category_nodes = defaultdict(int)
        for r in recs:
            cat = r["classification"]
            category_counts[cat] += 1
            category_nodes[cat] += r["special_nodes"]
            total_special_nodes += r["special_nodes"]

        # A-case details
        a_recs = [r for r in recs if r["classification"] == "A_DIRECTLY_CONDITIONABLE"]
        a_conditioning_ok = sum(1 for r in a_recs if r["conditioning_ok"])
        a_nodes = sum(r["special_nodes"] for r in a_recs)
        a_next_ordinary = sum(1 for r in a_recs if r["next_click_role"] == "ordinary")
        a_next_special = sum(1 for r in a_recs if r["next_click_role"] == "special")
        a_next_none = sum(1 for r in a_recs if r["next_click_role"] is None)

        total_a_nodes += a_nodes
        total_a_count += len(a_recs)
        total_a_next_ordinary += a_next_ordinary
        total_a_next_special += a_next_special

        # Upper bound: if ALL A-cases with conditioning_ok could be skipped
        # The 2D1 cost for this history = sum of all special_nodes
        # (since transition_nodes=0 in 2D1; all DFS is at eval time)
        h_nodes = sum(r["special_nodes"] for r in recs)
        a_saveable = sum(r["special_nodes"] for r in a_recs if r["conditioning_ok"])

        results[hid] = {
            "n_special_component_evals": n,
            "total_special_nodes": sum(r["special_nodes"] for r in recs),
            "by_category": {CATEGORY_SHORT[c]: category_counts[c] for c in CATEGORIES if category_counts[c]},
            "nodes_by_category": {CATEGORY_SHORT[c]: category_nodes[c] for c in CATEGORIES if category_nodes[c]},
            "A_total": len(a_recs),
            "A_conditioning_ok": a_conditioning_ok,
            "A_nodes": a_nodes,
            "A_saveable_nodes": a_saveable,
            "A_next_ordinary": a_next_ordinary,
            "A_next_special": a_next_special,
            "A_next_none": a_next_none,
            "upper_bound_savings_pct": 100.0 * a_saveable / h_nodes if h_nodes else 0.0,
        }

    results["__total__"] = {
        "total_special_component_evals": total_special,
        "total_special_nodes": total_special_nodes,
        "A_total": total_a_count,
        "A_saveable_nodes": total_a_nodes,
        "A_next_ordinary": total_a_next_ordinary,
        "A_next_special": total_a_next_special,
    }
    return results


# ---------------------------------------------------------------------------
# Detailed per-record table
# ---------------------------------------------------------------------------

def print_detail(records: list[dict]):
    print(f"\n{'HID':3} {'#':3} {'phase':5} {'out':4} {'sz':3} "
          f"{'x':1} {'src':20} {'nodes':6} {'cat':27} {'n_nxt':5} "
          f"{'cond':4} {'nxt_role':9}")
    print("-" * 110)
    for r in records:
        src = r["profile_source"]
        print(
            f"{r['history_id']:3} {r['click_number']:3} {r['phase']:5} "
            f"{r['real_outcome']:4} {r['comp_size']:3} "
            f"{'Y' if r['x_in_comp'] else 'N':1} {src:20} "
            f"{r['special_nodes']:6} {r['classification']:27} "
            f"{r['n_next_components']:5} "
            f"{'Y' if r['conditioning_ok'] else 'N':4} "
            f"{str(r['next_click_role'] or ''):9}"
        )


def print_summary(agg: dict):
    print("\n" + "=" * 60)
    print("PER-HISTORY AGGREGATE")
    print("=" * 60)
    for hid in sorted(k for k in agg if not k.startswith("__")):
        h = agg[hid]
        print(f"\n{hid}")
        print(f"  special-component evals: {h['n_special_component_evals']}")
        print(f"  total special DFS nodes: {h['total_special_nodes']}")
        print(f"  category counts: {h['by_category']}")
        print(f"  category nodes:  {h['nodes_by_category']}")
        print(f"  A cases: {h['A_total']} (conditioning_ok={h['A_conditioning_ok']})")
        print(f"    A nodes: {h['A_nodes']}, saveable: {h['A_saveable_nodes']}")
        print(f"    A next-click: ordinary={h['A_next_ordinary']} special={h['A_next_special']} none/terminal={h['A_next_none']}")
        print(f"  upper-bound savings (A conditionable / total): {h['upper_bound_savings_pct']:.1f}%")

    t = agg["__total__"]
    print(f"\nTOTAL across all histories:")
    print(f"  special-component evals: {t['total_special_component_evals']}")
    print(f"  total special DFS nodes: {t['total_special_nodes']}")
    print(f"  A_total: {t['A_total']}, A_saveable_nodes: {t['A_saveable_nodes']}")
    print(f"  A_next_ordinary: {t['A_next_ordinary']}, A_next_special: {t['A_next_special']}")
    pct = 100.0 * t['A_saveable_nodes'] / t['total_special_nodes'] if t['total_special_nodes'] else 0.0
    print(f"  theoretical max savings from simple conditioning: {pct:.1f}% of special DFS nodes")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    all_records: list[dict] = []
    for policy in hs.HISTORY_POLICIES:
        print(f"Analyzing {policy.history_id} ({policy.policy_name})...", flush=True)
        recs = analyze_history(policy)
        all_records.extend(recs)
        print(f"  {len(recs)} special-component evals found")

    print_detail(all_records)
    agg = aggregate(all_records)
    print_summary(agg)

    # Save raw classification for further inspection
    out_path = Path(__file__).parent / "prestudy_2d2_records.json"
    out_path.write_text(json.dumps(all_records, indent=2, default=str))
    print(f"\nRaw records saved to {out_path}")
