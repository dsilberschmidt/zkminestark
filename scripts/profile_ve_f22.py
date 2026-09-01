#!/usr/bin/env python3
"""
Phase A profiler: Variable Elimination step-by-step for f22 ord0 component.
Case: s00028g0f02 step=2, 10x10/16 RED (gas ~1.55B).
ord0: 27 variables, 22 constraints, max_ord_iw=7.

Tracks per-step intermediate factor sizes and entry counts to:
1. Identify where gas is concentrated.
2. Choose a natural split point for continuation.
3. Output the checkpoint factor state for use in Cairo chunk2 test.
"""
import sys
from collections import defaultdict

# ─── Data types ──────────────────────────────────────────────────────────────

def popcount(x):
    return bin(x).count('1')

def mask_bits(mask, positions):
    """Extract bits from mask at given bit positions (sorted). Returns sub-mask."""
    result = 0
    for i, p in enumerate(positions):
        if mask & (1 << p):
            result |= (1 << i)
    return result

class Factor:
    def __init__(self, variables, entries):
        # variables: sorted list of var indices
        # entries: list of [mask, mines, count] where mask bits correspond to positions in variables
        self.variables = list(variables)
        self.entries = entries  # list of [mask, mines, count]

    def scope_len(self):
        return len(self.variables)

    def entry_count(self):
        return len(self.entries)

    def nonzero_entry_count(self):
        return sum(1 for e in self.entries if e[2] != 0)

    def dense_capacity(self):
        return 1 << len(self.variables)

# ─── VE primitives ───────────────────────────────────────────────────────────

def constraint_factor(variables, rhs):
    """Build initial factor for one constraint."""
    n = len(variables)
    total = 1 << n
    entries = []
    for mask in range(total):
        if popcount(mask) == rhs:
            # mines=0 initially: mine count is accumulated only during eliminate_variable
            entries.append([mask, 0, 1])
    return Factor(variables, entries)

def merge_sorted(a, b):
    """Merge two sorted lists, dedup."""
    out, i, j = [], 0, 0
    while i < len(a) and j < len(b):
        if a[i] < b[j]: out.append(a[i]); i += 1
        elif a[i] > b[j]: out.append(b[j]); j += 1
        else: out.append(a[i]); i += 1; j += 1
    out.extend(a[i:]); out.extend(b[j:])
    return out

def expand_positions(sub_vars, merged_vars):
    """For each var in sub_vars, its position in merged_vars."""
    mv_pos = {v: i for i, v in enumerate(merged_vars)}
    return [mv_pos[v] for v in sub_vars]

def overlap_positions(left_vars, right_vars):
    """Positions of overlap variables in left and right, respectively."""
    right_set = set(right_vars)
    right_pos = {v: i for i, v in enumerate(right_vars)}
    left_ol, right_ol = [], []
    for i, v in enumerate(left_vars):
        if v in right_set:
            left_ol.append(i)
            right_ol.append(right_pos[v])
    return left_ol, right_ol

def expand_mask(mask, positions, total_len):
    """Expand local mask (positions indexed into sub-scope) to full merged scope."""
    result = 0
    for i, p in enumerate(positions):
        if mask & (1 << i):
            result |= (1 << p)
    return result

def project_mask(mask, positions):
    """Project full mask to overlap bits."""
    result = 0
    for i, p in enumerate(positions):
        if mask & (1 << p):
            result |= (1 << i)
    return result

def accumulate(entries_out, mask, mines, count):
    """Add (mask, mines, count) to entries, merging if key exists."""
    for e in entries_out:
        if e[0] == mask and e[1] == mines:
            e[2] += count
            return
    entries_out.append([mask, mines, count])

