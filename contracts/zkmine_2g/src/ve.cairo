/// 2G — Cairo CELL cost translation: exact Variable Elimination primitives.
///
/// Representation:
///   Factor = sparse array of FactorEntry. Each entry has:
///     mask   : bitmask of scope variables (bit i = variable at scope position i)
///     mines  : accumulated mine-count from eliminated variables (state key dim 0)
///     x_mine : 0|1, whether query variable x was mine (state key dim 1)
///     nbrs   : accumulated neighbor mine-count (state key dim 2)
///     count  : u256 — correct for fixtures with counts < 2^256 (~300 bits margin vs 471 bit max)
///
///   Scope variables are stored as an Array<u32> of variable indices, sorted ascending.
///   Factor.scope_len == Factor.variables.len().
///
/// This implements ordinary VE (no query tracking, x_var sentinel = 0xffff).
/// Joint VE primitives (x_mine, nbrs tracking) are also wired in constraint_factor/join/elim.

pub const NO_X_VAR: u32 = 0xffff;

// ─── Entry and Factor ────────────────────────────────────────────────────────

#[derive(Drop, Copy, Clone, Serde)]
pub struct FactorEntry {
    pub mask: u32,
    pub mines: u32,
    pub x_mine: u32,
    pub nbrs: u32,
    pub count: u256,
}

#[derive(Drop, Serde)]
pub struct Factor {
    pub scope_len: u32,
    pub variables: Array<u32>,
    pub entries: Array<FactorEntry>,
}

/// Constraint: scope variables (sorted) and required mine sum.
#[derive(Drop, Clone, Serde)]
pub struct Constraint {
    pub variables: Array<u32>,
    pub rhs: u32,
}

// ─── constraint_factor ───────────────────────────────────────────────────────

/// Build the initial factor for one constraint.
/// Enumerates all masks of `variables` with popcount == rhs, each with count=1.
/// x_var == NO_X_VAR means ordinary VE (no query tracking).
pub fn constraint_factor(
    variables: @Array<u32>, rhs: u32, x_var: u32, neighbor_vars: @Array<u32>,
) -> Factor {
    let scope_len = variables.len();
    let total = pow2(scope_len);
    let mut entries: Array<FactorEntry> = array![];
    let mut mask: u32 = 0;
    loop {
        if mask >= total {
            break;
        }
        if popcount(mask) == rhs {
            // x_mine and nbrs start at 0; they are only accumulated via eliminate_variable
            // when x_var or a neighbor_var is marginalized out.
            entries.append(FactorEntry { mask, mines: 0, x_mine: 0, nbrs: 0, count: 1 });
        }
        mask += 1;
    };
    Factor { scope_len, variables: clone_u32_array(variables), entries }
}

// ─── join_factors ────────────────────────────────────────────────────────────

/// Join two factors. Resulting scope = union of scopes (sorted, deduped).
/// For each compatible entry pair (same values on overlap variables):
///   merged_count += left_count * right_count
/// x_var/neighbor_vars are needed to correctly merge x_mine and nbrs when
/// the same tracked variable is live in both scopes.
/// For ordinary VE, pass x_var = NO_X_VAR and neighbor_vars = @empty_array.
pub fn join_factors(
    left: @Factor, right: @Factor, x_var: u32, neighbor_vars: @Array<u32>,
) -> Factor {
    let merged_vars = merge_sorted_u32(left.variables, right.variables);
    let merged_len = merged_vars.len();

    let left_expand = expand_positions(left.variables, @merged_vars);
    let right_expand = expand_positions(right.variables, @merged_vars);
    let (left_ol, right_ol) = overlap_positions(left.variables, right.variables);

    let mut out_entries: Array<FactorEntry> = array![];

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
                let merged_mask = expand_mask(le.mask, @left_expand)
                    | expand_mask(re.mask, @right_expand);
                let product: u256 = le.count * re.count;
                // x_mine and nbrs are stored-only (set by eliminate_variable, never by
                // constraint_factor). Simple addition is safe: each variable is eliminated
                // at most once, so there is no double-counting across the two factor chains.
                accumulate(
                    ref out_entries,
                    merged_mask,
                    le.mines + re.mines,
                    le.x_mine + re.x_mine,
                    le.nbrs + re.nbrs,
                    product,
                );
            }
            ri += 1;
        };
        li += 1;
    };

    Factor { scope_len: merged_len, variables: merged_vars, entries: out_entries }
}

// ─── eliminate_variable ──────────────────────────────────────────────────────

