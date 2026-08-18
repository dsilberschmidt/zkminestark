#!/usr/bin/env python3
"""
Medición comparativa: preconfirmación (execution_status=SUCCEEDED en cualquier finality)
vs. confirmación completa (ACCEPTED_ON_L2, equivalente a lo que mide measure_vrf.py).

Reusa el patrón de measure_vrf.py contra los contratos F0 ya desplegados en Sepolia.

Uso:
  python3 scripts/measure_preconfirm.py --cycles 40 \\
    --vrf-provider 0x062550dc48d58ab49e84176c7bbd255c8a0d457bb08bec93eabe76c8549e4291 \\
    --benchmark   0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b \\
    --account     sepolia_dev \\
    --rpc-url     https://api.cartridge.gg/x/starknet/sepolia \\
    --chain-id    0x534e5f5345504f4c4941 \\
    --caller      0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192
"""

import argparse
import re
import subprocess
import sys
import tempfile
import threading
import time
import statistics

import requests
from poseidon_py.poseidon_hash import poseidon_hash_many

VRF_SERVER    = "http://localhost:3001"
ACCOUNTS_FILE = "/home/cactussediento/.starknet_accounts/starknet_open_zeppelin_accounts.json"
POLL_INTERVAL = 0.25   # segundos entre consultas RPC de preconfirmación
POLL_TIMEOUT  = 90     # segundos máximo esperando execution_status=SUCCEEDED


# ── helpers (mismo patrón que measure_vrf.py) ───────────────────────────────

def compute_seed(nonce, caller, benchmark, chain_id):
    return poseidon_hash_many([nonce, caller, benchmark, chain_id])


def get_proof(seed):
    resp = requests.post(f"{VRF_SERVER}/proof", json={"seed": [hex(seed)]}, timeout=10)
    resp.raise_for_status()
    return resp.json()["result"]


def build_multicall_toml(seed, proof, vrf_provider, benchmark):
    seed_hex = hex(seed)
    return (
        f'[[call]]\ncall_type = "invoke"\n'
        f'contract_address = "{vrf_provider}"\nfunction = "submit_random"\n'
        f'inputs = ["{seed_hex}", "{proof["gamma_x"]}", "{proof["gamma_y"]}", '
        f'"{proof["c"]}", "{proof["s"]}", "{proof["sqrt_ratio"]}"]\n\n'
        f'[[call]]\ncall_type = "invoke"\n'
        f'contract_address = "{benchmark}"\nfunction = "roll"\ninputs = []\n\n'
        f'[[call]]\ncall_type = "invoke"\n'
        f'contract_address = "{vrf_provider}"\nfunction = "assert_consumed"\n'
        f'inputs = ["{seed_hex}"]\n'
    )


def read_nonce(benchmark, rpc_url):
    result = subprocess.run(
        ["sncast", "call", "--contract-address", benchmark,
         "--function", "get_counter", "--url", rpc_url],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"sncast call get_counter falló: {result.stderr.strip()}")
    for line in result.stdout.splitlines():
        hexes = re.findall(r"0x[0-9a-fA-F]+", line)
        if hexes:
            return int(hexes[0], 16)
    raise RuntimeError(f"No se pudo parsear nonce: {result.stdout}")


# ── polling de preconfirmación ───────────────────────────────────────────────

def poll_execution_status(tx_hash, rpc_url, t0, result_container, stop_event):
    """
    Thread: consulta starknet_getTransactionStatus cada POLL_INTERVAL hasta que
    execution_status=SUCCEEDED o POLL_TIMEOUT. Escribe en result_container[0].
    Formato: (elapsed_s: float | "TIMEOUT" | "REVERTED", finality_status: str)
    """
    deadline = time.perf_counter() + POLL_TIMEOUT
    while time.perf_counter() < deadline and not stop_event.is_set():
        try:
            resp = requests.post(rpc_url, json={
                "jsonrpc": "2.0",
                "method": "starknet_getTransactionStatus",
                "params": [tx_hash],
                "id": 1,
            }, timeout=5)
            data = resp.json()
            r = data.get("result", {})
            finality  = r.get("finality_status", "")
            exec_st   = r.get("execution_status", "")
            if exec_st == "SUCCEEDED":
                result_container[0] = (time.perf_counter() - t0, finality)
                return
            if exec_st == "REVERTED":
                result_container[0] = ("REVERTED", finality)
                return
        except Exception:
            pass
        time.sleep(POLL_INTERVAL)
    if not stop_event.is_set():
        result_container[0] = ("TIMEOUT", "")


