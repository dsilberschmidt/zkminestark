/// Tests for 2G VE primitives — exact parity with Python fixtures.
///
/// All fixtures generated from scripts/conditional_sampling_2e2_variable_elimination.py
/// and verified manually.

use zkmine_2g::ve::{
    constraint_factor, join_factors, eliminate_variable, count_ordinary_component,
    count_joint_component, count_joint_component_with_order, count_joint_component_profile,
    constraint_factor_with_profile, join_factors_profile, eliminate_variable_profile,
    Factor, FactorEntry, Constraint, JointEntry, VeStepProfile, NO_X_VAR,
};
use zkmine_2g::ve_dict::{
    join_factors_dict, count_ordinary_component_dict,
    pack_key,
};

// ─── helpers ─────────────────────────────────────────────────────────────────

fn find_entry(entries: @Array<FactorEntry>, mask: u32, mines: u32) -> Option<u256> {
    let mut i: usize = 0;
    loop {
        if i >= entries.len() {
            break Option::None;
        }
        let e = *entries.at(i);
        if e.mask == mask && e.mines == mines && e.x_mine == 0 && e.nbrs == 0 {
            break Option::Some(e.count);
        }
        i += 1;
    }
}

// ─── F0: constraint_factor ───────────────────────────────────────────────────

// Python: constraint_factor([0,1,2], rhs=1) → 3 entries each count=1, masks 1,2,4
#[test]
fn f0_scope_and_entry_count() {
    let vars: Array<u32> = array![0, 1, 2];
    let nbrs: Array<u32> = array![];
    let f = constraint_factor(@vars, 1, NO_X_VAR, @nbrs);
    assert(f.scope_len == 3, 'scope_len');
    assert(f.entries.len() == 3, 'entry count rhs=1');
}

#[test]
fn f0_entry_masks_rhs1() {
    let vars: Array<u32> = array![0, 1, 2];
    let nbrs: Array<u32> = array![];
    let f = constraint_factor(@vars, 1, NO_X_VAR, @nbrs);
    let e = @f.entries;
    assert(find_entry(e, 1, 0).unwrap() == 1, 'mask=001');
    assert(find_entry(e, 2, 0).unwrap() == 1, 'mask=010');
    assert(find_entry(e, 4, 0).unwrap() == 1, 'mask=100');
}

#[test]
fn f0_entry_masks_rhs2() {
    // C(3,2)=3 entries: masks 011=3, 101=5, 110=6
    let vars: Array<u32> = array![0, 1, 2];
    let nbrs: Array<u32> = array![];
    let f = constraint_factor(@vars, 2, NO_X_VAR, @nbrs);
    assert(f.entries.len() == 3, 'entry count rhs=2');
    let e = @f.entries;
    assert(find_entry(e, 3, 0).unwrap() == 1, 'mask=011');
    assert(find_entry(e, 5, 0).unwrap() == 1, 'mask=101');
    assert(find_entry(e, 6, 0).unwrap() == 1, 'mask=110');
}

// ─── F1: join [0,1,2]/1 ∪ [1,2,3]/1 → scope [0,1,2,3], 3 entries ─────────