/// Marginalize `variable` out of `factor`.
/// Bit value (0 or 1) is added to mines; additionally to x_mine / nbrs if applicable.
pub fn eliminate_variable(
    factor: @Factor, variable: u32, x_var: u32, neighbor_vars: @Array<u32>,
) -> Factor {
    let pos = scope_pos(factor.variables, variable);
    let out_vars = array_remove_at(factor.variables, pos);
    let out_len = out_vars.len();
    let mut out_entries: Array<FactorEntry> = array![];

    let mut i: usize = 0;
    loop {
        if i >= factor.entries.len() {
            break;
        }
        let e = *factor.entries.at(i);
        let bit_val: u32 = (e.mask / pow2_u32(pos)) & 1;
        let new_mask = remove_bit(e.mask, pos);
        let add_x: u32 = if x_var != NO_X_VAR && variable == x_var {
            bit_val
        } else {
            0
        };
        let add_nbr: u32 = if x_var != NO_X_VAR && u32_in_array(neighbor_vars, variable) {
            bit_val
        } else {
            0
        };
        accumulate(
            ref out_entries,
            new_mask,
            e.mines + bit_val,
            e.x_mine + add_x,
            e.nbrs + add_nbr,
            e.count,
        );
        i += 1;
    };

    Factor { scope_len: out_len, variables: out_vars, entries: out_entries }
}

// ─── JointEntry ──────────────────────────────────────────────────────────────

/// Output entry for joint VE: all three state dimensions.
/// After all variables are eliminated, mask=0 and (mines, x_mine, nbrs)
/// is the complete state key.
#[derive(Drop, Copy, Clone)]
pub struct JointEntry {
    pub mines: u32,
    pub x_mine: u32,
    pub nbrs: u32,
    pub count: u256,
}

#[derive(Drop, Copy, Clone)]
pub struct FactorProfile {
    pub scope_len: u32,
    pub dense_capacity: u32,
    pub entry_count: u32,
    pub nonzero_entry_count: u32,
}

#[derive(Drop, Copy, Clone)]
pub struct AccumulateProfile {
    pub calls: u32,
    pub scanned_entries: u32,
    pub copied_entries: u32,
    pub count_additions: u32,
}

#[derive(Drop, Copy, Clone)]
pub struct JoinProfile {
    pub left_scope_len: u32,
    pub right_scope_len: u32,
    pub left_dense_capacity: u32,
    pub right_dense_capacity: u32,
    pub left_entry_count: u32,
    pub right_entry_count: u32,
    pub left_nonzero_entry_count: u32,
    pub right_nonzero_entry_count: u32,
    pub overlap_len: u32,
    pub merged_scope_len: u32,
    pub merged_dense_capacity: u32,
    pub output_entry_count: u32,
    pub output_nonzero_entry_count: u32,
    pub candidate_pair_comparisons: u32,
    pub compatible_pair_matches: u32,
    pub accumulate_calls: u32,
    pub accumulate_scanned_entries: u32,
    pub accumulate_copied_entries: u32,
    pub bigint_multiplications: u32,
    pub bigint_additions: u32,
}

#[derive(Drop, Copy, Clone)]
pub struct EliminationProfile {
    pub variable: u32,
    pub input_scope_len: u32,
    pub input_dense_capacity: u32,
    pub input_entry_count: u32,
    pub input_nonzero_entry_count: u32,
    pub output_scope_len: u32,
    pub output_dense_capacity: u32,
    pub output_entry_count: u32,
    pub output_nonzero_entry_count: u32,
    pub eliminated_entries_with_bit_set: u32,
    pub accumulate_calls: u32,
    pub accumulate_scanned_entries: u32,
    pub accumulate_copied_entries: u32,
    pub bigint_additions: u32,
}

#[derive(Drop, Copy, Clone)]
pub struct VeStepProfile {
    pub variable: u32,
    pub related_factor_count: u32,
    pub related_entry_count_total: u32,
    pub related_nonzero_entry_count_total: u32,
    pub related_dense_capacity_total: u32,
    pub join_ops: u32,
    pub joined_scope_len: u32,
    pub joined_dense_capacity: u32,
    pub joined_entry_count: u32,
    pub joined_nonzero_entry_count: u32,
    pub candidate_pair_comparisons: u32,
    pub compatible_pair_matches: u32,
    pub join_accumulate_calls: u32,
    pub join_accumulate_scanned_entries: u32,
    pub join_accumulate_copied_entries: u32,
    pub join_bigint_multiplications: u32,
    pub join_bigint_additions: u32,
    pub elimination_output_scope_len: u32,
    pub elimination_output_dense_capacity: u32,
    pub elimination_output_entry_count: u32,
    pub elimination_output_nonzero_entry_count: u32,
    pub eliminated_entries_with_bit_set: u32,
    pub elimination_accumulate_calls: u32,
    pub elimination_accumulate_scanned_entries: u32,
    pub elimination_accumulate_copied_entries: u32,
    pub elimination_bigint_additions: u32,
    pub factor_count_after_step: u32,
}

#[derive(Drop)]
pub struct JointProfileResult {
    pub constraint_factors: Array<FactorProfile>,
    pub steps: Array<VeStepProfile>,
    pub joint: Array<JointEntry>,
}

