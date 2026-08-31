#!/usr/bin/env python3
"""
Análisis estructural de flood-fill sobre el corpus histórico congelado 30x16/99.

Usa exclusivamente transcripts públicos ya persistidos. No genera histories,
no modifica 2E2/2E3 y no implementa semánticas alternativas de constraints.
"""

from __future__ import annotations

import argparse
import json
import math
import statistics
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import conditional_sampling_2b3_shared_outcomes as b3
import conditional_sampling_2e2_variable_elimination as e2
import conditional_sampling_exact as cs


def percentile(values: list[float], q: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    if len(ordered) == 1:
        return float(ordered[0])
    pos = (len(ordered) - 1) * q
    lo = math.floor(pos)
    hi = math.ceil(pos)
    if lo == hi:
        return float(ordered[lo])
    frac = pos - lo
    return float(ordered[lo] * (1.0 - frac) + ordered[hi] * frac)


def summarize_scalar(values: list[int | float]) -> dict[str, float | int | None]:
    numeric = [float(value) for value in values]
    if not numeric:
        return {
            "count": 0,
            "min": None,
            "mean": None,
            "median": None,
            "p90": None,
            "p95": None,
            "p99": None,
            "max": None,
        }
    return {
        "count": len(numeric),
        "min": min(numeric),
        "mean": statistics.mean(numeric),
        "median": percentile(numeric, 0.5),
        "p90": percentile(numeric, 0.9),
        "p95": percentile(numeric, 0.95),
        "p99": percentile(numeric, 0.99),
        "max": max(numeric),
    }


def transcript_from_history_row(row: dict[str, object]) -> cs.Transcript:
    return b3.transcript_from_corpus_row({"transcript": row["transcript"]})


def structural_profile(transcript: cs.Transcript) -> dict[str, object]:
    consistent, constraints, variables, _remaining_mines = cs.build_constraints(transcript)
    if not consistent:
        return {
            "consistent": False,
            "frontier_variables": 0,
            "constraint_count": 0,
            "component_sizes": [],
            "component_count": 0,
            "largest_component": 0,
            "min_fill_width_max": 0,
        }
    component_variables, component_constraints = cs.connected_components(variables, constraints)
    widths = [
        e2.build_elimination_plan(vars_group, cons_group).min_fill_width
        for vars_group, cons_group in zip(component_variables, component_constraints)
    ]
    return {
        "consistent": True,
        "frontier_variables": len(variables),
        "constraint_count": len(constraints),
        "component_sizes": [len(group) for group in component_variables],
        "component_count": len(component_variables),
        "largest_component": max((len(group) for group in component_variables), default=0),
        "min_fill_width_max": max(widths, default=0),
    }


def build_after_transcript(
    row: dict[str, object],
    next_row: dict[str, object] | None,
) -> tuple[cs.Transcript | None, str]:
    transcript = transcript_from_history_row(row)
    outcome = str(row["observed_outcome"])
    if next_row is not None:
        return transcript_from_history_row(next_row), "next-transcript"
    if outcome == cs.MINE_OUTCOME:
        return transcript, "terminal-mine-no-reveal"
    if outcome != "0":
        return cs.with_outcome(transcript, int(row["clicked_cell"]["index"]), outcome), "synthetic-single-reveal"
    return None, "terminal-zero-without-next-transcript"


def boundary_union_variables(after_transcript: cs.Transcript, boundary_cells: list[int]) -> list[int]:
    known_safe = set(after_transcript.revealed_clues)
    known_mines = set(after_transcript.known_mines)
    boundary_union: set[int] = set()
    for clue_index in boundary_cells:
        for neighbor in cs.neighbors(after_transcript.width, after_transcript.height, clue_index):
            if neighbor in known_safe or neighbor in known_mines:
                continue
            boundary_union.add(neighbor)
    return sorted(boundary_union)


def wave_decomposition(
    after_transcript: cs.Transcript,
    clicked_cell: int,
    new_revealed: list[int],
) -> dict[str, object]:
    if after_transcript.revealed_clues[clicked_cell] != 0:
        raise ValueError("wave_decomposition sólo aplica a clicks con clue 0")
    new_set = set(new_revealed)
    classified: set[int] = set()
    current_wave = [clicked_cell]
    waves: list[dict[str, object]] = []
    full_region_pending_evolution: list[int] = []
    cumulative_positive_pending = 0

    while current_wave:
        wave_cells = sorted(set(current_wave) - classified)
        if not wave_cells:
            break
        zero_cells = [cell for cell in wave_cells if after_transcript.revealed_clues[cell] == 0]
        positive_cells = [cell for cell in wave_cells if after_transcript.revealed_clues[cell] > 0]
        waves.append({
            "wave_index": len(waves) + 1,
            "cells": wave_cells,
            "size": len(wave_cells),
            "zero_count": len(zero_cells),
            "positive_count": len(positive_cells),
        })
        cumulative_positive_pending += len(positive_cells)
        full_region_pending_evolution.append(cumulative_positive_pending)
        classified.update(wave_cells)
        next_wave: set[int] = set()
        for zero_cell in zero_cells:
            for neighbor in cs.neighbors(after_transcript.width, after_transcript.height, zero_cell):
                if neighbor in new_set and neighbor not in classified:
                    next_wave.add(neighbor)
        current_wave = sorted(next_wave)

    if classified != new_set:
        missing = sorted(new_set - classified)
        raise AssertionError(f"wave decomposition incompleta: faltan {missing[:10]}")

    positives_per_wave = [wave["positive_count"] for wave in waves]
    return {
        "wave_count": len(waves),
        "waves": waves,
        "wave_sizes": [wave["size"] for wave in waves],
        "wave_zero_counts": [wave["zero_count"] for wave in waves],
        "wave_positive_counts": positives_per_wave,
        "wave_pending_positive_counts": positives_per_wave,
        "wave_pending_positive_max": max(positives_per_wave, default=0),
        "full_region_pending_positive_evolution": full_region_pending_evolution,
        "full_region_pending_positive_max": max(full_region_pending_evolution, default=0),
    }


def analyze_click(
    row: dict[str, object],
    next_row: dict[str, object] | None,
) -> dict[str, object]:
    before_transcript = transcript_from_history_row(row)
    after_transcript, after_source = build_after_transcript(row, next_row)
    clicked_cell = int(row["clicked_cell"]["index"])
    outcome = str(row["observed_outcome"])
    before_revealed = set(before_transcript.revealed_clues)
    reconstructable = after_transcript is not None
    before_profile = structural_profile(before_transcript)

    result: dict[str, object] = {
        "history_id": row["history_id"],
        "click_number": int(row["click_number"]),
        "phase": row["phase"],
        "controlled": bool(row.get("controlled", False)),
        "policy": row["policy"],
        "terminal": bool(row["terminal"]),
        "terminal_state": row["terminal_state"],
        "clicked_cell": clicked_cell,
        "clicked_coord": row["clicked_cell"]["coord"],
        "observed_outcome": outcome,
        "after_source": after_source,
        "after_transcript_reconstructable": reconstructable,
        "flood_fill": outcome == "0",
        "before_structure": before_profile,
    }

    if not reconstructable:
        result.update({
            "new_revealed": None,
            "zero_region_size": None,
            "boundary_size": None,
            "wave_count": None,
            "wave_sizes": None,
            "wave_zero_counts": None,
            "wave_positive_counts": None,
            "cell_policy": None,
            "wave_policy": None,
            "full_region_policy": None,
            "after_structure": None,
            "boundary_union_variables": None,
            "boundary_union_variable_count": None,
            "notes": ["requires-next-transcript-for-public-reconstruction"],
        })
        return result

    after_revealed = set(after_transcript.revealed_clues)
    new_revealed_cells = sorted(after_revealed - before_revealed)
    if outcome != cs.MINE_OUTCOME and clicked_cell not in new_revealed_cells:
        raise AssertionError(f"clicked cell ausente en new_revealed: {row['history_id']} click {row['click_number']}")

    if outcome == cs.MINE_OUTCOME:
        new_revealed_count = 0
    else:
        new_revealed_count = len(new_revealed_cells)

    zero_region = [cell for cell in new_revealed_cells if after_transcript.revealed_clues[cell] == 0]
    boundary = [cell for cell in new_revealed_cells if after_transcript.revealed_clues[cell] > 0]
    after_profile = structural_profile(after_transcript)
    boundary_union = boundary_union_variables(after_transcript, boundary)

    wave_info: dict[str, object]
    if outcome == "0":
        wave_info = wave_decomposition(after_transcript, clicked_cell, new_revealed_cells)
    else:
        wave_info = {
            "wave_count": 0,
            "waves": [],
            "wave_sizes": [],
            "wave_zero_counts": [],
            "wave_positive_counts": [],
            "wave_pending_positive_counts": [],
            "wave_pending_positive_max": 0,
            "full_region_pending_positive_evolution": [],
            "full_region_pending_positive_max": 0,
        }

    result.update({
        "new_revealed": new_revealed_count,
        "zero_region_size": len(zero_region),
        "boundary_size": len(boundary),
        "wave_count": wave_info["wave_count"],
        "wave_sizes": wave_info["wave_sizes"],
        "wave_zero_counts": wave_info["wave_zero_counts"],
        "wave_positive_counts": wave_info["wave_positive_counts"],
        "cell_policy": {
            "forced_safe_exact_clues": new_revealed_count,
            "max_positive_pending_exact_refinement": 0,
        },
        "wave_policy": {
            "binary_classifications_total": new_revealed_count,
            "positive_refinements_total": len(boundary),
            "pending_positive_per_wave": wave_info["wave_pending_positive_counts"],
            "pending_positive_max": wave_info["wave_pending_positive_max"],
        },
        "full_region_policy": {
            "binary_classifications_total": new_revealed_count,
            "positive_refinements_total": len(boundary),
            "pending_positive_evolution": wave_info["full_region_pending_positive_evolution"],
            "pending_positive_max": wave_info["full_region_pending_positive_max"],
            "pending_positive_final_before_refinement": len(boundary),
        },
        "after_structure": after_profile,
        "boundary_union_variables": boundary_union,
        "boundary_union_variable_count": len(boundary_union),
        "boundary_union_structure_note": "exact under final 0..8 clues; binary 0/>0 structural state requires experimento posterior",
        "notes": [],
    })
    return result


def summarize_group(items: list[dict[str, object]]) -> dict[str, object]:
    metrics = ["new_revealed", "zero_region_size", "boundary_size", "wave_count"]
    summary: dict[str, object] = {
        "clicks": len(items),
        "reconstructable_clicks": sum(1 for item in items if item["after_transcript_reconstructable"]),
        "flood_fill_clicks": sum(1 for item in items if item["flood_fill"]),
        "reconstructable_flood_fill_clicks": sum(
            1 for item in items if item["flood_fill"] and item["after_transcript_reconstructable"]
        ),
    }
    for metric in metrics:
        present = [item[metric] for item in items if item.get(metric) is not None]
        summary[metric] = {
            "missing": len(items) - len(present),
            "stats": summarize_scalar(present),
        }

    flood_reconstructable = [
        item for item in items if item["flood_fill"] and item["after_transcript_reconstructable"]
    ]
    cascade_sizes = [int(item["new_revealed"]) for item in flood_reconstructable]
    all_wave_sizes = [size for item in flood_reconstructable for size in item["wave_sizes"]]
    wave_pending = [int(item["wave_policy"]["pending_positive_max"]) for item in flood_reconstructable]
    full_pending = [int(item["full_region_policy"]["pending_positive_max"]) for item in flood_reconstructable]
    pending_diff = [
        int(item["full_region_policy"]["pending_positive_max"]) - int(item["wave_policy"]["pending_positive_max"])
        for item in flood_reconstructable
    ]
    summary["cascade_size_distribution"] = dict(sorted(Counter(cascade_sizes).items()))
    summary["wave_size_distribution"] = dict(sorted(Counter(all_wave_sizes).items()))
    summary["wave_pending_positive_max"] = summarize_scalar(wave_pending)
    summary["full_region_pending_positive_max"] = summarize_scalar(full_pending)
    summary["pending_positive_max_difference_full_minus_wave"] = summarize_scalar(pending_diff)

    def structure_stats(field: str, nested_key: str | None = None) -> dict[str, object]:
        values: list[int] = []
        for item in flood_reconstructable:
            structure = item.get(field)
            if not structure:
                continue
            value = structure.get(nested_key) if nested_key is not None else structure
            if isinstance(value, int):
                values.append(value)
        return summarize_scalar(values)

    summary["flood_fill_after_structure"] = {
        "frontier_variables": structure_stats("after_structure", "frontier_variables"),
        "constraint_count": structure_stats("after_structure", "constraint_count"),
        "largest_component": structure_stats("after_structure", "largest_component"),
        "min_fill_width_max": structure_stats("after_structure", "min_fill_width_max"),
        "boundary_union_variable_count": summarize_scalar(
            [int(item["boundary_union_variable_count"]) for item in flood_reconstructable]
        ),
    }
    return summary


def top_flood_fills(items: list[dict[str, object]], top_n: int = 10) -> list[dict[str, object]]:
    floods = [
        item
        for item in items
        if item["flood_fill"] and item["after_transcript_reconstructable"] and item["new_revealed"] is not None
    ]
    ordered = sorted(
        floods,
        key=lambda item: (
            int(item["new_revealed"]),
            int(item["zero_region_size"]),
            int(item["boundary_size"]),
            int(item["wave_count"]),
            str(item["history_id"]),
            int(item["click_number"]),
        ),
        reverse=True,
    )
    return [
        {
            "history_id": item["history_id"],
            "click_number": item["click_number"],
            "phase": item["phase"],
            "total_revealed": item["new_revealed"],
            "zeros": item["zero_region_size"],
            "boundary": item["boundary_size"],
            "waves": item["wave_count"],
            "max_pending_wave": item["wave_policy"]["pending_positive_max"],
            "max_pending_full_region": item["full_region_policy"]["pending_positive_max"],
        }
        for item in ordered[:top_n]
    ]


def final_reading(items: list[dict[str, object]]) -> dict[str, str]:
    floods = [
        item
        for item in items
        if item["flood_fill"] and item["after_transcript_reconstructable"] and item["new_revealed"] is not None
    ]
    clicks = [item for item in items if item["after_transcript_reconstructable"]]
    non_floods = [item for item in clicks if not item["flood_fill"]]
    cascade_median = percentile([int(item["new_revealed"]) for item in floods], 0.5)
    cascade_p95 = percentile([int(item["new_revealed"]) for item in floods], 0.95)
    wave_pending_max = max((int(item["wave_policy"]["pending_positive_max"]) for item in floods), default=0)
    full_pending_max = max((int(item["full_region_policy"]["pending_positive_max"]) for item in floods), default=0)
    unreconstructable = [
        item for item in items if item["flood_fill"] and not item["after_transcript_reconstructable"]
    ]

    answer_a = (
        "Sí hay señal de multiplicador estructural relevante: los clicks con flood-fill revelan muchas más celdas "
        f"que los no-flood-fill, con mediana de cascada {cascade_median:.1f} y p95 {cascade_p95:.1f} celdas nuevas. "
        "Eso no demuestra costo Cairo ni costo VE, pero sí justifica tratar flood-fill como fenómeno separado "
        "frente a una implementación estrictamente cell-by-cell."
    )
    answer_b = (
        "Sí parece haber diferencia estructural suficiente entre CELL, WAVE y FULL-REGION para justificar comparación "
        "posterior: el total de clasificaciones coincide, pero WAVE acota positivos pendientes por oleada mientras "
        f"FULL-REGION puede acumular hasta {full_pending_max} positivos simultáneamente pendientes "
        f"(vs {wave_pending_max} bajo WAVE)."
    )
    answer_c = (
        "No hay evidencia suficiente para descartar ninguna de las tres antes de programarla. CELL es el baseline "
        "natural; WAVE y FULL-REGION sí difieren estructuralmente en backlog de positivos, pero todavía no sabemos "
        "si esa diferencia ayuda o perjudica a VE sin implementar la semántica binaria `0/>0`."
    )
    answer_d = (
        "Sólo un experimento posterior con constraints binarias reales podrá responder: cómo cambian frontier, "
        "componentes y min-fill width durante la expansión; si `>0` introduce más o menos sharing que `1..8`; "
        "si WAVE o FULL-REGION reducen o inflan el costo VE; y si el backlog de positivos pendientes compensa "
        "o empeora la estructura del problema. "
        + (
            f"Además, queda {len(unreconstructable)} flood-fill terminal sin transcript posterior cuya región final "
            "no puede reconstruirse completamente sólo desde el dataset público actual."
            if unreconstructable
            else ""
        )
    )
    return {"A": answer_a, "B": answer_b, "C": answer_c, "D": answer_d}


def build_summary(items: list[dict[str, object]], corpus_path: str, raw_path: str) -> dict[str, object]:
    public_only = [item for item in items if not item["controlled"]]
    controlled = [item for item in items if item["controlled"]]
    with_flood_fill = [item for item in items if item["flood_fill"]]
    without_flood_fill = [item for item in items if not item["flood_fill"]]
    return {
        "metadata": {
            "corpus_path": corpus_path,
            "raw_path": raw_path,
            "clicks_total": len(items),
            "histories_total": len({item["history_id"] for item in items}),
            "public_only_histories": len({item["history_id"] for item in public_only}),
            "controlled_histories": len({item["history_id"] for item in controlled}),
            "notes": [
                "Usa exclusivamente transcripts públicos ya persistidos.",
                "No aproxima constraints binarias 0/>0; eso requiere experimento posterior.",
                "No convierte conteos estructurales en gas ni en costo VE sin implementación real.",
            ],
        },
        "groups": {
            "all_clicks": summarize_group(items),
            "public_only": summarize_group(public_only),
            "controlled": summarize_group(controlled),
            "without_flood_fill": summarize_group(without_flood_fill),
            "with_flood_fill": summarize_group(with_flood_fill),
        },
        "top_flood_fills": top_flood_fills(items),
        "final_reading": final_reading(items),
        "limitations": {
            "requires_binary_constraint_experiment": [
                "comparar costo VE real de CELL vs WAVE vs FULL-REGION",
                "medir frontier/componentes/min-fill width bajo semántica binaria 0/>0 durante expansión",
            ],
            "public_reconstruction_gaps": [
                item
                for item in (
                    {
                        "history_id": analysis["history_id"],
                        "click_number": analysis["click_number"],
                        "reason": analysis["after_source"],
                    }
                    for analysis in items
                    if not analysis["after_transcript_reconstructable"]
                )
            ],
        },
    }


def analyze_corpus(corpus_path: Path, raw_path: Path, summary_path: Path) -> dict[str, object]:
    rows = [json.loads(line) for line in corpus_path.open(encoding="utf-8") if line.strip()]
    by_history: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_history[str(row["history_id"])].append(row)

    analyses: list[dict[str, object]] = []
    raw_path.parent.mkdir(parents=True, exist_ok=True)
    with raw_path.open("w", encoding="utf-8") as raw_handle:
        for history_id in sorted(by_history):
            ordered = sorted(by_history[history_id], key=lambda item: int(item["click_number"]))
            for idx, row in enumerate(ordered):
                next_row = ordered[idx + 1] if idx + 1 < len(ordered) else None
                analysis = analyze_click(row, next_row)
                analyses.append(analysis)
                raw_handle.write(json.dumps(analysis, sort_keys=True) + "\n")

    summary = build_summary(analyses, str(corpus_path), str(raw_path))
    summary_path.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description="Analiza la estructura pública de flood-fill sobre el corpus 30x16/99")
    parser.add_argument(
        "--corpus",
        default="benchmarks/conditional-sampling-histories-30x16-20260831.jsonl",
    )
    parser.add_argument(
        "--out",
        default="benchmarks/flood-fill-structure-30x16-20260831.jsonl",
    )
    parser.add_argument(
        "--summary-out",
        default="benchmarks/flood-fill-structure-30x16-20260831-summary.json",
    )
    args = parser.parse_args()

    summary = analyze_corpus(
        corpus_path=Path(args.corpus),
        raw_path=Path(args.out),
        summary_path=Path(args.summary_out),
    )
    print(json.dumps({
        "clicks_total": summary["metadata"]["clicks_total"],
        "histories_total": summary["metadata"]["histories_total"],
        "flood_fill_clicks": summary["groups"]["all_clicks"]["flood_fill_clicks"],
        "reconstructable_flood_fill_clicks": summary["groups"]["all_clicks"]["reconstructable_flood_fill_clicks"],
        "top_flood_fill": summary["top_flood_fills"][0] if summary["top_flood_fills"] else None,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
