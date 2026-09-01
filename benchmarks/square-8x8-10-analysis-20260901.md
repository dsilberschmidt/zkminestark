# Square 8×8/10 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 3940 |
| CELL states totales | 43642 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 2.7 |
| Media cells/partida | 29.1 |
| Media elapsed/partida | 0.018s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 13 | 19 | 21 | 25 | 33 | 189 |
| total_constr | 0 | 14 | 29 | 33 | 38 | 49 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 2 | 3 | 6 | 8 |
| max_sp_size | 0 | 7 | 18 | 20 | 24 | 33 | — |
| sum_ord_size | 0 | 1 | 14 | 17 | 21 | 33 | — |
| max_ord_internal_w | 0 | 0 | 4 | 5 | 5 | 7 | — |
| unc_other | 0 | 22 | 47 | 52 | 56 | 58 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 33 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 384 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 0 | patrón Expert | OK |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 10954 | 25.1% |
| 1 | 2410 | 5.5% |
| 2 | 2620 | 6.0% |
| 3 | 4981 | 11.4% |
| 4 | 18199 | 41.7% |
| 5 | 3776 | 8.7% |
| 6 | 668 | 1.5% |
| 7 | 34 | 0.1% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 454 | 0 | s00454g0f00 | 4 | **33** | 6 | 1 | 33 | 0 |
| 251 | 0 | s00251g0f00 | 2 | **31** | 6 | 1 | 31 | 0 |
| 454 | 0 | s00454g0f00 | 7 | **30** | 6 | 1 | 30 | 0 |
| 454 | 0 | s00454g0f00 | 8 | **30** | 6 | 1 | 30 | 0 |
| 473 | 0 | s00473g0f00 | 3 | **30** | 7 | 1 | 30 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 473 | 0 | s00473g0f00 | 3 | **7** | 30 | 30 | 0 |
| 266 | 0 | s00266g0f01 | 3 | **7** | 25 | 25 | 0 |
| 473 | 0 | s00473g0f00 | 12 | **7** | 25 | 25 | 0 |
| 473 | 0 | s00473g0f00 | 13 | **7** | 25 | 25 | 0 |
| 70 | 0 | s00070g0f00 | 15 | **7** | 20 | 20 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 70 | 0 | s00070g0f00 | 1 | **7** | 19 | 0 | 0 |
| 70 | 0 | s00070g0f00 | 2 | **7** | 23 | 0 | 0 |
| 70 | 0 | s00070g0f00 | 3 | **7** | 23 | 0 | 0 |
| 70 | 0 | s00070g0f00 | 4 | **7** | 24 | 0 | 0 |
| 70 | 0 | s00070g0f00 | 5 | **7** | 26 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 90 | 0 | s00090g0f00 | 1 | **33** | 5 | 0 | 0 |
| 90 | 0 | s00090g0f00 | 2 | **33** | 5 | 0 | 0 |
| 219 | 0 | s00219g0f00 | 1 | **33** | 6 | 0 | 0 |
| 454 | 0 | s00454g0f00 | 3 | **33** | 6 | 0 | 0 |
| 454 | 0 | s00454g0f00 | 4 | **33** | 0 | 1 | 33 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **58** | 0 | 0 | 10 |
| 1 | 1 | s00001g1f00 | 1 | **58** | 0 | 0 | 10 |
| 2 | 1 | s00002g1f00 | 1 | **58** | 0 | 0 | 10 |
| 11 | 1 | s00011g1f00 | 1 | **58** | 0 | 0 | 10 |
| 13 | 1 | s00013g1f00 | 1 | **58** | 0 | 0 | 10 |

## Candidatos Cairo (104 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 454 | 0 | s00454g0f00 | 4 | 33 | 6 | 0 | 33 | sum_ord_size |
| 2 | 251 | 0 | s00251g0f00 | 2 | 31 | 6 | 0 | 31 | sum_ord_size |
| 3 | 454 | 0 | s00454g0f00 | 7 | 30 | 6 | 0 | 30 | sum_ord_size |
| 4 | 454 | 0 | s00454g0f00 | 8 | 30 | 6 | 0 | 30 | sum_ord_size |
| 5 | 473 | 0 | s00473g0f00 | 3 | 30 | 7 | 0 | 30 | sum_ord_size |
| 6 | 59 | 0 | s00059g0f01 | 3 | 29 | 4 | 0 | 29 | sum_ord_size |
| 7 | 102 | 0 | s00102g0f00 | 2 | 29 | 6 | 0 | 29 | sum_ord_size |
| 8 | 112 | 0 | s00112g0f00 | 2 | 29 | 5 | 0 | 29 | sum_ord_size |
| 9 | 160 | 0 | s00160g0f01 | 5 | 29 | 6 | 0 | 29 | sum_ord_size |
| 10 | 167 | 0 | s00167g0f00 | 2 | 29 | 5 | 0 | 29 | sum_ord_size |

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
| `benchmarks/square-8x8-10-cells-20260901.jsonl` | 43642 CELL rows |
| `benchmarks/square-8x8-10-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-8x8-10-analysis-20260901.md` | Este informe |
| `benchmarks/square-8x8-10-candidates-20260901.jsonl` | 104 candidatos Cairo |
