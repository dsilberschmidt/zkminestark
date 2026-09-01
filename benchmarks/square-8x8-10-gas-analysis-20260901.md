# Square 8×8/10 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 104  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **104/104** |
| Tests exact PASS | **104/104** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (104 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 104 |
| min | 1,672,440 |
| mean | 63,435,401 |
| p50 | 53,948,856 |
| p90 | 138,739,831 |
| p95 | 258,737,329 |
| p99 | 260,253,414 |
| max | **260,762,011** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **104** | **100.0 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **0** | **0.0 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f18 | s00070g0f00 s11 | 261 | 2 | 19 | 7 | 22 | 20 |
| 2 | f19 | s00070g0f00 s10 | 260 | 1 | 19 | 7 | 21 | 21 |
| 3 | f25 | s00070g0f00 s9 | 260 | 0 | 19 | 7 | 19 | 22 |
| 4 | f23 | s00070g0f00 s7 | 260 | 0 | 19 | 7 | 19 | 24 |
| 5 | f24 | s00070g0f00 s8 | 260 | 0 | 19 | 7 | 19 | 24 |
| 6 | f29 | s00070g0f00 s13 | 259 | 0 | 18 | 7 | 18 | 17 |
| 7 | f20 | s00070g0f00 s15 | 223 | 0 | 20 | 7 | 20 | 17 |
| 8 | f21 | s00070g0f00 s16 | 223 | 0 | 20 | 7 | 20 | 17 |
| 9 | f22 | s00070g0f00 s17 | 223 | 0 | 20 | 7 | 20 | 17 |
| 10 | f08 | s00160g0f01 s5 | 190 | 0 | 29 | 6 | 29 | 1 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.300 |
| max_ord_internal_width | +0.524 |
| total_vars | +0.493 |
| unconstrained_other | -0.122 |
| max_width | +0.157 |
| n_ordinary | -0.278 |

## Comparación con referencias

| Métrica | 8×8/10 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 104 | 59 | 408 |
| p50 (M) | 53 | 75 | 143 |
| p90 (M) | 138 | 403 | 1,131 |
| max (M) | 260 | 1,591 | 6,268 |
| > 1.1B | 0 (0.0%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **GREEN**

**Criterio activado:** 100% exactos Python ↔ Cairo. Cero candidatos >= 900M. max gas = 260,762,011 L2 Sierra.


**Detalles:**
- 104/104 exactos Python ↔ Cairo ✓
- 104/104 por debajo de 750 M ✓
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **0 casos > 1.1B** ✓

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-8x8-10-gas-20260901.jsonl` | Raw gas + features (104 filas) |
| `benchmarks/square-snforge-bench-sq8x8-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq8x8-20260901.log` | Log snforge exact |
