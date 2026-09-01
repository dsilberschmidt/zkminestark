# Intermediate 16×16/40 — Structural Corpus Analysis

**Fecha:** 2026-09-01  
**Generado por:** `gen_intermediate_structural_corpus.py`  
**Comparado con:** Expert 30×16/99 (Phase 8, 408 CELLs, 22 floods, 16 historias)

## Corpus

| Parámetro | Valor |
|:----------|------:|
| (seed,strategy) combos | 1500 |
| Floods únicos | 10810 |
| CELL states totales | 187098 |
| Estrategias | [0, 1, 2] |
| Media floods/partida | 7.3 |
| Media cells/partida | 124.7 |
| Media elapsed/partida | 0.402s |

## Distribuciones estructurales

| Campo | min | p50 | p90 | p95 | p99 | max | (Expert max) |
|:------|----:|----:|----:|----:|----:|----:|:-------------|
| total_vars | 0 | 42 | 58 | 62 | 69 | 87 | 189 |
| total_constr | 0 | 59 | 122 | 134 | 150 | 178 | 116 |
| max_width | 0 | 4 | 5 | 6 | 6 | 8 | 7 |
| n_special | 0 | 1 | 2 | 2 | 2 | 2 | — |
| n_ordinary | 0 | 1 | 3 | 4 | 6 | 11 | 8 |
| max_sp_size | 0 | 21 | 50 | 56 | 66 | 87 | — |
| sum_ord_size | 0 | 6 | 46 | 53 | 62 | 86 | — |
| unc_other | 0 | 118 | 216 | 230 | 244 | 250 | 474 |
| unc_local_n | 0 | 1 | 3 | 3 | 5 | 5 | — |

## Distribución por max_width

| max_width | n | % | Riesgo Cairo |
|----------:|--:|--:|:-------------|
| 0 | 25520 | 13.6% | barato |
| 1 | 6139 | 3.3% | barato |
| 2 | 6293 | 3.4% | barato |
| 3 | 10548 | 5.6% | barato |
| 4 | 92816 | 49.6% | barato |
| 5 | 35800 | 19.1% | ok (sub-threshold) |
| 6 | 9429 | 5.0% | ⚡ Investigar (1 bajo Expert threshold) |
| 7 | 544 | 0.3% | ⚠ POSIBLE supera gate |
| 8 | 9 | 0.0% | ⚠ POSIBLE supera gate |

## Top-5 por max_width (predictor principal Phase 8)

| seed | strat | flood_id | step | max_width | total_vars | n_ordinary | unc_other | sum_ord_size |
|-----:|------:|:---------|-----:|----------:|-----------:|-----------:|----------:|-------------:|
| 38 | 0 | s00038g0f01 | 9 | **8** | 53 | 0 | 145 | 0 |
| 38 | 2 | s00038g2f03 | 9 | **8** | 54 | 0 | 67 | 0 |
| 349 | 0 | s00349g0f01 | 1 | **8** | 59 | 0 | 101 | 0 |
| 349 | 0 | s00349g0f01 | 2 | **8** | 63 | 0 | 101 | 0 |
| 349 | 0 | s00349g0f01 | 3 | **8** | 63 | 0 | 100 | 0 |

## Top-5 por total_vars (predictor lineal r=+0.679 en Phase 8)

| seed | strat | flood_id | step | total_vars | max_width | n_ordinary | unc_other |
|-----:|------:|:---------|-----:|-----------:|----------:|-----------:|----------:|
| 213 | 0 | s00213g0f03 | 5 | **87** | 7 | 0 | 49 |
| 82 | 0 | s00082g0f03 | 2 | **86** | 6 | 1 | 8 |
| 82 | 0 | s00082g0f03 | 3 | **86** | 0 | 2 | 8 |
| 82 | 0 | s00082g0f03 | 4 | **86** | 6 | 1 | 8 |
| 82 | 0 | s00082g0f03 | 6 | **86** | 6 | 1 | 6 |

## Top-5 por sum_ord_size (convolution de componentes ordinarias)

