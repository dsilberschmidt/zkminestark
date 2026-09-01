/// 2G Phase 7 — Full CELL evaluation in Cairo.
///
/// Computes the 10 outcome counts (mine + clues 0..8) for a single clicked cell,
/// starting from the canonical public problem structure.
///
/// Pipeline:
///   1. Joint VE on special component  → Array<JointEntry>  (via ve.cairo)
///   2. Ordinary VE on each ordinary component → Array<u256> (via ve.cairo)
///   3. Convolve ordinary into aggregate  (convolve_ordinary)
///   4. Unconstrained local factor        (apply_unconstrained_local)
///   5. Extract outcomes via binomials    (extract_outcomes)
///      — applies C(unc_other, remaining_mines − mines) for each aggregate entry
///      — filters by global mine constraint
///      — classifies into mine / clue-0..8 buckets
///
/// Count sizes: ae.count (u256) after steps 1-4 can exceed u32 for complex floods.
/// Step 5 multiplies ae.count (u256) × C(unc_other, k) (u512) via u512_mul_u256 → u512.

use zkmine_2g::ve::JointEntry;
use zkmine_2g::bigint::{binom, u512_add, u512_mul_small, u512_mul_u256, u512_zero, u512_from_u32};
use core::integer::u512;

// ─── accumulate_joint ────────────────────────────────────────────────────────

/// Add JointEntry e into result array.
/// If an entry with the same (mines, x_mine, nbrs) exists, add to its count.
/// Otherwise append.  O(n) scan — result sizes in corpus are ≤ ~100 entries.
fn accumulate_joint(result: Array<JointEntry>, e: JointEntry) -> Array<JointEntry> {
    let mut out: Array<JointEntry> = array![];
    let mut i: usize = 0;
    let mut found = false;
    loop {
        if i >= result.len() { break; }
        let ex = *result.at(i);
        if ex.mines == e.mines && ex.x_mine == e.x_mine && ex.nbrs == e.nbrs {
            out.append(JointEntry { mines: e.mines, x_mine: e.x_mine, nbrs: e.nbrs, count: ex.count + e.count });
            found = true;
        } else {
            out.append(ex);
        }
        i += 1;
    };
    if !found {
        out.append(e);
    }
    out
}

// ─── convolve_joint ──────────────────────────────────────────────────────────

/// Convolve two joint aggregates (for steps with multiple special components).
/// For each pair (ae1, ae2): new entry (mines1+mines2, x_mine1+x_mine2, nbrs1+nbrs2, count1×count2).
/// Since x_var appears in at most one component, x_mine1+x_mine2 ≤ 1 in practice.
pub fn convolve_joint(agg1: @Array<JointEntry>, agg2: @Array<JointEntry>) -> Array<JointEntry> {
    let mut out: Array<JointEntry> = array![];
    let mut i: usize = 0;
    loop {
        if i >= agg1.len() { break; }
        let ae1 = *agg1.at(i);
        let mut j: usize = 0;
        loop {
            if j >= agg2.len() { break; }
            let ae2 = *agg2.at(j);
            let new_e = JointEntry {
                mines: ae1.mines + ae2.mines,
                x_mine: ae1.x_mine + ae2.x_mine,
                nbrs: ae1.nbrs + ae2.nbrs,
                count: ae1.count * ae2.count,
            };
            out = accumulate_joint(out, new_e);
            j += 1;
        };
        i += 1;
    };
    out
}

// ─── convolve_ordinary ───────────────────────────────────────────────────────

/// Convolve joint aggregate with an ordinary component's mine-count vector.
/// `ways[k]` = number of mine arrangements with exactly k mines in that component.
/// For each aggregate entry (am, ax, an, aw) and each k where ways[k] != 0:
///   new entry (am+k, ax, an, aw * ways[k]).
/// Then accumulate to merge entries with same key.
pub fn convolve_ordinary(aggregate: @Array<JointEntry>, ways: @Array<u256>) -> Array<JointEntry> {
    let mut out: Array<JointEntry> = array![];
    let mut ai: usize = 0;
    loop {
        if ai >= aggregate.len() { break; }
        let ae = *aggregate.at(ai);
        let mut ki: usize = 0;
        loop {
            if ki >= ways.len() { break; }
            let w = *ways.at(ki);
            if w != 0 {
                let new_e = JointEntry {
                    mines: ae.mines + ki.try_into().unwrap(),
                    x_mine: ae.x_mine,
                    nbrs: ae.nbrs,
                    count: ae.count * w,
                };
                out = accumulate_joint(out, new_e);
            }
            ki += 1;
        };
        ai += 1;
    };
    out
}

// ─── apply_unconstrained_local ───────────────────────────────────────────────

