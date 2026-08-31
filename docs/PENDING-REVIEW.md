Auditado y corregido `2F` sin commit ni push.

Problemas metodológicos corregidos:
- la query binaria ya no llama a `evaluate_safe_cell_exact()`; ahora calcula sólo `N_0` con VE sobre el estado refinado temporalmente a `{0}` y obtiene `N_positive = current_compatible_total - N_0`
- la expansión flood-fill de la simulación oficial ya no usa `oracle_wave_structure()` ni membership futura; las waves emergen sólo desde `T + clicked_cell = 0` y de los zeros observados
- el coste común de validación quedó separado del coste oficial de política
- la instrumentación fue auditada y renombrada: `dense_factor_capacity_touched` separado de `nonzero_factor_entries_processed`; también se cuenta la aritmética de agregación/convolución global dentro del solver comparado

Tests:
- `python3 -m unittest scripts/test_conditional_sampling_2f_flood_fill_refinement.py`
- resultado: `12 OK`
- se agregaron regresiones para:
  - binary directa vs exhaustive
  - binary independiente del exact evaluator
  - flood-fill emergente
  - final transcript match
  - path identity
  - invariantes básicos de accounting

Smoke regenerado desde cero sobre los mismos 4 casos representativos:
- output: `benchmarks/conditional-sampling-2f-smoke-20260831.jsonl`
- summary: `benchmarks/conditional-sampling-2f-smoke-20260831-summary.json`
- `12/12` rows `ok`, `0` timeouts, `0` invalid
- cada row `ok` cumple `all_partitions_ok`, `final_transcript_match`, `path_identity_ok`

Resumen smoke corregido:
- `CELL`: ok `4`, solves `82`, binary `0`, exact `82`, dense `8419780`, nonzero `122159`, bigint_add `309705`, bigint_mul `392666`, peak_nonzero `135`, max_scope `8`, max_width `7`, wall p50/max `224.58/1287.48 ms`
- `WAVE`: ok `4`, solves `133`, binary `82`, exact `51`, dense `9163124`, nonzero `225835`, bigint_add `296591`, bigint_mul `372367`, peak_nonzero `448`, max_scope `8`, max_width `7`, wall p50/max `974.71/3577.25 ms`
- `FULL-REGION`: ok `4`, solves `133`, binary `82`, exact `51`, dense `13782692`, nonzero `320046`, bigint_add `484304`, bigint_mul `592729`, peak_nonzero `1504`, max_scope `8`, max_width `7`, wall p50/max `1190.04/4539.25 ms`

Lectura útil para auditar:
- con query binaria realmente binaria, flood-fill emergente y accounting comparable, `CELL` sigue ganando en wall-clock oficial sobre estos 4 casos
- `FULL-REGION` sigue siendo claramente el más caro
- `WAVE` queda entre ambos por wall-clock y por varias métricas estructurales, pero no domina a `CELL`
- esto sigue siendo smoke de `4` casos; no es decisión final sobre los `22`

Archivos tocados en esta tanda:
- `scripts/conditional_sampling_2f_flood_fill_refinement.py`
- `scripts/test_conditional_sampling_2f_flood_fill_refinement.py`
- `benchmarks/conditional-sampling-2f-smoke-20260831.jsonl`
- `benchmarks/conditional-sampling-2f-smoke-20260831-summary.json`
- `docs/PENDING-REVIEW.md`

`git status --short` actual:
- ` M docs/PENDING-REVIEW.md`
- `?? benchmarks/conditional-sampling-2f-smoke-20260831-summary.json`
- `?? benchmarks/conditional-sampling-2f-smoke-20260831.jsonl`
- `?? scripts/conditional_sampling_2f_flood_fill_refinement.py`
- `?? scripts/test_conditional_sampling_2f_flood_fill_refinement.py`

Recomendación:
- antes de correr los `22` flood-fills completos, revisar el summary corregido y decidir si este smoke ya alcanza como gate metodológico; no hay bloqueo técnico fuerte restante, pero la muestra sigue siendo chica.
