#!/usr/bin/env bash
# run_square_sharded.sh N M [RUN_TAG]
# Corre tests Cairo para square NxN/M en shards pequeños con --max-threads 1.
# 404-safe: append + permite resume si se interrumpe.
# Memoria segura: un módulo a la vez.
#
# Uso: bash scripts/run_square_sharded.sh 15 35
#      bash scripts/run_square_sharded.sh 9 13 rep2

set -uo pipefail

N="${1:?Provide board size N}"
M="${2:?Provide mine count M}"
RUN_TAG="${3:-}"

if [ -n "$RUN_TAG" ]; then
    TAG="sq${N}x${N}_${RUN_TAG}"
    PREFIX="sq${N}_${RUN_TAG}"
else
    TAG="sq${N}x${N}"
    PREFIX="sq${N}"
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="$REPO_ROOT/contracts/zkmine_2g"
TESTS_CAIRO="$CONTRACT_DIR/src/tests.cairo"
BENCH_DIR="$REPO_ROOT/benchmarks"
DATE="20260901"

LOG_BENCH="$BENCH_DIR/square-snforge-bench-${TAG}-${DATE}.log"
LOG_EXACT="$BENCH_DIR/square-snforge-exact-${TAG}-${DATE}.log"

BENCH_MODULE="test_ve_${TAG}"
EXACT_MODULE="test_ve_${TAG}_exact"

ORIG_TESTS_CAIRO="$(cat "$TESTS_CAIRO")"

restore_tests_cairo() {
    printf "%s\n" "$ORIG_TESTS_CAIRO" > "$TESTS_CAIRO"
    echo "Restored tests.cairo" >&2
}
trap restore_tests_cairo EXIT

run_shard() {
    local shard_name="$1"
    local module="$2"
    local filter="$3"
    local log="$4"

    echo "========================================"
    echo "SHARD: $shard_name"
    echo "========================================"

    printf "mod %s;\n" "$module" > "$TESTS_CAIRO"

    {
        echo "=== SHARD: $shard_name ==="
        echo "=== $(date) ==="
        cd "$CONTRACT_DIR" && snforge test "$filter" --max-n-steps 4294967295 --max-threads 1 2>&1 || true
        echo "=== END SHARD: $shard_name ==="
    } | tee -a "$log"

    echo ""
}

echo "Square ${N}×${N}/${M}${RUN_TAG:+ [${RUN_TAG}]} sharded run — $(date)"
echo "RAM: $(free -h | awk '/Mem:/{print $4}') free, Swap: $(free -h | awk '/Swap:/{print $4}') free"
echo ""

# Shard 1: benchmark (gas measurement)
> "$LOG_BENCH"
echo "Square ${TAG} benchmark run — $(date)" >> "$LOG_BENCH"
run_shard "benchmark (${N}×${N}/${M})" "$BENCH_MODULE" "${PREFIX}_f" "$LOG_BENCH"

# Shard 2: exact (correctness)
> "$LOG_EXACT"
echo "Square ${TAG} exact run — $(date)" >> "$LOG_EXACT"
run_shard "exact (${N}×${N}/${M})" "$EXACT_MODULE" "${PREFIX}_exact_f" "$LOG_EXACT"

echo ""
echo "=== Square ${TAG} sharded run COMPLETE === $(date)"
echo "Bench log: $LOG_BENCH"
echo "Exact log:  $LOG_EXACT"
echo ""
echo "Next step: python3 scripts/parse_square_gas.py --size ${N} --mines ${M}${RUN_TAG:+ --run-tag ${RUN_TAG}}"