// ─── count_joint_component ───────────────────────────────────────────────────

/// Run joint VE on the special component containing x_var.
/// Tracks x_mine (was x_var a mine?) and nbrs (how many neighbor_vars were mines).
/// Returns the joint_counts: all (mines, x_mine, nbrs) → count entries.
pub fn count_joint_component(
    variables: @Array<u32>,
    constraints: @Array<Constraint>,
    x_var: u32,
    neighbor_vars: @Array<u32>,
) -> Array<JointEntry> {
    let mut factors: Array<Factor> = array![];
    let mut ci: usize = 0;
    loop {
        if ci >= constraints.len() {
            break;
        }
        let c = constraints.at(ci);
        factors.append(constraint_factor(c.variables, *c.rhs, x_var, neighbor_vars));
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
            joined = join_factors(@joined, @next, x_var, neighbor_vars);
        };
        let reduced = eliminate_variable(@joined, var, x_var, neighbor_vars);
        remaining.append(reduced);
        factors = remaining;
        vi += 1;
    };

    if factors.len() == 0 {
        return array![];
    }
    let mut final_f = factors.pop_front().unwrap();
    loop {
        if factors.len() == 0 { break; }
        let next = factors.pop_front().unwrap();
        final_f = join_factors(@final_f, @next, x_var, neighbor_vars);
    };

    let mut out: Array<JointEntry> = array![];
    let mut ei: usize = 0;
    loop {
        if ei >= final_f.entries.len() { break; }
        let e = *final_f.entries.at(ei);
        if e.count != 0 {
            out.append(JointEntry { mines: e.mines, x_mine: e.x_mine, nbrs: e.nbrs, count: e.count });
        }
        ei += 1;
    };
    out
}

// ─── verified elimination-order hint ─────────────────────────────────────────

/// Verify that `hint` is exactly a permutation of `vars`:
///   - same length
///   - every element of `hint` is in `vars`        (no extra vars)
///   - no element of `hint` is duplicated           (no omissions follow from len equality)
///
/// Panics with a descriptive message if any check fails.
/// O(n²) — acceptable for component sizes ≤ ~20 variables.
fn verify_permutation(vars: @Array<u32>, hint: @Array<u32>) {
    let n = vars.len();
    assert(hint.len() == n, 'hint: wrong length');

    let mut hi: usize = 0;
    loop {
        if hi >= n { break; }
        let v = *hint.at(hi);
        // check v ∈ vars
        assert(u32_in_array(vars, v), 'hint: var not in component');
        // check v not duplicated in hint[0..hi)
        let mut prev: usize = 0;
        loop {
            if prev >= hi { break; }
            assert(*hint.at(prev) != v, 'hint: duplicate variable');
            prev += 1;
        };
        hi += 1;
    };
}

/// Run joint VE using a caller-supplied elimination order.
/// The hint is verified on-chain to be an exact permutation of `variables`
/// before any computation begins.  A malformed hint panics; a valid but
/// suboptimal hint only increases gas — it cannot alter the joint counts.
pub fn count_joint_component_with_order(
    variables: @Array<u32>,
    constraints: @Array<Constraint>,
    x_var: u32,
    neighbor_vars: @Array<u32>,
    hint_order: @Array<u32>,
) -> Array<JointEntry> {
    verify_permutation(variables, hint_order);

    let mut factors: Array<Factor> = array![];
    let mut ci: usize = 0;
    loop {
        if ci >= constraints.len() { break; }
        let c = constraints.at(ci);
        factors.append(constraint_factor(c.variables, *c.rhs, x_var, neighbor_vars));
        ci += 1;
    };

    let mut vi: usize = 0;
    loop {
        if vi >= hint_order.len() { break; }
        let var = *hint_order.at(vi);
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
            joined = join_factors(@joined, @next, x_var, neighbor_vars);
        };
        let reduced = eliminate_variable(@joined, var, x_var, neighbor_vars);
        remaining.append(reduced);
        factors = remaining;
        vi += 1;
    };

    if factors.len() == 0 {
        return array![];
    }
    let mut final_f = factors.pop_front().unwrap();
    loop {
        if factors.len() == 0 { break; }
        let next = factors.pop_front().unwrap();
        final_f = join_factors(@final_f, @next, x_var, neighbor_vars);
    };

    let mut out: Array<JointEntry> = array![];
    let mut ei: usize = 0;
    loop {
        if ei >= final_f.entries.len() { break; }
        let e = *final_f.entries.at(ei);
        if e.count != 0 {
            out.append(JointEntry { mines: e.mines, x_mine: e.x_mine, nbrs: e.nbrs, count: e.count });
        }
        ei += 1;
    };
    out
}

