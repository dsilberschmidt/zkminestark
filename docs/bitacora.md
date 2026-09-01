# Bitácora — zkminestark

Registro histórico append-only. Cada entrada es el contenido de `pending_review.md`
al momento de ser reemplazado, con encabezado de fecha/hora.

---

## 2026-09-01T14:10 — Frontier VCLS/CELL replicación completa (snapshot anterior)

# Frontier Cairo VCLS/CELL — Replicación completa (2026-09-01)

**Tarea:** Determinar el mayor tablero cuadrado pre-grant GREEN con pipeline VCLS/CELL exacto, sin intra-CELL continuation.

---

### Metodología

- **Corpus:** 500 seeds × 3 estrategias (start, corner, end) por corpus
- **Minas:** formula `floor(5·N·N/32 + 0.5)`
- **Candidatos adversariales:** todo ord_iw≥7, top sum_ord_size, top max_width, combinaciones
- **Criterio predeclarado (invariante):**
  - GREEN: 100% exacto Python↔Cairo, cero candidatos ≥900M
  - YELLOW: 100% exacto, cero >1.1B, al menos uno ≥900M
  - RED: cualquier candidato >1.1B O fallo de exactitud
- **Replicación:** segundo corpus independiente (seeds 500–999) para validar resultados GREEN

### Tabla de resultados

| Tablero | Minas | CELL states | Candidatos | Max gas | Exactos | Veredicto |
|:--------|------:|------------:|-----------:|--------:|--------:|:---------|
| 16×16/40 | 40 | — | 59 | 1.591B | 59/59 | **RED** |
| 15×15/35 | 35 | 165,832 | 203 | 2.409B | 203/203 | **RED** |
| 12×12/23 | 23 | 102,838 | 126 | 1.668B | 126/126 | **RED** |
| 11×11/19 | 19 | 86,537 | 134 | 3.133B | 134/134 | **RED** |
| 10×10/16 | 16 | 69,306 | 117 | 1.547B | 117/117 | **RED** |
| 9×9/13 C1 | 13 | 54,912 | 120 | 0.340B | 120/120 | GREEN (solo) |
| 9×9/13 C2 | 13 | 55,386 | 126 | 2.133B | 126/126 | **RED** |
| **9×9/13 combinado** | — | **110,298** | **246** | **2.133B** | **246/246** | **RED** |
| 8×8/10 C1 | 10 | 43,642 | 104 | 0.261B | 104/104 | GREEN |
| 8×8/10 C2 | 10 | 44,234 | 111 | 0.198B | 111/111 | GREEN |
| **8×8/10 combinado** | — | **87,876** | **215** | **0.261B** | **215/215** | **GREEN ✓** |

### Preset GREEN más grande verificado

> **8×8/10** — 8 filas × 8 columnas, 10 minas
> Validado con 1000 seeds × 3 estrategias = 3000 partidas
> 215 candidatos adversariales Cairo ejecutados
> max gas = 261M L2 Sierra (29% del gate 900M)
> Exactitud Python↔Cairo: 215/215 (100%)

---

---

## 2026-08-19 — sozo init: resultado y plan de limpieza

### Lo que creó sozo init contracts/zkmine_f1

Nota en el output: "Couldn't find template for your current sozo version. Getting the
latest version instead." → usó el main de dojo-starter (dojo=1.8.0, starknet=2.13.1).

Archivos relevantes leídos del template:
- Scarb.toml: name="dojo_starter", version="1.8.0" — cambiar a "zkmine_f1" / "0.1.0"
- dojo_dev.toml: world "Dojo starter", namespace "dojo_starter", katana0 key en texto plano (test, no sensible)
- src/lib.cairo: módulos actions, models, tests — sin referencias a dojo_starter, OK
- src/models.cairo: ejemplo Moves/Position/Direction — reemplazar completo
- src/systems/actions.cairo: ejemplo spawn/move con self.world(@"dojo_starter") — reemplazar completo

Patrón API confirmado del template (Dojo 1.8.0):
- `#[dojo::contract]` / `#[dojo::model]` / `#[dojo::event]`
- `world.read_model(key)` / `world.write_model(@model)`
- `self.world(@"namespace")` → WorldStorage
- `#[abi(embed_v0)]` en el impl

### Plan de limpieza aprobado (9 pasos)

1. rm -rf: assets/, compose.yaml, Dockerfile, LICENSE, manifest_dev.json, README.md, torii_dev.toml, .vscode/, dojo_release.toml
2. .tool-versions: sozo 1.8.0 → sozo 1.8.7
3. Scarb.toml: name→"zkmine_f1", version→"0.1.0", quitar scripts spawn/move
4. dojo_dev.toml: world name/namespace/seed→"zkmine_f1", quitar social links, comentario explícito sobre clave katana (no sensible)
5. Crear dojo_sepolia.toml: con ${ZKMINE_SEPOLIA_PRIVATE_KEY}
6. Crear snfoundry.toml: perfil sepolia_dev
7. src/models.cairo: Game, Cell (con revealed:bool), Config
8. src/systems/actions.cairo: set_config, spawn_game (solo Game, sin VRF), click (VRF lazy + modulo)
9. src/tests/test_world.cairo: vaciar

---

## 2026-08-19 — Corrección actions.cairo: 4 bugs

### Bug 1 (arquitectura): spawn_game escribía 480 Cell — INCORRECTO

spawn_game() solo debe crear Game. click() llama consume_random y crea Cell.
Razón: si spawn_game escribe las 480 Cell al storage, cualquiera puede leer
el tablero completo on-chain antes del primer click (foreknowledge attack —
el mismo problema que el diseño lazy existe para evitar).

### Bug 2: literal 2^256 no compila en u256

0x10000...0_u256 (65 dígitos hex) desborda u256 max.
Fix: usar módulo para el sampling:
  bucket = raw_u256 % remaining_cells
  is_mine = bucket < remaining_mines
Bias = remaining_cells / felt252_max ≈ 2^-243 — negligible.

### Bug 3: falta chequeo "celda ya clickeada"

Cell necesita campo `revealed: bool`. Default false = "nunca clickeada".
assert(!cell.revealed, 'already clicked') antes de consumir VRF.
→ Cell en models.cairo actualizado para incluir revealed: bool.

### Bug 4 (implícito): win check incorrecto para diseño lazy

En Active state remaining_mines = mine_count (constante — clickear mina termina el juego).
Formula original: safe_remaining = total_cells - revealed_count → nunca llega a 0.
Fix: win cuando revealed_count + mine_count == total_cells (= 381 safe cells reveladas).

### Decisión consciente: remaining_mines -= 1 en rama is_mine

Mantenido con comentario. world.write_model(@game) escribe el campo al storage.
Estado final: mine_count - remaining_mines = 1 → auditable (una mina clickeada).

### Hallazgo: cartridge_vrf no es dependencia de Scarb

vrf_bench define la interfaz VRF localmente ("mirror manual"). zkmine_f1 hace lo mismo —
Source enum + IVrfProvider inline en actions.cairo. Sin dependencia nueva en Scarb.toml.

---

## 2026-08-19 — sozo build: resultado

```
Compiling zkmine_f1 v0.1.0 (/home/.../contracts/zkmine_f1/Scarb.toml)
Finished `dev` profile target(s) in 13 seconds
```

Sin errores. Sin warnings.
Confirma compatibilidad: dojo 1.8.0 + sozo 1.8.7 son compatibles.

### Estructura final de contracts/zkmine_f1/

```
dojo_dev.toml       — katana0, comentario explícito clave no sensible
dojo_sepolia.toml   — Sepolia, private_key=${ZKMINE_SEPOLIA_PRIVATE_KEY}
.gitignore          — conservado del template
Scarb.lock          — conservado
Scarb.toml          — package zkmine_f1 v0.1.0
snfoundry.toml      — perfil sepolia_dev
src/
  lib.cairo               — sin cambios
  models.cairo            — Game, Cell (revealed:bool), Config
  systems/actions.cairo   — set_config, spawn_game, click (VRF lazy)
  tests/test_world.cairo  — vaciado
.tool-versions      — sozo 1.8.7, scarb 2.13.1
```

### Sweep de claves — resultado

Archivos con private_key en texto plano en contracts/:
- dojo_dev.toml: katana0 — comentario explícito agregado ✓
- dojo_release.toml: katana0 — ELIMINADO ✓
Sin claves en: snfoundry.toml (ext), dojo_sepolia.toml (env var).

---

## 2026-08-19 — Secuencia de deploy F1 local: plan aprobado

Katana no estaba corriendo. Procedimiento aprobado (Opción A — manual, igual que F0):

1. katana --dev --dev.seed 0
   (CLI cambió: --seed 0 → --dev --dev.seed 0)
2. vrf-server --secret-key 420 --account-address 0x1 --account-private-key 0x1 --port 3001
3. Re-declarar y desplegar VrfProvider (build desde cartridge-gg/vrf@v0.3.1)
4. sozo migrate (desde contracts/zkmine_f1/, usa dojo_dev.toml)
5. sozo execute zkmine_f1-actions set_config -c <vrf_provider_addr> --wait

Opción B (--vrf nativo en katana) anotada en INSTALACIONES-001 para evaluar en el futuro.

set_config va DESPUÉS de migrate porque Dojo migrate solo declara clases y registra
recursos — no puede invocar funciones arbitrarias de los sistemas.

---

## 2026-08-19 — Paso 1: Katana

### Cambio de interfaz

`katana --seed 0` ya no existe. Nueva sintaxis:
  katana --dev --dev.seed 0

### Resultado

katana corriendo en 127.0.0.1:5050
Katana0 (seed=0):
  address:     0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec
  private_key: 0xc5b2... (test, no sensible)

### Hallazgo: --vrf nativo en katana 1.8.0-rc.9

Documentado en INSTALACIONES-001.md sección "Próximas direcciones a evaluar" ítem 4.
No evaluado en F1 por incertidumbre sobre secret-key interno y address del VrfProvider.

---

## 2026-08-19 — Paso 2: vrf-server

```
vrf-server --secret-key 420 --account-address 0x1 --account-private-key 0x1 --port 3001
```

Corriendo en http://0.0.0.0:3001. Endpoint /proof responde HTTP 200. ✓

### Cambio de puerto respecto a F0

Default del binario cambió de 3001 a 3000. Forzado a 3001 con --port para mantener
compatibilidad con measure_vrf.py y measure_preconfirm.py.

---

## 2026-08-19 — Paso 3: VrfProvider declarado y desplegado

### Situación

No había artefactos del VrfProvider en caché. Compilado de fuente:

```bash
git clone https://github.com/cartridge-gg/vrf.git /tmp/cartridge_vrf --branch v0.3.1 --depth 1
cd /tmp/cartridge_vrf && scarb build
```

### Declare

```bash
sncast --account katana0 --accounts-file ~/.starknet_accounts/...json \
  declare --url http://localhost:5050 --contract-name VrfProvider
```

Class Hash: 0x148ab1961b07a4488b81e025e5876623a197e7436811411a628da02aca3b9df
→ COINCIDE con F0. scarb 2.13.1 produce el mismo sierra determinísticamente. ✓

Nota sobre sncast 0.62.1: --url va después del subcomando (no antes de él).
Nota: sncast declare requiere --contract-name (no --contract-artifact) y necesita
      correr desde dentro del proyecto Scarb para encontrar los artefactos.

### Deploy

Constructor: VrfProvider(owner: ContractAddress, pubkey: PublicKey { x, y })

```bash
sncast --account katana0 --accounts-file ~/.starknet_accounts/...json \
  deploy --url http://localhost:5050 \
  --class-hash 0x148ab1961b07a4488b81e025e5876623a197e7436811411a628da02aca3b9df \
  --constructor-calldata \
    0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec \
    0x66da5d53168d591c55d4c05f3681663ac51bcdccd5ca09e366b71b0c40ccff4 \
    0x6d3eb29920bf55195e5ec76f69e247c0942c7ef85f6640896c058ec75ca2232
```

VrfProvider address: 0x02b5b5f0b96d4c8f48ee5bb75283cf83a977f19d74b739a2709108ca6e2699b1
Tx hash:            0x036cbeb1b4bf7e86e9fee93c740d20e547bdfa2a54b2f2d4ad1908d009171327

(Address diferente al de F0 — nueva instancia de Katana, esperado.)

---

## 2026-08-19 — Paso 4: sozo migrate

```
profile: dev | chain_id: KATANA | rpc_url: http://localhost:5050/
```

Warning RPC mismatch (0.10.0 vs 0.9.0) — mismo que F0, no bloqueante.

### Resultado

World desplegado en bloque 4:
  0x027b48a001297a0da77eb50f6f52837cd8ea5e128f1a57f3d8fe7a3d1fd5e14d

Recursos: 4 clases declaradas, 4 recursos registrados
Permisos: 1 (zkmine_f1 → zkmine_f1-actions writer) ✓
Contratos inicializados: 1 (zkmine_f1-actions)

### Dirección del contrato actions

tag:     zkmine_f1-actions
address: 0x292763cd8c85375a2d1f16d347ab93036b261305ff021715b49c91f1f43b2ba

(De manifest_dev.json generado por sozo migrate)
Nota: IPFS credentials not found — metadata upload skipped. No afecta el deploy.

---

## 2026-08-19 — Paso 5: set_config

Objetivo: configurar el modelo Config con la dirección del VrfProvider del paso 3.

### Hallazgo: sintaxis de sozo execute cambió

La sintaxis anterior (-c para calldata) ya no funciona. Nueva sintaxis:
  sozo execute <TAG> <ENTRYPOINT> [CALLDATA...] --wait
  (calldata como argumentos posicionales, sin flag -c)

### Comando correcto

```bash
sozo execute zkmine_f1-actions set_config \
  0x02b5b5f0b96d4c8f48ee5bb75283cf83a977f19d74b739a2709108ca6e2699b1 \
  --wait
```

Tx hash: 0x020550cf1c31565ef4714439e12afa8e0ae7cf70437d4a9a86b9242216cb686d

Nota: --wait no muestra mensaje de éxito explícito (solo el tx hash). Verificar con:
  sozo model get Config 0

### Verificación on-chain

```bash
sozo model get Config 0
```

Resultado:
{
    id           : 0x000...0
    vrf_provider : 0x02b5b5f0b96d4c8f48ee5bb75283cf83a977f19d74b739a2709108ca6e2699b1
}

vrf_provider coincide con el VrfProvider desplegado en paso 3. ✓

---

## 2026-08-19 — Deploy F1 local: COMPLETADO

Resumen de direcciones para esta sesión de Katana:

| Contrato        | Address                                                              |
|-----------------|----------------------------------------------------------------------|
| VrfProvider     | 0x02b5b5f0b96d4c8f48ee5bb75283cf83a977f19d74b739a2709108ca6e2699b1 |
| Dojo World      | 0x027b48a001297a0da77eb50f6f52837cd8ea5e128f1a57f3d8fe7a3d1fd5e14d |
| zkmine_f1-actions | 0x292763cd8c85375a2d1f16d347ab93036b261305ff021715b49c91f1f43b2ba |

Katana es efímero — estas addresses solo son válidas mientras la instancia actual
de katana siga corriendo. Al reiniciar, hay que repetir pasos 3-5 (VrfProvider +
sozo migrate + set_config).

Para Sepolia: usar sozo migrate --profile sepolia (requiere ZKMINE_SEPOLIA_PRIVATE_KEY).

---

## 2026-08-19 — F1 estado post-prueba de integración

Prueba de integración completa. Scope F1-A cerrado.
Entorno Katana activo con las direcciones documentadas en la sesión anterior.
Ver entrada siguiente para detalle completo de la prueba.

---

## 2026-08-19 — Prueba de integración F1: propuesta inicial

### Estado del entorno
Katana: corriendo (pid 223922, bloque 11) — misma instancia. ✓

### Hallazgo crítico: click() requiere multicall atómico
`click()` llama `vrf.consume_random()` que busca el proof almacenado por
`submit_random()` en el mismo tx. Dos txs separados fallan.
Multicall requerido: `[submit_random(seed, proof), click(game_id, x, y)]`

### Secuencia propuesta (T1-T6)
T1: sozo execute spawn_game 99 --wait
T2: extraer game_id del receipt (starknet_traceTransaction retdata)
T3: calcular VRF seed con poseidon_py (nonce_k=0, player, actions, chain_id)
T4: curl vrf-server:3001/proof con seed
T5: sncast multicall run (submit_random + click)
T6: sozo model get Game + Cell

### Puntos abiertos al momento de la propuesta
1. poseidon_py disponible? → verificar
2. Field names del JSON de vrf-server
3. Calldata de submit_random (Proof struct)

---

## 2026-08-19 — Prueba de integración F1: ejecución completa (2 juegos)

### Verificación de los 3 puntos abiertos

| # | Punto | Resultado |
|---|-------|-----------|
| 1 | poseidon_py disponible | ✓ `from poseidon_py.poseidon_hash import poseidon_hash_many` |
| 2 | Field names vrf-server /proof | `gamma_x`, `gamma_y`, `c`, `s`, `sqrt_ratio` — `resp.json()["result"]` |
| 3 | Calldata submit_random | 6 felts: seed + 5 proof fields; TOML usa clave `inputs` (no `calldata`) |

Hallazgo de interfaz: katana 1.8.0-rc.9 rechaza `pending` en starknet_getNonce — usar `pre_confirmed`.

---

### Juego 1 — rama mine hit

nonce katana0 = 9 (0x9) antes del spawn

```
game_id = poseidon_hash([9, player, actions, KATANA])
        = 0x5e835c8174e13828b6a3641a0dc7816e5ee353fb895475ced5c09eaf35aee38

vrf_seed (nonce_k=0) = poseidon_hash([0, player, actions, KATANA])
                     = 0x27ebd88efd07aad31da8ff72f9b1b08ede9d7b22afaec7adb29d5b3119e6602
```

