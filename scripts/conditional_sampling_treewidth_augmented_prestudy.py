#!/usr/bin/env python3
"""
PRESTUDY 2E1 — augmented factor cost simulation.

Para los 120 casos del corpus 30×16/99, simula el tamaño REAL de los factor
tables que necesitaría variable elimination para:
  1. Ordinary exact counting: produce F_C[k] (count vector indexed by mine count)
  2. Special joint query: produce ways[k, x_mine, n_mine]

Usa ordering min-fill. NO implementa VE completa.
Compara contra 2B3 search_nodes/branch_ops.

Métricas por componente:
  - ordinary_augmented_max: max de 2^{sep} × mines_range
  - ordinary_augmented_total: suma sobre todos los pasos
  - special_augmented_max: max de 2^{sep} × mines_range × 2 × (d+1)
  - special_augmented_total: suma
"""

from __future__ import annotations

import json
import statistics
from pathlib import Path
from typing import NamedTuple

import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_exact as cs
import conditional_sampling_2b3_shared_outcomes as b3


# ---------------------------------------------------------------------------
# Graph helpers
# ---------------------------------------------------------------------------

def build_primal_adj(component_vars: list[int], component_constraints: list[cs.Constraint]) -> list[set[int]]:
    n = len(component_vars)
    var_to_idx = {v: i for i, v in enumerate(component_vars)}
    adj: list[set[int]] = [set() for _ in range(n)]
    for constraint in component_constraints:
        local_scope = [var_to_idx[v] for v in constraint.variables if v in var_to_idx]
        for i in range(len(local_scope)):
            for j in range(i + 1, len(local_scope)):
                u, w = local_scope[i], local_scope[j]
                adj[u].add(w)
                adj[w].add(u)
    return adj


def min_fill_ordering(adj_orig: list[set[int]]) -> list[int]:
    n = len(adj_orig)
    adj = [set(neighbors) for neighbors in adj_orig]
    eliminated = [False] * n
    order: list[int] = []
    for _ in range(n):
        best_fill = float("inf")
        best_deg = float("inf")
        best_v = -1
        for v in range(n):
            if not eliminated[v]:
                neighbors = [u for u in adj[v] if not eliminated[u]]
                fill = sum(
                    1
                    for i in range(len(neighbors))
                    for j in range(i + 1, len(neighbors))
                    if neighbors[j] not in adj[neighbors[i]]
                )
                deg = len(neighbors)
                if fill < best_fill or (fill == best_fill and deg < best_deg):
                    best_fill = fill
                    best_deg = deg
                    best_v = v
        order.append(best_v)
        active_neighbors = [u for u in adj[best_v] if not eliminated[u]]
        for i in range(len(active_neighbors)):
            for j in range(i + 1, len(active_neighbors)):
                u, w = active_neighbors[i], active_neighbors[j]
                adj[u].add(w)
                adj[w].add(u)
        eliminated[best_v] = True
    return order


# ---------------------------------------------------------------------------
# Core simulation
# ---------------------------------------------------------------------------

class AugmentedMetrics(NamedTuple):
    case_id: str
    n: int
    remaining_mines: int
    d: int
    width_structural: int
    ordinary_scalar_max: int
    ordinary_aug_max: int
    ordinary_aug_total: int
    special_aug_max: int
    special_aug_total: int
    search_nodes_2b3: int | None
    branch_ops_2b3: int | None
    ordinary_aug_vs_nodes: float | None
    special_aug_vs_nodes: float | None


