use starknet::ContractAddress;

use zkmine_f1::systems::actions::{config_setter, set_config_guard_code};

const IDEAL_GRID_CELLS: u32 = 25;
const IDEAL_MINES: u32 = 2;
const IDEAL_CONFIGURATION_COUNT: u128 = 300;

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

fn gcd(mut a: u128, mut b: u128) -> u128 {
    while b != 0 {
        let r = a % b;
        a = b;
        b = r;
    }
    a
}

fn mul_ratio(
    numerator: u128, denominator: u128, step_numerator: u128, step_denominator: u128
) -> (u128, u128) {
    let left_gcd = gcd(numerator, step_denominator);
    let right_gcd = gcd(step_numerator, denominator);

    let reduced_numerator = numerator / left_gcd;
    let reduced_step_denominator = step_denominator / left_gcd;
    let reduced_step_numerator = step_numerator / right_gcd;
    let reduced_denominator = denominator / right_gcd;

    (
        reduced_numerator * reduced_step_numerator,
        reduced_denominator * reduced_step_denominator,
    )
}

fn has_mine(index: u32, mine_a: u32, mine_b: u32) -> bool {
    index == mine_a || index == mine_b
}

fn is_used(used: @Array<u32>, candidate: u32) -> bool {
    let mut idx = 0_usize;
    while idx < used.len() {
        if *used.at(idx) == candidate {
            return true;
        }
        idx += 1_usize;
    }
    false
}

fn choose_next_index(
    used: @Array<u32>, observed_mines: u32, step: u32, center_is_mine: bool
) -> u32 {
    if step == 0_u32 {
        return 12_u32;
    }
    if step == 1_u32 {
        return if center_is_mine { 0_u32 } else { 24_u32 };
    }
    if step == 2_u32 {
        return if observed_mines > 0_u32 { 4_u32 } else { 20_u32 };
    }
    if step == 3_u32 {
        return if observed_mines == 0_u32 { 6_u32 } else { 18_u32 };
    }

    let mut candidate = 0_u32;
    while candidate < IDEAL_GRID_CELLS {
        if !is_used(used, candidate) {
            return candidate;
        }
        candidate += 1_u32;
    }
    0_u32
}

fn simulate_fixed_row_major_probability(mine_a: u32, mine_b: u32) -> (u128, u128) {
    let mut numerator = 1_u128;
    let mut denominator = 1_u128;
    let mut remaining_mines = IDEAL_MINES;
    let mut remaining_cells = IDEAL_GRID_CELLS;
    let mut index = 0_u32;

    while index < IDEAL_GRID_CELLS {
        if has_mine(index, mine_a, mine_b) {
            let (next_numerator, next_denominator) = mul_ratio(
                numerator, denominator, remaining_mines.into(), remaining_cells.into()
            );
            numerator = next_numerator;
            denominator = next_denominator;
            remaining_mines -= 1_u32;
        } else {
            let (next_numerator, next_denominator) = mul_ratio(
                numerator,
                denominator,
                (remaining_cells - remaining_mines).into(),
                remaining_cells.into(),
            );
            numerator = next_numerator;
            denominator = next_denominator;
        }
        remaining_cells -= 1_u32;
        index += 1_u32;
    }

    (numerator, denominator)
}

fn simulate_adaptive_probability(mine_a: u32, mine_b: u32) -> (u128, u128) {
    let mut numerator = 1_u128;
    let mut denominator = 1_u128;
    let mut remaining_mines = IDEAL_MINES;
    let mut remaining_cells = IDEAL_GRID_CELLS;
    let mut used = ArrayTrait::<u32>::new();
    let mut observed_mines = 0_u32;
    let mut center_is_mine = false;
    let mut step = 0_u32;

    while step < IDEAL_GRID_CELLS {
        let index = choose_next_index(@used, observed_mines, step, center_is_mine);
        used.append(index);

        if has_mine(index, mine_a, mine_b) {
            let (next_numerator, next_denominator) = mul_ratio(
                numerator, denominator, remaining_mines.into(), remaining_cells.into()
            );
            numerator = next_numerator;
            denominator = next_denominator;
            remaining_mines -= 1_u32;
            observed_mines += 1_u32;
            if step == 0_u32 {
                center_is_mine = true;
            }
        } else {
            let (next_numerator, next_denominator) = mul_ratio(
                numerator,
                denominator,
                (remaining_cells - remaining_mines).into(),
                remaining_cells.into(),
            );
            numerator = next_numerator;
            denominator = next_denominator;
        }

        remaining_cells -= 1_u32;
        step += 1_u32;
    }

    (numerator, denominator)
}

fn assert_ideal_lazy_sampling_range(start_index: u128, end_index: u128) {
    // Exhaustive verification of the ideal lazy sampling model for 5x5 with 2 mines.
    // This checks exact uniformity over all 300 final configurations for two query orders:
    // one fixed and one adaptive. It does NOT test the tiny modulo bias of raw % remaining_cells.
    let mut configuration_count = 0_u128;
    let mut current_index = 0_u128;
    let mut i = 0_u32;

    while i < IDEAL_GRID_CELLS {
        let mut j = i + 1_u32;
        while j < IDEAL_GRID_CELLS {
            if current_index >= start_index && current_index < end_index {
                configuration_count += 1_u128;

                let (fixed_num, fixed_den) = simulate_fixed_row_major_probability(i, j);
                let (adaptive_num, adaptive_den) = simulate_adaptive_probability(i, j);

                assert(
                    fixed_num * IDEAL_CONFIGURATION_COUNT == fixed_den,
                    'fixed order not 1/300'
                );
                assert(
                    adaptive_num * IDEAL_CONFIGURATION_COUNT == adaptive_den,
                    'adaptive order not 1/300'
                );
                assert(
                    fixed_num * adaptive_den == adaptive_num * fixed_den,
                    'strategy distributions differ'
                );
            }

            current_index += 1_u128;
            j += 1_u32;
        }
        i += 1_u32;
    }

    assert(configuration_count == end_index - start_index, 'invalid range count');
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_000_050() {
    assert_ideal_lazy_sampling_range(0_u128, 50_u128);
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_050_100() {
    assert_ideal_lazy_sampling_range(50_u128, 100_u128);
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_100_150() {
    assert_ideal_lazy_sampling_range(100_u128, 150_u128);
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_150_200() {
    assert_ideal_lazy_sampling_range(150_u128, 200_u128);
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_200_250() {
    assert_ideal_lazy_sampling_range(200_u128, 250_u128);
}

#[test]
fn ideal_lazy_sampling_5x5_2_range_250_300() {
    assert_ideal_lazy_sampling_range(250_u128, 300_u128);
}
