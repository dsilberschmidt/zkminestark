// Minimal contract for on-chain continuation demo.
// chunk1: runs VE vars[0..end_idx), returns checkpoint (Array<Factor>).
// chunk2: takes checkpoint as calldata, runs VE vars[start_idx..), returns ways.
// Both are view functions — no state mutation, no storage.

use zkmine_2g::ve::{Factor, Constraint, count_ordinary_component_start, count_ordinary_component_resume};

#[starknet::interface]
pub trait IVeResume<TContractState> {
    fn chunk1(
        self: @TContractState,
        variables: Array<u32>,
        constraints: Array<Constraint>,
        end_idx: usize,
    ) -> Array<Factor>;

    fn chunk2(
        self: @TContractState,
        variables: Array<u32>,
        checkpoint: Array<Factor>,
        start_idx: usize,
    ) -> Array<u256>;
}

#[starknet::contract]
pub mod VeResume {
    use super::{Factor, Constraint, count_ordinary_component_start, count_ordinary_component_resume};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl VeResumeImpl of super::IVeResume<ContractState> {
        fn chunk1(
            self: @ContractState,
            variables: Array<u32>,
            constraints: Array<Constraint>,
            end_idx: usize,
        ) -> Array<Factor> {
            count_ordinary_component_start(@variables, @constraints, end_idx)
        }

        fn chunk2(
            self: @ContractState,
            variables: Array<u32>,
            checkpoint: Array<Factor>,
            start_idx: usize,
        ) -> Array<u256> {
            count_ordinary_component_resume(@variables, checkpoint, start_idx)
        }
    }
}
