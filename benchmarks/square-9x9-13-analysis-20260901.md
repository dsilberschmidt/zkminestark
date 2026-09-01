# Square 9×9/13 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 4595 |
| CELL states totales | 54912 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 3.2 |
| Media cells/partida | 36.6 |
| Media elapsed/partida | 0.034s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 17 | 24 | 26 | 31 | 39 | 189 |
| total_constr | 0 | 19 | 37 | 41 | 48 | 58 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 7 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 2 | 2 | 3 | 5 | 8 |
| max_sp_size | 0 | 9 | 21 | 24 | 30 | 39 | — |
| sum_ord_size | 0 | 2 | 17 | 20 | 26 | 37 | — |
| max_ord_internal_w | 0 | 0 | 4 | 5 | 6 | 7 | — |
| unc_other | 0 | 30 | 61 | 66 | 72 | 75 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 37 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 0 | — | cola moderada |
| max_ord_internal_width max | 7 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 660 | — | ⚠ Investigar en Cairo |
| width≥8 | 0 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 18 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 12177 | 22.2% |
| 1 | 2773 | 5.0% |
| 2 | 2746 | 5.0% |
| 3 | 5562 | 10.1% |
| 4 | 23992 | 43.7% |
| 5 | 6247 | 11.4% |
| 6 | 1350 | 2.5% |
| 7 | 65 | 0.1% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 250 | 0 | s00250g0f00 | 3 | **37** | 6 | 1 | 37 | 0 |
| 343 | 0 | s00343g0f00 | 4 | **37** | 5 | 1 | 37 | 0 |
| 345 | 0 | s00345g0f00 | 4 | **37** | 5 | 1 | 37 | 0 |
| 383 | 0 | s00383g0f01 | 2 | **37** | 5 | 1 | 37 | 0 |
| 383 | 0 | s00383g0f01 | 3 | **37** | 5 | 1 | 37 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 91 | 0 | s00091g0f00 | 6 | **7** | 34 | 34 | 0 |
| 464 | 2 | s00464g2f01 | 2 | **7** | 25 | 25 | 0 |
| 231 | 0 | s00231g0f00 | 8 | **7** | 22 | 22 | 0 |
| 231 | 0 | s00231g0f00 | 9 | **7** | 22 | 22 | 0 |
| 231 | 0 | s00231g0f00 | 10 | **7** | 22 | 22 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 91 | 0 | s00091g0f00 | 1 | **7** | 39 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 2 | **7** | 39 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 3 | **7** | 37 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 4 | **7** | 37 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 5 | **7** | 36 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 91 | 0 | s00091g0f00 | 1 | **39** | 7 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 2 | **39** | 7 | 0 | 0 |
| 430 | 0 | s00430g0f01 | 5 | **38** | 6 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 3 | **37** | 7 | 0 | 0 |
| 91 | 0 | s00091g0f00 | 4 | **37** | 7 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **75** | 0 | 0 | 13 |
| 1 | 1 | s00001g1f00 | 1 | **75** | 0 | 0 | 13 |
| 4 | 1 | s00004g1f00 | 1 | **75** | 0 | 0 | 13 |
| 5 | 1 | s00005g1f00 | 1 | **75** | 0 | 0 | 13 |
| 11 | 1 | s00011g1f00 | 1 | **75** | 0 | 0 | 13 |

## Candidatos Cairo (120 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 250 | 0 | s00250g0f00 | 3 | 37 | 6 | 0 | 37 | sum_ord_size |
| 2 | 343 | 0 | s00343g0f00 | 4 | 37 | 5 | 0 | 37 | sum_ord_size |
| 3 | 345 | 0 | s00345g0f00 | 4 | 37 | 5 | 0 | 37 | sum_ord_size |
| 4 | 383 | 0 | s00383g0f01 | 2 | 37 | 5 | 0 | 37 | sum_ord_size |
| 5 | 383 | 0 | s00383g0f01 | 3 | 37 | 5 | 0 | 37 | sum_ord_size |
| 6 | 383 | 0 | s00383g0f01 | 4 | 37 | 5 | 0 | 37 | sum_ord_size |
| 7 | 78 | 0 | s00078g0f00 | 4 | 36 | 6 | 0 | 36 | sum_ord_size |
| 8 | 294 | 0 | s00294g0f00 | 3 | 36 | 5 | 0 | 36 | sum_ord_size |
| 9 | 357 | 0 | s00357g0f01 | 3 | 36 | 5 | 0 | 36 | sum_ord_size |
| 10 | 8 | 0 | s00008g0f00 | 4 | 35 | 5 | 0 | 35 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 9×9/13 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 39 | 86 | 189 | 0.21× |
| sum_ord_size | 37 | 86 (RED) | — | — |
| max_ord_internal_width | 7 | 6 (RED) | — | — |
| max_width | 7 | 8 (benigno) | 7 | 1.00× |
| unc_other | 75 | — | 474 | 0.16× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-9x9-13-cells-20260901.jsonl` | 54912 CELL rows |
| `benchmarks/square-9x9-13-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-9x9-13-analysis-20260901.md` | Este informe |
| `benchmarks/square-9x9-13-candidates-20260901.jsonl` | 120 candidatos Cairo |
