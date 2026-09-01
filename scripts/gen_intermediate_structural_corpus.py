#!/usr/bin/env python3
"""
gen_intermediate_structural_corpus.py

Corpus estructural de CELL states para Intermediate 16x16/40.
Sin evaluación oracle — sólo features estructurales (total_vars, total_constr,
max_width, componentes) equivalentes a los usados en el análisis Phase 8.

Reproducibilidad: seed + estrategia + game_click_index determinan exactamente
el estado CELL (la secuencia de clicks es determinista dado seed y estrategia).

Diseñado para encontrar estados de cola comparables a los outliers Expert
(f08, f13, f14, f15 de Phase 8).

Uso:
    python3 scripts/gen_intermediate_structural_corpus.py [--n-seeds N] [--strategy S]

Salida:
    benchmarks/intermediate-16x16-40-cells-{DATE}.jsonl  (append, resumable)
    benchmarks/intermediate-16x16-40-meta-{DATE}.json    (por seed, para debug)
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))

import conditional_sampling_exact as cs
import conditional_sampling_2f_flood_fill_refinement as f2

W, H, M = 16, 16, 40
DATE = "20260901"

OUT_CELLS  = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-cells-{DATE}.jsonl"
OUT_META   = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-meta-{DATE}.jsonl"


# ── helpers ───────────────────────────────────────────────────────────────────

def manhattan_center(idx: int) -> int:
    x, y = cs.coord_of(W, idx)
    return abs(x - W // 2) + abs(y - H // 2)


def cell_click_order(strategy: int, mines: frozenset[int]) -> list[int]:
    """Return deterministic click sequence (safe cells only) for a given strategy."""
    board_safe = set(range(W * H)) - mines

    # Starting seed for this strategy
    if strategy == 0:
        # center-first BFS
        starts = [H // 2 * W + W // 2]
    elif strategy == 1:
        # corner NW first
        starts = [0]
    elif strategy == 2:
        # corner SE first
        starts = [W * H - 1]
    elif strategy == 3:
        # corner NE first
        starts = [W - 1]
    else:
        starts = [H // 2 * W + W // 2]

    # Find nearest safe starting cell
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
        nbrs = sorted(cs.neighbors(W, H, c),
                      key=lambda n: (manhattan_center(n) if strategy == 0 else -manhattan_center(n), n))
        for n in nbrs:
            if n not in visited:
                queue.append(n)

    # Append any safe cells missed by BFS
    for c in sorted(board_safe):
        if c not in visited:
            order.append(c)

    return order


def build_initial_state(mines: frozenset[int], revealed_clues: dict[int, int]) -> f2.GeneralizedState:
    """Build GeneralizedState from current revealed cells (player view — no known_mines)."""
    allowed = {cell: {clue} for cell, clue in revealed_clues.items()}
    return f2.GeneralizedState(
        width=W,
        height=H,
        total_mines=M,
        known_mines=frozenset(),  # player doesn't know mine positions
        known_safe=frozenset(revealed_clues.keys()),
        allowed_clues=f2.canonical_allowed_map(allowed),
        label="",
    )


def extract_structural_features(
    state: f2.GeneralizedState,
    cell_index: int,
    seed: int,
    strategy: int,
    flood_id: str,
    step: int,
    wave_idx: int,
    n_known_safe_at_start: int,
    flood_click: int,
    game_click_index: int,
) -> dict | None:
    """Extract structural features for one CELL state (no oracle evaluation)."""
    try:
        ok, constraints, variables, remaining_mines, unc_unk_count = \
            f2.build_generalized_constraints(state)
    except Exception as e:
        return {"_error": str(e), "flood_id": flood_id, "step": step}

    if not ok:
        return None  # inconsistent state — skip silently

    local_unknown_nbrs = {
        n for n in cs.neighbors(W, H, cell_index)
        if n not in state.known_mines and n not in state.known_safe
    }
    adj_known_mines = sum(1 for n in cs.neighbors(W, H, cell_index) if n in state.known_mines)
    frontier_set = set(variables)
    unc_local = sorted(local_unknown_nbrs - frontier_set)
    unc_other = unc_unk_count - len(unc_local)

    comp_vars_list, comp_constr_list = f2.connected_components(variables, constraints)

    special_comps: list[dict] = []
    ordinary_comps: list[dict] = []

    for cvars, cconstr in zip(comp_vars_list, comp_constr_list):
        comp_var_set = set(cvars)
        is_special = bool(comp_var_set & local_unknown_nbrs)
        try:
            plan = f2.build_generalized_plan(cvars, cconstr)
            width = plan.min_fill_width
        except Exception:
            width = -1  # flag as failed

        entry = {
            "size": len(cvars),
            "n_constr": len(cconstr),
            "min_fill_width": width,
        }
        if is_special:
            nbr_vars = sorted(local_unknown_nbrs & comp_var_set)
            entry["n_neighbor_vars"] = len(nbr_vars)
            special_comps.append(entry)
        else:
            ordinary_comps.append(entry)

    total_vars = len(variables)
    total_constr = len(constraints)
    max_width    = max((s["min_fill_width"] for s in special_comps), default=0)
    max_sp_size  = max((s["size"]           for s in special_comps), default=0)
    max_ord_size = max((o["size"]           for o in ordinary_comps), default=0)
    sum_ord_size = sum(o["size"]            for o in ordinary_comps)

    return {
        # Reproducibility
        "seed":              seed,
        "strategy":          strategy,
        "flood_id":          flood_id,
        "game_click_index":  game_click_index,   # index of flood-trigger click in click order
        "flood_click":       flood_click,
        "step":              step,
        "wave_index":        wave_idx,
        "cell_index":        cell_index,
        "n_known_safe_at_flood_start": n_known_safe_at_start,
        # Structural features (Phase 8 predictors)
        "remaining_mines":       remaining_mines,
        "adjacent_known_mines":  adj_known_mines,
        "total_vars":            total_vars,
        "total_constr":          total_constr,
        "n_special":             len(special_comps),
        "n_ordinary":            len(ordinary_comps),
        "max_width":             max_width,
        "max_sp_size":           max_sp_size,
        "max_ord_size":          max_ord_size,
        "sum_ord_size":          sum_ord_size,
        "unconstrained_local_n": len(unc_local),
        "unconstrained_other":   unc_other,
        # Per-component detail (compact)
        "special_comps":  special_comps,
        "ordinary_comps": ordinary_comps,
    }


def simulate_flood(
    mines: frozenset[int],
    pre_flood_state: f2.GeneralizedState,
    flood_click: int,
    seed: int,
    strategy: int,
    flood_num: int,
    game_click_index: int,
    n_known_safe_at_start: int,
) -> list[dict]:
    """Run VCLS flood fill simulation and extract structural CELL features."""
    flood_id = f"s{seed:05d}g{strategy}f{flood_num:02d}"

    # Add flood click with clue=0
    state = f2.with_allowed_clues(pre_flood_state, flood_click, {0})

    current_wave = sorted(
        n for n in cs.neighbors(W, H, flood_click)
        if n not in state.known_safe and n not in state.known_mines
    )

    results: list[dict] = []
    step = 0
    wave_idx = 0

    while current_wave:
        wave_idx += 1
        state = f2.with_known_safe(state, current_wave)
        next_wave: set[int] = set()

        for cell_index in current_wave:
            step += 1
            oracle_clue = cs.clue_for_board(W, H, mines, cell_index)

            feat = extract_structural_features(
                state, cell_index, seed, strategy, flood_id, step, wave_idx,
                n_known_safe_at_start, flood_click, game_click_index,
            )
            if feat is not None and "_error" not in feat:
                results.append(feat)

            state = f2.with_allowed_clues(state, cell_index, {oracle_clue})
            if oracle_clue == 0:
                next_wave.update(
                    n for n in cs.neighbors(W, H, cell_index)
                    if n not in state.known_safe and n not in state.known_mines
                )

        current_wave = sorted(next_wave)

    return results


def simulate_game(seed: int, strategy: int, mines: frozenset[int]) -> tuple[list[dict], dict]:
    """Simulate one full game and return all CELL structs + metadata."""
    click_order = cell_click_order(strategy, mines)
    revealed_clues: dict[int, int] = {}
    flood_num = 0
    all_cells: list[dict] = []
    floods_count = 0
    t0 = time.perf_counter()

    for click_idx, click in enumerate(click_order):
        if click in revealed_clues:
            continue  # already revealed by a previous flood

        clue = cs.clue_for_board(W, H, mines, click)

        if clue > 0:
            revealed_clues[click] = clue
        else:
            # Flood fill trigger
            pre_flood_state = build_initial_state(mines, revealed_clues)
            n_known = len(revealed_clues)

            cells = simulate_flood(
                mines, pre_flood_state, click,
                seed, strategy, flood_num, click_idx, n_known,
            )
            all_cells.extend(cells)
            flood_num += 1
            floods_count += 1

            # Board-level BFS reveal (advance game state)
            newly: set[int] = set()
            cs.reveal_from_board(W, H, mines, newly, click)
            for r in newly:
                if r not in revealed_clues:
                    revealed_clues[r] = cs.clue_for_board(W, H, mines, r)

    elapsed = time.perf_counter() - t0
    meta = {
        "seed": seed,
        "strategy": strategy,
        "n_cells": len(all_cells),
        "n_floods": floods_count,
        "n_clicks": len(click_order),
        "n_final_revealed": len(revealed_clues),
        "elapsed_s": round(elapsed, 3),
    }
    return all_cells, meta


# ── main ──────────────────────────────────────────────────────────────────────

def load_done_keys(path: Path) -> set[tuple[int, int]]:
    """Return (seed, strategy) pairs already written to output."""
    done: set[tuple[int, int]] = set()
    if not path.exists():
        return done
    with open(path) as f:
        for line in f:
            if not line.strip():
                continue
            try:
                r = json.loads(line)
                done.add((r["seed"], r["strategy"]))
            except Exception:
                pass
    return done


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--n-seeds",   type=int, default=500)
    parser.add_argument("--strategies", type=str, default="0,1,2",
                        help="Comma-separated strategy ids (0=center,1=NW,2=SE)")
    parser.add_argument("--seed-start", type=int, default=0)
    args = parser.parse_args()

    strategies = [int(s) for s in args.strategies.split(",")]
    seeds = range(args.seed_start, args.seed_start + args.n_seeds)
    total_combos = len(seeds) * len(strategies)

    print(f"Intermediate {W}×{H}/{M} structural corpus", file=sys.stderr)
    print(f"Seeds: {args.seed_start}..{args.seed_start+args.n_seeds-1}  Strategies: {strategies}", file=sys.stderr)
    print(f"Total (seed,strategy) combos: {total_combos}", file=sys.stderr)
    print(f"Output: {OUT_CELLS}", file=sys.stderr)

    # Resumability: find already-written (seed, strategy) pairs from meta
    done_keys = set()
    if OUT_META.exists():
        with open(OUT_META) as f:
            for line in f:
                if line.strip():
                    try:
                        r = json.loads(line)
                        done_keys.add((r["seed"], r["strategy"]))
                    except Exception:
                        pass

    total_cells_written = 0
    combos_done = sum(1 for key in done_keys
                      if key[0] in range(args.seed_start, args.seed_start + args.n_seeds)
                      and key[1] in strategies)
    print(f"Already done: {combos_done}/{total_combos}", file=sys.stderr)

    with open(OUT_CELLS, "a") as fout, open(OUT_META, "a") as fmeta:
        for seed in seeds:
            mines = frozenset(cs.random_board(W, H, M, seed))
            for strategy in strategies:
                if (seed, strategy) in done_keys:
                    continue

                try:
                    cells, meta = simulate_game(seed, strategy, mines)
                except Exception as e:
                    print(f"  ERROR seed={seed} strategy={strategy}: {e}", file=sys.stderr)
                    continue

                for row in cells:
                    fout.write(json.dumps(row) + "\n")
                fout.flush()

                fmeta.write(json.dumps(meta) + "\n")
                fmeta.flush()

                total_cells_written += meta["n_cells"]
                done_keys.add((seed, strategy))

                if seed % 50 == 0 or meta["elapsed_s"] > 5:
                    print(f"  seed={seed:4d} strat={strategy} floods={meta['n_floods']:2d} "
                          f"cells={meta['n_cells']:4d} t={meta['elapsed_s']:.2f}s "
                          f"total_written={total_cells_written}", file=sys.stderr)

    print(f"\nDone. Total new cells written: {total_cells_written}", file=sys.stderr)
    print(f"Output: {OUT_CELLS}", file=sys.stderr)


if __name__ == "__main__":
    main()
