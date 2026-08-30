#!/usr/bin/env python3
"""
PRESTUDY 2E — Frontier treewidth analysis.

Mide estructura del primal constraint graph para cada componente:
- Min-fill elimination width (upper bound treewidth)
- Min-degree elimination width (upper bound treewidth)
- Max clique size - 1 (lower bound treewidth)
- 2^{width} como indicador del factor size para junction tree

Datasets:
  A. Corpus 30x16/99 (benchmark objetivo)
  B. Historias smoke 12x12/20 (evolución early/mid/late)

No modifica raws congelados ni código de algoritmos existentes.
"""

from __future__ import annotations

import json
import statistics
from collections import defaultdict
from pathlib import Path
from typing import NamedTuple

import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_exact as cs
import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_history_smoke as hs


# ---------------------------------------------------------------------------
# Primal constraint graph helpers
# ---------------------------------------------------------------------------

def build_primal_graph(
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
) -> list[set[int]]:
    """
    Primal constraint graph: nodes indexed 0..n-1 (local indices).
    Two variables are adjacent iff they appear together in any constraint scope.
    Each constraint scope induces a clique.
    """
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


def edge_count(adj: list[set[int]]) -> int:
    return sum(len(neighbors) for neighbors in adj) // 2


def degree_stats(adj: list[set[int]]) -> tuple[int, float, int]:
    degrees = [len(neighbors) for neighbors in adj]
    return min(degrees), sum(degrees) / len(degrees), max(degrees)


# ---------------------------------------------------------------------------
# Elimination ordering heuristics
# ---------------------------------------------------------------------------

def _elimination_width(adj_original: list[set[int]], order_fn) -> tuple[int, list[int]]:
    """
    Generic elimination: repeatedly select a variable according to order_fn,
    connect all remaining neighbors to each other (triangulation), record width.
    Returns (elimination_width, order).
    """
    n = len(adj_original)
    adj = [set(neighbors) for neighbors in adj_original]
    eliminated = [False] * n
    width = 0
    order: list[int] = []

    for _ in range(n):
        v = order_fn(adj, eliminated)
        order.append(v)
        active_neighbors = [u for u in adj[v] if not eliminated[u]]
        width = max(width, len(active_neighbors))
        # Connect all remaining neighbors (triangulation)
        for i in range(len(active_neighbors)):
            for j in range(i + 1, len(active_neighbors)):
                u, w = active_neighbors[i], active_neighbors[j]
                adj[u].add(w)
                adj[w].add(u)
        eliminated[v] = True

    return width, order


def min_degree_width(adj: list[set[int]]) -> int:
    def order_fn(adj, eliminated):
        best_deg = float("inf")
        best_v = -1
        for v in range(len(adj)):
            if not eliminated[v]:
                deg = sum(1 for u in adj[v] if not eliminated[u])
                if deg < best_deg or (deg == best_deg and v < best_v):
                    best_deg = deg
                    best_v = v
        return best_v

    width, _ = _elimination_width(adj, order_fn)
    return width


def min_fill_width(adj: list[set[int]]) -> int:
    def order_fn(adj, eliminated):
        best_fill = float("inf")
        best_deg = float("inf")
        best_v = -1
        for v in range(len(adj)):
            if not eliminated[v]:
                neighbors = [u for u in adj[v] if not eliminated[u]]
                fill = 0
                for i in range(len(neighbors)):
                    for j in range(i + 1, len(neighbors)):
                        if neighbors[j] not in adj[neighbors[i]]:
                            fill += 1
                deg = len(neighbors)
                # Tie-break: fewer fill edges first, then higher degree (larger
                # remaining neighborhood eliminates more efficiently)
                if fill < best_fill or (fill == best_fill and deg < best_deg):
                    best_fill = fill
                    best_deg = deg
                    best_v = v
        return best_v

    width, _ = _elimination_width(adj, order_fn)
    return width


# ---------------------------------------------------------------------------
# Lower bound: max clique size - 1
# ---------------------------------------------------------------------------

def max_clique_size(adj: list[set[int]]) -> int:
    """
    Bron-Kerbosch for max clique. Practical for n ≤ 60 if the graph is sparse.
    In Minesweeper primal graphs, max clique ≤ max_scope ≤ 8, so this is fast.
    """
    n = len(adj)
    best = [1]

    def bk(R: set[int], P: set[int], X: set[int]):
        if not P and not X:
            best[0] = max(best[0], len(R))
            return
        if not P:
            return
        # Choose pivot with max connections to P
        pivot = max(P | X, key=lambda v: len(adj[v] & P))
        for v in list(P - adj[pivot]):
            bk(R | {v}, P & adj[v], X & adj[v])
            P.remove(v)
            X.add(v)

    bk(set(), set(range(n)), set())
    return best[0]


