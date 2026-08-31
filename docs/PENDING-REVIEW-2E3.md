# PENDING REVIEW - 2E3

Fecha de checkpoint: 2026-08-31

## Objetivo / hipotesis

- Experimento activo: `2E3 - history-aware / incremental variable elimination`.
- Pregunta: cuanto trabajo de `2E2` puede reutilizarse exactamente entre `T_i -> T_{i+1}` sin cambiar la distribucion exacta.
- Hipotesis actual: un cache content-addressed de mensajes ordinarios + overlay special query-aware puede producir reuse interno real, aunque el accounting honesto puede seguir perdiendo contra `2E2`.

## Arquitectura 2E3 actualmente elegida

- Archivo principal: `scripts/conditional_sampling_2e3_history_aware_ve.py`.
- `2E2` queda congelado; `2E3` vive en codigo nuevo.
- Estado persistente:
  - `GlobalMessageCache`: cache global de factores/mensajes por `FactorKey`.
  - `TranscriptState`: estado por transcript con features estructurales, componentes ordinarios persistidos y overlap con el transcript previo.
  - `OrdinaryComponentState`: plan VE, factores base, trazas por paso, factor final ordinario y vector `F_C[k]`.
- Reuse implementado:
  - whole-component hit por firma identica;
  - sub-DAG reuse por mensajes ordinarios cacheados;
  - overlay special query-aware que recomputa solo pasos cuyo cono depende de `x` o sus vecinos y reusa el resto.
- Fallback exacto:
  - existe mecanismo `force_fallback_min_fill_width` para tests;
  - en el camino normal todavia no hay una heuristica fuerte de fallback, salvo el hook de test.

## Decisiones tecnicas tomadas

- Se eligio cache content-addressed por paso de eliminacion en vez de mutar `2E2`, para preservar el freeze.
- El conteo special no persiste tablas query-specific entre clicks; solo persiste mensajes ordinarios query-independent.
- `phase` reutiliza la definicion congelada de `2D`: progreso de safe cells reveladas en tercios.
- El corpus historico `30x16/99` ahora se persiste incrementalmente por historia en JSONL y soporta resume por `history_id`.
- El replay historico `30x16/99` tambien soporta resume por `click_number` dentro de la misma history, reconstruyendo solo el estado incremental necesario.
- La generacion de histories `30x16/99` usa apertura determinista `first-click-safe` en el generador:
  - el primer click se fija por `start_mode`;
  - el tablero se samplea deterministamente excluyendo esa celda;
  - la policy sigue siendo public-only porque no usa hidden state para elegir clicks.

## Intentos descartados / ajustados

- Escritura atomica unica al final del corpus: descartada porque el usuario pidio persistencia incremental y resume.
- Generacion sin first-click-safe: produjo demasiadas historias triviales de 1 click por perdida inmediata; se ajusto el generador para excluir la celda inicial.
- Exploracion temporal de `exact_safest_public` sobre todas las celdas cerradas:
  - descartada como camino principal;
  - motivo: costo mucho mayor y no mejoro de forma visible la supervivencia;
  - ademas rompia la reproducibilidad del corpus publico ya fijado, asi que se revirtio.
- Dos procesos concurrentes de generacion escribiendo el mismo JSONL:
  - detectados por `ps`;
  - invalido para checkpointing;
  - se paso a append por historia + skip de IDs completos.
- Replay sin timeout oficial por punto:
  - descartado despues de observar una explosion real de `2B3` en `C03`;
  - ahora hay timeout oficial `150 s` por algoritmo/punto para mantener viable el benchmark sin favorecer a VE.

## Bugs encontrados y resolucion

- `KeyError` en accounting cuando un transcript de test caia en camino inconsistente:
  - `evaluate_with_state` ahora devuelve bloque `history_aware` completo tambien en inconsistente.
- Clasificacion `strong_change` en transcript identico:
  - `_transition_class` ahora detecta igualdad exacta de transcript y devuelve `identical`.
- JSONL parcial/corrupto durante inspeccion de un archivo en generacion:
  - se agrego `load_jsonl_rows()` con tolerancia a ultima linea truncada;
  - pendiente endurecerlo mejor si hace falta.
- Riesgo de reproducibilidad al cambiar una policy despues de generar el corpus:
  - detectado al comparar el corpus limpio `P01..P12` con una exploracion posterior;
  - se revirtio la policy `exact_safest_public` a su semantica original para preservar `policy + seed -> historia`.