def join_factors(left, right, stats=None):
    """Join two factors. Returns joined Factor and pair_comparisons."""
    merged_vars = merge_sorted(left.variables, right.variables)
    left_expand = expand_positions(left.variables, merged_vars)
    right_expand = expand_positions(right.variables, merged_vars)
    left_ol, right_ol = overlap_positions(left.variables, right.variables)

    out_entries = []
    pair_comp = 0
    matches = 0

    for le in left.entries:
        if le[2] == 0:
            continue
        lkey = project_mask(le[0], left_ol)
        for re in right.entries:
            if re[2] == 0:
                continue
            pair_comp += 1
            rkey = project_mask(re[0], right_ol)
            if lkey == rkey:
                matches += 1
                merged_mask = expand_mask(le[0], left_expand, len(merged_vars)) | \
                              expand_mask(re[0], right_expand, len(merged_vars))
                product = le[2] * re[2]
                accumulate(out_entries, merged_mask, le[1] + re[1], product)

    if stats is not None:
        stats['join_pair_comp'] += pair_comp
        stats['join_matches'] += matches

    return Factor(merged_vars, out_entries)

def eliminate_variable(factor, var, stats=None):
    """Marginalize var out of factor."""
    pos = factor.variables.index(var)
    out_vars = [v for i, v in enumerate(factor.variables) if i != pos]
    out_entries = []

    elim_comp = 0
    for e in factor.entries:
        if e[2] == 0:
            continue
        elim_comp += 1
        bit_val = (e[0] >> pos) & 1
        # Remove bit at pos from mask
        low = e[0] & ((1 << pos) - 1)
        high = e[0] >> (pos + 1)
        new_mask = low | (high << pos)
        new_mines = e[1] + bit_val
        accumulate(out_entries, new_mask, new_mines, e[2])

    if stats is not None:
        stats['elim_entries'] += elim_comp

    return Factor(out_vars, out_entries)

# ─── Gas weight estimate ──────────────────────────────────────────────────────

def estimate_step_gas(var, factors_before, joined_factor, elim_factor, join_pair_comp, elim_entries):
    """
    Rough gas proxy. In Cairo VE:
    - Join: dominated by pair comparisons + accumulate scans
    - Eliminate: dominated by entry processing + accumulate scans

    Each accumulate scan is O(n) where n = current output size.
    Very rough proxy: join_pair_comp + elim_entries * (avg accumulate scan).
    """
    join_cost = join_pair_comp * 3  # comparison + possible multiply + accumulate scan
    elim_cost = elim_entries * len(elim_factor.entries) // max(1, elim_entries // 2)
    return join_cost + elim_cost

# ─── Main VE with profiling ───────────────────────────────────────────────────

def run_ve_with_profile(variables, constraints):
    """
    Run ordinary VE with full step-by-step profiling.
    Returns: (ways_vector, step_profiles, intermediate_factor_states)

    intermediate_factor_states[i] = factor set BEFORE processing variables[i]
    (i.e., after processing variables[0..i-1])
    """
    # Build initial constraint factors
    factors = [constraint_factor(c['scope'], c['rhs']) for c in constraints]

    step_profiles = []
    intermediate_factor_states = {}

    # Save initial state
    intermediate_factor_states[0] = [Factor(list(f.variables), [list(e) for e in f.entries]) for f in factors]

    for vi, var in enumerate(variables):
        # Save state before this step
        # (already saved for vi=0; save for all others too)
        if vi > 0:
            intermediate_factor_states[vi] = [
                Factor(list(f.variables), [list(e) for e in f.entries])
                for f in factors
            ]

        n = len(factors)
        contains = [var in f.variables for f in factors]
        related = [factors[i] for i in range(n) if contains[i]]
        remaining = [factors[i] for i in range(n) if not contains[i]]

        if not related:
            step_profiles.append({
                'vi': vi, 'var': var,
                'related_count': 0, 'joined_scope': 0, 'joined_entries': 0,
                'elim_scope': 0, 'elim_entries': 0,
                'join_pair_comp': 0, 'join_matches': 0,
                'elim_input_entries': 0,
                'skipped': True,
            })
            continue

        stats = defaultdict(int)
        joined = related[0]
        for r in related[1:]:
            joined = join_factors(joined, r, stats)

        elim = eliminate_variable(joined, var, stats)
        remaining.append(elim)
        factors = remaining

        step_profiles.append({
            'vi': vi, 'var': var,
            'related_count': len(related),
            'related_entries_total': sum(f.entry_count() for f in related),
            'joined_scope': joined.scope_len(),
            'joined_entries': joined.entry_count(),
            'joined_nonzero': joined.nonzero_entry_count(),
            'elim_scope': elim.scope_len(),
            'elim_entries': elim.entry_count(),
            'elim_nonzero': elim.nonzero_entry_count(),
            'join_pair_comp': stats['join_pair_comp'],
            'join_matches': stats['join_matches'],
            'elim_input_entries': joined.entry_count(),
            'factors_remaining': len(factors),
            'skipped': False,
        })

    # Save state after last variable (before final join)
    intermediate_factor_states[len(variables)] = [
        Factor(list(f.variables), [list(e) for e in f.entries])
        for f in factors
    ]

    # Final join and extract result
    n_vars = len(variables)
    result = [0] * (n_vars + 1)
    if not factors:
        return result, step_profiles, intermediate_factor_states

    final_f = factors[0]
    for f in factors[1:]:
        final_f = join_factors(final_f, f)

    for e in final_f.entries:
        if e[2] != 0:
            result[e[1]] += e[2]

    return result, step_profiles, intermediate_factor_states

