# Square 12×12/23 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 126  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **126/126** |
| Tests exact PASS | **126/126** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (126 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 126 |
| min | 3,430,560 |
| mean | 155,749,179 |
| p50 | 94,262,682 |
| p90 | 248,412,371 |
| p95 | 601,635,627 |
| p99 | 1,666,291,867 |
| max | **1,668,243,042** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **122** | **96.8 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **4** | **3.2 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f27 | s00103g0f03 s1 | 1668 | 3 | 34 | 7 | 40 | 1 |
| 2 | f29 | s00103g0f03 s2 | 1666 | 2 | 34 | 7 | 39 | 1 |
| 3 | f30 | s00103g0f03 s3 | 1665 | 1 | 34 | 7 | 38 | 1 |
| 4 | f28 | s00103g0f03 s4 | 1665 | 0 | 37 | 7 | 37 | 1 |
| 5 | f32 | s00103g0f04 s1 | 602 | 0 | 32 | 7 | 32 | 0 |
| 6 | f33 | s00103g0f04 s2 | 602 | 0 | 32 | 7 | 32 | 0 |
| 7 | f35 | s00103g2f04 s1 | 602 | 0 | 32 | 7 | 32 | 0 |
| 8 | f36 | s00103g2f04 s2 | 602 | 0 | 32 | 7 | 32 | 0 |
| 9 | f23 | s00039g0f01 s9 | 342 | 0 | 41 | 7 | 41 | 51 |
| 10 | f24 | s00039g0f01 s10 | 342 | 0 | 41 | 7 | 41 | 51 |

## Casos > 1.1 B (4 total)

| fixture | flood_id_step | gas (B) | max_w | vars | sum_ord | ord_iw | unc_oth |
|:--------|:--------------|--------:|------:|-----:|--------:|-------:|--------:|
| f27 | s00103g0f03_s001 | **1.668** | 3 | 40 | 34 | 7 | 1 |
| f29 | s00103g0f03_s002 | **1.666** | 2 | 39 | 34 | 7 | 1 |
| f30 | s00103g0f03_s003 | **1.665** | 1 | 38 | 34 | 7 | 1 |
| f28 | s00103g0f03_s004 | **1.665** | 0 | 37 | 37 | 7 | 1 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.262 |
| max_ord_internal_width | +0.431 |
| total_vars | +0.202 |
| unconstrained_other | -0.196 |
| max_width | -0.074 |
| n_ordinary | +0.039 |

## Comparación con referencias

| Métrica | 12×12/23 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 126 | 59 | 408 |
| p50 (M) | 94 | 75 | 143 |
| p90 (M) | 248 | 403 | 1,131 |
| max (M) | 1668 | 1,591 | 6,268 |
| > 1.1B | 4 (3.2%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **RED**

**Criterio activado:** 4 candidatos > 1.1B L2 Sierra gas (gate Starknet)


**Detalles:**
- 126/126 exactos Python ↔ Cairo ✓
- 122/126 por debajo de 750 M 
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **4 casos > 1.1B** ✗ → RED

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-12x12-23-gas-20260901.jsonl` | Raw gas + features (126 filas) |
| `benchmarks/square-snforge-bench-sq12x12-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq12x12-20260901.log` | Log snforge exact |
