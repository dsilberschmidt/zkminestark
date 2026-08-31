Tanda de cierre documental formal de `2F`. Fecha: 2026-08-31.

Documentación permanente actualizada:
- [`docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`](/home/cactussediento/Proyectos/zkminestark/docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md)
  - agregada sección final de `2F` con pregunta experimental, semántica `CELL/WAVE/FULL-REGION`, correcciones metodológicas, corpus, tests, resultados, señales estructurales, auditoría adversarial, conclusión y límite explícito sobre gas Cairo.
- [`docs/bitacora.md`](/home/cactussediento/Proyectos/zkminestark/docs/bitacora.md)
  - agregada entrada cronológica breve de cierre formal de `2F`.
- [`docs/INCOGNITAS.md`](/home/cactussediento/Proyectos/zkminestark/docs/INCOGNITAS.md)
  - actualizada la incógnita de flood-fill/refinement horizon como respondida en el modelo Python/VE actual; queda abierta sólo la traducción a coste Cairo/gas.

Roadmap:
- [`docs/ROADMAP-STARKNET.md`](/home/cactussediento/Proyectos/zkminestark/docs/ROADMAP-STARKNET.md) no fue modificado.
- No encontré en roadmap una decisión pendiente explícita entre `CELL/WAVE/FULL-REGION` que justificara tocarlo automáticamente.

Archivos modificados en esta tanda:
- [`docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`](/home/cactussediento/Proyectos/zkminestark/docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md)
- [`docs/bitacora.md`](/home/cactussediento/Proyectos/zkminestark/docs/bitacora.md)
- [`docs/INCOGNITAS.md`](/home/cactussediento/Proyectos/zkminestark/docs/INCOGNITAS.md)
- [`docs/PENDING-REVIEW.md`](/home/cactussediento/Proyectos/zkminestark/docs/PENDING-REVIEW.md)

Inconsistencias encontradas:
- Ninguna nueva en esta tanda.
- La documentación permanente quedó alineada con:
  - [`benchmarks/conditional-sampling-2f-full-20260831-summary.json`](/home/cactussediento/Proyectos/zkminestark/benchmarks/conditional-sampling-2f-full-20260831-summary.json)
  - [`benchmarks/conditional-sampling-2f-full-20260831-audit.json`](/home/cactussediento/Proyectos/zkminestark/benchmarks/conditional-sampling-2f-full-20260831-audit.json)
  - [`benchmarks/conditional-sampling-2f-full-reverse-order-20260831-summary.json`](/home/cactussediento/Proyectos/zkminestark/benchmarks/conditional-sampling-2f-full-reverse-order-20260831-summary.json)
  - [`docs/PENDING-REVIEW.md`](/home/cactussediento/Proyectos/zkminestark/docs/PENDING-REVIEW.md) anterior de auditoría

¿Puede considerarse cerrado `2F`?
- Sí, para la implementación Python/VE auditada.
- Queda fijado en docs canónicos:
  - `CELL` como política operativa de `2F`
  - `WAVE` como línea secundaria
  - `FULL-REGION` descartada como política operativa actual
- Límite mantenido:
  esto no equivale todavía a gas Cairo.

Siguiente paso técnico recomendado:
- no reabrir `2F`;
- cuando toque continuar, atacar directamente la traducción de estas señales estructurales a coste Cairo/gas dentro de la línea operativa ya fijada en `CELL`.

`git diff --stat`:
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md | 90 ++++++++`
- `docs/INCOGNITAS.md | 24 ++-`
- `docs/PENDING-REVIEW.md | 57 +++++`
- `docs/bitacora.md | 42 ++++`
- `scripts/conditional_sampling_2f_flood_fill_refinement.py | 228 +++++++++++++++++++++`
- total observado al cierre:
  `5 files changed, 382 insertions(+), 25 deletions(-)` en tracked files

`git status --short`:
- ` M docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`
- ` M docs/INCOGNITAS.md`
- ` M docs/PENDING-REVIEW.md`
- ` M docs/bitacora.md`
- ` M scripts/conditional_sampling_2f_flood_fill_refinement.py`
- `?? benchmarks/conditional-sampling-2f-full-20260831-audit.json`
- `?? benchmarks/conditional-sampling-2f-full-20260831-summary.json`
- `?? benchmarks/conditional-sampling-2f-full-20260831.jsonl`
- `?? benchmarks/conditional-sampling-2f-full-reverse-order-20260831-summary.json`
- `?? benchmarks/conditional-sampling-2f-full-reverse-order-20260831.jsonl`
- `?? docs/404-safe.md`

Mensaje de commit sugerido:
- `docs: close 2F with audited operational decision for CELL`
