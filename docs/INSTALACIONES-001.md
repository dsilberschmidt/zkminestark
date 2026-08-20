# Instalaciones 001 — Entorno F0 Starknet/Dojo

**Fecha:** 2026-08-03  
**Contexto:** Setup inicial del entorno de desarrollo para la Fase 0 del roadmap (experimento de latencia lazy sampling + VRF). Instalación puramente de infraestructura — sin lógica de contrato todavía.  
**Plataforma:** Linux x86_64 (Ubuntu 24.04), gestión de versiones vía `asdf`.

---

## Herramientas instaladas

### 1. scarb 2.13.1
Compilador y gestor de paquetes de Cairo.

```
scarb 2.13.1 (a76aed717 2025-10-30)
cairo: 2.13.1
sierra: 1.7.0
arch: x86_64-unknown-linux-gnu
```

- **Instalación:** `asdf install scarb 2.13.1` + `asdf global scarb 2.13.1`
- **Versión previa en sistema:** 2.5.4 (reemplazada — incompatible con Dojo 1.8.x)
- **Fuente de la versión target:** `.tool-versions` del release `sozo/v1.8.7` de dojoengine/dojo

---

### 2. Starknet Foundry 0.62.1
Testing y despliegue de contratos Cairo. Incluye `snforge` (test runner) y `sncast` (CLI de interacción con Starknet).

```
snforge 0.62.1
sncast 0.62.1
```

- **Instalación:** `asdf install starknet-foundry 0.62.1`
- **Por qué 0.62.1 y no 0.51.0 (la versión original del setup):** sncast 0.51.0 ya usa el UDC nuevo (`0x02ceed65...`) pero fue diseñado para trabajar con `starknet-devnet`, no con Katana. Al combinarlo con Katana 1.8.0-rc.9 (spec 0.10.0), la compatibilidad era incierta. sncast 0.62.1 declara soporte explícito para Starknet v0.14.3 y spec 0.10.0 — la misma familia que rc.9. Es la versión estable más reciente al momento de este setup.
- **Scarb no requiere actualización para sncast:** La restricción de Scarb en starknet-foundry aplica solo a `snforge` (compila Cairo). `sncast declare/deploy` lee artefactos ya compilados — Scarb 2.13.1 sigue siendo válido.
- **Dependencia adicional instalada:** `universal-sierra-compiler v2.9.1`
- **Historial:** se instalaron y descartaron sncast 0.18.0 (spec esperado 0.6.0, incompatible) y 0.49.0 (usa UDC nuevo igual que 0.51.0). Ambos quedan instalados en asdf pero no se usan.

---

### 3. sozo 1.8.7
CLI de Dojo Engine — compilación, migración y gestión de mundos (worlds) en Starknet.

```
sozo 1.8.7
scarb: 2.13.1 / cairo: 2.13.1 / sierra: 1.7.0
```

- **Instalación:** vía `dojoup` (instalador oficial de Dojo) + `asdf global sozo 1.8.7`
- **Nota:** El script `dojoup` falló en el paso `asdf set --home sozo 1.8.7` (comando no reconocido en esta versión de asdf). La instalación del binario fue exitosa; se seteó global manualmente con `asdf global sozo 1.8.7`.

---

### 4. katana 1.8.0-rc.9
Blockchain local de desarrollo para Starknet (nodo Devnet de Dojo).

```
katana 1.8.0-rc.9-dev (92787269)
features: -native
built on: 2026-07-20T12:14:09Z
```

- **Instalación:** descarga directa desde `dojoengine/katana` (repo separado del monorepo dojo)
  ```
  wget https://github.com/dojoengine/katana/releases/download/v1.8.0-rc.9/katana_v1.8.0-rc.9_linux_amd64.tar.gz
  tar xzf katana_v1.8.0-rc.9_linux_amd64.tar.gz -C ~/.local/bin
  ```