pub fn constraint_factor_with_profile(
    variables: @Array<u32>, rhs: u32, x_var: u32, neighbor_vars: @Array<u32>,
) -> (Factor, FactorProfile) {
    let factor = constraint_factor(variables, rhs, x_var, neighbor_vars);
    let profile = factor_profile(@factor);
    (factor, profile)
}

pub fn join_factors_profile(
    left: @Factor, right: @Factor, x_var: u32, neighbor_vars: @Array<u32>,
) -> (Factor, JoinProfile) {
    let left_profile = factor_profile(left);
    let right_profile = factor_profile(right);
    let merged_vars = merge_sorted_u32(left.variables, right.variables);
    let merged_len = merged_vars.len();

    let left_expand = expand_positions(left.variables, @merged_vars);
    let right_expand = expand_positions(right.variables, @merged_vars);
    let (left_ol, right_ol) = overlap_positions(left.variables, right.variables);

    let mut out_entries: Array<FactorEntry> = array![];
    let mut pair_comp: u32 = 0;
    let mut matches: u32 = 0;
    let mut bigint_muls: u32 = 0;
    let mut acc = zero_accumulate_profile();

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
            pair_comp += 1;
            let re = *right.entries.at(ri);
            if project_mask(re.mask, @right_ol) == left_key {
                matches += 1;
                bigint_muls += 1;
                let merged_mask = expand_mask(le.mask, @left_expand)
                    | expand_mask(re.mask, @right_expand);
                let product: u256 = le.count * re.count;
                accumulate_profile(
                    ref out_entries,
                    merged_mask,
                    le.mines + re.mines,
                    le.x_mine + re.x_mine,
                    le.nbrs + re.nbrs,
                    product,
                    ref acc,
                );
            }
            ri += 1;
        };
        li += 1;
    };

    let factor = Factor { scope_len: merged_len, variables: merged_vars, entries: out_entries };
    let out_profile = factor_profile(@factor);
    let profile = JoinProfile {
        left_scope_len: left_profile.scope_len,
        right_scope_len: right_profile.scope_len,
        left_dense_capacity: left_profile.dense_capacity,
        right_dense_capacity: right_profile.dense_capacity,
        left_entry_count: left_profile.entry_count,
        right_entry_count: right_profile.entry_count,
        left_nonzero_entry_count: left_profile.nonzero_entry_count,
        right_nonzero_entry_count: right_profile.nonzero_entry_count,
        overlap_len: left_ol.len().try_into().unwrap(),
        merged_scope_len: out_profile.scope_len,
        merged_dense_capacity: out_profile.dense_capacity,
        output_entry_count: out_profile.entry_count,
        output_nonzero_entry_count: out_profile.nonzero_entry_count,
        candidate_pair_comparisons: pair_comp,
        compatible_pair_matches: matches,
        accumulate_calls: acc.calls,
        accumulate_scanned_entries: acc.scanned_entries,
        accumulate_copied_entries: acc.copied_entries,
        bigint_multiplications: bigint_muls,
        bigint_additions: acc.count_additions,
    };
    (factor, profile)
}

pub fn eliminate_variable_profile(
    factor: @Factor, variable: u32, x_var: u32, neighbor_vars: @Array<u32>,
) -> (Factor, EliminationProfile) {
    let input_profile = factor_profile(factor);
    let pos = scope_pos(factor.variables, variable);
    let out_vars = array_remove_at(factor.variables, pos);
    let out_len = out_vars.len();
    let mut out_entries: Array<FactorEntry> = array![];
    let mut bit_set_count: u32 = 0;
    let mut acc = zero_accumulate_profile();

    let mut i: usize = 0;
    loop {
        if i >= factor.entries.len() {
            break;
        }
        let e = *factor.entries.at(i);
        let bit_val: u32 = (e.mask / pow2_u32(pos)) & 1;
        if bit_val == 1 {
            bit_set_count += 1;
        }
        let new_mask = remove_bit(e.mask, pos);
        let add_x: u32 = if x_var != NO_X_VAR && variable == x_var {
            bit_val
        } else {
            0
        };
        let add_nbr: u32 = if x_var != NO_X_VAR && u32_in_array(neighbor_vars, variable) {
            bit_val
        } else {
            0
        };
        accumulate_profile(
            ref out_entries,
            new_mask,
            e.mines + bit_val,
            e.x_mine + add_x,
            e.nbrs + add_nbr,
            e.count,
            ref acc,
        );
        i += 1;
    };

    let out_factor = Factor { scope_len: out_len, variables: out_vars, entries: out_entries };
    let out_profile = factor_profile(@out_factor);
    let profile = EliminationProfile {
        variable,
        input_scope_len: input_profile.scope_len,
        input_dense_capacity: input_profile.dense_capacity,
        input_entry_count: input_profile.entry_count,
        input_nonzero_entry_count: input_profile.nonzero_entry_count,
        output_scope_len: out_profile.scope_len,
        output_dense_capacity: out_profile.dense_capacity,
        output_entry_count: out_profile.entry_count,
        output_nonzero_entry_count: out_profile.nonzero_entry_count,
        eliminated_entries_with_bit_set: bit_set_count,
        accumulate_calls: acc.calls,
        accumulate_scanned_entries: acc.scanned_entries,
        accumulate_copied_entries: acc.copied_entries,
        bigint_additions: acc.count_additions,
    };
    (out_factor, profile)
}

