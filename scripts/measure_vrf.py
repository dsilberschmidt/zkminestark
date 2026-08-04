#!/usr/bin/env python3
"""
Batch VRF latency measurement for zkminestark F0.

Mide latencia de N ciclos VRF completos (seed → proof → multicall).
Dependencias: poseidon_py, requests, sncast 0.62.1

Uso Katana (smoke test):
  python3 scripts/measure_vrf.py --cycles 500

Uso Sepolia (medición real):
  python3 scripts/measure_vrf.py --cycles 500 \
    --vrf-provider 0x... --benchmark 0x... \
    --account sepolia_dev \
    --rpc-url https://starknet-sepolia.public.blastapi.io \
    --chain-id 0x534e5f5345504f4c4941
"""

import argparse
import re
import subprocess
import sys
import tempfile
import time
import statistics

import requests
from poseidon_py.poseidon_hash import poseidon_hash_many

# Katana devnet defaults
VRF_PROVIDER_DEFAULT = "0x063f9d1fd88cd37da6397ec2cb746497bf3c85aca2938b06f707f53c76893dc5"
BENCHMARK_DEFAULT    = "0x018015db3a404681f9e0fde4d6aec8c82487ae89c6937249f4b4b0e3c02d4f87"
KATANA0              = "0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
CHAIN_ID_KATANA      = 0x4b4154414e41
ACCOUNTS_FILE        = "/home/cactussediento/.starknet_accounts/starknet_open_zeppelin_accounts.json"
VRF_SERVER           = "http://localhost:3001"
RPC_URL_DEFAULT      = "http://localhost:5050"


def sncast_call(contract: str, function: str, rpc_url: str) -> list[str]:
    """Run sncast call and return raw hex values from Response Raw line."""
    result = subprocess.run(
        ["sncast", "call",
         "--contract-address", contract,
         "--function", function,
         "--url", rpc_url],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"sncast call {function} failed:\n{result.stderr.strip()}")
    for line in result.stdout.splitlines():
        if "Response Raw" in line or "response" in line.lower():
            hexes = re.findall(r"0x[0-9a-fA-F]+", line)
            if hexes:
                return hexes
    raise RuntimeError(f"Could not parse sncast call output:\n{result.stdout}")


def read_nonce_from_chain(benchmark: str, rpc_url: str) -> int:
    """
    Read current nonce from Benchmark.get_counter().
    Counter == VrfProvider_nonces[katana0]: both increment exactly once per cycle.
    """
    hexes = sncast_call(benchmark, "get_counter", rpc_url)
    return int(hexes[0], 16)


def compute_seed(nonce: int, caller: int, benchmark: int, chain_id: int) -> int:
    # Mirrors vrf_provider_component.cairo get_seed() Source::Nonce branch (v0.3.1 l.186-188)
    return poseidon_hash_many([nonce, caller, benchmark, chain_id])


def get_proof(seed: int) -> dict:
    resp = requests.post(
        f"{VRF_SERVER}/proof",
        json={"seed": [hex(seed)]},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()["result"]


def build_multicall_toml(seed: int, proof: dict, vrf_provider: str, benchmark: str) -> str:
    seed_hex = hex(seed)
    return (
        f'[[call]]\n'
        f'call_type = "invoke"\n'
        f'contract_address = "{vrf_provider}"\n'
        f'function = "submit_random"\n'
        f'inputs = ["{seed_hex}", "{proof["gamma_x"]}", "{proof["gamma_y"]}", '
        f'"{proof["c"]}", "{proof["s"]}", "{proof["sqrt_ratio"]}"]\n'
        f'\n'
        f'[[call]]\n'
        f'call_type = "invoke"\n'
        f'contract_address = "{benchmark}"\n'
        f'function = "roll"\n'
        f'inputs = []\n'
        f'\n'
        f'[[call]]\n'
        f'call_type = "invoke"\n'
        f'contract_address = "{vrf_provider}"\n'
        f'function = "assert_consumed"\n'
        f'inputs = ["{seed_hex}"]\n'
    )


def run_multicall(toml_content: str, rpc_url: str, account: str) -> tuple[float, str]:
    """Returns (elapsed_seconds, tx_hash)."""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
        f.write(toml_content)
        toml_path = f.name

    cmd = [
        "sncast",
        "--account", account,
        "--accounts-file", ACCOUNTS_FILE,
        "multicall", "run",
        "--path", toml_path,
        "--url", rpc_url,
    ]
    t0 = time.perf_counter()
    result = subprocess.run(cmd, capture_output=True, text=True)
    elapsed = time.perf_counter() - t0

    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())

    tx_hash = ""
    for line in result.stdout.splitlines():
        if "transaction_hash" in line:
            m = re.search(r"0x[0-9a-fA-F]+", line)
            if m:
                tx_hash = m.group()
                break
    return elapsed, tx_hash


def verify_counter(benchmark: str, rpc_url: str, expected: int) -> bool:
    try:
        hexes = sncast_call(benchmark, "get_counter", rpc_url)
        return int(hexes[0], 16) == expected
    except Exception:
        return False


