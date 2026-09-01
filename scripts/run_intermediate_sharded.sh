#!/usr/bin/env bash
# run_intermediate_sharded.sh
# Corre los 59 tests Intermediate en shards pequeños con --max-threads 1.
# 404-safe: append + permite resume si se interrumpe.
# Memoria segura: un módulo a la vez.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="$REPO_ROOT/contracts/zkmine_2g"
TESTS_CAIRO="$CONTRACT_DIR/src/tests.cairo"
BENCH_DIR="$REPO_ROOT/benchmarks"
DATE="20260901"

LOG_BENCH="$BENCH_DIR/intermediate-snforge-bench-${DATE}.log"
LOG_EXACT="$BENCH_DIR/intermediate-snforge-exact-${DATE}.log"

# Backup original tests.cairo
ORIG_TESTS_CAIRO="$(cat "$TESTS_CAIRO")"

restore_tests_cairo() {
    echo "$ORIG_TESTS_CAIRO" > "$TESTS_CAIRO"
    echo "Restored tests.cairo" >&2
}
trap restore_tests_cairo EXIT

run_shard() {
    local shard_name="$1"
    local module="$2"
    local filter="$3"
    local log="$4"
    local expected="$5"

    echo "========================================"
    echo "SHARD: $shard_name  (expected ~$expected tests)"
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

echo "Intermediate 16x16/40 sharded run — $(date)"
echo "RAM: $(free -h | awk '/Mem:/{print $4}') free, Swap: $(free -h | awk '/Swap:/{print $4}') free"
echo ""

# Shard 1: benchmark (gas measurement)
> "$LOG_BENCH"
echo "Intermediate benchmark run — $(date)" >> "$LOG_BENCH"
run_shard "benchmark (59 tests)" "test_ve_intermediate" "im_f" "$LOG_BENCH" 59

# Shard 2: exact (correctness)
> "$LOG_EXACT"
echo "Intermediate exact run — $(date)" >> "$LOG_EXACT"
run_shard "exact (59 tests)" "test_ve_intermediate_exact" "im_exact_f" "$LOG_EXACT" 59

echo ""
echo "=== Intermediate sharded run COMPLETE === $(date)"
echo "Bench log: $LOG_BENCH"
echo "Exact log: $LOG_EXACT"
