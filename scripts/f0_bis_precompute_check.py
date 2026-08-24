#!/usr/bin/env python3
"""
F0-bis: check whether a VRF proof can be fetched off-chain for a future nonce
before any on-chain request_random / submit_random transaction is sent.

This script intentionally reuses the same seed/proof helpers from measure_vrf.py.

Usage:
  python3 scripts/f0_bis_precompute_check.py \
    --vrf-server https://<sepolia-vrf-server> \
    --benchmark 0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b \
    --caller 0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192 \
    --rpc-url https://api.cartridge.gg/x/starknet/sepolia \
    --chain-id 0x534e5f5345504f4c4941
"""

import argparse
import sys

import measure_vrf
from measure_vrf import compute_seed, get_proof, read_nonce_from_chain

SEPOLIA_BENCHMARK_DEFAULT = "0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b"
SEPOLIA_CALLER_DEFAULT = "0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192"
SEPOLIA_CHAIN_ID = 0x534E5F5345504F4C4941
SEPOLIA_RPC_DEFAULT = "https://api.cartridge.gg/x/starknet/sepolia"

REQUIRED_PROOF_FIELDS = ("gamma_x", "gamma_y", "c", "s", "sqrt_ratio")


def main():
    parser = argparse.ArgumentParser(
        description="F0-bis precompute check against a real Sepolia VRF server"
    )
    parser.add_argument("--vrf-server", required=True,
                        help="Base URL of the VRF server to query, e.g. https://host")
    parser.add_argument("--benchmark", default=SEPOLIA_BENCHMARK_DEFAULT)
    parser.add_argument("--caller", default=SEPOLIA_CALLER_DEFAULT,
                        help="EOA whose nonce-based seed will be computed")
    parser.add_argument("--rpc-url", default=SEPOLIA_RPC_DEFAULT)
    parser.add_argument("--chain-id", type=lambda x: int(x, 16), default=SEPOLIA_CHAIN_ID)
    args = parser.parse_args()

    measure_vrf.VRF_SERVER = args.vrf_server.rstrip("/")

    print("Paso 1/3 - leyendo nonce actual on-chain...", flush=True)
    nonce = read_nonce_from_chain(args.benchmark, args.rpc_url)
    print(f"  nonce actual = {nonce}")

    print("Paso 2/3 - calculando seed futuro sin enviar tx...", flush=True)
    seed = compute_seed(
        nonce,
        int(args.caller, 16),
        int(args.benchmark, 16),
        args.chain_id,
    )
    print(f"  seed = {hex(seed)}")

    print("Paso 3/3 - pidiendo prueba al vrf-server sin request_random previo...", flush=True)
    try:
        proof = get_proof(seed)
    except Exception as exc:
        print("RESULTADO: RECHAZO DEL SERVIDOR")
        print(f"  error = {exc}")
        sys.exit(1)

    missing = [field for field in REQUIRED_PROOF_FIELDS if field not in proof]
    if missing:
        print("RESULTADO: RESPUESTA INCOMPLETA")
        print(f"  faltan campos = {', '.join(missing)}")
        print(f"  respuesta = {proof}")
        sys.exit(1)

    print("RESULTADO: PRUEBA VALIDA RECIBIDA")
    for field in REQUIRED_PROOF_FIELDS:
        print(f"  {field} = {proof[field]}")
    if "rnd" in proof:
        print(f"  rnd = {proof['rnd']}")


if __name__ == "__main__":
    main()
