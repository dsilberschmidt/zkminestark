Trabajar 404-safe desde el inicio, aunque la sesión siga en 100%.

- Persistir siempre a archivos los resultados experimentales, raw y summary.
- Los benchmarks largos deben correr con append + flush y poder reanudarse sin repetir trabajo completo.
- Toda operación larga debe dejar checkpoints técnicos reanudables en archivos distintos de `docs/PENDING-REVIEW.md`.
- Nada importante puede existir sólo en terminal, contexto de Codex o memoria de sesión.
- Evitar imprimir archivos grandes, JSONL, JSON completos, diffs enormes, código completo o contenido de archivos eliminados.
- Al borrar o reemplazar archivos grandes, hacerlo silenciosamente.
- `docs/PENDING-REVIEW.md` no es checkpoint 404: contiene sólo el output final relevante del último prompt para pasar a ChatGPT.
- Si hace falta checkpoint intermedio, usar otro archivo temporal o artefacto técnico dedicado.
- Nunca hacer commit.
- Nunca hacer push.

---

## Convención de documentos operativos (acordada 2026-09-01)

### `docs/RUNNING-STATUS.md` — fotografía viva durante ejecuciones largas
Reemplazable en cualquier momento durante una tanda experimental activa. No es append-only.
Contiene el estado actual: qué está corriendo, qué se ha visto hasta ahora, qué queda.
Puede ser sobreescrito sin registro previo porque `docs/bitacora.md` es la fuente de historia.
**Decisión de versionado (conservadora)**: se incluye en el commit de cierre de campaña como
snapshot final del estado al momento de cerrar la tanda. No se versiona durante ejecuciones
intermedias. Justificación: preserva el contexto exacto de cierre sin contaminar el historial
con estados transitorios.

### `docs/PENDING-REVIEW.md` — cierre final de la última tanda
Contiene el informe final de la tanda más reciente: qué se intentó, qué quedó demostrado,
addresses/hashes completos, afirmaciones verificadas contra evidencia. Se reemplaza al inicio
de cada nueva tanda (con registro previo en bitácora). No es append-only.
**Invariante**: cada afirmación en PENDING debe estar respaldada por evidencia directa (TX hash,
log, output verificado). Nunca extrapolar a tipos de cuenta, redes o escenarios no testeados.

### `docs/bitacora.md` — historia append-only
Registro permanente de cierre de tandas. Antes de reemplazar PENDING-REVIEW, se hace append
a bitácora con header fecha/hora. Nunca se sobreescribe; nunca se elimina contenido existente.
Contiene también correcciones, addenda y decisiones durables.
