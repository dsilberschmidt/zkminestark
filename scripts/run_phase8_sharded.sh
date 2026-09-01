#!/usr/bin/env bash
# Phase 8 sharded snforge runner.
# Runs 5 shards sequentially to avoid OOM during compilation.
# Each shard swaps tests.cairo to a minimal module list, runs snforge,
# then appends results to the combined log.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="$REPO_ROOT/contracts/zkmine_2g"
TESTS_CAIRO="$CONTRACT_DIR/src/tests.cairo"
BENCH_DIR="$REPO_ROOT/benchmarks"
LOG="$BENCH_DIR/2g-phase8-snforge-combined-20260831.log"

ORIG_TESTS_CAIRO="$(cat "$TESTS_CAIRO")"

restore_tests_cairo() {
    echo "$ORIG_TESTS_CAIRO" > "$TESTS_CAIRO"
}
trap restore_tests_cairo EXIT

run_shard() {
    local shard_name="$1"   # human label
    local module="$2"       # Cairo module name (no .cairo)
    local filter="$3"       # snforge filter string (empty = no filter)
    local expected="$4"     # expected test count (for sanity)

    echo "========================================"
    echo "SHARD: $shard_name  (expected ~$expected tests)"
    echo "========================================"

    # Minimal tests.cairo for this shard
    printf "mod %s;\n" "$module" > "$TESTS_CAIRO"

    {
        echo "=== SHARD: $shard_name ==="
        if [[ -n "$filter" ]]; then
            cd "$CONTRACT_DIR" && snforge test "$filter" --max-n-steps 4294967295 2>&1 || true
        else
            cd "$CONTRACT_DIR" && snforge test --max-n-steps 4294967295 2>&1 || true
        fi
        echo "=== END SHARD: $shard_name ==="
    } | tee -a "$LOG"

    echo ""
}

# Clear stale log (previous interrupted run had only the compilation line)
> "$LOG"

echo "Phase 8 sharded run — $(date)" | tee -a "$LOG"
echo "Swap available: $(free -h | awk '/Swap/{print $4}') free" | tee -a "$LOG"
echo "" >> "$LOG"

run_shard "benchmark_s1 (floods f01-f11, 247 tests)"  "test_ve_phase8_s1"       "p8_f"       247
run_shard "benchmark_s2 (floods f12-f22, 161 tests)"  "test_ve_phase8_s2"       "p8_f"       161
run_shard "exact_s1 (floods f01-f11, 247 tests)"      "test_ve_phase8_exact_s1" "p8_exact_f" 247
run_shard "exact_s2 (floods f12-f22, 161 tests)"      "test_ve_phase8_exact_s2" "p8_exact_f" 161
run_shard "combined (3 tests)"                         "test_ve_phase8_combined" "p8_combined" 3

echo ""
echo "=== Phase 8 sharded run COMPLETE ===" | tee -a "$LOG"
echo "Log: $LOG"
