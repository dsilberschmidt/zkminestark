This document is maintained in Spanish. If automatic translation presents any difficulty, please let me know and I will maintain an English version alongside it.

# zkminestark — Roadmap Starknet v4

Actualizado para reflejar el alcance vigente del proyecto al 2026-08-28.

## 1. Qué es zkminestark

zkminestark es un buscaminas competitivo fully onchain en Starknet/Dojo.

La idea central es que el tablero no existe completo antes de jugarse. Se materializa durante la partida. Cada acción comprometida que requiere nueva materialización consume azar verificable y fija solo las celdas necesarias para resolver esa acción. Eso limita el conocimiento anticipado al estado público ya revelado y a las probabilidades condicionales que cualquiera puede calcular.

El juego principal es zkminestark. VCLS se presenta como el paquete reusable que se extrae de la mecánica de zkminestark una vez que el núcleo esté cerrado y probado.

## 2. Qué es VCLS

VCLS significa Verifiable Constrained Lazy Sampling.

Modela:

- un universo finito de posiciones
- suministros exactos por categoría
- una asignación parcial irreversible
- pedidos adaptativos dentro de una misma acción
- muestreo exacto sin reemplazo

La capa base cubre conservación de cupos, irreversibilidad, lecturas idempotentes, expansión determinista desde una única semilla VRF y separación de dominios. La contribución está en convertir la equivalencia estándar del muestreo sin reemplazo en una abstracción onchain explícita y auditable, con aleatoriedad atómica, materialización adaptativa, supuestos de seguridad declarados y una interfaz reusable en Cairo/Dojo. Las reglas espaciales o causales del juego siguen siendo responsabilidad del adaptador.

## 3. Qué se quiere demostrar

zkminestark sirve como implementación principal de VCLS porque fuerza exactamente los problemas difíciles:

- orden de consulta controlado por el jugador
- oferta global exacta de minas
- acciones que pueden materializar varias celdas
- cascadas de flood fill
- consecuencias competitivas inmediatas si existe foreknowledge

La meta combina dos resultados: tener un juego jugable y cerrar un patrón reusable para juegos onchain con estado oculto diferido bajo restricciones públicas.

## 4. Modelo formal y afirmación criptográfica

Hay dos niveles distintos y deben mantenerse separados.

Equivalencia exacta del sampler ideal:

- el sampler ideal asigna posiciones nuevas exactamente sin reemplazo
- la revelación progresiva tiene la misma distribución de transcript que revelar una asignación uniforme pre-generada compatible con las restricciones iniciales
- esta es la afirmación matemática exacta del modelo ideal

Indistinguibilidad computacional de la implementación VRF/PRF:

- la implementación en Cairo consume una salida VRF atómica
- esa salida se expande mediante un flujo PRF con separación de dominios
- la reducción exacta de rango se implementa con rejection sampling
- bajo seguridad de VRF y PRF, el transcript observable es computacionalmente indistinguible del sampler ideal

En corto: el sampler ideal apunta a equivalencia exacta de distribución; la implementación concreta apunta a indistinguibilidad computacional respecto de ese ideal.

## 5. Estado demostrado hoy

### F0: benchmark de latencia VRF

Estado: cerrado como benchmark, no cerrado como diagnóstico de arquitectura.

Antes de escribir lógica de juego completa se fijó un criterio de medición para clicks que consumen VRF:

- verde: p50 <= 2000 ms y p95 <= 5000 ms
- rojo: resultado insuficiente para asumir buena UX sin más investigación

Resultado inicial:

- p50 = 3312 ms
- p95 = 4095 ms

Rerun publicado el 2026-08-23:

- 459 ciclos reportados con muestra temporal válida
- 41 intentos fallidos aislados, con un patrón compatible con nonce races de la cuenta o del cliente
- p50 = 3268 ms
- p95 = 4093 ms

Fuente primaria: [INSTALACIONES-001.md](./INSTALACIONES-001.md) y [raw F0 rerun log](../benchmarks/f0-sepolia-rerun-20260823-135554.log)

Interpretación vigente:

