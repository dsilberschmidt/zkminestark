# Square 8×8/10 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 111  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **111/111** |
| Tests exact PASS | **111/111** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (111 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 111 |
| min | 1,672,440 |
| mean | 46,904,329 |
| p50 | 58,658,032 |
| p90 | 81,180,089 |
| p95 | 141,746,792 |
| p99 | 156,482,393 |
| max | **198,161,253** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **111** | **100.0 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **0** | **0.0 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f82 | s00965g0f00 s6 | 198 | 7 | 1 | 0 | 18 | 22 |
| 2 | f12 | s00802g0f01 s3 | 156 | 0 | 29 | 5 | 29 | 3 |
| 3 | f27 | s00612g2f01 s5 | 145 | 0 | 17 | 7 | 17 | 22 |
| 4 | f05 | s00661g0f01 s2 | 142 | 0 | 30 | 5 | 30 | 1 |
| 5 | f06 | s00661g0f01 s3 | 142 | 0 | 30 | 5 | 30 | 1 |
| 6 | f07 | s00661g0f01 s4 | 142 | 0 | 30 | 5 | 30 | 1 |
| 7 | f64 | s00965g0f00 s7 | 104 | 7 | 1 | 0 | 20 | 22 |
| 8 | f02 | s00529g0f00 s3 | 92 | 0 | 31 | 6 | 31 | 3 |
| 9 | f45 | s00965g0f00 s19 | 88 | 7 | 3 | 2 | 24 | 12 |
| 10 | f21 | s00965g0f00 s12 | 83 | 3 | 19 | 7 | 23 | 18 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.264 |
| max_ord_internal_width | +0.239 |
| total_vars | +0.697 |
| unconstrained_other | -0.205 |
| max_width | +0.442 |
| n_ordinary | -0.358 |

## Comparación con referencias

| Métrica | 8×8/10 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 111 | 59 | 408 |
| p50 (M) | 58 | 75 | 143 |
| p90 (M) | 81 | 403 | 1,131 |
| max (M) | 198 | 1,591 | 6,268 |
| > 1.1B | 0 (0.0%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **GREEN**

**Criterio activado:** 100% exactos Python ↔ Cairo. Cero candidatos >= 900M. max gas = 198,161,253 L2 Sierra.


**Detalles:**
- 111/111 exactos Python ↔ Cairo ✓
- 111/111 por debajo de 750 M ✓
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **0 casos > 1.1B** ✓

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-8x8-10-rep2-gas-20260901.jsonl` | Raw gas + features (111 filas) |
| `benchmarks/square-snforge-bench-sq8x8_rep2-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq8x8_rep2-20260901.log` | Log snforge exact |
