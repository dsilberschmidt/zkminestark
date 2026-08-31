This document is maintained in Spanish. If automatic translation presents
any difficulty, please let me know and I will maintain an English version
alongside it.

# EXPERIMENTO 2A — Conditional Sampling Exacto Baseline
### (2026-08-30)

## Pregunta

¿Es factible calcular exactamente, off-chain y sin secretos materializados,
los conteos:

- `N_mine`
- `N_0`
- `N_1`
- `N_2`
- `N_3`
- `N_4`
- `N_5`
- `N_6`
- `N_7`
- `N_8`

para una única celda cerrada `x`, donde `N_o` es el número de tableros
completos compatibles con el transcript público `T` que producirían el
outcome observable `o` al clickear `x`?

## Motivación

La arquitectura anterior materializaba `is_mine` para celdas cerradas de la
frontera. Eso resultó inválido en una blockchain pública: aunque la UI no
las mostrara, el storage del contrato seguiría siendo legible.

Por eso la pregunta pasó a ser otra:

- no materializar el futuro
- determinar solo el próximo resultado observable
- mantener la distribución exacta del tablero uniforme
- medir cuánto cuesta ese conteo antes de pensar en Cairo

## Historia técnica resumida

1. La arquitectura original intentó materializar `is_mine` para la frontera
   aún cerrada.
2. Se detectó que "oculto para la UI" no implica oculto on-chain:
   el storage seguiría siendo público.
3. Eso forzó una reformulación: no almacenar el futuro, sino contar
   exactamente los outcomes observables compatibles con el transcript
   público.
4. 2A nació como primer baseline exacto y deliberadamente poco optimizado.
5. La corrección inicial se ancló en un oracle exhaustivo independiente
   `5x5/2`.
6. Luego se agregó un smoke reproducible `30x16/99`.
7. Después se endureció la superficie operativa con budgets, clasificación
   de abortos y JSONL reproducible.
8. Finalmente se corrió un benchmark principal más amplio para congelar 2A
   como baseline comparativo.
9. Los próximos pasos 2B (locality) y 2C (reuse/incrementalidad) siguen
   explícitamente pendientes.

## Hipótesis de trabajo

1. La corrección exacta puede validarse contra un oracle exhaustivo
   independiente en `5x5/2`.
2. Un baseline poco optimizado pero estructuralmente correcto puede resolver
   algunos estados `30x16/99` con tiempos off-chain modestos.
3. El coste va a depender menos del tamaño total del tablero que de la
   frontera efectivamente constrained y, dentro de ella, del mayor
   componente conexo.

Estas son hipótesis, no conclusiones generales.

## Diseño de 2A

### Qué hace

`scripts/conditional_sampling_exact.py` implementa:

- oracle exhaustivo independiente por enumeración de tableros completos
- constructor de constraints desde el transcript público
- separación en componentes conexas de variables/constraints
- conteo exacto por componente
- recombinación global por número de minas
- evaluación de una celda cerrada concreta en los 10 outcomes
- instrumentación por outcome y por evaluación
- smoke reproducible `30x16/99` con JSONL

### Qué hace deliberadamente de más

2A recalcula desde cero cada outcome de cada click:

- vuelve a construir constraints
- vuelve a separar componentes
- vuelve a enumerar asignaciones válidas por componente
- vuelve a recombinar por número de minas

No reutiliza trabajo entre:

- clicks distintos
- outcomes distintos de la misma celda
- transcripts consecutivos

Ese exceso es intencional. 2A busca un baseline claro contra el que luego se
compararán:

- 2B: restringir el cálculo al componente relevante/local
- 2C: reutilizar cálculos entre clicks mediante cache/DP incremental

### Algoritmo

Para un transcript `T`:

1. Cada pista revelada induce una ecuación binaria local sobre celdas
   cerradas adyacentes.
2. Las celdas cerradas que aparecen en alguna ecuación forman la frontera
   constrained.
3. Las celdas cerradas fuera de toda ecuación se agregan combinatoriamente
   mediante `C(H, k)`.
4. La frontera se separa en componentes conexas del grafo
   variable-constraint.
5. Para cada componente `C`, se computa exactamente `F_C[k]`.
6. Los componentes se recombinan por convolución en el número de minas.
7. Se impone exactamente el número global de minas restantes.

Para evaluar un outcome:

- `mine`: fijar `x` como mina y volver a contar
- `clue q`: fijar `x` como safe, revelar la pista `q` y volver a contar

## Definición de métricas

Por evaluación de celda se registran, entre otras:

- tamaño del tablero
- minas totales y minas restantes
- celdas reveladas y cerradas
- variables de frontera
- celdas cerradas unconstrained
- número de constraints
- número de componentes
- tamaños de componentes
- mayor componente
- longitud de cada vector `F_C[k]`
- nodos de búsqueda
- operaciones de rama
- hojas solución
- convoluciones
- outcomes con `N_o > 0`
- `N_mine, N_0..N_8`
- `sum_counts`
- bit length del mayor conteo
- wall-clock

Conviene distinguir dos familias:

- métricas estructurales del transcript antes del click:
  `frontier_variables`, `constraint_count`, `component_count`,
  `component_sizes`, `largest_component`, `component_vector_lengths`
- métricas de coste de la evaluación completa:
  `total_search_nodes`, `total_branch_ops`, `total_leaf_solutions`,
  `total_convolutions`

En la versión congelada de 2A:

- `before_click_*` mide el conteo de completaciones compatibles con el
  transcript antes del click
- `per_outcome[*]` desglosa el coste de cada uno de los 10 outcomes
- `total_*` agrega `before_click_* + Σ per_outcome[*]`

2A no usa memo persistente ni DP incremental. Por eso:

- `memo_entries = 0`
- `dp_states_explored = 0`

No se interpretan como ausencia de estructura futura, sino como propiedad
del baseline elegido.

## Dataset de corrección

Oracle independiente:

- tablero `5x5`
- `2` minas
- `C(25, 2) = 300` tableros completos

Tests implementados en:

- `scripts/test_conditional_sampling_exact.py`

Cobertura de esta iteración:

- fixtures manuales con conteos calculables a mano
- tratamiento explícito de `known_mines`
- comparación exacta oracle vs contador por constraints/componentes
- igualdad exacta de los 10 outcomes
- invariante de partición:
  `N_mine + Σ N_q = total de completaciones compatibles con T`
- outcomes imposibles
- transcript incompatible
- celda forzada mine
- existencia de caso forzado safe
- caso que reduce el espacio a configuración única
- timeout con resultado parcial
- budget con resultado parcial
- mini-benchmark que verifica que timeout/budget no degraden a `error`

## Resultado medido — Fase 1

Comando corrido:

```bash
python3 -m unittest discover -s scripts -p 'test_conditional_sampling_exact.py'
```

Resultado:

- `12` tests
- `OK`
- tiempo local observado en la última corrida: ~17.3 s

Esto valida la corrección exacta en el caso exhaustivo `5x5/2` para la
iteración 2A.

## Smoke reproducible — Fase 4

Comando corrido:

```bash
python3 scripts/conditional_sampling_exact.py smoke
```

Archivo raw:

- `benchmarks/conditional-sampling-2a-smoke-20260830.jsonl`

Configuración:

- tableros `30x16`
- `99` minas
- seeds: `20260830`, `20260831`
- transcripts por seed: `early`, `mid`, `late`
- celdas evaluadas por transcript: hasta `2`, preferentemente en frontera

## Resultado medido — smoke 30×16/99

Resumen observado:

- evaluaciones: `12`
- errores: `0`
- min: `6.20 ms`
- p50: `7.58 ms`
- p90: `24.37 ms`
- p95: `30.45 ms`
- p99: `36.28 ms`
- max: `37.74 ms`
- media: `12.83 ms`
- mayor componente observado: `54`
- mayor bit length observado: `345`
- `search_nodes` p50: `1454`
- `search_nodes` p95: `6454.90`
- `search_nodes` max: `9074`
- `branch_ops` p50: `2702`
- `branch_ops` p95: `12584.00`
- `branch_ops` max: `18040`

Caso más barato:

- transcript: `seed-20260831-early`
- celda: `(15,7)`
- tiempo: `6.20 ms`
- mayor componente: `8`
- outcomes positivos: `7`

Caso más caro por wall-clock:

- transcript: `seed-20260830-mid`
- celda: `(13,8)`
- tiempo: `37.74 ms`
- mayor componente: `47`
- outcomes positivos: `4`
- counts no nulos: `clue 2`, `clue 3`, `clue 4`, `clue 5`

Caso con más búsqueda:

- transcript: `seed-20260830-mid`
- celda: `(13,8)`
- tiempo: `37.74 ms`
- mayor componente: `47`
- `total_search_nodes = 9074`
- `total_branch_ops = 18040`

## Interpretación

Lo que muestran directamente los datos:

- la exactitud quedó validada en el dominio exhaustivo `5x5/2`
- el baseline exacto 2A ya puede correr algunos casos `30x16/99`
- en este smoke el mayor componente observado fue `54`
- los tiempos no crecieron de forma trivial con el tamaño del componente:
  hubo casos con componente `54` más baratos que un caso con componente `47`

Lo que eso sugiere, sin elevarlo todavía a ley general:

- no alcanza con mirar solo `largest_component`
- importa también la forma concreta de las constraints y cuántos outcomes
  quedan realmente compatibles
- los casos donde el transcript fuerza un outcome único pueden seguir
  teniendo búsqueda no trivial, pero cierran rápido por poda

## Hipótesis para 2B y 2C

1. 2B debería bajar el coste medio limitando el trabajo al componente
   afectado por la celda evaluada, en vez de reconstruir el problema global
   completo para cada outcome.
2. 2C debería bajar todavía más el coste reutilizando estructura entre
   clicks consecutivos del mismo transcript/partida.
3. El factor de coste más informativo probablemente será una combinación de:
   tamaño del mayor componente, número de constraints activas y número de
   outcomes todavía compatibles.

Estas hipótesis siguen pendientes de verificación.

## Estado actual de 2A-hardening

La auditoría crítica del working tree encontró dos bugs reales de hardening
y ambos quedaron corregidos antes de congelar 2A:

- la ruta donde un timeout/budget ocurría durante el conteo base previo a
  los outcomes se degradaba a `error` genérico
- `max_search_nodes` y `max_branch_ops` no eran realmente globales a la
  evaluación completa; se aplicaban localmente por problema/componente

Además, 2A-hardening ya tenía implementado en código:

- budgets de evaluación por `wall_clock_s`, `max_search_nodes` y
  `max_branch_ops`
- `EvaluationAbortedError` con resultado parcial serializable
- generador de benchmark separado del smoke
- selección más diversa de celdas por transcript
- JSONL para benchmark principal
- resumen agregado con percentiles y top casos costosos

Tests agregados para hardening:

- timeout con resultado parcial
- budget con resultado parcial
- mini-run de benchmark que verifica que esos abortos no caen en `error`
- verificación de que `total_*` agrega correctamente el coste previo al
  click y el de todos los outcomes

## Resultado medido — benchmark principal 2A-hardening

Comando corrido:

```bash
python3 scripts/conditional_sampling_exact.py benchmark \
  --seeds 20260840,20260841,20260842,20260843,20260844,20260845,20260846,20260847,20260848,20260849 \
  --max-evaluations 120 \
  --timeout-s 2.0 \
  --max-search-nodes 100000 \
  --max-branch-ops 200000 \
  --out benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl
```

Archivo raw:

- `benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl`

Resumen observado:

- evaluaciones: `120`
- `ok`: `120`
- `timeouts`: `0`
- `budget_exceeded`: `0`
- `errors`: `0`
- wall-clock p50: `11.89 ms`
- wall-clock p90: `49.74 ms`
- wall-clock p95: `93.07 ms`
- wall-clock p99: `252.10 ms`
- wall-clock max: `416.00 ms`
- wall-clock media: `26.49 ms`
- `largest_component` p50: `31.5`
- `largest_component` p95: `53`
- `largest_component` p99: `56`
- `largest_component` max: `56`
- `search_nodes` p50: `1790`
- `search_nodes` p95: `23048.95`
- `search_nodes` p99: `57349.70`
- `search_nodes` max: `60554`
- `branch_ops` p50: `3256`
- `branch_ops` p95: `43864.50`
- `branch_ops` p99: `103980.46`
- `branch_ops` max: `109444`
- `max_count_bit_length` p50: `312`
- `max_count_bit_length` p95: `343`
- `max_count_bit_length` p99: `344`
- `max_count_bit_length` max: `344`

Resumen compacto para baseline comparativo 2A:

| métrica | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| wall-clock Python (ms) | 1.98 | 26.49 | 11.89 | 93.07 | 252.10 | 416.00 |
| `total_search_nodes` | 125 | 5451.25 | 1790 | 23048.95 | 57349.70 | 60554 |
| `total_branch_ops` | 226 | 10052.55 | 3256 | 43864.50 | 103980.46 | 109444 |
| `largest_component` | 10 | 29.93 | 31.5 | 53 | 56 | 56 |
| `max_count_bit_length` | 250 | 306.17 | 312 | 343 | 344 | 344 |

Lectura corta orientada a trabajo computacional:

| métrica | típico (p50) | p95 | peor observado |
| --- | ---: | ---: | ---: |
| `total_search_nodes` | 1790 | 23048.95 | 60554 |
| `total_branch_ops` | 3256 | 43864.50 | 109444 |

Casos más caros observados:

- `seed-20260840-mid`, celda `(14,2)`: `416.00 ms`,
  `largest_component=46`, `search_nodes=59871`
- `seed-20260840-late`, celda `(20,13)`: `260.27 ms`,
  `largest_component=50`, `search_nodes=46601`
- `seed-20260840-mid`, celda `(20,12)`: `217.31 ms`,
  `largest_component=46`, `search_nodes=60554`

Lectura directa de estos datos:

- bajo estos límites, el hardening del baseline no encontró abortos ni
  errores en `120` evaluaciones
- `search_nodes` y `branch_ops` son métricas algorítmicas más útiles que el
  wall-clock para comparar 2A → 2B → 2C
- `total_*` ya mide el conteo previo al click más los 10 outcomes
- el coste sigue dependiendo de la estructura concreta del transcript, no
  solo de `largest_component`
- el benchmark ya observó conteos con bit length `344`, por encima de
  `felt252`; una futura implementación Cairo tendrá que considerar
  aritmética multi-limb o equivalente
- ya hay una superficie reproducible suficiente para comparar 2B/2C contra
  percentiles, no solo contra casos aislados

## Reproducibilidad

Verificaciones independientes hechas sobre los archivos raw:

- `benchmarks/conditional-sampling-2a-smoke-20260830.jsonl`:
  `12` registros, todos `status=ok`
- `benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl`:
  `120` registros, todos `status=ok`
- `benchmarks/conditional-sampling-2a-corpus-20260830.jsonl`:
  corpus congelado de `120` casos para reutilizar exactamente en 2B y 2C
- los transcripts regenerados desde los seeds documentados coinciden con los
  transcripts serializados en ambos JSONL
- las celdas evaluadas en cada fila coinciden con las funciones de selección
  reproducibles del script
- al re-ejecutar el contador sobre cada fila, los campos discretos
  (`counts`, `sum_counts`, `compatible_total_before_click`,
  `largest_component`, `constraint_count`, `frontier_variables`,
  `max_count_bit_length`, `total_search_nodes`, `total_branch_ops`)
  coinciden exactamente con el raw
- los enteros grandes sobreviven la serialización JSON como enteros exactos;
  no pasan por `float`

Separación explícita generador vs contador:

- el generador de transcripts `30x16/99` usa un tablero oracle interno
  derivado del seed solo para producir el transcript público
- el contador exacto nunca consulta ese tablero oculto; recibe únicamente un
  `Transcript` y reconstruye el espacio compatible desde sus pistas/flags

Entorno local de referencia para wall-clock:

- Python: `3.12.3`
- SO/kernel: `Linux 6.8.0-138-generic x86_64`
- CPU: `AMD Ryzen 3 2200U with Radeon Vega Mobile Gfx`

Advertencia de interpretación:

- estos wall-clock son una referencia empírica de esta máquina y de este
  runtime de Python
- corresponden a Python `3.12.3` sobre `AMD Ryzen 3 2200U`
- `search_nodes` y `branch_ops` no son Cairo steps ni gas
- no son una estimación de Cairo, gas ni Starknet
- re-correr los mismos comandos reproduce transcripts, counts y estructuras;
  los wall-clock pueden variar entre corridas

Dataset común congelado para comparación posterior:

- el corpus `benchmarks/conditional-sampling-2a-corpus-20260830.jsonl`
  conserva exactamente los `120` casos de entrada del benchmark principal
  sin incluir resultados de 2A
- 2B y 2C deberán medirse sobre este mismo corpus caso por caso para que la
  comparación 2A → 2B → 2C sea estrictamente sobre la misma entrada pública

## Limitaciones de 2A

- no mide todavía Cairo/gas
- no reutiliza trabajo entre outcomes
- no reutiliza trabajo entre clicks
- no explota locality del componente relevante
- el benchmark `120` evals sigue siendo un muestreo acotado
- no demuestra ausencia de casos patológicos
- no autoriza todavía ninguna conclusión fuerte sobre viabilidad on-chain
- no es todavía una propuesta final de implementación on-chain

## Pregunta pendiente para Cairo

Todavía no hay un resultado medido de Cairo. La pregunta pendiente es doble:

- cuánto cuesta en Cairo una unidad de este trabajo algorítmico
  (`search_nodes` / `branch_ops`)
- cuánto logran reducir 2B y 2C ese trabajo antes del eventual port

## Decisiones derivadas en esta iteración

- mantener 2A como baseline exacto y explícitamente poco optimizado
- usar este baseline como referencia para 2B y 2C
- no sacar todavía conclusiones sobre port a Cairo más allá de que el
  problema no murió inmediatamente off-chain

## Artefactos

- código:
  `scripts/conditional_sampling_exact.py`
- tests:
  `scripts/test_conditional_sampling_exact.py`
- raw smoke:
  `benchmarks/conditional-sampling-2a-smoke-20260830.jsonl`
- raw benchmark:
  `benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl`

---

# EXPERIMENTO 2B — Locality
### (2026-08-30)

## Objetivo

Mantener exactamente los mismos conteos `N_mine, N_0..N_8` que 2A, pero
evitando recontar con DFS los componentes del grafo de constraints que
quedan idénticos para un outcome dado.

2B sigue tratando cada caso del corpus como independiente:

- no reutiliza trabajo entre clicks distintos
- no reutiliza trabajo entre casos del corpus
- no introduce todavía cache incremental

Eso queda explícitamente para 2C.

## Idea implementada

Para una evaluación de celda:

1. Se computa una sola vez el perfil exacto previo al click, igual que en 2A.
2. Para cada outcome, se reconstruye la estructura del problema resultante.
3. Los componentes outcome cuya firma `(variables, constraints)` coincide con
   un componente untouched del estado previo se reutilizan por su vector
   exacto `F_C[k]`, sin DFS nuevo.
4. Sólo los componentes outcome afectados se reenumeran con DFS.
5. Luego se recombinan:
   componentes recalculados + componentes reutilizados + unconstrained cells,
   manteniendo exactamente el total global de minas restantes.

La implementación de referencia quedó en:

- `scripts/conditional_sampling_locality.py`

## Validación incremental

Antes de correr los `120` casos se hizo una validación escalonada:

- primeros `5` casos del corpus: igualdad exacta `2A == 2B`
- primeros `20` casos del corpus: igualdad exacta `2A == 2B`
- casos dirigidos multi-componente:
  `2a-045`, `2a-046`, `2a-047`, `2a-048`
- verificación final sobre el corpus completo:
  `120 / 120` casos exactos, `0` mismatches

Tests agregados para 2B:

- `scripts/test_conditional_sampling_locality.py`
- suite local final:
  `16` tests, `OK`

## Resultado medido — exactitud

La exigencia fuerte de 2B era:

- igualdad exacta de `counts`
- igualdad exacta de `sum_counts`
- igualdad exacta de `compatible_total_before_click`
- mantenimiento del partition invariant

Resultado observado en el corpus congelado común:

- casos verificados: `120`
- mismatches: `0`
- `counts`: igualdad exacta en `120/120`
- `sum_counts`: igualdad exacta en `120/120`
- `compatible_total_before_click`: igualdad exacta en `120/120`
- `partition_ok`: igualdad exacta en `120/120`

## Resultado medido — benchmark 2B sobre el corpus común

Comando corrido:

```bash
python3 scripts/conditional_sampling_locality.py benchmark \
  --out benchmarks/conditional-sampling-2b-locality-20260830.jsonl
```

Archivo raw:

- `benchmarks/conditional-sampling-2b-locality-20260830.jsonl`

Resumen 2B:

| métrica | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| wall-clock Python (ms) | 2.35 | 21.17 | 10.42 | 77.45 | 177.94 | 181.49 |
| `total_search_nodes` | 125 | 5446.37 | 1790 | 23048.95 | 57349.70 | 60554 |
| `total_branch_ops` | 226 | 10043.28 | 3256 | 43864.50 | 103980.46 | 109444 |

Instrumentación locality específica observada:

- casos con reuse efectivo de al menos un componente untouched: `4 / 120`
- casos sin reuse: `116 / 120`
- casos con merge de componentes previamente separados: `0`
- `components_reused_total` por evaluación:
  media `0.1583`, max `9`
- `largest_recomputed_component`:
  min `1`, media `30.74`, p50 `32`, p95 `53.05`, p99 `56`, max `57`

## Comparación agregada 2A vs 2B

### `total_search_nodes`

| variante | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 125 | 5451.25 | 1790 | 23048.95 | 57349.70 | 60554 |
| 2B | 125 | 5446.37 | 1790 | 23048.95 | 57349.70 | 60554 |
| reducción `2A - 2B` | 0 | 4.88 | 0 | 0 | 26.43 | 532 |
| factor `2A / 2B` | 1.0000 | 1.0084 | 1.0000 | 1.0000 | 1.0047 | 1.9907 |

### `total_branch_ops`

| variante | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 226 | 10052.55 | 3256 | 43864.50 | 103980.46 | 109444 |
| 2B | 226 | 10043.28 | 3256 | 43864.50 | 103980.46 | 109444 |
| reducción `2A - 2B` | 0 | 9.27 | 0 | 0 | 35.24 | 1040 |
| factor `2A / 2B` | 1.0000 | 1.0084 | 1.0000 | 1.0000 | 1.0032 | 1.9943 |

### wall-clock Python

| variante | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 1.98 | 26.49 | 11.89 | 93.07 | 252.10 | 416.00 |
| 2B | 2.35 | 21.17 | 10.42 | 77.45 | 177.94 | 181.49 |
| reducción `2A - 2B` | -7.03 | 5.32 | 1.50 | 11.51 | 81.39 | 235.77 |
| factor `2A / 2B` | 0.7248 | 1.1768 | 1.1313 | 1.4611 | 2.2781 | 2.3441 |

Casos con mayor mejora en `search_nodes`:

- `2a-047` — `seed-20260843-late`, celda `(12,11)`:
  `532` nodos menos, `1040` branch ops menos,
  factor `1.9907`, reuse total `1`,
  `largest_recomputed_component = 1`
- `2a-046` — `seed-20260843-late`, celda `(7,4)`:
  `27` nodos menos, `36` branch ops menos,
  factor `1.0029`, reuse total `9`
- `2a-048` — `seed-20260843-late`, celda `(8,4)`:
  `24` nodos menos, `32` branch ops menos,
  factor `1.0049`, reuse total `8`
- `2a-045` — `seed-20260843-late`, celda `(16,8)`:
  `3` nodos menos, `4` branch ops menos,
  factor `1.0038`, reuse total `1`

Casos donde 2B no mejora `search_nodes` ni `branch_ops`:

- `116 / 120`

Casos donde 2B empeora en wall-clock:

- `16 / 120`
- el peor observado fue `2a-092`
  (`seed-20260847-mid`, celda `(14,3)`),
  con penalización de `7.03 ms`
  aun cuando el trabajo algorítmico fue idéntico

## Interpretación

Lo que muestran directamente los datos:

- 2B preserva exactitud total respecto de 2A en el corpus común
- en este corpus, la locality solo encuentra reuse real en `4` casos
- no aparecieron casos donde la nueva constraint local uniera componentes que
  antes estaban separados
- la mejora algorítmica agregada es pequeña porque `116/120` casos ya eran,
  desde el inicio, esencialmente monocomponente
- aun así, el wall-clock medio y de cola mejoró respecto de 2A en esta
  máquina

Lo que esto sugiere, sin elevarlo todavía a conclusión general:

- la locality por sí sola no alcanza si el corpus está dominado por un único
  componente grande
- el valor de 2B aparece cuando el transcript deja componentes untouched
  realmente separables
- para extraer mejoras sistemáticas probablemente hará falta 2C
  (reuse/caching entre clicks o estados cercanos), no solo locality estática

Nota breve sobre 2B2 descartado:

- se probó una proyección exacta por enumeración de patrones/configuraciones
  locales sobre `x + vecinos`
- se descartó como dirección de 2B2 porque multiplicaba innecesariamente el
  conteo residual exacto del resto del tablero

## 2B2-naive — diez conteos independientes exactos

Se implementó una variante 2B2 separada que resuelve exactamente estos
`10` problemas por celda:

- `x = mine`
- `x = safe` con una sola constraint agregada
  `sum(minas entre vecinos cerrados de x) = j`, para `j in 0..8`

Importante:

- no enumera configuraciones binarias de vecinos
- no determina qué vecinos son minas
- no materializa tableros futuros

Implementación:

- `scripts/conditional_sampling_2b2_exact_outcomes.py`

Tests:

- `scripts/test_conditional_sampling_2b2_exact_outcomes.py`

Raw:

- `benchmarks/conditional-sampling-2b2-exact-outcomes-20260830.jsonl`

Resultado medido sobre el corpus congelado común:

- exactitud `120/120` contra 2A
- `problems_executed = 10` en `120/120`
- `additional_top_level_subproblems = 0` en `120/120`

Resumen 2B2-naive:

| métrica | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| wall-clock Python (ms) | 0.61 | 16.24 | 6.42 | 67.93 | 165.85 | 184.64 |
| `total_search_nodes` | 48 | 4763.05 | 1340.5 | 21291.60 | 52760.79 | 55602 |
| `total_branch_ops` | 94 | 8775.88 | 2563 | 40422.20 | 96244.32 | 100512 |

Interpretación medida:

- 2B2-naive elimina el conteo global previo redundante de 2A
- pero el coste de sus `10` outcomes coincide exactamente con el coste
  outcome-only de 2A
- por eso 2B2-naive queda preservado como checkpoint correcto, pero
  descartado como dirección final por redundancia algorítmica

## 2B3 — shared exact outcomes

Objetivo de 2B3:

- producir directamente `N_mine, N_0..N_8`
- en una sola resolución compartida del transcript
- sin lanzar `10` DFS independientes

Implementación:

- `scripts/conditional_sampling_2b3_shared_outcomes.py`

Tests:

- `scripts/test_conditional_sampling_2b3_shared_outcomes.py`

Raw:

- `benchmarks/conditional-sampling-2b3-shared-outcomes-20260830.jsonl`

### Diseño

2B3 no resuelve `10` hipótesis separadas. En cambio:

1. construye una sola vez el problema de constraints del transcript público
2. descompone en componentes conectados
3. cada componente totalmente ajeno a `x` se cuenta una sola vez con su
   vector usual `F_C[k]`
4. el único componente especial que toca `x` y/o vecinos cerrados de `x`
   se cuenta una sola vez con una distribución conjunta
   `ways[mines_in_component, x_is_mine, neighbor_mines]`
5. las celdas unconstrained locales se incorporan combinatoriamente por
   coeficientes binomiales, sin enumerar configuraciones
6. las demás unconstrained cells se integran con su vector combinatorio
   habitual
7. la convolución final produce directamente los `10` outcomes observables

Lo que 2B3 comparte realmente:

- el recorrido DFS del componente local
- la contabilidad de minas globales
- la clasificación por outcome visible de `x`

Lo que 2B3 todavía no hace:

- memoización adicional
- DP sobre separadores/estados comprimidos

Eso queda explícito en la instrumentación actual:

- `memo_entries = 0`
- `dp_states_explored = 0`

### Auditoría crítica

Revisión hecha sobre el código final de 2B3:

- no hace ningún conteo oculto previo del transcript:
  usa `build_constraints()` + `connected_components()`, no `problem_profile()`
- ejecuta una sola resolución compartida:
  cada componente ordinary se cuenta una vez y el componente special se
  cuenta una vez con distribución conjunta
- `total_search_nodes` y `total_branch_ops` agregan todo el trabajo DFS
  ejecutado por 2B3
- las unconstrained local cells se integran por combinatoria cerrada, sin
  enumerar configuraciones
- el total global de minas se aplica filtrando exactamente los estados con
  `mines_used == remaining_mines`
- la clasificación `x=mine` vs `x=safe + neighbor_mines=j` particiona las
  completaciones exactamente una vez
- `Σ N_o` coincide exactamente con el total de completaciones del transcript
  en `120/120`
- no apareció doble conteo ni pérdida de completaciones en la validación
  completa contra 2A
- el partition invariant interno quedó calculado de forma independiente a la
  clasificación por outcome:
  `compatible_total_before_click` se deriva directamente de la
  `joint_distribution` filtrando `mines_used == remaining_mines`, y luego se
  verifica `partition_ok = (Σ N_o == compatible_total_before_click)`

### Validación

Exigencia fuerte sobre el corpus congelado común:

- igualdad exacta de `N_mine, N_0..N_8`
- igualdad exacta de `sum_counts`
- igualdad exacta de `compatible_total_before_click`
- `partition_ok = True`
- `problems_executed = 1`
- `shared_single_pass = True`

Resultado:

- casos verificados: `120`
- mismatches: `0`
- exactitud `2A == 2B3`: `120 / 120`

### Resultado medido

Resumen 2B3:

| métrica | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| wall-clock Python (ms) | 2.89 | 7.40 | 6.54 | 16.82 | 21.91 | 22.69 |
| `total_search_nodes` | 64 | 688.20 | 324.5 | 3041 | 4952 | 4952 |
| `total_branch_ops` | 116 | 1276.67 | 581 | 5596 | 8932 | 8932 |
| `convolutions` | 2 | 2.81 | 3 | 3 | 4 | 4 |
| `ordinary_component_count` | 0 | 0.03 | 0 | 0 | 1 | 1 |
| `special_component_count` | 1 | 1.00 | 1 | 1 | 1 | 1 |
| `unconstrained_local_count` | 0 | 2.48 | 3 | 5 | 5 | 5 |

Comparación agregada:

### `total_search_nodes`

| variante | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 125 | 5451.25 | 1790 | 23048.95 | 57349.70 | 60554 |
| 2B2-naive | 48 | 4763.05 | 1340.5 | 21291.60 | 52760.79 | 55602 |
| 2B3 | 64 | 688.20 | 324.5 | 3041 | 4952 | 4952 |

Factores:

- `2A / 2B3`: min `1.4748`, mean `9.6318`, p50 `7.1506`,
  p95 `31.1684`, p99 `35.6159`, max `37.3750`
- `2B2 / 2B3`: min `0.4748`, mean `8.6318`, p50 `6.1506`,
  p95 `30.1684`, p99 `34.6159`, max `36.3750`

### `total_branch_ops`

| variante | min | mean | p50 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 226 | 10052.55 | 3256 | 43864.50 | 103980.46 | 109444 |
| 2B2-naive | 94 | 8775.88 | 2563 | 40422.20 | 96244.32 | 100512 |
| 2B3 | 116 | 1276.67 | 581 | 5596 | 8932 | 8932 |

Factores:

- `2A / 2B3`: min `1.4693`, mean `9.8288`, p50 `7.2078`,
  p95 `31.6708`, p99 `35.7680`, max `37.8276`
- `2B2 / 2B3`: min `0.4693`, mean `8.8288`, p50 `6.2078`,
  p95 `30.6708`, p99 `34.7680`, max `36.8276`

### Cola cara: p95 / p99 / máximo

Umbrales 2A:

- `p95 total_search_nodes = 23048.95`
- `p99 total_search_nodes = 57349.70`
- `max total_search_nodes = 60554`

Casos p95 observados y su coste en 2B3:

- `2a-006`:
  `2A=60554`, `2B2=55602`, `2B3=4952`
- `2a-008`:
  `2A=59871`, `2B2=54919`, `2B3=4952`
- `2a-010`:
  `2A=46601`, `2B2=43560`, `2B3=3041`
- `2a-012`:
  `2A=36939`, `2B2=33898`, `2B3=3041`
- `2a-058`:
  `2A=26772`, `2B2=26034`, `2B3=738`
- `2a-090`:
  `2A=44444`, `2B2=43089`, `2B3=1355`

Casos p99:

- `2a-006`: `2B3=4952`
- `2a-008`: `2B3=4952`

Máximo de 2A:

- `2a-006` (`seed-20260840-mid`, celda `(20,12)`)
- `2A=60554`, `2B2=55602`, `2B3=4952`
- factor `2A / 2B3 = 12.2282`
- factor `2B2 / 2B3 = 11.2282`

### Interpretación

Resultado medido directamente:

- 2B3 preserva exactitud total contra 2A en el corpus común
- 2B3 baja de forma fuerte la media, la mediana y especialmente la cola
  cara frente a 2A y 2B2-naive
- el componente special fue siempre único en este corpus
- no hubo todavía memoización ni DP adicional: la mejora viene solo del
  sharing estructural de los outcomes

Hipótesis que esto sugiere, todavía separadas del dato medido:

- el sharing entre outcomes ya captura una parte sustancial de la
  redundancia dominante de 2A/2B2
- la ganancia debería crecer cuando la celda tenga más outcomes positivos y
  más unconstrained local cells
- un siguiente paso natural sería memo/DP adicional dentro del componente
  special, no más recálculos outcome por outcome

## Hipótesis pendientes

- medir si un corpus futuro más fragmentado hace crecer claramente la ventaja
  de 2B
- medir cuánto trabajo logra recortar 2C sobre el mismo corpus común
- recién después preguntar cuánto cuesta en Cairo una unidad de este trabajo
  y si la reducción previa alcanza para volver razonable un port

## Artefactos 2B

- código:
  `scripts/conditional_sampling_locality.py`
- tests:
  `scripts/test_conditional_sampling_locality.py`
- raw benchmark 2B:
  `benchmarks/conditional-sampling-2b-locality-20260830.jsonl`

