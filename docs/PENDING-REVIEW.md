# Continuation VE autenticada — Cierre final pre-grant (2026-09-01)

## Qué se intentó

Demostrar continuation VE con handoff criptográficamente autenticado en Katana y Sepolia:

1. Diseñar e implementar contrato `VeAuth` con Poseidon commitment (calldata bridge + hash).
2. Verificar en snforge todos los escenarios positivos y negativos (tamper, replay, orden incorrecto).
3. Ejecutar en Katana con receipts reales.
4. Ejecutar en Starknet Sepolia con la misma arquitectura y fixture.

---

## Arquitectura del handoff autenticado

```
Tx1 — chunk1_commit(game_id, vars, constraints, end_idx=9):
  1. Ejecuta count_ordinary_component_start → checkpoint (Array<Factor>, 19 factores)
  2. Serializa checkpoint (Serde) → 1201 felts
  3. commitment = poseidon_hash_span(1201 felts)
  4. Escribe storage: commitment[game_id] = commitment, phase[game_id] = 1
  5. Emite CommitmentStored{game_id, commitment}
  6. Retorna: felt252 (commitment, 1 felt)

Off-chain:
  - Python profiler computa checkpoint determinísticamente
  - Lee get_commitment(game_id) → verifica coincidencia con pre-computado
  - Si coincide: checkpoint autenticado sin transmitirlo en Tx1

Tx2 — chunk2_verify(game_id, vars, checkpoint, start_idx=9):
  1. Assert phase[game_id] == 1 (chunk1 previo existe)
  2. Serializa checkpoint recibido → Serde → 1201 felts
  3. actual = poseidon_hash_span(1201 felts)
  4. Assert actual == commitment[game_id]  ← verificación criptográfica
  5. Limpia: commitment = 0, phase = 2
  6. Emite ChunkCompleted{game_id}
  7. Ejecuta count_ordinary_component_resume → retorna ways (Array<u256>)
```

**Storage por game_id**: 2 slots (commitment felt252 + phase u8). Checkpoint NO almacenado.  
**Hash**: `core::poseidon::poseidon_hash_span` sobre los 1201 felts Cairo-serializados.

---

## Qué quedó demostrado

### snforge — 4 tests PASS

| Test | l2_gas | Estado |
|:-----|-------:|:------:|
| `auth_a_correct_flow_ways_exact` | 1,557,047,566 | **PASS** ✓ |
| `auth_b_tampered_checkpoint_reverts` | 804,688,367 | **PASS** ✓ |
| `auth_c_double_chunk1_reverts` | 805,191,476 | **PASS** ✓ |
| `auth_d_no_chunk1_reverts` | 533,270 | **PASS** ✓ |

Test A verifica: phase 0→1→2, commitment almacenado/verificado/limpiado, ways[10]=1, ways[11]=2.  
Tests B/C/D verifican: los tres vectores de ataque revocan con el mensaje correcto.

### Katana — TXs autenticados

Contrato: `0x05863245a9d2632d004aecb29b6824643b1debf2871cf013ce0db4196b983801`  
Commitment observado (3 fuentes — evento, storage, hash_checkpoint view):  
`0x2fb8c8905437bc13724bc4ca355a4a566e4e9522ec146ccaaaa3b9f98cf422f`

| Operación | TX hash | l2_gas | l1_gas | Estado |
|:----------|:--------|-------:|-------:|:------:|
| chunk1_commit | `0x0283752c37420faad975e142f6d0385b50ae64f57964915c4224288218c7d3eb` | **808,077,951** | 5,748 | SUCCEEDED ✓ |
| chunk2_verify (correcto) | `0x06e928611cb7fa267b9e92a9a5a7c306652c7cebd647999a67b4e713c4cc1551` | **760,475,735** | 4,646 | SUCCEEDED ✓ |
| chunk2_verify (checkpoint tampered) | *(hash no capturado — TX revertida)* | — | — | REVERTIDO `commitment mismatch` ✓ |
| chunk2_verify (replay, phase=2) | *(hash no capturado — TX revertida)* | — | — | REVERTIDO `no pending chunk1` ✓ |
| chunk2_verify (sin chunk1) | *(hash no capturado — TX revertida)* | — | — | REVERTIDO `no pending chunk1` ✓ |

