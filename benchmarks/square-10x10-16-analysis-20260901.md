# Square 10×10/16 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 5239 |
| CELL states totales | 69306 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 3.6 |
| Media cells/partida | 46.2 |
| Media elapsed/partida | 0.045s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 20 | 28 | 30 | 34 | 45 | 189 |
| total_constr | 0 | 22 | 46 | 51 | 58 | 75 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 3 | 3 | 6 | 8 |
| max_sp_size | 0 | 11 | 25 | 28 | 33 | 45 | — |
| sum_ord_size | 0 | 2 | 21 | 24 | 30 | 43 | — |
| max_ord_internal_w | 0 | 1 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 40 | 78 | 85 | 91 | 94 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 43 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 939 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 14 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 13859 | 20.0% |
| 1 | 3067 | 4.4% |
| 2 | 3210 | 4.6% |
| 3 | 6193 | 8.9% |
| 4 | 32745 | 47.2% |
| 5 | 8313 | 12.0% |
| 6 | 1865 | 2.7% |
| 7 | 54 | 0.1% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 499 | 0 | s00499g0f01 | 2 | **43** | 5 | 1 | 43 | 0 |
| 499 | 0 | s00499g0f01 | 3 | **43** | 5 | 1 | 43 | 0 |
| 499 | 0 | s00499g0f01 | 4 | **43** | 5 | 1 | 43 | 0 |
| 53 | 0 | s00053g0f00 | 3 | **42** | 5 | 1 | 42 | 0 |
| 380 | 0 | s00380g0f01 | 2 | **42** | 5 | 1 | 42 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 18 | 0 | s00018g0f01 | 4 | **7** | 39 | 39 | 0 |
| 34 | 0 | s00034g0f00 | 7 | **7** | 36 | 36 | 0 |
| 19 | 0 | s00019g0f00 | 7 | **7** | 35 | 35 | 0 |
| 19 | 0 | s00019g0f00 | 8 | **7** | 35 | 35 | 0 |
| 19 | 0 | s00019g0f00 | 9 | **7** | 35 | 35 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 18 | 0 | s00018g0f01 | 1 | **7** | 35 | 0 | 0 |
| 18 | 0 | s00018g0f01 | 2 | **7** | 38 | 0 | 0 |
| 18 | 0 | s00018g0f01 | 3 | **7** | 39 | 0 | 0 |
| 18 | 0 | s00018g0f01 | 5 | **7** | 39 | 0 | 0 |
| 19 | 0 | s00019g0f00 | 1 | **7** | 33 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 101 | 0 | s00101g0f00 | 5 | **45** | 6 | 0 | 0 |
| 57 | 0 | s00057g0f01 | 1 | **44** | 6 | 0 | 0 |
| 101 | 0 | s00101g0f00 | 4 | **44** | 6 | 0 | 0 |
| 57 | 0 | s00057g0f01 | 2 | **43** | 6 | 0 | 0 |
| 101 | 0 | s00101g0f00 | 3 | **43** | 6 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **94** | 0 | 0 | 16 |
| 1 | 1 | s00001g1f00 | 1 | **94** | 0 | 0 | 16 |
| 5 | 1 | s00005g1f00 | 1 | **94** | 0 | 0 | 16 |
| 13 | 1 | s00013g1f00 | 1 | **94** | 0 | 0 | 16 |
| 14 | 1 | s00014g1f00 | 1 | **94** | 0 | 0 | 16 |

## Candidatos Cairo (117 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 499 | 0 | s00499g0f01 | 2 | 43 | 5 | 0 | 43 | sum_ord_size |
| 2 | 499 | 0 | s00499g0f01 | 3 | 43 | 5 | 0 | 43 | sum_ord_size |
| 3 | 499 | 0 | s00499g0f01 | 4 | 43 | 5 | 0 | 43 | sum_ord_size |
| 4 | 53 | 0 | s00053g0f00 | 3 | 42 | 5 | 0 | 42 | sum_ord_size |
| 5 | 380 | 0 | s00380g0f01 | 2 | 42 | 5 | 0 | 42 | sum_ord_size |
| 6 | 437 | 0 | s00437g0f01 | 4 | 42 | 5 | 0 | 42 | sum_ord_size |
| 7 | 454 | 0 | s00454g0f01 | 2 | 42 | 6 | 0 | 42 | sum_ord_size |
| 8 | 480 | 0 | s00480g0f01 | 2 | 42 | 5 | 0 | 42 | sum_ord_size |
| 9 | 480 | 0 | s00480g0f01 | 3 | 42 | 5 | 0 | 42 | sum_ord_size |
| 10 | 480 | 0 | s00480g0f01 | 4 | 42 | 5 | 0 | 42 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 10×10/16 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 45 | 86 | 189 | 0.24× |
| sum_ord_size | 43 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 94 | — | 474 | 0.20× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-10x10-16-cells-20260901.jsonl` | 69306 CELL rows |
| `benchmarks/square-10x10-16-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-10x10-16-analysis-20260901.md` | Este informe |
| `benchmarks/square-10x10-16-candidates-20260901.jsonl` | 117 candidatos Cairo |