- Hard point legitimo de `2B3` en `C03` sin timeout oficial:
  - el proceso siguio mas de `12` minutos adicionales al `~99%` CPU sin producir la fila siguiente;
  - se corto manualmente;
  - el raw quedo consistente en `143` filas con ultima persistida `C03` click `46`.

## Tests ejecutados

- `python3 -m unittest scripts/test_conditional_sampling_2e3_history_aware_ve.py`
  - revalidado al cierre de esta revision: `16 tests`, `OK`.
- `python3 -m unittest discover -s scripts -p 'test_conditional_sampling*.py'`
  - revalidado al cierre de esta revision: `52 tests`, `OK`.

## Metricas parciales relevantes

### Smoke H1/H2/H3

- Raw generado: `benchmarks/conditional-sampling-2e3-smoke-20260831.jsonl`
- Exactitud:
  - `H1`: exacta
  - `H2`: exacta
  - `H3`: exacta
  - total smoke: `84/84` puntos exactos contra `2B3` y `2E2`
- Reuse medio observado:
  - `H1`: `0.6640`
  - `H2`: `0.6426`
  - `H3`: `0.0439`
- Resultado honest accounting:
  - `2E3` es mas lento que `2E2` en las tres histories smoke de esta primera version
  - `H1`: `2E2/2E3 = 0.5298`
  - `H2`: `2E2/2E3 = 0.4770`
  - `H3`: `2E2/2E3 = 0.6478`
- Conclusión parcial: hay reuse interno real, pero no alcanza para ganar en wall-clock honesto sobre smoke.

### Replay 30x16/99 - hallazgo parcial temprano

- Durante el replay del corpus combinado aparecio un hard point relevante en `C02` click `33`:
  - `phase`: `early`
  - `frontier_variables`: `80`
  - `constraint_count`: `49`
  - `special_component_size`: `80`
  - `structural_width`: `6`
  - `2B3 wall`: `24907.88 ms`
  - `2E2 wall`: `24.55 ms`
  - `2E3 total official`: `43.04 ms`
  - `2E3 evaluation only`: `8.96 ms`
  - `2E3 transition`: `34.08 ms`
  - `reuse_fraction`: `0.9935`
  - `messages_reused`: `53`
  - `messages_recomputed`: `27`
- Interpretacion parcial:
  - el corpus nuevo ya contiene cola dificil real;
  - en esos puntos, `2E2` y `2E3` pueden estar muchisimo por delante de `2B3`;
  - aun no alcanza para concluir si `2E3` gana a `2E2` en total history cost.
- Segundo hard point ya observado:
  - `C03` click `39`
  - `phase`: `mid`
  - `2B3 wall`: `25966.62 ms`
  - el proceso siguio vivo al `98%` de CPU despues de persistir ese punto, asi que no es cuelgue sino cola dura real.
- Hard point que gatillo el timeout oficial:
  - `C03` siguiente punto despues de click `46` persistido
  - observacion real: `2B3 >12 min`
  - interpretacion: explosion legitima de DFS, no fallo de infraestructura.
- Segundo timeout oficial finalmente observado:
  - `C04` click `44`
  - `phase`: `mid`
  - `2B3.status = "timeout"`

### Timeout oficial introducido despues de C03

- Fecha de decision: `2026-08-31`.
- Regla:
  - timeout por algoritmo/punto = `150 s`
  - al excederlo: registrar `status="timeout"` y `timeout_s=150`
  - tratar el runtime como observacion censurada `>150 s`, nunca como `150 s` exactos
  - conservar metricas parciales solo si el algoritmo ya las devuelve limpiamente
  - seguir con los otros algoritmos y con el siguiente click
- Aplica a:
  - `2B3`, `2E2`, `2E3`
  - y tambien `2A`, `2B`, `2B2`, `2D1` en el replay longitudinal.
- Primera confirmacion en raw:
  - `C03` click `47`
  - `2B3.status = "timeout"`
  - `timeout_s = 150`
  - el replay continuo y avanzo a `C04`.
