#!/usr/bin/env python3
"""
parse_square_gas.py

Parsea logs snforge para tableros NxN/M y produce:
  benchmarks/square-{N}x{N}-{M}-gas-{DATE}.jsonl   (raw gas + features por candidato)
  benchmarks/square-{N}x{N}-{M}-gas-analysis-{DATE}.md  (estadísticas + verdict)

Formato del log:
  [PASS] zkmine_2g::tests::test_ve_sq{N}x{N}::sq{N}_f00 (l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~296898158)

Uso:
    python3 scripts/parse_square_gas.py --size 15 --mines 35

Criterio predeclarado (invariante — no cambiar después de ver resultados):
  GREEN:  100% exactos, cero candidatos >= 900,000,000 L2 Sierra gas
  YELLOW: 100% exactos, cero candidatos > 1,100,000,000, al menos uno >= 900,000,000
  RED:    cualquier candidato > 1,100,000,000 OR fallo de exactitud no metodológico
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DATE = "20260901"

GREEN_GATE  = 900_000_000
YELLOW_GATE = 1_100_000_000


def mines_for_size(n: int) -> int:
    return math.floor(5 * n * n / 32 + 0.5)


def parse_gas_from_log(log_path: Path, prefix: str) -> dict[int, int]:
    """Parse l2_gas values from snforge log. Returns {fixture_index: gas}."""
    pattern = re.compile(
        rf"\[PASS\].*::{re.escape(prefix)}_f(\d+)\s+\(.*l2_gas:\s+~(\d+)\)"
    )
    result: dict[int, int] = {}
    if not log_path.exists():
        return result
    with open(log_path) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                idx = int(m.group(1))
                gas = int(m.group(2))
                result[idx] = gas
    return result


def parse_exact_pass_from_log(log_path: Path, prefix: str) -> set[int]:
    """Return fixture indices that have [PASS] in the exact log."""
    pattern = re.compile(
        rf"\[PASS\].*::{re.escape(prefix)}_exact_f(\d+)"
    )
    passed: set[int] = set()
    if not log_path.exists():
        return passed
    with open(log_path) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                passed.add(int(m.group(1)))
    return passed


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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--size",    type=int, required=True)
    parser.add_argument("--mines",   type=int, default=-1)
    parser.add_argument("--run-tag", type=str, default="", help="Optional tag for replication runs (e.g. rep2)")
    args = parser.parse_args()

    N = args.size
    M = args.mines if args.mines >= 0 else mines_for_size(N)
    tag_infix  = f"-{args.run_tag}" if args.run_tag else ""
    tag_suffix = f"_{args.run_tag}" if args.run_tag else ""
    prefix = f"sq{N}{tag_suffix}"
    size_tag = f"sq{N}x{N}{tag_suffix}"

    candidates_path  = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-candidates-{DATE}.jsonl"
    log_bench_path   = REPO_ROOT / "benchmarks" / f"square-snforge-bench-{size_tag}-{DATE}.log"
    log_exact_path   = REPO_ROOT / "benchmarks" / f"square-snforge-exact-{size_tag}-{DATE}.log"
    gas_out_path     = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-gas-{DATE}.jsonl"
    analysis_path    = REPO_ROOT / "benchmarks" / f"square-{N}x{N}-{M}{tag_infix}-gas-analysis-{DATE}.md"

    # Load candidates (for structural features)
    candidates: list[dict] = []
    with open(candidates_path) as f:
        for line in f:
            if line.strip():
                candidates.append(json.loads(line))
    print(f"Loaded {len(candidates)} candidates", file=sys.stderr)

    # Parse gas
    bench_gas  = parse_gas_from_log(log_bench_path, prefix)
    exact_pass = parse_exact_pass_from_log(log_exact_path, prefix)
    print(f"Bench gas parsed: {len(bench_gas)} entries", file=sys.stderr)
    print(f"Exact pass:       {len(exact_pass)} entries", file=sys.stderr)

    # Build combined records
    records: list[dict] = []
    for i, cand in enumerate(candidates):
        if i not in bench_gas:
            print(f"  WARNING: no gas for candidate {i} ({cand.get('flood_id','?')})", file=sys.stderr)
            continue
        rec = {
            "fixture_index":   i,
            "flood_id":        cand.get("flood_id", "?"),
            "seed":            cand.get("seed", -1),
            "strategy":        cand.get("strategy", -1),
            "step":            cand.get("step", -1),
            "wave_index":      cand.get("wave_index", -1),
            "cell_index":      cand.get("cell_index", -1),
            "max_width":       cand.get("max_width", 0),
            "total_vars":      cand.get("total_vars", 0),
            "total_constr":    cand.get("total_constr", 0),
            "n_special":       cand.get("n_special", 0),
            "n_ordinary":      cand.get("n_ordinary", 0),
            "max_sp_size":     cand.get("max_sp_size", 0),
            "sum_ord_size":    cand.get("sum_ord_size", 0),
            "max_ord_internal_width": cand.get("max_ord_internal_width", 0),
            "unconstrained_other": cand.get("unconstrained_other", 0),
            "remaining_mines": cand.get("remaining_mines", 0),
            "reason":          cand.get("_reason", "?"),
            "bench_gas":       bench_gas[i],
            "exact_pass":      i in exact_pass,
        }
        records.append(rec)

    # Write gas JSONL
    with open(gas_out_path, "w") as f:
        for rec in records:
            f.write(json.dumps(rec) + "\n")
    print(f"Written {len(records)} records to {gas_out_path}", file=sys.stderr)

    if not records:
        print("ERROR: No gas records — cannot produce analysis.", file=sys.stderr)
        sys.exit(1)

    # Statistics
    gas_vals    = [r["bench_gas"] for r in records]
    st          = stats(gas_vals)
    n_total     = len(records)
    n_exact     = sum(1 for r in records if r["exact_pass"])
    n_lt750     = sum(1 for g in gas_vals if g < 750_000_000)
    n_750_900   = sum(1 for g in gas_vals if 750_000_000 <= g < 900_000_000)
    n_900_1100  = sum(1 for g in gas_vals if 900_000_000 <= g <= 1_100_000_000)
    n_gt1100    = sum(1 for g in gas_vals if g > 1_100_000_000)

    # Top 10 by gas
    top10 = sorted(records, key=lambda r: r["bench_gas"], reverse=True)[:10]

    # Verdict (predeclared criteria — DO NOT CHANGE after seeing results)
    exact_pct = n_exact / n_total * 100 if n_total else 0
    all_exact = (n_exact == n_total)

    if not all_exact:
        verdict = "RED"
        verdict_reason = f"exactitud fallida: {n_total - n_exact}/{n_total} tests exact no PASS"
    elif n_gt1100 > 0:
        verdict = "RED"
        verdict_reason = f"{n_gt1100} candidatos > 1.1B L2 Sierra gas (gate Starknet)"
    elif n_900_1100 > 0 or n_750_900 > 0:
        verdict = "YELLOW"
        verdict_reason = (
            f"{n_900_1100} candidatos en [900M, 1.1B] + {n_750_900} en [750M, 900M). "
            f"100% exactos, cero > 1.1B. NO garantizable sin continuation intra-CELL."
        )
    else:
        verdict = "GREEN"
        verdict_reason = (
            f"100% exactos Python ↔ Cairo. Cero candidatos >= 900M. "
            f"max gas = {int(st['max']):,} L2 Sierra."
        )

    # Generate analysis report
    def fmt_gas(g: float) -> str:
        return f"{int(g):,}"

    lines: list[str] = []
    lines.append(f"# Square {N}×{N}/{M} — Cairo CELL Gas Benchmark")
    lines.append(f"\n**Fecha:** {DATE}  ")
    lines.append(f"**Candidatos:** {n_total}  ")
    lines.append(f"**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B")
    lines.append(f"\n---\n")

    lines.append(f"## Exactitud Python ↔ Cairo\n")
    lines.append(f"| Métrica | Valor |")
    lines.append(f"|:--------|------:|")
    lines.append(f"| Candidatos ejecutados | **{n_total}/{len(candidates)}** |")
    lines.append(f"| Tests exact PASS | **{n_exact}/{n_total}** |")
    lines.append(f"| Fallos de exactitud | **{n_total - n_exact}** |")
    lines.append(f"| Exactitud % | {exact_pct:.1f}% |")

    lines.append(f"\n## Estadísticas de gas L2 Sierra ({n_total} candidatos)\n")
    lines.append(f"| Estadístico | Gas L2 Sierra |")
    lines.append(f"|:------------|-------------:|")
    lines.append(f"| n | {int(st['n'])} |")
    lines.append(f"| min | {fmt_gas(st['min'])} |")
    lines.append(f"| mean | {fmt_gas(st['mean'])} |")
    lines.append(f"| p50 | {fmt_gas(st['p50'])} |")
    lines.append(f"| p90 | {fmt_gas(st['p90'])} |")
    lines.append(f"| p95 | {fmt_gas(st['p95'])} |")
    lines.append(f"| p99 | {fmt_gas(st['p99'])} |")
    lines.append(f"| max | **{fmt_gas(st['max'])}** |")

    lines.append(f"\n### Distribución por bucket (gate Starknet = 1.1B L2 gas)\n")
    lines.append(f"| Bucket | Count | % |")
    lines.append(f"|:-------|------:|--:|")
    lines.append(f"| < 750 M | **{n_lt750}** | **{100*n_lt750/n_total:.1f} %** |")
    lines.append(f"| 750 M – 900 M | {n_750_900} | {100*n_750_900/n_total:.1f} % |")
    lines.append(f"| 900 M – 1.1 B | {n_900_1100} | {100*n_900_1100/n_total:.1f} % |")
    lines.append(f"| **> 1.1 B** | **{n_gt1100}** | **{100*n_gt1100/n_total:.1f} %** |")

    lines.append(f"\n## Top 10 por gas\n")
    lines.append(f"| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |")
    lines.append(f"|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|")
    for rank, r in enumerate(top10, 1):
        gas_m = r["bench_gas"] / 1e6
        lines.append(
            f"| {rank} | f{r['fixture_index']:02d} | {r['flood_id']} s{r['step']} "
            f"| {gas_m:.0f} | {r['max_width']} | {r['sum_ord_size']} "
            f"| {r['max_ord_internal_width']} | {r['total_vars']} | {r['unconstrained_other']} |"
        )

    # Cases > 1.1B if any
    cases_red = [r for r in records if r["bench_gas"] > 1_100_000_000]
    if cases_red:
        lines.append(f"\n## Casos > 1.1 B ({len(cases_red)} total)\n")
        lines.append(f"| fixture | flood_id_step | gas (B) | max_w | vars | sum_ord | ord_iw | unc_oth |")
        lines.append(f"|:--------|:--------------|--------:|------:|-----:|--------:|-------:|--------:|")
        for r in sorted(cases_red, key=lambda r: r["bench_gas"], reverse=True):
            lines.append(
                f"| f{r['fixture_index']:02d} | {r['flood_id']}_s{r['step']:03d} "
                f"| **{r['bench_gas']/1e9:.3f}** | {r['max_width']} | {r['total_vars']} "
                f"| {r['sum_ord_size']} | {r['max_ord_internal_width']} | {r['unconstrained_other']} |"
            )

    # Correlations
    if len(records) >= 3:
        def corr(xs: list[float], ys: list[float]) -> float:
            n = len(xs)
            if n < 2:
                return 0.0
            mx, my = sum(xs)/n, sum(ys)/n
            num = sum((x-mx)*(y-my) for x,y in zip(xs,ys))
            dx  = (sum((x-mx)**2 for x in xs)**0.5)
            dy  = (sum((y-my)**2 for y in ys)**0.5)
            if dx == 0 or dy == 0:
                return 0.0
            return num / (dx * dy)

        g = gas_vals
        features = [
            ("sum_ord_size",           [r["sum_ord_size"] for r in records]),
            ("max_ord_internal_width", [r["max_ord_internal_width"] for r in records]),
            ("total_vars",             [r["total_vars"] for r in records]),
            ("unconstrained_other",    [r["unconstrained_other"] for r in records]),
            ("max_width",              [r["max_width"] for r in records]),
            ("n_ordinary",             [r["n_ordinary"] for r in records]),
        ]
        lines.append(f"\n## Correlaciones gas ↔ features\n")
        lines.append(f"| Feature | r con bench_gas |")
        lines.append(f"|:--------|----------------:|")
        for fname, fvals in features:
            r_val = corr(fvals, g)
            lines.append(f"| {fname} | {r_val:+.3f} |")

    # Comparison with 16x16 and Expert
    lines.append(f"\n## Comparación con referencias\n")
    lines.append(f"| Métrica | {N}×{N}/{M} | 16×16/40 (RED) | Expert 30×16 |")
    lines.append(f"|:--------|----------:|---------------:|-------------:|")
    lines.append(f"| n | {n_total} | 59 | 408 |")
    lines.append(f"| p50 (M) | {int(st['p50'])//1000000} | 75 | 143 |")
    lines.append(f"| p90 (M) | {int(st['p90'])//1000000} | 403 | 1,131 |")
    lines.append(f"| max (M) | {int(st['max'])//1000000} | 1,591 | 6,268 |")
    lines.append(f"| > 1.1B | {n_gt1100} ({100*n_gt1100/n_total:.1f}%) | 3 (5.1%) | 45 (11.0%) |")

    # Verdict section
    lines.append(f"\n---\n")
    lines.append(f"## Veredicto\n")
    lines.append(f"### **{verdict}**\n")
    lines.append(f"**Criterio activado:** {verdict_reason}\n")
    lines.append(f"\n**Detalles:**")
    lines.append(f"- {n_exact}/{n_total} exactos Python ↔ Cairo {'✓' if all_exact else '✗'}")
    lines.append(f"- {n_lt750}/{n_total} por debajo de 750 M {'✓' if n_lt750 == n_total else ''}")
    lines.append(f"- {n_750_900} casos en [750M, 900M)")
    lines.append(f"- {n_900_1100} casos en [900M, 1.1B]")
    lines.append(f"- **{n_gt1100} casos > 1.1B** {'✗ → RED' if n_gt1100 > 0 else '✓'}")

    lines.append(f"\n---\n")
    lines.append(f"## Artefactos\n")
    lines.append(f"| Archivo | Descripción |")
    lines.append(f"|:--------|:------------|")
    lines.append(f"| `benchmarks/square-{N}x{N}-{M}{tag_infix}-gas-{DATE}.jsonl` | Raw gas + features ({len(records)} filas) |")
    lines.append(f"| `benchmarks/square-snforge-bench-{size_tag}-{DATE}.log` | Log snforge benchmark |")
    lines.append(f"| `benchmarks/square-snforge-exact-{size_tag}-{DATE}.log` | Log snforge exact |")

    report = "\n".join(lines) + "\n"
    analysis_path.write_text(report)
    print(f"\nReport written to {analysis_path}", file=sys.stderr)
    print(f"\n{'='*50}", file=sys.stderr)
    print(f"VERDICT: {verdict}", file=sys.stderr)
    print(f"Reason:  {verdict_reason}", file=sys.stderr)
    print(f"{'='*50}", file=sys.stderr)
    print(f"  n={n_total}, exact={n_exact}/{n_total}, "
          f"max_gas={int(st['max']):,}, n_gt1100={n_gt1100}", file=sys.stderr)


if __name__ == "__main__":
    main()
