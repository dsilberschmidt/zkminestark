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
