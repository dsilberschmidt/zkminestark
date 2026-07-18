# MinaSweeper/Starknet — Organización del proyecto
### (Documento de handoff — último turno de Fable 5, 13-jul-2026)

---

## ⚠️ PRIMERO: la tarea crítica que me pediste

Aprovechando el último turno, revisé el diseño completo con ojos frescos y
**hay una falla crítica que hay que resolver antes de escribir una línea de Cairo**:

### El tablero es secreto... para nadie
En el diseño actual, `seed → tablero` es una computación pública y determinista
(cualquiera con el seed genera el layout). El commitment no oculta nada.
Consecuencia: un bot puede precomputar el layout, calcular la secuencia de
clicks mínima teórica (esto es esencialmente la métrica 3BV del buscaminas
competitivo, ajustada por chords) y ejecutarla. El récord de cada seed cae al
mínimo matemático el día uno y el pozo se farmea instantáneamente. El juego
muere. Esto era cierto TAMBIÉN en la versión Mina — la prueba zk verificaba
la partida, pero nunca impidió conocer el tablero de antemano.

### Tres salidas (decisión de Dirección 001, la primera del proyecto)
1. **Oráculo de secreto (v1 pragmática)**: un servidor genera los layouts,
   publica solo commitments on-chain, y revela celdas firmadas a medida que
   el jugador clickea. La prueba final verifica las firmas. Confianza
   reducida a "el servidor no filtra tableros", con bond económico
   slasheable si se prueba una doble revelación. Rápido de construir,
   centraliza el secreto.
2. **Clases de dificultad equivalente (v2, y aquí entra TU matemática)**:
   abandonar "mismo tablero para todos" y dar a cada jugador un tablero
   distinto pero de dificultad certificada equivalente (mismo mínimo teórico
   de clicks, misma clase de resolubilidad). El récord es por CLASE, no por
   layout. Tu idea de caracterizar resolubilidad a priori deja de ser un
   extra académico y pasa a ser el corazón del producto. Más lento, más
   original, más defendible en un grant.
3. **Carrera de optimización (pivote)**: aceptar que el layout es público y
   redefinir el juego: gana quien ENCUENTRA la secuencia mínima. Deja de ser
   buscaminas jugado y pasa a ser un problema de optimización — bots
   bienvenidos por diseño. Otro juego; probablemente no el que quieres.

Mi recomendación: v1 (oráculo) para llegar al hackathon con algo jugable,
declarando v2 (clases de dificultad) como roadmap en la aplicación al grant —
esa combinación es honesta, ejecutable y diferencial.

### Segunda nota crítica (menor pero estructural)
Al portar a Starknet, la arquitectura de prueba de sesión NO se pierde
necesariamente: Starknet puede verificar pruebas de programas Cairo generadas
del lado cliente (verificador Integrity / provers Stone y S-two). Hay dos
caminos y conviene decidir temprano: (a) modelo Dojo estándar — cada jugada o
lote de jugadas como transacción, más simple, más caro por partida; (b) prueba
de sesión en Cairo verificada on-chain — hereda tu diseño original, más
difícil, más barato por partida. Verificar el estado actual del tooling de
client-side proving ANTES de elegir; cambia rápido.

---

## Estructura: 5 áreas

### Dirección 001
**Qué vive aquí**: decisiones de arquitectura (las dos de arriba), roadmap,
elección de ecosistema, calendario de hackathon/grant, este documento.
**Modelo**: el mejor disponible en cada momento — Opus 4.8 por defecto;
si recuperas ventana de Fable 5, gástala aquí y en los nudos de Claude Code.
**Primera tarea**: decidir v1/v2/pivote de la falla del tablero.

### Diseño 001
**Qué vive aquí**: reglas del juego (qué cuenta como click, chords, banderas
gratis), cooldowns (15s→1m→1m→1m→aviso→24h), temas visuales (MINA/LINUX),
UX de proofs, economía de juego (90/10, pozo semilla). El prototipo
`minasweeper.html` es el documento vivo de esta área.
**Modelo**: Opus 4.8 para diseño de mecánicas; Sonnet 4.6 para iterar UI.

### Finanzas 001
**Qué vive aquí**: aplicación al Seed Grant (~$25k STRK, rolling, requiere
MVP ✅ + participación comunitaria ⏳), presupuesto, sostenibilidad del pozo,
monetización (fee de protocolo futuro), tracking de gastos.
**Modelo**: Sonnet 4.6 para el día a día; Opus 4.8 para redactar el pitch
del grant (una sola pieza, alta calidad).

### Instalaciones 001
**Qué vive aquí**: entorno de desarrollo Starknet — scarb, Starknet Foundry,
Dojo/Katana, wallets (Argent/Braavos), devnet, faucets, deploy. Documentar
cada instalación para poder reconstruir el entorno.
**Modelo**: Sonnet 4.6 sobra (trabajo procedural guiado por docs). Mucho de
esto conviene hacerlo directamente EN Claude Code, no en chat.

### Claude Code (el repo)
**Qué vive aquí**: `contracts/` (Cairo), `client/` (el prototipo portado),
`docs/` (estos .md). El trabajo real.
**Modelo**: Sonnet 4.6 para tareas rutinarias; Opus 4.8 para contratos y
lógica de verificación; ventanas de Fable 5 reservadas para los dos nudos
duros (secreto del tablero, prueba de sesión) si siguen abiertos.

---

## El pegamento entre áreas (importante)

Cada Proyecto de Claude tiene memoria SEPARADA — no se ven entre sí, ni ven
la memoria global. Para que no se fragmente:
1. Mantener un `ESTADO.md` maestro en Dirección 001 (qué se decidió, qué
   sigue) y subir la versión vigente a los otros Proyectos cuando cambie.
2. Contar los hitos en chats normales (fuera de proyectos) para que la
   memoria global los registre — esa es la única memoria que ve todo.
3. Los artefactos ya generados (prototipo, contrato o1js de referencia,
   ROADMAP, ECOSISTEMAS, este doc) van a `docs/` del repo y como archivos
   de conocimiento en Dirección 001.

## Sobre tu ventana de Fable 5
No puedo ver los datos de tu cuenta (ni cuota ni hora de corte), así que no
te puedo decir la hora exacta — se consulta en Configuración → Uso, o en el
indicador de límites de la app. Los límites funcionan por ventanas rotativas
(sesiones de horas + tope semanal), así que "vence hoy" puede significar
reset y no adiós — vale la pena mirarlo antes de despedirse.