pub fn count_joint_component_profile(
    variables: @Array<u32>,
    constraints: @Array<Constraint>,
    x_var: u32,
    neighbor_vars: @Array<u32>,
) -> JointProfileResult {
    let mut factors: Array<Factor> = array![];
    let mut constraint_factors: Array<FactorProfile> = array![];
    let mut ci: usize = 0;
    loop {
        if ci >= constraints.len() {
            break;
        }
        let c = constraints.at(ci);
        let (factor, profile) = constraint_factor_with_profile(c.variables, *c.rhs, x_var, neighbor_vars);
        factors.append(factor);
        constraint_factors.append(profile);
        ci += 1;
    };

    let mut steps: Array<VeStepProfile> = array![];
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

        let mut related_entry_total: u32 = 0;
        let mut related_nonzero_total: u32 = 0;
        let mut related_dense_total: u32 = 0;
        fi = 0;
        loop {
            if fi >= related.len() {
                break;
            }
            let rp = factor_profile(related.at(fi));
            related_entry_total += rp.entry_count;
            related_nonzero_total += rp.nonzero_entry_count;
            related_dense_total += rp.dense_capacity;
            fi += 1;
        };

        let mut join_ops: u32 = 0;
        let mut joined = related.pop_front().unwrap();
        let mut pair_comp: u32 = 0;
        let mut matches: u32 = 0;
        let mut join_acc_calls: u32 = 0;
        let mut join_acc_scans: u32 = 0;
        let mut join_acc_copies: u32 = 0;
        let mut join_bigint_muls: u32 = 0;
        let mut join_bigint_adds: u32 = 0;
        loop {
            if related.len() == 0 { break; }
            let next = related.pop_front().unwrap();
            let (next_joined, join_profile) = join_factors_profile(@joined, @next, x_var, neighbor_vars);
            joined = next_joined;
            join_ops += 1;
            pair_comp += join_profile.candidate_pair_comparisons;
            matches += join_profile.compatible_pair_matches;
            join_acc_calls += join_profile.accumulate_calls;
            join_acc_scans += join_profile.accumulate_scanned_entries;
            join_acc_copies += join_profile.accumulate_copied_entries;
            join_bigint_muls += join_profile.bigint_multiplications;
            join_bigint_adds += join_profile.bigint_additions;
        };

        let joined_profile = factor_profile(@joined);
        let (reduced, elim_profile) = eliminate_variable_profile(@joined, var, x_var, neighbor_vars);
        remaining.append(reduced);
        factors = remaining;
        steps.append(VeStepProfile {
            variable: var,
            related_factor_count: (join_ops + 1),
            related_entry_count_total: related_entry_total,
            related_nonzero_entry_count_total: related_nonzero_total,
            related_dense_capacity_total: related_dense_total,
            join_ops,
            joined_scope_len: joined_profile.scope_len,
            joined_dense_capacity: joined_profile.dense_capacity,
            joined_entry_count: joined_profile.entry_count,
            joined_nonzero_entry_count: joined_profile.nonzero_entry_count,
            candidate_pair_comparisons: pair_comp,
            compatible_pair_matches: matches,
            join_accumulate_calls: join_acc_calls,
            join_accumulate_scanned_entries: join_acc_scans,
            join_accumulate_copied_entries: join_acc_copies,
            join_bigint_multiplications: join_bigint_muls,
            join_bigint_additions: join_bigint_adds,
            elimination_output_scope_len: elim_profile.output_scope_len,
            elimination_output_dense_capacity: elim_profile.output_dense_capacity,
            elimination_output_entry_count: elim_profile.output_entry_count,
            elimination_output_nonzero_entry_count: elim_profile.output_nonzero_entry_count,
            eliminated_entries_with_bit_set: elim_profile.eliminated_entries_with_bit_set,
            elimination_accumulate_calls: elim_profile.accumulate_calls,
            elimination_accumulate_scanned_entries: elim_profile.accumulate_scanned_entries,
            elimination_accumulate_copied_entries: elim_profile.accumulate_copied_entries,
            elimination_bigint_additions: elim_profile.bigint_additions,
            factor_count_after_step: factors.len().try_into().unwrap(),
        });
        vi += 1;
    };

    if factors.len() == 0 {
        return JointProfileResult { constraint_factors, steps, joint: array![] };
    }
    let mut final_f = factors.pop_front().unwrap();
    loop {
        if factors.len() == 0 { break; }
        let next = factors.pop_front().unwrap();
        final_f = join_factors(@final_f, @next, x_var, neighbor_vars);
    };

    let mut out: Array<JointEntry> = array![];
    let mut ei: usize = 0;
    loop {
        if ei >= final_f.entries.len() { break; }
        let e = *final_f.entries.at(ei);
        if e.count != 0 {
            out.append(JointEntry { mines: e.mines, x_mine: e.x_mine, nbrs: e.nbrs, count: e.count });
        }
        ei += 1;
    };
    JointProfileResult { constraint_factors, steps, joint: out }
}

