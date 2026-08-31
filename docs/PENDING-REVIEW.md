# PENDING REVIEW

Fecha de checkpoint: 2026-08-31

Al retomar una sesión, verificar `HEAD` y working tree con:

- `git log -1 --oneline`
- `git status --short`

## Estado

- `2E2` es el candidato operativo.
- `2E3` está cerrado.
- El análisis estructural de flood-fill ya quedó cerrado y persistido.

## Señales a conservar

- `23` clicks con outcome `0`; `22` flood-fills reconstruibles.
- multiplicador relevante:
  `new_revealed` mediana `14.5`, p95 `38.9`, max `41`
- backlog máximo:
  `WAVE` `10`, `FULL-REGION` `22`
- ninguna de `CELL` / `WAVE` / `FULL-REGION` quedó descartada
- gap del dataset:
  `C03` click `47`

## Corrección conceptual para el próximo experimento

- La comparación `CELL` / `WAVE` / `FULL-REGION` empieza después de que el
  click inicial ya fue determinado como `0`.
- Estado conceptual inicial:
  `T + clicked_cell = 0`
- Ese click inicial es común a las tres políticas y no cuenta como costo
  diferencial.

## Próximo paso, todavía no iniciado

- `2F — Flood-fill refinement horizon`
- una única VE generalizada con allowed sums `{0}`, `{1..d}`, `{k}`
- validar primero en tableros pequeños contra enumeración exhaustiva antes del
  replay histórico

## Artefactos permanentes

- `scripts/analyze_flood_fill_structure.py`
- `benchmarks/flood-fill-structure-30x16-20260831.jsonl`
- `benchmarks/flood-fill-structure-30x16-20260831-summary.json`
