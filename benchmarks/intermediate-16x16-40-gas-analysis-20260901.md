# Intermediate 16×16/40 — Cairo CELL Gas Benchmark

**Fecha:** 2026-09-01  
**Candidatos:** 59 (de `intermediate-16x16-40-candidates-20260901.jsonl`)  
**Comparado con:** Expert 30×16/99 Phase 8 (408 CELLs)

---

## Metodología

1. **Fixtures:** Reconstrucción determinista desde (seed, strategy) usando la misma infraestructura Phase 8. Para cada candidato se reprodujo el estado exacto del tablero en la etapa (flood, step) indicada. Se extrajo: constraints completos, min_fill_order (VE hint), oracle outcomes exactos via `evaluate_safe_cell_exact`.
2. **Tests Cairo:** Un test benchmark (sin assertions) + un test exact (10 assertions de outcome) por candidato. Nomenclatura `im_f{i:02d}` / `im_exact_f{i:02d}` con i = índice del candidato (0–58).
3. **Ejecución:** `snforge test --max-n-steps 4294967295 --max-threads 1` en shards de 1 módulo. Tests ejecutados en `contracts/zkmine_2g`.
4. **Gas medido:** L2 Sierra gas por test individual (no combinado, no acumulado por flood).

---

## Exactitud Python ↔ Cairo

| Métrica | Valor |
|:--------|------:|
| Candidatos ejecutados | **59/59** |
| Tests benchmark PASS | **59/59** |
| Tests exact PASS | **59/59** |
| Fallos de exactitud | **0** |
| Delta exact−bench (media) | ~16,453 gas (overhead de 10 assertions) |
| Delta siempre positivo | ✓ (exact siempre ≥ bench) |

**59/59 exactos Python ↔ Cairo. Sin ningún fallo de correctness.**

---

## Estadísticas de gas L2 Sierra (59 candidatos)

| Estadístico | Gas L2 Sierra |
|:------------|-------------:|
| n | 59 |
| min | 5,729,640 |
| mean | 215,419,167 |
| p50 | 75,189,011 |
| p90 | 402,800,340 |
| p95 | 1,573,439,705 |
| p99 | 1,591,439,034 |
| max | **1,591,439,034** |

### Distribución por bucket (gate Starknet = 1.1 B L2 gas)

| Bucket | Count | % |
|:-------|------:|--:|
| < 750 M | **56** | **94.9 %** |
| 750 M – 900 M | 0 | 0 % |
| 900 M – 1.1 B | 0 | 0 % |
| **> 1.1 B** | **3** | **5.1 %** |

---

## Casos > 1.1 B (3 total)

Todos del mismo flood: seed=82, strategy=0, flood_id=s00082g0f03.

| fixture | flood_id_step | gas (B) | max_width | total_vars | sum_ord_size | unc_oth |
|:--------|:--------------|--------:|----------:|-----------:|-------------:|--------:|
| f33 | s00082g0f03_s003 | **1.591** | 0 | 86 | 86 | 8 |
| f34 | s00082g0f03_s005 | **1.588** | 0 | 84 | 84 | 6 |
| f36 | s00082g0f03_s013 | **1.573** | 0 | 81 | 81 | 3 |

**Característica clave:** estos 3 casos tienen max_width=0 (sin special component), pero un componente ordinario muy grande con ~80–86 vars y VE ancho interno=6. La ausencia de special component significa que se usa `count_ordinary_component` para la VE, que también es O(n · 2^w) pero sin la pista de ordering explícita.

---

## Top 10 por gas

| # | fixture | case | gas (M) | max_w | vars | n_ord | sum_ord | unc_oth |
|--:|:--------|:-----|--------:|------:|-----:|------:|--------:|--------:|
| 1 | f33 | s00082g0f03 s3 | 1,591 | 0 | 86 | 2 | 86 | 8 |
| 2 | f34 | s00082g0f03 s5 | 1,588 | 0 | 84 | 2 | 84 | 6 |
| 3 | f36 | s00082g0f03 s13 | 1,573 | 0 | 81 | 2 | 81 | 3 |
| 4 | f08 | s00038g0f01 s9 | 425 | **8** | 53 | 0 | 0 | 145 |
| 5 | f40 | s00213g0f03 s7 | 403 | 0 | 80 | 1 | 80 | 49 |
| 6 | f41 | s00213g0f03 s8 | 403 | 0 | 80 | 1 | 80 | 49 |
| 7 | f42 | s00213g0f03 s9 | 403 | 0 | 80 | 1 | 80 | 49 |
| 8 | f01 | s00374g0f02 s4 | 371 | **8** | 68 | 0 | 0 | 97 |
| 9 | f35 | s00213g0f04 s3 | 340 | 0 | 83 | 1 | 83 | 27 |
| 10 | f39 | s00447g0f03 s2 | 300 | 0 | 81 | 1 | 81 | 11 |

---

## Casos width=8 (9 CELLs — riesgo estructural identificado ex-ante)

| fixture | case | gas (M) | vars |
|:--------|:-----|--------:|-----:|
| f08 | s00038g0f01 s9 | **425** | 53 |
| f01 | s00374g0f02 s4 | 371 | 68 |
| f00 | s00374g0f02 s9 | 297 | 70 |
| f02 | s00349g0f01 s5 | 234 | 66 |
| f03 | s00349g0f01 s4 | 226 | 64 |
| f05 | s00349g0f01 s3 | 200 | 63 |
| f04 | s00349g0f01 s2 | 198 | 63 |
| f06 | s00349g0f01 s1 | 168 | 59 |
| f07 | s00038g2f03 s9 | 168 | 54 |