- Estado final del replay obligatorio:
  - `259` filas completadas
  - `2B3` exacto en `257/259` puntos
  - `2B3` timeout en:
    - `C03` click `47`
    - `C04` click `44`
  - `2E2`: `0` timeouts observados
  - `2E3`: `0` timeouts observados
  - `2E3` gano a `2E2` en `9` puntos y perdio en `250`
  - reuse medio `2E3`: `0.6781`

## Archivos creados / modificados

- Creado:
  - `scripts/conditional_sampling_2e3_history_aware_ve.py`
  - `scripts/test_conditional_sampling_2e3_history_aware_ve.py`
  - `docs/PENDING-REVIEW-2E3.md`
- Generados localmente:
  - `benchmarks/conditional-sampling-2e3-smoke-20260831.jsonl`
  - `benchmarks/conditional-sampling-histories-30x16-20260831.jsonl`
  - `benchmarks/conditional-sampling-2e3-histories-30x16-20260831.jsonl`
  - `benchmarks/conditional-sampling-2e3-histories-30x16-longitudinal-20260831.jsonl`

## Comandos de reproduccion

- Tests 2E3:
  - `python3 -m unittest scripts/test_conditional_sampling_2e3_history_aware_ve.py`
- Suite conditional sampling:
  - `python3 -m unittest discover -s scripts -p 'test_conditional_sampling*.py'`
- Smoke 2E3:
  - `python3 scripts/conditional_sampling_2e3_history_aware_ve.py smoke --histories benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl --out benchmarks/conditional-sampling-2e3-smoke-20260831.jsonl --timeout-s 150`
- Generar corpus 30x16/99:
  - `python3 scripts/conditional_sampling_2e3_history_aware_ve.py generate-histories-30x16 --out benchmarks/conditional-sampling-histories-30x16-20260831.jsonl --max-clicks 48`
- Replay obligatorio 30x16:
  - `python3 scripts/conditional_sampling_2e3_history_aware_ve.py benchmark-30x16 --histories benchmarks/conditional-sampling-histories-30x16-20260831.jsonl --out benchmarks/conditional-sampling-2e3-histories-30x16-20260831.jsonl --timeout-s 150`

## Estado smoke H1/H2/H3

- Completado.
- Exactitud validada.
- Raw presente.
- Pendiente: incorporar resumen y lectura critica final en docs oficiales.

## Estado generacion histories 30x16/99

- Cambio de estrategia ya aplicado:
  - append por historia;
  - flush por historia;
  - resume por `history_id` ya terminal;
  - `max_clicks=48`.
- Se verifico que no quedan procesos viejos `generate-histories-30x16`.
- El corpus parcial heredado fue apartado como:
  - `benchmarks/conditional-sampling-histories-30x16-20260831.partial-pre-resume.jsonl`
- Generacion limpia completada sobre:
  - `benchmarks/conditional-sampling-histories-30x16-20260831.jsonl`
- Resultado actual:
  - `P01..P12` completadas;
  - todas `PUBLIC-ONLY`;
  - todas terminan en `loss`;
  - longitudes: `2, 6, 9, 2, 3, 5, 10, 7, 6, 9, 2, 6`;
  - toda la cobertura quedo en `early`.
- Evaluacion metodologica:
  - reproducible: si;
  - heterogeneidad minima: si;
  - utilidad para comparar reuse en mid/late: insuficiente.
- Bloque `CONTROLLED` ya anexado:
  - `C01..C04`;
  - `48` clicks cada una;
  - `C03/C04` ya alcanzan `mid`;
  - ninguna llega a `late` con cap `48`.
- Corpus combinado actual:
  - `16` histories
  - `259` puntos historicos
- Proximo paso inmediato:
  - reanudar el replay obligatorio `2B3/2E2/2E3` sobre el corpus combinado con timeout oficial `150 s`.

## Histories completadas / pendientes

- Estado previo no confiable archivado:
  - habia `P01..P11` parcial, con muchas historias muy cortas por perdida temprana;
  - no usar como corpus oficial;
  - quedo preservado solo como referencia de debugging en `.partial-pre-resume`.
