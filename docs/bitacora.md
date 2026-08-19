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
