use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: felt252,
    pub player: ContractAddress,
    pub status: u8,
    pub mine_count: u16,
    pub remaining_mines: u16,
    pub revealed_count: u32,
    pub total_cells: u32,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Cell {
    #[key]
    pub game_id: felt252,
    #[key]
    pub x: u8,
    #[key]
    pub y: u8,
    pub is_mine: bool,
    pub revealed: bool,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Config {
    #[key]
    pub id: felt252,
    pub vrf_provider: ContractAddress,
}