# ── multicall con doble medición ─────────────────────────────────────────────

def run_dual(toml_content, rpc_url, account):
    """
    Lanza sncast con stdbuf -oL (fuerza flush línea a línea).
    Registra:
      t_preconfirm_s : primer momento con execution_status=SUCCEEDED (float) o str de error
      t_accepted_s   : momento en que sncast termina (= ACCEPTED_ON_L2 confirmado por sncast)
      finality_at_pre: finality_status cuando se detectó SUCCEEDED
      tx_hash        : hash de la transacción
      hash_seen_late : True si el tx_hash apareció después de que sncast terminó
    """
    with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
        f.write(toml_content)
        toml_path = f.name

    cmd = [
        "stdbuf", "-oL",
        "sncast",
        "--account", account,
        "--accounts-file", ACCOUNTS_FILE,
        "multicall", "run",
        "--path", toml_path,
        "--url", rpc_url,
    ]

    t0 = time.perf_counter()
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    poll_result   = [None]
    stop_event    = threading.Event()
    poll_thread   = None
    tx_hash       = None
    hash_seen_late = False
    all_lines     = []

    for line in proc.stdout:
        all_lines.append(line)
        if tx_hash is None and "transaction_hash" in line:
            m = re.search(r"0x[0-9a-fA-F]+", line)
            if m:
                tx_hash = m.group()
                poll_thread = threading.Thread(
                    target=poll_execution_status,
                    args=(tx_hash, rpc_url, t0, poll_result, stop_event),
                    daemon=True,
                )
                poll_thread.start()

    proc.wait()
    t_accepted = time.perf_counter() - t0
    stop_event.set()

    if poll_thread is not None:
        poll_thread.join(timeout=5)

    # Si sncast terminó sin que veamos el tx_hash (output buffeado igual),
    # buscamos en todas las líneas acumuladas y hacemos una consulta puntual.
    if tx_hash is None:
        for line in all_lines:
            if "transaction_hash" in line:
                m = re.search(r"0x[0-9a-fA-F]+", line)
                if m:
                    tx_hash = m.group()
                    hash_seen_late = True
                    break
        if tx_hash and poll_result[0] is None:
            try:
                resp = requests.post(rpc_url, json={
                    "jsonrpc": "2.0", "method": "starknet_getTransactionStatus",
                    "params": [tx_hash], "id": 1,
                }, timeout=5)
                r = resp.json().get("result", {})
                if r.get("execution_status") == "SUCCEEDED":
                    poll_result[0] = ("LATE", r.get("finality_status", ""))
            except Exception:
                pass

    if proc.returncode != 0:
        stderr = proc.stderr.read()
        raise RuntimeError(f"sncast falló (rc={proc.returncode}): {stderr.strip()}")

    raw = poll_result[0]
    if raw is None:
        t_pre = None
        finality = "NO_RESULT"
    elif isinstance(raw[0], float):
        t_pre = raw[0]
        finality = raw[1]
    else:
        t_pre = raw[0]      # "TIMEOUT", "REVERTED", "LATE"
        finality = raw[1]

    return t_pre, t_accepted, tx_hash, finality, hash_seen_late


# ── main ─────────────────────────────────────────────────────────────────────

def percentile(data, p):
    if not data:
        return 0.0
    s = sorted(data)
    if len(s) == 1:
        return s[0]
    idx = (p / 100) * (len(s) - 1)
    lo  = int(idx)
    hi  = min(lo + 1, len(s) - 1)
    return s[lo] + (idx - lo) * (s[hi] - s[lo])


