# Square 12×12/23 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 6681 |
| CELL states totales | 102838 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 4.5 |
| Media cells/partida | 68.6 |
| Media elapsed/partida | 0.113s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 26 | 37 | 39 | 44 | 57 | 189 |
| total_constr | 0 | 32 | 67 | 74 | 84 | 100 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 3 | 4 | 9 | 8 |
| max_sp_size | 0 | 14 | 33 | 36 | 42 | 57 | — |
| sum_ord_size | 0 | 3 | 28 | 32 | 39 | 54 | — |
| max_ord_internal_w | 0 | 1 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 62 | 116 | 125 | 135 | 138 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 54 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 1710 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 85 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 17272 | 16.8% |
| 1 | 3985 | 3.9% |
| 2 | 4180 | 4.1% |
| 3 | 7731 | 7.5% |
| 4 | 50692 | 49.3% |
| 5 | 15099 | 14.7% |
| 6 | 3602 | 3.5% |
| 7 | 277 | 0.3% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 110 | 0 | s00110g0f02 | 3 | **54** | 6 | 1 | 54 | 0 |
| 131 | 0 | s00131g0f02 | 3 | **54** | 6 | 1 | 54 | 0 |
| 387 | 0 | s00387g0f01 | 7 | **54** | 5 | 1 | 54 | 0 |
| 151 | 0 | s00151g0f03 | 2 | **53** | 7 | 2 | 53 | 0 |
| 162 | 0 | s00162g0f01 | 3 | **52** | 6 | 1 | 52 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 151 | 0 | s00151g0f03 | 2 | **7** | 53 | 53 | 0 |
| 151 | 0 | s00151g0f03 | 7 | **7** | 50 | 50 | 0 |
| 151 | 0 | s00151g0f03 | 8 | **7** | 50 | 50 | 0 |
| 414 | 0 | s00414g0f00 | 3 | **7** | 48 | 48 | 0 |
| 414 | 0 | s00414g0f00 | 15 | **7** | 44 | 44 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 14 | 0 | s00014g0f01 | 4 | **7** | 50 | 0 | 0 |
| 39 | 0 | s00039g0f01 | 1 | **7** | 39 | 0 | 0 |
| 39 | 0 | s00039g0f01 | 2 | **7** | 40 | 0 | 0 |
| 39 | 0 | s00039g0f01 | 3 | **7** | 43 | 0 | 0 |
| 39 | 0 | s00039g0f01 | 4 | **7** | 44 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 332 | 0 | s00332g0f01 | 1 | **57** | 6 | 0 | 0 |
| 332 | 0 | s00332g0f01 | 2 | **57** | 6 | 0 | 0 |
| 272 | 0 | s00272g0f02 | 5 | **56** | 5 | 0 | 0 |
| 332 | 0 | s00332g0f01 | 3 | **56** | 6 | 0 | 0 |
| 387 | 0 | s00387g0f01 | 5 | **56** | 5 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **138** | 0 | 0 | 23 |
| 2 | 1 | s00002g1f00 | 1 | **138** | 0 | 0 | 23 |
| 4 | 1 | s00004g1f00 | 1 | **138** | 0 | 0 | 23 |
| 8 | 1 | s00008g1f00 | 1 | **138** | 0 | 0 | 23 |
| 10 | 1 | s00010g1f00 | 1 | **138** | 0 | 0 | 23 |

## Candidatos Cairo (126 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 110 | 0 | s00110g0f02 | 3 | 54 | 6 | 0 | 54 | sum_ord_size |
| 2 | 131 | 0 | s00131g0f02 | 3 | 54 | 6 | 0 | 54 | sum_ord_size |
| 3 | 387 | 0 | s00387g0f01 | 7 | 54 | 5 | 0 | 54 | sum_ord_size |
| 4 | 151 | 0 | s00151g0f03 | 2 | 53 | 7 | 0 | 53 | sum_ord_size |
| 5 | 162 | 0 | s00162g0f01 | 3 | 52 | 6 | 0 | 52 | sum_ord_size |
| 6 | 387 | 0 | s00387g0f02 | 2 | 52 | 5 | 0 | 52 | sum_ord_size |
| 7 | 131 | 0 | s00131g0f02 | 10 | 51 | 6 | 0 | 51 | sum_ord_size |
| 8 | 131 | 0 | s00131g0f02 | 11 | 51 | 6 | 0 | 51 | sum_ord_size |
| 9 | 131 | 0 | s00131g0f02 | 12 | 51 | 6 | 0 | 51 | sum_ord_size |
| 10 | 288 | 0 | s00288g0f01 | 7 | 51 | 5 | 0 | 51 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 12×12/23 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 57 | 86 | 189 | 0.30× |
| sum_ord_size | 54 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 138 | — | 474 | 0.29× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-12x12-23-cells-20260901.jsonl.gz` | 102838 CELL rows |
| `benchmarks/square-12x12-23-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-12x12-23-analysis-20260901.md` | Este informe |
| `benchmarks/square-12x12-23-candidates-20260901.jsonl` | 126 candidatos Cairo |