- Estado actual confiable:
  - `P01` `local_frontier_public` seed `2026083101` -> `loss` en `2` clicks
  - `P02` `local_frontier_public` seed `2026083102` -> `loss` en `6` clicks
  - `P03` `local_frontier_public` seed `2026083103` -> `loss` en `9` clicks
  - `P04` `local_frontier_public` seed `2026083104` -> `loss` en `2` clicks
  - `P05` `jump_exploration_public` seed `2026083101` -> `loss` en `3` clicks
  - `P06` `jump_exploration_public` seed `2026083102` -> `loss` en `5` clicks
  - `P07` `jump_exploration_public` seed `2026083103` -> `loss` en `10` clicks
  - `P08` `jump_exploration_public` seed `2026083104` -> `loss` en `7` clicks
  - `P09` `exact_safest_public` seed `2026083101` -> `loss` en `6` clicks
  - `P10` `exact_safest_public` seed `2026083102` -> `loss` en `9` clicks
  - `P11` `exact_safest_public` seed `2026083103` -> `loss` en `2` clicks
  - `P12` `exact_safest_public` seed `2026083104` -> `loss` en `6` clicks
- `C01` `oracle_safe_local_center` seed `2026083101` -> `incomplete` en `48` clicks
- `C02` `oracle_safe_local_center` seed `2026083102` -> `incomplete` en `48` clicks
- `C03` `oracle_safe_jump_edge` seed `2026083101` -> `incomplete` en `48` clicks (`11` mid)
- `C04` `oracle_safe_jump_edge` seed `2026083102` -> `incomplete` en `48` clicks (`12` mid)
- Pendiente:
  - despues del replay obligatorio, decidir si hacen falta mas controladas para llegar a `late`.

## Estado final del replay 2B3 / 2E2 / 2E3 y variantes anteriores

- Replay smoke `H1/H2/H3`:
  - `2B3`, `2E2`, `2E3` corridos y exactos;
  - secundarios (`2A`, `2B`, `2B2`, `2D1`) integrados en el smoke harness.
- Replay principal `30x16/99`:
  - raw oficial:
    - `benchmarks/conditional-sampling-2e3-histories-30x16-20260831.jsonl`
  - corpus completo:
    - `16` histories = `P01..P12 + C01..C04`
    - `259` puntos historicos
  - completado al `100%` el `2026-08-31`.
- Replay longitudinal `2A/2B/2B2/2B3/2D1/2E2/2E3`:
  - raw oficial:
    - `benchmarks/conditional-sampling-2e3-histories-30x16-longitudinal-20260831.jsonl`
  - completado al `100%` el `2026-08-31`.

## Auditoria del raw completo

### Exactitud contra referencia exacta disponible

- En el replay principal, `2B3` termino exacto en `257/259` puntos y timeout en `2/259`.
- En los `257` puntos con referencia exacta disponible (`2B3.status = "ok"`):
  - `2E2`: `257/257` exacto en `counts`, `sum_counts`, `compatible_total_before_click` y `partition_ok`.
  - `2E3`: `257/257` exacto en `counts`, `sum_counts`, `compatible_total_before_click` y `partition_ok`.
- En los `259/259` puntos del replay principal:
  - `2E2` y `2E3` coinciden exactamente entre si en `counts`, `sum_counts`, `compatible_total_before_click` y `partition_ok`.
- En el replay longitudinal:
  - para cada variante y punto con `status="ok"`, el resultado coincidió con la referencia exacta disponible;
  - los `timeouts` son observaciones censuradas `>150 s` y no validaciones de exactitud;
  - `2E2` y `2E3` coinciden entre si en `259/259` puntos del replay longitudinal, porque ninguno timeouta;
  - la validacion independiente contra `2B3` queda disponible en `257/259` puntos, porque `2B3` timeouta en `2`.

### Counts / partition / compatible total

- No aparecieron mismatches de `counts`.
- No aparecieron mismatches de `sum_counts`.
- No aparecieron mismatches de `compatible_total_before_click`.
- No aparecieron mismatches de `partition_ok`.
- No aparecieron `timeouts` de `2E2` ni de `2E3`.

### Accounting oficial de 2E3

- El `official total` reportado por `2E3` es exactamente:
  - `startup_ms + transition_ms + maintenance_ms + evaluation_ms`.
- En la implementacion actual:
  - `startup_ms` y `transition_ms` miden todo el trabajo de `build_transcript_state(...)`;
  - `evaluation_ms` mide `evaluate_with_state(...)`;
  - `maintenance_ms` existe en el schema pero hoy vale siempre `0.0`.