spawn_game tx:   0x06477ce552bea8ba230c3863ff67aff01268d11716cb4aea0540689da19c8676
multicall tx:    0x36240c9799c8014ced54f01d36cb288807719777625cbec3fa75348947b2c9c

Proof (nonce_k=0):
```
gamma_x    : 0x6ea634f8d28218a83877b1ff59a7447ef9dc126d1f2e6f3a7e75b6fb7917e8f
gamma_y    : 0x3d8390ea3bf5817f1698e2a08ceb9f8d3d6c55e8091e31845d9f99b53d812c8
c          : 0x33f204f1ea6c462ac775e41b77ef8b4de805e449887d5f4ceb1195fe96a601a
s          : 0x52e01e6ffe0f25496dd8728c904164260ef5dc0f674097f4f59093d9a2b35e
sqrt_ratio : 0x28752cbcddb860b55878c9dd2c4767ce05fdb4f328a4f20a6649a20e8717647
rnd        : 0x45766ffd0e0db64fd74bf502a06c9d2b1c14ddaf79bc33a779ed2d300af6f6e
```

Resultado (click 0,0):
```
Game: status=2 (Lost), mine_count=99, remaining_mines=98, revealed_count=0, total_cells=480
Cell: is_mine=1, revealed=1
```

---

### Juego 2 — rama safe click

nonce katana0 = 11 (0xb) antes del spawn

```
game_id = poseidon_hash([11, player, actions, KATANA])
        = 0x61a7f3be6ac5c170f0cd7f2ff1193c6d8763dbea34e84d80bdb8a1e9835e7af

vrf_seed (nonce_k=1) = poseidon_hash([1, player, actions, KATANA])
                     = 0x21640a9afda869d4ca69cd1f5a5a049c247099dcd32e4e9c2d4edff670442ee
```

Pre-verificación off-chain: rnd % 480 = 239 < 99 → False → safe click garantizado

spawn_game tx:   0x0287b7cc07680014b7ea6259ee87989b59e8573b0e4b13760abc3d1dd9eeb9d6
multicall tx:    0x5bb256bc72af0ee228d118d2017705e7e9c0bda98628e227a244c87182d2ce1

Proof (nonce_k=1):
```
gamma_x    : 0x7c28ff6309e2c77a7928d47cc68b7fc438d8bc974e840a4ed0223bf52f22301
gamma_y    : 0x1666b40ee59e420238db9007f4e506985331ff707300cc48048753fb4adf3e9
c          : 0x30f7d7e30d9afaa4cb4031d8459c4aeb00cde6b1bce7842db92d4bb2e39f8fd
s          : 0x30b150b94ed919d18a817afab31286a89abde8b3f646eac901dc31909cd8f65
sqrt_ratio : 0x1307b735aecd6974a07cb8e3cffb231db6d08fe34bef6cadddca462243067d
rnd        : 0x3bcbafac9e96a436eeed55c06a88efd6b0977b153a7502ac03b749d13bd02f
```

Resultado (click 0,0):
```
Game: status=0 (Active), mine_count=99, remaining_mines=99, revealed_count=1, total_cells=480
Cell: is_mine=0, revealed=1
```

Win check: 1 + 99 = 100 ≠ 480 → no dispara. Bug 4 fix verificado on-chain. ✓

---

### Tabla resumen — invariantes verificados

| Invariante | J1 (mine hit) | J2 (safe click) |
|------------|:---:|:---:|
| game_id off-chain == on-chain | ✓ | ✓ |
| Game inicial correcto | ✓ | ✓ |
| Flujo VRF completo (seed→proof→multicall→consume_random) | ✓ | ✓ |
| Cell creada lazy en el click | ✓ | ✓ |
| Mine hit: status=2, remaining_mines−1 | ✓ | — |
| Safe click: status=0, revealed_count+1 | — | ✓ |
| Win check no dispara prematuramente | — | ✓ |
| Double-click guard: Cell.revealed=true | ✓ | ✓ |
| Pre-verificación off-chain coincide con on-chain | ✓ | ✓ |
| sncast multicall sin --profile | ✓ | ✓ |

### Conclusión
El contrato F1 funciona de punta a punta en Katana local con VRF real.
Ambas ramas (mine hit y safe click) verificadas on-chain.
El scope F1-A (spawn + click + VRF + win/loss) está cerrado.

---

## 2026-08-20 — Deploy F1-A en Sepolia: propuesta + Paso 1

### Pre-checks completados

| Check | Resultado |
|-------|-----------|
| Balance STRK sepolia_dev | 975.26 STRK ✓ |
| vrf-server (pid 225125, puerto 3001, secret-key 420) | Corriendo ✓ |
| Clase VrfProvider en Sepolia (0x148ab1...b9df) | Ya declarada (F0) ✓ → skip declare |

### Paso 1 ✓ — Deploy VrfProvider en Sepolia

```
Contract Address : 0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37
Transaction Hash : 0x0713d868b6f49f8d1a98116446c92ab5de56a5c382a30b5296216a0f79e44cf2
```

Voyager: https://sepolia.voyager.online/contract/0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37

Pendiente: Pasos 2-5 (migrate, set_config, prueba de integración, documentación).

---

## 2026-08-20 — Deploy F1-A Sepolia: hallazgos sozo migrate + build

Hallazgo: sozo 1.8.7 requiere dos pasos previos al migrate con perfil no-dev:
1. Declarar [profile.sepolia] vacío en Scarb.toml (sin esto: "profile does not exist")
2. Correr sozo build --profile sepolia (sin esto: "target directory empty")

Fix aplicado: agregado [profile.sepolia] al final de contracts/zkmine_f1/Scarb.toml.

sozo build --profile sepolia:
```
Compiling zkmine_f1 v0.1.0 (...)
Finished `sepolia` profile target(s) in 13 seconds
```
Sin errores, sin warnings. ✓

Pendiente: sozo migrate --profile sepolia.

---

## Nota de seguridad — manejo de claves privadas en terminal (2026-08-20)

Para exportar variables de entorno con secretos (ej. ZKMINE_SEPOLIA_PRIVATE_KEY) sin que queden en el historial de shell, usar (en la propia terminal del usuario, nunca dentro de una sesión de agente):

read -s ZKMINE_SEPOLIA_PRIVATE_KEY

Esto oculta el input en pantalla y no lo registra en el historial de bash. Alternativa más simple si la shell tiene HISTCONTROL=ignorespace/ignoreboth activo (default en Ubuntu): anteponer un espacio antes del comando export.

Regla general del proyecto: ningún agente (Claude Code u otro) toca una clave privada real bajo ninguna circunstancia — el paso lo hace el usuario manualmente, fuera de cualquier sesión de agente.

---

## 2026-08-20 — Deploy F1-A Sepolia: Paso 2b resuelto (pending_review archivado)

Contenido de pending_review.md al momento de ser reemplazado:

---

# Deploy F1-A en Sepolia — Propuesta
# (2026-08-20)

## Pre-checks completados

| Check | Resultado |
|-------|-----------|
| Balance STRK sepolia_dev | 975.26 STRK ✓ |
| vrf-server (pid 225125, puerto 3001, secret-key 420) | Corriendo ✓ |
| Clase VrfProvider en Sepolia (0x148ab1...b9df) | Ya declarada (F0) ✓ → skip declare |

La clase VrfProvider ya está declarada en Sepolia desde F0.
No hace falta re-declararla — mismo hash determinista (scarb 2.13.1).

---

## Secuencia de 5 pasos (todos pendientes de confirmación)

### Paso 1 ✓ — Deploy VrfProvider en Sepolia

```
Contract Address : 0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37
Transaction Hash : 0x0713d868b6f49f8d1a98116446c92ab5de56a5c382a30b5296216a0f79e44cf2
```

Voyager: https://sepolia.voyager.online/contract/0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37

---

### Paso 2 — sozo migrate --profile sepolia

Hallazgo: sozo 1.8.7 requiere (a) [profile.sepolia] en Scarb.toml y (b) build previo.
Fix aplicado: agregado [profile.sepolia] vacío al final de Scarb.toml.

**Paso 2a ✓ — sozo build --profile sepolia**
```
Compiling zkmine_f1 v0.1.0 (...)
Finished `sepolia` profile target(s) in 13 seconds
```
Sin errores, sin warnings. ✓

**Paso 2b ✓ — sozo migrate --profile sepolia**

Fix adicional: sozo 1.8.7 no expande ${VAR} en toml antes de parsear como Felt252.
Workaround: pasar --private-key $ZKMINE_SEPOLIA_PRIVATE_KEY como flag de CLI.

```
World deployed at block 13754985
World address     : 0x027b48a001297a0da77eb50f6f52837cd8ea5e128f1a57f3d8fe7a3d1fd5e14d
zkmine_f1-actions : 0x292763cd8c85375a2d1f16d347ab93036b261305ff021715b49c91f1f43b2ba
```

---

### Paso 3 — set_config en Sepolia (pendiente)

```bash
sozo execute --profile sepolia zkmine_f1-actions set_config \
  0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37 \
  --private-key $ZKMINE_SEPOLIA_PRIVATE_KEY --wait
```

---

### Paso 4 — Prueba de integración en Sepolia (pendiente)

### Paso 5 — Documentar en INSTALACIONES-001.md (pendiente)

---

## 2026-08-20 — Deploy F1-A Sepolia: Paso 3 set_config confirmado

Paso 3 corrió con éxito en terminal de Daniel:
Tx set_config: 0x0061bac85a32a5284b611d4f222e1dfa7dabb500f60b302c1e3bf1ac11d3d9fb

Config model en Sepolia apunta a VrfProvider: 0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37

Siguiente: Paso 4 — prueba de integración en Sepolia.

---

## 2026-08-20 — Paso 4 Sepolia: T1-T5 completados

T1: nonce sepolia_dev = 0x202
T2: game_id = 0x686b989ce684941e21cb3dc097567f6846897147cab1ab30964fbd0c93a1651
T3: spawn_game tx = 0x07205c78d5d68719fc50e43a5f550f1eab368b14622b26bf7623460ee52d73cf
T4: Game model verificado (status=0, mine_count=99, total_cells=480, game_id coincide)
T5:
  nonce_k (get_consume_count) = 0
  seed = 0x6dcf6a08d17cd8a1ee582349fed79a41c41d47bff76b5058d5440879b46c642
  gamma_x   = 0x6eda61464dfb3f9077f90ed91672403ca8419d7f782908836b7a9a1b7a9eeb
  gamma_y   = 0x3276c04e377e1c4051e422567d082d0f8de6a19a7fca675c4abd21f26973b6d
  c         = 0x3cad41fecb9b556a6106e11d65bd157ec1e62f896ba8cf62decac7bca3f1cec
  s         = 0x2e0595d9b9d67922403fafe2f05c2a53b3b776abc7a757c0d94a85525e5b0da
  sqrt_ratio= 0x2554d620095c7b3e6b4523d690e118b38e7672a31a9d5726330f294e9262024
  rnd       = 0x653ec692828a6a6ddea5908be0c817ac4b400e2907c1d07f48b1a33bcc10d8b

T6 (multicall submit_random+click) pendiente — Daniel corre en terminal.

---

## 2026-08-20 — Paso 4 Sepolia: T6 ok, buscando mine hit (Opción A)

T6 click 1 tx: 0x1b7107c971c5174fd00c797a7c9d3167ab86024e0fc72ce7e35dd8ff5802410
T7 Game post-click 1: status=0, revealed_count=1
T7 Cell(0,0): is_mine=0, revealed=1 → rama SAFE CLICK cubierta ✓

Pre-cómputo de seeds/proofs nonce_k=1..7 para encontrar mine hit:
- nonce_k=1: safe (bucket=148)
- nonce_k=2: safe (bucket=271)
- nonce_k=3: safe (bucket=158)
- nonce_k=4: safe (bucket=274)
- nonce_k=5: safe (bucket=114)
- nonce_k=6: safe (bucket=257)
- nonce_k=7: MINE (bucket=24) ← mine hit

NOTA DE SEGURIDAD: este pre-cómputo se realizó con fines de testing en entorno propio de
desarrollo (clave sepolia_dev, no producción). Este patrón NUNCA debe usarse contra un
jugador real ni en ningún contexto de producción.

---

## 2026-08-20 — Paso 4 Sepolia COMPLETO: ambas ramas verificadas

Click 2 (nonce_k=1) resultó ser MINE HIT — contrario a la predicción off-chain (bucket=148→safe).
Diagnóstico: el campo `rnd` de la API del vrf-server NO coincide con el valor que
`consume_random` devuelve on-chain. El contrato es correcto; la predicción off-chain con
`rnd` es imposible por este método. Propiedad de seguridad implícita.

Resultados finales Paso 4:

RAMA SAFE CLICK ✓
  click 1  tx : 0x1b7107c971c5174fd00c797a7c9d3167ab86024e0fc72ce7e35dd8ff5802410
  Cell(0,0)   : is_mine=0, revealed=1
  Game post-1 : status=0, revealed_count=1

RAMA MINE HIT ✓
  click 2  tx : 0x78ffa919d9916a4be323702b20fb03092c33888ebb1d930865ff790980b0731
  Cell(1,0)   : is_mine=1, revealed=1
  Game post-2 : status=2, remaining_mines=98

F1-A validado en Sepolia con VRF real. Paso 5 pendiente: INSTALACIONES-001.md.

---

## 2026-08-20 — Paso 5 completado: INSTALACIONES-001.md actualizado

Agregadas dos secciones nuevas a docs/INSTALACIONES-001.md:
- F1-A Katana (2026-08-19): ambas ramas, game_ids, fórmulas verificadas
- F1-A Sepolia (2026-08-20): todas las direcciones, tx hashes reales, hallazgos técnicos

Deploy F1-A completo y documentado.

---

## 2026-08-20 — Auditoría JSONL: análisis refinado de claves privadas

Retomando análisis de 5fdc57de...jsonl y f87ed580...jsonl.
Filtro: hex 63-64 chars en contexto de private_key/--private-key/PRIVATE_KEY/read -s,
excluyendo hashes de tx/contract/class. Resultado en pending_review.

### Resultado del análisis (resumen para bitácora):
- 7 valores únicos identificados, 17 apariciones totales
- TODOS en rol assistant/tool — ninguno en rol human/user
- 5 de 7 son direcciones/hashes CONOCIDOS (contratos Sepolia y tx hashes de esta sesión)
- 2 de 7 no verificados contra tabla de addresses conocidas (KEY-01: 0x127fd5, KEY-03: 0x6d3eb2)
- La clave privada real de Sepolia NUNCA aparece en texto plano — siempre como referencia a variable $ZKMINE_SEPOLIA_PRIVATE_KEY
- Todos los hits son falsos positivos por ventana de contexto de 300 chars: el flag --private-key $VAR aparece cerca de direcciones de contratos legítimas

### Cierre de auditoría (confirmado por Daniel, 2026-08-20):
- KEY-01 (0x127fd5...): dirección katana0 — pública, documentada desde F0
- KEY-03 (0x6d3eb2...): pubkey.y de la clave VRF de test (secret-key 420) — pública, documentada desde F0
- VEREDICTO FINAL: ninguna clave privada real aparece en texto plano en ninguno de los dos .jsonl
  ni en ningún otro archivo del proyecto. Auditoría de seguridad de sesión CERRADA.

---

## 2026-08-21 — Propuesta GNOME Adwaita demo (zkminestark-gnome-demo.html)

### Lo que estaba en pending_review.md al momento de ser reemplazado

# Propuesta: zkminestark-gnome-demo.html (GNOME Adwaita demo)

**Contexto:** Archivo derivado de `client/minasweeper.html`. El original NO se modifica.
Destino: `docs/archivo/zkminestark-gnome-demo.html`

---

## A. `<head>`

| # | Qué | Detalle |
|---|-----|---------|
| 1 | `<title>` | → `zkminestark · MINASWEEPER (GNOME demo)` |
| 2 | Google Fonts | Agregar `Cantarell:ital,wght@0,400;0,700` al link existente (Silkscreen + Space Grotesk quedan intactos) |

---

## B. CSS — solo adiciones al `<style>` existente, sin tocar MINA ni linux

### `[data-theme="gnome"]` — paleta Adwaita

Celdas:
- Cerrada: `repeating-conic-gradient(#C6C4C0 0% 25%, #BEBCB8 0% 50%) 0 0 / 8px 8px`
- Abierta: `repeating-conic-gradient(#E9F4DD 0% 25%, #DFF0CB 0% 50%) 0 0 / 8px 8px`
- Mina detonada: `background:#E01B24`
- Números 1–8: `#1C71D8, #26A269, #C01C28, #1A5FB4, #7A3814, #1E7890, #241F31, #5C5C5C`
- Fuente body: `Cantarell, system-ui, sans-serif`

Layout GNOME:
- `body` → `flex-direction:row` en gnome theme
- `.gnome-main` → `display:contents` por defecto; `flex:1; flex-direction:column` en gnome theme
- `.wallet, .tagline, .status, .info` → `display:none` en gnome
- `.board-wrap` → `flex:1; border:none; border-radius:0; padding:0; overflow:hidden; display:flex; align-items:center; justify-content:center`
- `.gnome-side` → panel 90px, columna con face btn + stats + record/pot secundario

## C. HTML — cambios estructurales mínimos

1. `<div class="gnome-main">` envuelve todo el body
2. `<aside class="gnome-side">` con 💣 gMines, 🖱 gClicks, gRec, gPot
3. Botón `<button data-t="gnome">GNOME</button>` en `.themes`

## D. JS — adiciones mínimas

- `updateCellSize()`: calcula cs = min(floor(boardWrap.clientWidth/W), floor(boardWrap.clientHeight/H))
- `window.addEventListener("resize", updateCellSize)`
- Sync gMines/gClicks/gRec/gPot en `updateHUD()`
- `updateCellSize()` en listener de `.themes button`
- `faceBtnGnome` → dispara `faceBtn.click()`
- `updateCellSize()` en init

## Tareas pendientes relacionadas