def simulate_augmented(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    clicked_cell: int,
    local_neighbors: set[int],
    remaining_mines: int,
    search_nodes: int | None,
    branch_ops: int | None,
    case_id: str,
) -> AugmentedMetrics:
    n = len(component_vars)
    comp_var_set = set(component_vars)
    d = len(local_neighbors & comp_var_set) if clicked_cell in comp_var_set else 0
    k_max_component = min(n, remaining_mines)

    adj = build_primal_adj(component_vars, component_constraints)
    order = min_fill_ordering(adj)

    adj_sim = [set(neighbors) for neighbors in adj]
    eliminated = [False] * n

    width_structural = 0
    ordinary_scalar_max = 0
    ordinary_aug_max = 0
    ordinary_aug_total = 0
    special_aug_max = 0
    special_aug_total = 0

    for step, v in enumerate(order):
        active_neighbors = [u for u in adj_sim[v] if not eliminated[u]]
        sep_size = len(active_neighbors)
        width_structural = max(width_structural, sep_size)

        scalar = 2 ** sep_size
        ordinary_scalar_max = max(ordinary_scalar_max, scalar)

        mines_range = min(step + 1, k_max_component) + 1

        ord_aug = scalar * mines_range
        ordinary_aug_max = max(ordinary_aug_max, ord_aug)
        ordinary_aug_total += ord_aug

        spec_aug = ord_aug * 2 * (d + 1)
        special_aug_max = max(special_aug_max, spec_aug)
        special_aug_total += spec_aug

        for i in range(len(active_neighbors)):
            for j in range(i + 1, len(active_neighbors)):
                u, w = active_neighbors[i], active_neighbors[j]
                adj_sim[u].add(w)
                adj_sim[w].add(u)
        eliminated[v] = True

    def ratio(a, b):
        return a / b if b else None

    return AugmentedMetrics(
        case_id=case_id,
        n=n,
        remaining_mines=remaining_mines,
        d=d,
        width_structural=width_structural,
        ordinary_scalar_max=ordinary_scalar_max,
        ordinary_aug_max=ordinary_aug_max,
        ordinary_aug_total=ordinary_aug_total,
        special_aug_max=special_aug_max,
        special_aug_total=special_aug_total,
        search_nodes_2b3=search_nodes,
        branch_ops_2b3=branch_ops,
        ordinary_aug_vs_nodes=ratio(ordinary_aug_max, search_nodes),
        special_aug_vs_nodes=ratio(special_aug_max, search_nodes),
    )


# ---------------------------------------------------------------------------
# Analyze corpus
# ---------------------------------------------------------------------------

def analyze_corpus(corpus_path: Path, b3_bench_path: Path) -> list[AugmentedMetrics]:
    corpus = {json.loads(l)["case_id"]: json.loads(l) for l in corpus_path.read_text().splitlines() if l.strip()}
    bench = {json.loads(l)["case_id"]: json.loads(l) for l in b3_bench_path.read_text().splitlines() if l.strip()}

    all_metrics: list[AugmentedMetrics] = []

    for case_id in sorted(corpus):
        case = corpus[case_id]
        t = case["transcript"]
        transcript = cs.Transcript(
            width=int(t["width"]), height=int(t["height"]), total_mines=int(t["total_mines"]),
            revealed_clues={int(item["index"]): int(item["clue"]) for item in t["revealed_clues"]},
            known_mines=frozenset(int(item["index"]) for item in t["known_mines"]),
            label=str(t["label"]), generator_seed=t.get("generator_seed"),
        )
        consistent, constraints, variables, remaining_mines = cs.build_constraints(transcript)
        if not consistent or not variables:
            continue

        comp_vars_list, comp_consts_list = cs.connected_components(variables, constraints)
        clicked = int(case["clicked_cell"]["index"])
        local_hidden, local_neighbors, _ = b3.local_hidden_sets(transcript, clicked)

        b3_res = bench.get(case_id)
        nodes = b3_res["result"]["total_search_nodes"] if b3_res and b3_res["status"] == "ok" else None
        bops = b3_res["result"]["total_branch_ops"] if b3_res and b3_res["status"] == "ok" else None

        for cvars, cconsts in zip(comp_vars_list, comp_consts_list):
            if not (set(cvars) & local_hidden):
                continue
            m = simulate_augmented(
                component_vars=cvars,
                component_constraints=cconsts,
                clicked_cell=clicked,
                local_neighbors=local_neighbors,
                remaining_mines=remaining_mines,
                search_nodes=nodes,
                branch_ops=bops,
                case_id=case_id,
            )
            all_metrics.append(m)

    return all_metrics


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def pct(vals, p):
    if not vals:
        return float("nan")
    s = sorted(vals)
    idx = p / 100 * (len(s) - 1)
    lo, hi = int(idx), min(int(idx) + 1, len(s) - 1)
    return s[lo] + (idx - lo) * (s[hi] - s[lo])


