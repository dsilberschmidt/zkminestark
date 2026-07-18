# MINASWEEPER — Hoja de ruta on-chain

Objetivo: del prototipo + contrato actual a un juego funcionando en devnet de Mina,
resolviendo los TODO en orden de riesgo. El trabajo matemático (resolubilidad a priori)
queda explícitamente para después.

Artefactos de partida: `minasweeper.html` (prototipo jugable) y `MinaSweeper.ts`
(SmartContract + GameProgram, o1js v2.x).

---

## Fase 0 — Entorno (½ día)

```bash
npm install -g zkapp-cli
zk project minasweeper        # scaffolding con o1js incluido
```

Estructura sugerida:
```
minasweeper/
  contracts/src/MinaSweeper.ts   ← copiar el contrato aquí y hacerlo compilar
  contracts/src/rules.ts         ← extraer la regla de clausura (ver Fase 2)
  contracts/test/                ← tests con Mina.LocalBlockchain
  ui/                            ← el prototipo html, luego app web
```

Herramienta recomendada: **Claude Code** sobre este repo. El trabajo que viene es un
bucle compilar → medir → trocear → repetir, y eso exige entorno real, no chat.
Docs: https://docs.claude.com/en/docs/claude-code/overview

**Milestone F0**: `npm run build` compila el contrato sin errores de tipos.

---

## Fase 1 — Medición del circuito (LA incógnita crítica)

Todo lo demás depende de si `click` cabe en un circuito de Kimchi.

1. `await GameProgram.analyzeMethods()` → filas por método. Anotar números.
2. Si `click` excede el límite (~2^16 filas) → **TODO(chunking)**:
   - Extender `GameState` con un cursor `(clickIndex, cellRangeStart)`.
   - Sub-pruebas que verifican la clausura para rangos de 60–120 celdas,
     encadenadas por recursión; el paso final del click exige cursor completo.
3. Optimizaciones antes de trocear (más baratas):
   - `adjCount` se recalcula por vecino → cachear los 480 conteos una vez por paso.
   - Los conteos de adyacencia pueden entrar como witness empaquetado
     (480 valores de 4 bits = 4 Fields) verificado una sola vez contra el tablero.
4. Medir tiempo real de prueba por click en portátil. Si es de minutos,
   replantear la granularidad (¿un paso = k clicks?) antes de seguir.

**Milestone F1**: una partida completa (start → clicks → finish) probada y verificada
en `Mina.LocalBlockchain`, con tiempos anotados.

---

## Fase 2 — Soundness (TODOs de seguridad)

1. **TODO(front-running)** — prioridad máxima antes de cualquier red pública:
   añadir `claimerHash: Field` a `GameState`, fijado en `start` con
   `Poseidon(claimerPubKey)`; `claimRecord` exige que coincida con el sender.
   Test: intentar reclamar con la prueba de otra wallet → debe fallar.
2. **Motor de reglas único**: extraer la regla de clausura a `rules.ts` con dos
   implementaciones (JS rápido para el cliente / provable para el circuito) y
   tests de equivalencia con partidas aleatorias (fuzzing ligero).
3. Tests negativos mínimos:
   - máscara no monótona → rechazada
   - revelar una mina → rechazada
   - celda revelada sin justificación (ni click, ni cero vecino, ni chord) → rechazada
   - `finish` con celdas seguras sin revelar → rechazada
   - contador de clicks manipulado → imposible por construcción (verificarlo igual)

**Milestone F2**: suite de tests en verde, incluida la prueba de robo de claim.

---

## Fase 3 — Estado y concurrencia

1. **Witnesses obsoletos**: dos entradas simultáneas al mismo seed se pisan.
   Migrar el registro a Actions/Reducer (cola de entradas) u OffchainState.
2. **TODO(cooldown)**: OffchainState por `(jugador, seed)` con `lastEntrySlot`
   (`this.network.globalSlotSinceGenesis`) y la escalera acordada:
   15s → 1m → 1m → 1m → aviso de último intento → 24h.
   Nota de diseño: on-chain se limitan ENTRADAS, no derrotas (nadie reporta
   su propia derrota); el cooldown de derrota fino vive en el cliente.
3. **TODO(seeds verificables)**: commitment derivado de fuente pública
   (hash de bloque futuro o VRF) para que ni el registrador conozca el tablero.
   Flag opcional por seed: "certificado resoluble sin adivinar" (solver offline).
   Ambos modos coexisten: solo cabeza / cabeza + administración del azar.

**Milestone F3**: dos wallets locales entrando al mismo seed sin pisarse.

---

## Fase 4 — Devnet

1. `zk config` + deploy a devnet, MINA de faucet.
2. UI real: portar el prototipo a app web con o1js en browser + Auro wallet.
   - Los proofs tardan → UX: se juega primero, la prueba se genera en un
     web worker SOLO si completaste el tablero (y con opción de reanudar).
   - Temas MINA/LINUX ya resueltos en el prototipo; son puro cliente.
3. Registrar 2–3 seeds con pozo semilla y jugar de verdad.

**Milestone F4**: primer récord batido en devnet entre dos wallets distintas. 🏆

---

## Fase 5 — Antes de mainnet (lejos todavía)

- Revisión externa del circuito y de la economía del pozo (¿90/10 es estable?
  ¿mínimo de pozo? ¿fee de protocolo?).
- Decidir gobernanza de seeds oficiales.
- Después de esto: el trabajo matemático de resolubilidad a priori, con
  lectura de papers (punto de partida: Kaye 2000, NP-completitud de
  Minesweeper; literatura de generadores no-guess tipo Tatham).

---

## Reparto de trabajo sugerido por modelo

- **Opus 4.8**: suficiente para Fases 0, 2 (tests), 3 y 4 — scaffolding,
  UI, deploy, tests. Es el 80% del volumen.
- **Fable 5**: reservarlo para Fase 1 (chunking del circuito, optimización de
  constraints) y el diseño de soundness de Fase 2 — es donde el razonamiento
  extra paga de verdad.
- En ambos casos: verificar la API de o1js contra docs actuales al empezar
  cada fase; cambia rápido.