def main():
    parser = argparse.ArgumentParser(description="VRF preconfirmation vs full-confirmation comparison")
    parser.add_argument("--cycles",       type=int, default=40)
    parser.add_argument("--vrf-provider", required=True)
    parser.add_argument("--benchmark",    required=True)
    parser.add_argument("--account",      required=True)
    parser.add_argument("--rpc-url",      required=True)
    parser.add_argument("--chain-id",     type=lambda x: int(x, 16), required=True)
    parser.add_argument("--caller",       required=True)
    args = parser.parse_args()

    caller_int    = int(args.caller, 16)
    benchmark_int = int(args.benchmark, 16)

    print("Leyendo nonce desde chain...", end=" ", flush=True)
    nonce = read_nonce(args.benchmark, args.rpc_url)
    print(f"nonce={nonce}")
    print(f"Iniciando {args.cycles} ciclos — rpc={args.rpc_url}")
    print()

    hdr = f"{'ciclo':>8}  {'preconfirm':>12}  {'finality@pre':>16}  {'accepted':>10}  {'delta':>9}  {'late?':>5}  tx"
    print(hdr)
    print("-" * len(hdr))

    t_pre_list  = []   # solo floats (medibles antes de accepted)
    t_acc_list  = []
    late_count  = 0
    errors      = 0

    for k in range(args.cycles):
        nonce_k = nonce + k
        label   = f"[{k+1:>3}/{args.cycles}]"
        try:
            seed  = compute_seed(nonce_k, caller_int, benchmark_int, args.chain_id)
            proof = get_proof(seed)
            toml  = build_multicall_toml(seed, proof, args.vrf_provider, args.benchmark)

            t_pre, t_acc, tx_hash, finality, hash_late = run_dual(toml, args.rpc_url, args.account)

            t_acc_ms  = t_acc * 1000
            tx_short  = (tx_hash or "?")[:16] + "..."
            late_mark = "LATE" if hash_late else "  ok"

            if isinstance(t_pre, float):
                t_pre_ms  = t_pre * 1000
                pre_str   = f"{t_pre_ms:>10.0f}ms"
                delta_str = f"{t_acc_ms - t_pre_ms:>+8.0f}ms"
                t_pre_list.append(t_pre_ms)
            else:
                pre_str   = f"{'(' + str(t_pre) + ')':>12}"
                delta_str = "         —"

            if hash_late:
                late_count += 1

            t_acc_list.append(t_acc_ms)
            print(f"{label}  {pre_str}  {finality:>16}  {t_acc_ms:>8.0f}ms  {delta_str}  {late_mark}  {tx_short}")

        except Exception as e:
            errors += 1
            print(f"{label}  ERROR: {e}")

    print()
    print("=" * 90)
    n_pre = len(t_pre_list)
    n_acc = len(t_acc_list)

    print(f"Ciclos con preconfirm medible (hash a tiempo): {n_pre}/{args.cycles}")
    print(f"Ciclos con hash tardío (stdbuf no alcanzó):    {late_count}/{args.cycles}")
    print(f"Ciclos con confirmación completa registrada:   {n_acc}/{args.cycles}")
    print(f"Errores totales: {errors}")

    if t_pre_list:
        print(f"\nPreconfirmación (execution_status=SUCCEEDED, hash visto antes de accepted):")
        print(f"  p50: {percentile(t_pre_list, 50):>8.0f} ms")
        print(f"  p95: {percentile(t_pre_list, 95):>8.0f} ms")
        print(f"  min: {min(t_pre_list):>8.0f} ms")
        print(f"  max: {max(t_pre_list):>8.0f} ms")
        print(f"  mean:{statistics.mean(t_pre_list):>8.0f} ms")

    if t_acc_list:
        print(f"\nConfirmación completa (ACCEPTED_ON_L2, sncast termina):")
        print(f"  p50: {percentile(t_acc_list, 50):>8.0f} ms")
        print(f"  p95: {percentile(t_acc_list, 95):>8.0f} ms")
        print(f"  min: {min(t_acc_list):>8.0f} ms")
        print(f"  max: {max(t_acc_list):>8.0f} ms")
        print(f"  mean:{statistics.mean(t_acc_list):>8.0f} ms")

    if t_pre_list and t_acc_list:
        ahorro = percentile(t_acc_list, 50) - percentile(t_pre_list, 50)
        print(f"\nAhorro mediano estimado (p50 accepted − p50 preconfirm): {ahorro:+.0f} ms")
        if late_count == args.cycles:
            print("\nNOTA CRÍTICA: el 100% de los hashes llegaron tarde (stdbuf no logró flush temprano).")
            print("Los tiempos de 'preconfirm' reflejan una consulta post-confirmación, no preconfirmación real.")
            print("Resultado: preconfirmación no accesible antes de ACCEPTED_ON_L2 con este método.")
        elif late_count > args.cycles * 0.5:
            print(f"\nNOTA: {late_count}/{args.cycles} hashes llegaron tarde — resultado de preconfirm parcialmente contaminado.")


if __name__ == "__main__":
    main()