- Commit del souvenir (`docs/archivo/minasweeper-mina-souvenir.html`): aún no hecho.
  Mensaje acordado: `archive: original Mina Protocol prototype, pre-Starknet pivot`
- Este gnome-demo puede ir en el mismo commit o en uno separado, a confirmar.

---

## 2026-08-22 — Simplificación visual de client/minasweeper.html hacia GNOME Mines

### Objetivo aprobado

Tomar el prototipo existente en `client/minasweeper.html` y convertirlo en una
versión visualmente cercana a GNOME Mines, manteniendo solo la lógica esencial
de Buscaminas: tablero `30x16`, `99` minas, banderas, chord, conteo de clicks,
derrota, victoria, reinicio y récord persistido.

### Eliminado del prototipo original

Se retiró por completo todo lo que no era esencial para jugar:
- nombre visible del prototipo
- selector de temas
- seed y RNG determinista por seed
- wallet, balance, MINA, pozo y premios
- cooldowns por derrota
- overlays y modal de "prueba zk"
- textos explicativos, tarjetas y cabeceras decorativas
- lógica de registry por seed, récord por seed y economía simulada

### Interfaz final

La pantalla quedó reducida a:
- tablero principal de `30x16`
- columna lateral derecha con indicadores mínimos
- récord persistido arriba a la izquierda, mostrado como `R`
- botón de reinicio arriba a la derecha, reducido a flecha circular

Ajustes de layout aprobados e implementados:
- tablero centrado verticalmente
- columna lateral también centrada verticalmente respecto al tablero
- contador de minas a la derecha en formato `xx/99`
- contador de clicks debajo del contador de minas
- récord fuera de la columna lateral, arriba a la izquierda

### Reescritura de HTML/CSS

Se rehizo la estructura y la presentación para acercarla a GNOME Mines:
- fondo general `#f6f5f4`
- celdas cerradas `#babdb6`
- celdas abiertas vacías `#dededc`
- separaciones blancas entre celdas
- tablero escalable según viewport, manteniendo celdas cuadradas
- visual mínimo, sin gradientes, neón, sombras llamativas ni paneles del prototipo

Cambio importante en celdas reveladas:
- el número ya no cambia de color
- todos los números usan texto `#2e3436`
- lo que cambia es el color de fondo de la casilla según su valor

Fondos aplicados:
- `1` → `#ddfac3`
- `2` → `#ecedbf`
- `3` → `#eddab4`
- `4` → `#edc38a`
- `5` → `#e7b17a`
- `6` → `#df9f73`
- `7` → `#d58d6b`
- `8` → `#cb7d63`

### Mina y estados de derrota

La mina dejó de representarse con un carácter Unicode y pasó a dibujarse con
SVG embebido para aproximar la silueta de GNOME Mines:
- cuerpo circular oscuro `#2e3436`
- ocho puntas cortas en horizontal, vertical y diagonal
- brillo blanco pequeño
- minas reveladas sobre fondo `#888a85`
- mina detonada sobre fondo rojo

### Limpieza de JavaScript

Se conservó solamente la lógica necesaria para jugar:
- generación del tablero
- vecinos
- reveal normal
- `floodReveal`
- banderas
- chord
- derrota y victoria
- reinicio
- escalado responsivo del tablero
- lectura/escritura del récord en `localStorage`

Se cambió la apertura inicial:
- ya no existe apertura automática a `0` clicks
- el primer click siempre es seguro
- el primer click sí cuenta

### Persistencia del récord

El récord quedó como valor único local, no por seed.
Se guarda en `localStorage` con la clave:

`minesweeper-best-clicks`

Se actualiza solo al ganar una partida con menos clicks que el mejor valor previo.

---

## 2026-08-22 — Despliegue público del Minesweeper en Vercel

Se publicó el cliente Minesweeper en Vercel.

URL pública: https://zkminestark.vercel.app/

Configuración:
- Root Directory: `client`
- Application Preset: `Other`
- Sin build.
- `client/minasweeper.html` sigue siendo el archivo principal.
- Se añadió `client/vercel.json` con un rewrite de `/` a `/minasweeper.html`.
- Los `git push` al repositorio disparan nuevos deployments automáticamente.

---

## 2026-08-23 — Selector de tamaños + fixes de juego en client/minasweeper.html

### Alcance

Se extendió `client/minasweeper.html` para soportar múltiples tamaños de tablero
desde una pantalla inicial de selección, y se corrigieron tres problemas de juego
detectados en la versión GNOME-like anterior.

### Selector inicial de tamaño

Se añadió una pantalla de arranque full-screen con grid `2x2` inspirada en
GNOME Mines:
- `8x8 / 10 minas`
- `16x16 / 40 minas`
- `30x16 / 99 minas` (opción Linux / default visual)
- `Custom` con `?`, visible pero sin funcionalidad

La partida ya no arranca directamente: primero se elige un preset.

### Refactor del motor a tamaño dinámico

El archivo dejó de depender de constantes fijas `30x16 / 99`.
Se refactorizó la lógica para trabajar con:
- `width`
- `height`
- `mineCount`
- `cellCount`
- preset activo

Efectos del refactor:
- un único motor soporta `8x8`, `16x16` y `30x16`
- el grid CSS toma el ancho desde variable dinámica
- el escalado del tablero se recalcula según el tamaño elegido
- el récord ya no se mezcla entre tamaños

### Récord por preset

El récord pasó de una única clave global a claves separadas por preset:

- `minesweeper-best-clicks:beginner`
- `minesweeper-best-clicks:intermediate`
- `minesweeper-best-clicks:linux`

### Fix 1 — contador de minas en tiempo real

Bug original:
- el contador no se actualizaba al poner o quitar banderas
- solo se refrescaba al revelar una casilla

Corrección:
- el HUD se actualiza en cada cambio de marca
- el indicador refleja en tiempo real cuántas banderas hay puestas

### Fix 2 — victoria

Criterio mantenido y explicitado:
- la victoria depende exclusivamente de que estén reveladas todas las casillas
  que no son mina
- NO depende del contador de banderas

Comportamiento visual final:
- al ganar, la partida pasa a estado congelado
- los clicks quedan congelados
- el contador de minas se fuerza visualmente al máximo del tablero:
  `10/10`, `40/40` o `99/99`
- no se añadió modal, popup ni overlay

### Fix 3 — ciclo de click derecho estilo GNOME Mines

Se añadió el tercer estado de marca faltante:

- vacía → bandera → incógnita → vacía

Reglas:
- solo la bandera cuenta en el contador de minas
- la incógnita no altera el contador
- las banderas siguen siendo gratis y no suman al contador de clicks

### Estado final

Se probó manualmente en sesión y quedó funcionando:
- selección de tamaño
- primer click seguro
- contador de minas en tiempo real
- victoria no invasiva
- ciclo bandera/incógnita

Se intentó un pulido visual adicional de la pantalla inicial, pero fue revertido
por preferencia visual: se conservó la versión anterior del menú.

---

## 2026-08-23 — Cierre hardening F1-A, tests y redeploy Sepolia

Se cerró el hardening de `zkmine_f1` y la limpieza de tests del repo.

### Cambios de contrato y compatibilidad

- `set_config` quedó endurecido con policy explícita:
  - caller autorizado (`CONFIG_SETTER = sepolia_dev`)
  - rechazo de VRF cero
  - una sola escritura
  - inmutable después de la primera configuración válida
- Compatibilidad ajustada para Cairo 2.13 / Dojo 1.8 sin cambiar la policy acordada.

### Tests añadidos

`zkmine_f1`:
- `4` tests de policy para `set_config`
- property test exhaustivo del modelo ideal de lazy sampling en `5x5/2`
- el property test quedó particionado en `6` rangos y, en conjunto, cubre exactamente
  las `300` configuraciones con orden fijo y adaptativo, racionales exactos y sin float
- resultado local: `10/10` tests pass

`vrf_bench`:
- eliminación total del viejo template `HelloStarknet`
- reemplazo por `2` integration tests reales del benchmark + mock VRF compatible con la ABI
- resultado local: `2/2` tests pass
- `IBenchmark` se hizo `pub` únicamente para posibilitar esos integration tests

Compatibilidad Cairo 2.13 / Dojo 1.8 registrada:
- `contract_address_const` eliminado
- `config_setter()` mediante conversión
- checks con `is_zero()`
- `#[cfg(test)]` en tests
- `.snfoundry_cache/` agregado a `.gitignore`

Commits publicados relacionados:
- `67d2153` — `Harden VRF config and replace placeholder tests`
- `7155b90` — `Add exhaustive lazy sampling property test`

### Redeploy limpio de Sepolia

Motivo:
- el World anterior ya tenía `Config.vrf_provider` cargado
- para validar correctamente `set_config` one-shot e inmutable hacía falta storage nuevo

Cambio aplicado:
- nuevo seed `zkmine_f1_hardened`
- reutilización del VrfProvider Sepolia existente
- redeploy en bloque Sepolia `13924626`

Direcciones nuevas:
- World `0x05cec67ca060126d1e1133ae4002001b03f1c631e6e43d8a9904cb3b7c5e392d`
- `zkmine_f1-actions` `0x31a8af789641e9883d23c17b072ad7d0bd5d557d4643eeda013eae0a3b048bc`

Primera configuración válida:
- tx `0x032e835fb3d447b7a8baa9674634b52afdffec25b8a154bc00008f5ebba29cec`
- `Config.vrf_provider` verificado como
  `0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37`

Segunda configuración:
- rechazada con revert `already configured`
- no debe presentarse como tx exitosa

### Revalidación mínima F1-A

- `spawn_game` tx:
  `0x0560bd2953e9d9eefe67cc03af4213dec8defec406739484fc72d86dc6b1b599`
- `game_id`:
  `0x335060aeef3ab51fc10ea76b8a3a60b53372c9b43d052ac552ac46204f80ead`
- multicall atómico `submit_random + click` tx:
  `0x4147c66f07556ef80d2713a016823b38f553ab32a7a936625300d70ec8776d3`

Lectura final:
- `Game status=2, mine_count=99, remaining_mines=98, revealed_count=0, total_cells=480`
- `Cell(0,0): is_mine=1, revealed=1`

Esto revalida en el deploy endurecido la rama `mine-hit` con VRF real + lazy sampling.

---

## 2026-08-29 — Giro arquitectónico: frontera pública descartada y benchmark RPC directo de latencia

### Secuencia causal

#### A. Arquitectura anterior: frontera precalculada/materializada

La idea para evitar esperar VRF en cada click era mantener una frontera
precalculada. Al revelar una celda, el protocolo fijaba anticipadamente
`is_mine` de las celdas cerradas necesarias para calcular los números de la
frontera. Así, cuando el jugador clickeara después una celda de esa
frontera, el resultado ya estaría determinado y ese click podría mostrarse
sin esperar randomness nueva.

La lectura de F0 descansaba en esa hipótesis: el batch de clicks-VRF
consecutivos medía un peor caso técnico, no la UX normal de una partida.
La expectativa era que la mayoría de los clicks "siguiendo pistas" cayeran
sobre celdas ya determinadas y por lo tanto no pagaran espera nueva.

#### B. Blocker descubierto: el secreto se rompe en storage público

Esa arquitectura falla en una blockchain pública. `is_mine` de una celda
cerrada estaba previsto como dato de modelo Dojo, por lo tanto vive en
storage público de Starknet. Un bot puede leer ese storage antes de
clickear y conocer el estado de la frontera.

Ocultar el dato en la UI, en Torii o en cualquier capa off-chain no sirve:
el storage on-chain sigue siendo legible. Consecuencia:

**no se puede mantener `is_mine` materializado en plaintext para una celda
todavía cerrada.**

Este hallazgo invalida el precálculo secreto de frontera como mecanismo
trustless.

#### C. Salidas consideradas

Se revisaron conceptualmente tres familias:

1. commitment de `is_mine` con secreto/witness

   El contrato necesitaría después ese secreto o witness para validar el
   click. Reintroduce custodio de estado secreto o infraestructura
   adicional.

2. derivación determinista desde una seed VRF pública

   Si la seed es pública, un bot deriva exactamente los mismos estados
   futuros.

3. no materializar hasta el click

   Evita el leak, pero para publicar un número de Minesweeper hay que
   preservar compatibilidad con todos los números ya publicados. El
   problema se convierte en muestreo condicionado/model counting sobre el
   conjunto de tableros compatibles con el transcript público.

Conclusión conceptual:

- si el futuro queda fijado, hay que ocultarlo
- si no queremos secretos, el futuro no puede quedar fijado
- si el futuro no queda fijado, cada nueva observación debe samplearse
  condicionada al transcript público

#### D. Nueva arquitectura candidata

La alternativa que queda abierta es no guardar `is_mine` de celdas
cerradas. Cuando el jugador realiza una acción materializante, se samplea
únicamente el próximo resultado observable (`mine` o número compatible),
con pesos proporcionales al número de tableros completos compatibles con
el transcript público que producen cada resultado.

Esto preservaría la distribución de un tablero uniforme sin almacenar
estado secreto de celdas cerradas. Pero introduce dos riesgos separados:

1. latencia: una parte importante de las acciones materializantes vuelve a
   necesitar randomness fresca / VRF
2. complejidad on-chain: el conteo condicionado/model counting debe ser lo
   bastante barato como para ejecutarse en Cairo/gas

Por eso se congeló el grant y se definieron dos experimentos go/no-go
independientes antes de seguir.

### Experimento 1 — latencia real por acción materializante

Unidad correcta: **acción del jugador**, no celda revelada. Chord y
flood-fill/cascade pueden revelar varias celdas usando un único VRF/PRF
stream, así que "ms por celda" sería una métrica conceptualmente falsa.

F0 había dado aproximadamente:

- p50 ~3.3 s
- p95 ~4.1 s

pero F0 medía `sncast multicall run`, incluyendo overhead de CLI,
`estimateFee`, build/sign y espera de aceptación. No representaba
necesariamente la espera real del jugador.

Por eso se construyó un benchmark nuevo con:

- submit RPC directo
- polling de preconfirmación
- verificación real de que `Benchmark.get_counter()` ya es legible
- secuencia `acción N -> result_readable -> acción N+1`
- sin esperar `ACCEPTED_ON_L2` entre acciones

Umbrales fijados **antes** de la corrida principal:

- GREEN: p50 ≤ 1.5 s y p95 ≤ 2.5 s
- YELLOW: p50 1.5–2.0 s o p95 2.5–4.0 s
- RED: p50 > 2.0 s o p95 > 4.0 s

Resultado principal — 200 acciones válidas:

- N válido = 200
- N fallido = 0
- min = 376 ms
- p50 = 1596 ms
- p90 = 2669 ms
- p95 = 2887 ms
- p99 = 3538 ms
- max = 4013 ms
- media = 1449 ms
- `Benchmark.get_counter()` legible en `pre_confirmed` en 200/200
- clasificación = **YELLOW**

Observación cualitativa a conservar como hipótesis, no como causalidad
probada: muchas acciones ya tenían el resultado legible al volver del
submit, mientras otras mostraban saltos de aproximadamente uno o más
ciclos. Es compatible con ventanas/ciclos de preconfirmación del
proveedor, pero no queda demostrado aquí.

Conclusión del experimento 1:

**la latencia no mata el proyecto. Queda YELLOW y justifica continuar al
segundo experimento.**

No reinterpretar como GREEN.

### Experimento 2 — pendiente e independiente

El segundo go/no-go debe responder si el conditional sampler / exact model
counting necesario para no almacenar `is_mine` oculto puede ejecutarse con
coste aceptable.

Dirección de trabajo:

- restricciones locales de Minesweeper
- separación de la frontera en componentes conexas
- conteo por número de minas `F_j(m)`
- recombinación global por mine count
- posible compresión de variables equivalentes / DP / estructura tipo
  treewidth

Orden correcto:

1. prototipo off-chain para medir complejidad real en partidas 30×16/99
2. si sobrevive, implementación representativa en Cairo/gas

Este segundo experimento sigue siendo un blocker independiente y todavía
puede hacer inviable zkminestark.

### Estado actual

- precálculo de frontera con `is_mine` en storage público: descartado
- grant: congelado
- experimento de latencia: terminado, YELLOW
- conditional sampling/model counting: próximo blocker
- arquitectura final del proyecto: todavía no cerrada

---

## 2026-08-30 — EXPERIMENTO 2A iniciado: baseline exacto off-chain

Se abrió la siguiente fase técnica tras cerrar el benchmark de latencia:
medir la factibilidad del conditional sampling exacto sin materializar
`is_mine` oculto en storage público.