---

# EXPERIMENTO 2D — History-Aware / Incremental
### (2026-08-30)

## Pregunta

¿Cuánto trabajo exacto puede reutilizarse entre clicks consecutivos de una
misma historia, cuando el transcript crece de `T_i` a `T_{i+1}` tras
observar el outcome del click `x_i`?

La métrica principal pasa de un snapshot aislado a una historia completa:

```
coste total = startup + Σ evaluation(T_i) + Σ transition(T_i → T_{i+1})
```

comparado contra `Σ 2B3-from-scratch(T_i)`.

## Historias smoke

Tres historias reproducibles sobre tablero 12×12/20:

| id | política | seed | resultado | clicks |
|----|----------|------|-----------|--------|
| H1 | oracle_safe_local_center | 2026083001 | victoria | 46 |
| H2 | oracle_safe_jump_edge    | 2026083003 | victoria | 32 |
| H3 | public_risky_aggressive  | 2026083109 | derrota  |  6 |

Total: 84 puntos históricos.

El oracle solo genera la historia (board, outcome real, transcript siguiente).
Nunca interviene en los conteos: cada `(T_i, x_i)` se evalúa como si fuera
un transcript público opaco.

## 2D0 — Baseline Incremental Eager

### Diseño

2D0 preserva entre transcripts consecutivos:

- constraints
- componentes conectados y sus firmas exactas
- perfiles ordinarios `F_C[k]` de componentes reutilizados

**Transición `T_i → T_{i+1}`** (`build_state`, modo "2D0"):

1. Reconstruye constraints y componentes desde el transcript.
2. Para componentes con firma idéntica al step anterior: reutiliza el perfil.
3. Para componentes con firma nueva (changed): ejecuta `count_component()`
   eager → DFS ordinario → nodos cobrados en `transition.search_nodes`.

**Evaluación en `(T_i, x_i)`** (`evaluate_candidate_with_state`):

- Componente que contiene `x_i` o vecinos cerrados (special):
  ejecuta `count_component_joint()` → joint DFS.
- Otros componentes (ordinary): usa perfil cacheado, 0 DFS.

### Diagnóstico de doble conteo

Para un componente changed en la transición que resulta special en eval:

- Transición: `count_component()` ordinary → S nodos
- Evaluación: `count_component_joint()` sobre el mismo árbol → S nodos
- **Total: 2×S. Desperdicio: S.**

Verificación empírica: `eval_nodes[i] ≈ transition_nodes[i-1]` en el 91% de
los pasos de H1 (41/45) y el 100% de H3. En H2 (política jump), el 68%
(21/31), porque la política salta entre regiones y el componente changed
no siempre es el special del siguiente click.

El overhead de 2D0 respecto de 2B3 está compuesto íntegramente por las
transiciones eager: 120% del overhead en H1, 152% en H2, 100% en H3.
(Valores > 100% significan que el eval de 2D0 ya era más barato que 2B3 por
reutilización, pero el costo de transición lo superaba.)

### Resultado 2D0 (search_nodes, métrica oficial)

| historia | 2B3  | 2D0 eval | 2D0 trans | 2D0 total |
|----------|------|----------|-----------|-----------|
| H1 (46 clicks) | 3672 | 3150 | 3163 | 6313 |
| H2 (32 clicks) | 2202 | 1592 | 1779 | 3371 |
| H3 (6 clicks)  |  216 |  216 |  216 |  432 |
| total 84        | 6090 | —    | —    | 10116 |

2D0 es exacto (84/84 contra 2A/2B/2B2/2B3) pero peor que 2B3 en coste
total de historia. Sirve como baseline para cuantificar el beneficio de 2D1.

## 2D1 — Lazy Transition

### Idea

No ejecutar el DFS eager durante la transición. Los componentes changed quedan
marcados como `deferred` (profile=None). El DFS se corre una sola vez en el
momento en que realmente se necesita.

### Diseño

**Transición `T_i → T_{i+1}`** (`build_state`, modo "2D1"):

1. Reconstruye constraints y componentes.
2. Para componentes con firma idéntica: reutiliza el perfil (sin cambio).
3. Para componentes changed: marca `profile=None, profile_source="deferred"`.
   **No ejecuta ningún DFS. `transition.search_nodes = 0`.**

**Evaluación en `(T_i, x_i)`**:

- Componente deferred + special:
  ejecuta `count_component_joint()` directamente → 1 DFS (en lugar de 2 en 2D0).
- Componente deferred + ordinary:
  ejecuta `count_component()` al momento de usar su perfil → 1 DFS diferido.
  El perfil queda cacheado en el estado para reutilización posterior.
- Componente reused + ordinary: perfil disponible, 0 DFS.
- Componente reused + special: joint DFS necesario (siempre, igual que 2B3).

### Contabilidad de nodos

Por diseño y verificado en auditoría:

```
transition.search_nodes = 0  (siempre, en todo step 2D1)
eval.total_search_nodes = ordinary_materialization_nodes + special_evaluation_nodes
```

No existe DFS escondido en ninguna otra ruta de código.

### Correcciones al harness

Antes de implementar 2D1 se corrigieron tres problemas en
`conditional_sampling_history_smoke.py`:

1. **Bug real**: `IncrementalTransition` nunca tuvo el campo
   `recomputed_components` ni `recomputed_component_sizes`; el harness
   los referenciaba → `AttributeError` en producción. Corregido reemplazando
   por los campos reales (`eagerly_counted_components`,
   `changed_component_sizes`).

2. **Necesario para 2D1**: `persistent_state_size()` hacía
   `component.profile.solution_vector` sin verificar `None` → crash para
   componentes deferred. Corregido con guard `if component.profile is not None`.

3. **Limitación del harness**: `build_state()` solo se llamaba con modo
   implícito "2D0". Refactorizado para aceptar `modes=("2D0","2D1")` y
   correr cadenas de estado independientes por variante.

## Validación de exactitud

Sobre exactamente los 84 `(T_i, x_i)` de H1/H2/H3:

```
2A == 2B == 2B2 == 2B3 == 2D0 == 2D1
```

para `N_mine`, `N_0..N_8`, `sum_counts`, `compatible_total_before_click`
y `partition_ok`. Cero mismatches. El harness lanza `AssertionError` al
primer desvío; no hubo ninguno.

Tests: 28/28 OK (suite completa de conditional sampling).

## Resultado 2D1 — Métricas finales (calculadas desde raw)

### search_nodes (startup + Σ evaluation + Σ transition)

| historia | 2B3  | 2D0 eval | 2D0 trans | 2D0 total | 2D1 eval | 2D1 trans | 2D1 total | 2B3/2D1 | 2D0/2D1 |
|----------|------|----------|-----------|-----------|----------|-----------|-----------|---------|---------|
| H1 (46)  | 3672 | 3150 | 3163 | 6313 | 3187 | 0 | **3187** | **1.152x** | 1.981x |
| H2 (32)  | 2202 | 1592 | 1779 | 3371 | 2040 | 0 | **2040** | **1.079x** | 1.652x |
| H3 (6)   |  216 |  216 |  216 |  432 |  216 | 0 |  **216** | **1.000x** | 2.000x |
| total 84 | 6090 |    — |     — | 10116 |  5443 | 0 | **5443** | **1.119x** | 1.860x |

### branch_ops (misma métrica)

| historia | 2B3   | 2D1 total | 2B3/2D1 |
|----------|-------|-----------|---------|
| H1 (46)  | 6784  | 5922      | 1.146x  |
| H2 (32)  | 4100  | 3900      | 1.051x  |
| H3 (6)   |  364  |  364      | 1.000x  |
| total 84 | 11248 | 10186     | 1.104x  |

### Desglose eval de 2D1 (search_nodes)

| historia | ordinary_mat | special_eval | reused_costo_0 |
|----------|-------------|--------------|----------------|
| H1 |  37 (1%) | 3150 (99%) | dominante |
| H2 | 448 (22%) | 1592 (78%) | moderado  |
| H3 |   0  (0%) |  216 (100%) | ninguno  |

Los 448 nodos de ordinary_mat en H2 corresponden a componentes que la
política jump deja como changed-pero-no-special. En 2D0, esos mismos
componentes se pagaban en transición; en 2D1 se pagan en eval. Mismo costo,
distinto momento. Sin pérdida neta.

### Pasos donde 2D1 gana/empata/pierde vs 2B3 (per-step)

| historia | gana | empata | pierde |
|----------|------|--------|--------|
| H1 | 27 | 19 | **0** |
| H2 | 25 |  7 | **0** |
| H3 |  0 |  6 | **0** |

2D1 nunca pierde contra 2B3 en ningún paso individual.

### Desglose por fase (search_nodes)

| historia | fase   | steps | 2B3  | 2D0  | 2D1  | 2B3/2D1 |
|----------|--------|-------|------|------|------|---------|
| H1 | early |  9 | 1482 | 3001 | 1482 | 1.000x |
| H1 | mid   | 15 | 1140 | 2280 | 1125 | 1.013x |
| H1 | late  | 22 | 1050 | 1032 |  580 | **1.810x** |
| H2 | early |  6 |  370 |  525 |  370 | 1.000x |
| H2 | mid   |  1 |  155 |  111 |  155 | 1.000x |
| H2 | late  | 25 | 1677 | 2735 | 1515 | **1.107x** |
| H3 | early |  6 |  216 |  432 |  216 | 1.000x |

El beneficio crece en late-game: los componentes acumulan pasos sin cambiar
de firma, aumentando la reutilización efectiva. Early-game tiene pocas
constraints establecidas y casi todo es nuevo.

## Interpretación

Lo que muestran los datos directamente:

- 2D1 es más eficiente que 2B3 en coste total de historia para H1 (−13.2%)
  y H2 (−7.4%). H3 empata (historia corta, sin late-game).
- La lazy transition elimina el doble conteo sin introducir pérdidas.
- La ganancia viene exclusivamente de los componentes reutilizados entre steps
  (0 DFS en 2D1 vs DFS completo en 2B3).
- Los ordinarios materializados en 2D1 cuestan lo mismo que en 2D0 (solo
  se desplaza el momento del pago de transición a eval).
- El beneficio se concentra en late-game, donde los componentes son estables.

Lo que esto sugiere, separado del dato medido:

- El factor 1.81x de H1-late indica potencial real de reutilización en
  historias largas con política local estable.
- H2 (jump) extrae menos beneficio porque la política espacialmente dispersa
  reduce la coincidencia de firmas entre steps consecutivos.
- H3 (6 clicks, solo early) es un caso degenerado: ningún componente
  alcanza a estabilizarse.

## Análisis de carry-forward (hipótesis no implementada)

Después de evaluar `(T_i, x_i)`, `count_component_joint()` produjo:

```
ways[k, x_is_mine, neighbor_mines]
```

Al observar el outcome real:

- Si `x` revela mina: condicionar `x_is_mine = 1`
- Si `x` revela pista `j`: condicionar `x_is_mine = 0` y
  `neighbor_mines = j - known_adjacent_mines`

Para el caso simple (x estaba en el componente C, ningún split ni merge
al pasar a `T_{i+1}`):

```
F_{C_new}[k'] = ways[k', x_is_mine=0, m_needed]
```

Esto daría el perfil ordinario de `C_new` en `T_{i+1}` sin ningún DFS
adicional.

### Límites del carry-forward simple

1. **Split**: si revelar `x` divide C en `C_a` y `C_b`, el joint profile
   agrega las dos subregiones y no puede descomponerse sin información
   del árbol de descomposición.
2. **Merge**: si la nueva constraint conecta componentes antes separados,
   hace falta convolucionarlos.
