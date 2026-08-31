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
