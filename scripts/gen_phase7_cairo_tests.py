#!/usr/bin/env python3
"""
Generate Cairo test files for Phase 7 full CELL evaluation.

Produces TWO files from benchmarks/2g-phase7-fixtures-20260831.jsonl:

  test_ve_phase7.cairo       — gas benchmark: full CELL without outcome assertions.
                               Reports gas for the complete pipeline.

  test_ve_phase7_exact.cairo — correctness: same pipeline + all 10 outcome assertions.
                               Gas includes assertion overhead — do NOT use for gas dist.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

FIXTURES = Path("benchmarks/2g-phase7-fixtures-20260831.jsonl")
OUT_GAS   = Path("contracts/zkmine_2g/src/tests/test_ve_phase7.cairo")
OUT_EXACT = Path("contracts/zkmine_2g/src/tests/test_ve_phase7_exact.cairo")


def safe_name(s: str) -> str:
    return re.sub(r"[^a-zA-Z0-9]", "_", s)


def fmt_u32_array(items: list[int]) -> str:
    return "array![" + ", ".join(str(v) for v in items) + "]"


def fmt_constraints(constraints: list[dict]) -> str:
    parts = []
    for c in constraints:
        scope = ", ".join(str(v) for v in c["scope"])
        parts.append(f"Constraint {{ variables: array![{scope}], rhs: {c['rhs']} }}")
    return "array![" + ", ".join(parts) + "]"


def u512_literal(v: int) -> str:
    limb0 = v & ((1 << 128) - 1)
    limb1 = (v >> 128) & ((1 << 128) - 1)
    limb2 = (v >> 256) & ((1 << 128) - 1)
    limb3 = (v >> 384) & ((1 << 128) - 1)
    return f"u512 {{ limb0: {limb0}, limb1: {limb1}, limb2: {limb2}, limb3: {limb3} }}"


def build_cell_body(rec: dict, include_asserts: bool) -> str:
    """Build the body of a CELL test function."""
    sp = rec["special"]
    unc = rec["unconstrained_local"]
    name = safe_name(rec["case_id"])

    lines: list[str] = []

    # Step 1: joint VE on special component
    x_var = sp["x_var"] if sp["x_var"] is not None else 0xFFFFFFFF
    lines.append(f"    // Step 1: joint VE on special component")
    lines.append(f"    let sp_vars: Array<u32> = {fmt_u32_array(sp['variables'])};")
    lines.append(f"    let sp_constraints: Array<Constraint> = {fmt_constraints(sp['constraints'])};")
    lines.append(f"    let sp_hint: Array<u32> = {fmt_u32_array(sp['min_fill_order'])};")
    lines.append(f"    let sp_nbrs: Array<u32> = {fmt_u32_array(sp['neighbor_vars'])};")
    lines.append(
        f"    let mut aggregate: Array<JointEntry> = "
        f"count_joint_component_with_order(@sp_vars, @sp_constraints, {x_var}, @sp_nbrs, @sp_hint);"
    )
    lines.append("")

    # Step 2: ordinary components
    for i, oc in enumerate(rec["ordinary_components"]):
        lines.append(f"    // Step 2.{i}: ordinary component {i}")
        lines.append(f"    let ord{i}_vars: Array<u32> = {fmt_u32_array(oc['variables'])};")
        lines.append(f"    let ord{i}_constr: Array<Constraint> = {fmt_constraints(oc['constraints'])};")
        lines.append(f"    let ord{i}_ways = count_ordinary_component(@ord{i}_vars, @ord{i}_constr);")
        lines.append(f"    aggregate = convolve_ordinary(@aggregate, @ord{i}_ways);")
        lines.append("")

    # Step 3: unconstrained local
    if unc["has"]:
        x_unc = "true" if unc["x_is_unconstrained"] else "false"
        nbr_cnt = unc["neighbor_count"]
        lines.append(f"    // Step 3: unconstrained local (total={unc['total']}, nbrs={nbr_cnt})")
        lines.append(
            f"    aggregate = apply_unconstrained_local(@aggregate, {x_unc}, {nbr_cnt});"
        )
        lines.append("")

    # Step 4: extract outcomes (applies binom + global mine constraint)
    rm = rec["remaining_mines"]
    uo = rec["unconstrained_other_count"]
    adj = rec["adjacent_known_mines"]
    lines.append(f"    // Step 4: extract outcomes (binom + global constraint)")
    lines.append(
        f"    let outcomes = extract_outcomes(@aggregate, {rm}, {uo}, {adj});"
    )

    if include_asserts:
        lines.append("")
        lines.append(f"    // Correctness: assert all 10 outcomes exactly")
        eo = rec["expected_outcomes"]
        mine_v = int(eo["mine"])
        lines.append(
            f"    assert(u512_eq(*outcomes.at(0), {u512_literal(mine_v)}), '{rec['case_id']} mine');"
        )
        for i in range(9):
            clue_v = int(eo[str(i)])
            idx = i + 1
            lines.append(
                f"    assert(u512_eq(*outcomes.at({idx}), {u512_literal(clue_v)}), '{rec['case_id']} c{i}');"
            )

    return "\n".join(lines)


def build_gas_test(rec: dict) -> str:
    sp = rec["special"]
    n_ord = rec["_audit"]["n_ordinary"]
    width = sp["min_fill_width"]
    name = safe_name(rec["case_id"])
    body = build_cell_body(rec, include_asserts=False)
    return (
        f"#[test]\n"
        f"// CELL gas: size={sp['size'] if 'size' in sp else len(sp['variables'])} "
        f"width={width} ord={n_ord} unc_loc={rec['unconstrained_local']['total']} "
        f"unc_oth={rec['unconstrained_other_count']}\n"
        f"fn p7_{name}() {{\n{body}\n}}\n"
    )


def build_exact_test(rec: dict) -> str:
    sp = rec["special"]
    n_ord = rec["_audit"]["n_ordinary"]
    width = sp["min_fill_width"]
    name = safe_name(rec["case_id"])
    body = build_cell_body(rec, include_asserts=True)
    return (
        f"#[test]\n"
        f"// CELL exact: size={len(sp['variables'])} width={width} ord={n_ord}\n"
        f"fn p7_exact_{name}() {{\n{body}\n}}\n"
    )


HEADER_GAS = """\
// AUTO-GENERATED by gen_phase7_cairo_tests.py — do not edit by hand
// Phase 7 gas benchmark: full CELL without outcome assertions.

