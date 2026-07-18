# MINASWEEPER — Roadmap Starknet (v2, 18-jul-2026)
### Reemplaza a ROADMAP.md (que apuntaba a Mina/o1js — queda como
### referencia histórica de la rama determinista).
### Base: INCOGNITAS.md con las 7 incógnitas cerradas + adendas.

---

## DECISIONES DE DIRECCIÓN 001 (tomadas aquí; revisables solo con
## evidencia nueva de Fase 0 o dictamen legal)

**D1 — Identidad del juego: lazy sampling + entrada gratuita.**
Generación diferida con VRF (Adenda 2 de #1): sin seed, sin secreto,
sin oráculo. Régimen legal B (#2): entrada gratis, pozo patrocinado.
El azar forma parte de la identidad ("cabeza + administración del
azar", filosofía ya declarada).
- **Plan B1 (latencia)**: si Fase 0 da rojo (ver F0), pivotar a
  oráculo con integridad zk (Opción A + Adenda 1 de #1): misma
  identidad de juego, ~0.1–0.3s/click, componente centralizado con
  bond slasheable.
- **Plan B2 (negocio, archivado)**: determinismo certificado +
  entrada pagada. Solo se abre con dictamen legal favorable de
  habilidad pura (#2) Y la matemática de #7 madura. No es un plan de
  contingencia: es otro producto. No gastar hasta que exista razón.

**D2 — Anti-espiral del récord: TEMPORADAS** (no decaimiento).
Récords por época (p.ej. mensual), rollover del pozo. Más simple de
implementar y comunicar; las "seasons" son además vocabulario nativo
del gaming. El decaimiento queda anotado como alternativa si las
temporadas resultan muy largas/cortas en la práctica.

**D3 — Score: relativo y versionado.** Puntuación = clicks − par,
donde par = ZiNi-det v1 (aproximación canónica, determinista,
función pura del tablero materializado). Récords por clase de
dificultad. La spec exacta de ZiNi-det v1 la define Daniel (#7) —
para F1 basta un placeholder honesto (3BV) marcado como provisional.

**D4 — Bots: bienvenidos y declarados.** Sin proof-of-humanity en v1.
Posicionamiento público: "gana el mejor solver, humano o no".

**D5 — Dinero real: NO hasta F5.** Todo el roadmap hasta F4 inclusive
corre en testnet / economía simulada (zona legal segura de #2).

---

## FASE 0 — Entorno + GO/NO-GO de latencia (1–2 semanas)
El resto del roadmap depende de una medición. Hacerla PRIMERO.

1. Entorno: scarb, Starknet Foundry, Dojo + Katana local, wallet.
   Documentar cada paso en Instalaciones 001. Trabajar en Claude Code.
2. Contrato de prueba MÍNIMO con Cartridge VRF: una función que pide
   aleatoriedad atómica y escribe un valor. Nada de juego todavía.
3. **Medición go/no-go (criterio escrito ANTES de medir, Adenda 3 #3)**:
   ~500 llamadas en testnet, horarios variados.
   - VERDE: p50 ≤ 2s y p95 ≤ 5s ⇒ continuar con lazy sampling.
   - ROJO: activar Plan B1 (oráculo zk) — F1 cambia de forma, el
     resto del roadmap sobrevive casi entero.
4. Verificar de paso: coste por request VRF, session keys de
   Cartridge Controller funcionando, paymaster en testnet.

**Milestone F0**: número p50/p95 real anotado + decisión verde/rojo.

## FASE 1 — Core on-chain en Dojo (3–5 semanas)
1. World de Dojo con modelos: Partida, CeldaDeterminada, Época,
   RécordPorClase, Pozo.
2. Lazy sampling on-chain: UNA semilla VRF por click alimentando un
   stream PRF para todos los sorteos hipergeométricos del click
   (flood-fill = una sola espera). Invariante sagrado: ningún número
   se afirma antes de determinar su vecindario (Adenda 2 #1).
3. Optimización de clicks determinados (Adenda 3 #3): click sobre
   celda ya determinada NO pide VRF — tx barata que solo registra el
   click; el cliente puede responder optimista.
4. Apertura inicial "como en Linux": celda de inicio + vecinas
   fijadas seguras antes del primer sorteo, a 0 clicks.
5. Cierre de partida: computar par provisional (3BV) y score
   relativo; registrar récord por clase y época.
6. Nota de soundness: en este modelo cada click es una tx de la
   cuenta del jugador ⇒ el récord se acumula on-chain a su nombre ⇒
   el TODO(front-running) del contrato o1js queda resuelto
   ESTRUCTURALMENTE (no hay prueba de sesión que robar).

**Milestone F1**: partida completa jugada por CLI/scripts en Katana,
tablero final auditable contra el transcript de sorteos.

## FASE 2 — Cliente web (2–4 semanas, solapable con F1)
1. Portar minasweeper.html: mismo look (temas MINA/LINUX — renombrar
   tema MINA a algo propio, el chiste ya no aplica), conectado al
   World vía Controller (session keys: UN login, cero popups).
2. UX de latencia: shimmer "sorteando…" en clicks de frontera;
   respuesta instantánea en celdas determinadas; contador de clicks
   y par visibles.
3. Cooldowns de derrota (escalera 15s→…→24h) en cliente + límite de
   entradas on-chain por época (hace trabajo antisybil, ver F3).

**Milestone F2**: partida completa jugable en navegador contra
testnet por alguien que no sea Daniel.

## FASE 3 — Economía en testnet (2–3 semanas)
1. Temporadas: reset de récords por época, rollover del pozo,
   suelo mínimo de pozo (relleno post-claim). Reparto 90/10.
2. Antisybil régimen B (#5): entradas limitadas por cuenta/época +
   cooldowns + gas NO subsidiado (regla: subsidiar entrada sí, gas
   no — o con tope). Presupuesto de pozo con tope por época.
3. Simulación de agentes (script): bots greedy vs. la economía;
   ajustar parámetros (duración de época, suelo, topes) con datos.

**Milestone F3**: una temporada completa simulada con 3+ cuentas y
bots, sin exploits de faucet.

## FASE 4 — Comunidad + Grant (carril PARALELO desde hoy)
1. Repo público desde F0 (el "y/o" del criterio del grant, #6).
2. Alta y presencia real en Discord Dojo/Cartridge + foro Starknet;
   preguntar allí lo de sesgo del sequencer/VRF (#3) — pregunta
   técnica legítima que además construye visibilidad.
3. PR a GNOME Mines (contador de clicks): issue primero, MR mínimo
   después (ECOSISTEMAS §4). Open source de juegos demostrable.
4. Vigilancia semanal: hackathon.starknet.org + @StarknetFndn +
   anuncio de Basecamp 14. Inscribirse a lo primero que abra.
5. **Aplicar al Seed Grant cuando**: port F1 visible en el repo +
   4+ semanas de presencia comunitaria (o hackathon/Basecamp hecho).
   Pitch: demo + plan a 3 meses (= F1–F3 de este doc) + ángulo
   diferencial (clicks-no-tiempo, lazy sampling, roadmap de
   investigación #7). Economía presentada como testnet/simulada,
   monetización "sujeta a estructuración legal".

**Milestone F4**: aplicación enviada. (Fecha manda el ecosistema.)

## FASE 5 — Mainnet entrada-gratuita (lejos; solo tras F1–F4)
Requisitos previos NO negociables:
1. Consulta con abogado de juego (aunque sea gratis: blindar "sin
   desembolso encubierto"; depósito reembolsable a su lista) (#2).
2. Simulación de agentes en verde con parámetros finales (#5).
3. Revisión externa del World (audit ligero mínimo).
4. Fuente del pozo definida (grant/tesorería/patrocinio) con tope
   por época presupuestado en Finanzas 001.
5. MiCA (jul-2026, ya en vigor): revisar custodia/movimiento de
   tokens del pozo con el abogado.

## CARRIL MATEMÁTICO (de Daniel, sin fecha — #7)
- Spec ZiNi-det v1 (lo único que el producto NECESITA de este carril;
  desbloquea el par definitivo de F3).
- Después, a su ritmo: dureza del mínimo-con-chords (resultado
  original disponible), calidad de ZiNi-det vs. óptimo,
  caracterización a priori. Lecturas: Kaye 2000; Scott/Stege/van
  Rooij 2011; Becerra 2015; notas de Tatham; wiki minesweepergame.

---

## MAPA DE PLANES B (resumen)
| Riesgo | Señal | Plan B |
|---|---|---|
| Latencia VRF injugable | F0 rojo (p50>2s o p95>5s) | Oráculo zk (Opción A+Adenda 1): mismo juego, servidor con bond |
| Cartridge VRF caro/inmaduro | Coste por request alto en F0 | Pragma u otro VRF SOLO si es atómico; si no, oráculo |
| Sequencer/VRF sesgado | Evidencia o aviso comunidad | Escalar en foro; pozo pausable por época |
| Faucet farmeado (mainnet) | Drenaje anómalo del pozo | Topes por época ya diseñados = pérdida acotada; endurecer límites |
| Sin hackathon/Basecamp en otoño | Nada anunciado a oct-2026 | Aplicar por la vía "y/o" con repo + comunidad |
| Grant rechazado | — | Propulsion (programa gaming), créditos de fees, re-aplicar con F3 hecho |
| Se desea entrada pagada | Dictamen legal favorable | Plan B2: rama determinista (ROADMAP.md viejo + S-two/Integrity) |

## Próximos 7 días (concreto)
1. Crear repo público + copiar docs (este, INCOGNITAS.md).
2. Instalar entorno F0.1 y documentar en Instalaciones 001.
3. Alta en Discord Dojo/Cartridge.
4. Contrato de prueba VRF + empezar la medición go/no-go.
5. Abrir el issue en GNOME Mines (el pitch de diseño ya está escrito
   en ECOSISTEMAS §4 — llevarlo tal cual).
