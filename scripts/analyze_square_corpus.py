#!/usr/bin/env python3
"""
analyze_square_corpus.py

Análisis estructural del corpus NxN generado por gen_square_corpus.py.
Parametrizado con --size N --mines M.

Genera:
  benchmarks/square-{N}x{N}-{M}-analysis-{DATE}.md
  benchmarks/square-{N}x{N}-{M}-candidates-{DATE}.jsonl

Lección de 16x16/40: el predictor primario de gas es sum_ord_size
(no max_width). Los candidatos adversariales deben incluir
todos los casos con sum_ord_size alto y max_ord_internal_width alto.

Uso:
    python3 scripts/analyze_square_corpus.py --size 15 --mines 35
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DATE = "20260901"

# Reference: Expert Phase 8 (30x16/99)
EXPERT = {
    "n_cells": 408,
    "total_vars":        {"p50": 52,  "p90": 163, "p95": 185, "max": 189},
    "total_constraints": {"p50": 32,  "p90": 90,  "p95": 104, "max": 116},
    "max_width":         {"p50": 4,   "p90": 7,   "p95": 7,   "max": 7},
    "n_ordinary":        {"p50": 4,   "p90": 7,   "p95": 7,   "max": 8},
    "unc_other":         {"p50": 376, "p90": 462, "p95": 468, "min": 113, "max": 474},
    "n_over_gate":  45,
    "pct_over_gate": 11.0,
    "max_gas_B":    6.268,
    "floods_unseg": 4,
}

# Reference: Intermediate 16x16/40 RED threshold
INTERMEDIATE_RED = {
    "sum_ord_size_red": 81,   # minimum sum_ord_size that produced >1.1B gas
    "max_gas_B": 1.591,
    "n_over_gate": 3,
}

GAS_GATE_B = 1.1


def percentile(vals: list[float], p: float) -> float:
    if not vals:
        return 0.0
    s = sorted(vals)
    idx = min(int(len(s) * p / 100), len(s) - 1)
    return s[idx]


def stats(vals: list[float]) -> dict:
    if not vals:
        return {"n": 0, "min": 0, "mean": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0, "max": 0}
    s = sorted(vals)
    n = len(s)
    return {
        "n":    n,
        "min":  s[0],
        "mean": sum(s) / n,
        "p50":  s[n // 2],
        "p90":  s[int(n * 0.90)],
        "p95":  s[int(n * 0.95)],
        "p99":  s[int(n * 0.99)],
        "max":  s[-1],
    }


def fmt_stat_row(label: str, s: dict, expert_max: float | None = None) -> str:
    expert_str = f"{expert_max:.0f}" if expert_max is not None else "—"
    return (
        f"| {label} | {s['min']:.0f} | {s['p50']:.0f} | "
        f"{s['p90']:.0f} | {s['p95']:.0f} | {s['p99']:.0f} | "
        f"{s['max']:.0f} | {expert_str} |"
    )


def build_candidates(cells: list[dict], top_k: int = 15) -> list[dict]:
    """
    Adversarial candidate selection for Cairo testing.

    Primary predictors (from 16x16/40 RED analysis):
      - sum_ord_size: direct predictor of gas (all RED cases had sum_ord_size >= 81)
      - max_ord_internal_width: width of ordinary component VE (RED cases: width=6)

    Secondary predictors (structural diversity):
      - max_width: special component VE width
      - total_vars: total frontier size
      - unconstrained_other: multiplier in extract_outcomes
      - n_ordinary: component count

    Extra: include ALL cases with sum_ord_size >= SUM_ORD_THRESHOLD (adversarial sweep).
    """
    SUM_ORD_THRESHOLD = 55  # ~68% of 16x16 RED threshold of 81

    selected: dict[str, dict] = {}

    def add(row: dict, reason: str) -> None:
        key = f"{row['seed']}_s{row['strategy']}_{row['flood_id']}_step{row['step']}"
        if key not in selected:
            selected[key] = {**row, "_reason": reason}

    predictors = [
        "sum_ord_size",
        "max_ord_internal_width",
        "max_width",
        "total_vars",
        "total_constr",
        "unconstrained_other",
        "n_ordinary",
    ]

    for pred in predictors:
        sorted_rows = sorted(
            [r for r in cells if r.get(pred) is not None],
            key=lambda r: r[pred], reverse=True,
        )
        for row in sorted_rows[:top_k]:
            add(row, pred)

    # All sum_ord_size >= threshold (sweep for potential RED)
    for row in cells:
        if row.get("sum_ord_size", 0) >= SUM_ORD_THRESHOLD:
            add(row, f"sum_ord_size>={SUM_ORD_THRESHOLD}")

    # Combined: high max_ord_internal_width AND high sum_ord_size
    combo = sorted(
        cells,
        key=lambda r: (r.get("max_ord_internal_width", 0), r.get("sum_ord_size", 0)),
        reverse=True,
    )
    for row in combo[:top_k]:
        add(row, "ord_width+ord_size")

    # Combined: high max_width AND positive n_ordinary (Expert pattern)
    combo2 = sorted(
        cells,
        key=lambda r: (r.get("max_width", 0), r.get("n_ordinary", 0), r.get("sum_ord_size", 0)),
        reverse=True,
    )
    for row in combo2[:top_k]:
        add(row, "max_width+n_ord")

    # Controls: typical high total_vars
    for row in sorted(cells, key=lambda r: r.get("total_vars", 0), reverse=True)[:5]:
        add(row, "total_vars_control")

    return list(selected.values())


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--size",    type=int, required=True)
    parser.add_argument("--mines",   type=int, default=-1)
    parser.add_argument("--run-tag", type=str, default="", help="Optional tag for replication runs (e.g. rep2)")
    args = parser.parse_args()

    N = args.size
    M = args.mines if args.mines >= 0 else math.floor(5 * N * N / 32 + 0.5)
    tag_infix = f"-{args.run_tag}" if args.run_tag else ""

    cells_path      = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-cells-{DATE}.jsonl"
    meta_path       = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-meta-{DATE}.jsonl"
    analysis_path   = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-analysis-{DATE}.md"
    candidates_path = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-candidates-{DATE}.jsonl"

    print(f"Loading corpus from {cells_path} ...", file=sys.stderr)
    cells: list[dict] = []
    with open(cells_path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    cells.append(json.loads(line))
                except Exception:
                    pass
    print(f"  {len(cells)} CELL rows", file=sys.stderr)

    if not cells:
        print("ERROR: No cells loaded.", file=sys.stderr)
        sys.exit(1)

    meta: list[dict] = []
    if meta_path.exists():
        with open(meta_path) as f:
            for line in f:
                if line.strip():
                    try:
                        meta.append(json.loads(line))
                    except Exception:
                        pass

    n_seeds    = len({(r["seed"], r["strategy"]) for r in cells})
    n_floods   = len({r["flood_id"] for r in cells})
    strategies = sorted({r["strategy"] for r in cells})

    st_total_vars   = stats([r["total_vars"]            for r in cells])
    st_total_constr = stats([r["total_constr"]          for r in cells])
    st_max_width    = stats([r["max_width"]             for r in cells])
    st_n_special    = stats([r["n_special"]             for r in cells])
    st_n_ordinary   = stats([r["n_ordinary"]            for r in cells])
    st_sum_ord_size = stats([r["sum_ord_size"]          for r in cells])
    st_max_ord_iw   = stats([r.get("max_ord_internal_width", 0) for r in cells])
    st_unc_other    = stats([r["unconstrained_other"]   for r in cells])
    st_unc_local    = stats([r["unconstrained_local_n"] for r in cells])
    st_max_sp_size  = stats([r["max_sp_size"]           for r in cells])

    width_counts: dict[int, int] = defaultdict(int)
    for r in cells:
        width_counts[r["max_width"]] += 1

    top_by_ord_iw = sorted(cells, key=lambda r: (r.get("max_ord_internal_width", 0), r.get("sum_ord_size", 0)), reverse=True)[:5]
    top_by_width  = sorted(cells, key=lambda r: r["max_width"],               reverse=True)[:5]
    top_by_vars   = sorted(cells, key=lambda r: r["total_vars"],              reverse=True)[:5]
    top_by_ord    = sorted(cells, key=lambda r: r["sum_ord_size"],            reverse=True)[:5]
    top_by_unc    = sorted(cells, key=lambda r: r["unconstrained_other"],     reverse=True)[:5]

    n_width8_plus      = sum(1 for r in cells if r["max_width"] >= 8)
    n_width7_with_ord  = sum(1 for r in cells if r["max_width"] == 7 and r["n_ordinary"] > 0)
    n_sum_ord_ge81     = sum(1 for r in cells if r.get("sum_ord_size", 0) >= 81)
    n_sum_ord_ge60     = sum(1 for r in cells if r.get("sum_ord_size", 0) >= 60)
    n_ord_iw_ge6       = sum(1 for r in cells if r.get("max_ord_internal_width", 0) >= 6)

    unc_other_max_constrained = max(
        (r["unconstrained_other"] for r in cells if r["total_vars"] > 0),
        default=0,
    )

    # Build candidates
    candidates = build_candidates(cells)
    candidates.sort(
        key=lambda r: (r.get("sum_ord_size", 0) + r.get("total_vars", 0)),
        reverse=True,
    )
    with open(candidates_path, "w") as f:
        for row in candidates:
            f.write(json.dumps(row) + "\n")
    print(f"  {len(candidates)} candidates written to {candidates_path}", file=sys.stderr)

    # Generate report
    meta_stats: dict = {}
    if meta:
        meta_stats["floods_per_game"] = stats([m["n_floods"] for m in meta])
        meta_stats["cells_per_game"]  = stats([m["n_cells"]  for m in meta])
        meta_stats["elapsed"]         = stats([m["elapsed_s"] for m in meta])

    lines: list[str] = []
    lines.append(f"# Square {N}×{N}/{M} — Structural Corpus Analysis")
    lines.append(f"\n**Fecha:** {DATE}  \n**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`")
    lines.append(f"\n**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.")
    lines.append(f"**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).")
    lines.append(f"\n## Corpus\n")
    lines.append(f"| Parámetro | Valor |")
    lines.append(f"|:----------|------:|")
    lines.append(f"| (seed,strategy) combos | {n_seeds} |")
    lines.append(f"| Floods únicos | {n_floods} |")
    lines.append(f"| CELL states totales | {len(cells)} |")
    lines.append(f"| Estrategias | {strategies} |")
    if meta:
        lines.append(f"| Media floods/partida | {meta_stats['floods_per_game']['mean']:.1f} |")
        lines.append(f"| Media cells/partida | {meta_stats['cells_per_game']['mean']:.1f} |")
        lines.append(f"| Media elapsed/partida | {meta_stats['elapsed']['mean']:.3f}s |")

    lines.append(f"\n## Distribuciones estructurales\n")
    lines.append(f"| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |")
    lines.append(f"|:------|----:|----:|----:|----:|----:|----:|:-------------|")
    lines.append(fmt_stat_row("total_vars",          st_total_vars,   EXPERT["total_vars"]["max"]))
    lines.append(fmt_stat_row("total_constr",        st_total_constr, 116))
    lines.append(fmt_stat_row("max_width",           st_max_width,    EXPERT["max_width"]["max"]))
    lines.append(fmt_stat_row("n_special",           st_n_special,    None))
    lines.append(fmt_stat_row("n_ordinary",          st_n_ordinary,   EXPERT["n_ordinary"]["max"]))
    lines.append(fmt_stat_row("max_sp_size",         st_max_sp_size,  None))
    lines.append(fmt_stat_row("sum_ord_size",        st_sum_ord_size, None))
    lines.append(fmt_stat_row("max_ord_internal_w",  st_max_ord_iw,   None))
    lines.append(fmt_stat_row("unc_other",           st_unc_other,    EXPERT["unc_other"]["max"]))
    lines.append(fmt_stat_row("unc_local_n",         st_unc_local,    None))

    lines.append(f"\n## Análisis de riesgo RED (lección 16×16/40)\n")
    lines.append(f"| Señal | Valor | Umbral RED 16×16 | Interpretación |")
    lines.append(f"|:------|------:|----------------:|:---------------|")
    lines.append(f"| sum_ord_size max | {int(st_sum_ord_size['max'])} | 81 | "
                 f"{'⚠ IGUAL O SUPERIOR' if st_sum_ord_size['max'] >= 81 else 'por debajo'} |")
    lines.append(f"| n CELLs sum_ord_size≥81 | {n_sum_ord_ge81} | >0 → sospecha | "
                 f"{'⚠ RIESGO' if n_sum_ord_ge81 > 0 else 'OK'} |")
    lines.append(f"| n CELLs sum_ord_size≥60 | {n_sum_ord_ge60} | — | cola moderada |")
    lines.append(f"| max_ord_internal_width max | {int(st_max_ord_iw['max'])} | 6 | "
                 f"{'⚠ RIESGO si sum_ord alto' if st_max_ord_iw['max'] >= 6 else 'OK'} |")
    lines.append(f"| n CELLs ord_internal_width≥6 | {n_ord_iw_ge6} | — | "
                 f"{'⚠ Investigar en Cairo' if n_ord_iw_ge6 > 0 else 'OK'} |")
    lines.append(f"| width≥8 | {n_width8_plus} | benigno (n_ord=0) | ver análisis |")
    lines.append(f"| width=7+n_ord>0 | {n_width7_with_ord} | patrón Expert | "
                 f"{'⚠ patrón UNSEG' if n_width7_with_ord > 0 else 'OK'} |")

    lines.append(f"\n## Distribución max_width\n")
    lines.append(f"| max_width | n | % |")
    lines.append(f"|----------:|--:|--:|")
    total_n = len(cells)
    for w in sorted(width_counts.keys()):
        n_w = width_counts[w]
        lines.append(f"| {w} | {n_w} | {100*n_w/total_n:.1f}% |")

    lines.append(f"\n## Top-5 por sum_ord_size (predictor primario)\n")
    lines.append(f"| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |")
    lines.append(f"|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|")
    for r in top_by_ord:
        lines.append(
            f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| **{r['sum_ord_size']}** | {r.get('max_ord_internal_width', '?')} "
            f"| {r['n_ordinary']} | {r['total_vars']} | {r['max_width']} |"
        )

    lines.append(f"\n## Top-5 por max_ord_internal_width (ancho VE ordinario)\n")
    lines.append(f"| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |")
    lines.append(f"|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|")
    for r in top_by_ord_iw:
        lines.append(
            f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| **{r.get('max_ord_internal_width', '?')}** | {r['sum_ord_size']} "
            f"| {r['total_vars']} | {r['max_width']} |"
        )

    lines.append(f"\n## Top-5 por max_width (riesgo Expert)\n")
    lines.append(f"| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |")
    lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|")
    for r in top_by_width:
        lines.append(
            f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| **{r['max_width']}** | {r['total_vars']} | {r['n_ordinary']} | {r['sum_ord_size']} |"
        )

    lines.append(f"\n## Top-5 por total_vars\n")
    lines.append(f"| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |")
    lines.append(f"|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|")
    for r in top_by_vars:
        lines.append(
            f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| **{r['total_vars']}** | {r['max_width']} | {r['n_ordinary']} | {r['sum_ord_size']} |"
        )

    lines.append(f"\n## Top-5 por unconstrained_other\n")
    lines.append(f"| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |")
    lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|")
    for r in top_by_unc:
        lines.append(
            f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| **{r['unconstrained_other']}** | {r['total_vars']} "
            f"| {r['max_width']} | {r['remaining_mines']} |"
        )

    lines.append(f"\n## Candidatos Cairo ({len(candidates)} estados)\n")
    lines.append(f"Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.")
    lines.append(f"\nTop-10 por (sum_ord_size, total_vars):\n")
    lines.append(f"| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |")
    lines.append(f"|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|")
    for i, r in enumerate(candidates[:10], 1):
        lines.append(
            f"| {i} | {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} "
            f"| {r['sum_ord_size']} | {r.get('max_ord_internal_width', '?')} "
            f"| {r['max_width']} | {r['total_vars']} | {r.get('_reason', '?')} |"
        )

    lines.append(f"\n## Comparación con 16×16/40 RED\n")
    tv_ratio = st_total_vars["max"] / EXPERT["total_vars"]["max"]
    mw_ratio = st_max_width["max"]  / EXPERT["max_width"]["max"] if EXPERT["max_width"]["max"] else 0
    uo_ratio = st_unc_other["max"]  / EXPERT["unc_other"]["max"]
    lines.append(f"| Métrica | {N}×{N}/{M} max | 16×16/40 RED max | Expert max | Ratio vs Expert |")
    lines.append(f"|:--------|---------------:|----------------:|-----------:|----------------:|")
    lines.append(f"| total_vars | {int(st_total_vars['max'])} | 86 | {EXPERT['total_vars']['max']} | {tv_ratio:.2f}× |")
    lines.append(f"| sum_ord_size | {int(st_sum_ord_size['max'])} | 86 (RED) | — | — |")
    lines.append(f"| max_ord_internal_width | {int(st_max_ord_iw['max'])} | 6 (RED) | — | — |")
    lines.append(f"| max_width | {int(st_max_width['max'])} | 8 (benigno) | {EXPERT['max_width']['max']} | {mw_ratio:.2f}× |")
    lines.append(f"| unc_other | {int(st_unc_other['max'])} | — | {EXPERT['unc_other']['max']} | {uo_ratio:.2f}× |")

    lines.append(f"\n## Artefactos\n")
    lines.append(f"| Archivo | Descripción |")
    lines.append(f"|:--------|:------------|")
    lines.append(f"| `benchmarks/square-{N}x{N}-{M}-cells-{DATE}.jsonl` | {len(cells)} CELL rows |")
    lines.append(f"| `benchmarks/square-{N}x{N}-{M}-meta-{DATE}.jsonl` | {len(meta)} game records |")
    lines.append(f"| `benchmarks/square-{N}x{N}-{M}-analysis-{DATE}.md` | Este informe |")
    lines.append(f"| `benchmarks/square-{N}x{N}-{M}-candidates-{DATE}.jsonl` | {len(candidates)} candidatos Cairo |")

    report = "\n".join(lines) + "\n"
    analysis_path.write_text(report)
    print(f"\nReport written to {analysis_path}", file=sys.stderr)
    print(f"Candidates: {len(candidates)}", file=sys.stderr)
    print(
        f"Key signals: sum_ord_size_max={int(st_sum_ord_size['max'])} "
        f"(RED threshold=81), n_ge81={n_sum_ord_ge81}, "
        f"max_ord_iw={int(st_max_ord_iw['max'])}, n_ord_iw_ge6={n_ord_iw_ge6}",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
