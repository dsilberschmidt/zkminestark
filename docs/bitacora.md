# Bitácora — zkminestark

Registro histórico append-only. Cada entrada es el contenido de `pending_review.md`
al momento de ser reemplazado, con encabezado de fecha/hora.

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
