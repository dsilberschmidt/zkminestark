// ATENCIÓN: este contrato usa --secret-key 420 del repo cartridge-gg/vrf.
// Clave VRF pública de test. Válida solo para medición F0 en Sepolia testnet.
// NUNCA usar en producción ni con fondos reales.

// Espejo manual de la interfaz IVrfProvider de cartridge_vrf v0.3.1.
// Fuente: https://github.com/cartridge-gg/vrf/blob/v0.3.1/src/vrf_provider/vrf_provider_component.cairo
// Si el ABI del contrato real cambia, esta interfaz debe actualizarse en paralelo.
// El selector de función se calcula por nombre — cualquier diferencia produce revert silencioso.
#[derive(Drop, Copy, Clone, Serde)]
enum Source {
    Nonce: starknet::ContractAddress,
    Salt: felt252,
}

#[starknet::interface]
trait IVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: starknet::ContractAddress, source: Source);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
}

#[starknet::interface]
trait IBenchmark<TContractState> {
    fn roll(ref self: TContractState);
    fn get_last_value(self: @TContractState) -> felt252;
    fn get_counter(self: @TContractState) -> u64;
}

#[starknet::contract]
mod Benchmark {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use super::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};

    #[storage]
    struct Storage {
        vrf_provider: ContractAddress,
        last_value: felt252,
        counter: u64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RandomConsumed: RandomConsumed,
    }

    #[derive(Drop, starknet::Event)]
    struct RandomConsumed {
        caller: ContractAddress,
        value: felt252,
        counter: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState, vrf_provider: ContractAddress) {
        self.vrf_provider.write(vrf_provider);
    }

    #[abi(embed_v0)]
    impl BenchmarkImpl of super::IBenchmark<ContractState> {
        fn roll(ref self: ContractState) {
            let caller = get_caller_address();
            let vrf = IVrfProviderDispatcher {
                contract_address: self.vrf_provider.read()
            };
            let value = vrf.consume_random(Source::Nonce(caller));
            let counter = self.counter.read() + 1;
            self.last_value.write(value);
            self.counter.write(counter);
            self.emit(RandomConsumed { caller, value, counter });
        }

        fn get_last_value(self: @ContractState) -> felt252 {
            self.last_value.read()
        }

        fn get_counter(self: @ContractState) -> u64 {
            self.counter.read()
        }
    }
}
