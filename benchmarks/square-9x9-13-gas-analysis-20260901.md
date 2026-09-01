# Square 9×9/13 — Cairo CELL Gas Benchmark

**Fecha:** 20260901  
**Candidatos:** 120  
**Criterio predeclarado:** GREEN <900M / YELLOW [900M,1.1B] / RED >1.1B

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **120/120** |
| Tests exact PASS | **120/120** |
| Fallos de exactitud | **0** |
| Exactitud % | 100.0% |

## Estadísticas de gas L2 Sierra (120 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 120 |
| min | 2,078,160 |
| mean | 51,442,551 |
| p50 | 30,664,280 |
| p90 | 117,806,215 |
| p95 | 168,968,308 |
| p99 | 340,164,866 |
| max | **340,164,866** |

### Distribución por bucket (gate Starknet = 1.1B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **120** | **100.0 %** |
| 750 M – 900 M | 0 | 0.0 % |
| 900 M – 1.1 B | 0 | 0.0 % |
| **> 1.1 B** | **0** | **0.0 %** |

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | sum_ord | ord_iw | vars | unc_oth |
|--:|:--------|:-----|--------:|------:|--------:|-------:|-----:|--------:|
| 1 | f03 | s00383g0f01 s2 | 340 | 0 | 37 | 5 | 37 | 2 |
| 2 | f04 | s00383g0f01 s3 | 340 | 0 | 37 | 5 | 37 | 2 |
| 3 | f05 | s00383g0f01 s4 | 340 | 0 | 37 | 5 | 37 | 2 |
| 4 | f01 | s00343g0f00 s4 | 200 | 0 | 37 | 5 | 37 | 8 |
| 5 | f02 | s00345g0f00 s4 | 193 | 0 | 37 | 5 | 37 | 7 |
| 6 | f11 | s00087g0f01 s3 | 169 | 0 | 35 | 5 | 35 | 4 |
| 7 | f00 | s00250g0f00 s3 | 166 | 0 | 37 | 6 | 37 | 6 |
| 8 | f16 | s00464g2f01 s2 | 147 | 0 | 25 | 7 | 25 | 14 |
| 9 | f37 | s00250g0f00 s2 | 146 | 6 | 0 | 0 | 37 | 6 |
| 10 | f38 | s00250g0f00 s4 | 146 | 6 | 0 | 0 | 37 | 6 |

## Correlaciones gas ↔ features

| Feature | r con bench_gas |
|:--------|----------------:|
| sum_ord_size | +0.480 |
| max_ord_internal_width | +0.208 |
| total_vars | +0.732 |
| unconstrained_other | -0.295 |
| max_width | +0.057 |
| n_ordinary | -0.271 |

## Comparación con referencias

| Métrica | 9×9/13 | 16×16/40 (RED) | Expert 30×16 |
|:--------|----------:|---------------:|-------------:|
| n | 120 | 59 | 408 |
| p50 (M) | 30 | 75 | 143 |
| p90 (M) | 117 | 403 | 1,131 |
| max (M) | 340 | 1,591 | 6,268 |
| > 1.1B | 0 (0.0%) | 3 (5.1%) | 45 (11.0%) |

---

## Veredicto

### **GREEN**

**Criterio activado:** 100% exactos Python ↔ Cairo. Cero candidatos >= 900M. max gas = 340,164,866 L2 Sierra.


**Detalles:**
- 120/120 exactos Python ↔ Cairo ✓
- 120/120 por debajo de 750 M ✓
- 0 casos en [750M, 900M)
- 0 casos en [900M, 1.1B]
- **0 casos > 1.1B** ✓

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/square-9x9-13-gas-20260901.jsonl` | Raw gas + features (120 filas) |
| `benchmarks/square-snforge-bench-sq9x9-20260901.log` | Log snforge benchmark |
| `benchmarks/square-snforge-exact-sq9x9-20260901.log` | Log snforge exact |