| seed | strat | flood_id | step | sum_ord_size | n_ordinary | total_vars | max_width |
|-----:|------:|:---------|-----:|-------------:|-----------:|-----------:|----------:|
| 82 | 0 | s00082g0f03 | 3 | **86** | 2 | 86 | 0 |
| 82 | 0 | s00082g0f03 | 5 | **84** | 2 | 84 | 0 |
| 213 | 0 | s00213g0f04 | 3 | **83** | 1 | 83 | 0 |
| 82 | 0 | s00082g0f03 | 13 | **81** | 2 | 81 | 0 |
| 181 | 0 | s00181g0f02 | 7 | **81** | 2 | 81 | 0 |

## Top-5 por unconstrained_other (multiplicador en extract_outcomes)

| seed | strat | flood_id | step | unc_other | total_vars | max_width | remaining_mines |
|-----:|------:|:---------|-----:|----------:|-----------:|----------:|----------------:|
| 0 | 1 | s00000g1f00 | 1 | **250** | 0 | 0 | 40 |
| 2 | 1 | s00002g1f00 | 1 | **250** | 0 | 0 | 40 |
| 5 | 1 | s00005g1f00 | 1 | **250** | 0 | 0 | 40 |
| 8 | 1 | s00008g1f00 | 1 | **250** | 0 | 0 | 40 |
| 11 | 1 | s00011g1f00 | 1 | **250** | 0 | 0 | 40 |

## Análisis de cola: width≥7 (señal de riesgo Expert)

### width≥8 (9 CELLs)

Todos con n_ordinary=0. Expert no tuvo ningún CELL con width≥8 en su corpus.

| seed | strat | flood_id | step | max_width | total_vars | max_sp_size | unc_other |
|-----:|------:|:---------|-----:|----------:|-----------:|------------:|----------:|
| 374 | 0 | s00374g0f02 | 9 | **8** | 70 | 70 | 90 |
| 374 | 0 | s00374g0f02 | 4 | **8** | 68 | 68 | 97 |
| 349 | 0 | s00349g0f01 | 5 | **8** | 66 | 66 | 98 |
| 349 | 0 | s00349g0f01 | 4 | **8** | 64 | 64 | 98 |
| 349 | 0 | s00349g0f01 | 2 | **8** | 63 | 63 | 101 |
| 349 | 0 | s00349g0f01 | 3 | **8** | 63 | 63 | 100 |
| 349 | 0 | s00349g0f01 | 1 | **8** | 59 | 59 | 101 |
| 38 | 2 | s00038g2f03 | 9 | **8** | 54 | 54 | 67 |
| 38 | 0 | s00038g0f01 | 9 | **8** | 53 | 53 | 145 |

### width=7 + n_ordinary>0 (217 CELLs) — patrón Expert unseg

Este es el patrón que causó 4 floods UNSEG en Expert (width=7 + n_ord=5-8).

Top-10 por (n_ordinary, sum_ord_size):

| seed | strat | flood_id | step | max_width | total_vars | n_ord | sum_ord | unc_other |
|-----:|------:|:---------|-----:|----------:|-----------:|------:|--------:|----------:|
| 105 | 2 | s00105g2f04 | 3 | 7 | 46 | **6** | 35 | 0 |
| 105 | 2 | s00105g2f04 | 1 | 7 | 48 | **5** | 28 | 0 |
| 105 | 2 | s00105g2f04 | 2 | 7 | 47 | **5** | 28 | 0 |
| 480 | 2 | s00480g2f08 | 1 | 7 | 48 | **5** | 22 | 1 |
| 260 | 0 | s00260g0f03 | 10 | 7 | 54 | **5** | 17 | 29 |
| 105 | 0 | s00105g0f03 | 1 | 7 | 58 | **4** | 28 | 0 |
| 105 | 0 | s00105g0f03 | 2 | 7 | 57 | **4** | 28 | 0 |
| 351 | 0 | s00351g0f03 | 29 | 7 | 56 | **4** | 24 | 55 |
| 351 | 0 | s00351g0f03 | 30 | 7 | 56 | **4** | 24 | 55 |
| 124 | 0 | s00124g0f03 | 1 | 7 | 50 | **4** | 12 | 53 |

### width=7, n_ordinary=0 (327 CELLs)