**Rango: 168 M – 425 M. Todos bien por debajo del gate de 750 M.**

> Sorpresa respecto al análisis estructural previo: los 9 casos max_width=8 (identificados como el riesgo principal) son baratos. La ausencia de n_ord>0 en todos ellos mitiga completamente el VE: la special component con width=8 pero sin ordinary components adicionales resulta manejable (~168–425 M gas).

---

## Correlaciones gas ↔ features estructurales

| Feature | r con bench_gas | Interpretación |
|:--------|----------------:|:---------------|
| total_vars | **+0.517** | Mejor predictor lineal |
| sum_ord_size | **+0.509** | Casi idéntico a total_vars |
| unconstrained_other | −0.244 | Negativo: tableros avanzados más caros |
| n_ordinary | −0.172 | Contradictorio: más componentes no implica más gas |
| total_constr | +0.096 | Predictor débil |
| max_width | −0.075 | **No discrimina** en Intermediate |

**Hallazgo clave:** max_width es el predictor dominante en Phase 8 Expert (r≈+0.22 descriptivo), pero en Intermediate la correlación es **negativa y débil** (r=−0.075). Esto se explica porque los 9 casos width=8 tienen n_ord=0 y son baratos, mientras que los casos caros tienen max_width=0 (ordinary-dominated). El predictor real es **total_vars / sum_ord_size**.

---

## Comparación directa con Expert Phase 8

| Métrica | Intermediate | Expert |
|:--------|-------------:|-------:|
| n | 59 | 408 |
| p50 | 75 M | 143 M |
| p90 | 403 M | 1,131 M |
| p95 | 1,573 M | 5,548 M |
| max | **1,591 M** | **6,268 M** |
| > 1.1 B | **3 (5.1 %)** | 45 (11.0 %) |
| > 1.1 B floods distintos | 1 | 4 |

La distribución Intermediate es considerablemente más barata que Expert (p50 2× menor, max 4× menor). Sin embargo, la presencia de 3 casos > 1.1B en un único flood confirma que Intermediate tampoco es totalmente safe sin continuation intra-CELL.

---

## Análisis de los 3 casos RED

Todos provienen de `s00082g0f03` (seed=82, strategy=0, flood 3):
- **Patrón estructural:** sin special component, componente ordinario grande (81–86 vars) con VE ancho interno ≈ 6
- **No es el patrón de riesgo Expert:** los UNSEG Expert tenían max_width=7 + n_ord>0. Aquí max_width=0 (no hay special component)
- **Causa:** `count_ordinary_component` ejecuta VE completo sin pista de ordering; para 85 vars y ancho 6, esto equivale a ~85 × 64 = 5440 pasos de eliminación de clústeres de tamaño 2^6=64 → costoso
- **Mitigación posible:** proveer min_fill_hint también para ordinary components, o poner cap en sum_ord_size

---

## Limitaciones

1. Los 59 candidatos son los PEORES de un corpus de 187,098 CELLs (la tasa real de excedencia en el corpus completo sería inferior, ya que estos son seleccionados para maximizar riesgo).
2. Solo 3 casos exceden el gate; todos del mismo flood (seed=82). Un solo tablero problemático.
3. El runner local (snforge) no distingue entre "gas L2 Sierra" y "pasos de ejecución"; no se observaron timeouts de runner, solo medición de gas.
4. La estimación estructural previa (width=8 → riesgo principal) resultó incorrecta; el riesgo real es sum_ord_size con VE width interna alta.

---

## Veredicto

### **RED**

**Criterio activado:** 3 casos > 1,100,000,000 L2 Sierra gas (max: 1,591,439,034 = 1.45× el gate).

**Detalles:**
- 59/59 exactos Python ↔ Cairo ✓
- 56/59 por debajo de 750 M ✓
- 0 casos en [750 M, 1.1 B] ✓
- **3 casos > 1.1 B** ✗ → RED

**Flood problemático:** s00082g0f03 (seed=82, strategy=0, flood 3) con componente ordinario ~85 vars / VE ancho=6 sin special component.

**Para consideración del grant:** Intermediate 16×16/40 necesita continuation intra-CELL para los casos con sum_ord_size ≥ ~80 y VE ancho ordinario ≥ 6. Los 9 casos max_width=8 (el riesgo estructural identificado ex-ante) resultaron todos safe (max 425 M gas). El riesgo real proviene de un patrón distinto: componentes ordinarios grandes sin particionamiento especial.

---

## Artefactos

| Archivo | Descripción |
|:--------|:------------|
| `benchmarks/intermediate-16x16-40-gas-20260901.jsonl` | Raw gas + features por candidato (59 filas) |
| `benchmarks/intermediate-snforge-bench-20260901.log` | Log snforge benchmark completo |
| `benchmarks/intermediate-snforge-exact-20260901.log` | Log snforge exact completo |
| `benchmarks/intermediate-16x16-40-fixtures-20260901.jsonl` | Fixtures Cairo completos (59) |
| `contracts/zkmine_2g/src/tests/test_ve_intermediate.cairo` | 59 benchmark tests |
| `contracts/zkmine_2g/src/tests/test_ve_intermediate_exact.cairo` | 59 exact tests |
| `scripts/gen_intermediate_fixtures.py` | Generador de fixtures |
| `scripts/gen_intermediate_cairo_tests.py` | Generador de tests Cairo |
| `scripts/run_intermediate_sharded.sh` | Runner sharded |
