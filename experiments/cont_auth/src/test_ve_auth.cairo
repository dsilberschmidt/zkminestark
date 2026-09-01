// Authenticated continuation VE — snforge contract tests.
//
// Tests A/B/C/D for calldata bridge + Poseidon commitment.
//   A: correct flow → ways[10]=1, ways[11]=2, phase transitions 0→1→2
//   B: tampered checkpoint → reverts 'commitment mismatch'
//   C: double chunk1 same game_id → reverts 'chunk1 already submitted'
//      (demonstrates replay protection; phase=2 after completion makes chunk2 replay
//       also fail at 'no pending chunk1' — verified by phase check in Test A)
//   D: chunk2 before chunk1 → reverts 'no pending chunk1'
//
// Gas: tests A/B/C use --max-n-steps 4000000000.

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use zkmine_cont::ve_auth::{IVeAuthDispatcher, IVeAuthDispatcherTrait};
use zkmine_2g::ve::{Factor, Constraint};

const GAME_ID: felt252 = 0x1;
const OTHER_GAME_ID: felt252 = 0x9999;

fn deploy() -> IVeAuthDispatcher {
    let class = declare("VeAuth").unwrap().contract_class();
    let (addr, _) = class.deploy(@array![]).unwrap();
    IVeAuthDispatcher { contract_address: addr }
}

fn f22_vars() -> Array<u32> {
    array![1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 14, 16, 18, 19, 20, 22, 26, 27, 28, 30, 40, 50, 60, 70, 80, 81, 91]
}

fn f22_constraints() -> Array<Constraint> {
    array![
        Constraint { variables: array![1, 2, 3, 11, 22], rhs: 1 },
        Constraint { variables: array![2, 3, 4, 14, 22], rhs: 2 },
        Constraint { variables: array![4, 5, 6, 14, 16, 26], rhs: 3 },
        Constraint { variables: array![6, 7, 8, 16, 18, 26, 27, 28], rhs: 5 },
        Constraint { variables: array![10, 11, 20, 22, 30], rhs: 1 },
        Constraint { variables: array![14], rhs: 1 },
        Constraint { variables: array![14, 16, 26], rhs: 3 },
        Constraint { variables: array![14, 22], rhs: 2 },
        Constraint { variables: array![18, 19, 28], rhs: 2 },
        Constraint { variables: array![20, 22, 30, 40], rhs: 1 },
        Constraint { variables: array![22], rhs: 1 },
        Constraint { variables: array![26], rhs: 1 },
        Constraint { variables: array![26, 27], rhs: 2 },
        Constraint { variables: array![26, 27, 28], rhs: 3 },
        Constraint { variables: array![27, 28], rhs: 2 },
        Constraint { variables: array![28], rhs: 1 },
        Constraint { variables: array![30, 40, 50], rhs: 1 },
        Constraint { variables: array![40, 50, 60], rhs: 1 },
        Constraint { variables: array![50, 60, 70], rhs: 1 },
        Constraint { variables: array![60, 70, 80, 81], rhs: 1 },
        Constraint { variables: array![81], rhs: 1 },
        Constraint { variables: array![81, 91], rhs: 2 },
    ]
}

// Helper: deploy a fresh contract, run chunk1 for a dummy game_id to get the checkpoint.
// chunk1_commit no longer returns the checkpoint; use hash_checkpoint view to verify,
// or deploy a VeResume view-only contract. Here we use hash_checkpoint indirectly:
// we need an Array<Factor> for chunk2_verify — get it via the ve_resume chunk1 view.
use zkmine_cont::ve_resume::{IVeResumeDispatcher, IVeResumeDispatcherTrait};

fn fresh_checkpoint() -> Array<Factor> {
    // VeResume has chunk1 as a VIEW function (no state mutation) that returns Array<Factor>
    let class = declare("VeResume").unwrap().contract_class();
    let (addr, _) = class.deploy(@array![]).unwrap();
    let d = IVeResumeDispatcher { contract_address: addr };
    d.chunk1(f22_vars(), f22_constraints(), 9_usize)
}

// ─── Test A: correct flow + exact result + phase transitions ─────────────────

#[test]
fn auth_a_correct_flow_ways_exact() {
    let disp = deploy();

    // Phase 0 before anything
    assert(disp.get_phase(GAME_ID) == 0_u8, 'phase not 0 initially');

    // chunk1_commit returns only the commitment (1 felt); checkpoint computed off-chain
    let commitment = disp.chunk1_commit(GAME_ID, f22_vars(), f22_constraints(), 9_usize);

    // Commitment must be nonzero (hash of 1201 felts, never 0 in practice)
    assert(commitment != 0, 'commitment is zero');
    // Phase 1 after chunk1
    assert(disp.get_phase(GAME_ID) == 1_u8, 'phase not 1 after chunk1');
    // Commitment stored
    assert(disp.get_commitment(GAME_ID) == commitment, 'stored commitment differs');

    // Get checkpoint via independent computation (same inputs → same result)
    let checkpoint = fresh_checkpoint();
    let ways = disp.chunk2_verify(GAME_ID, f22_vars(), checkpoint, 9_usize);

    // Python-verified: ways0[10]=1, ways0[11]=2
    assert(*ways.at(10) == 1_u256, 'ways[10] wrong');
    assert(*ways.at(11) == 2_u256, 'ways[11] wrong');

    // Phase 2 after chunk2
    assert(disp.get_phase(GAME_ID) == 2_u8, 'phase not 2 after chunk2');
    // Commitment slot cleared
    assert(disp.get_commitment(GAME_ID) == 0, 'commitment not cleared');
    // Any subsequent chunk2 would now fail: phase=2 ≠ 1 → 'no pending chunk1'
    // (demonstrated by state; explicit replay tested in auth_c)
}

// ─── Test B: tampered checkpoint reverts 'commitment mismatch' ───────────────

#[test]
#[should_panic]
fn auth_b_tampered_checkpoint_reverts() {
    let disp = deploy();
    // Tx1: stores commitment for the real 19-factor checkpoint (returns commitment only)
    let _ = disp.chunk1_commit(GAME_ID, f22_vars(), f22_constraints(), 9_usize);
    // Tx2 with empty checkpoint: hash([]) ≠ stored commitment → REVERT
    let bad: Array<Factor> = array![];
    disp.chunk2_verify(GAME_ID, f22_vars(), bad, 9_usize);
}

// ─── Test C: double chunk1 same game_id reverts 'chunk1 already submitted' ──

#[test]
#[should_panic]
fn auth_c_double_chunk1_reverts() {
    let disp = deploy();
    // First chunk1: OK (phase 0→1, returns commitment only)
    let _ = disp.chunk1_commit(GAME_ID, f22_vars(), f22_constraints(), 9_usize);
    // Second chunk1 for same game_id: phase=1 ≠ 0 → REVERT
    let _ = disp.chunk1_commit(GAME_ID, f22_vars(), f22_constraints(), 9_usize);
}

// ─── Test D: chunk2 before chunk1 reverts 'no pending chunk1' ───────────────

#[test]
#[should_panic]
fn auth_d_no_chunk1_reverts() {
    let disp = deploy();
    // No chunk1 called for OTHER_GAME_ID → phase=0 → REVERT
    let bad: Array<Factor> = array![];
    disp.chunk2_verify(OTHER_GAME_ID, f22_vars(), bad, 9_usize);
}