# ─── f22 ord0 data ───────────────────────────────────────────────────────────

ORD0_VARS = [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 14, 16, 18, 19, 20, 22, 26, 27, 28, 30, 40, 50, 60, 70, 80, 81, 91]

ORD0_CONSTRAINTS = [
    {'scope': [1, 2, 3, 11, 22], 'rhs': 1},
    {'scope': [2, 3, 4, 14, 22], 'rhs': 2},
    {'scope': [4, 5, 6, 14, 16, 26], 'rhs': 3},
    {'scope': [6, 7, 8, 16, 18, 26, 27, 28], 'rhs': 5},
    {'scope': [10, 11, 20, 22, 30], 'rhs': 1},
    {'scope': [14], 'rhs': 1},
    {'scope': [14, 16, 26], 'rhs': 3},
    {'scope': [14, 22], 'rhs': 2},
    {'scope': [18, 19, 28], 'rhs': 2},
    {'scope': [20, 22, 30, 40], 'rhs': 1},
    {'scope': [22], 'rhs': 1},
    {'scope': [26], 'rhs': 1},
    {'scope': [26, 27], 'rhs': 2},
    {'scope': [26, 27, 28], 'rhs': 3},
    {'scope': [27, 28], 'rhs': 2},
    {'scope': [28], 'rhs': 1},
    {'scope': [30, 40, 50], 'rhs': 1},
    {'scope': [40, 50, 60], 'rhs': 1},
    {'scope': [50, 60, 70], 'rhs': 1},
    {'scope': [60, 70, 80, 81], 'rhs': 1},
    {'scope': [81], 'rhs': 1},
    {'scope': [81, 91], 'rhs': 2},
]

# Minor components (trivial, just for full CELL verification)
ORD1_VARS = [53]
ORD1_CONSTRAINTS = [{'scope': [53], 'rhs': 1}]

ORD2_VARS = [59, 69]
ORD2_CONSTRAINTS = [
    {'scope': [59], 'rhs': 1},
    {'scope': [59, 69], 'rhs': 2},
    {'scope': [69], 'rhs': 1},
]

ORD3_VARS = [76, 95, 96, 97]
ORD3_CONSTRAINTS = [
    {'scope': [76], 'rhs': 1},
    {'scope': [76, 95, 96], 'rhs': 2},
    {'scope': [76, 95, 96, 97], 'rhs': 3},
    {'scope': [76, 96, 97], 'rhs': 2},
    {'scope': [95], 'rhs': 1},
    {'scope': [97], 'rhs': 1},
]

