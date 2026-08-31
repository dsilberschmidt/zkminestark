# PENDING-REVIEW — 2G Phase 7: Full CELL pipeline en Cairo
# Fecha: 2026-08-31

## Qué es Phase 7

Phase 7 implementa y mide el pipeline CELL completo en Cairo: dada la estructura pública del
problema para una celda clickeada, produce los 10 conteos de outcome (mine + clues 0..8).

Pipeline:
1. Joint VE sobre el componente especial → `Array<JointEntry>`
2. VE ordinaria sobre cada componente ordinario → `Array<u256>`
3. Convolución ordinal al agregado (`convolve_ordinary`)
4. Factor unconstrained local (`apply_unconstrained_local`)
5. Extracción de outcomes vía binomiales (`extract_outcomes`)

## Archivos nuevos

| Archivo | Rol |
|---------|-----|
| `contracts/zkmine_2g/src/cell.cairo` | Pipeline CELL: convolve_ordinary, apply_unconstrained_local, extract_outcomes |
| `contracts/zkmine_2g/src/tests/test_ve_phase7.cairo` | Gas benchmark: 120 tests, solo pipeline sin assertions de valores |
| `contracts/zkmine_2g/src/tests/test_ve_phase7_exact.cairo` | Correctness: 120 tests con los 10 outcomes exactos en u512 por caso |
| `benchmarks/2g-phase7-fixtures-20260831.jsonl` | 120 fixtures con estructura canónica + expected outcomes |
| `benchmarks/2g-phase7-stats-20260831.json` | Stats de gas extraídas del run |
| `benchmarks/2g-phase7-snforge-combined-20260831.log` | Log completo del run snforge (240 tests) |

## Resultado: 240/240 PASS — todo el corpus

```
snforge test "p7_"   →   240 passed, 0 failed, 0 ignored
```

(120 benchmark + 120 exact, mismo corpus 2A 30×16/99)

## Gas benchmark (Phase 7 — pipeline completo sin assertions de valor)

| Métrica | L2 sierra gas |
|---------|---------------|
| min | 44,465,577 |
| p50 | 111,191,179 |
| p90 | 278,493,128 |
| p95 | 342,618,654 |
| p99 | 446,960,364 |
| max | **449,028,297** |
| mean | 142,576,712 |
| worst case | 2a_064 |

**% casos < 1.1B gate: 100% (120/120)**

## Overhead assertions exactas (exact − benchmark)

| Métrica | Gas |
|---------|-----|
| min | 16,430 |
| p50 | 19,030 |
| p90 | 20,830 |
| max | 21,430 |
| max como % del max benchmark | **0.005%** |

Los valores de Phase 7 benchmark son el costo real del algoritmo sin contaminar.

## Comparación Phase 6 vs Phase 7

| Phase | Algoritmo | Max gas |
|-------|-----------|---------|
| Phase 6 | Joint VE sola (count_joint_component_with_order) | 261,796,804 |
| Phase 7 | Pipeline CELL completo | 449,028,297 |

Diferencia: +187M gas por el pipeline adicional (ordinary VE conv + unc_local + extract_outcomes).
Ambas fases 100% bajo el gate de 1.1B.

## Correctness: paridad Python↔Cairo para outcomes

120/120 casos verifican los 10 outcomes exactos (u512) contra el oracle Python:
- mine count
- clue-0 .. clue-8 counts

Sin ningún fallo. Confirmación de que:
- `convolve_ordinary` aplica correctamente ordinary VE al agregado joint
- `apply_unconstrained_local` expande correctamente los factores unconstrained
- `extract_outcomes` computa C(unc_other, k) × count y clasifica correctamente
- Los conteos en u32 antes del binom son válidos (ningún overflow detectado)
- Los u512 de outcome coinciden bit a bit con Python

## Afirmaciones finales

| Afirmación | Evidencia |
|------------|-----------|
| 120/120 CELL completo < 1.1B gate | test_ve_phase7: max 449M gas |
| Outcomes exactos Python↔Cairo (10 per case, 1200 assertions) | test_ve_phase7_exact: 120 PASS |
| Overhead assertions = 0.005% del gas de algoritmo | overhead max 21,430 gas |
| Pipeline CELL viable on-chain para corpus 30×16/99 | 100% casos bajo gate |

## git status --short (relevante)

```
 M contracts/zkmine_2g/src/lib.cairo
 M contracts/zkmine_2g/src/tests.cairo
?? benchmarks/2g-phase7-fixtures-20260831.jsonl
?? benchmarks/2g-phase7-snforge-combined-20260831.log
?? benchmarks/2g-phase7-stats-20260831.json
?? contracts/zkmine_2g/src/cell.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase7.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase7_exact.cairo
?? scripts/gen_phase7_cairo_tests.py
?? scripts/gen_phase7_fixtures.py
```

**STOP.**
