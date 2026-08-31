# 2G checkpoint — acumulador shootout
# Fecha: 2026-08-31 — checkpoint 404-safe (NO es PENDING-REVIEW)

## Rangos reales del state key (corpus 2E2, 120 casos, todos los factores intermedios)

| Dimensión | Rango observado | Valores distintos |
|-----------|----------------|-------------------|
| scope_len | 0..7 | — |
| mask | 0..127 | 2^scope_len posibles |
| mines_used | 0..30 | 31 valores (0..30 inclusive) |
| x_mine | 0..1 | 2 valores |
| nbrs | 0..4 | 5 valores |
| nonzero entries per factor (total) | máx 103 | — |
| nonzero state-keys per mask | máx 17 | — |

### Por qué `mines_used` llega a 30
- `mines_used` NO está limitado por el scope actual del factor
- Acumula el conteo de minas de TODAS las variables eliminadas hasta ese punto
- En un componente de 23 variables del corpus 30×16/99, con hasta 30 minas restantes,
  las variables eliminadas pueden tener hasta ~20-30 minas en total

### Dense table analysis
Para tabla densa indexada por (mask, mines, x_mine, nbrs):
- scope=3: 2³ × 31 × 2 × 5 = 2,480 slots
- scope=7: 2⁷ × 31 × 2 × 5 = 39,680 slots
- Sparsity: 103 nonzero / 39,680 slots = 0.26%
→ Dense table es inviable: setup O(39,680) writes en Cairo × coste por write = prohibitivo

### Packing key para Felt252Dict
key = mask + 128 * (mines + 31 * (x_mine + 2 * nbrs))
- Rango: 0..39,679 → cabe en felt252
- Para ordinary VE (x_mine=0, nbrs=0): key = mask + 128 * mines → rango 0..3,967

## Variante elegida para el shootout

- Baseline: linear-scan/rebuild O(n²) (ya medido)
- Alt A: Felt252Dict<u128> accumulator O(1) amortizado por inserción
  - Ventaja: get/insert O(1), sin rebuild
  - Costo: squash al destruir, must track keys separately
  - Limitación: u128 (≤ 128 bits), suficiente para fixtures chain pero no corpus 471-bit
- Alt B (descartada): dense array setup cost O(39,680 writes) > O(103 accumulate ops)

## Plan de implementación
- Añadir `join_factors_dict` a ve.cairo usando Felt252Dict<u128>
- Mismo output type (Factor), misma semántica
- Tests de equivalencia con baseline
- Medir f3/f6/f7 con ambas variantes

## Estado
- [x] Rangos auditados
- [x] Dense descartada
- [x] Felt252Dict seleccionada
- [ ] Implementación Alt A
- [ ] Tests equivalencia
- [ ] Benchmark comparativo