def report(metrics: list[AugmentedMetrics]):
    def P(label, vals):
        print(
            f"  {label:42s}: p50={pct(vals,50):8.0f}  p90={pct(vals,90):8.0f}  max={max(vals):8.0f}"
        )

    def P_ratio(label, a_list, b_list):
        ratios = [a/b for a, b in zip(a_list, b_list) if b and b > 0]
        if not ratios:
            return
        print(
            f"  {label:42s}: p50={pct(ratios,50):8.2f}  p90={pct(ratios,90):8.2f}  max={max(ratios):8.2f}  mean={statistics.mean(ratios):8.2f}"
        )

    nodes_all = [m.search_nodes_2b3 for m in metrics if m.search_nodes_2b3]
    print(f"\n{'='*70}")
    print(f"CORPUS 30×16/99 — {len(metrics)} special components")
    print()
    print("--- 2B3 DFS COST (reference) ---")
    P("search_nodes", nodes_all)
    print()
    print("--- ORDINARY AUGMENTED (F_C[k]) ---")
    P("ordinary_aug_max (peak)", [m.ordinary_aug_max for m in metrics])
    P("ordinary_aug_total (sum all steps)", [m.ordinary_aug_total for m in metrics])
    print()
    print("--- SPECIAL AUGMENTED (ways[k,x_mine,n_mine]) ---")
    ds = [m.d for m in metrics]
    print(f"  d = |N(x)∩comp|: min={min(ds)} p50={pct(ds,50):.0f} p90={pct(ds,90):.0f} max={max(ds)}")
    P("special_aug_max (peak)", [m.special_aug_max for m in metrics])
    P("special_aug_total (sum all steps)", [m.special_aug_total for m in metrics])
    print()
    print("--- RATIOS: augmented / DFS nodes ---")
    ok = [m for m in metrics if m.search_nodes_2b3]
    P_ratio("ordinary_aug_max / search_nodes", [m.ordinary_aug_max for m in ok], [m.search_nodes_2b3 for m in ok])
    P_ratio("special_aug_max / search_nodes", [m.special_aug_max for m in ok], [m.search_nodes_2b3 for m in ok])
    P_ratio("ordinary_aug_total / search_nodes", [m.ordinary_aug_total for m in ok], [m.search_nodes_2b3 for m in ok])
    P_ratio("special_aug_total / search_nodes", [m.special_aug_total for m in ok], [m.search_nodes_2b3 for m in ok])
    print()

    hard = [m for m in ok if m.search_nodes_2b3 > 1500]
    print(f"--- HARD CASES (nodes>1500): {len(hard)} ---")
    if hard:
        P_ratio("ord_aug_max / search_nodes", [m.ordinary_aug_max for m in hard], [m.search_nodes_2b3 for m in hard])
        P_ratio("spc_aug_max / search_nodes", [m.special_aug_max for m in hard], [m.search_nodes_2b3 for m in hard])
        P_ratio("ord_aug_total / search_nodes", [m.ordinary_aug_total for m in hard], [m.search_nodes_2b3 for m in hard])
        P_ratio("spc_aug_total / search_nodes", [m.special_aug_total for m in hard], [m.search_nodes_2b3 for m in hard])
    print()

    print("--- TOP 10 BY special_aug_max ---")
    print(f"  {'case_id':10} {'n':3} {'w':2} {'d':2} {'mines':6} {'ord_max':8} {'spc_max':8} {'nodes':8} {'spc/nd':8}")
    for m in sorted(metrics, key=lambda x: -x.special_aug_max)[:10]:
        r = f"{m.special_aug_max/m.search_nodes_2b3:.2f}" if m.search_nodes_2b3 else "N/A"
        print(f"  {m.case_id:10} {m.n:3} {m.width_structural:2} {m.d:2} {m.remaining_mines:6} "
              f"{m.ordinary_aug_max:8} {m.special_aug_max:8} {str(m.search_nodes_2b3):8} {r:8}")
    print()

    print("--- LARGE COMPONENTS (n>=46) ---")
    for m in sorted([m for m in metrics if m.n >= 46], key=lambda x: -x.n)[:8]:
        print(f"  {m.case_id}: n={m.n} w={m.width_structural} d={m.d} "
              f"ord_aug_max={m.ordinary_aug_max} spc_aug_max={m.special_aug_max} "
              f"nodes={m.search_nodes_2b3}")


if __name__ == "__main__":
    repo_root = Path(__file__).resolve().parent.parent
    corpus_path = repo_root / "benchmarks" / "conditional-sampling-2a-corpus-20260830.jsonl"
    b3_path = repo_root / "benchmarks" / "conditional-sampling-2b3-shared-outcomes-20260830.jsonl"
    out_path = repo_root / "benchmarks" / "conditional-sampling-treewidth-augmented-20260830.jsonl"

    print("Running augmented factor simulation on 30×16/99 corpus...", flush=True)
    metrics = analyze_corpus(corpus_path, b3_path)
    print(f"  {len(metrics)} special components analyzed")

    report(metrics)

    with out_path.open("w", encoding="utf-8") as f:
        for m in metrics:
            f.write(json.dumps(m._asdict(), sort_keys=True) + "\n")
    print(f"\nRaw saved: {out_path}")