# ---------------------------------------------------------------------------
# Per-component analysis
# ---------------------------------------------------------------------------

class ComponentMetrics(NamedTuple):
    dataset: str
    case_id: str
    phase: str | None
    component_index: int
    n: int
    num_constraints: int
    max_scope_size: int
    num_edges: int
    density: float
    degree_min: int
    degree_mean: float
    degree_max: int
    upper_bound_min_degree: int
    upper_bound_min_fill: int
    upper_bound_best: int
    lower_bound_clique: int
    exact_or_uncertain: str
    log2_factor_best: int
    search_nodes_2b3: int | None
    is_special: bool


def analyze_component(
    dataset: str,
    case_id: str,
    phase: str | None,
    component_index: int,
    component_vars: list[int],
    component_constraints: list[cs.Constraint],
    search_nodes_2b3: int | None,
    is_special: bool,
) -> ComponentMetrics:
    n = len(component_vars)
    num_constraints = len(component_constraints)
    max_scope = max(len(c.variables) for c in component_constraints) if component_constraints else 0

    adj = build_primal_graph(component_vars, component_constraints)
    edges = edge_count(adj)
    max_possible_edges = n * (n - 1) // 2
    density = edges / max_possible_edges if max_possible_edges else 0.0
    deg_min, deg_mean, deg_max = degree_stats(adj)

    ub_mindeg = min_degree_width(adj)
    ub_minfill = min_fill_width(adj)
    ub_best = min(ub_mindeg, ub_minfill)

    mc = max_clique_size(adj)
    lb_clique = mc - 1

    if lb_clique == ub_best:
        exact_or_uncertain = "exact"
    else:
        exact_or_uncertain = f"in [{lb_clique}, {ub_best}]"

    return ComponentMetrics(
        dataset=dataset,
        case_id=case_id,
        phase=phase,
        component_index=component_index,
        n=n,
        num_constraints=num_constraints,
        max_scope_size=max_scope,
        num_edges=edges,
        density=density,
        degree_min=deg_min,
        degree_mean=deg_mean,
        degree_max=deg_max,
        upper_bound_min_degree=ub_mindeg,
        upper_bound_min_fill=ub_minfill,
        upper_bound_best=ub_best,
        lower_bound_clique=lb_clique,
        exact_or_uncertain=exact_or_uncertain,
        log2_factor_best=ub_best,
        search_nodes_2b3=search_nodes_2b3,
        is_special=is_special,
    )


# ---------------------------------------------------------------------------
# Dataset A: 30x16/99 corpus
# ---------------------------------------------------------------------------

def analyze_corpus(
    corpus_path: Path,
    benchmark_path: Path,
) -> list[ComponentMetrics]:
    corpus = {
        json.loads(l)["case_id"]: json.loads(l)
        for l in corpus_path.read_text().splitlines() if l.strip()
    }
    benchmark = {
        json.loads(l)["case_id"]: json.loads(l)
        for l in benchmark_path.read_text().splitlines() if l.strip()
    }

    metrics: list[ComponentMetrics] = []
    for case_id, case in sorted(corpus.items()):
        transcript_data = case["transcript"]
        transcript = cs.Transcript(
            width=int(transcript_data["width"]),
            height=int(transcript_data["height"]),
            total_mines=int(transcript_data["total_mines"]),
            revealed_clues={int(item["index"]): int(item["clue"]) for item in transcript_data["revealed_clues"]},
            known_mines=frozenset(int(item["index"]) for item in transcript_data["known_mines"]),
            label=str(transcript_data["label"]),
            generator_seed=transcript_data.get("generator_seed"),
        )
        consistent, constraints, variables, _ = cs.build_constraints(transcript)
        if not consistent or not variables:
            continue

        component_variables, component_constraints = cs.connected_components(variables, constraints)
        clicked = int(case["clicked_cell"]["index"])
        local_hidden, _, _ = b3.local_hidden_sets(transcript, clicked)

        bench = benchmark.get(case_id)
        total_nodes = bench["result"]["total_search_nodes"] if bench and bench["status"] == "ok" else None

        for c_idx, (cvars, cconstraints) in enumerate(zip(component_variables, component_constraints)):
            is_special = bool(set(cvars) & local_hidden)
            # Assign total_search_nodes only to the special component (only 1 in corpus)
            nodes = total_nodes if is_special else None
            m = analyze_component(
                dataset="30x16_99",
                case_id=case_id,
                phase=None,
                component_index=c_idx,
                component_vars=cvars,
                component_constraints=cconstraints,
                search_nodes_2b3=nodes,
                is_special=is_special,
            )
            metrics.append(m)

    return metrics


# ---------------------------------------------------------------------------
# Dataset B: 12x12/20 histories
# ---------------------------------------------------------------------------