- F0 es ROJO
- ese ROJO mide el camino `sncast` completo para clicks que consumen VRF
- el punto pendiente es separar latencia de red de latencia de arquitectura cliente
- la siguiente medición obligatoria es RPC directo con polling de preconfirmación

Este roadmap presenta el ROJO como un diagnóstico abierto que M2 debe medir mejor antes de cerrar la interpretación arquitectónica.

### F1-A: vertical slice onchain con lazy assignment atómico

Estado: completado y verificado en Sepolia.

Lo que ya existe:

- creación de partida y clicks por multicall atómico con VRF real
- consumo de VRF y actualización onchain dentro de la misma transacción
- evidencia pública de click seguro y click sobre mina
- endurecimiento de `set_config` con autorización, rechazo de dirección cero y escritura única

F1-A demuestra el mecanismo central. M1 completa el juego con materialización de vecindad, cómputo de números y cascada de lazy sampling.

### Prototipo jugable

Estado: completado.

[`../client/minasweeper.html`](../client/minasweeper.html) implementa la experiencia completa del buscaminas con RNG local del navegador. Sirve para validar UX, scoring por clicks y flujo de interacción. Demuestra el prototipo jugable y deja para M2 la integración final con VRF onchain.

### Prueba de uniformidad del sampler ideal

Estado: completado y machine-checked.

[`../contracts/zkmine_f1/src/tests/test_world.cairo`](../contracts/zkmine_f1/src/tests/test_world.cairo) evalúa exhaustivamente las 300 configuraciones posibles de un tablero 5x5 con 2 minas, comparando orden fijo y orden adaptativo de consulta mediante racionales exactos.

Eso apoya la afirmación del sampler ideal en un caso finito exhaustivo. La prueba escrita general y la validación de la implementación de producción se completan en M3 y en los tests distribucionales del camino desplegado.

### Resumen de evidencia disponible

- benchmark F0 con dataset público reproducible
- F1-A en Sepolia con transacciones verificables
- prototipo jugable en navegador
- prueba exhaustiva finita del sampler ideal

## 6. Alcance del roadmap

Este roadmap cubre formalización, implementación, testnet y pruebas públicas del juego y del paquete reusable.

Quedan explícitamente fuera de esta fase:

- mainnet
- valor transferible
- entrada paga

Esas tres cosas se tratan como una fase futura con su propia compuerta.

## 7. Plan de tres meses

El plan vigente tiene tres milestones. Se reproducen aquí como alcance operativo actual.

### Milestone 1: core sampler y lógica completa del juego

Ventana: semanas 1 a 5.

Objetivo:

- definir la interfaz inicial de VCLS y sus invariantes
- implementar el núcleo en Cairo con rejection sampling, expansión PRF con separación de dominios, orden determinista de asignación, contabilidad de categorías restantes y eventos auditables
- construir el adaptador de zkminestark y el World completo de Dojo con modelos de Game, DeterminedCell, Epoch y Record

Trabajo funcional:

- completar lazy sampling en todos los caminos de click y cascada
- fijar apertura inicial estilo Linux, con la celda inicial y sus vecinas seguras antes del primer sorteo, a cero clicks
- validar cada preset al crear la partida
- verificar que `mine_count` quepa en la población de muestreo luego de reservar la región inicial segura
- calcular 3BV, par y score al final de la partida

Punto técnico crítico:

- cuando una cascada materializa vecinos que siguen visualmente cerrados, la población de muestreo ya no coincide con `total_cells - revealed_count`
- en ese punto F1-A deja de ser suficiente y hay que contar celdas indeterminadas reales para no romper la uniformidad

Entregable verificable:

- interfaz inicial de VCLS e invariantes
- implementación de referencia en Cairo
- partidas completas jugadas por CLI en Katana y Sepolia
- tableros finales auditados contra su historial onchain de asignaciones
- tests distribucionales del módulo VCLS y del camino desplegado de `click()`
- suite `snforge`
- direcciones de despliegue publicadas

### Milestone 2: VRF de producción y cliente jugable

Ventana: semanas 4 a 9, solapado con M1.

Objetivo:

- conectar el prototipo de navegador con el World vía Cartridge Controller y session keys
- enviar transacciones por RPC directo
- hacer polling de preconfirmación
- renderizar de forma optimista las celdas ya determinadas
- dejar que los clicks que requieren nueva materialización esperen resolución VRF
- usar Torii para leaderboard y vistas agregadas

Trabajo de seguridad:

- probar el proveedor VRF de producción de Cartridge contra tres estrategias adversarias
- precomputar un resultado antes del envío
- simular un click vía `estimateFee` o `simulate_transaction`, inspeccionar el resultado y abortar una transacción desfavorable
- reintentar la misma seed tras una transacción fallida o rechazada

Propósito de M2:

- medir si el ROJO de F0 proviene del camino `sncast` o de un piso real de latencia del stack
- probar el flujo de request y Paymaster de producción, además de la clave de test usada en F0 y F1-A

Entregable verificable:

- ocho jugadores externos completan onboarding estructurado, sesiones de playtesting en Sepolia y sesiones de feedback
- se registra telemetría de wallet setup, completion, latency, transaction cost, fresh-materialisation share y feedback cualitativo
- se repite F0 bajo arquitectura de RPC directo con la misma metodología base
- se publican los resultados de los tres ataques adversarios y sus transaction hashes

### Milestone 3: paquete reusable y ejemplo independiente

Ventana: semanas 9 a 12.

Objetivo:

- endurecer y publicar VCLS como paquete open source independiente en Cairo/Dojo
- cubrir en su API universos finitos, categorías exactas, muestreo exacto sin reemplazo, materialización irreversible e internamente adaptativa, asignación por lotes desde una sola semilla VRF, replay determinista e historial auditable de transiciones

Documentación obligatoria, comprimida al núcleo reusable:

- especificación formal con prueba de equivalencia ideal
- supuestos de seguridad
- guía de integración
- tests

Segundo adaptador:

- construir un ejemplo mínimo de exploración de recursos donde parcelas adquieren progresivamente suministros finitos de varias categorías
- ese adaptador debe usar más de dos categorías
- su función es probar que la API generaliza más allá de la semántica específica de Minesweeper

Entregable verificable:

- paquete VCLS publicado con especificación, prueba, suite de tests, dos adaptadores y ejemplo de exploración de recursos
- artículo técnico sobre VCLS y sobre los resultados F0/M2 de latencia

## 8. Riesgos que siguen abiertos

### Latencia por click

La evidencia actual apunta a que el camino de aceptación por bloque puede estar mezclando limitaciones de arquitectura cliente con limitaciones reales de red. M2 debe medir RPC directo con preconfirmación antes de cerrar ese diagnóstico.

### Exposición de la ruta de prueba VRF

F0-bis mostró que el `vrf-server` manual acepta `get_proof(seed)` antes de una sumisión onchain. La pregunta abierta es si el endpoint de producción de Cartridge permite algo equivalente fuera del flujo comprometido por Paymaster. M2 debe responderlo con pruebas adversarias o confirmación operativa.

### Divergencia entre prueba y código

La especificación, el algoritmo de referencia, el replay determinista y los tests distribucionales tienen que quedar alineados. M3 existe para cerrar exactamente ese riesgo.

### Reutilización real de VCLS

Si el segundo adaptador de exploración no encaja con naturalidad, la abstracción es demasiado estrecha. Por eso M3 exige un adaptador ajeno a Minesweeper y con más de dos categorías.

## 9. Fase futura: mainnet, valor y entrada paga

Quedan explícitamente reservados para una fase posterior.

Se tratan como una fase posterior, separada, con su propio criterio de entrada:

- latencia de juego aceptable bajo la arquitectura definitiva
- VRF de producción evaluado contra los ataques relevantes
- paquete VCLS estabilizado
- revisión externa de seguridad proporcionada al alcance de valor real
- análisis legal específico antes de introducir entrada paga o premios transferibles

## 10. Referencias del repo

- [INSTALACIONES-001.md](./INSTALACIONES-001.md)
- [INCOGNITAS.md](./INCOGNITAS.md)
- [bitacora.md](./bitacora.md)
- [../README.md](../README.md)