def convolve_ordinary(aggregate, ways):
    """Convolve aggregate with ordinary ways vector."""
    from itertools import product as iproduct
    out = {}
    for (am, ax, an), aw in aggregate.items():
        for k, w in enumerate(ways):
            if w == 0:
                continue
            key = (am + k, ax, an)
            out[key] = out.get(key, 0) + aw * w
    return out

def extract_outcomes(aggregate, remaining_mines, unc_other, adj_known_mines):
    """Extract 10 outcomes."""
    from math import comb
    outcomes = [0] * 10
    for (am, ax, an), aw in aggregate.items():
        if am > remaining_mines:
            continue
        k = remaining_mines - am
        if k > unc_other:
            continue
        bk = comb(unc_other, k)
        contrib = bk * aw
        if ax == 1:
            outcomes[0] += contrib
        else:
            clue = adj_known_mines + an
            if clue <= 8:
                outcomes[clue + 1] += contrib
    return outcomes

def checkpoint_to_cairo(factors, split_idx):
    """Format checkpoint factors as Cairo array literals."""
    lines = []
    lines.append(f"    // Checkpoint after eliminating vars[0..{split_idx})")
    lines.append(f"    // {len(factors)} factors remaining")
    for fi, f in enumerate(factors):
        nz = [e for e in f.entries if e[2] != 0]
        lines.append(f"    // Factor {fi}: scope={f.variables}, {len(nz)} nonzero entries")
        lines.append(f"    let ckpt_f{fi}_vars: Array<u32> = array![{', '.join(str(v) for v in f.variables)}];")
        entry_strs = []
        for e in nz:
            mask, mines, count = e
            # In ordinary VE, x_mine=0, nbrs=0 always
            lo = count & ((1 << 128) - 1)
            hi = count >> 128
            entry_strs.append(
                f"FactorEntry {{ mask: {mask}, mines: {mines}, x_mine: 0, nbrs: 0, "
                f"count: u256 {{ low: {lo}_u128, high: {hi}_u128 }} }}"
            )
        lines.append(f"    let ckpt_f{fi}_entries: Array<FactorEntry> = array![{', '.join(entry_strs)}];")
        lines.append(f"    let ckpt_f{fi} = Factor {{ scope_len: {len(f.variables)}, variables: ckpt_f{fi}_vars, entries: ckpt_f{fi}_entries }};")
    lines.append(f"    let mut checkpoint_factors: Array<Factor> = array![{', '.join(f'ckpt_f{i}' for i in range(len(factors)))}];")
    return '\n'.join(lines)


def cumulative_gas_proxy(step_profiles, from_vi=0, to_vi=None):
    """Sum of pair comparisons + elim entries over steps."""
    total = 0
    for p in step_profiles:
        vi = p['vi']
        if vi < from_vi:
            continue
        if to_vi is not None and vi >= to_vi:
            break
        if p.get('skipped'):
            continue
        total += p.get('join_pair_comp', 0) + p.get('elim_input_entries', 0) * max(1, p.get('join_matches', 1))
    return total


