# Square 9×9/13 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 4487 |
| CELL states totales | 55386 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 3.1 |
| Media cells/partida | 36.9 |
| Media elapsed/partida | 0.027s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 17 | 23 | 25 | 29 | 39 | 189 |
| total_constr | 0 | 18 | 37 | 41 | 48 | 64 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 2 | 3 | 6 | 8 |
| max_sp_size | 0 | 9 | 21 | 23 | 28 | 39 | — |
| sum_ord_size | 0 | 2 | 17 | 20 | 25 | 39 | — |
| max_ord_internal_w | 0 | 1 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 30 | 61 | 66 | 72 | 75 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 39 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 634 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 32 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 12134 | 21.9% |
| 1 | 2789 | 5.0% |
| 2 | 3035 | 5.5% |
| 3 | 5509 | 9.9% |
| 4 | 24673 | 44.5% |
| 5 | 6061 | 10.9% |
| 6 | 1092 | 2.0% |
| 7 | 93 | 0.2% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 853 | 0 | s00853g0f01 | 3 | **39** | 6 | 1 | 39 | 0 |
| 871 | 0 | s00871g0f00 | 4 | **37** | 5 | 1 | 37 | 0 |
| 753 | 0 | s00753g0f02 | 3 | **36** | 6 | 1 | 36 | 0 |
| 756 | 0 | s00756g0f00 | 3 | **36** | 5 | 1 | 36 | 0 |
| 661 | 0 | s00661g0f00 | 2 | **35** | 5 | 1 | 35 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 535 | 0 | s00535g0f01 | 3 | **7** | 29 | 29 | 0 |
| 535 | 0 | s00535g0f01 | 8 | **7** | 27 | 27 | 0 |
| 551 | 0 | s00551g0f00 | 3 | **7** | 26 | 26 | 0 |
| 551 | 0 | s00551g0f00 | 14 | **7** | 26 | 26 | 0 |
| 551 | 0 | s00551g0f00 | 8 | **7** | 25 | 25 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 535 | 0 | s00535g0f01 | 1 | **7** | 28 | 0 | 0 |
| 535 | 0 | s00535g0f01 | 2 | **7** | 29 | 0 | 0 |
| 535 | 0 | s00535g0f01 | 4 | **7** | 29 | 0 | 0 |
| 535 | 0 | s00535g0f01 | 5 | **7** | 27 | 0 | 0 |
| 535 | 0 | s00535g0f01 | 6 | **7** | 29 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 853 | 0 | s00853g0f01 | 2 | **39** | 6 | 0 | 0 |
| 853 | 0 | s00853g0f01 | 3 | **39** | 0 | 1 | 39 |
| 853 | 0 | s00853g0f01 | 4 | **39** | 6 | 0 | 0 |
| 606 | 0 | s00606g0f01 | 1 | **38** | 5 | 0 | 0 |
| 606 | 0 | s00606g0f01 | 2 | **38** | 5 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 500 | 1 | s00500g1f00 | 1 | **75** | 0 | 0 | 13 |
| 503 | 1 | s00503g1f00 | 1 | **75** | 0 | 0 | 13 |
| 505 | 1 | s00505g1f00 | 1 | **75** | 0 | 0 | 13 |
| 506 | 1 | s00506g1f00 | 1 | **75** | 0 | 0 | 13 |
| 507 | 1 | s00507g1f00 | 1 | **75** | 0 | 0 | 13 |

## Candidatos Cairo (126 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 853 | 0 | s00853g0f01 | 3 | 39 | 6 | 0 | 39 | sum_ord_size |
| 2 | 871 | 0 | s00871g0f00 | 4 | 37 | 5 | 0 | 37 | sum_ord_size |
| 3 | 753 | 0 | s00753g0f02 | 3 | 36 | 6 | 0 | 36 | sum_ord_size |
| 4 | 756 | 0 | s00756g0f00 | 3 | 36 | 5 | 0 | 36 | sum_ord_size |
| 5 | 661 | 0 | s00661g0f00 | 2 | 35 | 5 | 0 | 35 | sum_ord_size |
| 6 | 816 | 0 | s00816g0f01 | 3 | 35 | 5 | 0 | 35 | sum_ord_size |
| 7 | 526 | 0 | s00526g0f01 | 4 | 34 | 5 | 0 | 34 | sum_ord_size |
| 8 | 541 | 0 | s00541g0f02 | 3 | 34 | 5 | 0 | 34 | sum_ord_size |
| 9 | 542 | 0 | s00542g0f01 | 2 | 34 | 6 | 0 | 34 | sum_ord_size |
| 10 | 542 | 0 | s00542g0f01 | 3 | 34 | 6 | 0 | 34 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 9×9/13 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 39 | 86 | 189 | 0.21× |
| sum_ord_size | 39 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 75 | — | 474 | 0.16× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-9x9-13-cells-20260901.jsonl` | 55386 CELL rows |
| `benchmarks/square-9x9-13-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-9x9-13-analysis-20260901.md` | Este informe |
| `benchmarks/square-9x9-13-candidates-20260901.jsonl` | 126 candidatos Cairo |
