# zkminestark

Public demo: https://zkminestark.vercel.app/

`zkminestark` is a Minesweeper-on-Starknet project centered on three ideas:
- the score is click count, not time
- board generation is lazy rather than precommitted up front
- randomness is intended to come from VRF, not from a client-visible deterministic layout

Useful references:
- [`docs/ROADMAP-STARKNET.md`](docs/ROADMAP-STARKNET.md)
- [`docs/INSTALACIONES-001.md`](docs/INSTALACIONES-001.md)
- [`docs/bitacora.md`](docs/bitacora.md)

## Current state

- The repo contains a public demo client at [`client/minasweeper.html`](client/minasweeper.html), deployed via Vercel.
- The current client is a GNOME Mines-style local demo with three playable presets:
  - `8x8 / 10 mines`
  - `16x16 / 40 mines`
  - `30x16 / 99 mines`
- The demo supports first-click-safe opening, flags, question-mark state, chord, click counter and a local best-score record per preset.
- The client RNG is local browser RNG based on `Math.random()`. It is not deterministic, is not a fairness mechanism, and is only used for demo/UX purposes.
- The repo also contains two Cairo packages with real tests:
  - `contracts/vrf_bench`
  - `contracts/zkmine_f1`

## What is proven

- F0 is completed and documented.
- `vrf_bench` integrates the VRF provider interface and now has 2 real integration tests for the actual benchmark contract behavior.
- F1-A is completed and documented as a Sepolia PoC combining real VRF integration with lazy sampling.
- In `zkmine_f1`, `set_config` is now protected by an authorized caller, rejects zero VRF addresses, and is one-shot / immutable after the first valid configuration.
- `zkmine_f1` includes 4 policy tests for `set_config`:
  - authorized initial call
  - unauthorized caller rejection
  - second write rejection
  - zero VRF rejection
- `zkmine_f1` also includes an exhaustive property test for the ideal lazy sampling model on a finite `5x5` board with `2` mines:
  - all `C(25,2) = 300` final configurations are covered
  - a fixed order and an adaptive order are both checked
  - probabilities are represented as exact rationals, with no floating point
  - each configuration is checked against the expected probability `1 / 300`
  - both strategies are checked to induce the same distribution

Important scope note:
- this property test is an exhaustive verification of one finite case of the ideal lazy sampling model
- it is not a general mathematical proof
- it does not prove exact uniformity of the production `raw % remaining_cells` implementation, which still carries the already-known negligible modulo bias

## What is not yet implemented

- There is not yet a complete on-chain game equivalent to the current GNOME-style demo.
- The full playable UX has not yet been carried through into the final on-chain flow.
- Production-ready payout / reward logic is not implemented yet.
- Final economics and anti-spam mechanics are not closed yet.
- There is not yet an end-to-end validation of the complete game, with all rules and UX, wired into real VRF.

## Demo

The public demo at https://zkminestark.vercel.app/ is:
- a GNOME Mines-style interaction demo
- playable with presets `8x8/10`, `16x16/40`, `30x16/99`
- storing local per-preset best scores in `localStorage`
- not using seeds
- not using simulated economy
- not using cooldowns
- not using visual theme switching

It should be read as a product / interaction demo, not yet as the final on-chain game logic.

## Sepolia evidence

- F0 VRF benchmark: completed
- F1-A: redeployed with hardened `set_config`
  - world address: `0x05cec67ca060126d1e1133ae4002001b03f1c631e6e43d8a9904cb3b7c5e392d`
  - actions address: `0x31a8af789641e9883d23c17b072ad7d0bd5d557d4643eeda013eae0a3b048bc`
  - `set_config` valid call executed once: `0x032e835fb3d447b7a8baa9674634b52afdffec25b8a154bc00008f5ebba29cec`
  - `Config.vrf_provider` verified as `0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37`
  - second `set_config` call verified to revert with `already configured`
  - minimal F1-A revalidation:
    - `spawn_game` tx `0x0560bd2953e9d9eefe67cc03af4213dec8defec406739484fc72d86dc6b1b599`
    - `game_id` `0x335060aeef3ab51fc10ea76b8a3a60b53372c9b43d052ac552ac46204f80ead`
    - atomic `submit_random + click` tx `0x4147c66f07556ef80d2713a016823b38f553ab32a7a936625300d70ec8776d3`
    - final read: `Game status=2, mine_count=99, remaining_mines=98, revealed_count=0, total_cells=480`
    - final read: `Cell(0,0): is_mine=1, revealed=1`

Detailed addresses, tx hashes and run evidence belong in:
- [`docs/INSTALACIONES-001.md`](docs/INSTALACIONES-001.md)

## Grant roadmap

- Turn the current PoC into a playable on-chain vertical slice.
- Connect the UX to real VRF-driven game flow.
- Complete board state, number propagation and rule handling needed for the full experience.
- Close minimal scoring, settlement and economic logic.
- Expand edge-case coverage and move from benchmark + PoC to an end-to-end verifiable demo.
