# MINASWEEPER — Roadmap Starknet (v3, autoexplicado, 18-jul-2026)
### Versión para releer en tres semanas sin recordar nada.
### Reemplaza a la v2 (misma sustancia, ahora con términos definidos).
### El detalle técnico y los porqués completos viven en INCOGNITAS.md.

---

## GLOSARIO MÍNIMO (leer primero, volver cuando haga falta)

- **Starknet**: la blockchain donde vive el juego (una L2 de Ethereum).
- **Cairo**: el lenguaje de programación de los contratos en Starknet.
- **Dojo**: el motor open-source para juegos on-chain en Starknet.
  Un juego en Dojo se organiza en un **World** (el contrato-mundo que
  contiene los modelos de datos y las reglas).
- **scarb**: el compilador/gestor de paquetes de Cairo.
- **Katana**: una blockchain local de mentira para desarrollar y
  probar en tu máquina, sin red real.
- **Testnet**: la red pública de práctica de Starknet; los tokens no
  valen nada. **Mainnet**: la red real, con valor real.
- **VRF** (Verifiable Random Function): "un dado con acta notarial".
  Un servicio que entrega números aleatorios junto con una prueba de
  que no pudo elegirlos ni predecirlos. Lo necesitamos porque los
  contratos no pueden generar azar por sí mismos (todos los nodos
  deben recomputar lo mismo). **Cartridge VRF**: el proveedor
  candidato, porque resuelve el azar DENTRO de la misma transacción
  (patrón "atómico" = rápido). Los VRF de patrón "request/callback"
  tardan bloques extra y quedaron descartados.
- **Session keys / Cartridge Controller**: firmar UNA vez al entrar y
  que los clicks fluyan sin popup de wallet por transacción.
- **Paymaster**: mecanismo para que el protocolo pague el gas de los
  usuarios. Regla nuestra: subsidiar la entrada sí, el gas NO (o con
  tope) — si el gas es gratis, los bots atacan gratis.
- **Lazy sampling / generación diferida**: la idea central del juego
  (fue de Daniel): el tablero NO existe antes de jugarse. Cada click
  sortea en ese instante el contenido de las celdas (probabilidad =
  minas restantes / celdas restantes), con aleatoriedad del VRF.
  Nadie puede conocer de antemano un tablero que no existe ⇒ no hay
  trampas de precómputo, no hay secreto que custodiar.
- **Celda determinada**: celda cuyo contenido ya quedó fijado por un
  sorteo anterior (p.ej. al computar el número de una vecina).
  Clickearla no necesita VRF ⇒ respuesta instantánea.
- **Par**: los clicks "esperables" de un tablero, como el par de un
  hoyo de golf. Se computa al TERMINAR la partida (el tablero recién
  entonces existe completo). En v1, par = **3BV**.
- **3BV**: métrica estándar de la comunidad de buscaminas: nº de
  regiones vacías (cada una se abre con 1 click) + nº de números que
  no se abren solos con esas regiones. Algoritmo trivial, igual para
  todos. Ignora los chords ⇒ es imperfecta, pero es LA MISMA
  imperfección para todos, que es lo único que la justicia necesita.
- **Chord**: click en un número que ya tiene sus banderas puestas ⇒
  abre todos sus vecinos de golpe. Cuenta 1 click. Banderas gratis.
- **Score**: clicks − par. Cuanto más bajo, mejor. Compara a cada
  jugador contra lo que SU tablero exigía (la vara se ajusta al
  tablero; la suerte del sorteo no decide el podio).
- **Temporada/época**: período (p.ej. mensual) tras el cual los
  récords se resetean y el pozo no reclamado pasa a la siguiente.
- **Sybil**: ataque de crear muchas cuentas para multiplicar intentos.
  Con entrada gratuita es EL riesgo económico; se contiene con
  límites por cuenta/época, cooldowns y gas no subsidiado.
- **Seed Grant**: programa de la Starknet Foundation, hasta $25k en
  STRK, aplicación rolling. Requisitos: MVP + participación en la
  comunidad (hackathon, builder program, o involucramiento
  demostrable — el criterio dice "y/o").
- **Ley 13/2011 (España)**: define juego regulado como PAGO + AZAR
  (en alguna medida) + PREMIO transferible entre jugadores. Sin test
  de habilidad. Nuestro esquive: quitar el PAGO ⇒ entrada gratuita.

---

## LAS 5 DECISIONES (D1–D5), YA TOMADAS
(Revisables solo con evidencia nueva de F0 o dictamen legal.)