3. **Consulta special subsiguiente**: el ordinary derivado no alcanza para
   contestar una nueva query joint sin un DFS fresco sobre `C_new`.
4. **Firma exacta**: el sistema actual reconoce reutilización solo por firma
   idéntica; `C_new` tiene distinta firma que C (variable `x` removida,
   nueva constraint), por lo que no habría match automático.

### Para implementar carry-forward real

- Guardar el joint profile después del special eval (no solo el ordinary).
- Lógica de "derivación de firma": detectar que `C_new` = C − {x} con
  conditioning y aplicar la derivación directa.
- Manejo explícito de splits y merges (posiblemente junction tree o
  representación factorizada).

Para el rango actual (componentes 5–20 variables, tablero 12×12) el overhead
de esta maquinaria adicional puede no justificarse. Para 30×16/99 con
historias largas, el argumento se hace más fuerte.

Este análisis queda como hipótesis abierta. No se implementa en 2D1.

---

## PRESTUDY 2D2 — Carry-Forward: Análisis Experimental
### (2026-08-30)

### Pregunta

¿Cuántas transiciones de las 3 historias smoke son estructuralmente aptas para
carry-forward (simple conditioning)? ¿Cuánto trabajo de 2D1 podría evitarse?

### Metodología

Script `scripts/conditional_sampling_2d2_prestudy.py`.
Para cada paso `(T_i, x_i)` de las 3 historias:
- Se identifica el/los componentes special en `IncrementalState` de 2D1.
- Se corre `count_component_joint()` para obtener el coste exacto del DFS.
- Se construye el estado `T_{i+1}` y se rastrean las variables del componente.
- Se clasifica la transición en una de 6 categorías.
- Se verifica si el siguiente click cae en la misma región y si es special u ordinary.

Los `special_nodes` del prestudy coinciden exactamente con los del benchmark
congelado (H1=3150, H2=1592, H3=216), verificando que el análisis es coherente.

### Taxonomía de transiciones

**A — DIRECTLY_CONDITIONABLE**

Todas las variables de C que quedaron en el frontier después de revelar `x_i`
forman un único componente C_new sin variables externas. La fórmula:

```
F_{C_new}[k'] = ways[k', x_is_mine=0, neighbor_mines=m_eff]
```

donde `m_eff = j − adjacent_known_mines`, es matemáticamente exacta.
`k'` no incluye `x_i` (ya no es variable del frontier).
Las dimensiones son: `k'` ∈ [0, |V_C|−1], `m_eff` ∈ [0, 8].

**B — SPLIT**

La remoción de `x_i` (o el cambio de constraints) divide C en ≥2 componentes.
No existe una deconvolución exacta del joint profile `ways[k, ·, ·]` en
perfiles individuales:

```
ways_C[k] = Σ_{k_a+k_b=k} F_A[k_a] · F_B[k_b]
```

Múltiples pares `(F_A, F_B)` producen el mismo `ways_C`. Carry-forward es
**matemáticamente imposible** para splits.

**C — MERGE**

El componente C_new en `T_{i+1}` contiene variables que no estaban en C.
El constraint nuevo de `x_i`'s clue conecta variables previamente separadas
(o unconstrained). Carry-forward no aplica.

**D — DISAPPEARED**

Las variables de C salen completamente del frontier (todo se revela).

**E — ALREADY_REUSABLE**

2D1 ya reutiliza el componente por firma exacta. Carry-forward no suma nada.

**F — MERGE+SPLIT**

Combinación de merge y split simultáneos.

### Resultados sobre 79 transiciones especiales

(84 pasos totales; 5 sin componente special — el click cae en región totalmente
unconstrained.)

| Categoría | Count | % | Nodes | % nodes |
|-----------|-------|---|-------|---------|
| C — MERGE | 42 | 53.2% | 3244 | 65.4% |
| A — DIRECTLY_CONDITIONABLE | 29 | 36.7% | 1310 | 26.4% |
| B — SPLIT | 4 | 5.1% | 268 | 5.4% |
| TERMINAL | 3 | 3.8% | 90 | 1.8% |
| F — MERGE+SPLIT | 1 | 1.3% | 46 | 0.9% |
| E — ALREADY_REUSABLE | **0** | 0% | 0 | 0% |

**MERGE domina (53.2%).** El mecanismo es inherente a Minesweeper: al revelar
`x_i` con pista `j`, el constraint `Σ N(x_i)∩closed = j − known_adj` conecta
vecinos cerrados de `x_i` que podían estar fuera de C (unconstrained o en otro
componente). Esto ocurre en early/mid-game donde el frontier crece, y reaparece
en late-game cuando la política salta a nuevas regiones.

**SPLIT (5.1%)** ocurre cuando `x_i` era el único enlace estructural entre dos
subgrafos de C. Hay 4 casos observados en H1 y H2.

**E=0**: el componente special siempre cambia de firma (x_i se remueve y se
agrega un constraint nuevo), por lo que 2D1 nunca reutiliza el componente
special del paso anterior directamente.

### El problema crítico: todos los A-cases tienen siguiente click special

De los 29 casos A:
- **25** tienen el siguiente click dentro de la misma región.
- En esos 25, el siguiente click es **SPECIAL** (necesita `count_component_joint()` nuevo).
- Derivar `F_{C_new}[k']` (ordinary profile) no evita ese joint DFS.
- **A_next_ordinary = 0**.

Los 4 A-cases con siguiente click fuera de la región son candidatos realistas:

| Historia | Click | Comp size | Nodes |
|----------|-------|-----------|-------|
| H2 | 7 | 35 | 111 |
| H2 | 10 | 30 | 128 |
| H2 | 11 | 4 | 6 |
| H1 | 38 | 2 | 3 |

Si esos componentes fuesen luego accedidos como **ordinary** (hipótesis
favorable), el ahorro máximo es **248 search_nodes**.

### Upper bound vs ahorro realista

| Escenario | Nodes ahorrados | % 2D1 total |
|-----------|-----------------|-------------|
| Todos los A condicionables (teórico puro) | 1310 | 24.1% |
| A con next_ordinary (fórmula correctamente aplicada) | **0** | **0%** |
| A sin siguiente click en región (mejor caso realista) | 248 | 4.6% |

El 2D1 total = 5443 nodes (H1+H2+H3).

### Carry-forward joint: ¿sirve para el caso next_special?

Para evitar el joint DFS del paso siguiente necesitaríamos derivar:

```
ways_{C_new}[k', x'_mine, n'_mine]
```

para la nueva query `(x', N')` desde el joint profile de C.
Esto requiere la distribución conjunta 4D:

```
ways_C[k, x_mine=0, n_mine=m_eff, x'_mine, n'_mine]
```

que el DFS actual no produce porque solo rastrea `(x, N)` del click corriente.
Precomputing esto para todos los posibles `(x', N')` es equivalente a enumerar
todas las posibles queries siguientes — impracticable sin tree decomposition.

### Conclusión

**2D2 simple carry-forward: descartado antes de implementación.**

- MERGE es el caso dominante (53.2%, 65.4% de los nodos): prerequisito
  estructural falla en más de la mitad de las transiciones.
- Para los casos A, el siguiente click es siempre special → el DFS joint es
  inevitable → ahorro ordinary = 0.
- Upper bound realista: 4.6% del coste de 2D1 en el mejor escenario.
- SPLIT es matemáticamente no-invertible.
- Para carry-forward que beneficie el caso next_special haría falta una
  representación de estado más rica (junction tree, variable elimination),
  que sería un algoritmo distinto: EXPERIMENTO 2E o 2D3.

## Artefactos 2D

- código incremental:
  `scripts/conditional_sampling_2d_incremental.py`
- harness de historias:
  `scripts/conditional_sampling_history_smoke.py`
- tests:
  `scripts/test_conditional_sampling_2d_incremental.py`
- historias smoke (84 puntos, 3 historias):
  `benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl`
- benchmark 2D0 + 2D1:
  `benchmarks/conditional-sampling-2d-smoke-20260830.jsonl`
- prestudy 2D2 (script de análisis):
  `scripts/conditional_sampling_2d2_prestudy.py`

## Artefactos prestudy 2E + 2E1

- script de análisis de treewidth (2E):
  `scripts/conditional_sampling_treewidth_prestudy.py`
- raw de métricas treewidth por componente (2E):
  `benchmarks/conditional-sampling-treewidth-prestudy-20260830.jsonl`
- script de simulación de factor aumentado (2E1):
  `scripts/conditional_sampling_treewidth_augmented_prestudy.py`
- raw de métricas de factor aumentado por componente (2E1):
  `benchmarks/conditional-sampling-treewidth-augmented-20260830.jsonl`

---

## PRESTUDY 2E — Treewidth del Frontier Constraint Graph
### (2026-08-30)

### Pregunta

¿Los grandes componentes del frontier tienen baja treewidth de su primal
constraint graph? Si la treewidth `w` está acotada mientras `n` crece,
variable elimination / junction tree sería exponencial en `w` en vez de en
`n`, con potencial aceleración significativa.

### Definiciones

**Primal constraint graph**: un nodo por variable booleana del frontier,
dos variables conectadas iff aparecen juntas en algún constraint.
Cada scope de constraint induce una clique en el primal graph.

**Treewidth** de este grafo = anchura del árbol de descomposición óptimo.
Para variable elimination: el ancho de eliminación de la mejor ordering.

**Métricas reportadas** (por componente):
- `upper_bound_min_fill`: ancho de eliminación con heurística min-fill
- `upper_bound_min_degree`: ancho de eliminación con heurística min-degree
- `upper_bound_best`: mínimo de los dos
- `lower_bound_clique`: max_clique_size − 1 (cota inferior)
- `exact_or_uncertain`: "exact" si lower_bound == upper_bound

**Bron-Kerbosch** para max clique: exacto. Nota: en grafos primales los
cliques pueden cruzar scopes (variables compartidas entre constraints),
así que max_clique no está acotado por max_scope. En el corpus 30×16/99
el max clique observado es 7.

### Datasets analizados

**A. Corpus 30×16/99** (benchmark objetivo): 120 casos, 124 componentes total,
120 especiales. Transcripts con 2-56 variables en el frontier.

**B. Historias smoke 12×12/20**: 81 pasos, 210 componentes total, 79 especiales.
Permite observar evolución early/mid/late.

### Resultados clave: 30×16/99

| Estadístico | n (size) | w (upper_bound) | 2^w | DFS nodes |
|-------------|----------|-----------------|-----|-----------|
| min | 2 | 1 | 2 | 64 |
| p50 | 30 | 5 | 32 | 324 |
| p90 | 49 | 6 | 64 | 3041 |
| p95 | 53 | 6 | 64 | 3041 |
| max | **56** | **6** | **64** | **4952** |

**Distribución de width (120 componentes especiales):**

| w | count | n range | n_mean | 2^w | avg_nodes |
|---|-------|---------|--------|-----|-----------|
| 1 | 1 | [2,2] | 2.0 | 2 | 535 |
| 4 | 55 | [16,56] | 35.6 | 16 | 808 |
| 5 | 28 | [33,53] | 43.3 | 32 | 956 |
| 6 | 36 | [10,12] | 10.4 | 64 | 302 |

**116/120 treewidths exactos** (lower_bound == upper_bound, confirmado por
Bron-Kerbosch).

Hallazgo estructural crítico: **los componentes grandes (n=40-56) tienen
width 4-5, no 6**. La width=6 pertenece a componentes pequeños y densos
(n=10-12). La treewidth no crece con n para el rango objetivo 30×16/99.

### Casos extremos

