/// 2G Phase 3 — u512 arithmetic for CELL evaluation.
///
/// Cairo 2.13.1 provides u512 { limb0..limb3: u128 } with:
///   u256_wide_mul(u256, u256) -> u512  (in core::integer)
///   u512_safe_div_rem_by_u256          (in core::integer)
/// Missing: addition and small-number multiplication/division.
///
/// This module provides those primitives plus binomial coefficient computation.
///
/// Maximum values observed in CELL evaluation for 30×16/99:
///   binom(465, k) max ≈ 2^461 (k≈232, but for k≤99: max ≈ 2^343 at k≈98)
///   intermediate products: small_count × binom ≤ 24 × 2^461 < 2^466
///   sums: ≤ 17 terms × 2^466 < 2^470
///   All fit in u512 (512 bits). No overflow for 30×16/99 CELL evaluation.
///
/// Justification that u512 ≥ 480 bits is sufficient:
///   The max count in any factor is bounded by C(N, M) where N ≤ 480 and M ≤ 99.
///   C(480, 99) ≈ 2^415 < 2^512.
///   Intermediate products count_left × count_right are at most 2^471 (empirically
///   measured in corpus 2F: max_integer_bit_length=471). u512 is sufficient.

use core::integer::{u512, u512_safe_div_rem_by_u256};
use core::num::traits::{OverflowingAdd, WideMul};

// ─── carry helper ────────────────────────────────────────────────────────────

fn u128_add_with_carry(a: u128, b: u128) -> (u128, u128) {
    let (sum, overflowed) = a.overflowing_add(b);
    if overflowed { (sum, 1) } else { (sum, 0) }
}

// ─── u512 from small types ───────────────────────────────────────────────────

pub fn u512_zero() -> u512 {
    u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }
}

pub fn u512_one() -> u512 {
    u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }
}

pub fn u512_from_u128(v: u128) -> u512 {
    u512 { limb0: v, limb1: 0, limb2: 0, limb3: 0 }
}

pub fn u512_from_u32(v: u32) -> u512 {
    u512 { limb0: v.into(), limb1: 0, limb2: 0, limb3: 0 }
}

pub fn u512_from_u256(v: u256) -> u512 {
    u512 { limb0: v.low, limb1: v.high, limb2: 0, limb3: 0 }
}

// ─── u512 addition ───────────────────────────────────────────────────────────

/// a + b. Panics on overflow beyond 512 bits.
pub fn u512_add(a: u512, b: u512) -> u512 {
    let (s0, c0) = u128_add_with_carry(a.limb0, b.limb0);

    let (s1a, c1a) = u128_add_with_carry(a.limb1, b.limb1);
    let (s1, c1b) = u128_add_with_carry(s1a, c0);
    let c1 = c1a + c1b;

    let (s2a, c2a) = u128_add_with_carry(a.limb2, b.limb2);
    let (s2, c2b) = u128_add_with_carry(s2a, c1);
    let c2 = c2a + c2b;

    let (s3, carry) = u128_add_with_carry(a.limb3 + b.limb3, c2);
    assert(carry == 0, 'u512 overflow');

    u512 { limb0: s0, limb1: s1, limb2: s2, limb3: s3 }
}

// ─── u512 × u32 multiplication ───────────────────────────────────────────────

/// a × v where v ≤ 2^32. Panics on overflow beyond 512 bits.
/// Used for binom step: v = (n - i) ≤ 465 for 30×16/99 corpus.
pub fn u512_mul_small(a: u512, v: u32) -> u512 {
    let v_u128: u128 = v.into();

    let p0: u256 = WideMul::wide_mul(a.limb0, v_u128);
    let (p0h, p0l) = (p0.high, p0.low);
    let p1: u256 = WideMul::wide_mul(a.limb1, v_u128);
    let (p1h, p1l) = (p1.high, p1.low);
    let p2: u256 = WideMul::wide_mul(a.limb2, v_u128);
    let (p2h, p2l) = (p2.high, p2.low);
    // limb3 × v: for 30×16/99 corpus, binom values have limb3=0 or very small
    let p3l: u128 = a.limb3 * v_u128;

    let s0 = p0l;

    let (s1, c1a) = u128_add_with_carry(p0h, p1l);

    let (s2a, c2a) = u128_add_with_carry(p1h, p2l);
    let (s2, c2b) = u128_add_with_carry(s2a, c1a);
    let c2 = c2a + c2b;

    let (s3, carry) = u128_add_with_carry(p2h + p3l, c2);
    assert(carry == 0, 'u512_mul_small overflow');

    u512 { limb0: s0, limb1: s1, limb2: s2, limb3: s3 }
}