use zkmine_2g::ve::{count_joint_component_with_order, count_ordinary_component, Constraint, JointEntry};
use zkmine_2g::cell::{convolve_ordinary, apply_unconstrained_local, extract_outcomes};

"""

HEADER_EXACT = """\
// AUTO-GENERATED by gen_phase7_cairo_tests.py — do not edit by hand
// Phase 7 correctness: full CELL with all 10 outcome assertions.
// Gas from these tests includes assertion overhead.

use zkmine_2g::ve::{count_joint_component_with_order, count_ordinary_component, Constraint, JointEntry};
use zkmine_2g::cell::{convolve_ordinary, apply_unconstrained_local, extract_outcomes};
use zkmine_2g::bigint::u512_eq;
use core::integer::u512;

"""


def main() -> None:
    with open(FIXTURES) as f:
        recs = [json.loads(l) for l in f]

    # sort by special component size for readability
    recs.sort(key=lambda r: (len(r["special"]["variables"]), r["case_id"]))

    gas_lines = [HEADER_GAS]
    for rec in recs:
        gas_lines.append(build_gas_test(rec))
    OUT_GAS.write_text("".join(gas_lines))
    print(f"wrote {len(recs)} gas-benchmark tests to {OUT_GAS}")

    exact_lines = [HEADER_EXACT]
    for rec in recs:
        exact_lines.append(build_exact_test(rec))
    OUT_EXACT.write_text("".join(exact_lines))
    print(f"wrote {len(recs)} exact-correctness tests to {OUT_EXACT}")
    print(f"gas file: {OUT_GAS.stat().st_size // 1024} KB")
    print(f"exact file: {OUT_EXACT.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
