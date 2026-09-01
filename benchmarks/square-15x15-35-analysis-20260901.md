# Square 15×15/35 — Structural Corpus Analysis

**Fecha:** 20260901  
**Generado por:** `gen_square_corpus.py` + `analyze_square_corpus.py`

**Contexto:** búsqueda de frontera GREEN desde 15×15 descendiendo.
**Lección de 16×16/40:** predictor primario de gas = sum_ord_size (no max_width).

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 9576 |
| CELL states totales | 165832 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 6.5 |
| Media cells/partida | 110.6 |
| Media elapsed/partida | 0.298s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 37 | 52 | 55 | 62 | 75 | 189 |
| total_constr | 0 | 51 | 106 | 116 | 131 | 156 | 116 |
| max_width | 0 | 4 | 5 | 5 | 6 | 8 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 3 | 4 | 5 | 9 | 8 |
| max_sp_size | 0 | 19 | 45 | 50 | 59 | 75 | — |
| sum_ord_size | 0 | 5 | 40 | 46 | 55 | 74 | — |
| max_ord_internal_w | 0 | 2 | 5 | 5 | 6 | 8 | — |
| unc_other | 0 | 104 | 188 | 201 | 214 | 219 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Análisis de riesgo RED (lección 16×16/40)

| Señal | Valor | Umbral RED 16×16 | Interpretación |
|:------|------:|----------------:|:---------------|
| sum_ord_size max | 74 | 81 | por debajo |
| n CELLs sum_ord_size≥81 | 0 | >0 → sospecha | OK |
| n CELLs sum_ord_size≥60 | 577 | — | cola moderada |
| max_ord_internal_width max | 8 | 6 | ⚠ RIESGO si sum_ord alto |
| n CELLs ord_internal_width≥6 | 3420 | — | ⚠ Investigar en Cairo |
| width≥8 | 10 | benigno (n_ord=0) | ver análisis |
| width=7+n_ord>0 | 151 | patrón Expert | ⚠ patrón UNSEG |

## Distribución max_width

| max_width | n | % |
|----------:|--:|--:|
| 0 | 23446 | 14.1% |
| 1 | 5575 | 3.4% |
| 2 | 5606 | 3.4% |
| 3 | 10609 | 6.4% |
| 4 | 85193 | 51.4% |
| 5 | 28915 | 17.4% |
| 6 | 6183 | 3.7% |
| 7 | 295 | 0.2% |
| 8 | 10 | 0.0% |

## Top-5 por sum_ord_size (predictor primario)

| seed | strat | flood_id | step | sum_ord_size | max_ord_iw | n_ord | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|------:|-----------:|----------:|
| 177 | 0 | s00177g0f03 | 2 | **74** | 5 | 1 | 74 | 0 |
| 177 | 0 | s00177g0f03 | 3 | **74** | 5 | 1 | 74 | 0 |
| 177 | 0 | s00177g0f03 | 4 | **74** | 5 | 1 | 74 | 0 |
| 122 | 0 | s00122g0f03 | 2 | **73** | 6 | 2 | 73 | 0 |
| 470 | 0 | s00470g0f02 | 3 | **72** | 5 | 2 | 72 | 0 |

## Top-5 por max_ord_internal_width (ancho VE ordinario)

| seed | strat | flood_id | step | max_ord_iw | sum_ord_size | total_vars | max_width |
|-----:|------:|:---------|-----:|-----------:|-------------:|-----------:|----------:|
| 379 | 0 | s00379g0f01 | 1 | **8** | 59 | 59 | 0 |
| 379 | 0 | s00379g0f01 | 2 | **8** | 59 | 64 | 4 |
| 347 | 0 | s00347g0f04 | 3 | **7** | 70 | 70 | 0 |
| 305 | 0 | s00305g0f02 | 3 | **7** | 63 | 63 | 0 |
| 125 | 0 | s00125g0f04 | 3 | **7** | 62 | 62 | 0 |