// ─── count_ordinary_component ────────────────────────────────────────────────

/// Run ordinary VE on a component.
/// Elimination order = variable order as given (no heuristic).
/// Returns solution[k] = number of valid assignments with exactly k mines,
/// for k = 0 .. variables.len().
pub fn count_ordinary_component(
    variables: @Array<u32>, constraints: @Array<Constraint>,
) -> Array<u256> {
    let x_var = NO_X_VAR;
    let empty_nbrs: Array<u32> = array![];

    // Build initial factors
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

    // Eliminate each variable in given order
    let mut vi: usize = 0;
    loop {
        if vi >= variables.len() {
            break;
        }
        let var = *variables.at(vi);

        // Determine which factors contain this variable
        let n = factors.len();
        let mut contains: Array<bool> = array![];
        let mut fi: usize = 0;
        loop {
            if fi >= n {
                break;
            }
            contains.append(u32_in_array(factors.at(fi).variables, var));
            fi += 1;
        };

        // Drain factors into related/remaining
        let mut related: Array<Factor> = array![];
        let mut remaining: Array<Factor> = array![];
        fi = 0;
        loop {
            if factors.len() == 0 {
                break;
            }
            let f = factors.pop_front().unwrap();
            if *contains.at(fi) {
                related.append(f);
            } else {
                remaining.append(f);
            }
            fi += 1;
        };

        if related.len() == 0 {
            factors = remaining;
            vi += 1;
            continue;
        }

        // Join all related factors
        let mut joined = related.pop_front().unwrap();
        loop {
            if related.len() == 0 {
                break;
            }
            let next = related.pop_front().unwrap();
            joined = join_factors(@joined, @next, x_var, @empty_nbrs);
        };

        // Eliminate the variable
        let reduced = eliminate_variable(@joined, var, x_var, @empty_nbrs);
        remaining.append(reduced);
        factors = remaining;
        vi += 1;
    };

    // Build result vector of length (n_vars + 1)
    let n_vars = variables.len();
    let mut result: Array<u256> = array![];
    let mut k: usize = 0;
    loop {
        if k > n_vars {
            break;
        }
        result.append(0);
        k += 1;
    };

    // Join any remaining factors, then accumulate into result
    if factors.len() == 0 {
        return result;
    }
    let mut final_f = factors.pop_front().unwrap();
    loop {
        if factors.len() == 0 {
            break;
        }
        let next = factors.pop_front().unwrap();
        final_f = join_factors(@final_f, @next, x_var, @empty_nbrs);
    };

    let mut ei: usize = 0;
    loop {
        if ei >= final_f.entries.len() {
            break;
        }
        let e = *final_f.entries.at(ei);
        let idx: usize = e.mines.try_into().unwrap();
        let prev = *result.at(idx);
        result = array_set_u256(result, idx, prev + e.count);
        ei += 1;
    };
    result
}

// ─── Continuation: intra-component split ─────────────────────────────────────

/// Run ordinary VE on variables[0..end_idx), returning the intermediate factor set.
/// The returned Array<Factor> is the complete checkpoint needed to resume.
/// Invariant: process variables in order; end_idx ≤ variables.len().
pub fn count_ordinary_component_start(
    variables: @Array<u32>,
    constraints: @Array<Constraint>,
    end_idx: usize,
) -> Array<Factor> {
    let x_var = NO_X_VAR;
    let empty_nbrs: Array<u32> = array![];

    let mut factors: Array<Factor> = array![];
    let mut ci: usize = 0;
    loop {
        if ci >= constraints.len() { break; }
        let c = constraints.at(ci);
        factors.append(constraint_factor(c.variables, *c.rhs, x_var, @empty_nbrs));
        ci += 1;
    };

    let mut vi: usize = 0;
    loop {
        if vi >= end_idx { break; }
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
            joined = join_factors(@joined, @next, x_var, @empty_nbrs);
        };
        let reduced = eliminate_variable(@joined, var, x_var, @empty_nbrs);
        remaining.append(reduced);
        factors = remaining;
        vi += 1;
    };

    factors
}