ways[10]=1, ways[11]=2 ✓

### Sepolia — TXs reales en Starknet testnet público

Account: `0x77bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192` (tipo: Ready)

**Deploy v1** (chunk1 retornaba tuple — fallido por límite return data):  
Class hash v1: `0x5af04c5518922794b38dc12e91f9c9b39995a673c50a3dbfb6673ba87440980`  
Declare TX v1: `0x44c4e35e093e4d9a25d2c40b9ba8da71d1722bb5185b93425c2c18b64e293f3`  
Deploy TX v1: `0x0442632c62f501fb52cbb7baf5c46024918064c6d7074c04b7c647516f53562b`  
Contrato v1: `0x023d60c97f168ed7ea74f8cd025d37d5008a11ef288670907937c88d163e4df7`

**Deploy v2** (chunk1 retorna solo felt252 — usado para el PASS):  
Class hash v2: `0x6c1e4582186427ad5821c710aa28c184fd8a9c98995c988ddf70caa50d0cdf8`  
Declare TX v2: `0x2962c22a3e05afa5c7f54776a932bd4421cc83b22730c3293f0833d490b194b`  
Deploy TX v2: `0x04c655b1812d042a5f69433424daaaa1db6618ede313076681341a6c577ca698`  
Contrato v2: `0x049ba05c16fa5dcb357d1cc7de94d2dd31c91468f9633d75542767a8fe3a1c5e`

| TX | Hash | l2_gas | l1_data_gas | Fee (testnet) | Estado |
|:---|:-----|-------:|------------:|:--------------|:------:|
| chunk1_commit | `0x03b5ed127b37bc7dbbd69c4ff1deeac11ab624320d47da6740410aa1a1819e49` | **784,788,320** | 384 | 26.18 STRK | SUCCEEDED ✓ |
| chunk2_verify | `0x04d582b91192acce98fb98b234ece14aad50df3e1fd3f021251795ee59e616bd` | **749,396,480** | 320 | 25.00 STRK | SUCCEEDED ✓ |

Commitment Sepolia = `0x2fb8c8905437bc13724bc4ca355a4a566e4e9522ec146ccaaaa3b9f98cf422f` ✓  
(idéntico a Katana, Python, y Katana hash_checkpoint view — determinismo verificado)

ways[10]=1, ways[11]=2 verificados desde el return data del evento de Tx2 ✓

---

## Hallazgo: límite de return data en cuenta Ready

El primer intento de chunk1_commit en Sepolia falló con:  
`Exceeded the maximum data length, data length: 1204, max data length: 300`

La cuenta tipo Ready (clase `0x36078334...`) impone un límite de **300 felts de return data** por call en `__execute__`. chunk1_commit original retornaba `(Array<Factor>, felt252)` = 1204 felts → rechazado.

**Fix aplicado**: chunk1_commit retorna solo `felt252` (commitment, 1 felt). El checkpoint se computa off-chain de forma determinista y se verifica contra el commitment almacenado.

**Input calldata observado**: en la cuenta Ready usada, chunk2_verify con 1231 felts de input calldata fue aceptado. El límite de 300 observado en el intento anterior no impidió ese input. No se determinó el límite máximo de input calldata ni si existe uno.

**Nota sobre tipos de cuenta**: el comportamiento documentado corresponde estrictamente a la cuenta Ready (`0x36078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f`) usada en Sepolia. No se probó con cuenta OpenZeppelin estándar; no se puede afirmar que una cuenta OZ aceptaría o rechazaría el return grande. El fix (retornar solo commitment) evitó el problema observado con esta cuenta Ready y es arquitectónicamente limpio: menor surface de retorno, separación clara de responsabilidades.

---

## Tabla gas consolidada

| Métrica | snforge | Katana invoke | Sepolia invoke |
|:--------|--------:|--------------:|---------------:|
| chunk1 l2_gas | 1,557,047,566 (A+B) | 808,077,951 | 784,788,320 |
| chunk2 l2_gas | — (parte de test A) | 760,475,735 | 749,396,480 |
| chunk1 l1_gas/data | — | 5,748 l1_gas | 384 l1_data_gas |
| chunk2 l1_gas/data | — | 4,646 l1_gas | 320 l1_data_gas |
| chunk1 overhead auth vs bridge | — | +3,332,181 (+0.41%) | N/A (distinto build) |
| chunk2 overhead auth vs bridge | — | +3,338,751 (+0.44%) | N/A |