def percentile(data: list[float], p: float) -> float:
    if len(data) < 2:
        return data[0] if data else 0.0
    s = sorted(data)
    idx = (p / 100) * (len(s) - 1)
    lo = int(idx)
    hi = min(lo + 1, len(s) - 1)
    return s[lo] + (idx - lo) * (s[hi] - s[lo])


def main():
    parser = argparse.ArgumentParser(description="VRF latency batch measurement")
    parser.add_argument("--cycles", type=int, default=500)
    parser.add_argument("--start-nonce", type=int, default=None,
                        help="Expected nonce on-chain. Script reads chain value first; "
                             "if provided, aborts if it doesn't match.")
    parser.add_argument("--vrf-provider", default=VRF_PROVIDER_DEFAULT)
    parser.add_argument("--benchmark", default=BENCHMARK_DEFAULT)
    parser.add_argument("--chain-id", type=lambda x: int(x, 16), default=CHAIN_ID_KATANA)
    parser.add_argument("--rpc-url", default=RPC_URL_DEFAULT)
    parser.add_argument("--caller", default=KATANA0,
                        help="EOA used as Source::Nonce key")
    parser.add_argument("--account", default="katana0",
                        help="Nombre de cuenta sncast para el multicall (default: katana0)")
    parser.add_argument("--verify", action="store_true",
                        help="Verify get_counter() after each cycle (adds latency per cycle)")
    parser.add_argument("--abort-on-errors", type=int, default=10,
                        help="Abort after this many consecutive errors (default 10)")
    args = parser.parse_args()

    # Read nonce from chain before starting — avoids silent wrong-nonce batches on Sepolia
    print("Leyendo nonce actual desde chain...", end=" ", flush=True)
    try:
        chain_nonce = read_nonce_from_chain(args.benchmark, args.rpc_url)
        print(f"nonce={chain_nonce}")
    except Exception as e:
        print(f"\nERROR: no se pudo leer nonce desde chain: {e}")
        if args.start_nonce is None:
            print("Especificá --start-nonce para continuar sin lectura de chain.")
            sys.exit(1)
        chain_nonce = None
        print(f"Usando --start-nonce={args.start_nonce} (sin verificación de chain).")

    if chain_nonce is not None and args.start_nonce is not None:
        if chain_nonce != args.start_nonce:
            print(f"ERROR: nonce en chain ({chain_nonce}) != --start-nonce ({args.start_nonce}). Abortando.")
            print("Si querés forzar el valor manual, no uses --start-nonce (el script usa el chain).")
            sys.exit(1)

    start_nonce = chain_nonce if chain_nonce is not None else args.start_nonce

    caller_int    = int(args.caller, 16)
    benchmark_int = int(args.benchmark, 16)

    latencies_s: list[float] = []
    errors = 0
    consecutive_errors = 0

    print(f"Iniciando {args.cycles} ciclos — start_nonce={start_nonce} rpc={args.rpc_url}")

    for k in range(args.cycles):
        nonce = start_nonce + k
        cycle_num = k + 1
        print(f"  [{cycle_num:>4}/{args.cycles}] nonce={nonce} ", end="", flush=True)

        try:
            seed = compute_seed(nonce, caller_int, benchmark_int, args.chain_id)
            proof = get_proof(seed)
            toml = build_multicall_toml(seed, proof, args.vrf_provider, args.benchmark)
            elapsed, tx_hash = run_multicall(toml, args.rpc_url, args.account)
            latencies_s.append(elapsed)
            consecutive_errors = 0

            if args.verify:
                # After cycle k (1-indexed), counter = start_nonce + cycle_num
                expected_counter = start_nonce + cycle_num
                ok = verify_counter(args.benchmark, args.rpc_url, expected_counter)
                status = f"counter={'OK' if ok else 'MISMATCH(expected=' + str(expected_counter) + ')'}"
            else:
                status = "ok"

            print(f"{elapsed:.3f}s  {status}  tx={tx_hash[:14]}...")

        except Exception as e:
            errors += 1
            consecutive_errors += 1
            print(f"ERROR: {e}")
            if consecutive_errors >= args.abort_on_errors:
                print(f"Abortando: {consecutive_errors} errores consecutivos.")
                break

    print()
    if not latencies_s:
        print("Sin datos de latencia.")
        sys.exit(1)

    n = len(latencies_s)
    lat_ms = [l * 1000 for l in latencies_s]
    p50 = percentile(lat_ms, 50)
    p95 = percentile(lat_ms, 95)
    p99 = percentile(lat_ms, 99)

    print(f"=== Resultados: {n}/{args.cycles} ciclos exitosos, {errors} errores ===")
    print(f"  p50:  {p50:>8.0f} ms  (criterio ≤ 2000 ms: {'PASS' if p50 <= 2000 else 'FAIL'})")
    print(f"  p95:  {p95:>8.0f} ms  (criterio ≤ 5000 ms: {'PASS' if p95 <= 5000 else 'FAIL'})")
    print(f"  p99:  {p99:>8.0f} ms")
    print(f"  min:  {min(lat_ms):>8.0f} ms")
    print(f"  max:  {max(lat_ms):>8.0f} ms")
    print(f"  mean: {statistics.mean(lat_ms):>8.0f} ms")


if __name__ == "__main__":
    main()