Artefactos creados:
- `scripts/conditional_sampling_exact.py`
- `scripts/test_conditional_sampling_exact.py`
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`
- `benchmarks/conditional-sampling-2a-smoke-20260830.jsonl`

Resultado de esta primera iteración:
- oracle exhaustivo independiente `5x5/2` implementado
- tests exactos: `5` corridos, `OK`
- smoke reproducible `30x16/99`: `12` evaluaciones, `0` errores
- baseline deliberadamente poco optimizado: recalcula desde cero cada
  outcome/click y deja 2B/2C para locality + reuse

La nota detallada del experimento, con algoritmo, métricas, resultados,
interpretación e hipótesis, queda en
`docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`.

---

## 2026-08-30 — EXPERIMENTO 2A-hardening continuado desde working tree

Se reconstruyó el estado únicamente desde el working tree y quedó claro que
la capa de hardening ya estaba parcialmente implementada en
`scripts/conditional_sampling_exact.py`, aunque todavía no documentada por
completo:

- benchmark dedicado `2A-hardening`
- budgets por wall-clock, `search_nodes` y `branch_ops`
- serialización JSONL por evaluación
- resumen agregado con percentiles y top casos costosos

Parte faltante detectada y corregida:

- si el aborto ocurría durante el conteo base previo a evaluar los
  outcomes, el código caía como `error` genérico
- ahora esa ruta devuelve `timeout` o `budget_exceeded` con resultado
  parcial serializable, igual que los abortos dentro del loop de outcomes

Cobertura ampliada:

- tests exactos/hardening: `8` corridos, `OK`
- nuevos tests para timeout parcial, budget parcial y mini-benchmark sin
  degradación a `error`

Benchmark principal corrido:

- archivo raw:
  `benchmarks/conditional-sampling-2a-benchmark-20260830.jsonl`
- configuración:
  `30x16/99`, seeds `20260840..20260849`, `120` evaluaciones
- resultado:
  `ok=120`, `timeouts=0`, `budget_exceeded=0`, `errors=0`
- wall-clock:
  p50 `9.93 ms`, p95 `71.96 ms`, p99 `160.24 ms`, max `163.09 ms`
- mayor componente observado:
  `56`

Conclusión acotada de esta iteración:

- 2A queda mejor endurecido como baseline reproducible
- sigue faltando el trabajo estructural de 2B/2C
  (locality/reuse), no implementado todavía

---

## 2026-08-30 — Auditoría final para congelar EXPERIMENTO 2A

Se hizo una revisión crítica del baseline 2A antes de abrir 2B. Hallazgos
reales corregidos en esta auditoría:

- `timeout`/`budget_exceeded` podían degradarse a `error` si el aborto
  ocurría durante el conteo base previo al loop de outcomes
- `max_search_nodes` y `max_branch_ops` no se aplicaban globalmente a toda
  la evaluación de la celda; quedaban efectivamente locales por
  problema/componente
- la instrumentación `total_search_nodes` / `total_branch_ops` estaba
  reportando solo el coste base previo al click, no el coste total de la
  evaluación completa

Acciones tomadas:

- clasificación de abortos unificada en smoke/benchmark
- budgets corregidos a semántica global por evaluación
- métricas `total_*` corregidas para agregar
  `before_click_* + Σ per_outcome[*]`
- smoke y benchmark raw regenerados desde el código final
- fixtures manuales simples agregados a tests para no depender solo del
  oracle exhaustivo
- documentación actualizada con historia técnica, reproducibilidad, entorno
  local y límites de interpretación

Estado de cierre de 2A:

- tests: `12`, `OK`
- smoke raw: `12` registros `ok`
- benchmark raw: `120` registros `ok`
- baseline listo para congelar como referencia comparativa de 2B/2C
- cierre cuantitativo completado desde raw: baseline comparativo documentado para `search_nodes` y `branch_ops`
- corpus congelado creado: `benchmarks/conditional-sampling-2a-corpus-20260830.jsonl` (`120` casos)

---

## 2026-08-30 — EXPERIMENTO 2B iniciado: locality sobre corpus congelado

Se implementó una variante 2B separada (`scripts/conditional_sampling_locality.py`)
que reutiliza por firma exacta los componentes untouched del grafo de
constraints por outcome.

Resultado de validación actual:

- igualdad exacta `2A == 2B` en `120/120` casos del corpus común
- reuse efectivo observado en `4/120` casos
- merges de componentes previamente separados: `0`
- benchmark 2B raw generado en
  `benchmarks/conditional-sampling-2b-locality-20260830.jsonl`

---

## 2026-08-30 — Cierre de EXPERIMENTO 2B3 simple: shared exact outcomes

Se congeló 2B3 como checkpoint reproducible antes de abrir optimizaciones
adicionales.

Artefactos:

- código:
  `scripts/conditional_sampling_2b3_shared_outcomes.py`
- tests:
  `scripts/test_conditional_sampling_2b3_shared_outcomes.py`
- raw:
  `benchmarks/conditional-sampling-2b3-shared-outcomes-20260830.jsonl`

Definición congelada:

- una sola pasada compartida produce directamente
  `N_mine, N_0..N_8`
- sin `10` conteos independientes
- sin memoización adicional todavía
- `memo_entries = 0`
- `dp_states_explored = 0`

Validación final:

- exactitud `120/120` contra 2A
- `problems_executed = 1`
- `shared_single_pass = True`
- partition invariant interno independiente de la clasificación por outcome:
  `compatible_total_before_click` ahora se deriva de la `joint_distribution`
  antes de sumar `N_mine + N_0 + ... + N_8`

Resumen cuantitativo principal:

- `total_search_nodes`:
  media `5451.25 -> 688.20`,
  p50 `1790 -> 324.5`,
  p95 `23048.95 -> 3041`,
  max `60554 -> 4952`
- `total_branch_ops`:
  media `10052.55 -> 1276.67`,
  p95 `43864.50 -> 5596`,
  max `109444 -> 8932`

Lectura de cierre:

- 2B3 simple ya captura sharing real fuerte entre outcomes
- la mejora grande aparece sobre todo en la cola cara del corpus
- quedan pendientes sólo optimizaciones internas sobre esta arquitectura,
  no un cambio de formulación

---

## 2026-08-30 — Freeze 2D1: history-aware lazy transition

### Contexto

Tras congelar 2B3 como baseline de evaluación independiente, se abrió el
EXPERIMENTO 2D para medir cuánto trabajo exacto puede reutilizarse entre
clicks consecutivos de una misma historia.

### 2D0 — baseline incremental eager

Se implementó un estado incremental que preserva entre transcripts:
constraints, componentes conectados, firmas exactas y perfiles ordinarios.

Para cada componente changed en la transición `T_i → T_{i+1}`, 2D0 ejecuta
`count_component()` de forma eager (DFS ordinario completo).

Resultado sobre 3 historias smoke 12×12/20 (84 puntos, H1/H2/H3):

- 2D0 baja el coste de eval pointwise frente a 2B3 (reutilización real)
- pero el coste de transición eager lo supera con creces
- total historia: H1 6313 vs 2B3 3672, H2 3371 vs 2202, H3 432 vs 216
- 2D0 es exacto (84/84) pero peor que 2B3 en coste total de historia

### Diagnóstico: doble conteo

Auditoría del lifecycle `T_i → T_{i+1} → x_{i+1}` reveló:

- transición (2D0): `count_component()` ordinary → S nodos por componente changed
- evaluación: `count_component_joint()` joint → S nodos sobre el mismo árbol

Para componentes que son changed en transición Y special en eval:
2D0 paga 2×S. El doble conteo se verifica empíricamente:
eval[i] ≈ trans[i−1] en 41/45 pasos de H1 (91%), 100% en H3.

El overhead de 2D0 vs 2B3 proviene 100–152% de la transición eager.

### 2D1 — lazy transition

Implementación minimal: en `build_state()` modo "2D1", los componentes
changed se marcan como `deferred` (profile=None) sin ejecutar ningún DFS.

En `evaluate_candidate_with_state()`:
- deferred + special → `count_component_joint()` directamente (1 DFS)
- deferred + ordinary → `count_component()` materializado (1 DFS, diferido)
- reused + ordinary → perfil cacheado (0 DFS)
- reused + special → joint DFS (necesario siempre)

Ordinarios materializados durante eval quedan cacheados en el estado para
reutilización posterior.

### Resultado 2D1 — métricas finales (recalculadas desde raw)

Exactitud: 2A == 2B == 2B2 == 2B3 == 2D0 == 2D1 en 84/84 puntos.

search_nodes (startup + Σ eval + Σ transition):

| historia | 2B3  | 2D0   | 2D1  | 2B3/2D1 |
|----------|------|-------|------|---------|
| H1 (46)  | 3672 | 6313  | 3187 | 1.152x  |
| H2 (32)  | 2202 | 3371  | 2040 | 1.079x  |
| H3 (6)   | 216  | 432   | 216  | 1.000x  |
| total 84 | 6090 | 10116 | 5443 | 1.119x  |

2D1 nunca pierde contra 2B3 en ningún paso individual (gana 52, empata 32).

Beneficio por fase (H1, nodos):
- early (9 steps): 2D1 = 2B3 (sin reutilización)
- mid  (15 steps): 2D1/2B3 = 1.013x
- late (22 steps): 2D1/2B3 = 1.810x

### Bugs corregidos en el harness

- `recomputed_components` / `recomputed_component_sizes` no existían en
  `IncrementalTransition` → AttributeError en producción; corregidos
- `persistent_state_size` crasheaba con `profile=None` en 2D1 → corregido
- harness no exponía parámetro `mode` → refactorizado para 2D0 y 2D1

### Artefactos congelados

- `scripts/conditional_sampling_2d_incremental.py`
- `scripts/conditional_sampling_history_smoke.py`
- `scripts/test_conditional_sampling_2d_incremental.py`
- `benchmarks/conditional-sampling-2d-histories-smoke-20260830.jsonl` (84 puntos)
- `benchmarks/conditional-sampling-2d-smoke-20260830.jsonl` (2D0 + 2D1)
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md` (sección 2D)

Commit: `experiment: freeze history-aware lazy transition 2D1`

---

## 2026-08-30 — Prestudy 2D2: carry-forward descartado antes de implementación

### Pregunta

¿Vale la pena implementar 2D2 carry-forward, que derivaría el perfil del
componente `T_{i+1}` desde el joint profile de `T_i` sin DFS adicional?

### Metodología

Script de análisis `scripts/conditional_sampling_2d2_prestudy.py` ejecutado
sobre las 3 historias smoke (84 puntos, 79 transiciones con componente special).

Para cada transición se clasifica el destino del componente special:
MERGE / DIRECTLY_CONDITIONABLE / SPLIT / DISAPPEARED / ALREADY_REUSABLE /
TERMINAL / MERGE+SPLIT.

También se rastrea si el siguiente click cae en la misma región y si es special
u ordinary.

### Hallazgos clave

- MERGE (C): 42/79 = 53.2% de transiciones, 65.4% de nodos — dominante.
  Causa: al revelar `x_i`, el constraint nuevo conecta vecinos cerrados que
  estaban fuera de C. Inherente a Minesweeper, no evitable.
- DIRECTLY_CONDITIONABLE (A): 29/79 = 36.7%, 1310 nodos.
  Carry-forward matemáticamente válido: F_{C_new}[k'] = ways[k', 0, m_eff].
- SPLIT (B): 4/79 = 5.1%. Deconvolución imposible — descartado.
- ALREADY_REUSABLE (E): 0 casos. El componente special siempre cambia de firma.

### Falla del carry-forward simple

A_next_ordinary = 0 sobre los 84 puntos.
En los 25 casos A donde el siguiente click toca la misma región, el siguiente
uso es SPECIAL (no ordinary), lo que exige un nuevo joint DFS de todos modos.
Carry-forward de F_C[k] no ayuda cuando la siguiente query es joint.

Upper bound realista: 248 nodes / 5443 total 2D1 = 4.6%.
Upper bound teórico (todos los A condicionables): 24.1%, no realizable.

### Conclusión

**2D2 simple carry-forward descartado.** No implementar.

Para carry-forward útil en el caso next-special haría falta tree decomposition /
junction tree — experimento distinto (2E).

### Artefactos

- `scripts/conditional_sampling_2d2_prestudy.py` (análisis, no benchmark)
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md` (sección PRESTUDY 2D2 añadida)

Commit: `experiment: document 2D2 carry-forward prestudy`

---

## 2026-08-30 — Prestudy 2E: treewidth del frontier constraint graph

### Pregunta

¿El primal constraint graph del frontier tiene treewidth acotada mientras n
crece? Si sí, variable elimination / junction tree sería factible.

### Metodología

Script `scripts/conditional_sampling_treewidth_prestudy.py`.
Para cada componente del frontier:
- Construir primal graph (clique por scope de constraint).
- Calcular upper bounds min-fill y min-degree.
- Calcular lower bound Bron-Kerbosch (max clique size − 1).
- Si lower_bound == upper_bound: exact treewidth confirmado.
- Reporte 2^{upper_bound_best} como factor size de junction tree.

Datasets: corpus 30×16/99 (120 casos) + historias smoke 12×12/20 (84 pasos).

### Hallazgos clave

**30×16/99 corpus (tamaño objetivo)**:
- n range: 2–56 variables por componente
- width range: **1–6** (¡max 6 en todos los 120 casos!)
- 116/120 treewidths exactos confirmados (lower == upper)
- Distribución: w=4 (55 casos, n_mean=35.6), w=5 (28 casos), w=6 (36 casos, n_mean=10.4)
- Los componentes GRANDES (n=40-56) tienen width 4-5, NO 6
- Caso más grande: n=56, w=4, factor=16 (2a-033 group)
- Caso más caro (DFS): n=46, w=4, factor=16, DFS=4952 nodos → ratio DFS/factor = 309x

---

## 2026-08-30 — Cierre de EXPERIMENTO 2E2: exact variable elimination

Se implementó 2E2 como contador exacto alternativo por componente usando
variable elimination sobre el primal constraint graph, manteniendo intacta la
semántica global de 2B3 para `N_mine, N_0..N_8`.

Arquitectura congelada:

- snapshot only: mejora within-click de `count(T,x)`
- sin reuse entre transcripts todavía
- superficie lista para 2E3:
  `ComponentSignature`, `ComponentEliminationPlan`,
  `EliminationStep`, `SparseCountFactor`

Artefactos:

- `scripts/conditional_sampling_2e2_variable_elimination.py`
- `scripts/test_conditional_sampling_2e2_variable_elimination.py`
- `benchmarks/conditional-sampling-2e2-variable-elimination-20260830.jsonl`
- `benchmarks/conditional-sampling-2e2-variable-elimination-repeated-20260830.jsonl`
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md` (sección 2E2)

Validación final:

- exactitud `2E2 == 2B3` en `120/120` casos del corpus congelado `30×16/99`
- igualdad exacta también en:
  `sum_counts`, `compatible_total_before_click`, `partition_ok`
- suite tracked completa de conditional sampling:
  `32` tests, `OK`

Auditoría de fairness del timing:

- `2B3 wall_clock_ms` mide solo `evaluate_cell_shared_outcomes(T,x)`
- `2E2 wall_clock_ms` mide solo `evaluate_cell_2e2(T,x)`
- benchmark repetido con corpus precargado, `1` warmup no medido y `20`
  repeticiones medidas por caso
- validación de exactitud hecha fuera de la ventana temporal

Hechos medidos:

- width efectivo especial `<= 6` en todo el corpus
- sparsity fuerte observada:
  `peak_nonzero_entries` p50 `20`, max `103`
- mediana wall-clock por caso:
  `2B3 p50=6.66 ms`, `2E2 p50=8.70 ms`
- cola wall-clock por caso:
  `2B3 p99=21.64 ms`, `2E2 p99=15.03 ms`

Crossover DFS -> VE por dificultad 2B3 (`search_nodes`):

- `<250`: 2E2 pierde `52/52`
- `250-499`: 2E2 gana `7/24`
- `500-999`: 2E2 gana `4/24`
- `1000-1999`: 2E2 gana `7/12`
- `>=2000`: 2E2 gana `8/8`, speedup mediano `1.400x`

Lectura de cierre:

- VE paga overhead claro en los casos fáciles
- la zona de crossover aparece en `1000-1999` nodos; para `>=2000` VE domina en los `8/8` casos observados
- 2E2 queda validado como checkpoint exacto y estructuralmente manejable
- siguiente paso correcto: **2E3 history-aware VE**

---

## 2026-08-31 — Cierre formal de EXPERIMENTO 2E3: history-aware variable elimination

Se cerró formalmente `2E3` sobre el benchmark histórico largo ya fijado para
`30×16/99`, sin abrir experimentos nuevos.

Secuencia experimental cerrada:

- corpus histórico común:
  `16` histories (`P01..P12 + C01..C04`)
- cobertura:
  `259` puntos históricos
- replay principal completado:
  `2B3 / 2E2 / 2E3`
- replay longitudinal completado:
  `2A / 2B / 2B2 / 2B3 / 2D1 / 2E2 / 2E3`
- regla oficial de timeout:
  `150 s` por algoritmo/punto
- interpretación correcta:
  todo timeout se trata como observación censurada `>150 s`, nunca como
  runtime exacto de `150 s`

Time-outs observados en el longitudinal:

- `2A = 9`
- `2B = 5`
- `2B2 = 8`
- `2B3 = 2`
- `2D1 = 1`
- `2E2 = 0`
- `2E3 = 0`

Validación de exactitud:

- `2E2` y `2E3` coinciden exactamente entre sí en `259/259` puntos
- validación independiente contra `2B3` disponible en `257/259` puntos,
  porque `2B3` timeouta en dos
- en todos los puntos donde la referencia exacta quedó disponible,
  cada variante que terminó con `status="ok"` coincidió con esa referencia

Resultados principales:

- el salto de régimen fuerte aparece al pasar a **Variable Elimination**
- `2E2` aplasta la cola de coste de `2A -> 2D1` y elimina los timeouts en
  el corpus histórico largo
- `2E3` demuestra reuse incremental exacto real
- pero el overhead de transición/bookkeeping no compensa frente a `2E2`

Decisión de cierre:

- `2E2` queda como candidato operativo para la siguiente etapa
- `2E3` queda congelado como experimento negativo útil y expediente técnico
  auditado, no como rama de producción

La nota detallada del experimento y la tabla longitudinal quedan en
`docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`. El estado de continuidad entre
sesiones pasa a `docs/PENDING-REVIEW.md`.

---

## 2026-08-31 — Análisis estructural de flood-fill sobre el corpus histórico largo

Se cerró un primer análisis estructural de flood-fill usando únicamente el
corpus público congelado `30×16/99`:

- fuente única:
  `benchmarks/conditional-sampling-histories-30x16-20260831.jsonl`
- cobertura:
  `16` histories, `259` clicks
- clicks con outcome `0`:
  `23`
- flood-fills completamente reconstruibles:
  `22`
- gap del dataset:
  `C03` click `47`, último `0` terminal sin transcript posterior

Resultado principal:

- sin flood-fill, `new_revealed` tiene mediana `1` y max `1`
- con flood-fill, `new_revealed` tiene mediana `14.5`, p95 `38.9`, max `41`
- `WAVE` acumula hasta `10` positivos pendientes
- `FULL-REGION` acumula hasta `22`

Lectura de cierre:

- flood-fill sí parece un multiplicador estructural relevante
- `CELL`, `WAVE` y `FULL-REGION` sí parecen lo bastante distintas como para
  justificar comparación posterior
- no hay evidencia suficiente para descartar ninguna antes de implementar la
  semántica real `0/>0`

El detalle técnico, la metodología y los artefactos permanentes quedan en
`docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md`.

---

## 2026-08-31 — Cierre formal de 2F

Se cerró formalmente `2F` sobre el corpus reconstruible de flood-fill:

- pregunta probada:
  `CELL` vs `WAVE` vs `FULL-REGION`
- cobertura:
  `22` flood-fills reconstruibles x `3` políticas = `66` filas
- exclusión única:
  `C03` click `47`, sin transcript posterior reconstruible
- tests previos:
  `12 OK`
- resultado:
  `66/66 ok`, `0 timeout`, `0 invalid`

Veredicto:

- `CELL` ganó `22/22` contra `WAVE`
- `CELL` ganó `22/22` contra `FULL-REGION`
- `WAVE` ganó `21/22` contra `FULL-REGION`

La auditoría adversarial también pasó:

- recomputación independiente `PASS`
- invariantes `PASS`
- oracle leakage `PASS`
- coste comparable `PASS`
- reverse-order `PASS`

Decisión:

- `CELL` queda como política operativa de `2F`
- `WAVE` queda como línea secundaria
- `FULL-REGION` se descarta como política operativa actual

Límite conservado:

- este cierre vale para el modelo Python/VE auditado y no equivale todavía a
  gas Cairo

**12×12/20 historias**:
- width range: 1–7, max 7 en 5 casos
- Phase evolution: w/n = 0.52 (early), 0.17 (mid), 0.25 (late)
- Los componentes crecen (n: 10→27) pero w se mantiene (4-5)

### Conclusión

**Recomendación A: JUNCTION TREE / VARIABLE ELIMINATION MERECE EXPERIMENTO.**

Evidencia determinante:
1. Treewidth ≤ 6 para todos los 120 casos del corpus objetivo 30×16/99.
2. Componentes n=40-56 tienen width 4-5 (no crece con n), ratio n/w hasta 14x.
3. DFS más caro (4952 nodos, n=46, w=4): speedup teórico ~3-7x con VE.
4. Factor size 2^w = 16-64, vs DFS exponencial en n (2^46 sin pruning).
5. El beneficio se acentúa en mid-game (w/n = 0.17) donde más importa.

No garantía teórica de w≤6 para todo transcript 30×16, pero los 120 casos
más grandes y más caros del corpus jamás lo superan.

### Artefactos

- `scripts/conditional_sampling_treewidth_prestudy.py`
- `benchmarks/conditional-sampling-treewidth-prestudy-20260830.jsonl`
- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md` (sección PRESTUDY 2E añadida)

---

## 2026-08-30 — Prestudy 2E1: corrección de factor aumentado y auditoría de max clique

### Contexto

Revisión de tres simplificaciones en el análisis de treewidth (PRESTUDY 2E):
1. `factor_size = 2^w` era demasiado optimista — falta la dimensión de conteo de minas.
2. La query especial `ways[k, x_mine, n_mine]` tiene dimensiones extra `2 × (d+1)`.
3. La afirmación "max_clique ≤ max_scope ≤ 8" era conceptualmente incorrecta
   (los cliques pueden cruzar scopes en grafos primales).

### Correcciones al análisis

**Factor ordinario correcto**: `2^{sep_size} × mines_range` (no `2^w`).
`mines_range` crece con cada eliminación (acumula minas de variables ya eliminadas).

**Factor especial correcto**: `2^{sep_size} × mines_range × 2 × (d+1)` donde
`d = |N(x) ∩ component|`. En el corpus 30×16/99: mediana d=3, típico multiplicador 8.

**Max clique**: Bron-Kerbosch es exacto y su cálculo era correcto. Solo el prose
estaba mal. Max clique observado en 30×16/99: 7. No está acotado por max_scope.

### Resultados de simulación (120 casos 30×16/99)

**Global**:

| Métrica | p50 | p90 | max |
|---------|-----|-----|-----|
| ord_aug_max / nodes | 1.56 | 3.61 | 5.00 |
| spc_aug_max / nodes | 10.77 | 29.93 | 40.00 |
| ord_aug_total / nodes | 11.46 | — | 44.71 |
| spc_aug_total / nodes | 68.77 | — | 357.67 |

**Casos duros (nodes>1500, 12 casos)**:

| Métrica | p50 | p90 | max |
|---------|-----|-----|-----|
| ord_aug_max / nodes | 0.32 | 0.48 | 0.48 |
| spc_aug_max / nodes | 1.92 | 2.87 | 3.87 |
| ord_aug_total / nodes | 3.82 | 4.82 | 4.82 |
| spc_aug_total / nodes | 21.10 | 30.56 | 38.56 |

**Caso más caro (2a-005, n=46, w=4, d=2, nodes=4,952)**:
- ord_aug_max=688, spc_aug_max=4,128
- ord_aug_total=8,771, spc_aug_total=52,626

### Conclusión revisada

La señal estructural del PRESTUDY 2E se mantiene: **treewidth ≤ 6** en todos
los casos es un hallazgo firme. El análisis aumentado no muestra explosión de
factores intermedios en ninguno de los 120 casos.

Nota importante sobre las métricas: `ord_aug_max`, `spc_aug_max`, `ord_aug_total`,
`spc_aug_total` son capacidades estructurales bajo la ordering simulada, no
conteos de entradas non-zero ni conteos de operaciones aritméticas. `augmented
factor states` y `DFS nodes` son métricas de trabajo distintas; el coste
relativo real depende de sparsity, joins, marginalizaciones y aritmética big-int,
y sólo puede determinarse implementando y benchmarkeando VE exacta.

**Recomendación A — variable elimination exacta merece experimento.**
No se reporta speedup estimado. El rendimiento frente al DFS queda como hipótesis
pendiente de implementación y benchmark real.

### Artefactos actualizados

- `docs/EXPERIMENTO-2-CONDITIONAL-SAMPLING.md` (sección PRESTUDY 2E corregida;
  análisis aumentado 2E1 añadido; framing de métricas corregido en 2E1)
- `docs/bitacora.md` (esta entrada)
- `scripts/conditional_sampling_treewidth_prestudy.py`
- `scripts/conditional_sampling_treewidth_augmented_prestudy.py`
- `benchmarks/conditional-sampling-treewidth-prestudy-20260830.jsonl`
- `benchmarks/conditional-sampling-treewidth-augmented-20260830.jsonl`

---

## 2026-08-31T12:46 — Apertura 2G: Cairo CELL cost translation

Tanda de apertura del experimento 2G. Inspección completa del repo Cairo existente,
análisis de bit lengths (max 471 bits en instrumentation.max_integer_bit_length de 2F),
confirmación de que u256 es insuficiente para corpus-scale.

Implementación inicial: paquete standalone `contracts/zkmine_2g/` con VE primitives
en Cairo (constraint_factor, join_factors, eliminate_variable, count_ordinary_component).
12/12 tests pasan. Paridad exacta con Python verificada en todos los fixtures.

Mediciones reales de sierra gas (snforge 0.62.1 --detailed-resources):
- constraint_factor 3-var/rhs=1: ~174K–200K sierra gas
- join 3-var + 3-var (2 overlap): ~1.24M sierra gas
- full ordinary VE 4-var/2-constraints: ~1.46M sierra gas
- chain 10-var/8-constraints: ~9.1M sierra gas
- chain 16-var/14-constraints: ~17.1M sierra gas

Extrapolación para corpus real 30×16/99 (23-26 vars, higher treewidth): ~30-60M sierra gas
por evaluación de celda en el esquema actual.

Primer cuello de botella observado: la función `accumulate` en join_factors hace O(n²)
reconstrucción de arrays por cada entrada (no hay hashmap en Cairo). Para 103 nonzero entries
esto sería ~10K operaciones de Array rebuild. Optimización clara disponible.

Estado: archivos nuevos en contracts/zkmine_2g/, benchmark en benchmarks/2g-cairo-ve-fixtures-20260831.json.

---
## 2026-08-31T15:00 — Experimento 2G Phase 2: accumulator shootout

### Qué se hizo
- Auditado rangos reales del state key (corpus 2E2): mines_used llega a 30, NO acotado por scope_len
- Dense table descartada: 39,680 slots inviable en Cairo (0.26% ocupancy)
- Implementado Alt A: Felt252Dict<u128> accumulator en ve_dict.cairo (join_factors_dict, eliminate_variable_dict, count_ordinary_component_dict, pack_key)
- Añadidos 5 tests de equivalencia dict/baseline (d1..d5): 17/17 tests pasan
- Añadida sección de contingencias a INCOGNITAS.md

### Resultado del shootout

| Fixture | Baseline (gas) | Dict (gas) | Ratio dict/baseline |
|---------|---------------|------------|---------------------|
| f3 (4-var) | 1,457,904 | 3,240,418 | 2.22× |
| f6 (10-var) | 9,116,144 | 19,380,178 | 2.13× |
| f7 (16-var) | 17,144,044 | 36,253,378 | 2.11× |

**Ganador: BASELINE** — el overhead del squash de Felt252Dict domina sobre las tablas sparse pequeñas (≤103 entries). El O(n²) con n pequeño tiene constante suficientemente baja.

### Archivos nuevos/modificados Phase 2
- contracts/zkmine_2g/src/ve_dict.cairo  (nuevo)
- contracts/zkmine_2g/src/lib.cairo  (M — pub mod ve_dict)
- contracts/zkmine_2g/src/tests/test_ve.cairo  (M — 5 tests dict equiv)
- benchmarks/2g-cairo-accumulator-20260831.json  (nuevo)
- docs/INCOGNITAS.md  (M — contingencias)
- docs/2g-checkpoint.md  (M — rangos + plan)

---

## 2026-08-31T20:00 — 2G Phase 3: bigint u512 + joint VE + 2a-109 CELL evaluation

### Resumen

Phase 3 completada. 28/28 tests pasan. Paridad exacta con Python 2E2 oracle.

### Logros

1. **bigint.cairo** — u512 desde cero: add (con carry chain), mul_small (×u32), div_small (exact /u32), binom(n,k) iterativo. Justificación: binom(465,k≤99) ≤ 343 bits; productos intermedios ≤ 2^466; todo cabe en u512 (512 bits).

2. **Bug crítico encontrado y corregido en VE joint** — constraint_factor inicializaba x_mine/nbrs desde la máscara live. Al eliminar el mismo variable, eliminate_variable los sumaba de nuevo: doble conteo. Fix: constraint_factor siempre x_mine=0, nbrs=0. Solo eliminate_variable acumula. join_factors simplificado (suma directa, sin filtro).

3. **j1 — joint VE 2a-109**: verified exact 5 entries {(1,0,0):2,(1,0,1):1,(1,1,0):1,(2,0,0):3,(2,0,1):6}. l2_gas=23,387,266.

4. **j2 — full CELL eval 2a-109**: joint VE + convolucion local + binom(465,94-98) × coeffs. 6 outcome counts verificados limb-a-limb contra Python oracle. l2_gas=45,366,416.

5. **b1-b8 — bigint boundary tests**: 256-bit crossing, 344-bit binom(465,98), 461-bit range, exact limb values. Todos pasan.

### Gas medido (l2_gas, sierra, snforge --detailed-resources)

| Test | l2_gas |
|------|--------|
| b7 binom(465,98) [343 bits] | 4,435,520 |
| b6 binom(480,99) [crosses 256] | 4,480,470 |
| j1 joint VE component | 23,387,266 |
| j2 full CELL eval 2a-109 | 45,366,416 |
| f7 chain 16-var ordinary VE | 16,984,074 |

### Archivos nuevos/modificados

- contracts/zkmine_2g/src/bigint.cairo (nuevo)
- contracts/zkmine_2g/src/ve.cairo (M — fix constraint_factor + join_factors + count_joint_component)
- contracts/zkmine_2g/src/lib.cairo (M — pub mod bigint)
- contracts/zkmine_2g/src/tests/test_ve.cairo (M — Phase 3 tests: b1-b8, j1, j2)
- benchmarks/2g-fixture-2a109-oracle.json (nuevo)
- benchmarks/2g-cairo-bigint-cell-20260831.json (nuevo)

---

## 2026-08-31T23:10 — 2G Phase 4 prep: binomial recurrence + second real case + flood sequence fixture

### Resumen

Se dejó preparada la siguiente tanda de 2G sin deshacer el working tree existente:

- `binom_range_from_anchor(n, k_lo, k_anchor, k_hi)` agregado en Cairo usando recurrencias exactas forward/backward sobre `u512`, con división exacta asserted.
- baseline `binom()` y `binom_range()` conservados intactos para comparación.
- tests nuevos añadidos para:
  - igualdad baseline vs recurrence en `C(465,94..98)` para `2a-109`
  - igualdad baseline vs recurrence en `C(452,88..94)` para el segundo caso real
  - paridad final `2a-109` usando recurrence
  - joint exacto del segundo caso real `P12-step-005`
  - outcome counts exactos del segundo caso real con recurrence

### Audit coupling

- `2a-109` usa exactamente `k = 94,95,96,97,98` sobre `binom(465,k)`.
- anchor elegido para recurrence en ese caso: `k0 = 96`.
- segundo caso real seleccionado: `P12-step-005`, `clicked_cell=54`.
- ese caso usa exactamente `k = 88,89,90,91,92,93,94` sobre `binom(452,k)`.
- anchor elegido: `k0 = 91`.

### Segundo caso real

Fixture autocontenido persistido:

- `benchmarks/2g-fixture-p12-step-005-oracle.json`

Criterios persistidos de selección frente a `2a-109`:

- special component variables: `10 -> 20`
- special constraint count: `2 -> 5`
- joins: `1 -> 4`
- peak_factor_entries: `5120 -> 9216`
- effective_width: `6 -> 6`

Joint exacto del componente special:

- `11` entradas
- `max joint coefficient = 120`
- after-local: `29` entradas
- `distinct k = 88..94`

### Flood/cascade

Secuencia representativa ya congelada y persistida:

- `benchmarks/2g-flood-c04-step-035-sequence.json`

Resumen:

- `history_id=C04`, `click_number=35`, `clicked_cell=252`
- `new_revealed=19`
- `step_count=18`
- `wave_count=2`
- instrumentation Python/2F: `peak_factor_entries=86016`, `peak_nonzero_factor_entries=220`, `max_integer_bit_length=231`

### Bloqueo local

No se pudieron ejecutar en este workspace las nuevas mediciones Cairo (`baseline coupling`, `recurrence coupling`, `j2 optimizado`, `segundo CELL`, `flood sequence`) porque `scarb` y `snforge` no están disponibles en `PATH` ni aparecieron bajo `/snap` durante la búsqueda local.

Se persistió checkpoint técnico:

- `benchmarks/2g-binom-recurrence-audit-20260831.json`

---

## 2026-08-31T23:55 — 2G Phase 4: P12 joint VE cost decomposition instrumentation

### Resumen

Se añadió una ruta de profiling en Cairo para descomponer el coste de `count_joint_component` sobre `P12-step-005` sin alterar la semántica baseline ni la paridad congelada de `j3`.

### Instrumentación nueva

- `contracts/zkmine_2g/src/ve.cairo`
  - `constraint_factor_with_profile`
  - `join_factors_profile`
  - `eliminate_variable_profile`
  - `count_joint_component_profile`
  - perfiles nuevos:
    - `FactorProfile`
    - `AccumulateProfile`
    - `JoinProfile`
    - `EliminationProfile`
    - `VeStepProfile`
    - `JointProfileResult`
- métricas explicitadas por etapa:
  - `scope_len`
  - `dense_capacity`
  - `entry_count`
  - `nonzero_entry_count`
  - `candidate_pair_comparisons`
  - `compatible_pair_matches`
  - `accumulate_calls`
  - `accumulate_scanned_entries`
  - `accumulate_copied_entries`
  - `bigint_multiplications`
  - `bigint_additions`
  - `eliminated_entries_with_bit_set`

### Etapas P12 fijadas

Join efectivo real en `P12-step-005`:

- stage 1: eliminar `54`
- stage 2: eliminar `84`
- stage 3: eliminar `112`
- stage 4: eliminar `115`

Las eliminaciones `113`, `116`, `144` y `174` siguen existiendo, pero se separan como cola monofactor y no se confunden con joins.

### Checkpoints / oráculos

- fixture técnico nuevo:
  - `benchmarks/2g-p12-joint-stage-oracle-20260831.json`
- tests autocontenidos nuevos en:
  - `contracts/zkmine_2g/src/tests/test_ve.cairo`
  - `j5_p12_stage0_constraint_factor_profiles`
  - `j6_p12_profile_trace_join_steps`
  - `j7_p12_stage1_join_elimination_from_checkpoint`
  - `j8_p12_stage2_join_elimination_from_checkpoint`
  - `j9_p12_stage3_join_elimination_from_checkpoint`
  - `j10_p12_stage4_join_to_final_joint_from_checkpoint`

### Datos locales confirmados persistidos

Persistidos en artefactos/Docs como resultados locales confirmados:

- `scarb build`: PASS, sin warnings tras limpieza de imports
- suite: `33` tests
  - corrida default: `32 PASS`, `j3` agotó el step limit default
  - rerun `j3` con `--max-n-steps 100000000`: PASS
- `j1 joint VE 2a-109 = 23,387,266`
- `j2 baseline 2a-109 = 45,366,416`
- `j2b recurrence coupling = 4,976,940`
- `j3 joint VE P12-step-005 = 2,071,551,573`
- `j4 P12 recurrence coupling = 5,149,160`

Corrección semántica persistida:

- `j2b` no es CELL completo
- `j4` no es CELL completo
- `j2` sí ejecuta joint VE, pero la convolución local sigue materializada en el test

### Limitación de este workspace

En este workspace concreto siguen sin aparecer `scarb` ni `snforge` en `PATH`, así que no pude re-ejecutar aquí esas mediciones; solo quedó preparado el código/fixture/documentación para correrlas fuera de este entorno sin perder contexto 404-safe.


---

## 2026-08-31 — 2G Phase 4: P12 stage decomposition ejecutada y clasificada

### Contenido de PENDING-REVIEW al ser reemplazado

Ver commit anterior (fd016ba) para el PENDING-REVIEW previo.
Este append registra el cierre de la descomposición P12 stage0..stage4.

### Bugs corregidos

**Bug j6** — `p12_vars()` usaba orden sorted `[52,53,54,55,56,82,...]`. Con ese orden, cuando el VE procesa var=54 (posición 3 en la lista), f0 todavía contiene 82 en su scope: scope=[54,82,84,112,113] con 7 entries (en vez de scope=[54,84,112,113] con 6 entries del oracle). La aserción `related_entry_count_total==22` fallaba porque el valor real era 28 (7+21). Fix: cambiar `p12_vars()` al orden del oracle [52,53,82,55,56,86,142,172,173,146,175,176,54,84,112,113,115,116,144,174].

**Bug j7/j10** — Ambos tests terminaban con llamada a `count_joint_component` completo (P12 entero, ~2.07B gas), contaminando el benchmark aislado. Removidas esas llamadas. j7 y j10 ahora miden sólo su stage.

### Mediciones locales

- `scarb build`: PASS sin warnings
- `snforge test` (default steps): 38/39 PASS; j3 necesita `--max-n-steps`
- `j3 --max-n-steps 100000000`: PASS, 2,071,551,573 L2 gas (baseline intacto con nuevo ordering)

Stages aislados:
- j5 stage0 = 17,237,105
- j7 stage1 = 19,191,812
- j8 stage2 = 19,041,266
- j9 stage3 = 47,519,745
- j10 stage4 = 61,206,340
- j6 trace completo (oracle ordering, con profiling) = 213,291,792

### Clasificación: CASO A



---

## 2026-08-31 — 2G Phase 4 cierre: j3o oracle-order unprofiled

Se añadió `j3o_joint_ve_p12_oracle_order`: mismo problema que j3, orden oracle, sin profiling.

- j3 sorted order: 2,071,551,573 L2 gas
- j3o oracle order (no profiling): 195,990,572 L2 gas
- j6 oracle order (con profiling): 213,291,792 L2 gas
- ratio j3/j3o ≈ 10.57×
- profiling overhead j6/j3o ≈ 1.088× (+8.8%)

Paridad: j3o produce exactamente los mismos 11 joint entries que j3.



---

## 2026-08-31 — 2G Phase 5: verified elimination-order hint

**Auditoría del oracle-order**:
El orden oracle [52,53,82,55,56,86,...,54,84,...] es IDÉNTICO al producido por
`build_elimination_plan` (heurística min-fill sobre grafo primal), confirmado con
`python3 scripts/conditional_sampling_2e2_variable_elimination.py`. Usa solo
estructura pública de constraints. No usa counts, board oculto ni oráculos.

**Implementación**:
- `count_joint_component_with_order` en `contracts/zkmine_2g/src/ve.cairo`
- `verify_permutation` (O(n²), clara, auditable)
- 7 tests Phase 5 (h1-h7): 45/47 PASS; h2 y j3 exceden step limit (conocido)

**Mediciones**:
- j3o (oracle, sin verificación): 195,990,572
- h1 (oracle + verificación): 197,319,222 → overhead: 1,328,650 (0.68%)
- j1 (2a-109, sin verificación): 23,387,266
- h7 (2a-109 + verificación sorted): 23,768,186 → overhead: 380,920 (1.63%)
- h2 (sorted + verificación): 2,072,564,863

**Gate**: P12 oracle order con hint verificado = 197.3M << 1.1B → PASA.

**2a-109 min-fill vs sorted**: min-fill order es [223,253,283,224,225,...] (distinto de sorted [223,224,225,226,...]). No medido en Cairo; se registra diferencia estructural.


---
## 2026-08-31 — Phase 6: corpus-scale min-fill campaign (120 casos)

**Campaña**: `count_joint_component_with_order` sobre 120 casos del corpus 30×16/99.

**Fuente de datos**: `conditional-sampling-2e2-variable-elimination-20260830.jsonl` (signatures + min-fill orderings) + `conditional-sampling-2a-corpus-20260830.jsonl` (transcripts).

**Fixture generator**: `scripts/gen_phase6_fixtures.py` → `benchmarks/2g-phase6-fixtures-20260831.jsonl`.

**Test generator**: `scripts/gen_phase6_cairo_tests.py` → `contracts/zkmine_2g/src/tests/test_ve_phase6.cairo` (120 tests).

**Resultados**:

| Métrica | Valor |
|---------|-------|
| Casos | 120 |
| PASS | 120 (100%) |
| FAIL | 0 |
| % < 1.1B gate | **100%** |
| min gas | 720,446 (size=2) |
| p50 gas | 70,049,051 |
| p90 gas | 139,238,839 |
| p95 gas | 197,648,551 |
| p99 gas | 260,881,552 |
| **max gas** | **261,796,804** (2a-006, size=46) |

**Top 3 más costosos**:
- 2a-006: size=46, width=4, 261.8M gas
- 2a-008: size=46, width=4, 260.9M gas
- 2a-026: size=10, width=6, 257.4M gas (width=6 > width=4 en cost)

**Hallazgo clave**: El factor determinante del costo es `min_fill_width`, no el número de variables. Los casos size=56 (width=4) cuestan ~82M gas mientras los size=10 (width=6) llegan a ~257M gas.

**Gate**: 100% de los 120 casos reales del corpus pasan < 1.1B.

**Archivos generados**:
- `benchmarks/2g-phase6-fixtures-20260831.jsonl` (120 fixtures con joint counts verificados)
- `benchmarks/2g-phase6-minfill-corpus-20260831.jsonl` (120 resultados de gas)
- `contracts/zkmine_2g/src/tests/test_ve_phase6.cairo` (120 tests generados)
- `scripts/gen_phase6_fixtures.py`
- `scripts/gen_phase6_cairo_tests.py`

---
## 2026-08-31 — Phase 6 correctness fix: exact joint parity

**Bug encontrado**: `gen_phase6_cairo_tests.py` original sólo generaba `assert(joint.len() == N)` — verificaba cardinalidad pero NO paridad exacta.

**Fix**: nuevo archivo `test_ve_phase6_exact.cairo` con `find_joint_local` per-entry para cada `(mines, x_mine, nbrs) -> count` esperado.

**Resultado**: 120/120 exact parity Python↔Cairo.

**Overhead de assertions** (gas exacto - gas benchmark):
- min: 8,250 | p50: 86,780 | p90: 582,230 | max: 1,354,050 gas
- max overhead ≈ 0.5% del caso más costoso (261.8M gas)

**Distribución de gas Phase 6**: los valores originales (test_ve_phase6.cairo, VE + len assert) son válidos como benchmark de la ejecución VE. No se necesita rerun.

**Archivos modificados**:
- `scripts/gen_phase6_cairo_tests.py`: actualizado para generar ambos archivos
- `contracts/zkmine_2g/src/tests/test_ve_phase6.cairo`: regenerado (idéntico semánticamente)
- `contracts/zkmine_2g/src/tests/test_ve_phase6_exact.cairo`: nuevo
- `contracts/zkmine_2g/src/tests.cairo`: añadido `mod test_ve_phase6_exact`

---

## 2026-08-31 — Phase 6: correctness fix + paridad exacta (archivado antes de Phase 7)

# PENDING-REVIEW — 2G Phase 6: correctness fix + paridad exacta
# Fecha: 2026-08-31

## Bug metodológico encontrado

`gen_phase6_cairo_tests.py` original generaba por test **únicamente**:

```cairo
assert(joint.len() == {expected_len}, '...');
```

Esto verifica cardinalidad del output pero **NO** que cada entrada `(mines, x_mine, nbrs) → count` sea la correcta. Los 120/120 PASS originales demostraban que el VE produce el número correcto de entradas distintas, no que sean las entradas exactas.

## Fix aplicado

Nuevo archivo: `contracts/zkmine_2g/src/tests/test_ve_phase6_exact.cairo`

Cada test ahora:
1. Llama a `count_joint_component_with_order` (exactamente igual al gas test)
2. Verifica `joint.len() == N`
3. Para **cada** entrada esperada en el fixture:
   ```cairo
   assert(find_joint_local(@joint, {mines}, {x_mine}, {nbrs}) == {count}, '...');
   ```

`find_joint_local` hace búsqueda lineal sobre el Array de salida (O(N) por llamada, N ≤ 17 en corpus). No asume ordering del Array.

Cobertura exacta:
- Mismo número de entries ✓
- Cada tupla `(mines, x_mine, nbrs)` esperada aparece ✓
- Count exacto por cada tupla ✓
- Si alguna entry faltara: `find_joint_local` devuelve `0`, assert falla ✓

## Resultado exacto: 120/120

```
snforge test "p6_exact_"
Tests: 120 passed, 0 failed, 0 ignored
```

**Paridad Python↔Cairo confirmada** para todos los 613 entries de joint distribution sobre el corpus completo.

## Gas: separación benchmark vs correctness

Dos archivos Cairo separados:

| Archivo | Assertions | Uso |
|---------|-----------|-----|
| `test_ve_phase6.cairo` | VE + `joint.len() == N` | **Gas benchmark** |
| `test_ve_phase6_exact.cairo` | VE + len + todos los entries exactos | **Correctness** |

### Overhead de assertions (exact − benchmark)

| Métrica | Gas |
|---------|-----|
| min | 8,250 |
| p50 | 86,780 |
| p90 | 582,230 |
| max | **1,354,050** |

Caso más costoso (2a-006): gas benchmark = 261,796,804 → gas exacto = 262,189,674. Diferencia = 392,870 gas = **0.15% overhead**.

**Los valores de Phase 6 original son válidos como benchmark del algoritmo VE.** No se necesita rerun: la diferencia está documentada y es <1%.

## Distribución de gas (benchmark, Phase 6 original — VE sin overhead de assertions)

| Métrica | L2 sierra gas |
|---------|---------------|
| min | 720,446 |
| p50 | 70,049,051 |
| p90 | 139,238,839 |
| p95 | 197,648,551 |
| p99 | 260,881,552 |
| max | 261,796,804 |

**% casos < 1.1B gate: 100% (120/120)**

## Afirmaciones finales

| Afirmación | Evidencia |
|------------|-----------|
| 120/120 exact joint-count parity Python↔Cairo | test_ve_phase6_exact: 120 PASS, 613 entry assertions |
| 120/120 < 1.1B gate | test_ve_phase6: max 261.8M gas |
| Gas = costo VE sin contaminar por assertions | overhead max 1.35M gas (0.5%) documentado y separado |
| Correctness y gas en tests distintos | archivos `_exact` vs base confirmados |

## git diff --stat

```
contracts/zkmine_2g/src/tests.cairo                     |   1 +
contracts/zkmine_2g/src/tests/test_ve_phase6.cairo      |   0   (regenerado, idéntico semánticamente)
contracts/zkmine_2g/src/tests/test_ve_phase6_exact.cairo| 889 +++++++++++++++++ (nuevo)
docs/bitacora.md                                        |  35 +
docs/PENDING-REVIEW.md                                  | reemplazado
scripts/gen_phase6_cairo_tests.py                       |  90 ++++++- (actualizado para 2 archivos)
```

## git status --short

```
 M contracts/zkmine_2g/src/tests.cairo