/// Apply the unconstrained local factor to the aggregate.
///
/// unconstrained_local cells are hidden cells adjacent to (or equal to) the
/// clicked cell that don't appear in any constraint.
///
/// If x_is_unconstrained (clicked cell itself is unconstrained):
///   For each existing aggregate entry (am, ax, an, aw):
///     For x_mine_delta in {0, 1} (only valid if ax + x_mine_delta ≤ 1):
///       For j in 0..=unconstrained_neighbor_count:
///         binom_j = C(unconstrained_neighbor_count, j)
///         mines_delta = x_mine_delta + j
///         new entry (am + mines_delta, ax + x_mine_delta, an + j, aw * binom_j)
///
/// If x is NOT unconstrained:
///   For each aggregate entry (am, ax, an, aw):
///     For j in 0..=unconstrained_neighbor_count:
///       binom_j = C(unconstrained_neighbor_count, j)
///       new entry (am + j, ax, an + j, aw * binom_j)
pub fn apply_unconstrained_local(
    aggregate: @Array<JointEntry>,
    x_is_unconstrained: bool,
    unconstrained_neighbor_count: u32,
) -> Array<JointEntry> {
    let mut out: Array<JointEntry> = array![];
    let mut ai: usize = 0;
    loop {
        if ai >= aggregate.len() { break; }
        let ae = *aggregate.at(ai);

        if x_is_unconstrained {
            let mut xmd: u32 = 0;
            loop {
                if xmd > 1 { break; }
                if ae.x_mine + xmd <= 1 {
                    let mut j: u32 = 0;
                    loop {
                        if j > unconstrained_neighbor_count { break; }
                        // C(unconstrained_neighbor_count, j) as u32 — fits since n≤5
                        let b_j = small_binom(unconstrained_neighbor_count, j);
                        let new_e = JointEntry {
                            mines: ae.mines + xmd + j,
                            x_mine: ae.x_mine + xmd,
                            nbrs: ae.nbrs + j,
                            count: ae.count * b_j.into(),
                        };
                        out = accumulate_joint(out, new_e);
                        j += 1;
                    };
                }
                xmd += 1;
            };
        } else {
            let mut j: u32 = 0;
            loop {
                if j > unconstrained_neighbor_count { break; }
                let b_j = small_binom(unconstrained_neighbor_count, j);
                let new_e = JointEntry {
                    mines: ae.mines + j,
                    x_mine: ae.x_mine,
                    nbrs: ae.nbrs + j,
                    count: ae.count * b_j.into(),
                };
                out = accumulate_joint(out, new_e);
                j += 1;
            };
        }
        ai += 1;
    };
    out
}

// ─── small_binom ─────────────────────────────────────────────────────────────

/// C(n, k) as u32 for small n (≤ 8 in corpus — unconstrained local neighbors ≤ 5).
/// Used only for the unconstrained_local factor.
fn small_binom(n: u32, k: u32) -> u32 {
    if k == 0 || k == n { return 1; }
    if k > n { return 0; }
    // Pascal's triangle for n ≤ 8 — always fits u32
    let mut result: u32 = 1;
    let mut i: u32 = 0;
    loop {
        if i >= k { break; }
        result = result * (n - i) / (i + 1);
        i += 1;
    };
    result
}

// ─── extract_outcomes ────────────────────────────────────────────────────────

/// Compute the 10 outcome counts from the pre-binom aggregate.
///
/// For each aggregate entry (am, ax, an, aw) where am ≤ remaining_mines and
/// (remaining_mines − am) ≤ unconstrained_other_count:
///   k = remaining_mines − am
///   binom_k = C(unconstrained_other_count, k)    (u512, large)
///   contribution = binom_k × aw                  (u512 × u32 via u512_mul_small)
///   if ax == 1: outcomes[0] += contribution        (mine)
///   else: clue = adjacent_known_mines + an
///         if clue ≤ 8: outcomes[clue + 1] += contribution
///
/// Returns Array<u512> of length 10:
///   [0] = mine count
///   [1..9] = clue-0 .. clue-8 counts
pub fn extract_outcomes(
    aggregate: @Array<JointEntry>,
    remaining_mines: u32,
    unconstrained_other_count: u32,
    adjacent_known_mines: u32,
) -> Array<u512> {
    let mut outcomes: Array<u512> = array![
        u512_zero(), u512_zero(), u512_zero(), u512_zero(), u512_zero(),
        u512_zero(), u512_zero(), u512_zero(), u512_zero(), u512_zero(),
    ];
    let mut ai: usize = 0;
    loop {
        if ai >= aggregate.len() { break; }
        let ae = *aggregate.at(ai);

        if ae.mines > remaining_mines { ai += 1; continue; }
        let k = remaining_mines - ae.mines;
        if k > unconstrained_other_count { ai += 1; continue; }

        let bk = binom(unconstrained_other_count, k);
        let contrib = u512_mul_u256(bk, ae.count);

        if ae.x_mine == 1 {
            // mine outcome at index 0
            let prev = *outcomes.at(0);
            outcomes = array_set_u512(outcomes, 0, u512_add(prev, contrib));
        } else {
            let clue = adjacent_known_mines + ae.nbrs;
            if clue <= 8 {
                let idx: usize = (clue + 1).try_into().unwrap();
                let prev = *outcomes.at(idx);
                outcomes = array_set_u512(outcomes, idx, u512_add(prev, contrib));
            }
        }
        ai += 1;
    };
    outcomes
}

// ─── array_set_u512 ──────────────────────────────────────────────────────────

fn array_set_u512(mut arr: Array<u512>, idx: usize, val: u512) -> Array<u512> {
    let mut out: Array<u512> = array![];
    let mut i: usize = 0;
    loop {
        if i >= arr.len() { break; }
        if i == idx {
            out.append(val);
        } else {
            out.append(*arr.at(i));
        }
        i += 1;
    };
    out
}
