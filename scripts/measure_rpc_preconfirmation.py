#!/usr/bin/env python3
"""
Medición go/no-go de latencia RPC directa para una acción VRF-consuming.

Unidad de medida: una acción del jugador (una tx invoke con las llamadas
necesarias para materializar el resultado), no celdas reveladas.

El script:
- envía la tx por RPC directo con starknet.py
- obtiene el tx hash inmediatamente del submit RPC
- hace polling de estados/receipt por JSON-RPC crudo
- persiste cada observación en JSONL tras cada ciclo, con flush + fsync
- ejecuta en forma estrictamente secuencial para no contaminar con carreras
  de nonce

Dependencias en el entorno del usuario:
- requests
- poseidon_py
- starknet_py
"""

from __future__ import annotations

import argparse
import json
import math
import os
import signal
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any

import requests


SEPOLIA_RPC_DEFAULT = "https://api.cartridge.gg/x/starknet/sepolia"
SEPOLIA_VRF_PROVIDER_DEFAULT = (
    "0x062550dc48d58ab49e84176c7bbd255c8a0d457bb08bec93eabe76c8549e4291"
)
SEPOLIA_BENCHMARK_DEFAULT = (
    "0x002f32e302a63cc7a181563819c5933bfc402bcf87c42c945183235a7269e79b"
)
SEPOLIA_CALLER_DEFAULT = (
    "0x077bd7696ed8573ee1f1d3aef662455d22f918e62de532d424134aaf24924192"
)
SEPOLIA_CHAIN_ID_DEFAULT = "0x534e5f5345504f4c4941"
PRIVATE_KEY_ENV = "ZKMINE_SEPOLIA_PRIVATE_KEY"
VRF_SERVER_DEFAULT = "http://localhost:3001"
POLL_INTERVAL_MS_DEFAULT = 250
POLL_TIMEOUT_S_DEFAULT = 90.0
ESTIMATE_MULTIPLIER_DEFAULT = 1.50
TIP_DEFAULT = 0


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds")


def short_hash(value: str | None) -> str:
    if not value:
        return "-"
    if len(value) <= 14:
        return value
    return value[:8] + "..." + value[-6:]


def percentile(data: list[float], p: float) -> float:
    if not data:
        return 0.0
    values = sorted(data)
    if len(values) == 1:
        return values[0]
    idx = (p / 100.0) * (len(values) - 1)
    lo = int(math.floor(idx))
    hi = int(math.ceil(idx))
    if lo == hi:
        return values[lo]
    frac = idx - lo
    return values[lo] + frac * (values[hi] - values[lo])


def summarize_ms(data: list[float]) -> dict[str, float]:
    summary = {
        "n": len(data),
        "min_ms": min(data),
        "max_ms": max(data),
        "mean_ms": sum(data) / len(data),
        "p50_ms": percentile(data, 50),
        "p90_ms": percentile(data, 90),
        "p95_ms": percentile(data, 95),
    }
    if len(data) >= 100:
        summary["p99_ms"] = percentile(data, 99)
    return summary


def go_no_go(p50_ms: float, p95_ms: float) -> str:
    if p50_ms <= 1500 and p95_ms <= 2500:
        return "GREEN"
    if p50_ms > 2000 or p95_ms > 4000:
        return "RED"
    return "YELLOW"


def rpc_error_text(payload: dict[str, Any]) -> str:
    err = payload.get("error") or {}
    code = err.get("code")
    msg = err.get("message", "unknown rpc error")
    data = err.get("data")
    if data is None:
        return f"{code}: {msg}"
    return f"{code}: {msg} | {data}"


