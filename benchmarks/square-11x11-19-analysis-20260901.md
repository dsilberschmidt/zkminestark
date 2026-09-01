# Square 11×11/19 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 5980 |
| CELL states totales | 86537 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 4.1 |
| Media cells/partida | 57.7 |
| Media elapsed/partida | 0.077s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 23 | 32 | 34 | 39 | 50 | 189 |
| total_constr | 0 | 27 | 56 | 62 | 70 | 81 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 3 | 4 | 7 | 8 |
| max_sp_size | 0 | 12 | 28 | 31 | 37 | 50 | — |
| sum_ord_size | 0 | 3 | 24 | 28 | 34 | 47 | — |
| max_ord_internal_w | 0 | 1 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 50 | 96 | 104 | 112 | 115 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 47 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 1410 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 75 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 16394 | 18.9% |
| 1 | 3847 | 4.4% |
| 2 | 4036 | 4.7% |
| 3 | 7265 | 8.4% |
| 4 | 40782 | 47.1% |
| 5 | 11430 | 13.2% |
| 6 | 2602 | 3.0% |
| 7 | 181 | 0.2% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 205 | 0 | s00205g0f01 | 3 | **47** | 5 | 1 | 47 | 0 |
| 28 | 0 | s00028g0f02 | 4 | **46** | 6 | 1 | 46 | 0 |
| 102 | 0 | s00102g0f02 | 3 | **46** | 6 | 1 | 46 | 0 |
| 469 | 0 | s00469g0f02 | 4 | **46** | 5 | 1 | 46 | 0 |
| 48 | 0 | s00048g0f02 | 3 | **45** | 5 | 1 | 45 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 159 | 0 | s00159g0f03 | 2 | **7** | 39 | 39 | 0 |
| 159 | 0 | s00159g0f03 | 3 | **7** | 39 | 39 | 0 |
| 159 | 0 | s00159g0f03 | 4 | **7** | 39 | 39 | 0 |
| 217 | 0 | s00217g0f03 | 2 | **7** | 37 | 37 | 0 |
| 322 | 0 | s00322g0f00 | 15 | **7** | 36 | 36 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 73 | 0 | s00073g0f00 | 1 | **7** | 24 | 0 | 0 |
| 73 | 0 | s00073g0f00 | 2 | **7** | 25 | 0 | 0 |
| 73 | 0 | s00073g0f00 | 3 | **7** | 28 | 0 | 0 |
| 73 | 0 | s00073g0f00 | 4 | **7** | 29 | 0 | 0 |
| 73 | 1 | s00073g1f03 | 1 | **7** | 30 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 356 | 0 | s00356g0f01 | 9 | **50** | 5 | 0 | 0 |
| 111 | 0 | s00111g0f01 | 1 | **49** | 6 | 0 | 0 |
| 111 | 0 | s00111g0f01 | 2 | **49** | 6 | 0 | 0 |
| 356 | 0 | s00356g0f01 | 8 | **49** | 5 | 0 | 0 |
| 356 | 0 | s00356g0f01 | 4 | **48** | 5 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **115** | 0 | 0 | 19 |
| 5 | 1 | s00005g1f00 | 1 | **115** | 0 | 0 | 19 |
| 8 | 1 | s00008g1f00 | 1 | **115** | 0 | 0 | 19 |
| 13 | 1 | s00013g1f00 | 1 | **115** | 0 | 0 | 19 |
| 14 | 1 | s00014g1f00 | 1 | **115** | 0 | 0 | 19 |

## Candidatos Cairo (134 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 205 | 0 | s00205g0f01 | 3 | 47 | 5 | 0 | 47 | sum_ord_size |
| 2 | 28 | 0 | s00028g0f02 | 4 | 46 | 6 | 0 | 46 | sum_ord_size |
| 3 | 102 | 0 | s00102g0f02 | 3 | 46 | 6 | 0 | 46 | sum_ord_size |
| 4 | 469 | 0 | s00469g0f02 | 4 | 46 | 5 | 0 | 46 | sum_ord_size |
| 5 | 48 | 0 | s00048g0f02 | 3 | 45 | 5 | 0 | 45 | sum_ord_size |
| 6 | 100 | 0 | s00100g0f03 | 3 | 45 | 5 | 0 | 45 | sum_ord_size |
| 7 | 215 | 0 | s00215g0f01 | 3 | 45 | 5 | 0 | 45 | sum_ord_size |
| 8 | 265 | 0 | s00265g0f02 | 2 | 45 | 6 | 0 | 45 | sum_ord_size |
| 9 | 265 | 0 | s00265g0f02 | 3 | 45 | 6 | 0 | 45 | sum_ord_size |
| 10 | 265 | 0 | s00265g0f02 | 4 | 45 | 6 | 0 | 45 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 11×11/19 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 50 | 86 | 189 | 0.26× |
| sum_ord_size | 47 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 115 | — | 474 | 0.24× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-11x11-19-cells-20260901.jsonl` | 86537 CELL rows |
| `benchmarks/square-11x11-19-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-11x11-19-analysis-20260901.md` | Este informe |
| `benchmarks/square-11x11-19-candidates-20260901.jsonl` | 134 candidatos Cairo |