// ─── u512 / u32 exact division ───────────────────────────────────────────────

/// a / v (exact). Panics if v does not divide a.
/// Uses stdlib u512_safe_div_rem_by_u256.
pub fn u512_div_small(a: u512, v: u32) -> u512 {
    let v_u256: u256 = v.into();
    let v_nz: NonZero<u256> = v_u256.try_into().unwrap();
    let (q, r) = u512_safe_div_rem_by_u256(a, v_nz);
    assert(r == 0, 'not exact division');
    q
}

// ─── u512 equality ───────────────────────────────────────────────────────────

pub fn u512_eq(a: u512, b: u512) -> bool {
    a.limb0 == b.limb0 && a.limb1 == b.limb1 && a.limb2 == b.limb2 && a.limb3 == b.limb3
}

// ─── Binomial coefficient C(n, k) → u512 ─────────────────────────────────────

/// C(n, k): computed iteratively with exact integer multiply-then-divide.
/// Invariant at step i: running_value = C(n, i).
/// Step: running_value = running_value × (n - i) / (i + 1).
/// Division is always exact because C(n, i+1) is an integer.
///
/// For 30×16/99: n ≤ 465, k ≤ 99. Max result ≈ 2^343 (k≈98). Fits in u512.
pub fn binom(n: u32, k: u32) -> u512 {
    if k == 0 {
        return u512_one();
    }
    if k > n {
        return u512_zero();
    }

    let mut result = u512_one();
    let mut i: u32 = 0;
    loop {
        if i >= k {
            break;
        }
        result = u512_mul_small(result, n - i);
        result = u512_div_small(result, i + 1);
        i += 1;
    };
    result
}

/// Compute C(n, k) for k in k_lo..=k_hi, returning an array indexed by k.
/// More efficient than calling binom k_hi times when the range is contiguous.
pub fn binom_range(n: u32, k_lo: u32, k_hi: u32) -> Array<u512> {
    let mut result: Array<u512> = array![];
    if k_lo > k_hi || k_hi > n {
        return result;
    }

    let mut cur = binom(n, k_lo);
    result.append(cur);

    let mut k = k_lo;
    loop {
        if k >= k_hi {
            break;
        }
        cur = u512_mul_small(cur, n - k);
        cur = u512_div_small(cur, k + 1);
        result.append(cur);
        k += 1;
    };
    result
}

/// Compute C(n, k) for k in k_lo..=k_hi by anchoring at k_anchor and walking
/// with exact recurrences in both directions:
///   C(n, k+1) = C(n, k) * (n-k) / (k+1)
///   C(n, k-1) = C(n, k) * k / (n-k+1)
///
/// This avoids recomputing each nearby binomial from scratch while preserving
/// exact integer arithmetic and exact-division assertions.
pub fn binom_range_from_anchor(n: u32, k_lo: u32, k_anchor: u32, k_hi: u32) -> Array<u512> {
    let mut result: Array<u512> = array![];
    if k_lo > k_hi || k_hi > n || k_anchor < k_lo || k_anchor > k_hi {
        return result;
    }

    let mut down_rev: Array<u512> = array![];
    let anchor = binom(n, k_anchor);
    let mut cur = anchor;
    let mut k = k_anchor;
    loop {
        if k <= k_lo {
            break;
        }
        cur = u512_mul_small(cur, k);
        cur = u512_div_small(cur, n - k + 1);
        down_rev.append(cur);
        k -= 1;
    };

    let mut i = down_rev.len();
    loop {
        if i == 0 {
            break;
        }
        i -= 1;
        result.append(*down_rev.at(i));
    };
    result.append(anchor);

    cur = anchor;
    k = k_anchor;
    loop {
        if k >= k_hi {
            break;
        }
        cur = u512_mul_small(cur, n - k);
        cur = u512_div_small(cur, k + 1);
        result.append(cur);
        k += 1;
    };

    result
}

/// u512 × u32 (small scalar) then add to accumulator.
/// Convenience for the convolution sum.
pub fn u512_mul_small_add(acc: u512, a: u512, v: u32) -> u512 {
    u512_add(acc, u512_mul_small(a, v))
}