- **Por qué rc.9 y no una versión estable:** La última versión estable (1.7.1) trae el UDC viejo (`0x041a78e...`). El UDC nuevo (`0x02ceed65...`) que requieren sncast ≥ 0.49.0 y starknet.py recientes sólo apareció en el genesis a partir de v1.8.0-rc.1 (PR #536). No hay versión estable de Katana con el UDC nuevo al momento de este setup (2026-08-03).
- **Spec JSON-RPC:** 0.10.0 (subió de 0.9.0 en la misma release que el UDC nuevo).
- **Nota de distribución:** Katana no está incluido en el release `sozo/v1.8.7` ni en ningún tarball del monorepo dojo post-1.5.0. Se distribuye independientemente desde `github.com/dojoengine/katana`.
- **Actualización F1 (2026-08-19):** La sintaxis `--seed 0` ya no existe. Usar: `katana --dev --dev.seed 0`. El flag `--dev` habilita modo desarrollo; `--dev.seed <N>` fija el seed para las cuentas predefinidas. Las cuentas resultantes con seed=0 son idénticas a las de F0.

---

## Verificación de interoperabilidad

Katana levantado en modo dev y verificado vía JSON-RPC:

```bash
katana --dev &
curl -s -X POST http://localhost:5050 \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}'
```

**Respuesta:**
```json
{"jsonrpc":"2.0","id":1,"result":"0x4b4154414e41"}
```

`0x4b4154414e41` = "KATANA" en ASCII. RPC activo, genesis inicializado, 10 cuentas prefunded disponibles para dev.

---

## Wallet de desarrollo

| Campo | Valor |
|---|---|
| Wallet | Argent X (Ready X) |
| Tipo de cuenta | Standard |
| Red | Sepolia testnet |
| Balance inicial | 100 STRK (faucet oficial) |
| Dirección | `0x01C04a8a056aaC747697C499e6eBeCf5ac4D9E5768dF002BB0920EE64Cf87531` |

- **Faucet usado:** starknet-faucet.vercel.app
- **Uso previsto:** despliegue y llamadas en Sepolia testnet (no necesaria para desarrollo local con Katana).

---

## Tabla resumen

| Herramienta | Versión | Gestor | Binario en |
|---|---|---|---|
| scarb | 2.13.1 | asdf | `~/.asdf/shims/scarb` |
| snforge | 0.62.1 | asdf | `~/.asdf/shims/snforge` |
| sncast | 0.62.1 | asdf | `~/.asdf/shims/sncast` |
| sozo | 1.8.7 | asdf | `~/.asdf/shims/sozo` |
| katana | 1.8.0-rc.9 | manual | `~/.local/bin/katana` |
| Argent X | — | browser | Sepolia: `0x01C0…7531` |

### Versiones Katana — UDC y spec de referencia

| Katana | Estable | spec JSON-RPC | UDC desplegado |
|---|---|---|---|
| ≤ 1.7.1 | sí | 0.9.0 | `0x041a78e...` (viejo) |
| 1.8.0-rc.1+ | no (pre-release) | 0.10.0 | `0x02ceed65...` (nuevo) |

sncast ≥ 0.49.0 usa el UDC nuevo por defecto. Para desarrollo local, se necesita Katana ≥ 1.8.0-rc.1.

---

## Nota operativa: `--profile` en sncast 0.62.1

sncast 0.62.1 busca `snfoundry.toml` **solo en el directorio de trabajo actual** y en el path global (`~/.config/starknet-foundry/snfoundry.toml`). **No sube en el árbol de directorios** como hace cargo con `Cargo.toml`.

Si se corre `sncast` desde un subdirectorio (por ejemplo `contracts/vrf_bench/` o el scratchpad de `vrf_src/`), el `--profile katana0` falla aunque el `snfoundry.toml` esté en la raíz del proyecto.

**Workaround:** usar flags explícitos en lugar de `--profile`:
```bash
sncast \
  --account katana0 \
  --accounts-file ~/.starknet_accounts/starknet_open_zeppelin_accounts.json \
  declare --url http://localhost:5050 ...
```

---

## Contratos desplegados en Katana (devnet local)

| Contrato | Class Hash | Dirección |
|---|---|---|
| VrfProvider (cartridge-gg/vrf v0.3.1) | `0x148ab1961b07a4488b81e025e5876623a197e7436811411a628da02aca3b9df` | `0x063f9d1fd88cd37da6397ec2cb746497bf3c85aca2938b06f707f53c76893dc5` |
| Benchmark (vrf_bench) | `0x51067eaf99a19f342a5208be14b0494d55ae80a6b7dc6bb9811f24ddcf33b6c` | `0x018015db3a404681f9e0fde4d6aec8c82487ae89c6937249f4b4b0e3c02d4f87` |

- Owner/deployer: cuenta Katana dev 0 (`0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec`)
- VRF pubkey (test, secret-key 420): x=`0x66da5d53168d591c55d4c05f3681663ac51bcdccd5ca09e366b71b0c40ccff4`, y=`0x6d3eb29920bf55195e5ec76f69e247c0942c7ef85f6640896c058ec75ca2232`
- **ATENCIÓN:** clave VRF de test pública del repo cartridge-gg/vrf. Solo válida para medición F0 en devnet/testnet. Nunca usar en producción.

### Fórmula del seed (Source::Nonce)

```
seed_k = poseidon_hash([nonce_k, addr, caller, chain_id])
```

| Variable | Valor para Katana devnet |
|---|---|
| `nonce_k` | `VrfProvider_nonces[katana0]` antes de cada ciclo (empieza en 0, incrementa +1 por ciclo) |
| `addr` | katana0: `0x127fd5f1...ec` (el EOA que llama `roll()`) |
| `caller` | Benchmark: `0x018015db...87` (quien llama `consume_random`) |
| `chain_id` | `0x4b4154414e41` ("KATANA") |

Semilla del primer ciclo: `0x20d5acd269cf1b5cc828d4d70f6575f86d0e2005fcdc972dc9c75dbf8fc26a2`

### vrf-server API

```
POST http://localhost:3001/proof
Body: { "seed": ["0x<hex>"] }   ← array de strings, no string directa
Response: { "result": { "gamma_x", "gamma_y", "c", "s", "sqrt_ratio", "rnd" } }
```

### Multicall por ciclo (sncast multicall run)

```toml
[[call]]
call_type = "invoke"
contract_address = "<VrfProvider>"
function = "submit_random"
inputs = ["<seed>", "<gamma_x>", "<gamma_y>", "<c>", "<s>", "<sqrt_ratio>"]

[[call]]
call_type = "invoke"
contract_address = "<Benchmark>"
function = "roll"
inputs = []

[[call]]
call_type = "invoke"
contract_address = "<VrfProvider>"
function = "assert_consumed"
inputs = ["<seed>"]
```

`request_random` se omite — función vacía `{}` en cartridge-gg/vrf v0.3.1 línea 76-78.

### Resultado del primer ciclo end-to-end (2026-08-03)

- `get_last_value()` = `0x12931695bf01c34b009d612e8e8db068c9c3755b18cf1ed6afd69ee05ff7a44`
- `get_counter()` = `1`
- Tx: `0x3aace113e0a533e644f8a40467b8cb92fa643d365e79cfd17de1be22201540f`

---

---

## Cuenta de desarrollo Sepolia

| Campo | Valor |
|---|---|
| Perfil sncast | `sepolia_dev` |
| Wallet | Argent X (Ready X) |
| Tipo | Standard (v0.4.0, class `0x36078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f`) |
| Dirección | `0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192` |
| Balance inicial | 1000 STRK |
| RPC | `https://api.cartridge.gg/x/starknet/sepolia` |

- Importada con `sncast account import` (tipo `ready`)
- Desplegada vía "Account activation" en Ready X
- Clave privada: nunca en texto plano en git ni en este archivo — usar sncast con keystore o confirmar con el usuario

---

## Contratos desplegados en Sepolia

| Contrato | Dirección | Estado |
|---|---|---|
| VrfProvider (cartridge-gg/vrf v0.3.1) | `0x062550dc48d58ab49e84176c7bbd255c8a0d457bb08bec93eabe76c8549e4291` | ✓ Desplegado y verificado |
| Benchmark (vrf_bench) | `0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b` | ✓ Desplegado y verificado |

**Verificación VrfProvider (on-chain, 2026-08-03):**
- owner: `0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192` (sepolia_dev) ✓
- pubkey.x: `0x66da5d53168d591c55d4c05f3681663ac51bcdccd5ca09e366b71b0c40ccff4` ✓
- pubkey.y: `0x6d3eb29920bf55195e5ec76f69e247c0942c7ef85f6640896c058ec75ca2232` ✓

**Verificación Benchmark (on-chain, 2026-08-04):**
- Transaction Hash: `0x00d2ca27d222296a4a5593a2a115f91eaab0db3b4722f26449a868e7595f7821`
- Class Hash: `0x51067eaf99a19f342a5208be14b0494d55ae80a6b7dc6bb9811f24ddcf33b6c`
- Constructor arg (VrfProvider): `0x062550dc48d58ab49e84176c7bbd255c8a0d457bb08bec93eabe76c8549e4291`
- `get_counter()` = 0 (contrato recién desplegado, sin ciclos corridos) ✓
- **Nota:** el declare/deploy corrió con warning RPC ("uses incompatible version 0.9.0, expected 0.10.0") en el endpoint de Cartridge — no bloqueó la operación; vigilar si el batch de medición presenta fallos extraños.

---

## Smoke test Katana — 500 ciclos (2026-08-03)

Script: `scripts/measure_vrf.py`

| Métrica | Resultado |
|---|---|
| Ciclos solicitados | 500 |
| Ciclos completados | 500 |
| Errores | 0 |
| get_counter() final | 501 (nonce 0 → estado inicial correcto) |
| p50 latencia | 151 ms |
| p95 latencia | 171 ms |

Criterio go/no-go para Sepolia: p50 ≤ 2 s, p95 ≤ 5 s.

---

## Diagnóstico mismatch CASM Sepolia — resuelto (2026-08-04)

**Síntoma:** `sncast declare --contract-name Benchmark` en Sepolia fallaba con "Mismatch compiled class hash":
- Hash enviado: `0x4dee95216ca64d3549a2b1e616c179c9222737e03b43746f79ee19ebc635e1a`
- Hash esperado: `0x7a4534c879bb36caf688ff9243d6278a140810634bd199b8110946b42fb3208`

**Causa raíz:** El declare se corrió con sncast **0.51.0** (asdf había reseteado). sncast < 0.53.0 calcula `compiled_class_hash` con **Poseidon**. Starknet v0.14.1 (SNIP-34, noviembre 2025) cambió el cálculo a **Blake (BLAKE2s)**. Los dos hashes son el mismo CASM bajo dos funciones de hash distintas.

**USC 2.9.1 NO es el problema.** Sierra→CASM se compila correctamente.

**Fix:** sncast 0.62.1 (activo vía `asdf global starknet-foundry 0.62.1`) tiene soporte completo Blake. Re-ejecutar el declare con 0.62.1 debería funcionar sin ningún otro cambio.

---

## Diagnóstico: perfil sepolia_dev faltante en vrf_bench/snfoundry.toml — resuelto (2026-08-04)

**Síntoma:** `sncast declare`/`deploy` con `--profile sepolia_dev` fallaba al ejecutarse desde `contracts/vrf_bench/` aunque el perfil existía en el `snfoundry.toml` de la raíz del repo.

**Causa raíz:** sncast busca `snfoundry.toml` **solo en el directorio de trabajo actual**, no sube en el árbol (ya documentado en la nota operativa de la sección anterior). Al correr los comandos desde `contracts/vrf_bench/`, sncast no encontraba el perfil `sepolia_dev`.

**Fix:** copiar el bloque `[profile.sepolia_dev]` dentro de `contracts/vrf_bench/snfoundry.toml`. Con el perfil presente en el directorio correcto y sncast 0.62.1 activo, el declare/deploy funcionó sin otros cambios.

---

## Batch 500 ciclos Sepolia — resultado F0 go/no-go (2026-08-04)

| Métrica | Resultado | Criterio | Estado |
|---|---|---|---|
| Ciclos solicitados | 500 | — | — |
| Ciclos exitosos | 457 | — | — |
| Ciclos fallidos | 43 | — | nonce mismatch del script (ver nota) |
| p50 latencia | 3312 ms | ≤ 2000 ms | **FAIL** |
| p95 latencia | 4095 ms | ≤ 5000 ms | PASS |
| p99 latencia | 4393 ms | — | — |
| min latencia | 1935 ms | — | — |
| max latencia | 5160 ms | — | — |
| mean latencia | 3251 ms | — | — |

**Resultado go/no-go: ROJO.** El criterio requiere p50 ≤ 2000 ms Y p95 ≤ 5000 ms. El p50 falla (3312 ms) de forma consistente — no es un outlier ni un problema de medición.

**Nota — 43 fallos:** los fallos al final del batch se debieron a un nonce mismatch del script, no a un fallo del protocolo VRF ni de los contratos. Los 457 ciclos exitosos son representativos del comportamiento real del sistema.

---

## Próximas direcciones a evaluar (sin decisión tomada)

Las siguientes ideas surgieron al analizar el resultado ROJO de F0. Quedan registradas para la próxima sesión; ninguna está decidida.

### 1. Agrupar múltiples clicks por llamada VRF

La Adenda 3 a #3 de INCOGNITAS.md ya contempla "una semilla VRF por click alimenta un stream PRF para todos los sorteos de ESE click". La extensión sería aplicar esa lógica a VARIOS clicks, no solo dentro de uno.

**Primer paso antes de evaluar esta vía:** separar cuánto del tiempo medido en el batch de hoy corresponde específicamente a la llamada VRF (submit_random + assert_consumed) vs. el resto de la transacción (roll). Sin ese desglose, no se puede confirmar si agrupar 4 clicks llevaría la latencia por debajo de 1 s, o si el VRF es solo una fracción del costo total.

**Si se confirma que el VRF domina el costo:** agrupar clicks reduciría la latencia proporcionalmente, pero cambia la UX — el jugador tendría que comprometerse a un lote de clicks antes de ver resultados, o el juego decidiría el tamaño del lote sin interacción explícita. Esto es un cambio de mecánica de juego, no solo técnico — requiere discusión en Diseño 001 antes de comprometerse.

**Actualización 2026-08-17 — Discord Cartridge (rol LORD):** El diseño de VRF de Cartridge opera bajo "one action = one vrf request" (dicho con salvedad "iirc" — no categórico). Esta dirección queda de **baja prioridad** frente a la preconfirmación vía RPC (ítem 3). El desglose temporal VRF vs. resto de tx sigue siendo útil para entender el sistema, pero el batching como optimización ya no es la primera palanca a evaluar.

### 2. drand como alternativa a evaluar

drand es un beacon de aleatoriedad distribuido (red "quicknet": ronda cada 3 s, criptografía de umbral entre múltiples nodos independientes — ningún nodo conoce el valor antes de que se publique). Como alternativa al VRF por click actual y al oráculo centralizado (Plan B1 del roadmap).

**Ventaja potencial:** no requiere una transacción propia por click — el juego solo lee un valor ya publicado y verificado on-chain. Podría reducir la latencia sin el problema de confianza centralizada del oráculo.

**Abierto a investigar antes de comprometerse:** si existe una integración madura y lista para usar de drand en Starknet (verificador on-chain de sus firmas BLS). Sin confirmar.

### 3. Preconfirmación vía RPC para el gameplay loop *(hallazgo Discord Cartridge, 2026-08-17, rol LORD)*

Para reducir la latencia percibida en el gameplay loop, la recomendación del equipo de Cartridge es consultar el **preconfirmed status** directamente vía RPC, en vez de esperar confirmación completa de bloque.

**Distinción clave que cambia el diagnóstico de F0:** Torii (el indexador de Dojo) es para datos **agregados** — leaderboard, historial, estado global — no para el loop de juego en tiempo real. Si `measure_vrf.py` esperaba confirmación completa de bloque antes de registrar cada ciclo como completado, una parte significativa de los 3312 ms medidos podría ser ese overhead de confirmación, no el costo intrínseco del VRF ni de la transacción en sí.

**Experimento corrido — 2026-08-18 (`scripts/measure_preconfirm.py`, 40 ciclos Sepolia):**

| Métrica                              | Resultado  |
|--------------------------------------|------------|
| Ciclos exitosos                      | 37 / 40    |
| Preconfirm medible antes de accepted | 0 / 37     |
| p50 confirmación completa            | 3677 ms    |
| p95 confirmación completa            | 4748 ms    |

- p50=3677 ms es consistente con F0 (3312 ms) — la diferencia entra en varianza de red normal. El criterio go/no-go sigue en ROJO (p50 > 2000 ms).
- Preconfirmación no fue medible con sncast como intermediario: el tx_hash no está disponible en stdout de sncast antes de que el proceso termine (sncast bufferiza internamente con su runtime Rust; `stdbuf -oL` solo afecta el buffering de C stdio, no alcanza). Esto es una **limitación del mecanismo de medición, no del concepto**: `starknet_getTransactionStatus` puede devolver `execution_status=SUCCEEDED` antes de ACCEPTED_ON_L2, pero para aprovecharlo hay que tener el tx_hash disponible antes de la confirmación.

**Arquitectura correcta para preconfirmación (identificada, pendiente de implementar):**

Para que el cliente de juego pueda usar preconfirmación, necesita someter transacciones directamente vía RPC en vez de a través de sncast:
1. Construir y firmar la tx en el cliente (starknet.py o SDK JS/Dart).
2. Broadcast vía `starknet_addInvokeTransaction` → responde con tx_hash inmediatamente.
3. Polling de `starknet_getTransactionStatus` hasta `execution_status=SUCCEEDED` (en cualquier `finality_status`).

Esto es un cambio en el cliente del juego (capa F2), NO en los contratos (F1). No bloquea el desarrollo de contratos de F1.

**Condición:** No invertir en implementación de cliente sin financiamiento confirmado (ver roadmap).

### 4. `--vrf` nativo en katana — posible simplificación del entorno dev

*Hallazgo 2026-08-19*

Katana 1.8.0-rc.9 incluye soporte nativo para VRF:

- `--vrf`: lanza vrf-server como sidecar automáticamente y despliega VrfProvider en el genesis.
- `--vrf.url`: conectar a un VRF externo en vez de sidecar.
- `--vrf.contract`: especificar address del VrfProvider a usar.
- `--vrf.bin`: path al binario vrf-server (default: busca `vrf-server` en PATH).
- Requisito: `--cartridge.paymaster`.

Si funciona, colapsaría los pasos 2 y 3 del setup local (lanzar vrf-server + declarar/desplegar VrfProvider) en un solo flag al arrancar katana. No se evaluó en F1 — incertidumbre sobre el secret-key interno y el address resultante del VrfProvider. Evaluar en sesión dedicada.

### Repo de referencia: z-korp/zordle

Wordle fully on-chain en Dojo + Cartridge, con práctica diaria sin login. Señalado por el mismo miembro del equipo (rol LORD, Discord Cartridge, 2026-08-17) como ejemplo de arquitectura similar funcionando en producción.

Revisar como referencia de patrones de integración Dojo/Cartridge — en particular cómo manejan el loop de confirmación — antes de diseñar la arquitectura de interacción on-chain de ZK Minesweeper.

---

## Actividad comunitaria — 2026-08-17

Registro de involucramiento comunitario de la sesión. Relevante como evidencia del criterio "community engagement" del Seed Grant de Starknet (criterio "y/o", no bloqueante).

### Discord Dojo

- Unido al servidor; perfil configurado con pseudónimo del proyecto: **Cactus Sediento**.
- Mensaje publicado en #general: resultado de latencia F0 (p50=3312 ms, criterio ROJO) + pregunta sobre sequencer centralization y su impacto en la latencia medida.
- Respuesta útil recibida de miembro con rol LORD: preconfirmación RPC, batching VRF probablemente no viable, referencia a z-korp/zordle. Contenido ya documentado en la sección "Próximas direcciones a evaluar" más arriba.
- Etiqueta **DOJO** asignada al perfil por la comunidad.

### Discord Cartridge

- Unido al servidor; mensaje adaptado publicado en #general, mencionando el vRNG de Cartridge específicamente.
- Perfil bajo el mismo pseudónimo: **Cactus Sediento**.

### Issue GNOME Mines

- Issue abierto: https://gitlab.gnome.org/GNOME/gnome-mines/-/work_items/103
- Título: "Add click count as alternative/additional scoring metric to time"
- Propuesta: contador de clicks como métrica alternativa/adicional al tiempo. Alcance mínimo propuesto: mostrar el contador sin tocar los récords existentes todavía.
- Basado en el pitch de ECOSISTEMAS.md §4.
- Publicado bajo identidad real (Daniel / dsilberschmidt en GitLab de GNOME), a diferencia de los Discords que usan el pseudónimo del proyecto.

---

## F1-A — Dojo World zkmine_f1 (Katana devnet, 2026-08-19)

Primer deploy y prueba de integración de zkmine_f1. Lógica completa: spawn_game + VRF +
click, ambas ramas (safe click y mine hit) verificadas on-chain.

### Configuración

| Campo | Valor |
|---|---|
| Katana | 1.8.0-rc.9, `--dev --dev.seed 0` |
| vrf-server | cartridge-gg/vrf v0.3.1, `--secret-key 420` |
| VrfProvider class | `0x148ab1961b07a4488b81e025e5876623a197e7436811411a628da02aca3b9df` |
| zkmine_f1-actions class | `0x47470bf45c8ba7262fd5a2c082135f096a37df30bd961c050c25b3bcb30de2c` |
| Dojo World class | `0x613551abceb2b37073b1149bb862ea70cf029981ce1ca47e9dd7c7ab97cb65d` |
| Cuenta | Katana dev seed=0 (`0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec`) |

> Direcciones on-chain de Katana son efímeras (proceso katana). Los class hashes son
> determinísticos e idénticos a los de Sepolia (mismo código, mismo compilador).

### Prueba de integración — resultados (2026-08-19)

Ambas ramas verificadas on-chain:

| Rama | game_id | Celda | Cell | Status final |
|---|---|---|---|---|
| Mine hit | `0x5e835c8174e13828b6a3641a0dc7816e5ee353fb895475ced5c09eaf35aee38` | (0,0) | is_mine=1, revealed=1 | status=2 |
| Safe click | `0x61a7f3be6ac5c170f0cd7f2ff1193c6d8763dbea34e84d80bdb8a1e9835e7af` | (0,0) | is_mine=0, revealed=1 | status=0, revealed_count=1 |

Tx hashes completos y outputs on-chain en `docs/bitacora.md` — sección
"Prueba de integración F1: ejecución completa (2 juegos)".

### Fórmulas verificadas

- **game_id:** `poseidon_hash([tx_nonce, player, actions, chain_id])`
- **VRF seed:** `poseidon_hash([nonce_k, player, actions, chain_id])`
  donde `nonce_k` = nonce del VrfProvider para el player (0 en primer juego, +1 por consume_random)
- **Lazy sampling:** `bucket = raw % (total_cells - revealed_count); is_mine = bucket < remaining_mines`

### Nota operativa Katana — sozo 1.8.7

- `sozo execute` (no sncast) para invocaciones en sistema Dojo
- Katana 1.8.0-rc.9: `starknet_getNonce` requiere tag `pre_confirmed` (no `pending`)

---

## F1-A — Dojo World zkmine_f1 (Sepolia testnet, 2026-08-20)

Deploy completo en Sepolia. Primeras transacciones de zkmine_f1 en red pública con VRF real.

### Contratos desplegados

| Contrato | Dirección | Tx |
|---|---|---|
| VrfProvider (cartridge-gg/vrf v0.3.1) | `0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37` | `0x0713d868b6f49f8d1a98116446c92ab5de56a5c382a30b5296216a0f79e44cf2` |
| Dojo World zkmine_f1 | `0x027b48a001297a0da77eb50f6f52837cd8ea5e128f1a57f3d8fe7a3d1fd5e14d` | (sozo migrate) |
| zkmine_f1-actions | `0x292763cd8c85375a2d1f16d347ab93036b261305ff021715b49c91f1f43b2ba` | (sozo migrate) |

Tx set_config: `0x0061bac85a32a5284b611d4f222e1dfa7dabb500f60b302c1e3bf1ac11d3d9fb`

### Class hashes (determinísticos, idénticos a Katana)

| Contrato | Class Hash |
|---|---|
| VrfProvider | `0x148ab1961b07a4488b81e025e5876623a197e7436811411a628da02aca3b9df` |
| Dojo World | `0x613551abceb2b37073b1149bb862ea70cf029981ce1ca47e9dd7c7ab97cb65d` |
| zkmine_f1-actions | `0x47470bf45c8ba7262fd5a2c082135f096a37df30bd961c050c25b3bcb30de2c` |

### Prueba de integración — resultados (2026-08-20)

game_id: `0x686b989ce684941e21cb3dc097567f6846897147cab1ab30964fbd0c93a1651`
spawn_game tx: `0x07205c78d5d68719fc50e43a5f550f1eab368b14622b26bf7623460ee52d73cf`

| Rama | Tx multicall | Celda | Cell | Game |
|---|---|---|---|---|
| Safe click | `0x1b7107c971c5174fd00c797a7c9d3167ab86024e0fc72ce7e35dd8ff5802410` | (0,0) | is_mine=0, revealed=1 | status=0, revealed_count=1 |
| Mine hit | `0x78ffa919d9916a4be323702b20fb03092c33888ebb1d930865ff790980b0731` | (1,0) | is_mine=1, revealed=1 | status=2, remaining_mines=98 |

Voyager mine hit tx:
https://sepolia.voyager.online/tx/0x078ffa919d9916a4be323702b20fb03092c33888ebb1d930865ff790980b0731

### Hallazgos técnicos del deploy

**sozo 1.8.7 — perfil no-dev:**
- `[profile.NAME]` debe existir en `Scarb.toml` (aunque vacío) antes de `sozo build/migrate --profile NAME`
- `sozo build --profile NAME` debe correr antes de `sozo migrate --profile NAME`

**sozo 1.8.7 — env var en toml:**
- `${VAR}` en `dojo_*.toml` NO se expande antes de parsear como Felt252
- Workaround: `sozo [migrate|execute] --profile NAME --private-key $VAR`

**VrfProvider v0.3.1 en Sepolia:**
- `nonces` no expuesto; función disponible: `get_consume_count()` (sin args, conteo global)
- El campo `rnd` del vrf-server API **no coincide** con el output de `consume_random` on-chain
  — no es posible predecir outcomes off-chain con este campo
- Seed array format: `{"seed": ["0x..."], "address": "0x..."}` (array, no string directa)
- sncast 0.62.1 + RPC Cartridge Sepolia: warning "incompatible version 0.9.0" — no bloqueante

---

## Estado al cierre de sesión 2026-08-04

### COMPLETADO Y VERIFICADO

- [x] Entorno local instalado (scarb 2.13.1, sncast 0.62.1, sozo 1.8.7, katana 1.8.0-rc.9)
- [x] VrfProvider desplegado y verificado en Katana
- [x] Benchmark desplegado en Katana
- [x] Primer ciclo end-to-end completado en Katana
- [x] Script `measure_vrf.py` validado — 500/500 ciclos, 0 errores
- [x] Cuenta sepolia_dev creada, importada a sncast, 1000 STRK
- [x] VrfProvider desplegado y verificado en Sepolia (`0x062550dc...91`)
- [x] Mismatch CASM diagnosticado — causa raíz identificada (sncast 0.51.0 vs Blake), fix disponible
- [x] Benchmark declarado en Sepolia (clase `0x51067eaf99a19f342a5208be14b0494d55ae80a6b7dc6bb9811f24ddcf33b6c`)
- [x] Benchmark desplegado en Sepolia (`0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b`)
- [x] Batch 500 ciclos en Sepolia — 457/500 exitosos
- [x] Reporte go/no-go F0 — resultado ROJO (p50=3312 ms, criterio ≤2000 ms)

### PENDIENTE — próxima sesión

Resultado F0 ROJO — pendiente de decisión de diseño. Ver sección "Próximas direcciones a evaluar" más arriba.

---