def main():
    print("=" * 72)
    print("Phase A: VE profiler for s00028g0f02 step=2, ord0 (27 vars, 22 constr)")
    print("=" * 72)

    ways0, step_profiles, checkpoint_states = run_ve_with_profile(ORD0_VARS, ORD0_CONSTRAINTS)

    print(f"\nFinal ways[k] for ord0 (k=mines in component):")
    for k, w in enumerate(ways0):
        if w:
            print(f"  ways[{k}] = {w}")

    print(f"\nTotal ways0 sum: {sum(ways0)}")

    # Per-step profile
    print(f"\n{'vi':>3} {'var':>5} {'rel':>4} {'j_scope':>7} {'j_ent':>7} {'j_nz':>6} {'e_scope':>7} {'e_ent':>6} {'e_nz':>6} {'pair_cmp':>9} {'fct_rem':>7}")
    print("-" * 80)

    # Gas-proxy cumulative
    cumulative = 0
    per_step_proxy = []
    for p in step_profiles:
        if p.get('skipped'):
            per_step_proxy.append(0)
            print(f"{p['vi']:>3} {p['var']:>5}  (skipped — var not in any factor)")
            continue
        proxy = p.get('join_pair_comp', 0) * 2 + p.get('joined_entries', 0) * max(1, p.get('elim_input_entries', 1) // 4)
        per_step_proxy.append(proxy)
        cumulative += proxy
        print(f"{p['vi']:>3} {p['var']:>5} {p['related_count']:>4} {p['joined_scope']:>7} {p['joined_entries']:>7} {p['joined_nonzero']:>6} {p['elim_scope']:>7} {p['elim_entries']:>6} {p['elim_nonzero']:>6} {p['join_pair_comp']:>9} {p['factors_remaining']:>7}")

    # Find good split points (at "valleys" in factor complexity)
    print("\n--- Factor set state at each potential split point ---")
    total_proxy = sum(per_step_proxy)
    best_splits = []
    for vi in range(1, len(ORD0_VARS)):
        state = checkpoint_states.get(vi, [])
        total_entries = sum(f.entry_count() for f in state)
        total_nz = sum(f.nonzero_entry_count() for f in state)
        max_scope = max((f.scope_len() for f in state), default=0)
        chunk1_proxy = cumulative_gas_proxy(step_profiles, 0, vi)
        chunk2_proxy = cumulative_gas_proxy(step_profiles, vi)
        balance = abs(chunk1_proxy - chunk2_proxy)
        best_splits.append({
            'vi': vi, 'n_factors': len(state), 'total_entries': total_entries,
            'total_nz': total_nz, 'max_scope': max_scope,
            'chunk1_proxy': chunk1_proxy, 'chunk2_proxy': chunk2_proxy,
            'balance': balance,
        })

    # Print split candidates (those where both chunks have proxy > 0 and split is interesting)
    print(f"\n{'vi':>3} {'n_fct':>6} {'t_ent':>7} {'t_nz':>6} {'maxsc':>6} {'c1_prx':>10} {'c2_prx':>10} {'balance':>10}")
    print("-" * 70)
    for s in best_splits:
        if s['chunk1_proxy'] > 0 or s['chunk2_proxy'] > 0:
            print(f"{s['vi']:>3} {s['n_factors']:>6} {s['total_entries']:>7} {s['total_nz']:>6} {s['max_scope']:>6} {s['chunk1_proxy']:>10} {s['chunk2_proxy']:>10} {s['balance']:>10}")

    # Find split with best balance (but both > 0)
    candidates = [s for s in best_splits if s['chunk1_proxy'] > 0 and s['chunk2_proxy'] > 0]
    if candidates:
        best = min(candidates, key=lambda x: x['balance'])
        print(f"\n=> Best balanced split: vi={best['vi']} var={ORD0_VARS[best['vi']]} (balance={best['balance']})")
        print(f"   Chunk1 proxy: {best['chunk1_proxy']}")
        print(f"   Chunk2 proxy: {best['chunk2_proxy']}")
        print(f"   Checkpoint: {best['n_factors']} factors, {best['total_nz']} nonzero entries total, max_scope={best['max_scope']}")

    # Also find a "min-max" split: minimize the max of chunk1 and chunk2
    if candidates:
        minmax_best = min(candidates, key=lambda x: max(x['chunk1_proxy'], x['chunk2_proxy']))
        print(f"\n=> Min-max split (minimize worst chunk): vi={minmax_best['vi']} var={ORD0_VARS[minmax_best['vi']]}")
        print(f"   Max chunk proxy: {max(minmax_best['chunk1_proxy'], minmax_best['chunk2_proxy'])}")

    # Output checkpoint state for chosen split (use vi=10 as initial candidate, then best)
    # Try multiple candidate splits
    candidate_vids = [10, 14, 18]
    if candidates:
        candidate_vids.append(best['vi'])
        candidate_vids.append(minmax_best['vi'])
    candidate_vids = sorted(set(candidate_vids))

    for cand_vi in candidate_vids:
        if cand_vi not in checkpoint_states:
            continue
        state = checkpoint_states[cand_vi]
        total_nz = sum(f.nonzero_entry_count() for f in state)
        max_scope = max((f.scope_len() for f in state), default=0)
        # Estimate checkpoint size in felts (scope_vars + entries×5_felts + metadata)
        felt_count = sum(1 + f.scope_len() + 1 + f.nonzero_entry_count() * 5 for f in state)
        print(f"\n--- Checkpoint at vi={cand_vi} (before var {ORD0_VARS[cand_vi] if cand_vi < len(ORD0_VARS) else 'END'}) ---")
        print(f"  {len(state)} factors, {total_nz} nonzero entries, max_scope={max_scope}")
        print(f"  Estimated checkpoint size: ~{felt_count} felts ({felt_count * 32} bytes)")
        for fi, f in enumerate(state):
            nz = [e for e in f.entries if e[2] != 0]
            print(f"  Factor {fi}: scope={f.variables} ({f.scope_len()} vars), {len(nz)} nonzero entries")
            for e in nz[:5]:
                print(f"    (mask={e[0]:0{f.scope_len()}b}, mines={e[1]}, count={e[2]})")
            if len(nz) > 5:
                print(f"    ... ({len(nz) - 5} more entries)")

    # Full CELL verification
    print("\n--- Full CELL verification (all 4 ordinary components) ---")
    ways1, _, _ = run_ve_with_profile(ORD1_VARS, ORD1_CONSTRAINTS)
    ways2, _, _ = run_ve_with_profile(ORD2_VARS, ORD2_CONSTRAINTS)
    ways3, _, _ = run_ve_with_profile(ORD3_VARS, ORD3_CONSTRAINTS)

    print(f"ways0 (27 vars): {dict((k, v) for k, v in enumerate(ways0) if v)}")
    print(f"ways1 (1 var):   {dict((k, v) for k, v in enumerate(ways1) if v)}")
    print(f"ways2 (2 vars):  {dict((k, v) for k, v in enumerate(ways2) if v)}")
    print(f"ways3 (4 vars):  {dict((k, v) for k, v in enumerate(ways3) if v)}")

    # Start with trivial aggregate (ordinary VE, no special component)
    aggregate = {(0, 0, 0): 1}
    aggregate = convolve_ordinary(aggregate, ways0)
    aggregate = convolve_ordinary(aggregate, ways1)
    aggregate = convolve_ordinary(aggregate, ways2)
    aggregate = convolve_ordinary(aggregate, ways3)

    outcomes = extract_outcomes(aggregate, remaining_mines=16, unc_other=3, adj_known_mines=0)
    print(f"\nPython outcomes (expected vs Cairo exact):")
    labels = ['mine', 'c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8']
    for i, (lbl, val) in enumerate(zip(labels, outcomes)):
        expected_cairo = {1: 1}.get(i, 0)  # Cairo: c0=1 (index 1), rest 0
        match = "✓" if val == expected_cairo else "✗"
        if val or expected_cairo:
            print(f"  {lbl:5s}: Python={val}, Cairo={expected_cairo} {match}")

    # Output Cairo code for best split checkpoint
    print("\n--- Cairo checkpoint code (vi=10) ---")
    if 10 in checkpoint_states:
        print(checkpoint_to_cairo(checkpoint_states[10], 10))

    # Output checkpoint at best balanced split
    if candidates and best['vi'] in checkpoint_states:
        print(f"\n--- Cairo checkpoint code (vi={best['vi']} balanced) ---")
        print(checkpoint_to_cairo(checkpoint_states[best['vi']], best['vi']))


if __name__ == '__main__':
    main()
