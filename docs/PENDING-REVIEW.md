# PENDING-REVIEW — 2G Phase 5: verified elimination-order hint
# Fecha: 2026-08-31

## Procedencia del oracle-order — Auditoría

Oracle-order auditado: `[52,53,82,55,56,86,142,172,173,146,175,176,54,84,112,113,115,116,144,174]`

**Verificación**: se ejecutó `build_elimination_plan(p12_vars, p12_constraints)` en Python:

```
min-fill order: [52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176,
                 54, 84, 112, 113, 115, 116, 144, 174]
match oracle: True
min_fill_width: 6
```

**Conclusiones de la auditoría**:

| Pregunta | Respuesta |
|----------|-----------|
| ¿Derivable de constraints/transcript públicos? | **Sí**. Solo usa la lista de variables y qué variables aparecen en cada constraint. |
| ¿Usa min-fill? | **Sí**. `_choose_min_fill_variable` elige el var con menos fill (aristas nuevas en grafo primal). Tie-break: menor degree, luego menor índice. |
| ¿Usa counts exactos? | **No**. Solo estructura booleana (var ∈ constraint). |
| ¿Usa board oculto/oracle? | **No**. La heurística es puramente estructural. |
| ¿Es determinístico desde el transcript? | **Sí**. Dado el componente, `build_elimination_plan` es determinístico. |

El término "oracle-order" fue impreciso: es el **min-fill order**, reproducible automáticamente.

**2a-109 comparación**: la heurística min-fill también difiere del sorted para 2a-109:
- min-fill: `[223, 253, 283, 224, 225, 226, 256, 284, 285, 286]`
- sorted: `[223, 224, 225, 226, 253, 256, 283, 284, 285, 286]`
Ambos válidos; min-fill elimina las hojas 253, 283 antes de las variables compartidas.

## Mecanismo de verificación del hint

### Función implementada

`count_joint_component_with_order(variables, constraints, x_var, neighbor_vars, hint_order)`

Antes de ejecutar VE, verifica on-chain:

```cairo
fn verify_permutation(vars: @Array<u32>, hint: @Array<u32>) {
    assert(hint.len() == vars.len(), 'hint: wrong length');
    // for each element in hint:
    //   assert it's in vars (no extra vars)
    //   assert no prior element in hint equals it (no duplicates)
    // len equality + all-in-vars + no-duplicates ⟹ same set (no omissions)
}
```

Complejidad: O(n²) con n ≤ 20 para P12. Clara, auditable, sin hashing ni dict.

### Propiedades de seguridad

**¿Puede un hint malicioso cambiar los joint counts?**

No. VE es semánticamente invariante al orden de eliminación — propiedad fundamental
del algoritmo. Para cualquier permutación válida (mismas variables, sin duplicados,
sin omisiones), el producto de las marginalizaciones produce el mismo joint distribution.

| Ataque | Efecto sobre counts | Efecto sobre gas |
|--------|---------------------|------------------|
| Orden subóptimo (ej. sorted) | **Ninguno** | Sube hasta ×10.6 |
| Orden reverso | **Ninguno** | Puede subir ×100+ (OOM) |
| Variable duplicada | Rechazado por verificación | N/A |
| Variable extra | Rechazado por verificación | N/A |
| Variable omitida | Rechazado por verificación | N/A |
| Longitud incorrecta | Rechazado por verificación | N/A |

Un hint malicioso **formalmente válido** sólo puede aumentar el gas — no puede
alterar los counts. El prover paga su propio gas → incentivo a proveer el orden
eficiente.

## Tests añadidos

| Test | Descripción | Resultado |
|------|-------------|-----------|
| h1 | P12 min-fill hint → 11 joint counts exactos | PASS |
| h2 | P12 sorted hint → mismos 11 counts (parity) | PASS (--max-n-steps) |
| h3 | reverso pequeño (4-var) → mismos counts | PASS |
| h4 | P12 variable duplicada → reject | PASS (should_panic) |
| h5 | P12 variable extra (999) → reject | PASS (should_panic) |
| h6 | P12 longitud incorrecta (19) → reject | PASS (should_panic) |
| h7 | 2a-109 sorted hint → 5 joint counts exactos | PASS |

Estado suite: **45/47 PASS**. Los 2 fallos restantes son j3 y h2 por step limit
(sorted order sobre P12 completo, conocido, necesita `--max-n-steps 100000000`).

Nota: h3 reverso P12 causa OOM (join de dos factores de 35 entries cada uno al inicio
→ factor gigante → prohibitivo). Se documenta como evidencia de que el worst-case
de un hint adversarial es OOM, no incorrección.

## Mediciones de gas

### Overhead de verificación en P12 (n=20 variables)

| Variante | L2/Sierra gas | Δ vs sin verificación | Δ % |
|----------|---------------|----------------------|-----|
| j3o: oracle sin verificación | 195,990,572 | — | — |
| **h1: oracle + verificación** | **197,319,222** | **+1,328,650** | **+0.68%** |
| h2: sorted + verificación | 2,072,564,863 | +1,013,290 sobre j3 | — |

### Overhead de verificación en 2a-109 (n=10 variables)