## Top-5 por max_width (riesgo Expert)

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|-------------:|
| 311 | 0 | s00311g0f01 | 1 | **8** | 44 | 0 | 0 |
| 311 | 0 | s00311g0f01 | 2 | **8** | 47 | 0 | 0 |
| 311 | 0 | s00311g0f01 | 3 | **8** | 48 | 0 | 0 |
| 311 | 0 | s00311g0f01 | 4 | **8** | 50 | 0 | 0 |
| 311 | 0 | s00311g0f01 | 5 | **8** | 47 | 0 | 0 |

## Top-5 por total_vars

| seed | strat | flood_id | step | total_vars | max_width | n_ord | sum_ord_size |
|-----:|------:|:---------|-----:|-----------:|----------:|------:|-------------:|
| 99 | 0 | s00099g0f03 | 5 | **75** | 5 | 0 | 0 |
| 28 | 0 | s00028g0f04 | 1 | **74** | 5 | 1 | 2 |
| 99 | 0 | s00099g0f03 | 4 | **74** | 5 | 0 | 0 |
| 122 | 0 | s00122g0f03 | 4 | **74** | 6 | 1 | 1 |
| 177 | 0 | s00177g0f03 | 1 | **74** | 5 | 0 | 0 |

## Top-5 por unconstrained_other

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **219** | 0 | 0 | 35 |
| 2 | 1 | s00002g1f00 | 1 | **219** | 0 | 0 | 35 |
| 5 | 1 | s00005g1f00 | 1 | **219** | 0 | 0 | 35 |
| 8 | 1 | s00008g1f00 | 1 | **219** | 0 | 0 | 35 |
| 10 | 1 | s00010g1f00 | 1 | **219** | 0 | 0 | 35 |

## Candidatos Cairo (1945 estados)

Selección adversarial priorizando sum_ord_size, max_ord_internal_width, max_width.

Top-10 por (sum_ord_size, total_vars):

| # | seed | strat | flood_id | step | sum_ord_size | max_ord_iw | max_width | total_vars | reason |
|--:|-----:|------:|:---------|-----:|-------------:|-----------:|----------:|-----------:|:-------|
| 1 | 177 | 0 | s00177g0f03 | 2 | 74 | 5 | 0 | 74 | sum_ord_size |
| 2 | 177 | 0 | s00177g0f03 | 3 | 74 | 5 | 0 | 74 | sum_ord_size |
| 3 | 177 | 0 | s00177g0f03 | 4 | 74 | 5 | 0 | 74 | sum_ord_size |
| 4 | 122 | 0 | s00122g0f03 | 2 | 73 | 6 | 0 | 73 | sum_ord_size |
| 5 | 470 | 0 | s00470g0f02 | 3 | 72 | 5 | 0 | 72 | sum_ord_size |
| 6 | 122 | 0 | s00122g0f04 | 3 | 71 | 5 | 0 | 71 | sum_ord_size |
| 7 | 434 | 0 | s00434g0f04 | 2 | 71 | 5 | 0 | 71 | sum_ord_size |
| 8 | 99 | 0 | s00099g0f03 | 6 | 70 | 5 | 0 | 70 | sum_ord_size |
| 9 | 99 | 0 | s00099g0f03 | 7 | 70 | 5 | 0 | 70 | sum_ord_size |
| 10 | 99 | 0 | s00099g0f03 | 8 | 70 | 5 | 0 | 70 | sum_ord_size |

## Comparación con 16×16/40 RED

| Métrica | 15×15/35 max | 16×16/40 RED max | Expert max | Ratio vs Expert |
|:--------|---------------:|----------------:|-----------:|----------------:|
| total_vars | 75 | 86 | 189 | 0.40× |
| sum_ord_size | 74 | 86 (RED) | — | — |
| max_ord_internal_width | 8 | 6 (RED) | — | — |
| max_width | 8 | 8 (benigno) | 7 | 1.14× |
| unc_other | 219 | — | 474 | 0.46× |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-15x15-35-cells-20260901.jsonl.gz` | 165832 CELL rows |
| `benchmarks/square-15x15-35-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/square-15x15-35-analysis-20260901.md` | Este informe |
| `benchmarks/square-15x15-35-candidates-20260901.jsonl` | 1945 candidatos Cairo |
