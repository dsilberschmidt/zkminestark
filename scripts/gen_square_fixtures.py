#!/usr/bin/env python3
"""
gen_square_fixtures.py

Genera fixtures Cairo completos (constraints + min_fill_order + oracle outcomes)
para candidatos de tableros NxN/M generados por gen_square_corpus.py.

Parametrizado con --size N --mines M.

404-safe: append + flush por cada (seed,strategy); resume via flood_index en output.

Salida: benchmarks/square-{N}x{N}-{M}-fixtures-{DATE}.jsonl
"""

from __future__ import annotations

import argparse
import json
import math
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))

import conditional_sampling_exact as cs
import conditional_sampling_2f_flood_fill_refinement as f2

DATE = "20260901"


def mines_for_size(n: int) -> int:
    return math.floor(5 * n * n / 32 + 0.5)


def manhattan_center(width: int, height: int, idx: int) -> int:
    x, y = cs.coord_of(width, idx)
    return abs(x - width // 2) + abs(y - height // 2)


def cell_click_order(width: int, height: int, strategy: int, mines: frozenset[int]) -> list[int]:
    board_safe = set(range(width * height)) - mines

    if strategy == 0:
        starts = [height // 2 * width + width // 2]
    elif strategy == 1:
        starts = [0]
    elif strategy == 2:
        starts = [width * height - 1]
    else:
        starts = [height // 2 * width + width // 2]

    safe_starts = []
    for s in starts:
        if s in board_safe:
            safe_starts.append(s)
        else:
            nearest = min(board_safe, key=lambda c: abs(c - s))
            safe_starts.append(nearest)

    visited: set[int] = set()
    order: list[int] = []
    queue: list[int] = [safe_starts[0]]

    while queue:
        c = queue.pop(0)
        if c in visited:
            continue
        visited.add(c)
        if c in board_safe:
            order.append(c)
        nbrs = sorted(
            cs.neighbors(width, height, c),
            key=lambda n: (manhattan_center(width, height, n) if strategy == 0
                           else -manhattan_center(width, height, n), n),
        )
        for n in nbrs:
            if n not in visited:
                queue.append(n)

    for c in sorted(board_safe):
        if c not in visited:
            order.append(c)

    return order


def build_initial_state(
    width: int, height: int, total_mines: int,
    mines: frozenset[int], revealed_clues: dict[int, int],
) -> f2.GeneralizedState:
    allowed = {cell: {clue} for cell, clue in revealed_clues.items()}
    return f2.GeneralizedState(
        width=width,
        height=height,
        total_mines=total_mines,
        known_mines=frozenset(),
        known_safe=frozenset(revealed_clues.keys()),
        allowed_clues=f2.canonical_allowed_map(allowed),
        label="",
    )


def _convert_constraints(constraints) -> list[dict]:
    out = []
    for c in constraints:
        assert len(c.allowed_sums) == 1, \
            f"Multi-valued constraint scope={list(c.variables)} allowed={list(c.allowed_sums)}"
        out.append({"scope": sorted(c.variables), "rhs": c.allowed_sums[0]})
    return out


def extract_full_fixture(
    state: f2.GeneralizedState,
    cell_index: int,
    width: int,
    height: int,
    mines: frozenset,
    flood_id: str,
    fixture_index: int,
    step: int,
    wave_index: int,
) -> dict:
    ok, constraints, variables, remaining_mines, unc_unk_count = \
        f2.build_generalized_constraints(state)
    assert ok, f"Inconsistent state at {flood_id} step {step}"

    local_unknown_nbrs = {
        n for n in cs.neighbors(width, height, cell_index)
        if n not in state.known_mines and n not in state.known_safe
    }
    adj_known_mines = sum(
        1 for n in cs.neighbors(width, height, cell_index) if n in state.known_mines
    )
    frontier_set = set(variables)
    unc_local = sorted(local_unknown_nbrs - frontier_set)
    unc_other = unc_unk_count - len(unc_local)

    comp_vars_list, comp_constr_list = f2.connected_components(variables, constraints)

    special_recs: list[dict] = []
    ordinary_comps: list[dict] = []

    for cvars, cconstr in zip(comp_vars_list, comp_constr_list):
        if set(cvars) & local_unknown_nbrs:
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
        else:
            ordinary_comps.append({
                "variables": cvars,
                "constraints": _convert_constraints(cconstr),
            })

    result = f2.evaluate_safe_cell_exact(state, cell_index)
    assert result["status"] == "ok", \
        f"evaluate_safe_cell_exact failed at {flood_id} step {step}: {result.get('reason','')}"
    counts = result["counts"]
    compatible_total = int(result["compatible_total_before_query"])

    oracle_clue = cs.clue_for_board(width, height, mines, cell_index)

    return {
        "flood_id": flood_id,
        "flood_index": fixture_index,
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
            "x_is_unconstrained": False,
            "neighbor_count": len(unc_local),
            "total": len(unc_local),
        },
        "unconstrained_other_count": unc_other,
        "expected_outcomes": {
            "mine": "0",
            **{str(i): str(int(counts.get(str(i), 0))) for i in range(9)},
        },
        "compatible_total": str(compatible_total),
        "_audit": {
            "n_constraints": len(constraints),
            "n_ordinary": len(ordinary_comps),
            "n_unc_local": len(unc_local),
            "n_special": len(special_recs),
        },
    }


def simulate_flood_for_targets(
    width: int,
    height: int,
    mines: frozenset,
    pre_state: f2.GeneralizedState,
    flood_click: int,
    flood_id: str,
    step_targets: dict,
) -> list[tuple[int, dict]]:
    state = f2.with_allowed_clues(pre_state, flood_click, {0})
    current_wave = sorted(
        n for n in cs.neighbors(width, height, flood_click)
        if n not in state.known_safe and n not in state.known_mines
    )

    results: list[tuple[int, dict]] = []
    step = 0
    wave_idx = 0
    remaining_targets = set(step_targets.keys())

    while current_wave and remaining_targets:
        wave_idx += 1
        state = f2.with_known_safe(state, current_wave)
        next_wave: set[int] = set()

        for cell_index in current_wave:
            step += 1

            if step in remaining_targets:
                target = step_targets[step]
                assert target["cell_index"] == cell_index, (
                    f"Cell mismatch at {flood_id} step {step}: "
                    f"expected {target['cell_index']} got {cell_index}"
                )
                t0 = time.perf_counter()
                fix = extract_full_fixture(
                    state, cell_index, width, height, mines, flood_id,
                    target["fixture_index"], step, wave_idx,
                )
                elapsed = time.perf_counter() - t0
                results.append((target["fixture_index"], fix))
                remaining_targets.discard(step)
                print(
                    f"  ok {flood_id} step={step} cell={cell_index} "
                    f"idx={target['fixture_index']} t={elapsed:.2f}s",
                    file=sys.stderr,
                )

            oracle_clue = cs.clue_for_board(width, height, mines, cell_index)
            state = f2.with_allowed_clues(state, cell_index, {oracle_clue})
            if oracle_clue == 0:
                next_wave.update(
                    n for n in cs.neighbors(width, height, cell_index)
                    if n not in state.known_safe and n not in state.known_mines
                )

        current_wave = sorted(next_wave)

    if remaining_targets:
        print(
            f"  WARNING: {len(remaining_targets)} targets not found in {flood_id}: "
            f"{remaining_targets}",
            file=sys.stderr,
        )

    return results


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--size",    type=int, required=True)
    parser.add_argument("--mines",   type=int, default=-1)
    parser.add_argument("--run-tag", type=str, default="", help="Optional tag for replication runs")
    args = parser.parse_args()

    N = args.size
    M = args.mines if args.mines >= 0 else mines_for_size(N)
    W = H = N
    tag_infix = f"-{args.run_tag}" if args.run_tag else ""

    candidates_path = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-candidates-{DATE}.jsonl"
    out_path        = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-fixtures-{DATE}.jsonl"

    candidates: list[dict] = []
    with open(candidates_path) as f:
        for i, line in enumerate(f):
            if line.strip():
                cand = json.loads(line)
                cand["_fixture_index"] = i
                candidates.append(cand)
    print(f"Loaded {len(candidates)} candidates from {candidates_path}", file=sys.stderr)

    done_indices: set[int] = set()
    if out_path.exists():
        with open(out_path) as f:
            for line in f:
                if line.strip():
                    rec = json.loads(line)
                    done_indices.add(rec["flood_index"])
    print(f"Already done: {len(done_indices)} fixtures", file=sys.stderr)

    todo = [c for c in candidates if c["_fixture_index"] not in done_indices]
    if not todo:
        print("All fixtures already generated.", file=sys.stderr)
        return
    print(f"Remaining: {len(todo)} fixtures to generate", file=sys.stderr)

    by_game: dict[tuple, list] = {}
    for cand in todo:
        key = (cand["seed"], cand["strategy"])
        by_game.setdefault(key, []).append(cand)

    with open(out_path, "a") as out:
        for (seed, strategy), game_cands in sorted(by_game.items()):
            print(
                f"\nProcessing seed={seed} strategy={strategy} "
                f"({len(game_cands)} fixtures needed)...",
                file=sys.stderr,
            )

            mines = frozenset(cs.random_board(W, H, M, seed))
            click_order = cell_click_order(W, H, strategy, mines)

            flood_map: dict[tuple, dict] = {}
            for cand in game_cands:
                key2 = (cand["game_click_index"], cand["flood_click"])
                step_map = flood_map.setdefault(key2, {})
                step_map[cand["step"]] = {
                    "cell_index":    cand["cell_index"],
                    "wave_index":    cand["wave_index"],
                    "fixture_index": cand["_fixture_index"],
                }

            revealed_clues: dict[int, int] = {}
            flood_num = 0
            all_results: list[tuple[int, dict]] = []

            for click_idx, click in enumerate(click_order):
                if click in revealed_clues:
                    continue

                clue = cs.clue_for_board(W, H, mines, click)

                if clue > 0:
                    revealed_clues[click] = clue
                else:
                    fkey = (click_idx, click)
                    flood_id = f"s{seed:05d}g{strategy}f{flood_num:02d}"

                    if fkey in flood_map:
                        pre_state = build_initial_state(W, H, M, mines, revealed_clues)
                        results = simulate_flood_for_targets(
                            W, H, mines, pre_state, click, flood_id, flood_map[fkey]
                        )
                        all_results.extend(results)

                    flood_num += 1

                    newly: set[int] = set()
                    cs.reveal_from_board(W, H, mines, newly, click)
                    for r in newly:
                        if r not in revealed_clues:
                            revealed_clues[r] = cs.clue_for_board(W, H, mines, r)

            all_results.sort(key=lambda x: x[0])
            for _, fix in all_results:
                out.write(json.dumps(fix) + "\n")
            out.flush()
            print(
                f"  Wrote {len(all_results)} fixtures for seed={seed} strategy={strategy}",
                file=sys.stderr,
            )

    count = 0
    if out_path.exists():
        with open(out_path) as f:
            count = sum(1 for line in f if line.strip())
    print(f"\nTotal fixtures in {out_path}: {count}", file=sys.stderr)


if __name__ == "__main__":
    main()