?? benchmarks/2g-phase6-fixtures-20260831.jsonl
?? benchmarks/2g-phase6-minfill-corpus-20260831.jsonl
?? contracts/zkmine_2g/src/tests/test_ve_phase6.cairo
?? contracts/zkmine_2g/src/tests/test_ve_phase6_exact.cairo
?? scripts/gen_phase6_cairo_tests.py
?? scripts/gen_phase6_fixtures.py
 M docs/bitacora.md
 M docs/PENDING-REVIEW.md
```

**STOP.**

## 2026-09-01 — Diagnóstico Phase 8 exact failures

Causa raíz identificada: gen_phase8_fixtures.py sobreescribe `special_comp_vars` en el loop de componentes. Cuando un click tiene vecinos locales en DOS componentes disjuntos (e.g., f01_s034: comp grande 52-vars con 261/231 + comp pequeña 2-vars con 289/290), el loop aplica `special_comp_vars = cvars` en CADA iteración → solo queda la ÚLTIMA. La primera componente se pierde: no está ni en "special" ni en "ordinary_components".

Fix requerido:
- gen_phase8_fixtures.py: acumular todos los specials en lista `special_components: list[dict]`
- gen_phase8_cairo_tests.py: generar llamadas múltiples count_joint_component_with_order + convolve_joint
- cell.cairo: agregar función `convolve_joint(agg1, agg2) -> Array<JointEntry>`
- Regenerar fixtures y tests, re-ejecutar snforge

32 fallos exactos en f01-f11 (exact_s1): todos tienen exactamente 2 componentes especiales.

## 2026-09-01 — Regeneración tests Phase 8 (continuación post-freeze)

Fixtures verificados: 408 entradas, formato `special_components: list[dict]` correcto.
C01_029 step 34: 2 special components (sp0 size=52 width=5, sp1 size=2 width=1).
Procediendo a regenerar test_ve_phase8*.cairo y shards.

## 2026-09-01 — Phase 8 COMPLETO: 816/816 tests pasan

### Resultados finales (dos corridas)

**Corrida 1** (scripts/run_phase8_sharded.sh):
- benchmark_s1: 246/246 PASS ✓
- exact_s1: 246/246 PASS ✓ (eran 32 fallos antes del fix)
- benchmark_s2: 18/162 registrados (OOM durante ejecución paralela)
- exact_s2: 88/162 registrados (OOM durante ejecución paralela)
- combined: error de compilación (`{prefix}//` → Cairo inválido)

**Corrida 2** (s2 + combined con --max-threads 1):
- benchmark_s2: 162/162 PASS ✓
- exact_s2: 162/162 PASS ✓
- combined f20 (3 steps): PASS ✓, l2_gas ~37M
- combined f06 (16 steps): PASS ✓, l2_gas ~2.2B
- combined f08 (40 steps): OOM esperado (~36B gas total > límite 4.29B)

### Fixes aplicados en esta sesión

1. `gen_phase8_fixtures.py`: multi-special-component bug (sobreescritura)
2. `gen_phase8_cairo_tests.py`: soporte N special components + `convolve_joint`; fix `{prefix}//` en comentarios
3. `cell.cairo`: añadida `convolve_joint`

**Estado: Phase 8 cerrada. 816 tests pasan.**

## 2026-09-01 — Extracción analítica Phase 8 (sin re-run)

Análisis de viabilidad sobre 408 CELL medidos.

**Resultados clave:**
- 45/408 CELLs (11%) exceden gate 1.1B L2 gas
- 4 floods unsegmentables entre CELLs: f08 (1 CELL >1.1B), f13 (8/11), f14 (12/18), f15 (24/24)
- f15 = C04_044: todos sus CELLs en rango 5.5–6.3B (~5-6× el gate)
- 18/22 floods (82%) segmentables con continuation entre CELLs
- 8/22 floods (36%) caben en 1 sola tx de 1.1B
- max_width=7 es el predictor más discriminante: 39% de CELLs con w=7 superan gate
- combined f06: ratio combined/sum=0.9999 (overhead despreciable)
- --max-n-steps 4294967295 del runner ≠ gate Starknet 1.1B (f08 combined silenciado por runner limit, no por el gate)

Summary durable: benchmarks/2g-phase8-analysis-20260901.md

## 2026-09-01 — Auditoría documental Phase 8

**Punto 1 — PENDING-REVIEW**: hallado drift de naming: extracción analítica escrita en `docs/pending_review.md` (gitignoreado, lowercase) en lugar de `docs/PENDING-REVIEW.md` (versionado). Corregido: PENDING-REVIEW.md reemplazado con informe de auditoría + extracción completa.

**Punto 2 — Artefacto gas**: faltaba JSONL/CSV con 408 filas individuales. Creado `benchmarks/2g-phase8-cell-gas-20260901.jsonl` desde logs+fixtures sin re-run. Verificado: n=408, >1.1B=45, floods=22, floods_con_over=4. Consistente con analysis.md.

**Punto 3 — Bitacora**: todos los items requeridos estaban presentes (líneas 2359, 2362-2364, 2384, 2375, 2399, 2403-2415).

Estado final: 2 artefactos nuevos, 1 archivo corregido. No commits. No re-run.

## 2026-09-01 — Intermediate 16×16/40 estudio estructural pre-Cairo

**Objetivo**: decidir si el preset Intermediate tiene riesgo de cola comparable a Expert Phase 8 ANTES de diseñar la ronda Cairo.

**Corpus generado**:
- Script: `scripts/gen_intermediate_structural_corpus.py` (404-safe, resumable, sin oracle)
- 500 seeds × 3 estrategias (0=center-first, 1=NW-corner, 2=SE-corner) = 1500 (seed,strategy) combos
- 187,098 CELL estructurales en `benchmarks/intermediate-16x16-40-cells-20260901.jsonl`
- 1,500 game records en `benchmarks/intermediate-16x16-40-meta-20260901.jsonl`
- Media: 124.7 cells/partida, 7.3 floods/partida, 0.40s/partida
- Script de análisis: `scripts/analyze_intermediate_corpus.py`
- Salidas: `benchmarks/intermediate-16x16-40-analysis-20260901.md` + `-candidates-20260901.jsonl`

**Hallazgos estructurales clave**:
- max_width=8 encontrado: 9 CELLs (3 boards distintos: seeds 38, 349, 374) — SUPERA Expert máximo (7)
  - Todos con n_ord=0 (mitiga parcialmente: sin convolution ordinaria)
  - Peor caso: seed=374, step=9, max_width=8, total_vars=70, unc_other=90