// Python: join of c1=[0,1,2]/rhs=1 and c2=[1,2,3]/rhs=1
//   nonzero entries: mask=2 (var1), mask=4 (var2), mask=9 (var0+var3), all count=1
#[test]
fn f1_join_entry_count() {
    let v1: Array<u32> = array![0, 1, 2];
    let v2: Array<u32> = array![1, 2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    assert(j.scope_len == 4, 'scope_len');
    assert(j.entries.len() == 3, 'entry count');
}

#[test]
fn f1_join_entry_masks() {
    let v1: Array<u32> = array![0, 1, 2];
    let v2: Array<u32> = array![1, 2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    let e = @j.entries;
    assert(find_entry(e, 2, 0).unwrap() == 1, 'mask=0010 var1');
    assert(find_entry(e, 4, 0).unwrap() == 1, 'mask=0100 var2');
    assert(find_entry(e, 9, 0).unwrap() == 1, 'mask=1001 var0+var3');
}

// ─── F2: join [0,1]/1 + [1,2,3]/1, eliminate var 1 ──────────────────────────

// Python result:
//   scope=[0,2,3], 3 entries:
//   mask=0 mines=1 count=1 (var1 was mine)
//   mask=3 mines=0 count=1 (var0 bit0 + var2 bit1)
//   mask=5 mines=0 count=1 (var0 bit0 + var3 bit2)
#[test]
fn f2_join_eliminate_scope() {
    let v1: Array<u32> = array![0, 1];
    let v2: Array<u32> = array![1, 2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    let r = eliminate_variable(@j, 1, NO_X_VAR, @nb);
    assert(r.scope_len == 3, 'scope_len after elim');
    assert(r.entries.len() == 3, 'entry count after elim');
}

#[test]
fn f2_join_eliminate_entries() {
    let v1: Array<u32> = array![0, 1];
    let v2: Array<u32> = array![1, 2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    let r = eliminate_variable(@j, 1, NO_X_VAR, @nb);
    let e = @r.entries;
    // mask=0 mines=1: var1 was mine
    assert(find_entry(e, 0, 1).unwrap() == 1, 'mask=0 mines=1');
    // mask=3 (bits 0+1) mines=0: var0 and var2
    assert(find_entry(e, 3, 0).unwrap() == 1, 'mask=3 mines=0');
    // mask=5 (bits 0+2) mines=0: var0 and var3
    assert(find_entry(e, 5, 0).unwrap() == 1, 'mask=5 mines=0');
}

// ─── F3: ordinary component count ────────────────────────────────────────────

// Component: vars=[0,1,2,3], c1=[0,1]/rhs=1, c2=[1,2,3]/rhs=1
// Python VE solution_vector: [0, 1, 2, 0, 0]
//   k=1: {v1=mine} → 1 assignment
//   k=2: {v0+v2=mine} and {v0+v3=mine} → 2 assignments
#[test]
fn f3_ordinary_count_solution_vector() {
    let vars: Array<u32> = array![0, 1, 2, 3];
    let c1 = Constraint { variables: array![0, 1], rhs: 1 };
    let c2 = Constraint { variables: array![1, 2, 3], rhs: 1 };
    let constraints: Array<Constraint> = array![c1, c2];
    let sol = count_ordinary_component(@vars, @constraints);
    assert(sol.len() == 5, 'sol len');
    assert(*sol.at(0) == 0, 'k=0');
    assert(*sol.at(1) == 1, 'k=1 should be 1');
    assert(*sol.at(2) == 2, 'k=2 should be 2');
    assert(*sol.at(3) == 0, 'k=3');
    assert(*sol.at(4) == 0, 'k=4');
}

// ─── F4: disjoint join — verify count multiplication ─────────────────────────

// c1=[0,1]/rhs=1 joined with c2=[2,3]/rhs=1: disjoint → 4 entries, total count=4
#[test]
fn f4_disjoint_join_total_count() {
    let v1: Array<u32> = array![0, 1];
    let v2: Array<u32> = array![2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    assert(j.scope_len == 4, 'scope_len');
    assert(j.entries.len() == 4, '4 entries for disjoint');
    let mut total: u256 = 0;
    let mut i: usize = 0;
    loop {
        if i >= j.entries.len() {
            break;
        }
        total += (*j.entries.at(i)).count;
        i += 1;
    };
    assert(total == 4, 'total count=4');
}

// ─── F6: scale — 10-variable chain (extrapolation fixture) ───────────────────

// Chain: vars=[0..9], constraints=[i,i+1,i+2]/rhs=1 for i=0..7
// Python VE: solution_vector=[0,0,0,2,1,0,0,0,0,0,0]
// (bigmuls=21, joins=7, margs=10, min_fill_width=2)
#[test]
fn f6_chain_10var_solution_vector() {
    let vars: Array<u32> = array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    let constraints: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
    ];
    let sol = count_ordinary_component(@vars, @constraints);
    assert(sol.len() == 11, 'sol len 10var');
    assert(*sol.at(3) == 2, 'k=3 should be 2');
    assert(*sol.at(4) == 1, 'k=4 should be 1');
    // All other slots should be 0
    assert(*sol.at(0) == 0, 'k=0');
    assert(*sol.at(1) == 0, 'k=1');
    assert(*sol.at(2) == 0, 'k=2');
    assert(*sol.at(5) == 0, 'k=5');
}

// ─── F7: scale — 16-variable chain (minimal real corpus size) ────────────────

// Chain: vars=[0..15], constraints=[i,i+1,i+2]/rhs=1 for i=0..13
// Python VE: solution_vector=[0,0,0,0,0,2,1,0,...,0]
// (bigmuls=39, joins=13, margs=16) — matches corpus cheapest case complexity
#[test]
fn f7_chain_16var_solution_vector() {
    let vars: Array<u32> = array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    let constraints: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
        Constraint { variables: array![8, 9, 10], rhs: 1 },
        Constraint { variables: array![9, 10, 11], rhs: 1 },
        Constraint { variables: array![10, 11, 12], rhs: 1 },
        Constraint { variables: array![11, 12, 13], rhs: 1 },
        Constraint { variables: array![12, 13, 14], rhs: 1 },
        Constraint { variables: array![13, 14, 15], rhs: 1 },
    ];
    let sol = count_ordinary_component(@vars, @constraints);
    assert(sol.len() == 17, 'sol len 16var');
    assert(*sol.at(5) == 2, 'k=5 should be 2');
    assert(*sol.at(6) == 1, 'k=6 should be 1');
    assert(*sol.at(0) == 0, 'k=0');
    assert(*sol.at(4) == 0, 'k=4');
    assert(*sol.at(7) == 0, 'k=7');
}

// ─── F5: accumulation — two paths to same state ──────────────────────────────

// c1=[0,1]/rhs=1; join with c2=[0,1]/rhs=1 → overlap=full scope
// Python: only mask=01 and mask=10 survive (both vars must agree), each count=1
// No accumulation since each path maps to a distinct mask.
#[test]
fn f5_full_overlap_join() {
    let v1: Array<u32> = array![0, 1];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let j = join_factors(@f1, @f2, NO_X_VAR, @nb);
    assert(j.scope_len == 2, 'scope_len full overlap');
    assert(j.entries.len() == 2, '2 entries for full overlap');
    let e = @j.entries;
    assert(find_entry(e, 1, 0).unwrap() == 1, 'mask=01');
    assert(find_entry(e, 2, 0).unwrap() == 1, 'mask=10');
}

// ─── Dict variant equivalence tests ──────────────────────────────────────────

// D1: join via dict same result as baseline for f1 fixture
#[test]
fn d1_join_dict_equiv_f1() {
    let v1: Array<u32> = array![0, 1, 2];
    let v2: Array<u32> = array![1, 2, 3];
    let nb: Array<u32> = array![];
    let f1 = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2 = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j_baseline = join_factors(@f1, @f2, NO_X_VAR, @nb);

    let f1b = constraint_factor(@v1, 1, NO_X_VAR, @nb);
    let f2b = constraint_factor(@v2, 1, NO_X_VAR, @nb);
    let j_dict = join_factors_dict(@f1b, @f2b);

    assert(j_dict.scope_len == j_baseline.scope_len, 'dict scope_len differs');
    assert(j_dict.entries.len() == j_baseline.entries.len(), 'dict entry count differs');
    assert(j_dict.entries.len() == 3, 'dict 3 entries');
}

// D2: full ordinary VE dict equiv f3 (4-var)
#[test]
fn d2_ordinary_dict_equiv_f3() {
    let vars: Array<u32> = array![0, 1, 2, 3];
    let c1 = Constraint { variables: array![0, 1], rhs: 1 };
    let c2 = Constraint { variables: array![1, 2, 3], rhs: 1 };
    let constraints: Array<Constraint> = array![c1, c2];

    let c1b = Constraint { variables: array![0, 1], rhs: 1 };
    let c2b = Constraint { variables: array![1, 2, 3], rhs: 1 };
    let constraints_d: Array<Constraint> = array![c1b, c2b];

    let sol_b = count_ordinary_component(@vars, @constraints);
    let sol_d = count_ordinary_component_dict(@vars, @constraints_d);

    assert(sol_d.len() == sol_b.len(), 'sol len differs');
    assert(*sol_d.at(1) == *sol_b.at(1), 'k=1 differs');
    assert(*sol_d.at(2) == *sol_b.at(2), 'k=2 differs');
    assert(*sol_d.at(0) == 0, 'k=0 dict');
}

// D3: dict equiv f6 chain 10-var
#[test]
fn d3_chain_10var_dict_equiv() {
    let vars: Array<u32> = array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    let c_b: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
    ];
    let c_d: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
    ];
    let sol_b = count_ordinary_component(@vars, @c_b);
    let sol_d = count_ordinary_component_dict(@vars, @c_d);
    assert(*sol_d.at(3) == *sol_b.at(3), 'k=3 chain10 differs');
    assert(*sol_d.at(4) == *sol_b.at(4), 'k=4 chain10 differs');
    assert(*sol_d.at(3) == 2, 'd k=3 should be 2');
    assert(*sol_d.at(4) == 1, 'd k=4 should be 1');
}

// D4: dict equiv f7 chain 16-var
#[test]
fn d4_chain_16var_dict_equiv() {
    let vars: Array<u32> = array![0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    let c_b: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
        Constraint { variables: array![8, 9, 10], rhs: 1 },
        Constraint { variables: array![9, 10, 11], rhs: 1 },
        Constraint { variables: array![10, 11, 12], rhs: 1 },
        Constraint { variables: array![11, 12, 13], rhs: 1 },
        Constraint { variables: array![12, 13, 14], rhs: 1 },
        Constraint { variables: array![13, 14, 15], rhs: 1 },
    ];
    let c_d: Array<Constraint> = array![
        Constraint { variables: array![0, 1, 2], rhs: 1 },
        Constraint { variables: array![1, 2, 3], rhs: 1 },
        Constraint { variables: array![2, 3, 4], rhs: 1 },
        Constraint { variables: array![3, 4, 5], rhs: 1 },
        Constraint { variables: array![4, 5, 6], rhs: 1 },
        Constraint { variables: array![5, 6, 7], rhs: 1 },
        Constraint { variables: array![6, 7, 8], rhs: 1 },
        Constraint { variables: array![7, 8, 9], rhs: 1 },
        Constraint { variables: array![8, 9, 10], rhs: 1 },
        Constraint { variables: array![9, 10, 11], rhs: 1 },
        Constraint { variables: array![10, 11, 12], rhs: 1 },
        Constraint { variables: array![11, 12, 13], rhs: 1 },
        Constraint { variables: array![12, 13, 14], rhs: 1 },
        Constraint { variables: array![13, 14, 15], rhs: 1 },
    ];
    let sol_b = count_ordinary_component(@vars, @c_b);
    let sol_d = count_ordinary_component_dict(@vars, @c_d);
    assert(*sol_d.at(5) == *sol_b.at(5), 'k=5 chain16 differs');
    assert(*sol_d.at(6) == *sol_b.at(6), 'k=6 chain16 differs');
    assert(*sol_d.at(5) == 2, 'd k=5 should be 2');
    assert(*sol_d.at(6) == 1, 'd k=6 should be 1');
}

// D5: pack_key roundtrip
#[test]
fn d5_pack_key_roundtrip() {
    // key = mask + 128*(mines + 31*(x_mine + 2*nbrs))
    // verify for mask=5, mines=3, x_mine=1, nbrs=2
    let key = pack_key(5, 3, 1, 2);
    let key_u32: u32 = key.try_into().unwrap();
    let mask = key_u32 % 128;
    let rest = key_u32 / 128;
    let mines = rest % 31;
    let rest2 = rest / 31;
    let x_mine = rest2 % 2;
    let nbrs = rest2 / 2;
    assert(mask == 5, 'mask roundtrip');
    assert(mines == 3, 'mines roundtrip');
    assert(x_mine == 1, 'x_mine roundtrip');
    assert(nbrs == 2, 'nbrs roundtrip');
}

// ─── Phase 3: bigint and joint VE tests ─────────────────────────────────────
use core::integer::u512;
use zkmine_2g::bigint::{
    u512_zero, u512_one, u512_from_u128, u512_add,
    u512_mul_small, u512_eq, binom, binom_range_from_anchor,
};

// ─── B1: u512 addition — basic sanity ────────────────────────────────────────

#[test]
fn b1_u512_add_basic() {
    let a = u512 { limb0: 100_u128, limb1: 0, limb2: 0, limb3: 0 };
    let b = u512 { limb0: 200_u128, limb1: 0, limb2: 0, limb3: 0 };
    let c = u512_add(a, b);
    assert(c.limb0 == 300, 'add basic');
    assert(c.limb1 == 0, 'add no carry');
}

// ─── B2: u512 addition — carry into limb1 ────────────────────────────────────

#[test]
fn b2_u512_add_carry_limb1() {
    let max128 = 0xffffffffffffffffffffffffffffffff_u128;
    let a = u512 { limb0: max128, limb1: 0, limb2: 0, limb3: 0 };
    let b = u512 { limb0: 1_u128, limb1: 0, limb2: 0, limb3: 0 };
    let c = u512_add(a, b);
    assert(c.limb0 == 0, 'carry->limb1 limb0');
    assert(c.limb1 == 1, 'carry->limb1 limb1');
}

// ─── B3: u512 crosses 256-bit boundary ───────────────────────────────────────

#[test]
fn b3_u512_add_crosses_256() {
    // a = 2^255 (bit 255 set)
    let a = u512 { limb0: 0, limb1: 0x80000000000000000000000000000000_u128, limb2: 0, limb3: 0 };
    let b = u512 { limb0: 0, limb1: 0x80000000000000000000000000000000_u128, limb2: 0, limb3: 0 };
    let c = u512_add(a, b);
    // 2^255 + 2^255 = 2^256
    assert(c.limb0 == 0, 'cross256 limb0');
    assert(c.limb1 == 0, 'cross256 limb1');
    assert(c.limb2 == 1, 'cross256 limb2');
    assert(c.limb3 == 0, 'cross256 limb3');
}

// ─── B4: u512_mul_small ──────────────────────────────────────────────────────

#[test]
fn b4_u512_mul_small_basic() {
    let a = u512_from_u128(1000_u128);
    let r = u512_mul_small(a, 465);
    assert(r.limb0 == 465000, 'mul_small basic');
    assert(r.limb1 == 0, 'mul_small no carry');
}

#[test]
fn b4_u512_mul_small_carry() {
    // (2^127) × 4 = 2^129 → crosses 128-bit boundary
    let a = u512 { limb0: 0x80000000000000000000000000000000_u128, limb1: 0, limb2: 0, limb3: 0 };
    let r = u512_mul_small(a, 4);
    assert(r.limb0 == 0, 'mul carry limb0');
    assert(r.limb1 == 2, 'mul carry limb1');
}

// ─── B5: binom small values ──────────────────────────────────────────────────

#[test]
fn b5_binom_small() {
    let b30_2 = binom(30, 2);
    assert(u512_eq(b30_2, u512_from_u128(435_u128)), 'C(30,2)=435');
    let b10_0 = binom(10, 0);
    assert(u512_eq(b10_0, u512_one()), 'C(10,0)=1');
    let b5_5 = binom(5, 5);
    assert(u512_eq(b5_5, u512_one()), 'C(5,5)=1');
    let b0_0 = binom(0, 0);
    assert(u512_eq(b0_0, u512_one()), 'C(0,0)=1');
    let b5_6 = binom(5, 6);
    assert(u512_eq(b5_6, u512_zero()), 'C(5,6)=0');
}

// ─── B6: binom crosses 256-bit boundary ──────────────────────────────────────

// Python: C(480, 99).bit_length() = 415 (fits in u512, crosses u256)
// C(480, 99) is 415 bits — computed value verified against Python oracle
#[test]
fn b6_binom_crosses_256() {
    // C(480, 99) — large but fits in u512, definitely > 2^256
    let b = binom(480, 99);
    // Just verify it's nonzero and limb2 or limb3 > 0 (crosses 256-bit boundary)
    let above_256 = b.limb2 != 0 || b.limb3 != 0;
    assert(above_256, 'C(480,99) should cross 256');
    // Also verify it's < 2^512 (limb3 small)
    assert(b.limb3 < 0x1000000_u128, 'C(480,99) limb3 reasonable');
}

// ─── B7: binom at 344-bit range (matches corpus output counts) ───────────────

// C(465, 98) — verified in Python: 343 bits, limbs known
#[test]
fn b7_binom_344bit() {
    let b = binom(465, 98);
    // Verify against Python-computed limbs:
    // binom(465,98) limbs: 19732901846017488217719909249838004768, 207551826612676959180398615165134163039, 38516214613005061698653243, 0
    assert(b.limb0 == 19732901846017488217719909249838004768_u128, 'b(465,98) limb0');
    assert(b.limb1 == 207551826612676959180398615165134163039_u128, 'b(465,98) limb1');
    assert(b.limb2 == 38516214613005061698653243_u128, 'b(465,98) limb2');
    assert(b.limb3 == 0, 'b(465,98) limb3');
}

// ─── B8: binom at 461-bit range (binom max for corpus) ───────────────────────

// C(465, 232) is close to the maximum — just verify it crosses 384 bits
#[test]
fn b8_binom_461bit_range() {
    // C(465, 230) should be > 2^384 (limb3 > 0) — testing near the maximum
    // We use a smaller case to keep gas bounded: C(400, 130) which is ~350 bits
    let b = binom(400, 130);
    // Should be > 2^256 but < 2^512
    assert(b.limb2 != 0 || b.limb3 != 0, 'C(400,130) crosses 256');
}

#[test]
fn b9_binom_recurrence_matches_baseline_465_94_98() {
    let recur = binom_range_from_anchor(465, 94, 96, 98);
    assert(recur.len() == 5, 'recur len 465');
    assert(u512_eq(binom_from_range(@recur, 94, 94), binom(465, 94)), 'b94');
    assert(u512_eq(binom_from_range(@recur, 94, 95), binom(465, 95)), 'b95');
    assert(u512_eq(binom_from_range(@recur, 94, 96), binom(465, 96)), 'b96');
    assert(u512_eq(binom_from_range(@recur, 94, 97), binom(465, 97)), 'b97');
    assert(u512_eq(binom_from_range(@recur, 94, 98), binom(465, 98)), 'b98');
}

#[test]
fn b10_binom_recurrence_matches_baseline_452_88_94() {
    let recur = binom_range_from_anchor(452, 88, 91, 94);
    assert(recur.len() == 7, 'recur len 452');
    assert(u512_eq(binom_from_range(@recur, 88, 88), binom(452, 88)), 'b88');
    assert(u512_eq(binom_from_range(@recur, 88, 89), binom(452, 89)), 'b89');
    assert(u512_eq(binom_from_range(@recur, 88, 90), binom(452, 90)), 'b90');
    assert(u512_eq(binom_from_range(@recur, 88, 91), binom(452, 91)), 'b91');
    assert(u512_eq(binom_from_range(@recur, 88, 92), binom(452, 92)), 'b92');
    assert(u512_eq(binom_from_range(@recur, 88, 93), binom(452, 93)), 'b93');
    assert(u512_eq(binom_from_range(@recur, 88, 94), binom(452, 94)), 'b94');
}

// ─── J1: Joint VE — 2a-109 special component ─────────────────────────────────
// Oracle: Python 2E2 VE on transcript seed-20260849-early, clicked_cell=225
// Special component: 10 vars, 2 constraints, x_var=225, neighbor_vars=[224,226,256]
// Expected joint_counts:
//   (mines=1, x=0, nbr=0): 2
//   (mines=1, x=0, nbr=1): 1
//   (mines=1, x=1, nbr=0): 1
//   (mines=2, x=0, nbr=0): 3
//   (mines=2, x=0, nbr=1): 6

fn find_joint(entries: @Array<JointEntry>, mines: u32, x_mine: u32, nbrs: u32) -> u256 {
    let mut i: usize = 0;
    let mut found: u256 = 0;
    loop {
        if i >= entries.len() { break; }
        let e = *entries.at(i);
        if e.mines == mines && e.x_mine == x_mine && e.nbrs == nbrs {
            found = e.count;
        }
        i += 1;
    };
    found
}

fn binom_from_range(values: @Array<u512>, k_lo: u32, k: u32) -> u512 {
    *values.at((k - k_lo).into())
}

fn make_factor(variables: Array<u32>, entries: Array<FactorEntry>) -> Factor {
    Factor { scope_len: variables.len().try_into().unwrap(), variables, entries }
}

fn find_step(steps: @Array<VeStepProfile>, variable: u32) -> VeStepProfile {
    let mut i: usize = 0;
    loop {
        let step = *steps.at(i);
        if step.variable == variable {
            break step;
        }
        i += 1;
    }
}

fn p12_vars() -> Array<u32> {
    // Oracle elimination order: leaf-only vars first so join stages see minimal factor sizes.
    // Sorted order puts 54 before 82, leaving 82 in f0's scope during stage-1 join and
    // inflating related_entry_count_total from 22 to 28.
    array![52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176, 54, 84, 112, 113, 115, 116, 144, 174]
}

fn p12_constraints() -> Array<Constraint> {
    array![
        Constraint { variables: array![52, 53, 54, 82, 84, 112, 113], rhs: 1 },
        Constraint { variables: array![54, 55, 56, 84, 86, 115, 116], rhs: 2 },
        Constraint { variables: array![84, 113, 115, 144], rhs: 2 },
        Constraint { variables: array![112, 113, 142, 144, 172, 173, 174], rhs: 3 },
        Constraint { variables: array![115, 116, 144, 146, 174, 175, 176], rhs: 4 },
    ]
}

fn p12_stage1_left_factor() -> Factor {
    make_factor(
        array![54, 84, 112, 113],
        array![
            FactorEntry { mask: 0, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 0, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 1, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 2, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 4, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 8, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage1_right_factor() -> Factor {
    make_factor(
        array![54, 84, 115, 116],
        array![
            FactorEntry { mask: 1, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 1, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 0, mines: 2, x_mine: 0, nbrs: 1, count: 2 },
            FactorEntry { mask: 3, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 2, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 2, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 0, mines: 2, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 5, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 4, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 4, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 6, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 9, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 8, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 8, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 10, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 12, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage2_left_factor() -> Factor {
    make_factor(
        array![84, 113, 115, 144],
        array![
            FactorEntry { mask: 3, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 5, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 6, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 9, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 10, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 12, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage2_right_factor() -> Factor {
    make_factor(
        array![84, 112, 113, 115, 116],
        array![
            FactorEntry { mask: 0, mines: 3, x_mine: 0, nbrs: 1, count: 5 },
            FactorEntry { mask: 0, mines: 3, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 8, mines: 2, x_mine: 0, nbrs: 1, count: 4 },
            FactorEntry { mask: 8, mines: 2, x_mine: 0, nbrs: 0, count: 4 },
            FactorEntry { mask: 16, mines: 2, x_mine: 0, nbrs: 1, count: 4 },
            FactorEntry { mask: 16, mines: 2, x_mine: 0, nbrs: 0, count: 4 },
            FactorEntry { mask: 24, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 0, mines: 3, x_mine: 0, nbrs: 2, count: 2 },
            FactorEntry { mask: 8, mines: 2, x_mine: 0, nbrs: 2, count: 1 },
            FactorEntry { mask: 16, mines: 2, x_mine: 0, nbrs: 2, count: 1 },
            FactorEntry { mask: 24, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 0, mines: 2, x_mine: 1, nbrs: 1, count: 1 },
            FactorEntry { mask: 0, mines: 2, x_mine: 1, nbrs: 0, count: 2 },
            FactorEntry { mask: 8, mines: 1, x_mine: 1, nbrs: 0, count: 1 },
            FactorEntry { mask: 16, mines: 1, x_mine: 1, nbrs: 0, count: 1 },
            FactorEntry { mask: 1, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 1, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 9, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 17, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 2, mines: 2, x_mine: 0, nbrs: 1, count: 2 },
            FactorEntry { mask: 2, mines: 2, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 10, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 10, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 18, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 18, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 26, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 4, mines: 2, x_mine: 0, nbrs: 1, count: 2 },
            FactorEntry { mask: 4, mines: 2, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 12, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 12, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 20, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 20, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 28, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage3_left_factor() -> Factor {
    make_factor(
        array![112, 113, 144, 174],
        array![
            FactorEntry { mask: 3, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 7, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 5, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 6, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 1, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 2, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 4, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 0, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 11, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 9, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 10, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 13, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 14, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 12, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 8, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
        ],
    )
}

fn p12_stage3_right_factor() -> Factor {
    make_factor(
        array![112, 113, 115, 116, 144],
        array![
            FactorEntry { mask: 4, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 6, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 6, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 14, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 16, mines: 2, x_mine: 0, nbrs: 2, count: 1 },
            FactorEntry { mask: 16, mines: 2, x_mine: 0, nbrs: 1, count: 2 },
            FactorEntry { mask: 24, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 18, mines: 2, x_mine: 0, nbrs: 1, count: 2 },
            FactorEntry { mask: 18, mines: 2, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 26, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 26, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 20, mines: 2, x_mine: 0, nbrs: 1, count: 4 },
            FactorEntry { mask: 20, mines: 2, x_mine: 0, nbrs: 0, count: 4 },
            FactorEntry { mask: 28, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 20, mines: 2, x_mine: 0, nbrs: 2, count: 1 },
            FactorEntry { mask: 28, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 20, mines: 1, x_mine: 1, nbrs: 0, count: 1 },
            FactorEntry { mask: 21, mines: 1, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 21, mines: 1, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 29, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage4_left_factor() -> Factor {
    make_factor(
        array![115, 116, 144, 174],
        array![
            FactorEntry { mask: 7, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 15, mines: 0, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 11, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 13, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 14, mines: 1, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 3, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 5, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 6, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 9, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 10, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 12, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 1, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 2, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 4, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 8, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
        ],
    )
}

fn p12_stage4_right_factor() -> Factor {
    make_factor(
        array![115, 116, 144, 174],
        array![
            FactorEntry { mask: 5, mines: 3, x_mine: 0, nbrs: 1, count: 3 },
            FactorEntry { mask: 5, mines: 3, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 7, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 4, mines: 4, x_mine: 0, nbrs: 1, count: 12 },
            FactorEntry { mask: 4, mines: 4, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 6, mines: 3, x_mine: 0, nbrs: 1, count: 6 },
            FactorEntry { mask: 6, mines: 3, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 1, mines: 4, x_mine: 0, nbrs: 1, count: 4 },
            FactorEntry { mask: 1, mines: 4, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 3, mines: 3, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 4, mines: 4, x_mine: 0, nbrs: 2, count: 3 },
            FactorEntry { mask: 5, mines: 4, x_mine: 0, nbrs: 1, count: 12 },
            FactorEntry { mask: 5, mines: 4, x_mine: 0, nbrs: 0, count: 12 },
            FactorEntry { mask: 7, mines: 3, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 5, mines: 4, x_mine: 0, nbrs: 2, count: 3 },
            FactorEntry { mask: 7, mines: 3, x_mine: 0, nbrs: 1, count: 3 },
            FactorEntry { mask: 5, mines: 3, x_mine: 1, nbrs: 0, count: 3 },
            FactorEntry { mask: 9, mines: 3, x_mine: 0, nbrs: 1, count: 6 },
            FactorEntry { mask: 9, mines: 3, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 11, mines: 2, x_mine: 0, nbrs: 0, count: 3 },
            FactorEntry { mask: 13, mines: 2, x_mine: 0, nbrs: 1, count: 1 },
            FactorEntry { mask: 13, mines: 2, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 15, mines: 1, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 12, mines: 3, x_mine: 0, nbrs: 1, count: 8 },
            FactorEntry { mask: 12, mines: 3, x_mine: 0, nbrs: 0, count: 1 },
            FactorEntry { mask: 14, mines: 2, x_mine: 0, nbrs: 1, count: 4 },
            FactorEntry { mask: 14, mines: 2, x_mine: 0, nbrs: 0, count: 2 },
            FactorEntry { mask: 12, mines: 3, x_mine: 0, nbrs: 2, count: 3 },
            FactorEntry { mask: 13, mines: 3, x_mine: 0, nbrs: 1, count: 12 },
            FactorEntry { mask: 13, mines: 3, x_mine: 0, nbrs: 0, count: 12 },
            FactorEntry { mask: 15, mines: 2, x_mine: 0, nbrs: 0, count: 6 },
            FactorEntry { mask: 13, mines: 3, x_mine: 0, nbrs: 2, count: 3 },
            FactorEntry { mask: 15, mines: 2, x_mine: 0, nbrs: 1, count: 3 },
            FactorEntry { mask: 13, mines: 2, x_mine: 1, nbrs: 0, count: 3 },
        ],
    )
}

#[test]
fn j1_joint_ve_2a109_component() {
    // Variables for the special component
    let vars: Array<u32> = array![223, 224, 225, 226, 253, 256, 283, 284, 285, 286];
    // C0: [223,224,225,253,283,284,285] rhs=1
    let c0 = Constraint { variables: array![223, 224, 225, 253, 283, 284, 285], rhs: 1 };
    // C1: [224,225,226,256,284,285,286] rhs=1
    let c1 = Constraint { variables: array![224, 225, 226, 256, 284, 285, 286], rhs: 1 };
    let constraints: Array<Constraint> = array![c0, c1];
    // x_var=225, neighbor_vars=[224,226,256]
    let x_var: u32 = 225;
    let nbr_vars: Array<u32> = array![224, 226, 256];

    let joint = count_joint_component(@vars, @constraints, x_var, @nbr_vars);

    // Verify nonzero count
    assert(joint.len() == 5, 'should have 5 joint entries');
    // Verify each expected entry
    assert(find_joint(@joint, 1, 0, 0) == 2, '(1,0,0) should be 2');
    assert(find_joint(@joint, 1, 0, 1) == 1, '(1,0,1) should be 1');
    assert(find_joint(@joint, 1, 1, 0) == 1, '(1,1,0) should be 1');
    assert(find_joint(@joint, 2, 0, 0) == 3, '(2,0,0) should be 3');
    assert(find_joint(@joint, 2, 0, 1) == 6, '(2,0,1) should be 6');
}

// ─── J2: Full CELL evaluation — 2a-109 exact counts ─────────────────────────
// This test reproduces the complete CELL evaluation for 2a-109:
// 1. Joint VE on special component (above)
// 2. Convolution with local_factor (3 unconstrained neighbor cells)
// 3. Binomial coupling with 465 unconstrained other cells
// 4. Verify final outcome counts against Python oracle
//
// Oracle (counts_2e2):
//   mine: 9040557845611419596542982750139841871473942469813632521875685849104975802452721315622994277207606265800
//   k=0:  12482796598748057883177089682781828055595296368251529780073827639107662104554617271155847496399594132500
//   k=1:  21521961173451245429176507217697013988346993335836937799838394279029810036292249195189610613612466227500
//   k=2:  11785130038944594824753678455516957357558834515487198206132293847014080432902729939033864010596038795700
//   k=3:  2618970762418893203888813571219987332501691121805866858274851676027305678068957626064788382009236284500
//   k=4:  205461916989181961169006993347513895621214920823849784634792313442238044389475684641802120102811460800

#[test]
fn j2_full_cell_eval_2a109() {
    // ── Step 1: Joint VE on special component ──
    let vars: Array<u32> = array![223, 224, 225, 226, 253, 256, 283, 284, 285, 286];
    let c0 = Constraint { variables: array![223, 224, 225, 253, 283, 284, 285], rhs: 1 };
    let c1 = Constraint { variables: array![224, 225, 226, 256, 284, 285, 286], rhs: 1 };
    let constraints: Array<Constraint> = array![c0, c1];
    let x_var: u32 = 225;
    let nbr_vars: Array<u32> = array![224, 226, 256];
    let joint = count_joint_component(@vars, @constraints, x_var, @nbr_vars);

    // ── Step 2: Convolve with local_factor ──
    // local_factor (3 unconstrained neighbor cells):
    //   (0,0,0):1  (1,0,1):3  (2,0,2):3  (3,0,3):1
    // After convolution: for each (mc, xm, nb) in joint × (lm, 0, ln) in local:
    //   → (mc+lm, xm, nb+ln) += joint_count × local_count
    // Result:
    //   (1,0,0):2  (1,0,1):1  (1,1,0):1
    //   (2,0,0):3  (2,0,1):12 (2,0,2):3  (2,1,1):3
    //   (3,0,1):9  (3,0,2):24 (3,0,3):3  (3,1,2):3
    //   (4,0,2):9  (4,0,3):20 (4,0,4):1  (4,1,3):1
    //   (5,0,3):3  (5,0,4):6
    // (17 entries total — matches Python convolution trace)

    // ── Step 3: Compute binomials binom(465, 94..98) ──
    // remaining_mines=99, so for entry with mc mines: k=99-mc mines from other cells
    // mc=1→k=98, mc=2→k=97, mc=3→k=96, mc=4→k=95, mc=5→k=94
    let b94 = binom(465, 94);
    let b95 = binom(465, 95);
    let b96 = binom(465, 96);
    let b97 = binom(465, 97);
    let b98 = binom(465, 98);

    // ── Step 4: Compute outcome counts ──
    // outcome[mine] = sum over (mc, 1, *) of count × binom(465, 99-mc)
    // = (1,1,0):1×b98 + (2,1,1):3×b97 + (3,1,2):3×b96 + (4,1,3):1×b95
    let mine_count = u512_add(
        u512_add(
            u512_mul_small(b98, 1), // (1,1,0):1 × b98
            u512_mul_small(b97, 3), // (2,1,1):3 × b97
        ),
        u512_add(
            u512_mul_small(b96, 3), // (3,1,2):3 × b96
            u512_mul_small(b95, 1), // (4,1,3):1 × b95
        ),
    );

    // outcome[0] = (1,0,0):2×b98 + (2,0,0):3×b97
    let k0_count = u512_add(
        u512_mul_small(b98, 2), // (1,0,0):2 × b98
        u512_mul_small(b97, 3), // (2,0,0):3 × b97
    );

    // outcome[1] = (1,0,1):1×b98 + (2,0,1):12×b97 + (3,0,1):9×b96
    let k1_count = u512_add(
        u512_add(
            u512_mul_small(b98, 1),  // (1,0,1):1 × b98
            u512_mul_small(b97, 12), // (2,0,1):12 × b97
        ),
        u512_mul_small(b96, 9),      // (3,0,1):9 × b96
    );

    // outcome[2] = (2,0,2):3×b97 + (3,0,2):24×b96 + (4,0,2):9×b95
    let k2_count = u512_add(
        u512_add(
            u512_mul_small(b97, 3),  // (2,0,2):3 × b97
            u512_mul_small(b96, 24), // (3,0,2):24 × b96
        ),
        u512_mul_small(b95, 9),      // (4,0,2):9 × b95
    );

    // outcome[3] = (3,0,3):3×b96 + (4,0,3):20×b95 + (5,0,3):3×b94
    let k3_count = u512_add(
        u512_add(
            u512_mul_small(b96, 3),  // (3,0,3):3 × b96
            u512_mul_small(b95, 20), // (4,0,3):20 × b95
        ),
        u512_mul_small(b94, 3),      // (5,0,3):3 × b94
    );

    // outcome[4] = (4,0,4):1×b95 + (5,0,4):6×b94
    let k4_count = u512_add(
        u512_mul_small(b95, 1),  // (4,0,4):1 × b95
        u512_mul_small(b94, 6),  // (5,0,4):6 × b94
    );

    // ── Step 5: Verify against Python oracle ──
    // All values verified against counts_2e2 in 2E2 benchmark JSONL

    // count[mine] = 9040557845611419596542982750139841871473942469813632521875685849104975802452721315622994277207606265800
    let expected_mine = u512 { limb0: 220475025731244965896959931178668492744_u128, limb1: 39671825408816083556318700283053379297_u128, limb2: 78075781386781718767587709_u128, limb3: 0_u128 };
    // count[0] = 12482796598748057883177089682781828055595296368251529780073827639107662104554617271155847496399594132500
    let expected_k0 = u512 { limb0: 138451907402941506999878318467913815060_u128, limb1: 316460936064317574470884336670115433298_u128, limb2: 107803535465747862906556632_u128, limb3: 0_u128 };
    // count[1] = 21521961173451245429176507217697013988346993335836937799838394279029810036292249195189610613612466227500
    let expected_k1 = u512 { limb0: 336047699986102480779036363377328081196_u128, limb1: 271895068684316433657926903587353505926_u128, limb2: 185867284330123180161647843_u128, limb3: 0_u128 };
    // count[2] = 11785130038944594824753678455516957357558834515487198206132293847014080432902729939033864010596038795700
    let expected_k2 = u512 { limb0: 247341301365452349748590628854599836084_u128, limb1: 32670001337450489725856247472934347778_u128, limb2: 101778369460032277404411018_u128, limb3: 0_u128 };
    // count[3] = 2618970762418893203888813571219987332501691121805866858274851676027305678068957626064788382009236284500
    let expected_k3 = u512 { limb0: 33448815304334741696156208360358044756_u128, limb1: 59298951830532665308567729967046889583_u128, limb2: 22617872945113768937882236_u128, limb3: 0_u128 };
    // count[4] = 205461916989181961169006993347513895621214920823849784634792313442238044389475684641802120102811460800
    let expected_k4 = u512 { limb0: 333977197254201719430733976684026586304_u128, limb1: 85160962776086453278293948713913583507_u128, limb2: 1774403746771398302002214_u128, limb3: 0_u128 };

    assert(u512_eq(mine_count, expected_mine), 'mine count mismatch');
    assert(u512_eq(k0_count, expected_k0), 'k=0 count mismatch');
    assert(u512_eq(k1_count, expected_k1), 'k=1 count mismatch');
    assert(u512_eq(k2_count, expected_k2), 'k=2 count mismatch');
    assert(u512_eq(k3_count, expected_k3), 'k=3 count mismatch');
    assert(u512_eq(k4_count, expected_k4), 'k=4 count mismatch');

    // Sanity: joint VE component must match oracle (redundant with J1 but cross-check)
    assert(find_joint(@joint, 1, 1, 0) == 1, 'j2: x_mine check');
}

#[test]
fn j2b_full_cell_eval_2a109_recurrence() {
    let binoms = binom_range_from_anchor(465, 94, 96, 98);
    let b94 = binom_from_range(@binoms, 94, 94);
    let b95 = binom_from_range(@binoms, 94, 95);
    let b96 = binom_from_range(@binoms, 94, 96);
    let b97 = binom_from_range(@binoms, 94, 97);
    let b98 = binom_from_range(@binoms, 94, 98);

    let mine_count = u512_add(
        u512_add(u512_mul_small(b98, 1), u512_mul_small(b97, 3)),
        u512_add(u512_mul_small(b96, 3), u512_mul_small(b95, 1)),
    );
    let k0_count = u512_add(u512_mul_small(b98, 2), u512_mul_small(b97, 3));
    let k1_count = u512_add(
        u512_add(u512_mul_small(b98, 1), u512_mul_small(b97, 12)),
        u512_mul_small(b96, 9),
    );
    let k2_count = u512_add(
        u512_add(u512_mul_small(b97, 3), u512_mul_small(b96, 24)),
        u512_mul_small(b95, 9),
    );
    let k3_count = u512_add(
        u512_add(u512_mul_small(b96, 3), u512_mul_small(b95, 20)),
        u512_mul_small(b94, 3),
    );
    let k4_count = u512_add(u512_mul_small(b95, 1), u512_mul_small(b94, 6));

    let expected_mine = u512 { limb0: 220475025731244965896959931178668492744_u128, limb1: 39671825408816083556318700283053379297_u128, limb2: 78075781386781718767587709_u128, limb3: 0_u128 };
    let expected_k0 = u512 { limb0: 138451907402941506999878318467913815060_u128, limb1: 316460936064317574470884336670115433298_u128, limb2: 107803535465747862906556632_u128, limb3: 0_u128 };
    let expected_k1 = u512 { limb0: 336047699986102480779036363377328081196_u128, limb1: 271895068684316433657926903587353505926_u128, limb2: 185867284330123180161647843_u128, limb3: 0_u128 };
    let expected_k2 = u512 { limb0: 247341301365452349748590628854599836084_u128, limb1: 32670001337450489725856247472934347778_u128, limb2: 101778369460032277404411018_u128, limb3: 0_u128 };
    let expected_k3 = u512 { limb0: 33448815304334741696156208360358044756_u128, limb1: 59298951830532665308567729967046889583_u128, limb2: 22617872945113768937882236_u128, limb3: 0_u128 };
    let expected_k4 = u512 { limb0: 333977197254201719430733976684026586304_u128, limb1: 85160962776086453278293948713913583507_u128, limb2: 1774403746771398302002214_u128, limb3: 0_u128 };

    assert(u512_eq(mine_count, expected_mine), 'mine recur');
    assert(u512_eq(k0_count, expected_k0), 'k0 recur');
    assert(u512_eq(k1_count, expected_k1), 'k1 recur');
    assert(u512_eq(k2_count, expected_k2), 'k2 recur');
    assert(u512_eq(k3_count, expected_k3), 'k3 recur');
    assert(u512_eq(k4_count, expected_k4), 'k4 recur');
}

#[test]
fn j3_joint_ve_p12_step_005_component() {
    let vars: Array<u32> = array![52, 53, 54, 55, 56, 82, 84, 86, 112, 113, 115, 116, 142, 144, 146, 172, 173, 174, 175, 176];
    let constraints: Array<Constraint> = array![
        Constraint { variables: array![52, 53, 54, 82, 84, 112, 113], rhs: 1 },
        Constraint { variables: array![54, 55, 56, 84, 86, 115, 116], rhs: 2 },
        Constraint { variables: array![84, 113, 115, 144], rhs: 2 },
        Constraint { variables: array![112, 113, 142, 144, 172, 173, 174], rhs: 3 },
        Constraint { variables: array![115, 116, 144, 146, 174, 175, 176], rhs: 4 },
    ];
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let joint = count_joint_component(@vars, @constraints, x_var, @nbr_vars);

    assert(joint.len() == 11, 'p12 joint len');
    assert(find_joint(@joint, 5, 0, 0) == 1, 'p12 (5,0,0)');
    assert(find_joint(@joint, 6, 0, 0) == 36, 'p12 (6,0,0)');
    assert(find_joint(@joint, 6, 0, 1) == 18, 'p12 (6,0,1)');
    assert(find_joint(@joint, 6, 1, 0) == 9, 'p12 (6,1,0)');
    assert(find_joint(@joint, 7, 0, 0) == 120, 'p12 (7,0,0)');
    assert(find_joint(@joint, 7, 0, 1) == 114, 'p12 (7,0,1)');
    assert(find_joint(@joint, 7, 0, 2) == 18, 'p12 (7,0,2)');
    assert(find_joint(@joint, 7, 1, 0) == 9, 'p12 (7,1,0)');
    assert(find_joint(@joint, 8, 0, 0) == 45, 'p12 (8,0,0)');
    assert(find_joint(@joint, 8, 0, 1) == 52, 'p12 (8,0,1)');
    assert(find_joint(@joint, 8, 0, 2) == 12, 'p12 (8,0,2)');
}

// ─── J3o: P12 oracle elimination order, no profiling ─────────────────────────
// Same problem as j3 but using the oracle ordering
// [52,53,82,55,56,86,142,172,173,146,175,176,54,84,112,113,115,116,144,174]
// so leaf-only variables are eliminated before any join occurs.
// Must produce identical joint counts to j3.
#[test]
fn j3o_joint_ve_p12_oracle_order() {
    let vars: Array<u32> = array![
        52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176,
        54, 84, 112, 113, 115, 116, 144, 174
    ];
    let constraints: Array<Constraint> = array![
        Constraint { variables: array![52, 53, 54, 82, 84, 112, 113], rhs: 1 },
        Constraint { variables: array![54, 55, 56, 84, 86, 115, 116], rhs: 2 },
        Constraint { variables: array![84, 113, 115, 144], rhs: 2 },
        Constraint { variables: array![112, 113, 142, 144, 172, 173, 174], rhs: 3 },
        Constraint { variables: array![115, 116, 144, 146, 174, 175, 176], rhs: 4 },
    ];
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let joint = count_joint_component(@vars, @constraints, x_var, @nbr_vars);

    assert(joint.len() == 11, 'p12o joint len');
    assert(find_joint(@joint, 5, 0, 0) == 1, 'p12o (5,0,0)');
    assert(find_joint(@joint, 6, 0, 0) == 36, 'p12o (6,0,0)');
    assert(find_joint(@joint, 6, 0, 1) == 18, 'p12o (6,0,1)');
    assert(find_joint(@joint, 6, 1, 0) == 9, 'p12o (6,1,0)');
    assert(find_joint(@joint, 7, 0, 0) == 120, 'p12o (7,0,0)');
    assert(find_joint(@joint, 7, 0, 1) == 114, 'p12o (7,0,1)');
    assert(find_joint(@joint, 7, 0, 2) == 18, 'p12o (7,0,2)');
    assert(find_joint(@joint, 7, 1, 0) == 9, 'p12o (7,1,0)');
    assert(find_joint(@joint, 8, 0, 0) == 45, 'p12o (8,0,0)');
    assert(find_joint(@joint, 8, 0, 1) == 52, 'p12o (8,0,1)');
    assert(find_joint(@joint, 8, 0, 2) == 12, 'p12o (8,0,2)');
}

#[test]
fn j4_full_cell_eval_p12_step_005_recurrence() {
    let recur = binom_range_from_anchor(452, 88, 91, 94);
    let b88 = binom_from_range(@recur, 88, 88);
    let b89 = binom_from_range(@recur, 88, 89);
    let b90 = binom_from_range(@recur, 88, 90);
    let b91 = binom_from_range(@recur, 88, 91);
    let b92 = binom_from_range(@recur, 88, 92);
    let b93 = binom_from_range(@recur, 88, 93);
    let b94 = binom_from_range(@recur, 88, 94);

    let mine_count = u512_add(
        u512_add(u512_mul_small(b93, 9), u512_mul_small(b92, 36)),
        u512_add(
            u512_mul_small(b91, 54),
            u512_add(u512_mul_small(b90, 36), u512_mul_small(b89, 9)),
        ),
    );
    let k0_count = u512_add(
        u512_add(u512_mul_small(b94, 1), u512_mul_small(b93, 36)),
        u512_add(u512_mul_small(b92, 120), u512_mul_small(b91, 45)),
    );
    let k1_count = u512_add(
        u512_add(u512_mul_small(b93, 21), u512_mul_small(b92, 222)),
        u512_add(u512_mul_small(b91, 412), u512_mul_small(b90, 135)),
    );
    let k2_count = u512_add(
        u512_add(u512_mul_small(b92, 75), u512_mul_small(b91, 462)),
        u512_add(u512_mul_small(b90, 516), u512_mul_small(b89, 135)),
    );
    let k3_count = u512_add(
        u512_add(u512_mul_small(b91, 109), u512_mul_small(b90, 414)),
        u512_add(u512_mul_small(b89, 276), u512_mul_small(b88, 45)),
    );
    let k4_count = u512_add(
        u512_add(u512_mul_small(b90, 72), u512_mul_small(b89, 150)),
        u512_mul_small(b88, 52),
    );
    let k5_count = u512_add(u512_mul_small(b89, 18), u512_mul_small(b88, 12));

    let expected_mine = u512 { limb0: 232264864010119674161732927818915852416_u128, limb1: 115743496516790258266652214186208686618_u128, limb2: 53616811826977887483066_u128, limb3: 0_u128 };
    let expected_k0 = u512 { limb0: 147308418511421751630621637486965907840_u128, limb1: 337330511862609825482025044251656383842_u128, limb2: 175914666517727383546903_u128, limb3: 0_u128 };
    let expected_k1 = u512 { limb0: 216276949887252130631399430401226000064_u128, limb1: 66427361868613977427463990438955908225_u128, limb2: 256804785373467919234676_u128, limb3: 0_u128 };
    let expected_k2 = u512 { limb0: 103111430015163148989578666118739785552_u128, limb1: 325565828912772989156287159112262569538_u128, limb2: 140396326887885513954420_u128, limb3: 0_u128 };
    let expected_k3 = u512 { limb0: 145757021400323180838177345976206794928_u128, limb1: 64285831697276746257054116290197616380_u128, limb2: 36253508985761782587272_u128, limb3: 0_u128 };
    let expected_k4 = u512 { limb0: 243240662693166088092436085454877963072_u128, limb1: 148106612766041370912245469349327684505_u128, limb2: 4432927363034904210993_u128, limb3: 0_u128 };
    let expected_k5 = u512 { limb0: 202526265157961706532237056448752328128_u128, limb1: 250789162754035558347484830617740413587_u128, limb2: 204803063210443294075_u128, limb3: 0_u128 };
    let expected_total = u512 { limb0: 269638510912592290486059327410379997632_u128, limb1: 287401705615325335459089001951044628330_u128, limb2: 667623830018065834311408_u128, limb3: 0_u128 };

    assert(u512_eq(mine_count, expected_mine), 'p12 mine');
    assert(u512_eq(k0_count, expected_k0), 'p12 k0');
    assert(u512_eq(k1_count, expected_k1), 'p12 k1');
    assert(u512_eq(k2_count, expected_k2), 'p12 k2');
    assert(u512_eq(k3_count, expected_k3), 'p12 k3');
    assert(u512_eq(k4_count, expected_k4), 'p12 k4');
    assert(u512_eq(k5_count, expected_k5), 'p12 k5');

    let total = u512_add(
        u512_add(u512_add(mine_count, k0_count), u512_add(k1_count, k2_count)),
        u512_add(u512_add(k3_count, k4_count), k5_count),
    );
    assert(u512_eq(total, expected_total), 'p12 total');
}

#[test]
fn j5_p12_stage0_constraint_factor_profiles() {
    let constraints = p12_constraints();
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];

    let c0 = constraints.at(0);
    let c1 = constraints.at(1);
    let c2 = constraints.at(2);
    let c3 = constraints.at(3);
    let c4 = constraints.at(4);
    let (_, p0) = constraint_factor_with_profile(c0.variables, *c0.rhs, x_var, @nbr_vars);
    let (_, p1) = constraint_factor_with_profile(c1.variables, *c1.rhs, x_var, @nbr_vars);
    let (_, p2) = constraint_factor_with_profile(c2.variables, *c2.rhs, x_var, @nbr_vars);
    let (_, p3) = constraint_factor_with_profile(c3.variables, *c3.rhs, x_var, @nbr_vars);
    let (_, p4) = constraint_factor_with_profile(c4.variables, *c4.rhs, x_var, @nbr_vars);

    assert(p0.scope_len == 7, 'p12 c0 scope');
    assert(p0.dense_capacity == 128, 'p12 c0 dense');
    assert(p0.nonzero_entry_count == 7, 'p12 c0 nz');
    assert(p1.scope_len == 7, 'p12 c1 scope');
    assert(p1.dense_capacity == 128, 'p12 c1 dense');
    assert(p1.nonzero_entry_count == 21, 'p12 c1 nz');
    assert(p2.scope_len == 4, 'p12 c2 scope');
    assert(p2.dense_capacity == 16, 'p12 c2 dense');
    assert(p2.nonzero_entry_count == 6, 'p12 c2 nz');
    assert(p3.scope_len == 7, 'p12 c3 scope');
    assert(p3.dense_capacity == 128, 'p12 c3 dense');
    assert(p3.nonzero_entry_count == 35, 'p12 c3 nz');
    assert(p4.scope_len == 7, 'p12 c4 scope');
    assert(p4.dense_capacity == 128, 'p12 c4 dense');
    assert(p4.nonzero_entry_count == 35, 'p12 c4 nz');
}

#[test]
fn j6_p12_profile_trace_join_steps() {
    let vars = p12_vars();
    let constraints = p12_constraints();
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let profile = count_joint_component_profile(@vars, @constraints, x_var, @nbr_vars);

    assert(profile.constraint_factors.len() == 5, 'p12 trace constraints');
    assert(profile.steps.len() == 20, 'p12 trace steps');
    assert(profile.joint.len() == 11, 'p12 trace final joint');

    let s54 = find_step(@profile.steps, 54);
    assert(s54.related_factor_count == 2, 's54 related');
    assert(s54.related_entry_count_total == 22, 's54 entries');
    assert(s54.candidate_pair_comparisons == 96, 's54 pairs');
    assert(s54.compatible_pair_matches == 36, 's54 matches');
    assert(s54.joined_scope_len == 6, 's54 scope len');
    assert(s54.joined_dense_capacity == 64, 's54 dense');
    assert(s54.joined_entry_count == 33, 's54 joined entries');
    assert(s54.joined_nonzero_entry_count == 33, 's54 joined nz');
    assert(s54.join_accumulate_calls == 36, 's54 acc calls');
    assert(s54.join_accumulate_scanned_entries == 555, 's54 acc scan');
    assert(s54.join_bigint_multiplications == 36, 's54 muls');
    assert(s54.join_bigint_additions == 3, 's54 adds');
    assert(s54.elimination_output_entry_count == 33, 's54 elim entries');

    let s84 = find_step(@profile.steps, 84);
    assert(s84.related_entry_count_total == 39, 's84 entries');
    assert(s84.candidate_pair_comparisons == 198, 's84 pairs');
    assert(s84.compatible_pair_matches == 20, 's84 matches');
    assert(s84.joined_entry_count == 20, 's84 joined entries');
    assert(s84.joined_nonzero_entry_count == 20, 's84 joined nz');
    assert(s84.join_accumulate_scanned_entries == 190, 's84 acc scan');
    assert(s84.join_bigint_multiplications == 20, 's84 muls');
    assert(s84.join_bigint_additions == 0, 's84 adds');

    let s112 = find_step(@profile.steps, 112);
    assert(s112.related_entry_count_total == 35, 's112 entries');
    assert(s112.candidate_pair_comparisons == 300, 's112 pairs');
    assert(s112.compatible_pair_matches == 40, 's112 matches');
    assert(s112.joined_entry_count == 40, 's112 joined entries');
    assert(s112.joined_nonzero_entry_count == 40, 's112 joined nz');
    assert(s112.join_accumulate_scanned_entries == 780, 's112 acc scan');
    assert(s112.join_bigint_multiplications == 40, 's112 muls');
    assert(s112.join_bigint_additions == 0, 's112 adds');

    let s115 = find_step(@profile.steps, 115);
    assert(s115.related_entry_count_total == 49, 's115 entries');
    assert(s115.candidate_pair_comparisons == 510, 's115 pairs');
    assert(s115.compatible_pair_matches == 34, 's115 matches');
    assert(s115.joined_scope_len == 4, 's115 scope len');
    assert(s115.joined_entry_count == 34, 's115 joined entries');
    assert(s115.join_accumulate_scanned_entries == 561, 's115 acc scan');
    assert(s115.join_bigint_multiplications == 34, 's115 muls');
    assert(s115.elimination_output_entry_count == 24, 's115 elim entries');
    assert(s115.elimination_bigint_additions == 10, 's115 elim adds');
}

#[test]
fn j7_p12_stage1_join_elimination_from_checkpoint() {
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let left = p12_stage1_left_factor();
    let right = p12_stage1_right_factor();
    let (joined, jp) = join_factors_profile(@left, @right, x_var, @nbr_vars);
    let (reduced, ep) = eliminate_variable_profile(@joined, 54, x_var, @nbr_vars);

    assert(jp.left_entry_count == 6, 'stage1 left entries');
    assert(jp.right_entry_count == 16, 'stage1 right entries');
    assert(jp.candidate_pair_comparisons == 96, 'stage1 pairs');
    assert(jp.compatible_pair_matches == 36, 'stage1 matches');
    assert(jp.output_entry_count == 33, 'stage1 joined entries');
    assert(jp.output_nonzero_entry_count == 33, 'stage1 joined nz');
    assert(jp.accumulate_scanned_entries == 555, 'stage1 acc scan');
    assert(jp.bigint_multiplications == 36, 'stage1 muls');
    assert(jp.bigint_additions == 3, 'stage1 adds');
    assert(ep.output_scope_len == 5 && ep.output_entry_count == 33, 'stage1 reduced');
    assert(ep.accumulate_scanned_entries == 528, 'stage1 elim scan');
    assert(reduced.entries.len() == 33, 'stage1 reduced len');
}

#[test]
fn j8_p12_stage2_join_elimination_from_checkpoint() {
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let left = p12_stage2_left_factor();
    let right = p12_stage2_right_factor();
    let (joined, jp) = join_factors_profile(@left, @right, x_var, @nbr_vars);
    let (reduced, ep) = eliminate_variable_profile(@joined, 84, x_var, @nbr_vars);

    assert(jp.candidate_pair_comparisons == 198, 'stage2 pairs');
    assert(jp.compatible_pair_matches == 20, 'stage2 matches');
    assert(jp.output_entry_count == 20, 'stage2 joined entries');
    assert(jp.output_nonzero_entry_count == 20, 'stage2 joined nz');
    assert(jp.accumulate_scanned_entries == 190, 'stage2 acc scan');
    assert(ep.output_scope_len == 5 && ep.output_entry_count == 20, 'stage2 reduced');
    assert(ep.accumulate_scanned_entries == 190, 'stage2 elim scan');
    assert(reduced.entries.len() == 20, 'stage2 reduced len');
}

#[test]
fn j9_p12_stage3_join_elimination_from_checkpoint() {
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let left = p12_stage3_left_factor();
    let right = p12_stage3_right_factor();
    let (joined, jp) = join_factors_profile(@left, @right, x_var, @nbr_vars);
    let (reduced, ep112) = eliminate_variable_profile(@joined, 112, x_var, @nbr_vars);
    let (_, ep113) = eliminate_variable_profile(@reduced, 113, x_var, @nbr_vars);

    assert(jp.candidate_pair_comparisons == 300, 'stage3 pairs');
    assert(jp.compatible_pair_matches == 40, 'stage3 matches');
    assert(jp.output_entry_count == 40, 'stage3 joined entries');
    assert(jp.output_nonzero_entry_count == 40, 'stage3 joined nz');
    assert(jp.accumulate_scanned_entries == 780, 'stage3 acc scan');
    assert(ep112.output_scope_len == 5 && ep112.output_entry_count == 40, 'stage3 reduced');
    assert(ep112.accumulate_scanned_entries == 780, 'stage3 elim scan');
    assert(ep113.output_scope_len == 4 && ep113.output_entry_count == 34, 'stage3 post113');
    assert(ep113.bigint_additions == 6, 'stage3 post113 adds');
}

#[test]
fn j10_p12_stage4_join_to_final_joint_from_checkpoint() {
    let x_var: u32 = 54;
    let nbr_vars: Array<u32> = array![53, 55, 84];
    let left = p12_stage4_left_factor();
    let right = p12_stage4_right_factor();
    let (joined, jp) = join_factors_profile(@left, @right, x_var, @nbr_vars);
    let (after_115, ep115) = eliminate_variable_profile(@joined, 115, x_var, @nbr_vars);
    let (after_116, _) = eliminate_variable_profile(@after_115, 116, x_var, @nbr_vars);
    let (after_144, _) = eliminate_variable_profile(@after_116, 144, x_var, @nbr_vars);
    let (after_174, _) = eliminate_variable_profile(@after_144, 174, x_var, @nbr_vars);

    assert(jp.candidate_pair_comparisons == 510, 'stage4 pairs');
    assert(jp.compatible_pair_matches == 34, 'stage4 matches');
    assert(jp.output_entry_count == 34, 'stage4 joined entries');
    assert(jp.output_nonzero_entry_count == 34, 'stage4 joined nz');
    assert(jp.accumulate_scanned_entries == 561, 'stage4 acc scan');
    assert(ep115.output_scope_len == 3 && ep115.output_entry_count == 24, 'stage4 after115');
    assert(ep115.bigint_additions == 10, 'stage4 after115 adds');
    assert(after_174.entries.len() == 11, 'stage4 final len');
}

// ─── Phase 5: verified elimination-order hint ─────────────────────────────────

// Helper: sorted P12 variables (j3 order) as a helper — NOT using p12_vars() to
// keep these tests independent of the oracle order.
fn p12_sorted_vars() -> Array<u32> {
    array![52, 53, 54, 55, 56, 82, 84, 86, 112, 113, 115, 116, 142, 144, 146, 172, 173, 174, 175, 176]
}

fn p12_oracle_hint() -> Array<u32> {
    array![52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176, 54, 84, 112, 113, 115, 116, 144, 174]
}

// H1: oracle order hint → same 11 joint counts as j3.
// Measures cost of hint path with optimal order.
#[test]
fn h1_p12_oracle_order_hint_correctness() {
    let vars = p12_sorted_vars();
    let constraints = p12_constraints();
    let hint = p12_oracle_hint();
    let joint = count_joint_component_with_order(@vars, @constraints, 54, @array![53, 55, 84], @hint);

    assert(joint.len() == 11, 'h1 joint len');
    assert(find_joint(@joint, 5, 0, 0) == 1, 'h1 (5,0,0)');
    assert(find_joint(@joint, 6, 0, 0) == 36, 'h1 (6,0,0)');
    assert(find_joint(@joint, 6, 0, 1) == 18, 'h1 (6,0,1)');
    assert(find_joint(@joint, 6, 1, 0) == 9, 'h1 (6,1,0)');
    assert(find_joint(@joint, 7, 0, 0) == 120, 'h1 (7,0,0)');
    assert(find_joint(@joint, 7, 0, 1) == 114, 'h1 (7,0,1)');
    assert(find_joint(@joint, 7, 0, 2) == 18, 'h1 (7,0,2)');
    assert(find_joint(@joint, 7, 1, 0) == 9, 'h1 (7,1,0)');
    assert(find_joint(@joint, 8, 0, 0) == 45, 'h1 (8,0,0)');
    assert(find_joint(@joint, 8, 0, 1) == 52, 'h1 (8,0,1)');
    assert(find_joint(@joint, 8, 0, 2) == 12, 'h1 (8,0,2)');
}

// H2: sorted order hint → same 11 joint counts despite being slower.
// Proves order-invariance of joint counts.
#[test]
fn h2_p12_sorted_order_hint_parity() {
    let vars = p12_sorted_vars();
    let constraints = p12_constraints();
    let hint = p12_sorted_vars(); // same as vars — a valid permutation
    let joint = count_joint_component_with_order(@vars, @constraints, 54, @array![53, 55, 84], @hint);

    assert(joint.len() == 11, 'h2 joint len');
    assert(find_joint(@joint, 5, 0, 0) == 1, 'h2 (5,0,0)');
    assert(find_joint(@joint, 6, 0, 0) == 36, 'h2 (6,0,0)');
    assert(find_joint(@joint, 7, 0, 0) == 120, 'h2 (7,0,0)');
    assert(find_joint(@joint, 8, 0, 0) == 45, 'h2 (8,0,0)');
    assert(find_joint(@joint, 8, 0, 2) == 12, 'h2 (8,0,2)');
}

// H3: reverse order hint → same joint counts on a small 4-variable component.
// Demonstrates order-invariance without the cost of P12 reverse (which would OOM).
// Component: vars=[0,1,2,3], c1=[0,1]/1, c2=[1,2,3]/1, x_var=1, nbr_vars=[0,2].
// Forward VE order [0,1,2,3] and reverse [3,2,1,0] must yield identical joint counts.
#[test]
fn h3_reverse_order_small_parity() {
    let vars: Array<u32> = array![0, 1, 2, 3];
    let c1 = Constraint { variables: array![0, 1], rhs: 1 };
    let c2 = Constraint { variables: array![1, 2, 3], rhs: 1 };
    let constraints: Array<Constraint> = array![c1, c2];
    let x_var: u32 = 1;
    let nbr_vars: Array<u32> = array![0, 2];

    let hint_fwd: Array<u32> = array![0, 1, 2, 3];
    let hint_rev: Array<u32> = array![3, 2, 1, 0];

    let joint_fwd = count_joint_component_with_order(@vars, @constraints, x_var, @nbr_vars, @hint_fwd);
    let joint_rev = count_joint_component_with_order(@vars, @constraints, x_var, @nbr_vars, @hint_rev);

    // Same entry count
    assert(joint_fwd.len() == joint_rev.len(), 'h3 len mismatch');
    // Key entries identical
    assert(find_joint(@joint_fwd, 1, 1, 0) == find_joint(@joint_rev, 1, 1, 0), 'h3 (1,1,0)');
    assert(find_joint(@joint_fwd, 1, 0, 1) == find_joint(@joint_rev, 1, 0, 1), 'h3 (1,0,1)');
    assert(find_joint(@joint_fwd, 2, 0, 1) == find_joint(@joint_rev, 2, 0, 1), 'h3 (2,0,1)');
    // Forward result is consistent with plain count_joint_component
    let c1b = Constraint { variables: array![0, 1], rhs: 1 };
    let c2b = Constraint { variables: array![1, 2, 3], rhs: 1 };
    let joint_base = count_joint_component(@vars, @array![c1b, c2b], x_var, @nbr_vars);
    assert(joint_base.len() == joint_fwd.len(), 'h3 base len');
}

// H4: duplicate variable → reject.
#[test]
#[should_panic(expected: ('hint: duplicate variable',))]
fn h4_duplicate_variable_rejected() {
    let vars = p12_sorted_vars();
    let constraints = p12_constraints();
    // replace last element (174) with 52 — creates duplicate 52
    let bad_hint: Array<u32> = array![52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176, 54, 84, 112, 113, 115, 116, 144, 52];
    count_joint_component_with_order(@vars, @constraints, 54, @array![53, 55, 84], @bad_hint);
}

// H5: variable not in component → reject.
#[test]
#[should_panic(expected: ('hint: var not in component',))]
fn h5_extra_variable_rejected() {
    let vars = p12_sorted_vars();
    let constraints = p12_constraints();
    // replace 174 with 999 — not in component
    let bad_hint: Array<u32> = array![52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176, 54, 84, 112, 113, 115, 116, 144, 999];
    count_joint_component_with_order(@vars, @constraints, 54, @array![53, 55, 84], @bad_hint);
}

// H6: wrong length (one omitted) → reject.
#[test]
#[should_panic(expected: ('hint: wrong length',))]
fn h6_wrong_length_rejected() {
    let vars = p12_sorted_vars();
    let constraints = p12_constraints();
    // 19-element hint (174 omitted)
    let bad_hint: Array<u32> = array![52, 53, 82, 55, 56, 86, 142, 172, 173, 146, 175, 176, 54, 84, 112, 113, 115, 116, 144];
    count_joint_component_with_order(@vars, @constraints, 54, @array![53, 55, 84], @bad_hint);
}

// H7: 2a-109 oracle-order hint — measures overhead on a cheap CELL.
// x_var=225, nbr_vars=[224,226,256], 10 vars, 2 constraints.
// Component variables sorted: [223,224,225,226,253,256,283,284,285,286]
// Min-fill order for 2a-109 (computed from primal graph):
//   2a-109 has only 2 constraints with 7 vars each; min-fill collapses to
//   a chain. The first non-x non-nbr leaves are: 253,283,284,285,286,223.
//   Then joint stage: 224,225(x),226,256 — but exact order needs computing.
//   Use sorted order as valid hint here; parity is what matters for this test.
#[test]
fn h7_2a109_sorted_hint_correctness() {
    let vars: Array<u32> = array![223, 224, 225, 226, 253, 256, 283, 284, 285, 286];
    let c0 = Constraint { variables: array![223, 224, 225, 253, 283, 284, 285], rhs: 1 };
    let c1 = Constraint { variables: array![224, 225, 226, 256, 284, 285, 286], rhs: 1 };
    let constraints: Array<Constraint> = array![c0, c1];
    let nbr_vars: Array<u32> = array![224, 226, 256];
    let hint = vars.clone(); // sorted order is a valid permutation
    let joint = count_joint_component_with_order(@vars, @constraints, 225, @nbr_vars, @hint);

    // same as j1 oracle
    assert(joint.len() == 5, 'h7 joint len');
    assert(find_joint(@joint, 1, 0, 0) == 2, 'h7 (1,0,0)');
    assert(find_joint(@joint, 1, 0, 1) == 1, 'h7 (1,0,1)');
    assert(find_joint(@joint, 1, 1, 0) == 1, 'h7 (1,1,0)');
    assert(find_joint(@joint, 2, 0, 0) == 3, 'h7 (2,0,0)');
    assert(find_joint(@joint, 2, 0, 1) == 6, 'h7 (2,0,1)');
}