**Caso más caro por DFS** (2a-005): n=46, w=4, d=2, DFS=**4,952 nodos**
- Factor ordinario pico (paso 41): 2^4 × 43 = **688 entradas** (sep=4, mines_range=43)
- Factor especial pico: 688 × 2 × (2+1) = **4,128 entradas**
- ord_aug_max / DFS nodes = **0.14x** — el factor ordinario es más pequeño que el DFS
- spc_aug_max / DFS nodes = **0.83x** — el factor especial también por debajo del DFS
- Totales sobre todas las eliminaciones: ord_aug_total=8,771; spc_aug_total=52,626

**Componente más grande** (2a-033): n=**56**, w=4, d=1, DFS=1,453 nodos
- n/w = **14x** (el componente tiene 14 veces más variables que width)
- Factor especial pico: **3,392 entradas**; spc_aug_total=37,340
- spc_aug_total / nodes = 25.7x (la suma acumulada de tablas supera el DFS total)

**Nota**: el caso n=56, w=4, DFS=1,453 es "más fácil" que n=46, DFS=4,952
porque tiene más constraints (más determinación), no por la estructura de width.

### Correlación n/w y su interpretación

La relación n/w es el indicador clave de cuánto beneficia junction tree:

- p50 n/w = 6.6x en 30×16/99
- max n/w = 14.0x (caso n=56, w=4)

Esto significa: para el componente más grande, la treewidth es 1/14 del
tamaño del componente. Variable elimination procesa este componente en
tablas de tamaño 2^{sep_size} × mines_range (factor aumentado) — ver
análisis 2E1 para los tamaños concretos.

Para 2a-005 (el caso más caro): ord_aug_max=688, spc_aug_max=4,128,
comparado con 4,952 DFS nodes. La estimación O(n × 2^w) = 736 subestimaba
el factor de minas y sobreestimaba el beneficio — el análisis aumentado 2E1
da números más precisos.

### Resultados: 12×12/20 historias

| Phase | count | n range | med_n | w range | med_w | w/n mean |
|-------|-------|---------|-------|---------|-------|----------|
| early | 17 | [3,20] | 10 | [2,7] | 5 | 0.519 |
| mid | 15 | [23,29] | 27 | [4,6] | 4 | 0.166 |
| late | 47 | [2,35] | 22 | [1,7] | 5 | 0.247 |

**Resultado más importante**: la razón w/n cae de 0.52 (early) a 0.17 (mid).
Los componentes crecen de n≈10 a n≈27, pero la width media se mantiene en
4-5. El beneficio estructural de junction tree **se acentúa con el progreso**
del juego.

### Análisis aumentado de factores (PRESTUDY 2E1 — 2026-08-30)

La dimensión de factor correcta no es `2^w` sino `2^{sep_size} × mines_range`,
donde `mines_range` crece con cada eliminación (acumula el rango de minas
posibles en las variables ya eliminadas):

- **Factor ordinario** (F_C[k]): tamaño = `2^{sep_size} × mines_range`
- **Factor especial** (ways[k, x_mine, n_mine]): tamaño = `2^{sep_size} × mines_range × 2 × (d+1)`

donde `d = |N(x) ∩ component|` (vecinos del click dentro del componente).
Distribución de d en corpus 30×16/99: d=3 en 51 casos, d=2 en 38, d=1 en 11,
d=4 en 10, d=0 en 6, d=5 en 4. Mediana d=3; multiplicador extra típico = 2×4=8.

**Simulación sobre 120 casos** (usando la eliminación min-fill del prestudy 2E):

`ord_aug_max`, `spc_aug_max`, `ord_aug_total`, `spc_aug_total` son capacidades
estructurales bajo la ordering simulada: el número máximo de entradas que
tendría el factor table más grande, o la suma de entradas sobre todos los pasos.
**No equivalen** a entradas non-zero (sparsity puede reducirlos), ni a operaciones
aritméticas (joins/convoluciones y aritmética big-int pueden aumentarlas).

| Estadístico | ord_aug_max/nodes | spc_aug_max/nodes | ord_aug_total/nodes | spc_aug_total/nodes |
|-------------|:-----------------:|:-----------------:|:-------------------:|:-------------------:|
| p50 (global) | 1.56 | 10.77 | 11.46 | 68.77 |
| p90 (global) | 3.61 | 29.93 | — | — |
| max (global) | 5.00 | 40.00 | 44.71 | 357.67 |

**Para los 12 casos más caros (nodes>1500) — los que más necesitan optimización:**

| Estadístico | ord_aug_max/nodes | spc_aug_max/nodes | ord_aug_total/nodes | spc_aug_total/nodes |
|-------------|:-----------------:|:-----------------:|:-------------------:|:-------------------:|
| p50 | 0.32 | 1.92 | 3.82 | 21.10 |
| p90 | 0.48 | 2.87 | 4.82 | 30.56 |
| max | 0.48 | 3.87 | 4.82 | 38.56 |

**Interpretación**: los ratios globales altos están inflados por los casos fáciles
(DFS ya pequeño). Para los casos que más necesitan optimización (nodes>1500):
- Factor ordinario pico: 32-48% de DFS nodes. Factor especial pico: 2-4x DFS nodes.
- No se observa explosión de factores intermedios en ninguno de los 120 casos.
- `augmented factor states` y `DFS nodes` son métricas de trabajo distintas;
  el coste relativo real depende de sparsity, joins, marginalizaciones y
  aritmética big-int, y sólo puede determinarse implementando y benchmarkeando
  VE exacta.

**Limitaciones del análisis**:
1. Las entradas de factor son big integers (~344 bits según 2A); joins/marginalizaciones
   involucran sumas de enteros grandes, no operaciones elementales simples.
2. La sparsity de las factor tables (entradas cero por violación de constraint)
   puede reducir el trabajo real de forma significativa, pero no está medida.
3. El DFS propaga constraints en la recursión (poda temprana); VE no propaga
   equivalentemente — el coste relativo no se puede deducir de los tamaños de tabla.

### ¿Crece la treewidth con tableros más grandes?

Los datos del corpus son sobre tableros 30×16/99 (el objetivo de producción),
no tableros más grandes. El max width observado es **6** — no 7, no 8.

La razón estructural: el primal graph de las constraints del frontier de
Minesweeper refleja la topología local del tablero (celdas adyacentes
comparten constraints). Esta topología tiene treewidth acotada por ~3+
(largo del band más corto de un separator en el tablero 2D). Para 30×16,
el band puede ser hasta 16 — pero los componentes típicos son más cortos
y delgados, dando width ≤ 6 en todos los 120 casos observados.

No hay garantía teórica de que width ≤ 6 para todo 30×16 transcript, pero
los 120 casos del corpus (incluyendo los más grandes) nunca lo superan.

### Conclusión y recomendación

**Recomendación A — variable elimination exacta merece experimento.**

Razón:
1. Treewidth ≤ 6 observado en todos los 120 casos 30×16/99 (el tamaño objetivo).
2. Componentes de hasta 56 variables mantienen width 4-5; la treewidth no crece
   con n (n/w llega a 14x).
3. El análisis aumentado no muestra explosión de factores intermedios en ninguno
   de los 120 casos, incluso para los componentes más grandes y costosos.
4. Esto hace técnicamente plausible VE/junction-tree exacta sobre el corpus objetivo.
5. En historias 12×12: w/n cae de 0.52→0.17 con el progreso — el beneficio
   estructural se acentúa donde más importa (mid/late game).
6. 116/120 treewidths exactos confirmados — los bounds son precisos.

**No se reporta speedup estimado.** El rendimiento de VE frente al DFS actual
queda como hipótesis pendiente de implementación y benchmark real.

### Paso siguiente desde el prestudy

El paso correcto después de este prestudy quedó definido como:

1. implementar **2E2 snapshot VE** con ordering min-fill determinista
2. verificar exactitud `2E2 == 2B3` sobre el corpus congelado `120` casos
3. medir tamaño real de factores, sparsity y wall-clock Python
4. si la estructura sigue siendo manejable, avanzar a **2E3 history-aware VE**

No abrir variantes algorítmicas nuevas salvo blocker concreto.

## EXPERIMENTO 2E2 — Exact Variable Elimination
### (2026-08-30)

## Objetivo

Implementar un contador exacto alternativo por componente usando
**variable elimination sobre el primal constraint graph**, manteniendo
exactamente la semántica global validada en 2B3:

- componentes ordinary -> `F_C[k]`
- componente special -> `ways[k, x_is_mine, neighbor_mines]`
- mismo tratamiento global de `remaining_mines`, otros componentes,
  unconstrained interior, vecinos locales unconstrained y proyección final

El experimento 2E2 estudia deliberadamente **solo la eficiencia within-click**:

- mejora de `count(T,x)` dentro de un snapshot
- **sin** reuse entre `T_i` y `T_{i+1}`
- pero con arquitectura preparada para persistir/reusar en 2E3:
  firmas de componente, ordering, factores y estado intermedio

## Implementación

Código nuevo:

- `scripts/conditional_sampling_2e2_variable_elimination.py`
- `scripts/test_conditional_sampling_2e2_variable_elimination.py`

Raw benchmark:

- `benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl`
- `benchmarks/conditional-sampling-2e2-variable-elimination-repeated-20260830.jsonl`

Diseño elegido:

1. ordering **min-fill determinista** con desempate estable
2. factores **sparse** con `int` exactos de Python
3. tracking explícito de:
   `scope`, assignment del separator, `mine_count`, `x_is_mine`,
   `neighbor_mines`
4. la dimensión `k` de minas **se incrementa solo al eliminar variables**,
   no al crear factors base, para evitar doble conteo
5. la consulta special se expresa en la misma estructura que la ordinary,
   agregando solo dos acumuladores:
   `x_is_mine in {0,1}` y `neighbor_mines in [0,d]`

Esto deja una superficie directa para 2E3:

- `ComponentSignature`
- `ComponentEliminationPlan`
- `EliminationStep`
- `SparseCountFactor`

## Validación

Antes del corpus completo se agregaron tests para:

- creación/join/marginalización de factores
- tracking correcto de minas
- componente satisfacible / insatisfacible
- ordinary `F_C[k]` vs DFS de 2A
- special joint profile vs `count_component_joint()` de 2B3
- oracle exhaustivo chico `5x5/2`
- end-to-end sobre casos del corpus

Resultado local observado:

- `python3 -m unittest scripts/test_conditional_sampling_2e2_variable_elimination.py`
- `8` tests, `OK`

Exigencia fuerte del experimento:

- `2E2[N_mine, N_0..N_8] == 2B3[N_mine, N_0..N_8]`
- igualdad exacta también en:
  `compatible_total_before_click`, `sum_counts`, `partition_ok`

Resultado observado sobre el corpus congelado `30×16/99`:

- casos: `120`
- exactitud `2E2 == 2B3`: **120 / 120**
- mismatches: `0`

## Resultado medido

Auditoría de fairness del wall-clock:

- `2B3 wall_clock_ms` mide solo `evaluate_cell_shared_outcomes(T,x)`:
  arranca antes de `analyze_joint_problem()` y termina después de proyectar
  la `joint_distribution` a `counts`, sin incluir `compare_case()` ni
  validación externa.
- `2E2 wall_clock_ms` mide solo `evaluate_cell_2e2(T,x)`:
  arranca antes de `analyze_joint_problem_ve()` y termina después de la misma
  proyección final a `counts`, también sin incluir `compare_case()`.
- para eliminar ruido de carga/JSON/validación se corrió además un benchmark
  repetido por caso con corpus ya cargado, `1` warmup no medido y `20`
  repeticiones medidas por caso.
- la comprobación `2E2 == 2B3` se hizo fuera de la ventana temporal antes de
  tomar muestras.

Comando corrido:

```bash
python3 scripts/conditional_sampling_2e2_variable_elimination.py benchmark \
  --corpus benchmarks/conditional-sampling-2a-corpus-20260830.jsonl \
  --out benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl
```