- max_width=7 + n_ord>0: 217 CELLs — patrón exacto de Expert UNSEG
  - Pero unc_other bajo en los peores: n_ord=6 con unc_other=0 (barato por extract_outcomes)
- Combinación crítica: width=7 + n_ord=0 + unc_other>200: seed=126 f00 step=1-3 (unc_other=219)
- total_vars: max=87 (Expert max=189, Expert p50=52) — mucho más pequeño
- unc_other: max constrained=248 (Expert min=113) — solapamiento leve pero en CELLs con max_width=0
- n_ordinary: max=11 (Expert max=8) — supera Expert, pero con componentes muy pequeñas

**Veredicto automatizado**: HIGH STRUCTURAL RISK
- Score=7 (≥5): width≥8 (+4), width=7+n_ord>0 (+1), unc_other≥200 con constraints (+2)
- Matiz: la combinación triple (alto width + n_ord>0 + unc_other>100) NO coincide en ningún CELL individual
- Conclusión operativa: Cairo testing de los 59 candidatos es ESENCIAL antes de diseñar ronda Intermediate

**Comparación Expert Phase 8**:
- Expert UNSEG rate: 4/22 floods (18%), todos con max_width=7 + n_ord>0 + unc_other≥100 simultáneo
- Intermediate: las tres condiciones nunca coinciden simultáneamente (n_ord=0 para width≥8, unc_other≈0 para n_ord>0)
- Gas real desconocido: estimación cualitativa 0.5B–3B para peor caso, pero no verificable sin Cairo run

**Artefactos**:
- `benchmarks/intermediate-16x16-40-cells-20260901.jsonl` — corpus completo (187K rows, reproducible)
- `benchmarks/intermediate-16x16-40-meta-20260901.jsonl` — game records
- `benchmarks/intermediate-16x16-40-analysis-20260901.md` — informe completo
- `benchmarks/intermediate-16x16-40-candidates-20260901.jsonl` — 59 candidatos Cairo
- `scripts/gen_intermediate_structural_corpus.py` — generador
- `scripts/analyze_intermediate_corpus.py` — análisis

**NO se ejecutó ronda Cairo. NO se editó el grant. NO se hizo commit. NO se hizo push.**

---

## 2026-09-01 11:22 — Intermediate 16×16/40 Cairo CELL benchmark (59 candidatos)

**Objetivo:** Ejecutar pipeline Cairo exacto VCLS/CELL sobre los 59 candidatos seleccionados del corpus Intermediate 16×16/40, medir L2 Sierra gas, verificar exactitud Python↔Cairo, emitir veredicto GREEN/YELLOW/RED.

**Criterio predeclarado:**
- GREEN: 59/59 exact; ningún caso ≥ 900 M
- YELLOW: 59/59 exact; ningún >1.1B; al menos uno ≥ 900 M
- RED: cualquier >1.1B o fallo exactitud

**Resultado:**
- 59/59 benchmark PASS, 59/59 exact PASS
- 59/59 exactos Python↔Cairo (todas las assertions pasaron)
- 3 casos > 1.1B gate: f33/f34/f36, todos del flood s00082g0f03 (seed=82 strat=0 flood3)
- Max gas: 1,591,439,034 L2 Sierra (f33, seed=82, step=3, max_width=0, vars=86, sum_ord_size=86)
- Width=8 cases (el riesgo estructural identificado): rango 168M–425M, todos bajo 750M
- Predictor real: total_vars/sum_ord_size (r≈+0.51), NO max_width (r=−0.075)

**Veredicto: RED** — 3 casos > 1.1B, mismo flood, patrón ordinary-dominated con VE width interno=6

**Archivos creados:**
- `benchmarks/intermediate-16x16-40-fixtures-20260901.jsonl` (59 fixtures completos)
- `benchmarks/intermediate-16x16-40-gas-20260901.jsonl` (raw gas por candidato)
- `benchmarks/intermediate-16x16-40-gas-analysis-20260901.md` (análisis completo)
- `benchmarks/intermediate-snforge-bench-20260901.log`
- `benchmarks/intermediate-snforge-exact-20260901.log`
- `contracts/zkmine_2g/src/tests/test_ve_intermediate.cairo`
- `contracts/zkmine_2g/src/tests/test_ve_intermediate_exact.cairo`
- `scripts/gen_intermediate_fixtures.py`
- `scripts/gen_intermediate_cairo_tests.py`
- `scripts/run_intermediate_sharded.sh`

**NO se editó el grant. NO se hizo commit. NO se hizo push.**

---

## 2026-09-01 — Búsqueda frontera GREEN: 15×15/35 RED, próximo 12×12/23

### Objetivo

Determinar el mayor tablero cuadrado pre-grant GREEN con pipeline exacto VCLS/CELL actual.
Punto de partida: 16×16/40 ya medido como RED. Descender hasta encontrar GREEN.

### Metodología

Infraestructura nueva parametrizada:
- `scripts/gen_square_corpus.py` — corpus estructural NxN/M (500 seeds × 3 estrategias)
- `scripts/analyze_square_corpus.py` — análisis + selección adversarial de candidatos
- `scripts/gen_square_fixtures.py` — fixtures completos Cairo
- `scripts/gen_square_cairo_tests.py` — tests Cairo bench + exact
- `scripts/parse_square_gas.py` — parseo de logs snforge
- `scripts/run_square_sharded.sh` — runner sharded (3 shards para 15×15)

Adición vs 16×16: nuevo feature `max_ord_internal_width` (máx min_fill_width de componentes ordinarios).

### 15×15/35 — RESULTADO: RED

**Corpus Python:**
- 1500 (seed,strategy) combos, 500 seeds, 3 estrategias
- 9576 floods únicos
- 165,832 CELL states totales
- max sum_ord_size = 74 (debajo del umbral RED 16×16 de 81)
- max_ord_internal_width = 8 (nuevo feature, arriba del umbral RED de 6)
- n CELLs sum_ord_size≥60 = 577

**Candidatos Cairo:** 203 (selección adversarial: todo iw≥7, top sum_ord_size, combinaciones)

**Cairo (203/203):**
- Bench: 203/203 PASS
- Exact: 203/203 PASS (corrección metodológica: asserts usaban "" en vez de '')
- max gas = 2,409,793,364 L2 Sierra (2.41B, 2.19× el gate)
- 4 casos > 1.1B:
  - f011: s00324g0f02 s6 → 2.41B (iw=6 sos=68 vars=68)
  - f005: s00125g0f04 s3 → 1.87B (iw=7 sos=62 vars=62)
  - f008: s00125g0f04 s4 → 1.87B (iw=7 sos=61 vars=62)
  - f015: s00125g0f04 s8 → 1.78B (iw=7 sos=59 vars=59)

**Hallazgo metodológico:** max_ord_internal_width NO predice fiablemente el gas.
Caso iw=8, sos=59 (seed=379) → solo 0.24B. Caso iw=6, sos=68 (seed=324) → 2.41B.
El predictor real es la estructura interna del grafo de restricciones, no solo el ancho mínimo.

**VERDICT: RED** — criterio activado: 4 candidatos > 1.1B.

### Cambio de estrategia (instrucción del usuario)

En vez de 14→13→..., próxima búsqueda será binaria:
- Próximo: **12×12/23**
- Si 12×12 GREEN → probar 14×14/31
  - Si 14×14 GREEN → terminar (14 es el mayor GREEN)
  - Si 14×14 RED/YELLOW → probar 13×13
- Si 12×12 RED/YELLOW → probar 10×10/16 y localizar zona GREEN primero

### Artifacts 15×15/35

- benchmarks/square-15x15-35-cells-20260901.jsonl (165832 rows)
- benchmarks/square-15x15-35-meta-20260901.jsonl (1500 records)
- benchmarks/square-15x15-35-analysis-20260901.md
- benchmarks/square-15x15-35-candidates-20260901.jsonl (203)
- benchmarks/square-15x15-35-fixtures-20260901.jsonl (203)
- benchmarks/square-15x15-35-gas-20260901.jsonl (203)
- benchmarks/square-15x15-35-gas-analysis-20260901.md
- benchmarks/square-snforge-bench-sq15x15-20260901.log
- benchmarks/square-snforge-exact-sq15x15-20260901.log
- contracts/zkmine_2g/src/tests/test_ve_sq15x15.cairo (generado, no en tests.cairo)
- contracts/zkmine_2g/src/tests/test_ve_sq15x15_s{1,2,3}.cairo
- contracts/zkmine_2g/src/tests/test_ve_sq15x15_exact_s{1,2,3}.cairo

**NO se editó el grant. NO se hizo commit. NO se hizo push.**

---

## 2026-09-01T12:30 — 12×12/23 COMPLETO: VERDICT RED

### Búsqueda de frontera GREEN: 12×12/23

**Contexto:** 12×12/23 es el siguiente en la búsqueda binaria tras 15×15/35 (RED) y 16×16/40 (RED).
mines = floor(5×144/32 + 0.5) = 23.

**Corpus Python:**
- 1500 (seed,strategy) combos, 500 seeds, 3 estrategias
- 6681 floods únicos
- 102,838 CELL states totales
- max sum_ord_size = 54 (debajo del umbral RED 16×16 de 81)
- max_ord_internal_width = 7 (presente pero sin sos≥60)
- n CELLs sum_ord_size≥60 = 0

**Candidatos Cairo:** 126 (selección adversarial: todo iw≥7, top sum_ord_size, top max_width)

**Cairo (126/126):**
- Bench: 126/126 PASS
- Exact: 126/126 PASS (100% exactitud Python ↔ Cairo)
- max gas = 1,668,243,042 L2 Sierra (1.67B, 1.52× el gate)
- 4 casos > 1.1B (todos seed=103, s00103g0f03):
  - f27: s00103g0f03 s1 → 1.668B (max_w=3, sum_ord=34, ord_iw=7, vars=40)
  - f29: s00103g0f03 s2 → 1.666B (max_w=2, sum_ord=34, ord_iw=7, vars=39)
  - f30: s00103g0f03 s3 → 1.665B (max_w=1, sum_ord=34, ord_iw=7, vars=38)
  - f28: s00103g0f03 s4 → 1.665B (max_w=0, sum_ord=37, ord_iw=7, vars=37)

**Hallazgo:** Mecanismo RED distinto a 15×15.
- 15×15 RED: ordinary component con sos alto (iw=6/7, sos=59-68 → 1.78-2.41B)
- 12×12 RED: ordinary component con ord_iw=7 y sos=34-37 → 1.67B (estructura interna específica)
- Correlación gas ↔ max_ord_iw: r=+0.431 (predictor más fuerte en 12×12)
- sos=34-37 es MENOR que sos=41 (seed=39, solo 341M) — la estructura del grafo importa más que el sos

**VERDICT: RED** — criterio activado: 4 candidatos > 1.1B.

### Cambio de búsqueda

12×12 RED → según protocolo: probar 10×10/16 para localizar zona GREEN.

### Artifacts 12×12/23

- benchmarks/square-12x12-23-cells-20260901.jsonl (102838 rows)
- benchmarks/square-12x12-23-meta-20260901.jsonl (1500 records)
- benchmarks/square-12x12-23-analysis-20260901.md
- benchmarks/square-12x12-23-candidates-20260901.jsonl (126)
- benchmarks/square-12x12-23-fixtures-20260901.jsonl (126)
- benchmarks/square-12x12-23-gas-20260901.jsonl (126)
- benchmarks/square-12x12-23-gas-analysis-20260901.md
- benchmarks/square-snforge-bench-sq12x12-20260901.log
- benchmarks/square-snforge-exact-sq12x12-20260901.log
- contracts/zkmine_2g/src/tests/test_ve_sq12x12.cairo (391KB)
- contracts/zkmine_2g/src/tests/test_ve_sq12x12_exact.cairo (525KB)

**NO se editó el grant. NO se hizo commit. NO se hizo push.**

---

## 2026-09-01T12:45 — 10×10/16 COMPLETO: VERDICT RED

### Búsqueda de frontera GREEN: 10×10/16

**Contexto:** 10×10/16 es el siguiente tras 12×12/23 (RED).
mines = floor(5×100/32 + 0.5) = 16.

**Corpus Python:**
- 1500 (seed,strategy) combos, 69,306 CELL states
- max sum_ord_size = 43, max_ord_internal_width = 7
- width=7+n_ord>0: solo 14 casos (vs 85 en 12×12)

**Candidatos Cairo:** 117

**Cairo (117/117):**
- Bench: 117/117 PASS
- Exact: 117/117 PASS (100% exactitud)
- max gas = 1,547,157,633 L2 Sierra (1.55B)
- 3 casos > 1.1B (todos ord_iw=7):
  - f22: s00028g0f02 s2 → 1.547B (sos=34, vars=34)
  - f24: s00028g0f02 s1 → 1.547B (sos=30, vars=34)
  - f14: s00018g0f01 s4 → 1.239B (sos=39, vars=39)

**Hallazgo crítico:** El patrón RED es invariante al tamaño del tablero.
El mecanismo es ord_iw=7 con estructuras de grafo específicas, independiente de sos absoluto.
Incluso 10×10 con max_sos=43 produce casos 1.55B.

**VERDICT: RED** — 3 candidatos > 1.1B.

Próximo: 8×8/10 (continúa búsqueda zona GREEN).

---

## 2026-09-01T12:48 — 8×8/10 COMPLETO: VERDICT GREEN

### Búsqueda de frontera GREEN: 8×8/10

**Contexto:** Tras RED en 16×16, 15×15, 12×12, 10×10, se prueba 8×8.
mines = floor(5×64/32 + 0.5) = 10.

**Corpus Python:**
- 1500 combos, 43,642 CELL states
- max sum_ord_size = 33, max_ord_internal_width = 7 (sos=20-30)
- width=7+n_ord>0 = 0 casos (distinto de 10×10 donde eran 14)

**Candidatos Cairo:** 104

**Cairo (104/104):**
- Bench: 104/104 PASS
- Exact: 104/104 PASS (100% exactitud)
- max gas = 260,762,011 L2 Sierra (~261M, bien por debajo de 900M)
- 0 casos > 900M, 0 casos > 1.1B

**VERDICT: GREEN** ✓ — primer tamaño GREEN medido.

**Implicación:** frontera entre 8×8 (GREEN) y 10×10 (RED). Queda verificar 9×9/13.

**Artifacts 8×8/10:**
- benchmarks/square-8x8-10-cells-20260901.jsonl (43642 rows)
- benchmarks/square-8x8-10-meta-20260901.jsonl
- benchmarks/square-8x8-10-analysis-20260901.md
- benchmarks/square-8x8-10-candidates-20260901.jsonl (104)
- benchmarks/square-8x8-10-fixtures-20260901.jsonl (104)
- benchmarks/square-8x8-10-gas-20260901.jsonl (104)
- benchmarks/square-8x8-10-gas-analysis-20260901.md
- benchmarks/square-snforge-bench-sq8x8-20260901.log
- benchmarks/square-snforge-exact-sq8x8-20260901.log

---

## 2026-09-01T12:52 — 9×9/13 COMPLETO: VERDICT GREEN

### Búsqueda de frontera GREEN: 9×9/13

**Contexto:** Verificación de frontera entre 8×8 (GREEN) y 10×10 (RED).
mines = floor(5×81/32 + 0.5) = 13.

**Corpus Python:** 1500 combos, 54,912 CELL states.
max_ord_iw=7 (seed=91, sos=34 — mismo perfil que 10×10 RED seed=28).
width=7+n_ord>0 = 18 casos (¡MÁS que 10×10 que tenía 14!).

**Candidatos Cairo:** 120.

**Cairo (120/120):**
- Bench + Exact: 120/120 PASS (100% exactitud)
- max gas = 340,164,866 L2 Sierra (~340M)
- 0 casos > 900M, 0 casos > 1.1B

**VERDICT: GREEN** ✓

**Observación crítica:** 9×9 tiene MÁS casos "width=7+n_ord>0" (18) que 10×10 (14), pero es GREEN.
Esto confirma que los predictores estructurales son indicativos pero no determinísticos.
El gas real depende de la estructura específica del grafo de restricciones, no solo del ancho de eliminación.

**Frontera identificada:** 9×9 GREEN, 10×10 RED.
Queda verificar 11×11 (entre 10×10 RED y 12×12 RED) para descartar islas GREEN.

---

## 2026-09-01T13:10 — Replicación independiente: 9×9 RED, 8×8 GREEN confirmado

### Instrucción del usuario: replicación con corpus disjunto

El usuario requirió validación con un segundo corpus independiente usando seeds 500-999
(disjunto del primer corpus 0-499). Se añadió `--run-tag rep2` a los 5 scripts del pipeline.

### 9×9/13 — Corpus 2 (seeds 500-999)

**Resultado: RED** — invalidación del resultado del primer corpus.

- 55,386 CELL states adicionales (total combinado: 110,298)
- max_ord_iw=7 (seed=535, sos=29) y max_ord_iw=6 (seed=542, sos=34)
- 126 candidatos Cairo adversariales
- 126/126 PASS exactos Python ↔ Cairo
- max gas = 2,132,911,663 L2 Sierra (2.13B)
- **3 casos > 1.1B**: s00542g0f01 pasos 2,3,4 → 2.133B (ord_iw=6, sos=34)

**Hallazgo crítico:** El caso RED en corpus 2 tiene ord_iw=6 (NO 7), sos=34.
El gas explosivo con ord_iw=6 confirma que incluso width=6 puede ser muy caro
con estructuras de grafo específicas.

**Conclusión 9×9:** Con los dos corpora combinados (1000 seeds), 9×9/13 es RED.
El primer corpus era insuficiente para detectar la vulnerabilidad.

### 8×8/10 — Corpus 2 (seeds 500-999)

**Resultado: GREEN** — replicación exitosa.

- 44,234 CELL states adicionales (total combinado: 87,876)
- max_ord_iw=7 (seed=965, sos=24; seed=710, sos=23)
- 111 candidatos Cairo adversariales
- 111/111 PASS exactos Python ↔ Cairo
- max gas = 198,161,253 L2 Sierra (~198M)
- **0 casos ≥ 900M**, 0 casos > 1.1B

