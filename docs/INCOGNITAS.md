This document is maintained in Spanish. If automatic translation presents any difficulty, please let me know and I will maintain an English version alongside it.

# INCÓGNITAS ABIERTAS — ranking por relevancia
### (Se responden una por prompt; #1 respondida abajo)

Criterio de ranking: poder de bloqueo — qué impide avanzar todo lo demás
si queda sin resolver.

Estado metodológico adicional sobre conditional sampling exacto:

- ✅ RESPONDIDA: `2E2` y `2E3` ya quedaron auditados sobre el corpus
  histórico largo `30×16/99` (`16` histories, `259` puntos).
- Veredicto corto:
  - el salto de régimen real aparece al pasar a Variable Elimination;
  - `2E3` sí demuestra reuse incremental exacto;
  - ese reuse no compensa el overhead frente a `2E2`;
  - por lo tanto `2E2` queda como candidato operativo y `2E3` se congela
    como experimento negativo útil.
- Sigue ABIERTA y separada:
  demostrar end-to-end el flood-fill completo generado únicamente por
  sampling secuencial, sin hidden-board oracle, como validación de sistema
  completo y no solo del primitive exacto por celda sobre transcripts dados.

1. **El secreto del tablero** — ¿cómo impedir el pre-cómputo del layout?
   Bloquea el diseño entero: sin esto no hay récords ni pozo defendibles.
   ✅ RESPONDIDA ABAJO.