| Variante | L2/Sierra gas | Δ vs sin verificación | Δ % |
|----------|---------------|----------------------|-----|
| j1: sorted sin verificación | 23,387,266 | — | — |
| **h7: sorted + verificación** | **23,768,186** | **+380,920** | **+1.63%** |

### Overhead de rechazo (verificaciones que fallan)

| Ataque | Gas hasta rechazo |
|--------|-------------------|
| h6 longitud incorrecta | 26,660 (inmediato) |
| h4 duplicado | 1,271,630 |
| h5 variable extra | 1,327,550 |

### Cuadro completo de variantes P12

| Variante | Ordering | Verificación | L2 gas |
|----------|----------|--------------|--------|
| j3 | sorted | no | 2,071,551,573 |
| j3o | min-fill | no | 195,990,572 |
| j6 | min-fill | no (profiling) | 213,291,792 |
| h1 | min-fill | **sí** | **197,319,222** |
| h2 | sorted | sí | 2,072,564,863 |

## Min-fill order: pública y automática

La heurística `build_elimination_plan` (Python, `conditional_sampling_2e2_variable_elimination.py`):
- usa solo el grafo primal de variables (estructura de constraints)
- es O(n³) off-chain — irrelevante para el prover
- produce el mismo order que el "oracle" que se usó en benchmarks anteriores
- es completamente determinística y pública

Para producir el hint en producción:
1. Off-chain (Python/Rust): ejecutar `build_elimination_plan(component_vars, component_constraints)`
2. Pasar el ordering resultante como `hint_order` argumento
3. Cairo verifica la permutación (~1.33M gas para n=20) y ejecuta VE

No se necesita ningún conocimiento privado. El hint puede generarse directamente
desde el transcript público.

## Conclusión del gate

| Criterio | Resultado |
|----------|-----------|
| Verificación barata | ✓ 1.33M gas (~0.68% de P12 oracle VE) |
| Order automático mantiene P12 << 1.1B | ✓ 197.3M << 1,100M |
| Paridad exacta con sorted order | ✓ Mismos 11 joint counts (h1, h2, j1 vs h7) |
| Order derivable sólo de información pública | ✓ `build_elimination_plan` sobre structure pública |

**Gate PASA.** El mecanismo de elimination-order hint verificado es viable.

## Diseño de la siguiente campaña

**Objetivo**: validar el mecanismo en múltiples casos reales del corpus 30×16/99
usando orders automáticos (min-fill) generados por el solver Python.

**Setup**:
1. Correr `conditional_sampling_2e2_variable_elimination.py` sobre el corpus 30×16/99
2. Para cada componente: extraer `plan.ordering`
3. Crear test suite parametrizado o fixture JSON con (component, min_fill_order, expected_joint)
4. En Cairo: medir gas de `count_joint_component_with_order` para cada caso

**Criterio de éxito**: todos los casos del corpus producen joint counts correctos,
y el gas de los casos más costosos queda claramente < 1.1B.

**Si algún caso supera 1.1B**: documentar qué estructura tiene ese componente
(min_fill_width, número de variables, número de constraints) antes de optimizar
cualquier otra cosa.

**Nota sobre dict**: Felt252Dict mostró 2.1-2.2× más costoso para factores pequeños/sparse
(Phase 2). Los factores en el regime min-fill siguen siendo small (max 40 nonzero de 64 dense).
No adoptar dict hasta tener evidencia de que los factores superan ~100 nonzero entries.

## Archivos tocados

- `contracts/zkmine_2g/src/ve.cairo`:
  - `verify_permutation` (función interna, ~30 líneas)
  - `count_joint_component_with_order` (función pública, ~65 líneas)
- `contracts/zkmine_2g/src/tests/test_ve.cairo`:
  - import de `count_joint_component_with_order`
  - helpers `p12_sorted_vars()`, `p12_oracle_hint()`
  - 7 tests h1-h7 (~100 líneas)

## git diff --stat

```
docs/INCOGNITAS.md     |  38 +++++++
docs/PENDING-REVIEW.md | 289 ++++++++++++++++++++-----
docs/bitacora.md       | 296 ++++++++++++++++++++++++++
3 files changed, 558 insertions(+), 65 deletions(-)
```
(contracts/zkmine_2g/ es directorio untracked — cambios no reflejados en diff)

## git status --short

```
 M docs/INCOGNITAS.md
 M docs/PENDING-REVIEW.md
 M docs/bitacora.md
?? benchmarks/2g-binom-recurrence-audit-20260831.json
?? benchmarks/2g-cairo-accumulator-20260831.json
?? benchmarks/2g-cairo-bigint-cell-20260831.json
?? benchmarks/2g-cairo-ve-fixtures-20260831.json
?? benchmarks/2g-fixture-2a109-oracle.json
?? benchmarks/2g-fixture-p12-step-005-oracle.json
?? benchmarks/2g-flood-c04-step-035-sequence.json
?? benchmarks/2g-p12-joint-stage-oracle-20260831.json
?? benchmarks/2g-p12-stage-profile-local-20260831.txt
?? contracts/zkmine_2g/
?? docs/2g-checkpoint.md
```

**STOP.**
