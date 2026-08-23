use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use vrf_bench::{IBenchmarkDispatcher, IBenchmarkDispatcherTrait};

#[derive(Drop, Copy, Clone, Serde)]
enum Source {
    Nonce: ContractAddress,
    Salt: felt252,
}

#[starknet::contract]
mod MockVrfProvider {
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        fixed_value: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, fixed_value: felt252) {
        self.fixed_value.write(fixed_value);
    }

    #[abi(embed_v0)]
    impl MockImpl of super::IMockVrfProvider<ContractState> {
        fn request_random(
            self: @ContractState, caller: ContractAddress, source: super::Source
        ) {
            let _ = caller;
            let _ = source;
        }

        fn consume_random(ref self: ContractState, source: super::Source) -> felt252 {
            let _ = source;
            self.fixed_value.read()
        }
    }
}

#[starknet::interface]
trait IMockVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: ContractAddress, source: Source);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
}

fn deploy_contract(name: ByteArray, calldata: Array<felt252>) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

fn deploy_mock_vrf(fixed_value: felt252) -> ContractAddress {
    deploy_contract("MockVrfProvider", array![fixed_value])
}

fn deploy_benchmark(vrf_provider: ContractAddress) -> IBenchmarkDispatcher {
    let benchmark_address = deploy_contract("Benchmark", array![vrf_provider.into()]);
    IBenchmarkDispatcher { contract_address: benchmark_address }
}

#[test]
fn benchmark_initial_state_is_zeroed() {
    let vrf_provider = deploy_mock_vrf(777);
    let benchmark = deploy_benchmark(vrf_provider);

    let last_value = benchmark.get_last_value();
    let counter = benchmark.get_counter();

    assert(last_value == 0, 'invalid initial last_value');
    assert(counter == 0, 'invalid initial counter');
}

#[test]
fn roll_consumes_mock_value_and_increments_counter() {
    let vrf_provider = deploy_mock_vrf(777);
    let benchmark = deploy_benchmark(vrf_provider);

    benchmark.roll();

    let last_value = benchmark.get_last_value();
    let counter = benchmark.get_counter();

    assert(last_value == 777, 'invalid persisted value');
    assert(counter == 1, 'invalid counter after roll');
}