def analyze_histories(
    histories_path: Path,
    benchmark_path: Path,
) -> list[ComponentMetrics]:
    histories_rows = [json.loads(l) for l in histories_path.read_text().splitlines() if l.strip()]
    bench_by_id: dict[str, list] = defaultdict(list)
    for l in benchmark_path.read_text().splitlines():
        if l.strip():
            row = json.loads(l)
            bench_by_id[row["transcript_id"]].append(row)
    bench_lookup = {r["transcript_id"]: r for rows in bench_by_id.values() for r in rows}

    metrics: list[ComponentMetrics] = []
    for row in histories_rows:
        transcript = b3.transcript_from_corpus_row({"transcript": row["transcript"]})
        consistent, constraints, variables, _ = cs.build_constraints(transcript)
        if not consistent or not variables:
            continue

        component_variables, component_constraints = cs.connected_components(variables, constraints)
        clicked = int(row["clicked_cell"]["index"])
        local_hidden, _, _ = b3.local_hidden_sets(transcript, clicked)
        phase = str(row["phase"])
        transcript_id = str(row["transcript_id"])
        case_id = str(row["transcript_id"])

        bench = bench_lookup.get(transcript_id)
        total_nodes = bench["compare"]["2B3"]["total_search_nodes"] if bench else None

        for c_idx, (cvars, cconstraints) in enumerate(zip(component_variables, component_constraints)):
            is_special = bool(set(cvars) & local_hidden)
            nodes = total_nodes if is_special else None
            m = analyze_component(
                dataset="12x12_20",
                case_id=case_id,
                phase=phase,
                component_index=c_idx,
                component_vars=cvars,
                component_constraints=cconstraints,
                search_nodes_2b3=nodes,
                is_special=is_special,
            )
            metrics.append(m)

    return metrics


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def percentile(values: list[float], p: float) -> float:
    if not values:
        return float("nan")
    s = sorted(values)
    idx = p / 100 * (len(s) - 1)
    lo, hi = int(idx), min(int(idx) + 1, len(s) - 1)
    return s[lo] + (idx - lo) * (s[hi] - s[lo])


def report_distribution(label: str, values: list[int | float]):
    if not values:
        print(f"  {label}: (empty)")
        return
    print(
        f"  {label}: min={min(values):.1f} p25={percentile(values,25):.1f} "
        f"p50={percentile(values,50):.1f} p75={percentile(values,75):.1f} "
        f"p90={percentile(values,90):.1f} p95={percentile(values,95):.1f} "
        f"p99={percentile(values,99):.1f} max={max(values):.1f}"
    )


