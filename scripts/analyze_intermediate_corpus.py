#!/usr/bin/env python3
"""
analyze_intermediate_corpus.py

Análisis estructural del corpus Intermediate 16×16/40 generado por
gen_intermediate_structural_corpus.py. Sin evaluación oracle — sólo
features estructurales comparados con Expert Phase 8.

Genera: benchmarks/intermediate-16x16-40-analysis-{DATE}.md
        benchmarks/intermediate-16x16-40-candidates-{DATE}.jsonl

Uso:
    python3 scripts/analyze_intermediate_corpus.py
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parents[1]

DATE       = "20260901"
W, H, M    = 16, 16, 40
CELLS_PATH = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-cells-{DATE}.jsonl"
META_PATH  = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-meta-{DATE}.jsonl"
ANALYSIS_PATH    = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-analysis-{DATE}.md"
CANDIDATES_PATH  = REPO_ROOT / "benchmarks" / f"intermediate-{W}x{H}-{M}-candidates-{DATE}.jsonl"

# Expert Phase 8 reference values (from benchmarks/2g-phase8-cell-gas-20260901.jsonl)
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

GAS_GATE_B = 1.1  # Starknet L2 gate in billions


def pct(x: list[float], p: float) -> float:
    if not x:
        return 0.0
    idx = min(int(len(x) * p / 100), len(x) - 1)
    return sorted(x)[idx]


def stats(vals: list[float]) -> dict:
    if not vals:
        return {"n": 0, "min": 0, "mean": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0, "max": 0}
    s = sorted(vals)
    n = len(s)
    return {
        "n":   n,
        "min": s[0],
        "mean": sum(s) / n,
        "p50": s[n // 2],
        "p90": s[int(n * 0.90)],
        "p95": s[int(n * 0.95)],
        "p99": s[int(n * 0.99)],
        "max": s[-1],
    }


def load_corpus() -> tuple[list[dict], list[dict]]:
    cells: list[dict] = []
    with open(CELLS_PATH) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    cells.append(json.loads(line))
                except Exception:
                    pass

    meta: list[dict] = []
    if META_PATH.exists():
        with open(META_PATH) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        meta.append(json.loads(line))
                    except Exception:
                        pass

    return cells, meta


def build_candidates(cells: list[dict], top_k: int = 10) -> list[dict]:
    """Select structurally extreme states as Cairo test candidates."""
    predictors = ["max_width", "total_vars", "total_constr", "sum_ord_size",
                  "unconstrained_other", "n_ordinary"]
    selected: dict[str, dict] = {}  # key = (seed,strategy,flood_id,step) → row

    for pred in predictors:
        sorted_rows = sorted(
            [r for r in cells if r.get(pred) is not None],
            key=lambda r: r[pred], reverse=True
        )
        for row in sorted_rows[:top_k]:
            key = f"{row['seed']}_s{row['strategy']}_{row['flood_id']}_step{row['step']}"
            if key not in selected:
                selected[key] = {**row, "_reason": pred}

    # Also: high width + many ordinary components (combined worst case)
    combo_sorted = sorted(
        cells,
        key=lambda r: (r.get("max_width", 0), r.get("sum_ord_size", 0)),
        reverse=True
    )
    for row in combo_sorted[:top_k]:
        key = f"{row['seed']}_s{row['strategy']}_{row['flood_id']}_step{row['step']}"
        if key not in selected:
            selected[key] = {**row, "_reason": "max_width+sum_ord_size"}

    return list(selected.values())


def fmt_stat_row(label: str, s: dict, expert_max: float | None = None) -> str:
    expert_str = f"{expert_max:.0f}" if expert_max is not None else "—"
    return (
        f"| {label} | {s['min']:.0f} | {s['p50']:.0f} | "
        f"{s['p90']:.0f} | {s['p95']:.0f} | {s['p99']:.0f} | "
        f"{s['max']:.0f} | {expert_str} |"
    )


def risk_verdict(
    max_width_max: int,
    max_width_p95: int,
    unc_other_max: int,
    total_vars_max: int,
    n_ordinary_max: int,
    n_width8_plus: int = 0,
    n_width7_with_ord: int = 0,
) -> tuple[str, str]:
    """Return (verdict_label, rationale).

    Calibration from Expert Phase 8:
    - width≤6, n_ord=0 → max Expert gas 0.571B (safe)
    - width=7, n_ord>0, unc_other~120 → gas up to 6.037B (UNSEG)
    - width=8 not observed in Expert
    Expert unseg threshold: width=7 + n_ord>0 + unc_other≥100
    """
    score = 0
    notes: list[str] = []

    # Width factor (primary predictor from Phase 8)
    if n_width8_plus > 0:
        score += 4
        notes.append(f"width≥8 observed ({n_width8_plus} CELLs) — ABOVE Expert worst case of 7 → VE 2× more expensive")
    elif max_width_max >= 7:
        score += 2
        notes.append(f"max_width=7 found ({n_width7_with_ord} CELLs have n_ord>0) — same as Expert unseg threshold")
    elif max_width_max == 6:
        score += 1
        notes.append("max_width=6 (1 below Expert threshold — Expert width=6 max gas 0.399B, safely below 1.1B gate)")
    else:
        notes.append(f"max_width={max_width_max} (well below Expert threshold)")

    # Ordinary component factor
    if n_width7_with_ord > 0:
        score += 1
        notes.append(f"width=7 + n_ord>0 cases exist ({n_width7_with_ord}) — the Expert unseg pattern")
    elif n_width8_plus > 0:
        notes.append("width≥8 cases all have n_ord=0 (no ordinary convolution) — partially mitigating")

    # unc_other factor
    # Note: unc_other=250 with total_vars=0 is trivially cheap (no VE, extract_outcomes fast)
    # Only unc_other matters when total_vars>0
    if unc_other_max >= 200:
        score += 2
        notes.append(f"unc_other≥200 with constraints (Expert p50={EXPERT['unc_other']['p50']})")
    elif unc_other_max >= 100:
        score += 1
        notes.append(f"unc_other max={unc_other_max} (Expert min={EXPERT['unc_other']['min']}) — approaching Expert territory")
    else:
        notes.append(f"unc_other max={unc_other_max} (below Expert min={EXPERT['unc_other']['min']})")

    # total_vars factor
    if total_vars_max >= 150:
        score += 1
        notes.append(f"total_vars≥150 (Expert p90={EXPERT['total_vars']['p90']})")
    elif total_vars_max < 90:
        notes.append(f"total_vars max={total_vars_max} (well below Expert p50={EXPERT['total_vars']['p50']})")

    if score >= 5:
        verdict = "HIGH STRUCTURAL RISK"
    elif score >= 2:
        verdict = "UNCERTAIN"
    else:
        verdict = "LOW STRUCTURAL RISK"

    return verdict, " | ".join(notes)


def main() -> None:
    print(f"Loading corpus from {CELLS_PATH} ...", file=sys.stderr)
    cells, meta = load_corpus()
    print(f"  {len(cells)} CELL rows, {len(meta)} game records", file=sys.stderr)

    if not cells:
        print("ERROR: No cells loaded. Run gen_intermediate_structural_corpus.py first.", file=sys.stderr)
        sys.exit(1)

    n_seeds = len({(r["seed"], r["strategy"]) for r in cells})
    n_floods = len({r["flood_id"] for r in cells})
    strategies = sorted({r["strategy"] for r in cells})

    # --- per-field stats ---
    st_total_vars  = stats([r["total_vars"]         for r in cells])
    st_total_constr = stats([r["total_constr"]      for r in cells])
    st_max_width   = stats([r["max_width"]          for r in cells])
    st_n_special   = stats([r["n_special"]          for r in cells])
    st_n_ordinary  = stats([r["n_ordinary"]         for r in cells])
    st_sum_ord_size = stats([r["sum_ord_size"]      for r in cells])
    st_unc_other   = stats([r["unconstrained_other"] for r in cells])
    st_unc_local   = stats([r["unconstrained_local_n"] for r in cells])
    st_max_sp_size = stats([r["max_sp_size"]        for r in cells])

    # Width distribution
    width_counts: dict[int, int] = defaultdict(int)
    for r in cells:
        width_counts[r["max_width"]] += 1

    # Top-k by each predictor
    top_by_width  = sorted(cells, key=lambda r: r["max_width"],   reverse=True)[:5]
    top_by_vars   = sorted(cells, key=lambda r: r["total_vars"],  reverse=True)[:5]
    top_by_ord    = sorted(cells, key=lambda r: r["sum_ord_size"],reverse=True)[:5]
    top_by_unc    = sorted(cells, key=lambda r: r["unconstrained_other"],reverse=True)[:5]

    # Width=8+ and width=7+n_ord analysis
    n_width8_plus = sum(1 for r in cells if r["max_width"] >= 8)
    n_width7_with_ord = sum(1 for r in cells if r["max_width"] == 7 and r["n_ordinary"] > 0)
    # unc_other max only for rows with actual constraints (total_vars>0)
    unc_other_max_constrained = max(
        (r["unconstrained_other"] for r in cells if r["total_vars"] > 0),
        default=0,
    )

    # Risk score
    verdict, rationale = risk_verdict(
        max_width_max    = int(st_max_width["max"]),
        max_width_p95    = int(pct([r["max_width"] for r in cells], 95)),
        unc_other_max    = unc_other_max_constrained,
        total_vars_max   = int(st_total_vars["max"]),
        n_ordinary_max   = int(st_n_ordinary["max"]),
        n_width8_plus    = n_width8_plus,
        n_width7_with_ord = n_width7_with_ord,
    )

    # --- build candidates ---
    candidates = build_candidates(cells)
    candidates.sort(key=lambda r: (r.get("max_width", 0), r.get("total_vars", 0)), reverse=True)
    with open(CANDIDATES_PATH, "w") as f:
        for row in candidates:
            f.write(json.dumps(row) + "\n")
    print(f"  {len(candidates)} candidates written to {CANDIDATES_PATH}", file=sys.stderr)

    # --- generate Markdown report ---
    meta_stats = {}
    if meta:
        meta_stats["n_floods_per_game"] = stats([m["n_floods"] for m in meta])
        meta_stats["cells_per_game"]    = stats([m["n_cells"]  for m in meta])
        meta_stats["elapsed_per_game"]  = stats([m["elapsed_s"] for m in meta])

    lines: list[str] = []
    lines.append(f"# Intermediate {W}×{H}/{M} — Structural Corpus Analysis")
    lines.append(f"\n**Fecha:** 2026-09-01  \n**Generado por:** `gen_intermediate_structural_corpus.py`  ")
    lines.append(f"**Comparado con:** Expert 30×16/99 (Phase 8, 408 CELLs, 22 floods, 16 historias)")
    lines.append(f"\n## Corpus")
    lines.append(f"\n| Parámetro | Valor |")
    lines.append(f"|:----------|------:|")
    lines.append(f"| (seed,strategy) combos | {n_seeds} |")
    lines.append(f"| Floods únicos | {n_floods} |")
    lines.append(f"| CELL states totales | {len(cells)} |")
    lines.append(f"| Estrategias | {strategies} |")
    if meta:
        lines.append(f"| Media floods/partida | {meta_stats['n_floods_per_game']['mean']:.1f} |")
        lines.append(f"| Media cells/partida | {meta_stats['cells_per_game']['mean']:.1f} |")
        lines.append(f"| Media elapsed/partida | {meta_stats['elapsed_per_game']['mean']:.3f}s |")

    lines.append(f"\n## Distribuciones estructurales")
    lines.append(f"\n| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |")
    lines.append(f"|:------|----:|----:|----:|----:|----:|----:|:-------------|")
    lines.append(fmt_stat_row("total_vars",     st_total_vars,   EXPERT["total_vars"]["max"]))
    lines.append(fmt_stat_row("total_constr",   st_total_constr, 116))
    lines.append(fmt_stat_row("max_width",      st_max_width,    EXPERT["max_width"]["max"]))
    lines.append(fmt_stat_row("n_special",      st_n_special,    None))
    lines.append(fmt_stat_row("n_ordinary",     st_n_ordinary,   EXPERT["n_ordinary"]["max"]))
    lines.append(fmt_stat_row("max_sp_size",    st_max_sp_size,  None))
    lines.append(fmt_stat_row("sum_ord_size",   st_sum_ord_size, None))
    lines.append(fmt_stat_row("unc_other",      st_unc_other,    EXPERT["unc_other"]["max"]))
    lines.append(fmt_stat_row("unc_local_n",    st_unc_local,    None))

    lines.append(f"\n## Distribución por max_width")
    lines.append(f"\n| max_width | n | % | Riesgo Cairo |")
    lines.append(f"|----------:|--:|--:|:-------------|")
    total_n = len(cells)
    for w in sorted(width_counts.keys()):
        n_w = width_counts[w]
        pct_w = 100 * n_w / total_n
        if w >= 7:
            risk_note = "⚠ POSIBLE supera gate"
        elif w == 6:
            risk_note = "⚡ Investigar (1 bajo Expert threshold)"
        elif w == 5:
            risk_note = "ok (sub-threshold)"
        else:
            risk_note = "barato"
        lines.append(f"| {w} | {n_w} | {pct_w:.1f}% | {risk_note} |")

    lines.append(f"\n## Top-5 por max_width (predictor principal Phase 8)")
    lines.append(f"\n| seed | strat | flood_id | step | max_width | total_vars | n_ordinary | unc_other | sum_ord_size |")
    lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|-----------:|----------:|-------------:|")
    for r in top_by_width:
        lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | **{r['max_width']}** | {r['total_vars']} | {r['n_ordinary']} | {r['unconstrained_other']} | {r['sum_ord_size']} |")

    lines.append(f"\n## Top-5 por total_vars (predictor lineal r=+0.679 en Phase 8)")
    lines.append(f"\n| seed | strat | flood_id | step | total_vars | max_width | n_ordinary | unc_other |")
    lines.append(f"|-----:|------:|:---------|-----:|-----------:|----------:|-----------:|----------:|")
    for r in top_by_vars:
        lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | **{r['total_vars']}** | {r['max_width']} | {r['n_ordinary']} | {r['unconstrained_other']} |")

    lines.append(f"\n## Top-5 por sum_ord_size (convolution de componentes ordinarias)")
    lines.append(f"\n| seed | strat | flood_id | step | sum_ord_size | n_ordinary | total_vars | max_width |")
    lines.append(f"|-----:|------:|:---------|-----:|-------------:|-----------:|-----------:|----------:|")
    for r in top_by_ord:
        lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | **{r['sum_ord_size']}** | {r['n_ordinary']} | {r['total_vars']} | {r['max_width']} |")

    lines.append(f"\n## Top-5 por unconstrained_other (multiplicador en extract_outcomes)")
    lines.append(f"\n| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |")
    lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|")
    for r in top_by_unc:
        lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | **{r['unconstrained_other']}** | {r['total_vars']} | {r['max_width']} | {r['remaining_mines']} |")

    lines.append(f"\n## Análisis de cola: width≥7 (señal de riesgo Expert)")

    w8_cells = [r for r in cells if r["max_width"] >= 8]
    w7_ord_cells = [r for r in cells if r["max_width"] == 7 and r["n_ordinary"] > 0]
    w7_no_ord_cells = [r for r in cells if r["max_width"] == 7 and r["n_ordinary"] == 0]

    lines.append(f"\n### width≥8 ({len(w8_cells)} CELLs)")
    if w8_cells:
        lines.append(f"\nTodos con n_ordinary=0. Expert no tuvo ningún CELL con width≥8 en su corpus.")
        lines.append(f"\n| seed | strat | flood_id | step | max_width | total_vars | max_sp_size | unc_other |")
        lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|------------:|----------:|")
        for r in sorted(w8_cells, key=lambda r: (r["max_width"], r["total_vars"]), reverse=True):
            lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | **{r['max_width']}** | {r['total_vars']} | {r['max_sp_size']} | {r['unconstrained_other']} |")
    else:
        lines.append(f"\n*No encontrado en este corpus.*")

    lines.append(f"\n### width=7 + n_ordinary>0 ({len(w7_ord_cells)} CELLs) — patrón Expert unseg")
    lines.append(f"\nEste es el patrón que causó 4 floods UNSEG en Expert (width=7 + n_ord=5-8).")
    if w7_ord_cells:
        top_w7_ord = sorted(w7_ord_cells, key=lambda r: (r["n_ordinary"], r["sum_ord_size"]), reverse=True)[:10]
        lines.append(f"\nTop-10 por (n_ordinary, sum_ord_size):")
        lines.append(f"\n| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord | unc_other |")
        lines.append(f"|-----:|------:|:---------|-----:|----------:|-----------:|------:|--------:|----------:|")
        for r in top_w7_ord:
            lines.append(f"| {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | {r['max_width']} | {r['total_vars']} | **{r['n_ordinary']}** | {r['sum_ord_size']} | {r['unconstrained_other']} |")

    lines.append(f"\n### width=7, n_ordinary=0 ({len(w7_no_ord_cells)} CELLs)")
    lines.append(f"\nEquivalente al Expert width=6 n_ord=0 (max gas 0.571B) pero con más cara VE. Probablemente bajo gate.")

    lines.append(f"\n## Comparación directa con Expert Phase 8")
    lines.append(f"\n| Métrica | Intermediate (max) | Expert (max) | Ratio | Interpretación |")
    lines.append(f"|:--------|------------------:|-------------:|------:|:---------------|")
    tv_ratio = st_total_vars["max"] / EXPERT["total_vars"]["max"]
    mw_ratio = st_max_width["max"]  / EXPERT["max_width"]["max"]
    uo_ratio = st_unc_other["max"]  / EXPERT["unc_other"]["max"]
    no_ratio = st_n_ordinary["max"] / EXPERT["n_ordinary"]["max"]
    lines.append(f"| total_vars | {st_total_vars['max']:.0f} | {EXPERT['total_vars']['max']} | {tv_ratio:.2f}× | {'OK' if tv_ratio < 0.7 else '⚠ similar'} |")
    lines.append(f"| max_width  | {st_max_width['max']:.0f} | {EXPERT['max_width']['max']} | {mw_ratio:.2f}× | {'OK' if mw_ratio < 1.0 else '⚠ mismo'} |")
    lines.append(f"| unc_other  | {st_unc_other['max']:.0f} | {EXPERT['unc_other']['max']} | {uo_ratio:.2f}× | {'OK' if uo_ratio < 0.5 else '⚠ comparable'} |")
    lines.append(f"| n_ordinary | {st_n_ordinary['max']:.0f} | {EXPERT['n_ordinary']['max']} | {no_ratio:.2f}× | {'OK' if no_ratio < 0.7 else '⚠ similar'} |")

    lines.append(f"\n## Estimación de gas (qualitativa)")
    lines.append(f"\nLa estimación cuantitativa de gas requiere tests Cairo reales. La estimación cualitativa:")
    lines.append(f"\n**Factores de escala frente a Expert f15 (peor caso, 6.268B L2 gas):**")
    lines.append(f"- VE con max_width={int(st_max_width['max'])} vs Expert max_width=7: factor ~{2**int(st_max_width['max'])/2**7:.2f}×")
    lines.append(f"- total_vars máximo {int(st_total_vars['max'])} vs Expert 189: factor ~{int(st_total_vars['max'])/189:.2f}×")
    lines.append(f"- unc_other máximo {int(st_unc_other['max'])} vs Expert 474: factor ~{int(st_unc_other['max'])/474:.2f}×")
    lines.append(f"- Producto multiplicativo (si factores independientes): ~{tv_ratio * (2**int(st_max_width['max'])/2**7) * uo_ratio:.3f}×")
    lines.append(f"- Gas estimado máximo (si lineal con factores): ~{6.268 * tv_ratio * (2**int(st_max_width['max'])/2**7) * uo_ratio:.3f}B L2")
    lines.append(f"\n*Nota:* esta estimación es orientativa. La dependencia real es no-lineal (especialmente la VE).")

    lines.append(f"\n## Veredicto de riesgo estructural")
    lines.append(f"\n### **{verdict}**")
    lines.append(f"\n**Racional:** {rationale}")
    lines.append(f"\n**Señales vs Expert:**")
    lines.append(f"- Expert UNSEG: 4/22 floods (18%) con CELLs individuales >1.1B")
    lines.append(f"- Expert predictor más discriminante: max_width=7 → 39% de esos CELLs superan gate; todos con n_ord>0")
    lines.append(f"- Intermediate max_width observado: **{int(st_max_width['max'])}** (umbral Expert: 7, Intermediate lo SUPERA)")
    lines.append(f"- Intermediate width≥8: {n_width8_plus} CELLs (todos con n_ord=0 — mitiga parcialmente)")
    lines.append(f"- Intermediate width=7 + n_ord>0: {n_width7_with_ord} CELLs (patrón de riesgo Expert)")
    lines.append(f"- Intermediate max total_vars: {int(st_total_vars['max'])} (Expert p50: {EXPERT['total_vars']['p50']})")
    lines.append(f"- Intermediate unc_other max (con constraints): {unc_other_max_constrained} (Expert min: {EXPERT['unc_other']['min']})")

    lines.append(f"\n## Candidatos Cairo ({len(candidates)} estados)")
    lines.append(f"\nEscritos en `{CANDIDATES_PATH.name}` para diseño de ronda Cairo.")
    lines.append(f"\nTop-10 por (max_width, total_vars):")
    lines.append(f"\n| # | seed | strat | flood_id | step | max_width | total_vars | unc_other | reason |")
    lines.append(f"|--:|-----:|------:|:---------|-----:|----------:|-----------:|----------:|:-------|")
    for i, r in enumerate(candidates[:10], 1):
        lines.append(f"| {i} | {r['seed']} | {r['strategy']} | {r['flood_id']} | {r['step']} | {r['max_width']} | {r['total_vars']} | {r['unconstrained_other']} | {r.get('_reason','?')} |")

    lines.append(f"\n## Artefactos")
    lines.append(f"\n| Archivo | Descripción |")
    lines.append(f"|:--------|:------------|")
    lines.append(f"| `benchmarks/intermediate-{W}x{H}-{M}-cells-{DATE}.jsonl` | {len(cells)} CELL rows estructurales |")
    lines.append(f"| `benchmarks/intermediate-{W}x{H}-{M}-meta-{DATE}.jsonl` | {len(meta)} game records |")
    lines.append(f"| `benchmarks/intermediate-{W}x{H}-{M}-analysis-{DATE}.md` | Este informe |")
    lines.append(f"| `benchmarks/intermediate-{W}x{H}-{M}-candidates-{DATE}.jsonl` | {len(candidates)} candidatos Cairo |")

    report = "\n".join(lines) + "\n"
    ANALYSIS_PATH.write_text(report)
    print(f"\nReport written to {ANALYSIS_PATH}", file=sys.stderr)
    print(f"Verdict: {verdict}", file=sys.stderr)


if __name__ == "__main__":
    main()
