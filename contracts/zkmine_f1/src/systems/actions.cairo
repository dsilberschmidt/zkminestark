use starknet::ContractAddress;

// Mirror of IVrfProvider from cartridge_vrf v0.3.1 — same pattern as vrf_bench, no package dep.
#[derive(Drop, Copy, Clone, Serde)]
enum Source {
    Nonce: ContractAddress,
    Salt: felt252,
}

#[starknet::interface]
trait IVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: ContractAddress, source: Source);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
}

#[starknet::interface]
pub trait IActions<T> {
    fn set_config(ref self: T, vrf_provider: ContractAddress);
    fn spawn_game(ref self: T, mine_count: u16) -> felt252;
    fn click(ref self: T, game_id: felt252, x: u8, y: u8);
}

#[dojo::contract]
pub mod actions {
    use dojo::model::ModelStorage;
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_tx_info};
    use core::poseidon::poseidon_hash_span;
    use super::{IActions, IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};
    use zkmine_f1::models::{Config, Game, Cell};

    const GRID_W: u8 = 30;
    const GRID_H: u8 = 16;
    const TOTAL_CELLS: u32 = 480;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn set_config(ref self: ContractState, vrf_provider: ContractAddress) {
            let mut world = self.world_default();
            world.write_model(@Config { id: 0, vrf_provider });
        }

        fn spawn_game(ref self: ContractState, mine_count: u16) -> felt252 {
            assert(mine_count > 0 && mine_count.into() < TOTAL_CELLS, 'invalid mine_count');

            let mut world = self.world_default();
            let player = get_caller_address();

            let tx_info = get_tx_info().unbox();
            let nonce = tx_info.nonce;
            let chain_id = tx_info.chain_id;
            let game_system = get_contract_address();

            let game_id = poseidon_hash_span(
                array![nonce, player.into(), game_system.into(), chain_id].span()
            );

            world.write_model(@Game {
                game_id,
                player,
                status: 0,
                mine_count,
                remaining_mines: mine_count,
                revealed_count: 0,
                total_cells: TOTAL_CELLS,
            });

            game_id
        }

        fn click(ref self: ContractState, game_id: felt252, x: u8, y: u8) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let mut game: Game = world.read_model(game_id);
            assert(game.status == 0, 'game not active');
            assert(game.player == player, 'not your game');
            assert(x < GRID_W && y < GRID_H, 'out of bounds');

            let cell: Cell = world.read_model((game_id, x, y));
            assert(!cell.revealed, 'already clicked');

            let config: Config = world.read_model(0_felt252);
            let vrf = IVrfProviderDispatcher { contract_address: config.vrf_provider };
            let raw: felt252 = vrf.consume_random(Source::Nonce(player));

            // Hypergeometric lazy sampling: P(mine) = remaining_mines / remaining_cells.
            // In Active state remaining_mines = mine_count (mine click ends game immediately),
            // so remaining_cells = total_cells - revealed_count.
            let remaining_cells: u32 = game.total_cells - game.revealed_count;

            // Map raw to [0, remaining_cells) via modulo; bias = remaining_cells/felt252_max ≈ 2^-243.
            let raw_u256: u256 = raw.into();
            let bucket: u256 = raw_u256 % remaining_cells.into();
            let is_mine: bool = bucket < game.remaining_mines.into();

            world.write_model(@Cell { game_id, x, y, is_mine, revealed: true });

            if is_mine {
                // Maintains auditable invariant: mine_count - remaining_mines = mines clicked.
                // Written to storage below — queryable in the final game record.
                game.remaining_mines -= 1;
                game.status = 2; // Lost
            } else {
                game.revealed_count += 1;
                // Win: all safe cells revealed ↔ revealed_count + mine_count == total_cells.
                if game.revealed_count + game.mine_count.into() == game.total_cells {
                    game.status = 1; // Won
                }
            }

            world.write_model(@game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zkmine_f1")
        }
    }
}