Benchmark repetido usado para la comparación final de wall-clock:

```bash
python3 scripts/conditional_sampling_2e2_variable_elimination.py benchmark-repeated \
  --corpus benchmarks/conditional-sampling-2a-corpus-20260830.jsonl \
  --out benchmarks/conditional-sampling-2e2-variable-elimination-repeated-20260830.jsonl \
  --repeats 20 --warmup 1
```

### Wall-clock Python total por evaluación

| variante | p50 | p90 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2E2 | 8.70 ms | 12.25 ms | 13.19 ms | 15.03 ms | 16.76 ms |
| 2B3 | 6.66 ms | 12.16 ms | 16.41 ms | 21.64 ms | 22.62 ms |

Aclaración de ratios:

- `2E2 / 2B3` reportado abajo significa
  `percentile( median_2e2_i / median_2b3_i )`, caso por caso.
- **No** es igual a `percentile(2E2) / percentile(2B3)`.

Con estas medianas repetidas:

- `percentile(2E2_i / 2B3_i)`: p50 `1.209x`, p90 `2.134x`,
  p95 `2.255x`, p99 `2.597x`, max `2.661x`
- `percentile(2B3_i / 2E2_i)`: p50 `0.827x`, p90 `1.044x`,
  p95 `1.157x`, p99 `1.917x`, max `1.995x`
- cociente de percentiles absolutos:
  p50 `8.70/6.66 = 1.305x`, p90 `12.25/12.16 = 1.008x`,
  p95 `13.19/16.41 = 0.804x`, p99 `15.03/21.64 = 0.695x`

Esto resuelve la aparente contradicción:

- por caso, la mediana favorece a 2B3 en la mayoría del corpus
- pero en la cola alta los percentiles absolutos favorecen a 2E2 porque
  los casos más duros son justamente donde VE empieza a ganar

### Métricas VE observadas

| métrica 2E2 | p50 | p90 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: |
| `component_size` | 30 | 49 | 53 | 56 | 56 |
| `special_min_fill_width_max` | 5 | 6 | 6 | 6 | 6 |
| `effective_special_width_max` | 5 | 6 | 6 | 6 | 6 |
| `peak_factor_entries` | 7328 | 17920 | 26976 | 36611 | 46080 |
| `peak_nonzero_entries` | 20 | 40.5 | 60 | 82.05 | 103 |
| `total_entries_processed` | 29215 | 115734 | 150138 | 174440 | 228304 |
| `total_nonzero_entries` | 355.5 | 618.1 | 759.4 | 1084.46 | 1117 |
| `peak_live_entries` | 96 | 129.7 | 163 | 170 | 170 |
| `bigint_additions` | 13 | 40 | 56 | 83.15 | 107 |
| `bigint_multiplications` | 77 | 183 | 239.6 | 397.92 | 405 |

Hallazgo estructural principal:

- el width especial efectivo real coincide con el width min-fill estructural
  del prestudy: nunca superó `6`
- la sparsity fue fuerte: `peak_nonzero_entries` quedó muy por debajo de la
  capacidad densa `peak_factor_entries`
- no apareció explosión de factores intermedios en el corpus `120/120`

### Casos pedidos

`2a-005` (caso más caro por DFS en 2B3):

- `2B3`: `4952` search nodes, `8932` branch ops, mediana repetida `17.61 ms`
- `2E2`: width especial `4`, `peak_factor_entries=13056`,
  `peak_nonzero_entries=40`, mediana repetida `8.88 ms`
- speedup mediano `2B3 / 2E2 = 1.984x`

Casos con componente `n=56` (`2a-033`..`2a-036`):

- todos preservan width especial `4`
- `peak_nonzero_entries=10` en los cuatro
- `peak_factor_entries` entre `8480` y `20160`
- `2E2` mediana repetida entre `9.60 ms` y `10.66 ms`
- `2B3` mediana repetida entre `6.56 ms` y `7.63 ms`

Lectura correcta de estos `n=56`:

- el tamaño del componente no fuerza un width grande
- VE sigue siendo estructuralmente manejable
- en Python puro todavía paga overhead frente al DFS compartido de 2B3

### Crossover por dificultad DFS -> VE

Buckets definidos por `search_nodes` de 2B3:

| bucket | casos | mediana nodes 2B3 | mediana wall 2B3 | mediana wall 2E2 | mediana speedup `2B3/2E2` | wins / ties / losses de 2E2 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `<250` | 52 | 123.0 | 5.39 ms | 7.44 ms | 0.748x | 0 / 0 / 52 |
| `250-499` | 24 | 373.0 | 7.00 ms | 9.65 ms | 0.819x | 7 / 0 / 17 |
| `500-999` | 24 | 611.5 | 5.71 ms | 9.65 ms | 0.743x | 4 / 0 / 20 |
| `1000-1999` | 12 | 1453.0 | 7.82 ms | 9.63 ms | 1.014x | 7 / 0 / 5 |
| `>=2000` | 8 | 3996.5 | 17.36 ms | 11.81 ms | 1.400x | 8 / 0 / 0 |

Dato principal:

- 2E2 paga overhead claro en los casos fáciles
- el crossover aparece entre `1000` y `2000` nodos DFS
- para `>=2000` nodos, 2E2 gana en `8/8` casos y mejora fuertemente la cola

### Correlaciones observadas

Usando speedup por caso `2B3_wall / 2E2_wall` sobre medianas repetidas:

- correlación con `search_nodes_2B3`: `+0.686`
- correlación con tamaño máximo de componente: `-0.349`
- correlación con width efectivo: `+0.323`

No conviene sobreinterpretarlas:

- la única señal realmente fuerte es que el speedup de VE crece con la
  dificultad DFS
- tamaño de componente por sí solo no explica el crossover
- width efectivo ayuda, pero no captura toda la estructura del caso

## Evaluación del criterio de éxito

1. **Exactitud 120/120**: cumplido.
2. **Factores estructuralmente manejables**: cumplido.
3. **Señal para continuar a 2E3**: cumplido.

### Hechos

- exactitud `120/120` contra 2B3
- width efectivo especial `<= 6` en todo el corpus
- sparsity fuerte observada: `peak_nonzero_entries` muy por debajo de
  `peak_factor_entries`
- wall-clock Python medido con benchmark repetido por caso
- crossover empírico: VE pierde en casos fáciles y gana sistemáticamente en
  los casos con `>= 2000` `search_nodes` de 2B3

### Interpretación

La evidencia no sugiere descartar VE. Tampoco justifica vender wall-clock
Python como estimación de Cairo. Lo que sí queda validado para la hoja de ruta:

- la estructura real de factores es regular
- el width observado permanece bajo
- VE es especialmente atractivo para hard cases del corpus actual
- la representación modular ya deja abierta la persistencia/reuse
  necesaria para **2E3 history-aware VE**

## Conclusión

2E2 queda validado como checkpoint exacto y arquitectónicamente correcto:

- reemplaza el DFS por componente por VE snapshot
- preserva exactamente `2B3`
- muestra que el cuello de botella no es explosión estructural de factors
- deja cerrada la siguiente ruta experimental:
  `2E2 snapshot VE -> 2E3 history-aware VE -> historias 30×16/99 -> Cairo`

## EXPERIMENTO 2E3 — History-Aware Variable Elimination
### (2026-08-31)

## Objetivo

Medir cuánto trabajo de `2E2` puede reutilizarse exactamente entre
transcripts consecutivos `T_i -> T_{i+1}` sin cambiar la distribución exacta
de `N_mine, N_0..N_8`.

Preguntas concretas:

- cuánta reutilización real aparece entre clicks de una misma historia
- cuánto cuesta esa reutilización en wall-clock honesto
- si `2E3` puede desplazar a `2E2` como baseline operativo

## Arquitectura congelada

Código nuevo:

- `scripts/conditional_sampling_2e3_history_aware_ve.py`
- `scripts/test_conditional_sampling_2e3_history_aware_ve.py`

Estado persistente:

- `GlobalMessageCache` content-addressed
- `TranscriptState` por transcript
- `OrdinaryComponentState` por componente ordinario

Reuse implementado:

- whole-component hit por firma idéntica
- sub-DAG reuse por mensajes ordinarios cacheados
- overlay special query-aware que recomputa solo el cono dependiente de la
  query y reusa el resto

Benchmark histórico oficial:

- corpus:
  `benchmarks/conditional-sampling-histories-30x16-20260831.jsonl`
- replay principal:
  `benchmarks/conditional-sampling-2e3-histories-30x16-20260831.jsonl`
- replay longitudinal:
  `benchmarks/conditional-sampling-2e3-histories-30x16-longitudinal-20260831.jsonl`

## Corpus y protocolo

Corpus histórico largo fijado:

- tablero objetivo:
  `30×16/99`
- histories:
  `16`
- puntos históricos:
  `259`
- composición:
  `P01..P12` public-only + `C01..C04` controlled

Regla oficial de timeout:

- `150 s` por algoritmo/punto
- un timeout se registra como observación censurada `>150 s`
- nunca se interpreta como un runtime exacto de `150 s`

## Validación de exactitud

Replay principal:

- `2E2` y `2E3` coinciden exactamente entre sí en `259/259` puntos
- validación independiente contra `2B3` disponible en `257/259` puntos
- motivo de los `2` faltantes:
  `2B3` timeouta en `C03` click `47` y `C04` click `44`
- en los `257` puntos con referencia exacta disponible:
  - `2E2`: `257/257` exacto
  - `2E3`: `257/257` exacto
  - igualdad también en `sum_counts`, `compatible_total_before_click` y
    `partition_ok`

Replay longitudinal:

- variantes corridas:
  `2A`, `2B`, `2B2`, `2B3`, `2D1`, `2E2`, `2E3`
- toda variante que terminó con `status="ok"` coincidió con la referencia
  exacta disponible en ese punto
- los timeouts son observaciones censuradas, no validaciones de exactitud

## Auditoría del accounting

El total oficial de `2E3` sí incluye todo el trabajo real medido:

- `startup_ms`
- `transition_ms`
- `maintenance_ms`
- `evaluation_ms`

Lectura correcta del desglose actual:

- `startup_ms` y `transition_ms` absorben todo `build_transcript_state(...)`
- `evaluation_ms` mide `evaluate_with_state(...)`
- `maintenance_ms` hoy existe como campo pero vale siempre `0.0`
- no hay trabajo oculto fuera de `total_ms`
- sí hay una limitación de granularidad:
  el mantenimiento real de cache/dependencias hoy queda absorbido dentro de
  `startup_ms` o `transition_ms`

## Resultado principal 2E2 vs 2E3

Distribución puntual:

| variante | p50 | p90 | p95 | p99 | max |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2E2 | 15.201 ms | 53.172 ms | 63.654 ms | 88.465 ms | 121.180 ms |
| 2E3 | 21.071 ms | 77.255 ms | 106.833 ms | 140.779 ms | 189.087 ms |

Suma total en el corpus principal:

- `2E2 = 5930.675 ms`
- `2E3 = 8730.097 ms`
- ratio `2E3 / 2E2 = 1.472x`

Wins / ties / losses punto a punto:

- `2E3`: `9 / 0 / 250` frente a `2E2`

Por fase:

| fase | puntos | total 2E2 | total 2E3 | mediana 2E2 | mediana 2E3 | wins 2E3 | losses 2E3 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| early | 236 | 4444.241 ms | 6255.205 ms | 13.739 ms | 19.264 ms | 9 | 227 |
| mid | 23 | 1486.432 ms | 2474.892 ms | 61.425 ms | 107.664 ms | 0 | 23 |

