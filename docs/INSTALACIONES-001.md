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

### 2. Starknet Foundry 0.51.0
Testing y despliegue de contratos Cairo. Incluye `snforge` (test runner) y `sncast` (CLI de interacción con Starknet).

```
snforge 0.51.0
sncast 0.51.0
```

- **Instalación:** `snfoundryup -v 0.51.0` (script oficial) + `asdf install starknet-foundry 0.51.0` + `asdf global starknet-foundry 0.51.0`
- **Nota:** El instalador oficial (`snfoundryup`) colocó los binarios en `~/.local/bin`, pero el shim de asdf tenía precedencia. Se resolvió instalando la versión también vía asdf.
- **Dependencia adicional instalada:** `universal-sierra-compiler v2.9.1`

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

### 4. katana 1.7.0
Blockchain local de desarrollo para Starknet (nodo Devnet de Dojo).

```
katana 1.7.0 (3135f78)
features: -native
built on: 2025-10-01T21:03:18.224704272Z
```

- **Instalación:** descarga directa desde `dojoengine/katana` (repo separado del monorepo dojo)
  ```
  curl -L https://github.com/dojoengine/katana/releases/download/v1.7.0/katana_v1.7.0_linux_amd64.tar.gz \
    | tar -xz -C ~/.local/bin
  ```
- **Nota:** Katana no está incluido en el release `sozo/v1.8.7` ni en ningún tarball del monorepo dojo post-1.5.0. Se distribuye independientemente desde `github.com/dojoengine/katana`.

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
| snforge | 0.51.0 | asdf | `~/.asdf/shims/snforge` |
| sncast | 0.51.0 | asdf | `~/.asdf/shims/sncast` |
| sozo | 1.8.7 | asdf | `~/.asdf/shims/sozo` |
| katana | 1.7.0 | manual | `~/.local/bin/katana` |
| Argent X | — | browser | Sepolia: `0x01C0…7531` |

---

## Pendiente

- Contrato de prueba Cartridge VRF (paso siguiente).
- Lógica de juego zk Minesweeper.