def to_json_safe(value: Any) -> Any:
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    if isinstance(value, Enum):
        enum_value = value.value
        if enum_value is None or isinstance(enum_value, (bool, int, float, str)):
            return enum_value
        return str(enum_value)
    if isinstance(value, dict):
        return {str(k): to_json_safe(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [to_json_safe(item) for item in value]
    if hasattr(value, "__dict__"):
        return {
            str(k): to_json_safe(v)
            for k, v in vars(value).items()
            if not callable(v) and not k.startswith("_")
        }
    return str(value)


def is_tx_hash_not_found(payload: dict[str, Any]) -> bool:
    err = payload.get("error") or {}
    msg = str(err.get("message", "")).lower()
    return "txn_hash_not_found" in msg or "transaction hash not found" in msg


def first_present(obj: Any, *keys: str) -> Any:
    if not isinstance(obj, dict):
        return None
    for key in keys:
        if key in obj and obj[key] is not None:
            return obj[key]
    return None


def required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            f"Falta la variable de entorno {name}. "
            f"Cargala en tu shell antes de ejecutar el script."
        )
    return value


def load_starknet_py():
    try:
        from starknet_py.hash.selector import get_selector_from_name
        from starknet_py.net.account.account import Account
        from starknet_py.net.client_models import Call, ResourceBounds, ResourceBoundsMapping
        from starknet_py.net.full_node_client import FullNodeClient
        from starknet_py.net.signer.key_pair import KeyPair
    except ImportError as exc:
        raise RuntimeError(
            "Falta starknet_py en este entorno. "
            "Instalalo en tu terminal antes de correr la medición."
        ) from exc
    return {
        "Account": Account,
        "Call": Call,
        "FullNodeClient": FullNodeClient,
        "KeyPair": KeyPair,
        "ResourceBounds": ResourceBounds,
        "ResourceBoundsMapping": ResourceBoundsMapping,
        "get_selector_from_name": get_selector_from_name,
    }


def poseidon_hash_many(values: list[int]) -> int:
    try:
        from poseidon_py.poseidon_hash import poseidon_hash_many as impl
    except ImportError as exc:
        raise RuntimeError(
            "Falta poseidon_py en este entorno. "
            "Instalalo en tu terminal antes de correr la medición."
        ) from exc
    return impl(values)


def compute_seed(vrf_nonce: int, caller: int, benchmark: int, chain_id: int) -> int:
    return poseidon_hash_many([vrf_nonce, caller, benchmark, chain_id])


def get_proof(seed: int, vrf_server: str, timeout_s: float) -> dict[str, str]:
    resp = requests.post(
        f"{vrf_server.rstrip('/')}/proof",
        json={"seed": [hex(seed)]},
        timeout=timeout_s,
    )
    resp.raise_for_status()
    payload = resp.json()
    return payload["result"]


def rpc_request(rpc_url: str, method: str, params: Any) -> dict[str, Any]:
    resp = requests.post(
        rpc_url,
        json={"jsonrpc": "2.0", "id": 1, "method": method, "params": params},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def probe_spec_version(rpc_url: str) -> str:
    try:
        payload = rpc_request(rpc_url, "starknet_specVersion", [])
    except Exception:
        return "unknown"
    return str(payload.get("result", "unknown"))


def build_call_helpers():
    api = load_starknet_py()
    call_cls = api["Call"]
    selector = api["get_selector_from_name"]

    def build_calls(vrf_provider: int, benchmark: int, seed: int, proof: dict[str, str]):
        return [
            call_cls(
                to_addr=vrf_provider,
                selector=selector("submit_random"),
                calldata=[
                    seed,
                    int(proof["gamma_x"], 16),
                    int(proof["gamma_y"], 16),
                    int(proof["c"], 16),
                    int(proof["s"], 16),
                    int(proof["sqrt_ratio"], 16),
                ],
            ),
            call_cls(
                to_addr=benchmark,
                selector=selector("roll"),
                calldata=[],
            ),
            call_cls(
                to_addr=vrf_provider,
                selector=selector("assert_consumed"),
                calldata=[seed],
            ),
        ]

    return build_calls


def make_client_and_account(
    rpc_url: str,
    account_address: str,
    chain_id: int,
    private_key: str,
):
    api = load_starknet_py()
    client = api["FullNodeClient"](node_url=rpc_url)
    key_pair = api["KeyPair"].from_private_key(int(private_key, 16))
    account = api["Account"](
        address=account_address,
        client=client,
        key_pair=key_pair,
        chain=chain_id,
    )
    return client, account, api


def detect_nonce_block_tag(client: Any, account_address: str) -> str:
    for tag in ("pre_confirmed", "latest", "pending"):
        try:
            client.get_contract_nonce_sync(account_address, block_number=tag)
            return tag
        except Exception:
            continue
    raise RuntimeError("No se pudo leer nonce del account con tags pre_confirmed/latest/pending.")


def read_account_nonce(client: Any, account_address: str, block_tag: str) -> int:
    return int(client.get_contract_nonce_sync(account_address, block_number=block_tag))


def read_benchmark_counter(client: Any, benchmark: int, block_tag: str, api: dict[str, Any]) -> int:
    call = api["Call"](
        to_addr=benchmark,
        selector=api["get_selector_from_name"]("get_counter"),
        calldata=[],
    )
    result = client.call_contract_sync(call=call, block_number=block_tag)
    if not result:
        raise RuntimeError("Benchmark.get_counter() devolvió vacío.")
    return int(result[0])


def scaled_resource(value: Any, multiplier: float) -> int:
    numeric = int(value)
    return max(1, math.ceil(numeric * multiplier))


def resource_bounds_from_estimate(estimate: Any, multiplier: float, api: dict[str, Any]) -> Any:
    rb = api["ResourceBounds"]
    rbm = api["ResourceBoundsMapping"]
    return rbm(
        l1_gas=rb(
            max_amount=scaled_resource(getattr(estimate, "l1_gas_consumed"), multiplier),
            max_price_per_unit=scaled_resource(getattr(estimate, "l1_gas_price"), multiplier),
        ),
        l2_gas=rb(
            max_amount=scaled_resource(getattr(estimate, "l2_gas_consumed"), multiplier),
            max_price_per_unit=scaled_resource(getattr(estimate, "l2_gas_price"), multiplier),
        ),
        l1_data_gas=rb(
            max_amount=scaled_resource(
                getattr(estimate, "l1_data_gas_consumed"), multiplier
            ),
            max_price_per_unit=scaled_resource(
                getattr(estimate, "l1_data_gas_price"), multiplier
            ),
        ),
    )


def estimate_resource_bounds(
    account: Any,
    calls: list[Any],
    tx_nonce: int,
    block_tag: str,
    tip: int,
    multiplier: float,
    api: dict[str, Any],
) -> tuple[Any, Any]:
    max_rb = api["ResourceBounds"]
    max_rbm = api["ResourceBoundsMapping"]
    draft_bounds = max_rbm(
        l1_gas=max_rb(max_amount=int(1e7), max_price_per_unit=int(1e18)),
        l2_gas=max_rb(max_amount=int(1e9), max_price_per_unit=int(1e18)),
        l1_data_gas=max_rb(max_amount=int(1e7), max_price_per_unit=int(1e18)),
    )
    estimate_tx = account.sign_invoke_v3_sync(
        calls=calls,
        nonce=tx_nonce,
        resource_bounds=draft_bounds,
        tip=tip,
    )
    estimate = account.estimate_fee_sync(tx=estimate_tx, block_number=block_tag)
    bounds = resource_bounds_from_estimate(estimate, multiplier, api)
    return estimate, bounds


def format_ms(value: float | None) -> str:
    if value is None:
        return "-"
    return f"{value:.0f}ms"


def print_metric_block(title: str, data: list[float]):
    if not data:
        print(f"{title}: sin datos")
        return
    summary = summarize_ms(data)
    print(f"{title}:")
    print(f"  N:    {summary['n']}")
    print(f"  min:  {summary['min_ms']:.0f} ms")
    print(f"  p50:  {summary['p50_ms']:.0f} ms")
    print(f"  p90:  {summary['p90_ms']:.0f} ms")
    print(f"  p95:  {summary['p95_ms']:.0f} ms")
    if "p99_ms" in summary:
        print(f"  p99:  {summary['p99_ms']:.0f} ms")
    print(f"  max:  {summary['max_ms']:.0f} ms")
    print(f"  mean: {summary['mean_ms']:.0f} ms")


@dataclass
class PollState:
    first_status_ms: float | None = None
    first_receipt_ms: float | None = None
    execution_succeeded_ms: float | None = None
    preconfirmed_ms: float | None = None
    result_readable_ms: float | None = None
    accepted_on_l2_ms: float | None = None
    result_readable_finality: str | None = None
    result_readable_signal: str | None = None
    finality_status: str | None = None
    execution_status: str | None = None
    failure_reason: Any = None
    result_read_check_status: str | None = None
    result_read_check_error: str | None = None
    result_read_expected_counter: int | None = None
    result_read_observed_counter: int | None = None
    result_read_signal_source: str | None = None
    result_read_signal_finality: str | None = None
    last_status_payload: dict[str, Any] | None = None
    last_receipt_payload: dict[str, Any] | None = None


def update_from_status(state: PollState, payload: dict[str, Any], elapsed_ms: float):
    result = payload.get("result")
    if not isinstance(result, dict):
        return
    state.last_status_payload = result
    if state.first_status_ms is None:
        state.first_status_ms = elapsed_ms
    finality = first_present(result, "finality_status")
    execution = first_present(result, "execution_status")
    failure_reason = first_present(result, "failure_reason")
    if finality is not None:
        state.finality_status = str(finality)
    if execution is not None:
        state.execution_status = str(execution)
    if failure_reason is not None:
        state.failure_reason = failure_reason
    if finality == "PRE_CONFIRMED" and state.preconfirmed_ms is None:
        state.preconfirmed_ms = elapsed_ms
    if execution == "SUCCEEDED" and state.execution_succeeded_ms is None:
        state.execution_succeeded_ms = elapsed_ms
        state.result_read_signal_source = (
            "starknet_getTransactionStatus.execution_status=SUCCEEDED"
        )
        state.result_read_signal_finality = str(finality) if finality is not None else None
    if finality == "ACCEPTED_ON_L2" and state.accepted_on_l2_ms is None:
        state.accepted_on_l2_ms = elapsed_ms


def update_from_receipt(state: PollState, payload: dict[str, Any], elapsed_ms: float):
    result = payload.get("result")
    if not isinstance(result, dict):
        return
    state.last_receipt_payload = result
    if state.first_receipt_ms is None:
        state.first_receipt_ms = elapsed_ms
    finality = first_present(result, "finality_status")
    execution = first_present(result, "execution_status")
    if finality is not None:
        state.finality_status = str(finality)
    if execution is not None:
        state.execution_status = str(execution)
    failure_reason = first_present(result, "revert_reason", "revert_error", "failure_reason")
    if failure_reason is not None:
        state.failure_reason = failure_reason
    if finality == "PRE_CONFIRMED" and state.preconfirmed_ms is None:
        state.preconfirmed_ms = elapsed_ms
    if execution == "SUCCEEDED" and state.execution_succeeded_ms is None:
        state.execution_succeeded_ms = elapsed_ms
        state.result_read_signal_source = (
            "starknet_getTransactionReceipt.execution_status=SUCCEEDED"
        )
        state.result_read_signal_finality = str(finality) if finality is not None else None
    if finality == "ACCEPTED_ON_L2" and state.accepted_on_l2_ms is None:
        state.accepted_on_l2_ms = elapsed_ms


def try_read_result(
    state: PollState,
    client: Any,
    benchmark: int,
    nonce_tag: str,
    api: dict[str, Any],
    expected_counter: int,
    elapsed_ms: float,
):
    if state.execution_succeeded_ms is None or state.result_readable_ms is not None:
        return
    state.result_read_expected_counter = expected_counter
    try:
        observed_counter = read_benchmark_counter(client, benchmark, nonce_tag, api)
    except Exception as exc:
        state.result_read_check_status = "read_error"
        state.result_read_check_error = str(exc)
        return

    state.result_read_observed_counter = observed_counter
    if observed_counter == expected_counter:
        state.result_readable_ms = elapsed_ms
        state.result_readable_signal = "Benchmark.get_counter() readable at pre_confirmed"
        state.result_readable_finality = state.finality_status
        state.result_read_check_status = "matched"
        state.result_read_check_error = None
    else:
        state.result_read_check_status = "mismatch"
        state.result_read_check_error = None


def poll_until_terminal(
    client: Any,
    benchmark: int,
    nonce_tag: str,
    api: dict[str, Any],
    rpc_url: str,
    tx_hash: str,
    submit_started: float,
    poll_interval_s: float,
    usable_timeout_s: float,
    expected_counter: int,
) -> PollState:
    state = PollState()
    usable_deadline = submit_started + usable_timeout_s

    while True:
        now = time.perf_counter()
        elapsed_ms = (now - submit_started) * 1000.0
        if state.result_readable_ms is None and now > usable_deadline:
            raise TimeoutError(f"timeout esperando resultado legible para {tx_hash}")

        status_payload = None
        receipt_payload = None

        try:
            status_payload = rpc_request(
                rpc_url,
                "starknet_getTransactionStatus",
                {"transaction_hash": tx_hash},
            )
            update_from_status(state, status_payload, elapsed_ms)
        except Exception as exc:
            message = str(exc)
            if "404" not in message:
                pass

        try:
            receipt_payload = rpc_request(
                rpc_url,
                "starknet_getTransactionReceipt",
                {"transaction_hash": tx_hash},
            )
            update_from_receipt(state, receipt_payload, elapsed_ms)
        except Exception as exc:
            message = str(exc)
            if "404" not in message:
                pass

        if status_payload and payload_has_rpc_error(status_payload) and not is_tx_hash_not_found(status_payload):
            raise RuntimeError(f"getTransactionStatus error: {rpc_error_text(status_payload)}")
        if receipt_payload and payload_has_rpc_error(receipt_payload) and not is_tx_hash_not_found(receipt_payload):
            raise RuntimeError(f"getTransactionReceipt error: {rpc_error_text(receipt_payload)}")

        if state.execution_status == "REVERTED":
            return state

        try_read_result(
            state=state,
            client=client,
            benchmark=benchmark,
            nonce_tag=nonce_tag,
            api=api,
            expected_counter=expected_counter,
            elapsed_ms=elapsed_ms,
        )

        if state.result_readable_ms is not None:
            return state

        time.sleep(poll_interval_s)


def payload_has_rpc_error(payload: dict[str, Any]) -> bool:
    return "error" in payload and payload["error"] is not None


def observation_status_label(obs: dict[str, Any]) -> str:
    if obs["status"] == "ok":
        return "OK"
    return f"ERROR {obs['error_type']}"


def write_jsonl_line(handle, row: dict[str, Any]):
    handle.write(json.dumps(to_json_safe(row), sort_keys=True) + "\n")
    handle.flush()
    os.fsync(handle.fileno())


def main():
    parser = argparse.ArgumentParser(
        description="Medición RPC directa de preconfirmación/latencia VRF por acción"
    )
    parser.add_argument("--cycles", type=int, required=True,
                        help="Cantidad mínima de acciones válidas objetivo.")
    parser.add_argument("--max-attempts", type=int, default=None,
                        help="Máximo de intentos totales. Default: cycles * 2.")
    parser.add_argument("--rpc-url", default=SEPOLIA_RPC_DEFAULT)
    parser.add_argument("--vrf-server", default=VRF_SERVER_DEFAULT)
    parser.add_argument("--vrf-provider", default=SEPOLIA_VRF_PROVIDER_DEFAULT)
    parser.add_argument("--benchmark", default=SEPOLIA_BENCHMARK_DEFAULT)
    parser.add_argument("--account-address", default=SEPOLIA_CALLER_DEFAULT)
    parser.add_argument("--caller", default=SEPOLIA_CALLER_DEFAULT,
                        help="EOA usado como caller y como clave Source::Nonce.")
    parser.add_argument("--chain-id", default=SEPOLIA_CHAIN_ID_DEFAULT)
    parser.add_argument("--poll-interval-ms", type=int, default=POLL_INTERVAL_MS_DEFAULT)
    parser.add_argument("--poll-timeout-s", type=float, default=POLL_TIMEOUT_S_DEFAULT)
    parser.add_argument("--proof-timeout-s", type=float, default=10.0)
    parser.add_argument("--estimate-multiplier", type=float, default=ESTIMATE_MULTIPLIER_DEFAULT)
    parser.add_argument("--tip", type=int, default=TIP_DEFAULT)
    parser.add_argument("--out", default=None,
                        help="Path del JSONL crudo. Default: benchmarks/rpc-preconfirm-<utc>.jsonl")
    args = parser.parse_args()

    private_key = required_env(PRIVATE_KEY_ENV)
    chain_id = int(args.chain_id, 16)
    caller_int = int(args.caller, 16)
    vrf_provider_int = int(args.vrf_provider, 16)
    benchmark_int = int(args.benchmark, 16)

    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    out_path = Path(args.out) if args.out else Path("benchmarks") / f"rpc-preconfirm-{ts}.jsonl"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    client, account, api = make_client_and_account(
        rpc_url=args.rpc_url,
        account_address=args.account_address,
        chain_id=chain_id,
        private_key=private_key,
    )
    build_calls = build_call_helpers()

    spec_version = probe_spec_version(args.rpc_url)
    nonce_tag = detect_nonce_block_tag(client, args.account_address)
    next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
    next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
    max_attempts = args.max_attempts or args.cycles * 2
    poll_interval_s = args.poll_interval_ms / 1000.0

    print(f"RPC: {args.rpc_url}")
    print(f"RPC spec_version: {spec_version}")
    print(f"Nonce tag usado: {nonce_tag}")
    print(
        "Usable signal preferido: "
        "starknet_getTransactionStatus.execution_status=SUCCEEDED; "
        "fallback: starknet_getTransactionReceipt.execution_status=SUCCEEDED; "
        "si no aparece antes, ACCEPTED_ON_L2."
    )
    print(f"VRF server: {args.vrf_server}")
    print(f"Benchmark: {args.benchmark}")
    print(f"VRF provider: {args.vrf_provider}")
    print(f"Account: {args.account_address}")
    print(f"Start tx_nonce={next_tx_nonce} vrf_nonce={next_vrf_nonce}")
    print(f"Raw output: {out_path}")
    print("Persistencia: JSONL, una línea por intento, flush + fsync tras cada ciclo.")
    print()

    valid = 0
    failed = 0
    result_readable_samples: list[float] = []
    accepted_samples: list[float] = []
    readable_signals_seen: dict[str, int] = {}
    interrupted = False

    def _sigint_handler(signum, frame):
        raise KeyboardInterrupt

    signal.signal(signal.SIGINT, _sigint_handler)

    with out_path.open("a", encoding="utf-8") as fh:
        try:
            for attempt in range(1, max_attempts + 1):
                if valid >= args.cycles:
                    break

                observation: dict[str, Any] = {
                    "attempt": attempt,
                    "target_valid_cycles": args.cycles,
                    "valid_completed_before": valid,
                    "started_at_utc": utc_now_iso(),
                    "rpc_url": args.rpc_url,
                    "rpc_spec_version": spec_version,
                    "usable_signal_policy": (
                        "first successful execution signal triggers immediate "
                        "Benchmark.get_counter() read at pre_confirmed; "
                        "primary metric is submit->result_readable; "
                        "ACCEPTED_ON_L2 is secondary"
                    ),
                    "nonce_block_tag": nonce_tag,
                    "tx_nonce": next_tx_nonce,
                    "vrf_nonce": next_vrf_nonce,
                    "tx_hash": None,
                    "status": "error",
                    "error_type": None,
                    "error_message": None,
                }

                try:
                    t0 = time.perf_counter()
                    seed = compute_seed(next_vrf_nonce, caller_int, benchmark_int, chain_id)
                    observation["seed_compute_ms"] = (time.perf_counter() - t0) * 1000.0
                    observation["seed"] = hex(seed)

                    t0 = time.perf_counter()
                    proof = get_proof(seed, args.vrf_server, args.proof_timeout_s)
                    observation["proof_fetch_ms"] = (time.perf_counter() - t0) * 1000.0

                    t0 = time.perf_counter()
                    calls = build_calls(vrf_provider_int, benchmark_int, seed, proof)
                    observation["call_build_ms"] = (time.perf_counter() - t0) * 1000.0

                    t0 = time.perf_counter()
                    estimate, resource_bounds = estimate_resource_bounds(
                        account=account,
                        calls=calls,
                        tx_nonce=next_tx_nonce,
                        block_tag=nonce_tag,
                        tip=args.tip,
                        multiplier=args.estimate_multiplier,
                        api=api,
                    )
                    observation["fee_estimate_ms"] = (time.perf_counter() - t0) * 1000.0
                    fee_unit = getattr(estimate, "unit", None)
                    observation["fee_unit"] = to_json_safe(fee_unit)
                    observation["fee_estimate"] = {
                        "overall_fee": getattr(estimate, "overall_fee", None),
                        "l1_gas_consumed": getattr(estimate, "l1_gas_consumed", None),
                        "l1_gas_price": getattr(estimate, "l1_gas_price", None),
                        "l1_data_gas_consumed": getattr(estimate, "l1_data_gas_consumed", None),
                        "l1_data_gas_price": getattr(estimate, "l1_data_gas_price", None),
                        "l2_gas_consumed": getattr(estimate, "l2_gas_consumed", None),
                        "l2_gas_price": getattr(estimate, "l2_gas_price", None),
                    }
                    observation["resource_bounds"] = {
                        "l1_gas": {
                            "max_amount": resource_bounds.l1_gas.max_amount,
                            "max_price_per_unit": resource_bounds.l1_gas.max_price_per_unit,
                        },
                        "l2_gas": {
                            "max_amount": resource_bounds.l2_gas.max_amount,
                            "max_price_per_unit": resource_bounds.l2_gas.max_price_per_unit,
                        },
                        "l1_data_gas": {
                            "max_amount": resource_bounds.l1_data_gas.max_amount,
                            "max_price_per_unit": resource_bounds.l1_data_gas.max_price_per_unit,
                        },
                    }

                    t0 = time.perf_counter()
                    signed_tx = account.sign_invoke_v3_sync(
                        calls=calls,
                        nonce=next_tx_nonce,
                        resource_bounds=resource_bounds,
                        tip=args.tip,
                    )
                    observation["sign_ms"] = (time.perf_counter() - t0) * 1000.0

                    observation["submit_started_at_utc"] = utc_now_iso()
                    submit_started = time.perf_counter()
                    sent = account.client.send_transaction_sync(transaction=signed_tx)
                    observation["submit_ms"] = (time.perf_counter() - submit_started) * 1000.0
                    tx_hash_value = getattr(sent, "transaction_hash", None)
                    tx_hash = hex(tx_hash_value) if isinstance(tx_hash_value, int) else str(tx_hash_value)
                    observation["tx_hash"] = tx_hash

                    poll_state = poll_until_terminal(
                        client=client,
                        benchmark=benchmark_int,
                        nonce_tag=nonce_tag,
                        api=api,
                        rpc_url=args.rpc_url,
                        tx_hash=tx_hash,
                        submit_started=submit_started,
                        poll_interval_s=poll_interval_s,
                        usable_timeout_s=args.poll_timeout_s,
                        expected_counter=next_vrf_nonce + 1,
                    )

                    observation["first_status_ms"] = poll_state.first_status_ms
                    observation["first_receipt_ms"] = poll_state.first_receipt_ms
                    observation["execution_succeeded_ms"] = poll_state.execution_succeeded_ms
                    observation["preconfirmed_ms"] = poll_state.preconfirmed_ms
                    observation["result_readable_ms"] = poll_state.result_readable_ms
                    observation["accepted_on_l2_ms"] = poll_state.accepted_on_l2_ms
                    observation["result_readable_finality"] = poll_state.result_readable_finality
                    observation["result_readable_signal"] = poll_state.result_readable_signal
                    observation["finality_status"] = poll_state.finality_status
                    observation["execution_status"] = poll_state.execution_status
                    observation["failure_reason"] = poll_state.failure_reason
                    observation["result_read_check_status"] = poll_state.result_read_check_status
                    observation["result_read_check_error"] = poll_state.result_read_check_error
                    observation["result_read_expected_counter"] = poll_state.result_read_expected_counter
                    observation["result_read_observed_counter"] = poll_state.result_read_observed_counter
                    observation["result_read_signal_source"] = poll_state.result_read_signal_source
                    observation["result_read_signal_finality"] = poll_state.result_read_signal_finality
                    observation["finished_at_utc"] = utc_now_iso()

                    if poll_state.execution_status == "REVERTED":
                        observation["status"] = "error"
                        observation["error_type"] = "reverted"
                        observation["error_message"] = str(poll_state.failure_reason)
                        failed += 1
                        next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
                        next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
                    elif observation["result_readable_ms"] is None:
                        observation["status"] = "error"
                        observation["error_type"] = "result_not_readable"
                        observation["error_message"] = (
                            "No se pudo leer Benchmark.get_counter() actualizado "
                            "en pre_confirmed dentro del timeout."
                        )
                        failed += 1
                        next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
                        next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
                    else:
                        observation["status"] = "ok"
                        valid += 1
                        result_readable_samples.append(float(observation["result_readable_ms"]))
                        signal_key = str(observation["result_readable_signal"])
                        readable_signals_seen[signal_key] = readable_signals_seen.get(signal_key, 0) + 1
                        if observation["accepted_on_l2_ms"] is not None:
                            accepted_samples.append(float(observation["accepted_on_l2_ms"]))
                        next_tx_nonce += 1
                        next_vrf_nonce += 1

                except KeyboardInterrupt:
                    interrupted = True
                    raise
                except Exception as exc:
                    observation["finished_at_utc"] = utc_now_iso()
                    observation["status"] = "error"
                    message = str(exc)
                    if "nonce" in message.lower():
                        observation["error_type"] = "nonce_error"
                        try:
                            next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
                            next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
                        except Exception:
                            pass
                    elif isinstance(exc, TimeoutError):
                        observation["error_type"] = "timeout"
                        try:
                            next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
                            next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
                        except Exception:
                            pass
                    else:
                        observation["error_type"] = "exception"
                        try:
                            next_tx_nonce = read_account_nonce(client, args.account_address, nonce_tag)
                            next_vrf_nonce = read_benchmark_counter(client, benchmark_int, nonce_tag, api)
                        except Exception:
                            pass
                    observation["error_message"] = message
                    failed += 1
                finally:
                    write_jsonl_line(fh, observation)
                    print(
                        f"[attempt {attempt:03d}] valid={valid:03d}/{args.cycles} "
                        f"vrf_nonce={observation['vrf_nonce']} tx_nonce={observation['tx_nonce']} "
                        f"hash={short_hash(observation['tx_hash'])} "
                        f"submit={format_ms(observation.get('submit_ms'))} "
                        f"readable={format_ms(observation.get('result_readable_ms'))} "
                        f"accepted={format_ms(observation.get('accepted_on_l2_ms'))} "
                        f"{observation_status_label(observation)}"
                    )

        except KeyboardInterrupt:
            print()
            print("Interrupción limpia por Ctrl+C.")

    print()
    print(f"Raw data: {out_path}")
    print(f"Válidos: {valid}")
    print(f"Fallidos: {failed}")
    print(f"Interrumpido: {'sí' if interrupted else 'no'}")
    if readable_signals_seen:
        print("Señales de resultado legible observadas:")
        for signal_name, count in sorted(readable_signals_seen.items()):
            print(f"  {signal_name}: {count}")
    print()
    print_metric_block("A. submit -> result_readable", result_readable_samples)
    print()
    print_metric_block("B. submit -> ACCEPTED_ON_L2", accepted_samples)

    if result_readable_samples:
        primary = summarize_ms(result_readable_samples)
        color = go_no_go(primary["p50_ms"], primary["p95_ms"])
        print()
        print(
            f"Go/No-Go primario: {color} "
            f"(p50={primary['p50_ms']:.0f} ms, p95={primary['p95_ms']:.0f} ms)"
        )
    else:
        print()
        print("Go/No-Go primario: sin datos válidos.")


if __name__ == "__main__":
    main()
