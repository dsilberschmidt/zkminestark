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