2. **¿Habilidad o apuesta?** — encuadre legal del pozo con entrada pagada.
   Pay-to-enter + premio = potencialmente juego regulado según jurisdicción.
   Bloquea monetización, el pitch del grant, y afecta desde Barcelona/España.
   ✅ RESPONDIDA ABAJO. Veredicto corto: en España NO hay test de habilidad;
   entrada pagada + pozo entre jugadores + azar "en alguna medida" = juego
   regulado (Ley 13/2011). Mainnet real ⇒ entrada GRATUITA con pozo
   patrocinado, o dictamen legal de habilidad pura (solo viable con tableros
   deterministas — tensión directa con la Adenda 2 de la #1).
3. **Arquitectura de prueba en Starknet** — ✅ RESPONDIDA ABAJO:
   click = transacción (modelo Dojo) con VRF; prueba de sesión archivada
   salvo pivote a tableros deterministas.
   ✅ RESPONDIDA ABAJO. Veredicto corto: la #1 (lazy sampling) la decide de
   facto — click = transacción, modelo Dojo + VRF. La prueba de sesión
   (S-two cliente + Integrity, hoy técnicamente viable) queda como rama
   alternativa ligada al diseño determinista de entrada pagada (#2).
4. **Viabilidad del proving del lado cliente** — ✅ RECONVERTIDA:
   ya no bloquea (v1 no prueba en cliente); condicional al pivote
   determinista. Ver nota abajo.
5. **Robustez económica del pozo** — ✅ RESPONDIDA ABAJO. Riesgo nº1:
   espiral de muerte del récord (⇒ temporadas o decaimiento). En régimen
   de entrada gratuita (#2), el sybil pasa a ser EL problema.
6. **Puerta comunitaria a Starknet** — ✅ RESPONDIDA ABAJO. Sin edición
   nueva anunciada a 13-jul-2026 (cadencia sugiere otoño); Basecamp SÍ
   califica como builder program; el "y/o" del criterio abre una tercera
   vía: involucramiento comunitario demostrable.
7. **Caracterización matemática de resolubilidad a priori** —
   ✅ ANDAMIAJE ABAJO (desarrollo profundo reservado al usuario).
   Tras #2 y #5 dejó de ser extra: es el "par" del score relativo y el
   potencial fundamento legal de la entrada pagada.

---

## INCÓGNITA #1 — El secreto del tablero: RESPUESTA

### El requisito exacto (esto es lo que cambia todo)
Analizándolo a fondo, el requisito no es "que el tablero esté comprometido"
sino algo más fuerte: **que NADIE — incluido el propio jugador — conozca el
contenido de una celda antes de clickearla**. Cualquier esquema donde el
cliente pueda derivar el tablero antes de terminar la partida (aunque sea su
tablero individual, aunque sea un segundo antes) permite a un bot computar la
secuencia óptima offline y ejecutarla. Esto descarta de raíz:
- seed → tablero por RNG público (el diseño actual): pre-cómputo trivial.
- tableros por jugador derivados de aleatoriedad on-chain en la entrada:
  el cliente conoce el tablero al instante de crearse → mismo agujero.
- cifrado timelock/threshold del layout completo: revela todo de golpe,
  pero el juego necesita revelación celda a celda, interactiva.

Solo hay dos familias que cumplen el requisito:

### Opción A — Oráculo de secreto (recomendada para v1)
Un servidor genera los tableros, publica SOLO el commitment on-chain, y
durante la partida revela cada celda clickeada con una firma. Al terminar,
revela el tablero completo; el contrato verifica hash + validez de la
secuencia (la prueba de sesión sigue existiendo, ahora sobre reveals
firmados). Conserva intacta tu visión original: mismo tablero para todos,
récord por disposición, pozo por seed.
- Confianza residual: "el servidor no filtra tableros a cómplices".
  Mitigación: bond económico slasheable si alguien prueba on-chain dos
  revelaciones contradictorias del mismo seed, + timeout con reembolso si
  el servidor no responde.
- Coste: es el componente centralizado del sistema. Para un hackathon y una
  v1 es completamente estándar y defendible; para el pitch, se declara con
  su plan de descentralización (comité threshold u opción B).
- Tiempo de construcción: semanas, no meses.

### Opción B — Revelación interactiva on-chain (v2 seria)
Cada click es una transacción; el contenido de la celda se muestrea de
aleatoriedad on-chain EN el momento del click, condicionado a que el total
sea 99 minas (muestreo sin reemplazo — es como funcionan los "mines"
provably-fair de los casinos cripto, pero con la estructura de adyacencias
real del buscaminas, que es más difícil de muestrear consistentemente:
los números ya revelados restringen dónde pueden caer las minas restantes).
- Consecuencia estructural: el tablero no existe antes de jugarse → muere
  "récord por disposición" → los récords pasan a ser por CLASE de
  dificultad, con score relativo (clicks sobre el mínimo teórico del
  tablero resultante, computable al terminar). Aquí tu matemática de
  resolubilidad a priori se vuelve el corazón del producto (la incógnita
  #7 sube al núcleo).
- Dato a favor inesperado: TU decisión de eliminar el tiempo hace viable
  la UX — con bloques de ~4s y ~100-200 clicks, una partida son ~10-15
  minutos de juego pausado. En un juego con timer sería inaceptable;
  en uno "tranquilizante", encaja.
- Coste: diseño de muestreo condicionado no trivial + fee por click
  (minúsculo en Starknet, pero no cero).

### Lo que ninguna opción arregla (y hay que decidir si importa)
Un bot sin foreknowledge sigue jugando Bayes perfecto y le ganará a casi
cualquier humano en eficiencia de clicks bajo incertidumbre. Eso NO es
trampa — es el juego jugado perfectamente. Decisión de diseño, no técnica:
o se acepta ("gana el mejor solver, humano o no", legítimo en un juego de
pozo) o se exige proof-of-humanity (otro pozo de complejidad; no
recomendado para v1). Mi consejo: aceptarlo y decirlo abiertamente — un
juego de habilidad pura donde los bots compiten es un posicionamiento
honesto y hasta atractivo para el público cripto.

### Recomendación final
**v1 = Opción A** (oráculo con bond): conserva tu diseño, es construible
para el hackathon, y el componente de confianza se declara con roadmap.
**v2 = Opción B** en el pitch del grant como evolución hacia la
descentralización total, con las clases de dificultad certificadas como
diferenciador de investigación. La falla detectada se convierte así en
narrativa: "encontramos el ataque, lo cerramos en v1, lo eliminamos en v2".

---

## ADENDA a #1 — "¿No basta un zk del seed pero sin el seed?"

### Sí como envoltorio, no como sustituto del oráculo
La intuición es correcta y de hecho MEJORA la Opción A, pero no la
reemplaza. El punto ciego está en la interactividad: alguien tiene que
estar online contestando cada click con "esa celda vale k", y para
computar esa respuesta hay que CONOCER el seed. Quien conoce el seed es,
por definición, el oráculo. El zk cambia lo que hay que confiarle:

- **Sin zk**: confías en que el oráculo no miente sobre el tablero Y en
  que no filtra el seed.
- **Con zk (tu propuesta)**: cada revelación va acompañada de una prueba
  "adj(celda i)=k es consistente con tablero=f(s) y commitment=H(s,salt)",
  sin revelar s. Además, al registrar el seed se prueba en zk que f(s)
  tiene exactamente 99 minas y región inicial vacía. El oráculo YA NO
  PUEDE mentir ni sesgar tableros. Solo queda confiarle una cosa: que no
  filtre.

Y esa última cosa es irreducible por zk: la confidencialidad no se puede
probar — no existe prueba de "no le susurré el seed a nadie". Ese residuo
se ataca con otras herramientas: bond slasheable (ya propuesto), TEE, o
la elegante: **comité threshold t-de-n** donde el seed vive en shares y
ningún participante individual lo conoce (las revelaciones se computan
distribuidamente, p.ej. contenido de celda i = PRF-threshold(i); el
detalle técnico a resolver ahí es condicionar el total a exactamente 99
minas). Ese comité es el camino natural de descentralización v1.5, y tu
pregunta define bien la arquitectura: **oráculo con integridad probada en
zk desde el día uno, confidencialidad descentralizada después**.

### Tu segunda pregunta es un ataque real: recuperar el seed desde las minas
Sí — y es la corrección de diseño más concreta de esta adenda. Si el seed
tiene poca entropía (como los "GENESIS"/"BERKELEY" del prototipo, o
cualquier cosa que un humano escriba), se rompe por fuerza bruta: se
enumeran seeds candidatos, se filtra por consistencia con el commitment
(¡incluso ANTES de jugar!) o con las celdas ya reveladas, y al quedar uno
solo, foreknowledge total a mitad de partida. Correcciones obligatorias:
1. El nombre público del seed pasa a ser solo una ETIQUETA (id legible).
2. La entropía real es secreta: s de ≥128 bits generado aleatoriamente.
3. El commitment debe ser ocultador: H(s, salt) con salt aleatorio, nunca
   H(nombre).
Con eso, invertir el seed desde las minas conocidas es infactible: cada
celda revelada aporta ~1 bit contra 128+, y f es una función tipo hash.
Lo único que las celdas reveladas siguen filtrando es la inferencia
bayesiana normal del buscaminas — los números SON pistas, eso es el juego
y es legítimo.

---

## ADENDA 2 a #1 — La propuesta de Daniel: generar el mapa sobre la marcha

**Veredicto: funciona, y es mejor que mis dos opciones.** Es la técnica de
"decisiones diferidas" (lazy sampling) y disuelve el problema en vez de
mitigarlo: si el tablero no existe hasta que se juega, no hay nada que
ocultar ni nadie a quien confiárselo. El seed deja de ser un secreto y pasa
a ser el TRANSCRIPT: la partida misma es el certificado del tablero.

### Por qué es matemáticamente sólido (y fácil, contra lo que parecía)
El miedo natural es que muestrear "lo que queda" condicionado a los números
ya revelados sea intratable (contar configuraciones consistentes de
buscaminas es #P-duro). Pero ese problema NO aparece si se respeta un
invariante: **ningún número se afirma antes de determinar su vecindario**.
El protocolo:
1. Estado: celdas determinadas (mina/segura), M_r minas restantes, N_r
   celdas indeterminadas.
2. Click en celda indeterminada X: se sortea X con probabilidad M_r/N_r
   (hipergeométrica). Mina → boom. Segura → se sortean sus vecinos
   indeterminados uno a uno (actualizando M_r/N_r) y recién entonces se
   computa el número de X. Los ceros cascadean el mismo proceso
   (flood-fill = más sorteos).
3. Al terminar, las celdas nunca tocadas se completan con los sorteos
   restantes.
Por intercambiabilidad, el tablero final es una muestra UNIFORME de todos
los layouts de 99 minas — distribucionalmente idéntico a un tablero
pre-generado con seed. Nada de posteriors #P: solo hipergeométricas
secuenciales. Y la apertura inicial "como en Linux" sale gratis:
se fijan como seguras la celda de inicio y sus vecinas antes de sortear.

### Lo que compra
- Cero oráculo, cero secreto, cero foreknowledge — para TODOS, por
  construcción. Adiós bond, adiós comité threshold, adiós adenda 1.
- Verificabilidad total: tablero final + pruebas de aleatoriedad de cada
  sorteo = procedencia auditable de la partida entera.

### Lo que cuesta (tres consecuencias estructurales)
1. **Decide la incógnita #3 de facto**: cada click necesita aleatoriedad
   fresca e impredecible → transacción por click (o por lote) con VRF
   on-chain. La prueba de sesión offline muere: no se puede jugar offline
   porque la aleatoriedad offline sería del jugador. En Starknet existe
   VRF (Pragma) — verificar estado y coste actual; la calidad de la fuente
   de aleatoriedad pasa a ser la nueva raíz de confianza (ojo con el
   sesgo del sequencer mientras esté centralizado).
2. **Muere el récord por disposición** (nada existe de antemano ⇒ no hay
   tablero compartido). El score pasa a ser RELATIVO: clicks sobre el
   mínimo teórico del tablero materializado (computable al terminar,
   estilo 3BV-con-chords), con récords por clase de dificultad. La
   incógnita #7 (tu matemática) sube al núcleo del producto.
3. **El azar vuelve al juego**: el tablero materializado puede forzar
   adivinanzas (no se puede certificar "sin azar" algo que no existe aún).
   Compatible con tu filosofía declarada — cabeza + administración del
   azar — pero es una decisión de identidad del juego, no un detalle.

### Recomendación revisada
La propuesta de Daniel reemplaza a la Opción A como diseño objetivo:
**v1 = generación diferida con VRF on-chain**, score relativo al mínimo
del tablero resultante. El oráculo queda descartado salvo que el coste de
UX por click (latencia de bloques + VRF) resulte inaceptable al medirlo —
único escenario en el que la Opción A vuelve a la mesa.

---

## INCÓGNITA #2 — ¿Habilidad o apuesta?: RESPUESTA
### (Resuelta 13-jul-2026. NO es asesoramiento legal — es el mapa para
### decidir y para saber qué preguntarle a un abogado de juego.)

### El marco: España no distingue habilidad de azar
Art. 3.a de la Ley 13/2011 (LRJ): es "juego" toda actividad donde se
arriesga dinero u objetos económicamente evaluables sobre resultados
futuros e inciertos, dependientes **en alguna medida** del azar, con
premio transferible entre participantes, **con independencia de que
predomine el grado de destreza**. La DGOJ lo descompone en tres
elementos concurrentes:
1. PAGO por participar (oneroso; lo gratuito queda excluido).
2. Resultado incierto dependiente en alguna medida del azar.
3. PREMIO transferible entre participantes.
No existe el debate skill-vs-chance de otras jurisdicciones: basta que
el azar intervenga algo. Por eso el póker es juego regulado en España.

### Aplicado a MinaSweeper mainnet
- Entrada 1 token = pago ✓.
- Pozo alimentado por entradas y pagado al récord = transferencia entre
  participantes ✓ (el caso más nítido posible del elemento 3).
- Azar: el buscaminas clásico ya tiene azar "en alguna medida"
  (adivinanzas forzadas). Y el diseño elegido en la Adenda 2 de la #1
  (generación diferida, sorteo hipergeométrico por click vía VRF) lo
  convierte en la variante MÁS dependiente del azar de todas —
  estructuralmente más cerca de los "mines" de casino cripto que de un
  torneo de destreza. ⚠️ TENSIÓN #1↔#2: la solución técnica óptima de
  la #1 es la peor configuración legal de la #2.

### Consecuencias de quedar dentro de la LRJ
- Licencia general + singular DGOJ: S.A. con objeto social exclusivo de
  juego, homologación técnica, verificación de identidad, reporte de
  operaciones. Inviable para un proyecto de una persona.
- Peor aún: los tipos de juego licenciables son un CATÁLOGO CERRADO por
  órdenes ministeriales; "buscaminas competitivo con pozo" no existe
  como tipo ⇒ hoy ni pagando se podría licenciar.
- Operar sin licencia = infracción muy grave: multas de 1 a 50 M€. No es
  teórico: en 2025 la DGOJ multó a 14 operadores sin licencia con 5 M€
  cada uno (10 M€ al reincidente), y declara públicamente que monitoriza
  el juego en cripto. "Es un contrato permissionless" no protege: el
  desarrollador residente en Barcelona, identificable y firmante de la
  aplicación al grant, ES el operador a ojos del regulador.
- Barcelona no cambia nada: el juego online es de ámbito estatal (DGOJ);
  Cataluña regula lo presencial.

### Las tres salidas
1. **Testnet / economía simulada (zona segura total)**: sin valor real
   no hay pago ni premio ⇒ no es juego. Cubre prototipo, hackathon,
   devnet y todo el roadmap hasta Fase 4. Recibir un grant en STRK por
   construir software tampoco es operar juego.
2. **Entrada GRATUITA con pozo patrocinado (vía para mainnet real)**:
   sin pago cae el elemento 1 y la actividad queda fuera de la LRJ por
   diseño. El pozo se financia con tesorería/patrocinio/grant; el loop
   de perseguir récords sobrevive. Muere "tu entrada alimenta el pozo"
   (que es exactamente el mecanismo a evitar). Validar con abogado que
   no haya desembolso encubierto (fees propios, token de compra
   obligada).
3. **Habilidad pura (frágil, solo con diseño determinista)**: tableros
   deterministas certificados "resolubles sin adivinar" ⇒ sin azar ⇒
   fuera de la definición legal (estatus de torneo de ajedrez con
   inscripción). Defendible pero exige dictamen de despacho
   especializado. Giro notable: la matemática de resolubilidad a priori
   (incógnita #7) pasaría de diferenciador técnico a FUNDAMENTO LEGAL
   del modelo de entrada pagada.

### Recomendación
- Hackathon + grant: economía simulada/testnet declarada como tal; en el
  pitch, la monetización real se presenta como "sujeta a estructuración
  legal" (suma seriedad, no resta).
- Mainnet: diseño por defecto = **entrada gratuita + pozo patrocinado**.
- La entrada pagada solo vuelve a la mesa con dictamen legal favorable
  por la vía de habilidad pura — que exige tableros deterministas sin
  azar, incompatible con el lazy sampling de la Adenda 2. Decisión de
  identidad pendiente: azar con VRF (mejor soundness, entrada gratis
  obligada) vs. determinismo certificado (entrada pagada posible, vuelve
  el problema del secreto del tablero).

### Pendiente
- [ ] Consulta con abogado especializado en juego ANTES de cualquier
      despliegue con valor real (aunque sea entrada gratuita, para
      blindar el "sin desembolso encubierto").
- [ ] Fiscalidad: premios tributan al jugador en IRPF base general
      (19–47%); si hay entidad operadora, Impuesto sobre Actividades de
      Juego. Anotar en Finanzas 001.
- [ ] Vigilar MiCA (aplicación plena jul-2026): regula el manejo de
      criptoactivos, no legaliza juego; afecta a cómo se custodian y
      mueven los tokens del pozo.
- [ ] Si otros países entran en el radar (jugadores no españoles), cada
      jurisdicción tiene su propio test — la entrada gratuita es también
      la opción más robusta internacionalmente.

---

## INCÓGNITA #3 — Arquitectura de prueba en Starknet: RESPUESTA
### (Resuelta 13-jul-2026, tooling verificado a esa fecha.)

### Estado actual del tooling (lo que cambió desde ECOSISTEMAS.md)
- S-two (Stwo): live en Starknet Mainnet desde dic-2025, stack completo
  open source (Apache 2.0) desde ene-2026. Es producción, no research:
  corre dentro de SHARP y asegura Starknet hoy.
- Dato clave: la prueba recursiva de circuito ya corre en un PORTÁTIL
  común (antes exigía máquinas dedicadas). El client-side proving pasó
  de "roadmap" a técnicamente viable.
- Integrity (Herodotus): verificador STARK en Cairo desplegado en
  Starknet; verifica pruebas Stone (y próximamente Stwo) de programas
  Cairo ejecutados fuera de la red, vía FactRegistry.

### Pero la #3 ya la decidió la #1
El lazy sampling (Adenda 2) exige aleatoriedad fresca e impredecible en
cada click. La aleatoriedad no puede generarse offline (sería del
jugador) ⇒ la prueba de sesión offline es INCOMPATIBLE con el diseño
vigente, por buena que sea la tecnología de proving. La decisión real
es un acoplamiento de ramas, la misma bifurcación de identidad que
detectó la #2:

**Rama A — lazy sampling (diseño vigente) ⇒ modelo Dojo, click = tx.**
- Lógica del juego en un World de Dojo; cada click consume aleatoriedad
  verificable (candidatos: Pragma VRF, Cartridge VRF — verificar coste,
  latencia y estado en Fase 0 del roadmap).
- Bloques ~4s + preconfirmaciones: UX viable para un juego pausado.
- Encaje con la #2: si mainnet es entrada gratuita, el fee por click lo
  absorbe el protocolo; en testnet/hackathon, gratis.
- Camino pavimentado del ecosistema que evalúa el grant (29 juegos
  nuevos sobre Dojo en 2025).

**Rama B — determinismo certificado ⇒ prueba de sesión + S-two + Integrity.**
- Solo revive si se vuelve a tableros deterministas (único camino a
  entrada pagada según la #2). Hereda la arquitectura de MinaSweeper.ts
  casi entera: jugar offline, probar la sesión client-side con S-two,
  verificar on-chain vía Integrity.
- Hoy construible pero camino difícil: pocos ejemplos, integración
  prover-en-navegador inmadura, y reabre el secreto del tablero (#1).

### Recomendación
**Rama A para hackathon y v1** — consecuencia coherente de #1+#2, la más
simple y la mejor posicionada en el ecosistema. La Rama B queda
documentada como arquitectura alternativa LIGADA a la decisión de
identidad (azar+gratis vs. determinismo+pago), no como opción suelta.

### Consecuencia sobre el ranking
Si se confirma la Rama A, la **#4 baja drásticamente**: el proving del
lado cliente solo aplica a la Rama B. Se despacha breve con los números
de S-two en portátil, como referencia por si la Rama B revive.

### Pendiente
- [ ] Fase 0: verificar Pragma VRF vs. Cartridge VRF (coste por request,
      latencia, madurez, soporte en Dojo) antes de escribir el World.
- [ ] Sesgo del sequencer centralizado como raíz de confianza de la
      aleatoriedad (ya señalado en Adenda 2) — preguntar en la comunidad
      Dojo cómo lo tratan otros juegos con VRF.
- [ ] Si la Rama B revive: probar el pipeline S-two→Integrity con un
      programa Cairo trivial antes de comprometerse.

---

*Siguiente prompt → Incógnita #4 (breve, solo aplica a Rama B): tiempos
reales de proving cliente con S-two para un circuito tamaño MinaSweeper.*

---

## INCÓGNITA #3 — Arquitectura de prueba en Starknet: RESPUESTA
### (Resuelta 13-jul-2026)

**Decidida de facto por la Adenda 2 de la #1.** La generación diferida
exige aleatoriedad fresca por click ⇒ la prueba de sesión offline es
estructuralmente incompatible (no se puede probar offline lo que se
materializa con aleatoriedad on-chain).

**v1 = modelo Dojo: click = transacción** (o lotes), consumiendo VRF.
- UX viable: upgrade Grinta (2025) = bloques de 4s, preconfirmaciones
  ~0.5s. En un juego sin timer, click-como-tx encaja.
- Nota #2↔#3: si mainnet es de entrada gratuita, el fee por click lo
  absorbe el protocolo (paymaster/patrocinio), no el jugador —
  presupuestarlo en Finanzas 001.

**Prueba de sesión (Integrity + client-side proving): archivada, no
muerta.** Vuelve SOLO si se pivota a tableros deterministas (la vía
legal de habilidad pura de la #2). Estado del tooling verificado a
jul-2026:
- S-two en mainnet desde nov-2025 (reemplazó a Stone como prover de la
  red); open-source, en crates.io; pruebas Cairo comprimidas de 1.3MB
  a 77KB (ene-2026).
- Verificador Integrity (Herodotus) live en Starknet para pruebas
  Stone; soporte S-two anunciado como próximo.
- Client-side proving: dirección declarada del ecosistema, pero las
  APIs/plantillas para integrarlo en apps figuran como futuras, y
  WebGPU/WASM en navegador como "pronto". Pavimentándose, no
  pavimentado. Camino equivocado para llegar al hackathon.

**Pendiente**: verificar coste y estado de Pragma VRF al implementar;
sesgo del sequencer centralizado como raíz de confianza de la
aleatoriedad (descentralización de sequencing prevista para 2026).

---

## INCÓGNITA #4 — Proving del lado cliente: RECONVERTIDA A CONDICIONAL

Con la #3 resuelta como "click = tx", v1 NO genera pruebas en el
cliente ⇒ esta incógnita ya no bloquea la UX. Solo se reactiva si hay
pivote a tableros deterministas + prueba de sesión. Para ese caso,
anotado sin desarrollar: S-two es el prover a medir (benchmarks propios
en portátil/browser cuando existan las APIs de integración); el
presupuesto de constraints del circuito de MinaSweeper ya está
estimado en MinaSweeper.ts (⚠️ chunking). No gastar más aquí hasta que
el pivote exista.


---

## INCÓGNITA #5 — Robustez económica del pozo: RESPUESTA
### (Resuelta 13-jul-2026. La #2 la parte en dos regímenes.)

### Régimen A — entrada pagada (solo con dictamen legal / fuera de España)
- **Sybil/self-play: resueltos por diseño.** La entrada cuesta ⇒ el
  grinding se autofinanciar del pozo que intenta ganar; reclamar tu
  propio pozo pierde 10% por vuelta. Colusión entre jugadores ≈ bots,
  ya aceptado en la #1.
- **Riesgo estructural nº1: espiral de muerte del récord.** Récord →
  óptimo teórico ⇒ P(batirlo) → 0 ⇒ EV de entrar negativo ⇒ cesan las
  entradas ⇒ pozo huérfano. El 90/10 no lo arregla. Mitigación
  obligatoria (elegir una):
  a) **Temporadas/épocas**: récords se resetean periódicamente, pozo
     hace rollover; b) **Decaimiento**: el récord se relaja (+1 click /
     semana) — siempre vuelve a ser batible.
- **Timing del claim**: incentivo a retener el claim para engordar el
  pozo, arriesgando que otro bata el récord antes. Carrera sana SI la
  prueba liga al claimer ⇒ el TODO(front-running) del contrato pasa de
  importante a OBLIGATORIO. Las carreras se resuelven por el fee market
  de tips (post-Grinta): aceptable.

### Régimen B — entrada gratuita + pozo patrocinado (default legal España)
- **El sybil se invierte: pasa a ser EL problema.** Atacar es gratis ⇒
  el pozo es un faucet farmeable por bots. Defensas:
  - Cooldowns: dejan de ser UX, hacen trabajo económico (límite de
    intentos por identidad).
  - Click=tx (#3) ayuda: cada click paga gas ⇒ "gratis" no es gratis.
    ⚠️ Si el protocolo subsidia gas vía paymaster, devuelve el faucet
    al bot: subsidiar entrada sí, gas NO (o con tope).
  - Presupuesto de patrocinio con tope por época: el pozo es gasto de
    marketing acotado, no equilibrio.
  - Opción intermedia: **depósito reembolsable** para jugar (se
    devuelve, no se consume) — argumento de que no es "pago" oneroso,
    pero zona gris ⇒ a la lista del abogado (#2).

### El 90/10
No es inestable, pero el 10% de semilla puede ser poco para reactivar
interés tras un claim grande. Mantener 90/10 + **suelo mínimo de pozo**
(el protocolo rellena hasta X tras cada claim). Revisar con datos.

### Pendiente
- [ ] Simulación de agentes de la economía (script, no paper) antes de
      mainnet.
- [ ] Consulta legal: ¿depósito reembolsable = "pago" oneroso?
- [ ] Sesgo VRF/sequencer = colusión de infraestructura (ver #3).
- [ ] Elegir temporadas vs. decaimiento del récord (decisión de
      identidad del juego, va a Diseño 001).


---

## INCÓGNITA #6 — Puerta comunitaria a Starknet: RESPUESTA
### (Verificada 13-jul-2026 — fechas y programas cambian, revalidar.)

### Estado de los hackathons
- Re{solve}: ago–oct 2025 (cierre 15-oct-2025), CON track de Gaming y
  premios específicos Dojo/Cartridge — precedente perfecto para
  MinaSweeper.
- Re{define}: 1–28 feb 2026, tracks Bitcoin/Privacy/Open; sus ganadores
  pueden aplicar a seed grants de hasta $25K (el hackathon es la
  antesala directa del grant).
- **A 13-jul-2026 NO hay próxima edición anunciada** (la página oficial
  hackathon.starknet.org aún muestra Re{define}). Cadencia ≈ una por
  temporada ⇒ probable anuncio para fin de verano/otoño 2026.
  Vigilar: hackathon.starknet.org + @StarknetFndn.

### El criterio del Seed Grant, releído
Texto del programa: equipos "actively involved in the Starknet
community AND/OR participated in a hackathon, builder program, or
other entry-level initiative", con MVP. El **"y/o"** importa: el peaje
también se paga con involucramiento demostrable (Discord Dojo/
Cartridge, foro Starknet, repo público activo), sin esperar hackathon.

### Basecamp: SÍ califica
Developer Basecamp = bootcamp GRATUITO de 5-6 semanas de la Foundation
(Basecamp 12 ~EthCC 2025 Cannes; Basecamp 13 ~Devconnect BA nov-2025).
Encaja de lleno en "builder program / entry-level initiative". Próxima
cohorte tampoco anunciada. Las grabaciones completas están en YouTube:
sirven para preparar el port a Cairo/Dojo YA, pero ver vídeos no es
participación — para el checkbox hace falta la cohorte en vivo.

### Nota: incubador "Proof"
Nuevo acelerador selectivo de Starknet. Cohort 01 (privacidad,
20-jul → 14-sep-2026) cerró aplicaciones el 10-jul-2026 — no era el
fit. Vigilar cohortes futuras por si aparece una de gaming/consumer.

### Recomendación (tres carriles en paralelo)
1. Vigilancia semanal de hackathon.starknet.org y @StarknetFndn;
   inscribirse a próximo hackathon Y próximo Basecamp apenas abran.
2. Mientras tanto, construir el "y/o": repo público del port a Dojo,
   presencia en Discord de Cartridge/Dojo, PR a GNOME Mines (open
   source de juegos demostrable — ver ECOSISTEMAS.md §4).
3. El port a Dojo se ejecuta DURANTE el hackathon (matar dos pájaros,
   como ya planteaba ECOSISTEMAS.md §3).

### Pendiente
- [ ] Chequeo semanal de anuncios (hackathon + Basecamp 14).
- [ ] Alta en Discord Dojo/Cartridge y foro Starknet (Instalaciones/
      Dirección 001).
- [ ] Empezar playlist de Basecamp en YouTube como preparación.


---

## INCÓGNITA #7 — Resolubilidad a priori: ANDAMIAJE
### (13-jul-2026. Mapa del terreno; la exploración profunda es del
### usuario. Verificar literatura post-2024 al entrar a fondo.)

### Son TRES problemas distintos (no mezclarlos)
1. **Consistencia** (¿existe tablero compatible con estos números?):
   NP-completo — Kaye 2000, Mathematical Intelligencer.
2. **Inferencia** (¿esta celda es deducible con certeza?):
   co-NP-completo — Scott, Stege & van Rooij 2011, "Minesweeper may
   not be NP-complete but is hard nonetheless" (la secuela que corrige
   a Kaye: ESTE es el problema que juega el jugador).
3. **Conteo** de configuraciones consistentes: #P-completo — el
   monstruo que la Adenda 2 esquivó con muestreo diferido.
Dureza de PEOR caso: en 30×16/99 reales, un solver completo
(propagación de restricciones + enumeración por componentes de la
frontera) termina en ms casi siempre ⇒ **certificar "no-guess" es
barato en la práctica**: correr el solver desde la región inicial; si
nunca se atasca, el tablero es resoluble sin adivinar. Referencia de
ingeniería: el generador de Simon Tatham (solver en el loop).

### El "par" del score relativo es OTRO problema
- 3BV = mínimo de clicks SIN chords (aperturas + números no adyacentes
  a aperturas). Con chords (regla del juego: banderas gratis, chord=1
  click) el mínimo real es menor; la comunidad lo aproxima con ZiNi
  (greedy, no óptimo).
- El mínimo exacto con chords es optimización combinatoria (cubrir las
  381 celdas seguras con clicks/chords — estructura tipo set cover).
  Casi seguro NP-duro; **no hay prueba publicada conocida ⇒ resultado
  original disponible**.
- Decisión de diseño derivada: el "par" del protocolo NO es el óptimo
  verdadero sino una **aproximación canónica, determinista y
  versionada (ZiNi-det)**, función pura del tablero materializado —
  reproducible por cualquiera, sin disputas. Récord = clicks − par
  (o clicks/par), por clase.

### Clases de dificultad (features post-hoc del tablero materializado)
- par (ZiNi-det), 3BV, nº y tamaño de aperturas.
- La clave: nº de adivinanzas forzadas al solver lógico perfecto y sus
  probabilidades. 0 adivinanzas = clase "pura habilidad" ⇒ en el
  pivote determinista, certificar 0 adivinanzas ES el argumento legal
  de habilidad pura de la #2.

### Referencias de partida
- Kaye (2000), "Minesweeper is NP-complete", Math. Intelligencer.
- Scott, Stege, van Rooij (2011), "Minesweeper may not be NP-complete
  but is hard nonetheless", Math. Intelligencer.
- Becerra (2015), tesis Harvard, "Algorithmic approaches to playing
  Minesweeper" — el mejor survey práctico (solvers, prob. de guess).
- Notas de desarrollo del Mines de Simon Tatham (generación no-guess).
- Wiki de minesweepergame.com: definiciones exactas de 3BV y ZiNi.

### Abierto y reservado al usuario
- [ ] Prueba de dureza del mínimo-de-clicks-con-chords.
- [ ] Calidad de aproximación de ZiNi-det vs. óptimo (cotas o
      empírico masivo).
- [ ] Caracterización A PRIORI de verdad: predecir el par desde
      parámetros de generación sin materializar el tablero — el más
      ambicioso y el más "paper".

---

# ESTADO FINAL (13-jul-2026): las 7 incógnitas cerradas
1 ✅ lazy sampling (Adenda 2) · 2 ✅ entrada gratuita o dictamen legal ·
3 ✅ click=tx con VRF · 4 ✅ condicional al pivote · 5 ✅ temporadas/
decaimiento + antisybil según régimen · 6 ✅ vigilar hackathon/Basecamp,
construir el "y/o" · 7 ✅ andamiaje (desarrollo del usuario).
Tensión maestra a decidir en Dirección 001: **azar-VRF (entrada
gratis obligada) vs. determinismo certificado (entrada pagada posible,
vuelve el secreto del tablero)** — atraviesa #1, #2, #3, #5 y #7.

---

## ADENDA a #3 — Latencia real por click (pregunta posterior)
**0.5s es el MEJOR caso (preconfirmación), no el máximo.** Componentes:
1. Tx: preconf ~0.5s típico / bloque ~4s; sin techo garantizado bajo
   congestión.
2. VRF — LA decisión: patrón request/callback (Pragma) = 1+ bloques
   extra ⇒ ~4–10s/click, INJUGABLE. Patrón atómico (Cartridge VRF,
   hecho para Dojo) = resuelto en la misma tx ⇒ ~0.5–2s, jugable.
   ⇒ Cartridge VRF pasa a candidato primario; medir en Fase 0 con
   contrato de prueba ANTES de escribir el World.
3. Sin UI optimista posible (la celda no existe hasta que llega la
   aleatoriedad). Mitigar: UNA semilla VRF por click alimentando un
   stream PRF para todos los sorteos del click (flood-fill = una sola
   espera). Nunca una request por celda.
4. Session keys obligatorias (Cartridge Controller): un popup de
   wallet por click mata el juego antes que la latencia.
Plan B ya documentado: si la medición de Fase 0 da latencia
inaceptable, revive la Opción A de la #1 (oráculo con integridad zk).

---

## ADENDA 2 a #3 — Latencia del plan B (oráculo): pregunta posterior
**El oráculo es la opción MÁS RÁPIDA**: la partida no toca la chain.
Click = petición al servidor ⇒ ~0.1–0.3s (latencia web). On-chain solo
entrada y claim. Las pruebas zk de consistencia NO bloquean: la firma
del oráculo llega al instante (y ya lo compromete — slashing si luego
contradice); las pruebas se generan en paralelo/lote y se verifican en
el claim. Precio: liveness centralizada (servidor caído = partida
bloqueada) ⇒ timeout con reembolso + reanudación, ya previstos.

**Cuadro de latencias por rama** (todas jugables en su mejor config):
- Oráculo zk: ~0.1–0.3s/click · peor confianza (liveness + no-filtración)
- Lazy sampling + VRF atómico: ~0.5–2s/click · confianza mínima
- Lazy sampling + VRF callback: 4–10s/click · DESCARTADO
- Determinista: 0s (offline, prueba al final) · solo en pivote legal
⇒ La decisión de Dirección 001 es confianza↔fluidez, no jugabilidad.

---

## ADENDA 3 a #3 — Escepticismo sobre el 0.5–2s (pregunta posterior)
**El 0.5–2s es especificación declarada, NO medición** de este stack
(Dojo + Cartridge VRF + session keys + lote de sorteos por click).
Expectativa honesta: mediana 1–3s en buenas condiciones, y COLAS
(p95 con congestión/hipos de RPC o VRF: 5–10s). El riesgo es la
imprevisibilidad, no la mediana.

**Go/no-go de Fase 0, numérico y escrito ANTES de medir**:
p50 ≤ 2s y p95 ≤ 5s sobre ~500 clicks en testnet, horarios variados.
Verde ⇒ lazy sampling confirmado. Rojo ⇒ plan B (oráculo).

**Mitigación estructural descubierta: no todos los clicks necesitan
VRF.** Los sorteos de vecinos (para computar números) van DETERMINANDO
celdas on-chain. Click sobre celda ya determinada = contenido ya
existe ⇒ UI optimista posible: revelación instantánea en cliente, tx
solo registra el click (fire-and-forget o en lote). Solo bloquean los
clicks a la frontera indeterminada — que se encoge sola durante la
partida. Endgame ≈ instantáneo; la espera VRF se concentra en los
clicks exploratorios.

**Recordatorio de diseño**: score = clicks, no tiempo ⇒ la latencia
nunca toca la puntuación, solo la sensación — y la sensación se
diseña (shimmer "sorteando…" = ritual, no lag).

---

## ADENDA 3 a #1 — Alfabeto de acciones y versionado del récord
### (2026-08-28, a partir de un bug del prototipo)

**Origen.** El prototipo contabilizaba clicks con dos criterios distintos
según la rama: celda cerrada cobraba por intentar, chord cobraba solo si
revelaba algo. Al unificarlo apareció una disyuntiva que parecía de reglas:
- **A — acción comprometida**: cuenta toda acción enviada, revele o no.
- **B — acción con efecto**: cuenta solo si revela.

**Hallazgo: la disyuntiva depende de dónde vive la validación, no de las
reglas del juego.** Con el chord enviado como conjunto explícito de celdas
y validado en cliente, ninguna acción enviada puede revelar cero — A y B
dan el mismo número siempre. La distinción reaparece únicamente si la
validación se mueve al contrato y las acciones inválidas se vuelven
enviables, y entonces la pregunta ya no es "¿qué cuenta como click?" sino
"¿un revert cuenta?".

Fijado provisionalmente A, por implementabilidad, no por convicción de que
sea el criterio más simple. Se cierra antes de fijar la firma de `click()`
en M1. El prototipo queda como banco de pruebas: el criterio está en un
punto único (`clickMode` en `client/minasweeper.html`).

**Restricción derivada sobre la firma del chord.** Las banderas son
anotación local: no viajan en la transacción y el contrato no las ve. Por
lo tanto no pueden frenar una cascada — el contrato haría flood-fill igual
— y el cliente que las respete diverge del estado on-chain. Consecuencia:
la cascada las ignora y las limpia al abrir. Y el chord no puede enviarse
como `(x,y)`: sin banderas el contrato no sabe qué vecinos excluir. Tiene
que recibir el conjunto y verificar que los vecinos cerrados fuera de él
son exactamente `adj`. No es preferencia — es la única firma compatible
con "banderas gratis".

**Los récords son relativos al alfabeto, no absolutos.** Un récord medido
bajo un conjunto de acciones no es comparable con otro medido bajo otro.
En el prototipo se resolvió versionando la clave
(`minesweeper-best-clicks:v2:<preset>`). On-chain el problema es el mismo
y más caro:
- el modelo `Record` necesita llevar la versión de reglas, o la `Epoch`
  tiene que llevarla y ser inmutable dentro de la época
- un cambio en el alfabeto de acciones FUERZA un corte de época; deja de
  ser una decisión de diseño (#5, temporadas vs. decaimiento) y pasa a ser
  una obligación técnica
- el par (ZiNi-det, #7) también depende del alfabeto: si cambian las
  acciones disponibles, cambia el mínimo. Como `score = clicks − par`, los
  dos lados del cálculo tienen que estar versionados juntos, o el ranking
  mezcla reglas

**Pendiente para M1**: decidir si la versión de reglas vive en `Record`, en
`Epoch`, o en la config del World, antes de fijar los modelos de Dojo.

---

## ADENDA 4 a #1 — Frontera pública descartada y blocker nuevo
### (2026-08-29, después del benchmark RPC directo)

**Cierre de la idea "la frontera evita la espera".** La arquitectura donde
el protocolo materializa por adelantado `is_mine` de celdas cerradas para
dejar una frontera ya resuelta queda invalidada en blockchain pública.
Si `is_mine` vive en un modelo Dojo, vive en storage legible; un bot puede
leerlo antes de clickear. Ocultarlo en UI o en Torii no cambia nada.

**Decisión derivada.** Una arquitectura sin secretos NO puede materializar
en plaintext el contenido oculto de celdas cerradas. Si el futuro queda
fijado, hay que ocultarlo; si no queremos custodio de secretos, el futuro
no puede quedar fijado por adelantado.

**Salida que queda abierta.** No materializar `is_mine` hasta la acción del
jugador y samplear solo el próximo resultado observable, condicionado al
transcript público. Esto conserva la familia de la #1 sin volver al
oráculo, pero mueve el peso técnico al muestreo condicionado/model
counting exacto.

**La latencia ya NO es el blocker principal.** El experimento RPC directo
de 200 acciones materializantes dio:
- N válido = 200, N fallido = 0
- `Benchmark.get_counter()` legible en `pre_confirmed` en 200/200
- min = 376 ms, p50 = 1596 ms, p90 = 2669 ms, p95 = 2887 ms, p99 = 3538 ms,
  max = 4013 ms, media = 1449 ms
- veredicto: **YELLOW**

Conclusión: la latencia queda resuelta como **viable para continuar**. No
es GREEN, pero tampoco mata el proyecto.

**Blocker principal abierto desde ahora.** ¿Puede el muestreo
condicionado/model counting exacto ejecutarse en Cairo con gas y latencia
aceptables para una acción materializante?

**Cuestión criptográfica que sigue abierta si más adelante se reabre una
capa de ocultamiento.** Commitments, witness secreto, comité threshold o
cualquier mecanismo de no-filtración siguen siendo una rama posible, pero
ya no se los puede tratar como detalle de implementación: afectan el
modelo de confianza entero.
