/// 2G accumulator shootout — Alt A: Felt252Dict<u128> accumulator.
///
/// Replaces the O(n²) linear-scan/array-rebuild in `accumulate` with
/// Felt252Dict O(1)-amortized get/insert. Key is packed as:
///   key = mask + 128 * (mines + 31 * (x_mine + 2 * nbrs))
/// covering the full corpus range: mask≤127, mines≤30, x_mine≤1, nbrs≤4.
///
/// Tradeoff vs baseline:
///   + No O(n) array copy per insertion
///   - Squash cost at drop (O(k log k) where k = total dict accesses)
///   - Must carry separate key_list (Array<felt252>) for iteration
///   - count is u128 (sufficient for chain fixtures, not for 471-bit corpus)
///
/// The output Factor type is identical to baseline — external callers see no difference.

use zkmine_2g::ve::{Factor, FactorEntry, Constraint, NO_X_VAR,
    constraint_factor,
    pow2_u32, expand_mask, project_mask,
    merge_sorted_u32, expand_positions, overlap_positions,
    u32_in_array,
    array_remove_at, scope_pos, array_set_u256,
};
use core::dict::Felt252Dict;

// ─── Key packing ─────────────────────────────────────────────────────────────

/// Pack (mask, mines, x_mine, nbrs) into a single felt252.
/// Ranges: mask 0..127, mines 0..30, x_mine 0..1, nbrs 0..4.
pub fn pack_key(mask: u32, mines: u32, x_mine: u32, nbrs: u32) -> felt252 {
    let inner: u32 = mask + 128 * (mines + 31 * (x_mine + 2 * nbrs));
    inner.into()
}

// ─── Dict-based accumulator ───────────────────────────────────────────────────

/// Accumulate (mask, mines, x_mine, nbrs) → count into a Felt252Dict.
/// key_list tracks which keys are occupied (for iteration at end).
/// new_key flags: 0 = existing, 1 = new.
fn accumulate_dict(
    ref counts: Felt252Dict<u128>,
    ref key_list: Array<felt252>,
    ref is_new: Felt252Dict<bool>,
    mask: u32,
    mines: u32,
    x_mine: u32,
    nbrs: u32,
    count: u128,
) {
    let key = pack_key(mask, mines, x_mine, nbrs);
    let prev: u128 = counts.get(key);
    counts.insert(key, prev + count);
    if !is_new.get(key) {
        is_new.insert(key, true);
        key_list.append(key);
    }
}

// ─── join_factors_dict ───────────────────────────────────────────────────────

/// Same semantics as baseline join_factors, but uses Felt252Dict accumulator.
/// count is truncated to u128 (ok for small fixtures; documents the bigint limitation).
pub fn join_factors_dict(left: @Factor, right: @Factor) -> Factor {
    let merged_vars = merge_sorted_u32(left.variables, right.variables);
    let merged_len = merged_vars.len();

    let left_expand = expand_positions(left.variables, @merged_vars);
    let right_expand = expand_positions(right.variables, @merged_vars);
    let (left_ol, right_ol) = overlap_positions(left.variables, right.variables);

    let mut counts: Felt252Dict<u128> = Default::default();
    let mut key_list: Array<felt252> = array![];
    let mut is_new: Felt252Dict<bool> = Default::default();

    let mut li: usize = 0;
    loop {
        if li >= left.entries.len() {
            break;
        }
        let le = *left.entries.at(li);
        let left_key = project_mask(le.mask, @left_ol);
        let mut ri: usize = 0;
        loop {
            if ri >= right.entries.len() {
                break;
            }
            let re = *right.entries.at(ri);
            if project_mask(re.mask, @right_ol) == left_key {
                let x_sum = le.x_mine + re.x_mine;
                if x_sum <= 1 {
                    let merged_mask = expand_mask(le.mask, @left_expand)
                        | expand_mask(re.mask, @right_expand);
                    // Truncate to u128 for dict storage
                    let lc: u128 = le.count.low;
                    let rc: u128 = re.count.low;
                    let product: u128 = lc * rc;
                    accumulate_dict(
                        ref counts,
                        ref key_list,
                        ref is_new,
                        merged_mask,
                        le.mines + re.mines,
                        x_sum,
                        le.nbrs + re.nbrs,
                        product,
                    );
                }
            }
            ri += 1;
        };
        li += 1;
    };

    // Build output entries from key_list
    let mut out_entries: Array<FactorEntry> = array![];
    let mut ki: usize = 0;
    loop {
        if ki >= key_list.len() {
            break;
        }
        let key = *key_list.at(ki);
        let c: u128 = counts.get(key);
        // Unpack key
        let key_u32: u32 = key.try_into().unwrap();
        let mask: u32 = key_u32 % 128;
        let rest: u32 = key_u32 / 128;
        let mines: u32 = rest % 31;
        let rest2: u32 = rest / 31;
        let x_mine: u32 = rest2 % 2;
        let nbrs: u32 = rest2 / 2;
        out_entries.append(FactorEntry {
            mask, mines, x_mine, nbrs, count: u256 { low: c, high: 0 }
        });
        ki += 1;
    };

    // Squash dicts (required before drop in Cairo)
    counts.squash();
    is_new.squash();

    Factor { scope_len: merged_len, variables: merged_vars, entries: out_entries }
}

