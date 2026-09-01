# Square 10×10/16 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 117  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **117/117** |
| Tests exact PASS | **117/117** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (117 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 117 |
| min | 2,483,880 |
| mean | 117,469,969 |
| p50 | 78,828,128 |
| p90 | 194,036,265 |
| p95 | 317,769,923 |
| p99 | 1,547,107,103 |
| max | **1,547,157,633** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **114** | **97.4 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **3** | **2.6 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f22 | s00028g0f02 s2 | 1547 | 0 | 34 | 7 | 34 | 3 |
| 2 | f24 | s00028g0f02 s1 | 1547 | 3 | 30 | 7 | 34 | 3 |
| 3 | f14 | s00018g0f01 s4 | 1239 | 0 | 39 | 7 | 39 | 16 |
| 4 | f15 | s00070g0f01 s3 | 486 | 0 | 39 | 6 | 39 | 0 |
| 5 | f12 | s00457g0f01 s3 | 326 | 0 | 41 | 6 | 41 | 7 |
| 6 | f07 | s00480g0f01 s2 | 318 | 0 | 42 | 5 | 42 | 5 |
| 7 | f08 | s00480g0f01 s3 | 318 | 0 | 42 | 5 | 42 | 5 |
| 8 | f09 | s00480g0f01 s4 | 318 | 0 | 42 | 5 | 42 | 5 |
| 9 | f59 | s00019g0f00 s2 | 220 | 7 | 0 | 0 | 36 | 33 |
| 10 | f47 | s00019g0f00 s5 | 202 | 7 | 0 | 0 | 41 | 28 |

## Casos > 1.1 B (3 total)

| fixture | flood_id_step | gas (B) | max_w | vars | sum_ord | ord_iw | unc_oth |
|:--------|:--------------|--------:|------:|-----:|--------:|-------:|--------:|
| f22 | s00028g0f02_s002 | **1.547** | 0 | 34 | 34 | 7 | 3 |
| f24 | s00028g0f02_s001 | **1.547** | 3 | 34 | 30 | 7 | 3 |
| f14 | s00018g0f01_s004 | **1.239** | 0 | 39 | 39 | 7 | 16 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.326 |
| max_ord_internal_width | +0.371 |
| total_vars | +0.340 |
| unconstrained_other | -0.134 |
| max_width | -0.023 |
| n_ordinary | -0.032 |

## Comparación con referencias

| Métrica | 10×10/16 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 117 | 59 | 408 |
| p50 (M) | 78 | 75 | 143 |
| p90 (M) | 194 | 403 | 1,131 |
| max (M) | 1547 | 1,591 | 6,268 |
| > 1.1B | 3 (2.6%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **RED**

**Criterio activado:** 3 candidatos > 1.1B L2 Sierra gas (gate Starknet)


**Detalles:**
- 117/117 exactos Python ↔ Cairo ✓
- 114/117 por debajo de 750 M 
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **3 casos > 1.1B** ✗ → RED

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-10x10-16-gas-20260901.jsonl` | Raw gas + features (117 filas) |
| `benchmarks/square-snforge-bench-sq10x10-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq10x10-20260901.log` | Log snforge exact |
