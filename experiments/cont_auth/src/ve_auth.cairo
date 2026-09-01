// Authenticated continuation VE contract.
//
// Pattern: calldata bridge + Poseidon commitment.
//   Tx1 (chunk1_commit): computes chunk1, serializes checkpoint, hashes it with
//     poseidon_hash_span, stores (commitment, phase=1) keyed by game_id. Returns
//     checkpoint and commitment so caller can log/verify off-chain.
//   Tx2 (chunk2_verify): receives checkpoint via calldata, recomputes hash, asserts
//     it equals stored commitment, consumes the slot (commitment=0, phase=2), runs
//     chunk2. Rejects if: no pending slot, hash mismatch, or already completed.
//
// Storage written per game_id:
//   commitment: felt252  (0 = not pending)
//   phase: u8           (0=none, 1=chunk1 done, 2=chunk2 done)
//
// Two storage slots per game. Checkpoint itself NOT stored.

use zkmine_2g::ve::{
    Factor, Constraint, count_ordinary_component_start, count_ordinary_component_resume,
};
use core::poseidon::poseidon_hash_span;

#[starknet::interface]
pub trait IVeAuth<TContractState> {
    fn chunk1_commit(
        ref self: TContractState,
        game_id: felt252,
        variables: Array<u32>,
        constraints: Array<Constraint>,
        end_idx: usize,
    ) -> felt252;  // returns commitment only; checkpoint computed off-chain

    fn chunk2_verify(
        ref self: TContractState,
        game_id: felt252,
        variables: Array<u32>,
        checkpoint: Array<Factor>,
        start_idx: usize,
    ) -> Array<u256>;

    fn hash_checkpoint(self: @TContractState, checkpoint: Array<Factor>) -> felt252;

    fn get_phase(self: @TContractState, game_id: felt252) -> u8;
    fn get_commitment(self: @TContractState, game_id: felt252) -> felt252;
}

#[starknet::contract]
pub mod VeAuth {
    use super::{
        Factor, Constraint, count_ordinary_component_start, count_ordinary_component_resume,
        poseidon_hash_span,
    };
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        commitment: Map<felt252, felt252>,
        phase: Map<felt252, u8>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CommitmentStored: CommitmentStored,
        ChunkCompleted: ChunkCompleted,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CommitmentStored {
        #[key]
        pub game_id: felt252,
        pub commitment: felt252,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChunkCompleted {
        #[key]
        pub game_id: felt252,
    }

    #[abi(embed_v0)]
    impl VeAuthImpl of super::IVeAuth<ContractState> {
        fn chunk1_commit(
            ref self: ContractState,
            game_id: felt252,
            variables: Array<u32>,
            constraints: Array<Constraint>,
            end_idx: usize,
        ) -> felt252 {
            assert(self.phase.read(game_id) == 0_u8, 'chunk1 already submitted');
            let checkpoint = count_ordinary_component_start(@variables, @constraints, end_idx);
            let mut buf: Array<felt252> = array![];
            Serde::serialize(@checkpoint, ref buf);
            let commitment = poseidon_hash_span(buf.span());
            self.commitment.write(game_id, commitment);
            self.phase.write(game_id, 1_u8);
            self.emit(CommitmentStored { game_id, commitment });
            commitment
        }

        fn chunk2_verify(
            ref self: ContractState,
            game_id: felt252,
            variables: Array<u32>,
            checkpoint: Array<Factor>,
            start_idx: usize,
        ) -> Array<u256> {
            assert(self.phase.read(game_id) == 1_u8, 'no pending chunk1');
            let expected = self.commitment.read(game_id);
            let mut buf: Array<felt252> = array![];
            Serde::serialize(@checkpoint, ref buf);
            let actual = poseidon_hash_span(buf.span());
            assert(actual == expected, 'commitment mismatch');
            self.commitment.write(game_id, 0);
            self.phase.write(game_id, 2_u8);
            self.emit(ChunkCompleted { game_id });
            count_ordinary_component_resume(@variables, checkpoint, start_idx)
        }

        fn hash_checkpoint(self: @ContractState, checkpoint: Array<Factor>) -> felt252 {
            let mut buf: Array<felt252> = array![];
            Serde::serialize(@checkpoint, ref buf);
            poseidon_hash_span(buf.span())
        }

        fn get_phase(self: @ContractState, game_id: felt252) -> u8 {
            self.phase.read(game_id)
        }

        fn get_commitment(self: @ContractState, game_id: felt252) -> felt252 {
            self.commitment.read(game_id)
        }
    }
}