// ─── eliminate_variable_dict ─────────────────────────────────────────────────

/// Same as baseline eliminate_variable but uses dict accumulator internally.
pub fn eliminate_variable_dict(
    factor: @Factor, variable: u32, x_var: u32, neighbor_vars: @Array<u32>,
) -> Factor {
    let pos = scope_pos(factor.variables, variable);
    let out_vars = array_remove_at(factor.variables, pos);
    let out_len = out_vars.len();

    let mut counts: Felt252Dict<u128> = Default::default();
    let mut key_list: Array<felt252> = array![];
    let mut is_new: Felt252Dict<bool> = Default::default();

    let mut i: usize = 0;
    loop {
        if i >= factor.entries.len() {
            break;
        }
        let e = *factor.entries.at(i);
        let bit_val: u32 = (e.mask / pow2_u32(pos)) & 1;
        let new_mask = remove_bit_ve(e.mask, pos);
        let add_x: u32 = if x_var != NO_X_VAR && variable == x_var { bit_val } else { 0 };
        let add_nbr: u32 = if x_var != NO_X_VAR && u32_in_array(neighbor_vars, variable) {
            bit_val
        } else {
            0
        };
        let c: u128 = e.count.low;
        accumulate_dict(
            ref counts,
            ref key_list,
            ref is_new,
            new_mask,
            e.mines + bit_val,
            e.x_mine + add_x,
            e.nbrs + add_nbr,
            c,
        );
        i += 1;
    };

    let mut out_entries: Array<FactorEntry> = array![];
    let mut ki: usize = 0;
    loop {
        if ki >= key_list.len() {
            break;
        }
        let key = *key_list.at(ki);
        let c: u128 = counts.get(key);
        let key_u32: u32 = key.try_into().unwrap();
        let mask: u32 = key_u32 % 128;
        let rest: u32 = key_u32 / 128;
        let mines: u32 = rest % 31;
        let rest2: u32 = rest / 31;
        let x_mine: u32 = rest2 % 2;
        let nbrs: u32 = rest2 / 2;
        out_entries.append(FactorEntry {
            mask, mines, x_mine, nbrs, count: u256 { low: c, high: 0 }
        });
        ki += 1;
    };

    counts.squash();
    is_new.squash();

    Factor { scope_len: out_len, variables: out_vars, entries: out_entries }
}

// ─── count_ordinary_component_dict ──────────────────────────────────────────

/// Same as count_ordinary_component but uses dict-based join and eliminate.
pub fn count_ordinary_component_dict(
    variables: @Array<u32>, constraints: @Array<Constraint>,
) -> Array<u256> {
    let x_var = NO_X_VAR;
    let empty_nbrs: Array<u32> = array![];

    let mut factors: Array<Factor> = array![];
    let mut ci: usize = 0;
    loop {
        if ci >= constraints.len() {
            break;
        }
        let c = constraints.at(ci);
        factors.append(constraint_factor(c.variables, *c.rhs, x_var, @empty_nbrs));
        ci += 1;
    };

    let mut vi: usize = 0;
    loop {
        if vi >= variables.len() {
            break;
        }
        let var = *variables.at(vi);

        let n = factors.len();
        let mut contains: Array<bool> = array![];
        let mut fi: usize = 0;
        loop {
            if fi >= n { break; }
            contains.append(u32_in_array(factors.at(fi).variables, var));
            fi += 1;
        };

        let mut related: Array<Factor> = array![];
        let mut remaining: Array<Factor> = array![];
        fi = 0;
        loop {
            if factors.len() == 0 { break; }
            let f = factors.pop_front().unwrap();
            if *contains.at(fi) { related.append(f); } else { remaining.append(f); }
            fi += 1;
        };

        if related.len() == 0 {
            factors = remaining;
            vi += 1;
            continue;
        }

        let mut joined = related.pop_front().unwrap();
        loop {
            if related.len() == 0 { break; }
            let next = related.pop_front().unwrap();
            joined = join_factors_dict(@joined, @next);
        };

        let reduced = eliminate_variable_dict(@joined, var, x_var, @empty_nbrs);
        remaining.append(reduced);
        factors = remaining;
        vi += 1;
    };

    let n_vars = variables.len();
    let mut result: Array<u256> = array![];
    let mut k: usize = 0;
    loop {
        if k > n_vars { break; }
        result.append(0);
        k += 1;
    };

    if factors.len() == 0 { return result; }
    let mut final_f = factors.pop_front().unwrap();
    loop {
        if factors.len() == 0 { break; }
        let next = factors.pop_front().unwrap();
        final_f = join_factors_dict(@final_f, @next);
    };

    let mut ei: usize = 0;
    loop {
        if ei >= final_f.entries.len() { break; }
        let e = *final_f.entries.at(ei);
        let idx: usize = e.mines.try_into().unwrap();
        let prev = *result.at(idx);
        result = array_set_u256(result, idx, prev + e.count);
        ei += 1;
    };
    result
}

// ─── Internal helper (avoid re-exporting from ve) ────────────────────────────

fn remove_bit_ve(mask: u32, pos: usize) -> u32 {
    let p = pow2_u32(pos);
    let lower = mask & (p - 1);
    let upper = mask / (p * 2);
    lower + upper * p
}
