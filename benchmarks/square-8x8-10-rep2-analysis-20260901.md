# Square 8×8/10 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 3915 |
| CELL states totales | 44234 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 2.7 |
| Media cells/partida | 29.5 |
| Media elapsed/partida | 0.022s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 14 | 20 | 21 | 25 | 33 | 189 |
| total_constr | 0 | 14 | 29 | 32 | 37 | 48 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 2 | 3 | 5 | 8 |
| max_sp_size | 0 | 8 | 18 | 20 | 25 | 33 | — |
| sum_ord_size | 0 | 1 | 14 | 17 | 22 | 33 | — |
| max_ord_internal_w | 0 | 0 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 22 | 46 | 52 | 56 | 58 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 33 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 499 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 8 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 10703 | 24.2% |
| 1 | 2345 | 5.3% |
| 2 | 2539 | 5.7% |
| 3 | 5186 | 11.7% |
| 4 | 18541 | 41.9% |
| 5 | 3922 | 8.9% |
| 6 | 963 | 2.2% |
| 7 | 35 | 0.1% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 602 | 0 | s00602g0f01 | 3 | **33** | 6 | 1 | 33 | 0 |
| 838 | 0 | s00838g0f00 | 4 | **32** | 5 | 1 | 32 | 0 |
| 529 | 0 | s00529g0f00 | 3 | **31** | 6 | 1 | 31 | 0 |
| 602 | 0 | s00602g0f01 | 5 | **30** | 6 | 1 | 30 | 0 |
| 602 | 0 | s00602g0f01 | 6 | **30** | 6 | 1 | 30 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 965 | 0 | s00965g0f00 | 18 | **7** | 24 | 24 | 0 |
| 710 | 0 | s00710g0f00 | 3 | **7** | 23 | 23 | 0 |
| 710 | 0 | s00710g0f00 | 14 | **7** | 22 | 22 | 0 |
| 710 | 0 | s00710g0f00 | 15 | **7** | 22 | 22 | 0 |
| 965 | 0 | s00965g0f00 | 17 | **7** | 21 | 24 | 2 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 612 | 2 | s00612g2f01 | 1 | **7** | 15 | 0 | 0 |
| 612 | 2 | s00612g2f01 | 2 | **7** | 19 | 0 | 0 |
| 612 | 2 | s00612g2f01 | 3 | **7** | 19 | 0 | 0 |
| 612 | 2 | s00612g2f01 | 4 | **7** | 17 | 0 | 0 |
| 710 | 0 | s00710g0f00 | 1 | **7** | 22 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 602 | 0 | s00602g0f01 | 2 | **33** | 6 | 0 | 0 |
| 602 | 0 | s00602g0f01 | 3 | **33** | 0 | 1 | 33 |
| 602 | 0 | s00602g0f01 | 4 | **33** | 6 | 0 | 0 |
| 602 | 0 | s00602g0f01 | 1 | **32** | 6 | 0 | 0 |
| 608 | 0 | s00608g0f00 | 5 | **32** | 5 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 500 | 1 | s00500g1f00 | 1 | **58** | 0 | 0 | 10 |
| 501 | 1 | s00501g1f00 | 1 | **58** | 0 | 0 | 10 |
| 502 | 1 | s00502g1f00 | 1 | **58** | 0 | 0 | 10 |
| 505 | 1 | s00505g1f00 | 1 | **58** | 0 | 0 | 10 |
| 506 | 1 | s00506g1f00 | 1 | **58** | 0 | 0 | 10 |

## Candidatos Cairo (111 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 602 | 0 | s00602g0f01 | 3 | 33 | 6 | 0 | 33 | sum_ord_size |
| 2 | 838 | 0 | s00838g0f00 | 4 | 32 | 5 | 0 | 32 | sum_ord_size |
| 3 | 529 | 0 | s00529g0f00 | 3 | 31 | 6 | 0 | 31 | sum_ord_size |
| 4 | 602 | 0 | s00602g0f01 | 5 | 30 | 6 | 0 | 30 | sum_ord_size |
| 5 | 602 | 0 | s00602g0f01 | 6 | 30 | 6 | 0 | 30 | sum_ord_size |
| 6 | 661 | 0 | s00661g0f01 | 2 | 30 | 5 | 0 | 30 | sum_ord_size |
| 7 | 661 | 0 | s00661g0f01 | 3 | 30 | 5 | 0 | 30 | sum_ord_size |
| 8 | 661 | 0 | s00661g0f01 | 4 | 30 | 5 | 0 | 30 | sum_ord_size |
| 9 | 509 | 0 | s00509g0f00 | 3 | 29 | 5 | 0 | 29 | sum_ord_size |
| 10 | 543 | 0 | s00543g0f01 | 3 | 29 | 5 | 0 | 29 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 8×8/10 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 33 | 86 | 189 | 0.17× |
| sum_ord_size | 33 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 58 | — | 474 | 0.12× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-8x8-10-cells-20260901.jsonl` | 44234 CELL rows |
| `benchmarks/square-8x8-10-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-8x8-10-analysis-20260901.md` | Este informe |
| `benchmarks/square-8x8-10-candidates-20260901.jsonl` | 111 candidatos Cairo |