- Con esa implementacion no aparece trabajo oculto fuera del total oficial:
  - construccion de constraints/componentes;
  - lookup/build de factores base;
  - lookup/build de mensajes ordinarios;
  - mantenimiento de cache/dependencias y `active_keys`;
  - overlay special query-aware;
  - convolve/final counts.
- Matiz importante:
  - aunque no hay trabajo oculto fuera de `total_ms`, el desglose fino no separa realmente mantenimiento de cache/dependencias;
  - ese costo hoy queda absorbido dentro de `startup_ms` o `transition_ms`, no en `maintenance_ms`.

## Anomalias detectadas en la auditoria

### `transition_class="identical"` con cambios reales

- Se verifico una inconsistencia semantica real en el raw corrido:
  - `104` filas muestran `history_aware.transition_class = "identical"` mientras coexisten `constraints_added`, `vars_added`, invalidaciones o recomputos.
- Causa:
  - la etiqueta `identical` no significaba siempre "transcript identico";
  - en muchos casos significaba que el componente especial relevante para la query conservaba la misma firma, aunque el transcript global hubiera cambiado en otros componentes o en el frontier general.
- Correccion aplicada en codigo:
  - el fast path de transcript realmente identico sigue devolviendo `identical`;
  - el caso "mismo componente especial, transcript cambiado" ahora devuelve `component_identical`.
- Revalidacion:
  - la correccion no cambia exactitud;
  - las suites cerraron `16 tests OK` y `52 tests OK`.
- Interpretacion para el raw ya corrido del `2026-08-31`:
  - toda fila con `transition_class = "identical"` y transcript distinto de la fila previa debe leerse como `component_identical`.

### `reuse_fraction > 1.0`

- Se detectaron `42` filas con `reuse_fraction > 1.0` en el raw corrido.
- Causa:
  - la formula anterior mezclaba mensajes reutilizados en el numerador sin incluir todo el denominador correspondiente.
- Correccion aplicada en codigo:
  - `reuse_fraction` queda normalizada a `messages_reused / (messages_reused + messages_recomputed)`.
- Reinterpretacion para este raw:
  - la columna guardada `reuse_fraction` del archivo `20260831` no debe usarse literalmente como fraccion;
  - para el analisis agregado se reconstruyo la fraccion corregida desde `messages_reused` y `messages_recomputed`.
- La correccion no cambia exactitud ni wall-clock.

## Resultado principal 2E2 vs 2E3

### Measured result

- Distribucion de costo puntual:
  - `2E2`: mediana `15.201 ms`, `p90 53.172 ms`, `p95 63.654 ms`, `p99 88.465 ms`, `max 121.180 ms`.
  - `2E3`: mediana `21.071 ms`, `p90 77.255 ms`, `p95 106.833 ms`, `p99 140.779 ms`, `max 189.087 ms`.
- Suma total en el corpus principal:
  - `2E2`: `5930.675 ms`
  - `2E3`: `8730.097 ms`
  - ratio total `2E3 / 2E2 = 1.472`.
- Wins / ties / losses punto a punto:
  - `2E3` gana `9`
  - empata `0`
  - pierde `250`
- Por fase:
  - `early`: `236` puntos; `2E2` suma `4444.241 ms`, `2E3` suma `6255.205 ms`; wins `9`, losses `227`.
  - `mid`: `23` puntos; `2E2` suma `1486.432 ms`, `2E3` suma `2474.892 ms`; wins `0`, losses `23`.
  - `late`: no hay puntos.
- Costo total por history (`2E3 / 2E2`):
  - `C01 1.614`
  - `C02 1.541`
  - `C03 1.451`
  - `C04 1.457`
  - `P01 1.066`
  - `P02 1.210`
  - `P03 1.274`
  - `P04 1.117`
  - `P05 1.117`
  - `P06 1.199`
  - `P07 1.217`
  - `P08 1.148`
  - `P09 1.217`
  - `P10 1.537`
  - `P11 1.084`
  - `P12 1.155`
- Descomposicion `2E3`:
  - `transition_ms`: suma `5745.425 ms`, media `22.183 ms`, mediana `12.762 ms`.
  - `evaluation_ms`: suma `2977.359 ms`, media `11.496 ms`, mediana `8.733 ms`.
  - `maintenance_ms`: suma `0.0 ms` por instrumentacion actual.
  - share medio del total:
    - `transition`: `51.2%`
    - `evaluation`: `48.4%`
