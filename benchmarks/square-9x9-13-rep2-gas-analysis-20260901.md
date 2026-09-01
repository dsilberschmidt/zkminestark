# Square 9×9/13 — Cairo CELL Gas Benchmark

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
| min | 2,078,160 |
| mean | 99,928,673 |
| p50 | 44,483,588 |
| p90 | 126,414,013 |
| p95 | 162,359,627 |
| p99 | 2,132,911,663 |
| max | **2,132,911,663** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **123** | **97.6 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **3** | **2.4 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f08 | s00542g0f01 s2 | 2133 | 0 | 34 | 6 | 34 | 3 |
| 2 | f09 | s00542g0f01 s3 | 2133 | 0 | 34 | 6 | 34 | 3 |
| 3 | f10 | s00542g0f01 s4 | 2133 | 0 | 34 | 6 | 34 | 3 |
| 4 | f05 | s00816g0f01 s3 | 180 | 0 | 35 | 5 | 35 | 7 |
| 5 | f07 | s00541g0f02 s3 | 169 | 0 | 34 | 5 | 34 | 9 |
| 6 | f19 | s00551g0f00 s8 | 163 | 0 | 25 | 7 | 25 | 30 |
| 7 | f20 | s00551g0f00 s10 | 162 | 0 | 25 | 7 | 25 | 28 |
| 8 | f18 | s00551g0f00 s14 | 158 | 0 | 26 | 7 | 26 | 25 |
| 9 | f21 | s00551g0f00 s12 | 153 | 0 | 25 | 7 | 25 | 26 |
| 10 | f06 | s00526g0f01 s4 | 150 | 0 | 34 | 5 | 34 | 8 |

## Casos > 1.1 B (3 total)

| fixture | flood_id_step | gas (B) | max_w | vars | sum_ord | ord_iw | unc_oth |
|:--------|:--------------|--------:|------:|-----:|--------:|-------:|--------:|
| f08 | s00542g0f01_s002 | **2.133** | 0 | 34 | 34 | 6 | 3 |
| f09 | s00542g0f01_s003 | **2.133** | 0 | 34 | 34 | 6 | 3 |
| f10 | s00542g0f01_s004 | **2.133** | 0 | 34 | 34 | 6 | 3 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.327 |
| max_ord_internal_width | +0.234 |
| total_vars | +0.278 |
| unconstrained_other | -0.108 |
| max_width | -0.098 |
| n_ordinary | -0.095 |

## Comparación con referencias

| Métrica | 9×9/13 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 126 | 59 | 408 |
| p50 (M) | 44 | 75 | 143 |
| p90 (M) | 126 | 403 | 1,131 |
| max (M) | 2132 | 1,591 | 6,268 |
| > 1.1B | 3 (2.4%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **RED**

**Criterio activado:** 3 candidatos > 1.1B L2 Sierra gas (gate Starknet)


**Detalles:**
- 126/126 exactos Python ↔ Cairo ✓
- 123/126 por debajo de 750 M 
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **3 casos > 1.1B** ✗ → RED

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-9x9-13-rep2-gas-20260901.jsonl` | Raw gas + features (126 filas) |
| `benchmarks/square-snforge-bench-sq9x9_rep2-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq9x9_rep2-20260901.log` | Log snforge exact |