/// Resume ordinary VE from a checkpoint factor set, processing variables[start_idx..len).
/// The checkpoint factors must be the exact output of count_ordinary_component_start
/// (or an equivalent computation). Returns the mine-count vector (same format as
/// count_ordinary_component).
pub fn count_ordinary_component_resume(
    variables: @Array<u32>,
    mut factors: Array<Factor>,
    start_idx: usize,
) -> Array<u256> {
    let x_var = NO_X_VAR;
    let empty_nbrs: Array<u32> = array![];

    let mut vi: usize = start_idx;
    loop {
        if vi >= variables.len() { break; }
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
            joined = join_factors(@joined, @next, x_var, @empty_nbrs);
        };
        let reduced = eliminate_variable(@joined, var, x_var, @empty_nbrs);
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
        final_f = join_factors(@final_f, @next, x_var, @empty_nbrs);
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

// ─── Internal helpers ────────────────────────────────────────────────────────

pub fn pow2(n: u32) -> u32 {
    let mut r: u32 = 1;
    let mut i: u32 = 0;
    loop {
        if i >= n {
            break;
        }
        r *= 2;
        i += 1;
    };
    r
}

pub fn pow2_u32(n: usize) -> u32 {
    let mut r: u32 = 1;
    let mut i: usize = 0;
    loop {
        if i >= n {
            break;
        }
        r *= 2;
        i += 1;
    };
    r
}

pub fn popcount(mut m: u32) -> u32 {
    let mut c: u32 = 0;
    loop {
        if m == 0 {
            break;
        }
        c += m & 1;
        m /= 2;
    };
    c
}

pub fn remove_bit(mask: u32, pos: usize) -> u32 {
    let p = pow2_u32(pos);
    let lower = mask & (p - 1);
    let upper = mask / (p * 2);
    lower + upper * p
}

pub fn expand_mask(mask: u32, positions: @Array<usize>) -> u32 {
    let mut result: u32 = 0;
    let mut src: usize = 0;
    loop {
        if src >= positions.len() {
            break;
        }
        if (mask / pow2_u32(src)) & 1 == 1 {
            result += pow2_u32(*positions.at(src));
        }
        src += 1;
    };
    result
}

pub fn project_mask(mask: u32, positions: @Array<usize>) -> u32 {
    let mut result: u32 = 0;
    let mut dst: usize = 0;
    loop {
        if dst >= positions.len() {
            break;
        }
        let src_pos = *positions.at(dst);
        if (mask / pow2_u32(src_pos)) & 1 == 1 {
            result += pow2_u32(dst);
        }
        dst += 1;
    };
    result
}

pub fn mine_bit_at_var(mask: u32, variables: @Array<u32>, x_var: u32) -> u32 {
    let mut i: usize = 0;
    let mut found: u32 = 0;
    loop {
        if i >= variables.len() {
            break;
        }
        if *variables.at(i) == x_var {
            found = (mask / pow2_u32(i)) & 1;
            break;
        }
        i += 1;
    };
    found
}

pub fn count_neighbor_mines(mask: u32, variables: @Array<u32>, neighbor_vars: @Array<u32>) -> u32 {
    let mut count: u32 = 0;
    let mut i: usize = 0;
    loop {
        if i >= variables.len() {
            break;
        }
        if (mask / pow2_u32(i)) & 1 == 1 && u32_in_array(neighbor_vars, *variables.at(i)) {
            count += 1;
        }
        i += 1;
    };
    count
}

pub fn u32_in_array(arr: @Array<u32>, val: u32) -> bool {
    let mut i: usize = 0;
    loop {
        if i >= arr.len() {
            break false;
        }
        if *arr.at(i) == val {
            break true;
        }
        i += 1;
    }
}

pub fn clone_u32_array(arr: @Array<u32>) -> Array<u32> {
    let mut result: Array<u32> = array![];
    let mut i: usize = 0;
    loop {
        if i >= arr.len() {
            break;
        }
        result.append(*arr.at(i));
        i += 1;
    };
    result
}

pub fn merge_sorted_u32(a: @Array<u32>, b: @Array<u32>) -> Array<u32> {
    let mut result: Array<u32> = array![];
    let mut ai: usize = 0;
    let mut bi: usize = 0;
    loop {
        if ai >= a.len() && bi >= b.len() {
            break;
        }
        if ai >= a.len() {
            result.append(*b.at(bi));
            bi += 1;
        } else if bi >= b.len() {
            result.append(*a.at(ai));
            ai += 1;
        } else {
            let av = *a.at(ai);
            let bv = *b.at(bi);
            if av < bv {
                result.append(av);
                ai += 1;
            } else if bv < av {
                result.append(bv);
                bi += 1;
            } else {
                result.append(av);
                ai += 1;
                bi += 1;
            }
        }
    };
    result
}

pub fn expand_positions(sub: @Array<u32>, full: @Array<u32>) -> Array<usize> {
    let mut positions: Array<usize> = array![];
    let mut fi: usize = 0;
    let mut si: usize = 0;
    loop {
        if si >= sub.len() {
            break;
        }
        loop {
            if fi >= full.len() {
                break;
            }
            if *full.at(fi) == *sub.at(si) {
                positions.append(fi);
                si += 1;
                fi += 1;
                break;
            }
            fi += 1;
        }
    };
    positions
}

pub fn overlap_positions(left: @Array<u32>, right: @Array<u32>) -> (Array<usize>, Array<usize>) {
    let mut lp: Array<usize> = array![];
    let mut rp: Array<usize> = array![];
    let mut li: usize = 0;
    loop {
        if li >= left.len() {
            break;
        }
        let lv = *left.at(li);
        let mut ri: usize = 0;
        loop {
            if ri >= right.len() {
                break;
            }
            if lv == *right.at(ri) {
                lp.append(li);
                rp.append(ri);
                break;
            }
            ri += 1;
        };
        li += 1;
    };
    (lp, rp)
}

pub fn scope_pos(vars: @Array<u32>, variable: u32) -> usize {
    let mut i: usize = 0;
    loop {
        assert(i < vars.len(), 'var not in scope');
        if *vars.at(i) == variable {
            break;
        }
        i += 1;
    };
    i
}

pub fn array_remove_at(arr: @Array<u32>, pos: usize) -> Array<u32> {
    let mut result: Array<u32> = array![];
    let mut i: usize = 0;
    loop {
        if i >= arr.len() {
            break;
        }
        if i != pos {
            result.append(*arr.at(i));
        }
        i += 1;
    };
    result
}

/// Accumulate into out_entries: find existing entry with same (mask, mines, x_mine, nbrs) and add,
/// or append a new entry.
pub fn accumulate(
    ref out_entries: Array<FactorEntry>,
    mask: u32,
    mines: u32,
    x_mine: u32,
    nbrs: u32,
    count: u256,
) {
    let n = out_entries.len();
    let mut new_entries: Array<FactorEntry> = array![];
    let mut found = false;
    let mut i: usize = 0;
    loop {
        if i >= n {
            break;
        }
        let e = *out_entries.at(i);
        if !found && e.mask == mask && e.mines == mines && e.x_mine == x_mine && e.nbrs == nbrs {
            new_entries.append(FactorEntry { mask, mines, x_mine, nbrs, count: e.count + count });
            found = true;
        } else {
            new_entries.append(e);
        }
        i += 1;
    };
    if !found {
        new_entries.append(FactorEntry { mask, mines, x_mine, nbrs, count });
    }
    out_entries = new_entries;
}

pub fn factor_profile(factor: @Factor) -> FactorProfile {
    let scope_len = *factor.scope_len;
    let entry_count: u32 = factor.entries.len().try_into().unwrap();
    let nonzero_entry_count = count_nonzero_entries(factor.entries);
    FactorProfile {
        scope_len,
        dense_capacity: pow2(scope_len),
        entry_count,
        nonzero_entry_count,
    }
}

pub fn zero_accumulate_profile() -> AccumulateProfile {
    AccumulateProfile { calls: 0, scanned_entries: 0, copied_entries: 0, count_additions: 0 }
}

pub fn count_nonzero_entries(entries: @Array<FactorEntry>) -> u32 {
    let mut total: u32 = 0;
    let mut i: usize = 0;
    loop {
        if i >= entries.len() {
            break;
        }
        if (*entries.at(i)).count != 0 {
            total += 1;
        }
        i += 1;
    };
    total
}

pub fn accumulate_profile(
    ref out_entries: Array<FactorEntry>,
    mask: u32,
    mines: u32,
    x_mine: u32,
    nbrs: u32,
    count: u256,
    ref profile: AccumulateProfile,
) {
    let n = out_entries.len();
    profile.calls += 1;
    profile.scanned_entries += n.try_into().unwrap();
    profile.copied_entries += n.try_into().unwrap();
    let mut new_entries: Array<FactorEntry> = array![];
    let mut found = false;
    let mut i: usize = 0;
    loop {
        if i >= n {
            break;
        }
        let e = *out_entries.at(i);
        if !found && e.mask == mask && e.mines == mines && e.x_mine == x_mine && e.nbrs == nbrs {
            new_entries.append(FactorEntry { mask, mines, x_mine, nbrs, count: e.count + count });
            profile.count_additions += 1;
            found = true;
        } else {
            new_entries.append(e);
        }
        i += 1;
    };
    if !found {
        new_entries.append(FactorEntry { mask, mines, x_mine, nbrs, count });
    }
    out_entries = new_entries;
}

pub fn array_set_u256(mut arr: Array<u256>, idx: usize, val: u256) -> Array<u256> {
    let mut result: Array<u256> = array![];
    let mut i: usize = 0;
    loop {
        if i >= arr.len() {
            break;
        }
        if i == idx {
            result.append(val);
        } else {
            result.append(*arr.at(i));
        }
        i += 1;
    };
    result
}