def print_report(all_metrics: list[ComponentMetrics]):
    for dataset in ("30x16_99", "12x12_20"):
        metrics = [m for m in all_metrics if m.dataset == dataset]
        if not metrics:
            continue

        special = [m for m in metrics if m.is_special]
        print(f"\n{'='*70}")
        print(f"DATASET: {dataset}")
        print(f"  Total components: {len(metrics)} ({len(special)} special)")
        print(f"  Unique transcripts: {len(set(m.case_id for m in metrics))}")
        print()

        # Special components only (these drive DFS cost)
        print("--- SPECIAL COMPONENTS ONLY ---")
        report_distribution("n (size)", [m.n for m in special])
        report_distribution("num_constraints", [m.num_constraints for m in special])
        report_distribution("edges", [m.num_edges for m in special])
        report_distribution("density", [m.density for m in special])
        report_distribution("degree_max", [m.degree_max for m in special])
        report_distribution("upper_bound_min_fill", [m.upper_bound_min_fill for m in special])
        report_distribution("upper_bound_min_degree", [m.upper_bound_min_degree for m in special])
        report_distribution("upper_bound_best", [m.upper_bound_best for m in special])
        report_distribution("lower_bound_clique", [m.lower_bound_clique for m in special])
        report_distribution("2^ub_best", [2**m.upper_bound_best for m in special])
        report_distribution("n / ub_best ratio", [m.n / m.upper_bound_best if m.upper_bound_best else float("inf") for m in special])

        # Exact vs uncertain
        n_exact = sum(1 for m in special if m.exact_or_uncertain == "exact")
        print(f"  exact treewidth: {n_exact}/{len(special)}")

        # Width distribution
        widths = [m.upper_bound_best for m in special]
        width_counts = defaultdict(int)
        for w in widths:
            width_counts[w] += 1
        print(f"  width histogram: {dict(sorted(width_counts.items()))}")

        # Correlation: ub_best vs search_nodes
        nodes_and_width = [(m.upper_bound_best, m.search_nodes_2b3, m.n)
                           for m in special if m.search_nodes_2b3 is not None]
        if nodes_and_width:
            print()
            print("--- CORRELATION: width vs search_nodes ---")
            # Group by width bucket
            by_width: dict[int, list] = defaultdict(list)
            for w, nodes, n in nodes_and_width:
                by_width[w].append((nodes, n))
            for w in sorted(by_width):
                entries = by_width[w]
                avg_nodes = statistics.mean(e[0] for e in entries)
                avg_n = statistics.mean(e[1] for e in entries)
                print(f"  width={w}: {len(entries)} cases, avg_n={avg_n:.1f}, avg_nodes={avg_nodes:.0f}, 2^w={2**w}")

        # Top-cost cases
        by_cost = sorted(
            [m for m in special if m.search_nodes_2b3 is not None],
            key=lambda m: -m.search_nodes_2b3,
        )
        if by_cost:
            print()
            print("--- TOP 10 MOST EXPENSIVE SPECIAL COMPONENTS ---")
            print(f"  {'case_id':20} {'n':3} {'constraints':3} {'ub_mf':5} {'ub_md':5} {'ub_best':7} {'lb':2} {'exact':5} {'2^ub':6} {'nodes':6} {'ratio_n/ub':10}")
            for m in by_cost[:10]:
                print(
                    f"  {m.case_id:20} {m.n:3} {m.num_constraints:3} "
                    f"{m.upper_bound_min_fill:5} {m.upper_bound_min_degree:5} "
                    f"{m.upper_bound_best:7} {m.lower_bound_clique:2} "
                    f"{m.exact_or_uncertain == 'exact':5} "
                    f"{2**m.upper_bound_best:6} {m.search_nodes_2b3:6} "
                    f"{m.n/m.upper_bound_best if m.upper_bound_best else 0:10.1f}"
                )

        # Interesting structural cases
        large_low_width = [m for m in special if m.n >= 20 and m.upper_bound_best <= 6]
        if large_low_width:
            print()
            print(f"--- LARGE BUT LOW WIDTH (n>=20, ub<=6): {len(large_low_width)} cases ---")
            for m in sorted(large_low_width, key=lambda x: -x.n)[:5]:
                print(f"  {m.case_id}: n={m.n} ub={m.upper_bound_best} lb={m.lower_bound_clique} nodes={m.search_nodes_2b3}")

        # 12x12 phase evolution
        if dataset == "12x12_20":
            print()
            print("--- PHASE EVOLUTION (12x12 special components) ---")
            print(f"  {'phase':6} {'count':6} {'n_mean':7} {'n_p50':7} {'n_max':7} {'ub_mean':8} {'ub_p50':8} {'ub_max':8} {'ub/n_mean':9}")
            for phase in ("early", "mid", "late"):
                ph = [m for m in special if m.phase == phase]
                if not ph:
                    continue
                ns = [m.n for m in ph]
                ubs = [m.upper_bound_best for m in ph]
                ratios = [m.upper_bound_best / m.n for m in ph if m.n]
                print(
                    f"  {phase:6} {len(ph):6} {statistics.mean(ns):7.1f} "
                    f"{statistics.median(ns):7.1f} {max(ns):7} "
                    f"{statistics.mean(ubs):8.2f} {statistics.median(ubs):8.1f} "
                    f"{max(ubs):8} {statistics.mean(ratios):9.3f}"
                )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    scripts_dir = Path(__file__).resolve().parent
    repo_root = scripts_dir.parent

    corpus_path = repo_root / "benchmarks" / "conditional-sampling-2a-corpus-20260830.jsonl"
    b3_bench_path = repo_root / "benchmarks" / "conditional-sampling-2b3-shared-outcomes-20260830.jsonl"
    histories_path = repo_root / "benchmarks" / "conditional-sampling-2d-histories-smoke-20260830.jsonl"
    d_bench_path = repo_root / "benchmarks" / "conditional-sampling-2d-smoke-20260830.jsonl"

    print("Analyzing 30x16/99 corpus...", flush=True)
    corpus_metrics = analyze_corpus(corpus_path, b3_bench_path)
    print(f"  {len(corpus_metrics)} components from {len(set(m.case_id for m in corpus_metrics))} cases")

    print("Analyzing 12x12/20 histories...", flush=True)
    history_metrics = analyze_histories(histories_path, d_bench_path)
    print(f"  {len(history_metrics)} components from {len(set(m.case_id for m in history_metrics))} steps")

    all_metrics = corpus_metrics + history_metrics

    # Save raw JSONL
    out_path = repo_root / "benchmarks" / "conditional-sampling-treewidth-prestudy-20260830.jsonl"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        for m in all_metrics:
            f.write(json.dumps(m._asdict(), sort_keys=True) + "\n")
    print(f"  Raw saved: {out_path}")

    print_report(all_metrics)


if __name__ == "__main__":
    main()