Ambas TXs en Sepolia por debajo del 1B l2_gas. Gate de referencia 1.1B: **PASS**.

---

## Qué sigue pendiente

- **Test negativo en Sepolia (tamper)**: no ejecutado; cubierto completamente por Katana.
- **Gas ceiling exacto de Starknet mainnet**: Sepolia confirma viabilidad; mainnet requiere medición directa.
- **Integración en flujo CELL completo**: continuation actual cubre solo `count_ordinary_component` (ord0). El pipeline CELL completo (VCLS + multi-componente) queda como trabajo de integración para el grant.
- **Contrato VeAuth en repo principal**: persisted en `experiments/cont_auth/` como prototipo. Integración en contrato de gameplay cuando se defina la arquitectura definitiva.
- **Cuenta OZ en Sepolia**: no probado. La cuenta Ready funcionó para el propósito de la demo; OZ eliminaría el workaround del return type.

---

## Código/artifacts creados

| Archivo | Descripción |
|:--------|:------------|
| `experiments/cont_auth/src/ve_auth.cairo` | Contrato VeAuth (prototipo, persisted en repo) |
| `experiments/cont_auth/src/ve_resume.cairo` | Contrato VeResume (helper sin estado) |
| `experiments/cont_auth/src/test_ve_auth.cairo` | Tests snforge A/B/C/D |
| `experiments/cont_auth/src/lib.cairo` | Módulo raíz del paquete standalone |
| `experiments/cont_auth/Scarb.toml` | Paquete con zkmine_2g como path dep relativo |
| `experiments/cont_auth/snfoundry.toml` | Profiles katana_dev + sepolia_dev |
| `contracts/zkmine_2g/src/ve.cairo` | Serde en FactorEntry/Factor/Constraint |
| `contracts/zkmine_2g/src/tests/test_ve_continuation_10x10.cairo` | Test 6 serde round-trip |

---

## Veredicto final pre-grant

| Hito | Estado |
|:-----|:------:|
| Continuation computacional chunk1→chunk2 | DEMOSTRADA ✓ |
| Serialización Serde checkpoint | DEMOSTRADA ✓ |
| Calldata bridge básico Katana | DEMOSTRADA ✓ (tanda anterior) |
| Handoff con Poseidon commitment Katana | DEMOSTRADA ✓ |
| Seguridad: tamper → revert | DEMOSTRADA ✓ (snforge + Katana) |
| Seguridad: replay → revert | DEMOSTRADA ✓ (snforge + Katana) |
| Seguridad: orden incorrecto → revert | DEMOSTRADA ✓ (snforge + Katana) |
| Continuation autenticada en Sepolia | **DEMOSTRADA** ✓ |
| Gas < 1B por TX en Sepolia | **DEMOSTRADO** ✓ (785M + 749M) |
| Exactitud: ways[10]=1, ways[11]=2 en Sepolia | **DEMOSTRADO** ✓ |
| Limite return data cuenta Ready | DOCUMENTADO (fix aplicado) ✓ |

**La fase técnica pre-grant queda CERRADA.**

---

## Git status (al cierre de housekeeping)

```
 M contracts/zkmine_2g/src/ve.cairo
 M docs/404-safe.md
 M docs/PENDING-REVIEW.md
 M docs/bitacora.md
?? benchmarks/           (JSONL + análisis .md de 9 corpus; 18 .log excluidos del commit)
?? contracts/zkmine_2g/src/tests/test_ve_sq*.cairo      (22 archivos)
?? contracts/zkmine_2g/src/tests/test_ve_intermediate*.cairo  (2 archivos)
?? contracts/zkmine_2g/src/tests/test_ve_continuation_10x10.cairo
?? docs/RUNNING-STATUS.md
?? experiments/cont_auth/    (6 archivos — prototipo VeAuth)
?? scripts/              (12 scripts)
(contracts/zkmine_2g/src/tests/mod.cairo: revertido — era no-op)
(sin commit, sin push)
```