**D1 — Identidad: lazy sampling + entrada gratuita.** El tablero se
sortea click a click con VRF (nadie puede hacer trampa de precómputo)
y entrar es gratis (así el juego queda FUERA de la ley española de
juego, que exige pago). El pozo se financia con patrocinio/grant, no
con entradas. El azar es parte de la identidad: "cabeza +
administración del azar".
- **Plan B1 (si la latencia falla en F0)**: oráculo con integridad zk
  — un servidor genera el tablero en secreto, publica un commitment,
  y revela celdas firmadas al instante (~0.1–0.3s/click); cada
  revelación lleva prueba zk de consistencia y el servidor arriesga
  un bond si miente. Mismo juego, componente centralizado.
- **Plan B2 (archivado, NO es contingencia — es otro producto)**:
  tableros deterministas certificados "resolubles sin adivinar" ⇒
  sin azar ⇒ argumento legal de habilidad pura ⇒ entrada pagada
  posible. Solo se abre con dictamen legal favorable. Su plan de
  ejecución es el viejo ROADMAP-mina.md (docs/archivo/).

**D2 — Anti-espiral del récord: TEMPORADAS.** Problema: el récord
solo baja, se acerca al mínimo posible, se vuelve imbatible, nadie
juega, el pozo muere. Cura elegida: reset periódico de récords con
rollover del pozo (las "seasons" del gaming). Alternativa anotada:
decaimiento (+1 click/semana al récord) si las temporadas calibran
mal.

**D3 — Score relativo: clicks − par, con par = 3BV en v1,
DEFINITIVO hasta nueva versión.** Un solo leaderboard por temporada.
Las clases de dificultad quedan para v2 si los datos las piden. El
carril matemático de Daniel (mejorar el par, curva
homogeneidad↔dificultad, teoremas) es upside sin fecha: NINGÚN
milestone depende de él.

**D4 — Bots: bienvenidos y declarados.** Un bot con Bayes perfecto
le gana a casi cualquier humano y eso NO es trampa. Posicionamiento
público: "gana el mejor solver, humano o no". Sin proof-of-humanity.

**D5 — Dinero real: NO hasta F5.** Todo hasta F4 inclusive corre en
testnet/economía simulada (legalmente inocuo). Encender valor real
es un interruptor aparte, al final, con checklist propia.

---

## LAS FASES (ordenadas por RIESGO: cada una mata la duda más
## peligrosa que quede viva)

### F0 — El experimento que decide todo (1–2 semanas)
Pregunta única: ¿cuánto tarda DE VERDAD un click que pide azar al
VRF? Todo D1 se sostiene o se cae con ese número.
1. Instalar entorno: scarb, Starknet Foundry, Dojo + Katana, wallet.
   Documentar cada paso en Instalaciones 001. Trabajar en Claude Code.
2. Contrato de prueba MÍNIMO con Cartridge VRF: una función que pide
   un número y lo guarda. Nada de buscaminas todavía.
3. Medirlo ~500 veces en testnet, en horarios variados. Criterio
   escrito ANTES de medir (para no autoengañarse):
   - **VERDE**: mediana ≤ 2s y peor-caso-razonable (p95) ≤ 5s
     ⇒ seguir con lazy sampling.
   - **ROJO**: activar Plan B1 (oráculo). F1 cambia de forma; el
     resto del roadmap sobrevive casi entero.
4. De paso: coste por request del VRF, session keys funcionando,
   paymaster en testnet.
**Milestone F0**: número real de mediana/p95 anotado + verde/rojo.

### F1 — El corazón del juego, sin cara (3–5 semanas)
La lógica completa on-chain, jugada por terminal (feo pero
verificable):
1. World de Dojo con modelos: Partida, CeldaDeterminada, Época,
   Récord, Pozo.
2. Lazy sampling: UNA semilla VRF por click alimenta TODOS los
   sorteos de ese click (un flood-fill = una sola espera, nunca una
   request por celda). Invariante sagrado: ningún número se afirma
   antes de sortear su vecindario.
3. Clicks sobre celdas determinadas: sin VRF, tx barata que solo
   registra el click (el cliente puede responder al instante).
4. Apertura inicial "como en Linux": celda de inicio + vecinas
   fijadas seguras antes del primer sorteo, a 0 clicks.
5. Al terminar: computar par (3BV) y score; registrar récord por
   época.
6. Soundness gratis: cada click es una tx de la cuenta del jugador ⇒
   el récord se acumula a su nombre ⇒ nadie puede robar una partida
   ajena (el problema de front-running del diseño viejo desaparece
   por estructura).
**Milestone F1**: partida completa por CLI en Katana, tablero final
auditable contra el registro de sorteos.

### F2 — La cara (2–4 semanas, solapable con F1)
1. Conectar el prototipo minasweeper.html al World vía Controller
   (session keys: UN login, cero popups). Renombrar el tema "MINA"
   (el chiste ya no aplica).
