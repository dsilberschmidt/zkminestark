# Square 11×11/19 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 134  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **134/134** |
| Tests exact PASS | **134/134** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (134 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 134 |
| min | 2,889,600 |
| mean | 106,725,444 |
| p50 | 75,238,569 |
| p90 | 117,571,672 |
| p95 | 175,324,755 |
| p99 | 753,255,558 |
| max | **3,133,369,256** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **132** | **98.5 %** |
| 750 M – 900 M | 1 | 0.7 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **1** | **0.7 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f01 | s00028g0f02 s4 | 3133 | 0 | 46 | 6 | 46 | 9 |
| 2 | f20 | s00322g0f00 s15 | 753 | 0 | 36 | 7 | 36 | 39 |
| 3 | f30 | s00322g0f00 s6 | 748 | 0 | 32 | 7 | 32 | 47 |
| 4 | f31 | s00322g0f00 s7 | 748 | 0 | 32 | 7 | 32 | 47 |
| 5 | f00 | s00205g0f01 s3 | 569 | 0 | 47 | 5 | 47 | 17 |
| 6 | f14 | s00381g0f01 s8 | 348 | 0 | 45 | 6 | 45 | 28 |
| 7 | f07 | s00265g0f02 s2 | 175 | 0 | 45 | 6 | 45 | 2 |
| 8 | f08 | s00265g0f02 s3 | 175 | 0 | 45 | 6 | 45 | 2 |
| 9 | f09 | s00265g0f02 s4 | 175 | 0 | 45 | 6 | 45 | 2 |
| 10 | f03 | s00469g0f02 s4 | 150 | 0 | 46 | 5 | 46 | 9 |

## Casos > 1.1 B (1 total)

| fixture | flood_id_step | gas (B) | max_w | vars | sum_ord | ord_iw | unc_oth |
|:--------|:--------------|--------:|------:|-----:|--------:|-------:|--------:|
| f01 | s00028g0f02_s004 | **3.133** | 0 | 46 | 46 | 6 | 9 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.277 |
| max_ord_internal_width | +0.199 |
| total_vars | +0.263 |
| unconstrained_other | -0.070 |
| max_width | -0.095 |
| n_ordinary | -0.120 |

## Comparación con referencias

| Métrica | 11×11/19 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 134 | 59 | 408 |
| p50 (M) | 75 | 75 | 143 |
| p90 (M) | 117 | 403 | 1,131 |
| max (M) | 3133 | 1,591 | 6,268 |
| > 1.1B | 1 (0.7%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **RED**

**Criterio activado:** 1 candidatos > 1.1B L2 Sierra gas (gate Starknet)


**Detalles:**
- 134/134 exactos Python ↔ Cairo ✓
- 132/134 por debajo de 750 M 
- 1 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **1 casos > 1.1B** ✗ → RED

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-11x11-19-gas-20260901.jsonl` | Raw gas + features (134 filas) |
| `benchmarks/square-snforge-bench-sq11x11-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq11x11-20260901.log` | Log snforge exact |