- Reuse reconstruido correctamente:
  - media `0.318`, mediana `0.300`, `p90 0.727`, `p95 0.763`, `max 0.874`.
  - rows con `whole_component_hits > 0`: `109/259`
  - rows con `subdag_hits > 0`: `213/259`
  - rows con algun componente special: `211/259`
  - rows sin componente special: `48/259`
  - rows con `plan_partial > 0`: `161/259`
  - rows con `plan_rebuilt > 0`: `82/259`
- Mensajes / factores:
  - `messages_reused`: suma `4419`, media `17.062`
  - `messages_recomputed`: suma `3391`, media `13.093`
  - `messages_invalidated`: suma `3388`, media `13.081`
  - `factor_entries_reused`: suma `36712`, media `141.745`
  - `factor_entries_recomputed`: suma `66835`, media `258.050`
  - `factor_entries_invalidated`: suma `36160`, media `139.614`
- Cache peak:
  - pico global observado por fila:
    - `cache_peak_entries`: max `12761`
    - `cache_peak_messages`: max `1146`
  - histories mas grandes:
    - `C01`: `12761 / 1146`
    - `C02`: `10912 / 1087`
    - `C04`: `9050 / 820`
    - `C03`: `8763 / 850`
  - no hay todavia instrumentacion directa en bytes, solo en entradas no nulas y numero de mensajes.
- Relacion reuse vs ganancia:
  - incluso con reuse reconstruido correctamente, no aparece una banda donde `2E3` pase a ganar de forma sistematica;
  - bucket `reuse < 0.25`: media de ganancia `-5.676 ms` (`9` wins, `110` losses);
  - bucket `0.25..0.50`: `-9.989 ms` (`0` wins);
  - bucket `0.50..0.75`: `-16.690 ms` (`0` wins);
  - bucket `0.75..0.90`: `-22.081 ms` (`0` wins).
- Hard points:
  - `C02` click `33` (`early`):
    - `2B3 = 24907.877 ms`
    - `2E2 = 24.549 ms`
    - `2E3 = 43.045 ms`
  - `C03` click `39` (`mid`):
    - `2B3 = 25966.616 ms`
    - `2E2 = 77.513 ms`
    - `2E3 = 147.691 ms`
  - `C03` click `45` (`mid`):
    - `2B3 = 21562.016 ms`
    - `2E2 = 121.180 ms`
    - `2E3 = 189.087 ms`
  - `C04` click `43` (`mid`):
    - `2B3 = 79580.295 ms`
    - `2E2 = 48.937 ms`
    - `2E3 = 76.308 ms`
  - timeouts oficiales:
    - `2B3`: `C03` click `47`, `C04` click `44`
    - `2E2`: ninguno
    - `2E3`: ninguno

### Interpretacion

- `2E3` demuestra reuse interno exacto real:
  - whole-component hits;
  - sub-DAG hits;
  - overlay special reusando mensajes ordinarios.
- Pero en este corpus y con accounting honesto, esa complejidad no compensa frente a `2E2`.
- El costo dominante que impide ganar no es la exactitud sino el overhead de transicion:
  - reconstruccion/actualizacion estructural;
  - bookkeeping de cache/dependencias;
  - invalidaciones y recomputos inducidos por la nueva frontera.
- En los puntos realmente duros, `2E3` si queda muy por delante de `2B3`, pero no cierra la brecha contra `2E2`.
- Conclusion practica:
  - `2E2` sigue siendo el baseline preferible para produccion y para comparaciones futuras;
  - `2E3` queda validado como experimento exacto y como prueba de reuse, no como reemplazo ganador.

## Longitudinal 2A -> 2B -> 2B2 -> 2B3 -> 2D1 -> 2E2 -> 2E3

### Evolucion teorica esperada

- `2A`: baseline exhaustivo mas ingenuo; cola muy pesada.
- `2B`: locality reduce trabajo respecto de `2A`, pero sigue con cola alta.
- `2B2`: exactitud multi-outcome mas organizada; mejora algunos casos pero todavia conserva cola severa.
- `2B3`: shared-outcomes baja fuerte el costo tipico y acorta la cola, aunque no la elimina.
- `2D1`: incremental por transcript reduce mas la cola, pero aun puede explotar en puntos duros.
- `2E2`: VE exacta por snapshot aplasta la cola observada en este corpus.
- `2E3`: agrega reuse incremental sobre VE, pero introduce overhead suficiente para quedar por detras de `2E2`.