Coste total por history (`2E3 / 2E2`):

| history | 2E2 total | 2E3 total | ratio |
| --- | ---: | ---: | ---: |
| C01 | 880.434 ms | 1420.899 ms | 1.614x |
| C02 | 1110.542 ms | 1711.705 ms | 1.541x |
| C03 | 1948.787 ms | 2827.239 ms | 1.451x |
| C04 | 1387.118 ms | 2020.516 ms | 1.457x |
| P01 | 21.279 ms | 22.690 ms | 1.066x |
| P02 | 56.454 ms | 68.335 ms | 1.210x |
| P03 | 75.324 ms | 95.936 ms | 1.274x |
| P04 | 19.966 ms | 22.296 ms | 1.117x |
| P05 | 18.653 ms | 20.831 ms | 1.117x |
| P06 | 33.360 ms | 39.993 ms | 1.199x |
| P07 | 79.731 ms | 97.015 ms | 1.217x |
| P08 | 43.933 ms | 50.429 ms | 1.148x |
| P09 | 56.847 ms | 69.196 ms | 1.217x |
| P10 | 92.917 ms | 142.818 ms | 1.537x |
| P11 | 20.957 ms | 22.710 ms | 1.084x |
| P12 | 84.372 ms | 97.487 ms | 1.155x |

Desglose `2E3`:

- `transition_ms` suma `5745.425 ms` (`51.2%` del total en media)
- `evaluation_ms` suma `2977.359 ms` (`48.4%` del total en media)
- `maintenance_ms` queda en `0.0 ms` por instrumentación actual

Reuse medido:

- filas con `whole_component_hits > 0`: `109/259`
- filas con `subdag_hits > 0`: `213/259`
- `messages_reused`: `4419`
- `messages_recomputed`: `3391`
- `messages_invalidated`: `3388`
- `factor_entries_reused`: `36712`
- `factor_entries_recomputed`: `66835`
- `factor_entries_invalidated`: `36160`

Fracción de reuse reconstruida correctamente desde el raw:

- media `0.318`
- mediana `0.300`
- `p90 0.727`
- `p95 0.763`
- `max 0.874`

Observación clave:

- no aparece una banda de reuse donde `2E3` pase a ganar de forma
  sistemática a `2E2`
- el overhead de transición/bookkeeping domina el beneficio del reuse

Cache peak observado:

- `cache_peak_entries`: max `12761`
- `cache_peak_messages`: max `1146`

Hard points representativos:

| punto | fase | 2B3 | 2E2 | 2E3 |
| --- | --- | ---: | ---: | ---: |
| `C02` click `33` | early | 24907.877 ms | 24.549 ms | 43.045 ms |
| `C03` click `39` | mid | 25966.616 ms | 77.513 ms | 147.691 ms |
| `C03` click `45` | mid | 21562.016 ms | 121.180 ms | 189.087 ms |
| `C04` click `43` | mid | 79580.295 ms | 48.937 ms | 76.308 ms |

## Tabla longitudinal 2A -> 2E3

| variante | ok | timeout | p50 exacto | p90 exacto | p95 exacto | p99 exacto | max exacto | suma exacta completados | cota inferior total con censura |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2A | 250 | 9 | 104.716 ms | 32698.981 ms | 76413.912 ms | 135918.419 ms | 142338.093 ms | 2532522.858 ms | >= 3882522.858 ms |
| 2B | 254 | 5 | 83.823 ms | 23767.144 ms | 40936.635 ms | 119388.636 ms | 142718.790 ms | 1891603.113 ms | >= 2641603.113 ms |
| 2B2 | 251 | 8 | 85.070 ms | 30779.030 ms | 67036.563 ms | 115870.111 ms | 139569.738 ms | 2228369.546 ms | >= 3428369.546 ms |
| 2B3 | 257 | 2 | 29.254 ms | 9185.927 ms | 15190.460 ms | 26661.672 ms | 64877.941 ms | 609381.699 ms | >= 909381.699 ms |
| 2D1 | 258 | 1 | 21.012 ms | 4873.474 ms | 8665.804 ms | 14497.686 ms | 55286.400 ms | 374178.611 ms | >= 524178.611 ms |
| 2E2 | 259 | 0 | 15.489 ms | 40.686 ms | 54.247 ms | 79.127 ms | 98.668 ms | 5230.885 ms | 5230.885 ms |
| 2E3 | 259 | 0 | 20.894 ms | 59.150 ms | 83.164 ms | 96.219 ms | 129.024 ms | 7393.482 ms | 7393.482 ms |

Lectura principal del longitudinal:

- el salto de régimen aparece al pasar a Variable Elimination
- `2E2` es el primer punto de la serie que controla de verdad la cola y
  elimina los timeouts en este corpus
- `2E3` conserva esa mejora de cola respecto de `2A -> 2D1`, pero no
  mejora el frente absoluto de `2E2`

## Correcciones de instrumentación detectadas al cierre

Se corrigieron dos problemas de instrumentación después de auditar el raw ya
corrido:

1. `transition_class`:
   separar `identical` de `component_identical`
2. `reuse_fraction`:
   normalización correcta a `[0,1]`

Importante:

- estas correcciones no modifican `counts`
- no modifican `wall_clock_ms`
- no invalidan los raws ya corridos
- sólo corrigen la interpretación de etiquetas y una métrica derivada

## Conclusión

Hechos medidos:

- `2E3` demuestra reuse incremental exacto real
- `2E3` no timeouta en el corpus histórico largo
- `2E3` sigue perdiendo contra `2E2` en coste total honesto

Decisión de cierre:

- `2E2` queda como candidato operativo para la siguiente etapa
- `2E3` queda congelado como experimento negativo útil
- el checkpoint de continuidad entre sesiones pasa a `docs/PENDING-REVIEW.md`

## Análisis estructural de flood-fill sobre el corpus histórico 30×16/99
### (2026-08-31)

## Objetivo

Caracterizar el flood-fill usando exclusivamente el corpus histórico público
ya congelado, antes de decidir si vale la pena implementar y comparar tres
políticas futuras de refinamiento del clue exacto:

- `CELL`: cada celda forced-safe recibe clue exacto `0..8` inmediatamente
- `WAVE`: dentro de cada oleada sólo se distingue `0` vs `>0`; los positivos
  se refinan al cerrar la oleada
- `FULL-REGION`: durante toda la expansión sólo se distingue `0` vs `>0`; la
  frontera positiva completa se refina al cerrar toda la región

Estas políticas representan distintos horizontes de diferimiento del clue
exacto. El objetivo aquí no fue implementarlas ni estimar su costo VE, sino
ver si el flood-fill introduce un multiplicador estructural relevante y si las
políticas parecen realmente distintas.

## Fuente de datos y restricciones

Fuente única:

- `benchmarks/conditional-sampling-histories-30x16-20260831.jsonl`

Restricciones respetadas:

- no se generaron histories nuevas
- no se modificaron `2E2` ni `2E3`
- no se implementaron constraints binarias `>0`
- no se abrió Cairo

Artefactos permanentes:

- `scripts/analyze_flood_fill_structure.py`
- `benchmarks/flood-fill-structure-30x16-20260831.jsonl`
- `benchmarks/flood-fill-structure-30x16-20260831-summary.json`

## Metodología

Se reconstruyó cada click únicamente desde transcripts públicos ya guardados.

Reconstrucción usada:

- cada row del corpus es el transcript previo al click
- cuando existe un row siguiente en la misma history, ese transcript siguiente
  se toma como transcript posterior público del click actual
- para losses sobre mina:
  - `new_revealed = 0`
  - no hay flood-fill
- para terminales positivos `1..8` sin transcript siguiente:
  - se reconstruye sintéticamente el transcript posterior agregando sólo esa
    clue
- para terminales con outcome `0` sin transcript siguiente:
  - la región completa no se infiere; se marca como gap del dataset público

Métricas reconstruidas por click:

- `new_revealed`
- outcome clickeado
- presencia de flood-fill
- `zero_region_size`
- `boundary_size`
- `wave_count`
- tamaño de cada oleada
- ceros y positivos por oleada

Caracterización estructural adicional, sin modificar el contador:

- `frontier_variables`
- `constraint_count`
- `component_sizes`
- `min_fill_width_max`
- tamaño de la unión de variables involucradas en las clues de frontera

Límite metodológico explícito:

- toda métrica que requiera representar realmente constraints `0/>0` queda
  como `requiere experimento posterior`

## Cobertura y limitaciones

- corpus:
  `16` histories, `259` clicks
- clicks con outcome `0`:
  `23`
- flood-fills completamente reconstruibles desde el dataset público:
  `22`
- gap real del dataset:
  `C03` click `47`, último `0` terminal sin transcript posterior

## Resultados

### Multiplicador de flood-fill

Clicks sin flood-fill (`236`):

- `new_revealed`: media `0.949`, mediana `1`, p95 `1`, max `1`

Clicks con flood-fill (`22` reconstruibles):

- `new_revealed`: media `19.545`, mediana `14.5`, p95 `38.9`, max `41`
- `zero_region_size`: media `7.727`, mediana `4`, p95 `19`, max `20`
- `boundary_size`: media `11.818`, mediana `10.5`, p95 `21.9`, max `22`
- `wave_count`: media `5.182`, mediana `5`, p95 `10.85`, max `11`

Distribuciones observadas:

- tamaños de cascada:
  `4, 10, 11, 12, 17, 18, 19, 25, 29, 32, 34, 37, 39, 41`
- tamaños de oleada:
  rango `1..10`

### CELL vs WAVE vs FULL-REGION

Conteos estructurales reconstruidos para flood-fills:

- `CELL`:
  - una determinación exacta `0..8` por cada celda forced-safe
  - backlog máximo de positivos pendientes:
    `0`
- `WAVE`:
  - backlog máximo de positivos pendientes:
    `10`
- `FULL-REGION`:
  - backlog máximo de positivos pendientes:
    `22`
- diferencia máxima observada `FULL-REGION - WAVE`:
  `16`

Lectura correcta:

- estos conteos no son costos computacionales equivalentes
- `CELL`, `WAVE` y `FULL-REGION` mantienen estados condicionados distintos
- la diferencia real para VE sigue abierta hasta implementar semántica binaria
  `0/>0`

### Relación con estructura VE exacta final

En flood-fills reconstruibles:

- `frontier_variables` post-cascada:
  media `63.045`, mediana `52.5`, p95 `173.4`, max `189`
- `constraint_count` post-cascada:
  media `39.591`, mediana `30`, p95 `103.7`, max `122`
- `largest_component` post-cascada:
  media `33.455`, mediana `23.5`, p95 `90.95`, max `116`
- `min_fill_width_max` post-cascada:
  mediana `6`, max `7`
- `boundary_union_variable_count`:
  media `15.909`, mediana `16.5`, p95 `25.95`, max `32`

Esto caracteriza la estructura exacta final con clues `0..8`, no la estructura
intermedia bajo una semántica binaria `0/>0`.

## Lectura técnica

1. El flood-fill sí introduce un multiplicador estructural fuerte sobre el
   número de celdas reveladas por click.
2. `WAVE` y `FULL-REGION` sí parecen estructuralmente distintas por el backlog
   de positivos pendientes, así que no es absurdo compararlas más adelante.
3. No hay evidencia suficiente para descartar `CELL`, `WAVE` o `FULL-REGION`
   antes de programarlas.
4. Lo que sigue abierto exige implementar de verdad la semántica binaria
   `0/>0` y medir VE:
   - cómo cambia frontier/componentes/min-fill width durante la expansión
   - si `>0` ayuda o empeora el sharing
   - si `WAVE` o `FULL-REGION` reducen o inflan el costo VE real

## Artefactos 2D