2. Sensación: shimmer "sorteando…" en clicks de frontera; respuesta
   instantánea en celdas determinadas; clicks y par visibles.
3. Cooldowns de derrota (15s→…→24h) en cliente + límite de entradas
   on-chain por época (ya hace trabajo antisybil).
**Milestone F2**: alguien que NO sea Daniel juega una partida
completa en su navegador contra testnet.

### F3 — El dinero de juguete (2–3 semanas)
1. Temporadas: reset + rollover + suelo mínimo de pozo (relleno
   post-claim). Reparto 90/10.
2. Antisybil: entradas limitadas por cuenta/época + cooldowns + gas
   NO subsidiado. Presupuesto de pozo con tope por época.
3. Atacarla a propósito: script de bots codiciosos contra la
   economía; ajustar parámetros con datos.
**Milestone F3**: una temporada completa simulada con 3+ cuentas y
bots, sin exploit de faucet encontrado.

### F4 — La gente (carril PARALELO, arranca YA — sus tiempos no los
### controlamos)
1. Repo público ✅ (github.com/dsilberschmidt/zkminestark).
2. Presencia real en Discord Dojo/Cartridge + foro Starknet
   (preguntar allí lo del sesgo del sequencer/VRF: pregunta técnica
   legítima que además da visibilidad).
3. PR a GNOME Mines (contador de clicks): issue primero, MR mínimo
   después. El pitch ya está escrito en ECOSISTEMAS.md §4.
4. Vigilancia semanal: hackathon.starknet.org + @StarknetFndn +
   anuncio de Basecamp. Inscribirse a lo primero que abra.
5. **Aplicar al Seed Grant cuando**: port de F1 visible en el repo +
   4+ semanas de presencia comunitaria (o hackathon/Basecamp hecho).
   Pitch: demo + plan a 3 meses (= F1–F3) + diferenciales
   (clicks-no-tiempo, lazy sampling, línea de investigación).
   Economía SIEMPRE presentada como testnet/simulada, monetización
   "sujeta a estructuración legal".
**Milestone F4**: aplicación enviada.

### F5 — El dinero real (lejos; es una COMPUERTA, no una fase de
### trabajo)
Cinco candados, todos obligatorios antes de mainnet:
1. Abogado de juego consultado (blindar "sin desembolso encubierto";
   preguntar por el depósito reembolsable).
2. Simulación de agentes en verde con parámetros finales.
3. Revisión externa del World (audit ligero mínimo).
4. Fuente del pozo definida (grant/tesorería/patrocinio) con tope
   por época presupuestado.
5. MiCA (ya en vigor) revisado para custodia/movimiento de tokens.

### Carril matemático (de Daniel, sin fecha, sin dependencias)
Curva homogeneidad/bolsones ↔ dificultad (no existe en la
literatura: se genera), hipótesis, contrastes, y — si llega — dureza
del mínimo-con-chords o caracterización a priori. Lecturas: Kaye
2000; Scott/Stege/van Rooij 2011; Becerra 2015; Tatham; wiki
minesweepergame; Dempsey & Guinn 2020 (arXiv 2008.04116, transición
de fase empírica); Louf 2025 (arXiv 2506.01634, transición de fase
demostrada). Si algo de esto madura: mejora el par (versionado) y/o
abre la puerta legal de B2. Si no, el juego vive igual.

---

## MAPA DE PLANES B
| Riesgo | Señal | Plan B |
|---|---|---|
| Latencia VRF injugable | F0 rojo (p50>2s o p95>5s) | B1: oráculo zk — mismo juego, servidor con bond |
| Cartridge VRF caro/inmaduro | Coste alto en F0 | Otro VRF SOLO si es atómico; si no, oráculo |
| Sequencer/VRF sesgado | Evidencia o aviso comunidad | Escalar en foro; pozo pausable por época |
| Faucet farmeado (mainnet) | Drenaje anómalo del pozo | Topes por época = pérdida acotada; endurecer límites |
| Sin hackathon/Basecamp en otoño | Nada anunciado a oct-2026 | Aplicar por la vía "y/o": repo + comunidad |
| Grant rechazado | — | Propulsion (programa gaming), créditos de fees, re-aplicar con F3 |
| Se desea entrada pagada | Dictamen legal favorable | B2: rama determinista (docs/archivo/) |

## Próximos 7 días
1. ~~Crear repo público~~ ✅ zkminestark.
2. Instalar entorno F0.1 y documentar en Instalaciones 001.
3. Alta en Discord Dojo/Cartridge.
4. Contrato de prueba VRF + empezar la medición go/no-go.
5. Abrir el issue en GNOME Mines (pitch listo en ECOSISTEMAS §4).