### Measured result con censura correcta

- Timeouts oficiales `>150 s`:
  - `2A = 9`
  - `2B = 5`
  - `2B2 = 8`
  - `2B3 = 2`
  - `2D1 = 1`
  - `2E2 = 0`
  - `2E3 = 0`
- Medianas exactas sobre puntos completados:
  - `2A 104.716 ms`
  - `2B 83.823 ms`
  - `2B2 85.070 ms`
  - `2B3 29.254 ms`
  - `2D1 21.012 ms`
  - `2E2 15.489 ms`
  - `2E3 20.894 ms`
- Cola de costo exacta (`p99` sobre completados):
  - `2A 135918.419 ms`
  - `2B 119388.636 ms`
  - `2B2 115870.111 ms`
  - `2B3 26661.672 ms`
  - `2D1 14497.686 ms`
  - `2E2 79.127 ms`
  - `2E3 96.219 ms`
- Lower bound de suma total tratando timeouts como censura `>150 s`, nunca como `150 s` exactos:
  - `2A >= 3882522.858 ms`
  - `2B >= 2641603.113 ms`
  - `2B2 >= 3428369.546 ms`
  - `2B3 >= 909381.699 ms`
  - `2D1 >= 524178.611 ms`
  - `2E2 = 5230.885 ms`
  - `2E3 = 7393.482 ms`
- Ratio de esos lower bounds contra `2E2`:
  - `2A >= 742.231x`
  - `2B >= 505.001x`
  - `2B2 >= 655.409x`
  - `2B3 >= 173.849x`
  - `2D1 >= 100.208x`
  - `2E3 = 1.413x`

### Donde aparecen los timeouts y como cambia la cola

- Los timeouts aparecen recien en los algoritmos previos a VE exacta:
  - ya hay timeouts en `2A/2B/2B2` durante `early`;
  - `2B3` aguanta mucho mejor pero igualmente cae en `C03` click `47` y `C04` click `44`;
  - `2D1` todavia registra un timeout.
- En `mid`, la cola de costo explota claramente para `2A/2B/2B2/2B3/2D1`:
  - mediana `mid` de `2A`: `106096.118 ms`
  - `2B`: `28059.308 ms`
  - `2B2`: `82290.279 ms`
  - `2B3`: `14012.145 ms`
  - `2D1`: `8667.495 ms`
  - `2E2`: `53.375 ms`
  - `2E3`: `84.960 ms`
- La gran conclusion empirica del longitudinal es doble:
  - `2E2` es el verdadero salto de regimen en esta familia;
  - `2E3` mantiene esa cola controlada, pero no mejora el frente absoluto de `2E2`.

## Cuestion metodologica separada

- El benchmark actual si demuestra:
  - exactitud del primitive exacto por celda;
  - exactitud de `2E3` respecto de `2E2` y `2B3`;
  - histories construidas desde transcripts persistidos;
  - accounting honesto por punto.
- El benchmark actual todavia no demuestra, por si solo:
  - una validacion end-to-end del flood-fill completo generado unicamente por sampling secuencial sin hidden-board oracle en toda la cadena experimental.
- Importa distinguir:
  - "primitive exacto por celda sobre transcripts dados"
  - vs
  - "demostracion end-to-end del proceso completo de juego/revelado sin oracle oculto".
- Esta diferencia queda documentada como pendiente metodologica, pero no invalida la correccion actual del raw ni requiere abrir otro experimento en esta revision.

## Conclusion final y siguiente paso recomendado

- Resultado medido:
  - `2E3` es exacto y estable;
  - `2E3` no timeouta en el corpus oficial;
  - `2E3` queda consistentemente por detras de `2E2` en wall-clock honesto.
- Interpretacion:
  - el experimento cumplio el objetivo cientifico de demostrar reuse incremental exacto;
  - no justifico, por ahora, adoptar esa complejidad sobre `2E2`.
- Siguiente paso recomendado:
  - congelar `2E3` como experimento auditado y mantener `2E2` como baseline operativo;
  - si se retoma investigacion, el siguiente trabajo deberia atacar especificamente el overhead de transicion/bookkeeping o la metodologia end-to-end, no inventar automaticamente una nueva rama tipo `2E3b/2E4`.