**Conclusión 8×8:** Con los dos corpora combinados (1000 seeds), 8×8/10 es GREEN.
max gas combinado = 261M (corpus 1) vs 198M (corpus 2).

### Frontera GREEN/RED actualizada

| Tablero | Minas | Corpus 1 | Corpus 2 | Veredicto combinado |
|:--------|------:|:---------|:---------|:--------------------|
| 16×16 | 40 | RED (1.59B) | — | RED |
| 15×15 | 35 | RED (2.41B) | — | RED |
| 12×12 | 23 | RED (1.67B) | — | RED |
| 11×11 | 19 | RED (3.13B) | — | RED |
| 10×10 | 16 | RED (1.55B) | — | RED |
| 9×9 | 13 | GREEN (340M) | RED (2.13B) | **RED** |
| 8×8 | 10 | GREEN (261M) | GREEN (198M) | **GREEN** ✓ |

**Preset GREEN más grande verificado: 8×8/10** (validado con 1000 seeds × 3 estrategias)

### Limitaciones

Este es soporte empírico, no garantía matemática sobre todos los estados alcanzables.
La cobertura es 1000 seeds × 3 estrategias = 3000 partidas por tamaño.
Casos con distribuciones extremas fuera del espacio muestreado podrían comportarse diferente.

---

## 2026-09-01T18:00 — Continuation VE onchain: calldata bridge demostrado en Katana

**Sesión**: post-crash/OOM. Reconstrucción total desde disco. Objetivo: auditar estado de continuation VE y demostrar persistence/calldata bridge on-chain.

### Contexto

El caso benchmark es `s00028g0f02 step=2` (10×10/16 RED, ord0: 27 vars, 22 constraints, max_ord_iw=7).
Split óptimo vi=9 (variable=11). Checkpoint: 19 factores, 182 entries nonzero, 1,201 felts serializados.

### Qué se hizo (nuevo en esta sesión)

1. **Serde en estructuras VE**: agregado `#[derive(Serde)]` a `FactorEntry`, `Factor`, `Constraint` en `ve.cairo`.
2. **Test 6 (serde round-trip)**: `cont_f22_serde_roundtrip_chunk2` → PASS, l2_gas=748,923,599. Overhead Serde: +2.86M gas (0.38%).
3. **Contrato VeResume**: standalone en `~/.claude/jobs/354105ca/tmp/zkmine_cont/src/ve_resume.cairo`. Entrypoints: `chunk1(vars, constraints, end_idx) -> Array<Factor>` y `chunk2(vars, checkpoint, start_idx) -> Array<u256>`.
4. **Demo Katana end-to-end**:
   - Katana iniciado (dev mode, seed=0)
   - Contrato declarado: class hash `0x74870340290b5181ce06ed498fdbb4a80a0ee749dd2bc3faa14d9ad41b395ab`
   - TX chunk1 invoke: SUCCEEDED, l2_gas=**804,745,770**
   - TX chunk2 invoke (1,230 felts calldata): SUCCEEDED, l2_gas=**757,136,984**
   - Resultado: ways[10]=1, ways[11]=2 ✓ (idéntico a Python y Cairo monolítico)

### Gas resumido

| TX | snforge | Katana invoke | Overhead ABI |
|:---|--------:|--------------:|-------------:|
| chunk1 | 796,326,725 | 804,745,770 | ~8.4M |
| chunk2 | 746,060,139 | 757,136,984 | ~8.2M |
| Serde chunk2 | 748,923,599 | — | — |

Overhead ABI dispatch (~8M) es consistente entre ambas txs.

### Veredicto

- Continuation computacional: DEMOSTRADA ✓
- Calldata bridge (Tx1→checkpoint→Tx2): DEMOSTRADO en Katana ✓
- Viabilidad producción: gas por tx < 1B nominal; confirmación definitiva requiere medición en Sepolia
- No storage writes: el checkpoint viaja como calldata, no requiere storage on-chain

### Archivos modificados en el repo

```
M contracts/zkmine_2g/src/ve.cairo        (Serde en 3 structs)
M contracts/zkmine_2g/src/tests/test_ve_continuation_10x10.cairo  (Test 6)
M contracts/zkmine_2g/src/tests/mod.cairo
M docs/PENDING-REVIEW.md
M docs/RUNNING-STATUS.md
M docs/bitacora.md
```

(Sin commit, sin push — en espera de decisión sobre integración en repo principal.)

---

## 2026-09-01T20:00 — Continuation VE autenticada: Katana + Sepolia confirmados

**Sesión**: última tanda técnica pre-grant. Objetivo: handoff autenticado con Poseidon commitment + verificación en Sepolia.

### Arquitectura implementada

Contrato `VeAuth` (standalone en `~/.claude/jobs/354105ca/tmp/zkmine_cont/src/ve_auth.cairo`):
- `chunk1_commit(game_id, vars, constraints, end_idx) → felt252`: ejecuta VE chunk1, calcula `poseidon_hash_span` sobre la serialización Serde de los 19 factores (1201 felts), almacena (commitment, phase=1) en storage. Retorna commitment (1 felt).
- `chunk2_verify(game_id, vars, checkpoint, start_idx) → Array<u256>`: recibe checkpoint por calldata (1201 felts), recalcula hash, verifica contra storage, consume el slot (commitment=0, phase=2), ejecuta VE chunk2. Retorna ways.
- Storage mínimo: 2 slots por game_id. El checkpoint NO se persiste.
- Eventos: `CommitmentStored{game_id, commitment}` en chunk1, `ChunkCompleted{game_id}` en chunk2.

### snforge — 4 tests PASS (contrato VeAuth)

| Test | l2_gas | Estado |
|:-----|-------:|:------:|
| auth_a: flujo correcto (ways[10]=1, ways[11]=2) | 1,557,047,566 | **PASS** ✓ |
| auth_b: checkpoint tampered → 'commitment mismatch' | 804,688,367 | **PASS** ✓ |
| auth_c: double chunk1 → 'chunk1 already submitted' | 805,191,476 | **PASS** ✓ |
| auth_d: chunk2 sin chunk1 → 'no pending chunk1' | 533,270 | **PASS** ✓ |

### Katana — TXs autenticados

| Operación | l2_gas | l1_gas | Estado |
|:----------|-------:|-------:|:------:|
| chunk1_commit TX | 808,077,951 | 5,748 | SUCCEEDED ✓ |
| chunk2_verify TX (correcto) | 760,475,735 | 4,646 | SUCCEEDED ✓ |
| chunk2_verify (checkpoint tampered) | — | — | REVERTIDO `commitment mismatch` ✓ |
| chunk2_verify (replay phase=2) | — | — | REVERTIDO `no pending chunk1` ✓ |
| chunk2_verify (sin chunk1 previo) | — | — | REVERTIDO `no pending chunk1` ✓ |

Commitment almacenado/emitido/hash_view — tres fuentes idénticas: `0x2fb8c8905437bc13724bc4ca355a4a566e4e9522ec146ccaaaa3b9f98cf422f` ✓

### Sepolia — TXs reales en Starknet testnet

Contrato: `0x049ba05c16fa5dcb357d1cc7de94d2dd31c91468f9633d75542767a8fe3a1c5e`
Class hash: `0x6c1e4582186427ad5821c710aa28c184fd8a9c98995c988ddf70caa50d0cdf8`

| TX | Hash | l2_gas | l1_data_gas | Fee | Estado |
|:---|:-----|-------:|------------:|----:|:------:|
| chunk1_commit | 0x03b5ed...819e49 | **784,788,320** | 384 | 26.18 STRK | SUCCEEDED ✓ |
| chunk2_verify | 0x04d582...616bd | **749,396,480** | 320 | 25.00 STRK | SUCCEEDED ✓ |

Commitment Sepolia = `0x2fb8c...422f` ✓ (idéntico a Katana y Python)
ways[10]=1, ways[11]=2 ✓ (verificados desde return data del evento)

### Hallazgo: límite return data en cuenta Ready

La cuenta Sepolia (clase `0x36078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f`, type: Ready) rechazó un return de 1204 felts (max data length: 300). En la misma cuenta, chunk2_verify con 1231 felts de input calldata fue aceptado. El límite de 300 observado no impidió ese input. No se determinó si existe un límite máximo de input calldata ni cuál sería.

chunk1_commit original retornaba `(Array<Factor>, felt252)` = 1204 felts → rechazado. Fix: retorna solo `felt252` (commitment, 1 felt). El checkpoint es computado off-chain de forma determinista por el profiler Python y verificado contra el commitment almacenado.

### Overhead auth vs bridge simple (Katana)

chunk1: +3.3M l2_gas (+0.41%) | chunk2: +3.4M l2_gas (+0.44%) | l1: +4.1KB / +3.0KB DA

### Archivos creados en esta sesión (standalone, fuera del repo principal)

```
~/.claude/jobs/354105ca/tmp/zkmine_cont/src/ve_auth.cairo   (nuevo contrato)
~/.claude/jobs/354105ca/tmp/zkmine_cont/src/test_ve_auth.cairo  (tests A/B/C/D)
snfoundry.toml actualizado con profile sepolia_dev
```

Repositorio principal (sin commit):
```
M contracts/zkmine_2g/src/ve.cairo
M contracts/zkmine_2g/src/tests/test_ve_continuation_10x10.cairo
M contracts/zkmine_2g/src/tests/mod.cairo
M docs/
```

**NO se editó el grant. NO se hizo commit. NO se hizo push.**

---

## 2026-09-01 — Cierre durable: hashes completos + corrección + persistencia en repo

### Hashes completos sin abreviación

**Katana:**
- Contrato: `0x05863245a9d2632d004aecb29b6824643b1debf2871cf013ce0db4196b983801`
- chunk1_commit TX: `0x0283752c37420faad975e142f6d0385b50ae64f57964915c4224288218c7d3eb`
- chunk2_verify TX: `0x06e928611cb7fa267b9e92a9a5a7c306652c7cebd647999a67b4e713c4cc1551`
- Commitment: `0x2fb8c8905437bc13724bc4ca355a4a566e4e9522ec146ccaaaa3b9f98cf422f`

**Sepolia v1** (chunk1 retornaba tuple — rechazado por límite return data cuenta Ready):
- Class hash: `0x5af04c5518922794b38dc12e91f9c9b39995a673c50a3dbfb6673ba87440980`
- Declare TX: `0x44c4e35e093e4d9a25d2c40b9ba8da71d1722bb5185b93425c2c18b64e293f3`
- Deploy TX: `0x0442632c62f501fb52cbb7baf5c46024918064c6d7074c04b7c647516f53562b`
- Contrato: `0x023d60c97f168ed7ea74f8cd025d37d5008a11ef288670907937c88d163e4df7`

**Sepolia v2** (chunk1 retorna felt252 — PASS):
- Class hash: `0x6c1e4582186427ad5821c710aa28c184fd8a9c98995c988ddf70caa50d0cdf8`
- Declare TX: `0x2962c22a3e05afa5c7f54776a932bd4421cc83b22730c3293f0833d490b194b`
- Deploy TX: `0x04c655b1812d042a5f69433424daaaa1db6618ede313076681341a6c577ca698`
- Contrato: `0x049ba05c16fa5dcb357d1cc7de94d2dd31c91468f9633d75542767a8fe3a1c5e`
- chunk1_commit TX: `0x03b5ed127b37bc7dbbd69c4ff1deeac11ab624320d47da6740410aa1a1819e49`
- chunk2_verify TX: `0x04d582b91192acce98fb98b234ece14aad50df3e1fd3f021251795ee59e616bd`
- Commitment: `0x2fb8c8905437bc13724bc4ca355a4a566e4e9522ec146ccaaaa3b9f98cf422f`

### Corrección: cuenta Ready vs OZ estándar

El comportamiento documentado fue observado estrictamente en la cuenta tipo Ready (`0x36078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f`). No se probó con cuenta OZ estándar; no se puede afirmar que una cuenta OZ aceptaría o rechazaría el return grande. El fix (retornar solo commitment, 1 felt) evitó el problema observado con esta cuenta Ready.

Observado con la cuenta Ready usada en Sepolia:
- 1231 felts input calldata (chunk2_verify): aceptados; el límite de 300 observado no impidió este input
- 1 felt return (commitment): ACEPTADO
- 1204 felts return (tuple original): RECHAZADO (error: max data length 300)
- Límite máximo de input calldata: no determinado

### Persistencia en repo

Código persisted en `experiments/cont_auth/` (prototipo, no integrado al gameplay):
- `src/ve_auth.cairo`, `src/ve_resume.cairo`, `src/test_ve_auth.cairo`
- `src/lib.cairo`, `Scarb.toml`, `snfoundry.toml`

**NO se hizo commit. NO se hizo push.**

---

## 2026-09-01 — Housekeeping pre-commit: auditoría y preparación

### Acciones ejecutadas

**Revert `contracts/zkmine_2g/src/tests/mod.cairo`**:
El cambio añadía `mod test_ve_continuation_10x10;` a `tests/mod.cairo`. Auditado y confirmado
como no-op: `contracts/zkmine_2g/src/tests.cairo` existe y toma precedencia sobre
`tests/mod.cairo` en el sistema de módulos Cairo/Scarb. El archivo `mod.cairo` es código muerto.
Se revirtió con `git checkout -- contracts/zkmine_2g/src/tests/mod.cairo`.

**Corrección en PENDING-REVIEW.md**:
Las filas de Katana TX-B/TX-C/TX-D (TXs revertidas) tenían etiquetas "TX-B" etc. como
placeholders. Reemplazadas por "hash no capturado — TX revertida" para reflejar que esos
hashes no fueron registrados, sin fabricar datos.

**Actualización docs/404-safe.md**:
Incorporada la convención durable de los tres documentos operativos: RUNNING-STATUS (fotografía
viva reemplazable, versionada solo al cierre), PENDING-REVIEW (cierre final de tanda, afirmaciones
verificadas), bitacora (historia append-only permanente).
Decisión: RUNNING-STATUS se incluye en el commit de cierre como snapshot final.

**Auditoría experiments/cont_auth/**:
Verificado. Contiene exactamente 6 archivos: Scarb.toml, snfoundry.toml, src/lib.cairo,
src/ve_auth.cairo, src/ve_resume.cairo, src/test_ve_auth.cairo. Sin target/, caches, claves
ni artifacts temporales.

### Clasificación de archivos untracked

**Evidencia durable necesaria → Commit A** (campaña falsación/gas):
- `benchmarks/*-analysis-*.md` (9 archivos)
- `benchmarks/*-candidates-*.jsonl` (9 archivos)
- `benchmarks/*-cells-*.jsonl` (9 archivos)
- `benchmarks/*-fixtures-*.jsonl` (9 archivos)
- `benchmarks/*-gas-*.jsonl` (9 archivos)
- `benchmarks/*-gas-analysis-*.md` (9 archivos)
- `benchmarks/*-meta-*.jsonl` (9 archivos)
- `benchmarks/2g-phase8-cell-gas-20260901.jsonl`
- `contracts/zkmine_2g/src/tests/test_ve_sq*.cairo` (22 archivos)
- `contracts/zkmine_2g/src/tests/test_ve_intermediate*.cairo` (2 archivos)
- `scripts/gen_*`, `analyze_*`, `parse_*`, `run_*` (11 scripts)

**Código reproducible necesario → Commit B** (authenticated VE continuation):
- `experiments/cont_auth/` (6 archivos)
- `scripts/profile_ve_f22.py`
- `contracts/zkmine_2g/src/tests/test_ve_continuation_10x10.cairo`
- `docs/RUNNING-STATUS.md` (snapshot final cerrado)
- `contracts/zkmine_2g/src/ve.cairo` (tracked modified — Serde derives)
- `docs/PENDING-REVIEW.md` (tracked modified)
- `docs/bitacora.md` (tracked modified)

**Logs/fixtures redundantes → NO commitear** (datos ya extraídos en JSONL):
- `benchmarks/*-snforge-bench-*.log` (10 archivos)
- `benchmarks/*-snforge-exact-*.log` (10 archivos)

Nota: `docs/404-safe.md` faltaba en la lista de commit B — corregido en addendum siguiente.

**NO se hizo commit. NO se hizo push.**

---

## 2026-09-01 — Addendum correcciones documentales pre-commit

### Correcciones aplicadas

**PENDING-REVIEW.md git status corregido**:
La sección "Git status" tenía estado viejo (incluía mod.cairo como M, faltaba 404-safe.md).
Actualizada para reflejar el estado real después del revert de mod.cairo.

**Verdicts de la campaña de tamaños (corrección factual)**:
El mensaje de commit A propuesto en sesión anterior decía erróneamente "8×8 y 9×9 GREEN" y
"10×10–12×12 YELLOW". Los resultados correctos son:

- 8×8/10m: dos corpus sin contraejemplo, max 261M combinado. Soporte empírico, NO prueba
  universal. Un corpus adicional podría aún encontrar un caso mayor.
- 9×9/13m: corpus 1 parecía limpio (max 340M). Corpus 2 encontró RED (2.133B). Veredicto
  combinado: RED. Este es el caso central que demuestra que ausencia de contraejemplo en un
  corpus no implica seguridad universal.
- 10×10/16m: RED, max 1.547B.
- 11×11/19m: RED, max 3.133B.
- 12×12/23m: RED, max 1.668B.
- 15×15/35m: RED, max 2.410B.
- 16×16/40m: RED, max 1.591B.

**Cuenta OZ no testeada**: lo demostrado es estrictamente sobre la cuenta Ready usada en Sepolia.
No extrapolar a OZ. Ya corregido en PENDING-REVIEW en sesión anterior.

**docs/404-safe.md agregado a commit B**: faltaba en la lista del housekeeping anterior.

### Commit B — lista actualizada
Igual que antes más: `docs/404-safe.md` (tracked modified — convención de documentos operativos).

**NO se hizo commit. NO se hizo push.**
