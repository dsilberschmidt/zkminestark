# MinaSweeper — ¿Dónde plantar las minas?

Brief de decisión: ecosistema, grants y el PR a Mines de Linux.
Datos verificados a 13-jul-2026; los montos y programas cambian — reverificar antes de aplicar.

---

## 1. Comparativa de ecosistemas zk

### Starknet — el más fértil para juegos, con diferencia
- Gaming es la categoría MÁS grande del ecosistema: de 4 a 51 proyectos de
  juegos en un año; 47 nuevos en 2025, 29 de ellos sobre Dojo.
- **Dojo**: motor open-source para juegos totalmente on-chain (ECS en Cairo,
  indexer, deploy, compatible con Unity/Unreal/Godot). Cartridge (empresa
  detrás) levantó $7.5M. Hay comunidad real de devs de juegos (Realms,
  Loot Survivor, Dope Wars) — pares con quienes hablar.
- **Grants**: Seed Grants hasta $25k en STRK, aplicación rolling, respuesta
  ~4 semanas. Requisitos: MVP (✅ ya lo tienes) + involucramiento en la
  comunidad (hackathon o builder program — ese es el peaje de entrada).
  Además: programa gaming específico (Propulsion) y créditos de fees para
  juegos con tracción.
- **Traducción técnica**: el diseño cambia. En Starknet el modelo natural es
  validity rollup: lógica del juego en Cairo dentro de un World de Dojo,
  jugadas como transacciones baratas (bloques de 4s, preconfirmaciones ~0.5s),
  no una prueba de sesión completa. El proving del lado cliente está en el
  roadmap de Dojo pero no es el camino pavimentado hoy. El contador de
  clicks, seeds, récords y pozo se portan directo; el GameProgram recursivo no.

### Mina — el hogar natural del diseño actual, pero ecosistema en repliegue
- Ventaja única: la prueba de sesión (jugar entero en tu navegador, subir UNA
  prueba) es exactamente lo que o1js hace y casi nadie más ofrece hoy.
  Y el juego de palabras MINA/minas solo existe aquí.
- Señal preocupante: la Mina Foundation se redujo y está enfocada en
  transicionar a una tesorería descentralizada. Los programas activos
  (Builders Grants, Core Grants) apuntan a "problemas reales", tooling e
  infraestructura — consistente con tu experiencia de que juegos no es
  prioridad. El proceso comunitario (MEF) está en construcción.
- Matiz: zkIgnite SÍ financió juegos en su momento (TileVille, zkNoid — hay
  una plataforma de gaming zk en Mina). zkNoid podría ser canal de
  distribución o aliado si te quedas.

### Otros (segunda línea para este proyecto) — verificar estado actual antes de decidir
- **Aleo**: privacidad nativa, lenguaje Leo; ecosistema más chico, poca
  cultura de juegos.
- **Aztec**: L2 de privacidad sobre Ethereum, Noir es un lenguaje muy
  agradable; en fase temprana de red, juegos no son el foco.
- **zkVMs (RISC Zero / SP1) + cualquier EVM**: técnicamente MUY atractivo
  para ti — la regla de clausura se escribe en Rust plano y el zkVM se come
  el problema del chunking de constraints entero. Contra: no hay UN
  ecosistema que te financie; es infraestructura, no comunidad de juegos.

## 2. ¿Multi-chain o una sola?

**Una sola.** Devnets en varias chains para un proyecto de una persona es
dispersión: cada ecosistema exige su lenguaje (o1js/TS, Cairo, Leo, Noir,
Rust), su tooling y su presencia comunitaria — y los grants premian
embeddedness, que no se puede fingir en tres lugares a la vez.

**Recomendación**: Starknet como apuesta principal si el objetivo es
jugadores + financiación. Es donde hay masa crítica de juegos on-chain,
dinero explícitamente destinado a gaming y un motor hecho para esto.
Mina queda como la opción purista si la prueba de sesión importa más que
el ecosistema (y el prototipo actual ya es tu demo allí).

## 3. Estrategia de grant (Starknet)

1. El prototipo HTML es chain-agnóstico: ya es tu demo de MVP.
2. Peaje de entrada: participar en un hackathon Starknet (StarkHack u
   online) o builder program — es requisito explícito del Seed Grant y
   la vía rápida de embeddedness. Portar MinaSweeper a Dojo durante el
   hackathon mata dos pájaros.
3. Aplicar a Seed Grant (hasta $25k STRK, rolling) con: demo jugable,
   el diseño de economía de récords/pozo, y plan a 3 meses (los piden).
4. Ángulo diferencial para la propuesta: "buscaminas competitivo por
   eficiencia de clicks con economía de récords" + roadmap de seeds
   certificados sin azar (el ángulo matemático es un diferenciador serio
   frente a otros juegos de grant).

Nota honesta: si esto avanza, el nombre pierde el chiste (la entrada sería
en STRK). "MinaSweeper" puede sobrevivir como marca igual — las minas son
las del tablero.

## 4. PR a Mines de Linux (clicks en lugar de tiempo)

Primero identificar CUÁL juegas (dijiste que deja tableros azarosos):
- **GNOME Mines** (el "Mines" por defecto en Ubuntu): candidato más
  probable. Vala, repo en gitlab.gnome.org/GNOME/gnome-mines. Mantenimiento
  lento — paciencia con el review.
- **KMines** (KDE): C++/Qt, en invent.kde.org.
- El Mines de Simon Tatham NO es el tuyo (genera tableros sin azar).

Camino correcto en GNOME:
1. Abrir un issue proponiendo la feature ANTES de escribir código:
   "contador de clicks como métrica alternativa/adicional al tiempo",
   con tu argumento del juego tranquilizante — es un pitch de diseño
   genuinamente bueno, llévalo tal cual.
2. Alcance mínimo viable para el MR: mostrar clicks junto al timer (o
   detrás de una opción), sin tocar récords todavía — los cambios chicos
   se aceptan; los que reforman el juego, no.
3. Si acepta buena recepción, segunda iteración: récords por clicks.
4. Definir qué cuenta como click igual que en MinaSweeper (reveals y
   chords cuentan; banderas no) — documentarlo en el issue.

Beneficio lateral: ese PR es "involucramiento en open source de juegos"
demostrable en cualquier aplicación de grant.

---

## Decisión pendiente (del usuario)
- [ ] ¿Starknet (fertilidad) o Mina (pureza técnica + familiaridad)?
- [ ] Si Starknet: ¿próximo hackathon disponible como puerta de entrada?
- [ ] ¿Cuál Mines juega (GNOME/KMines) para dirigir el PR?