Equivalente al Expert width=6 n_ord=0 (max gas 0.571B) pero con más cara VE. Probablemente bajo gate.

## Comparación directa con Expert Phase 8

| Métrica | Intermediate (max) | Expert (max) | Ratio | Interpretación |
|:--------|------------------:|-------------:|------:|:---------------|
| total_vars | 87 | 189 | 0.46× | OK |
| max_width  | 8 | 7 | 1.14× | ⚠ mismo |
| unc_other  | 250 | 474 | 0.53× | ⚠ comparable |
| n_ordinary | 11 | 8 | 1.38× | ⚠ similar |

## Estimación de gas (qualitativa)

La estimación cuantitativa de gas requiere tests Cairo reales. La estimación cualitativa:

**Factores de escala frente a Expert f15 (peor caso, 6.268B L2 gas):**
- VE con max_width=8 vs Expert max_width=7: factor ~2.00×
- total_vars máximo 87 vs Expert 189: factor ~0.46×
- unc_other máximo 250 vs Expert 474: factor ~0.53×
- Producto multiplicativo (si factores independientes): ~0.486×
- Gas estimado máximo (si lineal con factores): ~3.044B L2

*Nota:* esta estimación es orientativa. La dependencia real es no-lineal (especialmente la VE).

## Veredicto de riesgo estructural

### **HIGH STRUCTURAL RISK**

**Racional:** width≥8 observed (9 CELLs) — ABOVE Expert worst case of 7 → VE 2× more expensive | width=7 + n_ord>0 cases exist (217) — the Expert unseg pattern | unc_other≥200 with constraints (Expert p50=376) | total_vars max=87 (well below Expert p50=52)

**Señales vs Expert:**
- Expert UNSEG: 4/22 floods (18%) con CELLs individuales >1.1B
- Expert predictor más discriminante: max_width=7 → 39% de esos CELLs superan gate; todos con n_ord>0
- Intermediate max_width observado: **8** (umbral Expert: 7, Intermediate lo SUPERA)
- Intermediate width≥8: 9 CELLs (todos con n_ord=0 — mitiga parcialmente)
- Intermediate width=7 + n_ord>0: 217 CELLs (patrón de riesgo Expert)
- Intermediate max total_vars: 87 (Expert p50: 52)
- Intermediate unc_other max (con constraints): 248 (Expert min: 113)

## Candidatos Cairo (59 estados)

Escritos en `intermediate-16x16-40-candidates-20260901.jsonl` para diseño de ronda Cairo.

Top-10 por (max_width, total_vars):

| # | seed | strat | flood_id | step | max_width | total_vars | unc_other | reason |
|--:|-----:|------:|:---------|-----:|----------:|-----------:|----------:|:-------|
| 1 | 374 | 0 | s00374g0f02 | 9 | 8 | 70 | 90 | max_width |
| 2 | 374 | 0 | s00374g0f02 | 4 | 8 | 68 | 97 | max_width |
| 3 | 349 | 0 | s00349g0f01 | 5 | 8 | 66 | 98 | max_width |
| 4 | 349 | 0 | s00349g0f01 | 4 | 8 | 64 | 98 | max_width |
| 5 | 349 | 0 | s00349g0f01 | 2 | 8 | 63 | 101 | max_width |
| 6 | 349 | 0 | s00349g0f01 | 3 | 8 | 63 | 100 | max_width |
| 7 | 349 | 0 | s00349g0f01 | 1 | 8 | 59 | 101 | max_width |
| 8 | 38 | 2 | s00038g2f03 | 9 | 8 | 54 | 67 | max_width |
| 9 | 38 | 0 | s00038g0f01 | 9 | 8 | 53 | 145 | max_width |
| 10 | 213 | 0 | s00213g0f03 | 5 | 7 | 87 | 49 | total_vars |

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/intermediate-16x16-40-cells-20260901.jsonl.gz` | 187098 CELL rows estructurales |
| `benchmarks/intermediate-16x16-40-meta-20260901.jsonl` | 1500 game records |
| `benchmarks/intermediate-16x16-40-analysis-20260901.md` | Este informe |
| `benchmarks/intermediate-16x16-40-candidates-20260901.jsonl` | 59 candidatos Cairo |
