use starknet::ContractAddress;

use zkmine_f1::systems::actions::{config_setter, set_config_guard_code};

fn zero_address() -> ContractAddress {
    0_felt252.try_into().unwrap()
}

fn valid_vrf() -> ContractAddress {
    0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37.try_into().unwrap()
}

fn other_caller() -> ContractAddress {
    0x0127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec.try_into().unwrap()
}

fn existing_vrf() -> ContractAddress {
    0x062550dc4e5a4c6d4f0d2e6a5ee91c3f5a8cb4a1f962c5f47a9c7b9be8d3df91.try_into().unwrap()
}

#[test]
fn set_config_authorized_initial_call_is_allowed() {
    let code = set_config_guard_code(config_setter(), zero_address(), valid_vrf());
    assert(code == 0, 'authorized init rejected');
}

#[test]
fn set_config_unauthorized_call_is_rejected() {
    let code = set_config_guard_code(other_caller(), zero_address(), valid_vrf());
    assert(code == 1, 'unauthorized accepted');
}

#[test]
fn set_config_second_authorized_call_is_rejected() {
    let code = set_config_guard_code(config_setter(), existing_vrf(), valid_vrf());
    assert(code == 3, 'second write accepted');
}

#[test]
fn set_config_zero_vrf_is_rejected() {
    let code = set_config_guard_code(config_setter(), zero_address(), zero_address());
    assert(code == 2, 'zero vrf accepted');
}
