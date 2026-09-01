# Square 15×15/35 — Cairo CELL Gas Benchmark

**Fecha:** 20260901
**Candidatos:** 203
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **203/203** |
| Tests exact PASS | **203/203** |
| Fallos de exactitud | **0** |

**203/203 exactos Python ↔ Cairo. Sin ningún fallo de correctness.**

## Estadísticas de gas L2 Sierra (203 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 203 |
| min | 5,350,397 |
| mean | 174,226,683 |
| p50 | 110,610,469 |
| p90 | 265,413,463 |
| p95 | 394,010,132 |
| p99 | 1,868,168,207 |
| max | **2,409,793,364** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **199** | **98.0 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **4** | **2.0 %** |

## Top 10 por gas

| # | fixture | case | gas (B) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f011 | s00324g0f02 s6 | 2.410 | 0 | 68 | 6 | 68 | 18 |
| 2 | f005 | s00125g0f04 s3 | 1.868 | 0 | 62 | 7 | 62 | 11 |
| 3 | f008 | s00125g0f04 s4 | 1.868 | 0 | 61 | 7 | 62 | 11 |
| 4 | f015 | s00125g0f04 s8 | 1.779 | 0 | 59 | 7 | 59 | 10 |
| 5 | f010 | s00131g0f03 s3 | 0.473 | 0 | 68 | 6 | 68 | 14 |
| 6 | f039 | s00434g0f04 s2 | 0.455 | 0 | 71 | 5 | 71 | 14 |
| 7 | f054 | s00434g0f05 s3 | 0.454 | 0 | 69 | 5 | 69 | 6 |
| 8 | f196 | s00379g0f01 s3 | 0.430 | 8 | 0 | 0 | 65 | 76 |
| 9 | f046 | s00490g0f03 s3 | 0.417 | 0 | 70 | 5 | 70 | 8 |
| 10 | f009 | s00493g0f03 s14 | 0.405 | 0 | 69 | 6 | 69 | 62 |

## Casos > 1.1 B (4 total)

| fixture | flood_id step | gas (B) | max_w | sum_ord | ord_iw | vars | unc_oth |
|:--------|:--------------|--------:|------:|--------:|-------:|-----:|--------:|
| f011 | s00324g0f02 s006 | **2.410** | 0 | 68 | 6 | 68 | 18 |
| f005 | s00125g0f04 s003 | **1.868** | 0 | 62 | 7 | 62 | 11 |
| f008 | s00125g0f04 s004 | **1.868** | 0 | 61 | 7 | 62 | 11 |
| f015 | s00125g0f04 s008 | **1.779** | 0 | 59 | 7 | 59 | 10 |

## Observaciones metodológicas

1. **max_ord_internal_width NO predice fiablemente el gas de ordinary components.** El caso con iw=8, sos=59 (seed=379) produjo solo 0.24B gas, mientras que iw=6, sos=68 (seed=324) produjo 2.41B. El predictor real es la estructura interna del grafo de restricciones del componente, no solo su ancho de eliminación mínimo.
2. **sum_ord_size sigue siendo predictor necesario pero no suficiente.** El caso 2.41B tiene sos=68; pero sos=73 (seed=122) produjo <200M.
3. **El mecanismo RED es el mismo que 16×16:** componente ordinario grande con ancho de eliminación efectivo alto en count_ordinary_component, sin hint de ordering explícito.

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.211 |
| max_ord_internal_width | -0.017 |
| total_vars | +0.238 |
| unconstrained_other | -0.148 |
| max_width | -0.138 |
| n_ordinary | -0.088 |

## Comparación con referencias

| Métrica | 15×15/35 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 203 | 59 | 408 |
| p50 (M) | 110 | 75 | 143 |
| p90 (M) | 265 | 403 | 1,131 |
| max (B) | 2.410 | 1.591 | 6.268 |
| > 1.1B | 4 (2.0%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **RED**

**Criterio activado:** 4 candidatos > 1,100,000,000 L2 Sierra gas (gate Starknet). Max: 2,409,793,364 = 2.41× el gate.

**Detalles:**
- 203/203 exactos Python ↔ Cairo ✓
- 199/203 por debajo de 750 M ✓
- 0 casos en [750M, 900M) ✓
- 0 casos en [900M, 1.1B] ✓
- **4 casos > 1.1B ✗ → RED**

**Floods problemáticos:**
- s00324g0f02 step=6: 2.410B (iw=6 sos=68 vars=68)
- s00125g0f04 step=3: 1.868B (iw=7 sos=62 vars=62)
- s00125g0f04 step=4: 1.868B (iw=7 sos=61 vars=62)
- s00125g0f04 step=8: 1.779B (iw=7 sos=59 vars=59)

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
|  | Raw gas + features (203 filas) |
|  | Log snforge benchmark (3 shards) |
|  | Log snforge exact (3 shards) |
|  | Análisis estructural |
|  | 203 candidatos Cairo |
|  | 203 fixtures completos |
