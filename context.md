# zkminestark — Contexto para Claude Code

Buscaminas competitivo on-chain (Starknet/Dojo). Score = clicks, no tiempo.
Diseño central: lazy sampling — el tablero no existe hasta que se clickea, VRF verificado on-chain por cada click.

## Protocolo de trabajo — no negociable

- Un comando por vez. Confirmación explícita de Daniel antes de ejecutar CUALQUIER cosa — incluidas lecturas.
- Nunca ejecutar transacciones, deploys, ni cambios de configuración sin confirmación previa.
- Todo resultado que Daniel necesite revisar va PRIMERO a pending_review.md, completo y sin truncar. Recién después, un resumen corto en el chat.
- Antes de sobrescribir pending_review.md con contenido nuevo: appendear su contenido actual a docs/bitacora.md con fecha/hora.
- Si algo falla o da un resultado inesperado: parar y reportar. No encadenar intentos nuevos por cuenta propia.
- No asumir compatibilidad de versiones sin verificar (fuente concreta o prueba empírica) — ya costó horas de diagnóstico varias veces en este proyecto.
- No agrandar el alcance de una tarea ("ya que estoy, agrego..."). Alcance fijo se respeta.
- Ningún secreto/clave privada real se tipea, pega, o pasa a Claude Code bajo ninguna circunstancia — ni siquiera en la terminal. Ese paso lo hace Daniel manualmente, fuera de cualquier sesión de agente, usando read -s NOMBRE_VAR (oculta el input y no lo registra en el historial de bash) en vez de export VAR=valor directo.

## Dónde está el detalle

- docs/INSTALACIONES-001.md — estado técnico completo, contratos desplegados, diagnósticos de bugs resueltos.
- docs/ROADMAP-STARKNET.md — fases del proyecto, decisiones de diseño (D1-D5).
- docs/INCOGNITAS.md — decisiones de diseño de fondo (lazy sampling, legal, arquitectura de prueba).
- docs/bitacora.md — registro histórico completo de sesiones de trabajo pasadas.

## Modos de fallo ya vistos (no repetir)

- sncast --profile no funciona confiablemente fuera del directorio con snfoundry.toml — usar --account + --accounts-file explícitos.
- Katana es efímero — direcciones de contratos desplegados dejan de ser válidas al reiniciar el proceso.
- Verificar SIEMPRE con datos reales (leer estado on-chain, mostrar output completo) — nunca asumir que "no dio error" significa "está bien".
