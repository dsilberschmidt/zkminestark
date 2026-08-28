# zkminestark

Public demo: https://zkminestark.vercel.app/

`zkminestark` is a competitive fully onchain Minesweeper built for Starknet/Dojo. Its board materializes during play: each committed action that requires new materialization uses verifiable randomness to assign only the cells needed for that action. The grant application proposes extracting that mechanism as `VCLS` (`Verifiable Constrained Lazy Sampling`) and publishing it as a reusable Cairo/Dojo package for finite category supplies, adaptive materialization, and exact sampling without replacement.

Useful references:
- [`docs/ROADMAP-STARKNET.md`](docs/ROADMAP-STARKNET.md)
- [`docs/INSTALACIONES-001.md`](docs/INSTALACIONES-001.md)
- [`docs/INCOGNITAS.md`](docs/INCOGNITAS.md)
- [`docs/bitacora.md`](docs/bitacora.md)

## Current artifacts

- Public demo client: [`client/minasweeper.html`](client/minasweeper.html), deployed via Vercel.
- Cairo packages with tests: [`contracts/vrf_bench`](contracts/vrf_bench) and [`contracts/zkmine_f1`](contracts/zkmine_f1).
- Public F0 rerun log: [`benchmarks/f0-sepolia-rerun-20260823-135554.log`](benchmarks/f0-sepolia-rerun-20260823-135554.log).

## Demo

The public demo is a browser prototype for gameplay and UX validation.

- Playable presets: `8x8 / 10 mines`, `16x16 / 40 mines`, `30x16 / 99 mines`
- Features: safe opening behavior, flags, question marks, chord, click counter, local best score per preset
- RNG: local browser `Math.random()`

This artifact demonstrates the complete interaction model and click-based scoring in the browser. Grant milestone M2 connects that experience to the Dojo world through Cartridge Controller, direct RPC submission, preconfirmation polling, and Torii-backed aggregate views.

## What is demonstrated today

### F0: VRF latency benchmark

F0 measured the `sncast` submission path for VRF-consuming Sepolia transactions before full game implementation.

- Initial result: `p50 = 3312 ms`, `p95 = 4095 ms`
- Rerun on 2026-08-23: `p50 = 3268 ms`, `p95 = 4093 ms`
- Reported rerun sample: `459` successful timing samples, `41` isolated failed attempts with a pattern compatible with account or client nonce races

This demonstrates a public latency dataset and a RED benchmark result that still requires direct-RPC measurement to separate client-path cost from network latency. Methodology and raw data are in [`docs/INSTALACIONES-001.md`](docs/INSTALACIONES-001.md) and [`benchmarks/f0-sepolia-rerun-20260823-135554.log`](benchmarks/f0-sepolia-rerun-20260823-135554.log).

### F1-A: atomic lazy-assignment vertical slice

F1-A demonstrates the central onchain mechanism on Sepolia: atomic VRF consumption followed by an onchain state update.

- Dojo World: `0x05cec67ca060126d1e1133ae4002001b03f1c631e6e43d8a9904cb3b7c5e392d`
- Actions contract: `0x31a8af789641e9883d23c17b072ad7d0bd5d557d4643eeda013eae0a3b048bc`
- `Config.vrf_provider`: `0x05284b1597a91df6db38a25eae873063d08d37fd8cb5d0357d310b6e5dcffe37`
- Valid `set_config` transaction: `0x032e835fb3d447b7a8baa9674634b52afdffec25b8a154bc00008f5ebba29cec`
- `spawn_game` transaction: `0x0560bd2953e9d9eefe67cc03af4213dec8defec406739484fc72d86dc6b1b599`
- `game_id`: `0x335060aeef3ab51fc10ea76b8a3a60b53372c9b43d052ac552ac46204f80ead`
- Safe-cell transaction: `0x138185ae0d0d417ce26495edd689c8bcd4e2a20308601216f70156b0dc7f68`
- Mine-hit transaction: `0x4147c66f07556ef80d2713a016823b38f553ab32a7a936625300d70ec8776d3`
- Final read: `Game status=2, mine_count=99, remaining_mines=98, revealed_count=0, total_cells=480`
- Final read: `Cell(0,0): is_mine=1, revealed=1`

The hardened `set_config` policy is covered by tests for authorized initial call, unauthorized caller rejection, second write rejection, and zero VRF rejection.

### Ideal sampler property test

`zkmine_f1` includes an exhaustive finite-case property test for the ideal lazy-sampling model on a `5x5` board with `2` mines.

- All `C(25,2) = 300` final configurations are covered
- Fixed-order and adaptive-order sampling are both checked
- Probabilities are represented as exact rationals
- Each configuration is checked against probability `1 / 300`

This demonstrates exact equivalence for one finite instance of the ideal sampler.

## Ideal sampler vs implementation claim

The project keeps two claims separate.

- Exact equivalence of the ideal sampler: progressive revelation has the same distribution as revealing a uniformly pre-generated assignment compatible with the initial constraints.
- Computational indistinguishability of the VRF/PRF implementation: the M1 reference construction consumes one atomic VRF output, expands it through a domain-separated PRF stream, uses rejection sampling for exact range reduction, and aims to be computationally indistinguishable from the ideal sampler under VRF and PRF security.

F1-A currently uses `bucket = raw % remaining_cells; is_mine = bucket < remaining_mines`, which carries the already documented negligible modulo bias. Grant milestone M1 replaces that reduction with rejection sampling.

## Game model

For the standard `30 x 16` board, zkminestark starts from `480` cells and `99` mines. The opening policy conditions the board on a safe starting region, then samples the `99` mines uniformly among the remaining eligible cells.

On a click that requires new materialization:

- the selected cell is sampled against the remaining mine and cell counts
- a safe result triggers materialization of every undetermined neighbor required to compute the clue
- flood-fill cascades may request further cells adaptively from the same VRF seed through a PRF stream

This is the mechanism that VCLS generalizes.

## Proposed grant scope

The application requests funding to complete the testnet game and extract the reusable package. It is organized in three milestones.

### M1: core sampler and complete game logic

- Implement the VCLS core in Cairo with rejection sampling, domain-separated PRF expansion, deterministic assignment order, remaining-category accounting, and auditable events
- Build the full Dojo world for zkminestark
- Complete lazy sampling across click paths and cascades
- Add the conditioned safe opening, preset validation, final 3BV par, and score computation
- Publish deployment addresses, distributional tests, and audited final board histories

### M2: production VRF and playable client

- Connect the browser prototype to the Dojo world through Cartridge Controller session keys
- Submit transactions through direct RPC with preconfirmation polling
- Render already-determined cells optimistically and wait for VRF only on actions that require new materialization
- Test the production Cartridge VRF flow against precompute, simulation-abort, and seed-retry adversarial strategies
- Run eight structured external sessions covering onboarding, Sepolia playtesting, and feedback

### M3: reusable VCLS package and second adapter

- Publish VCLS as a standalone Cairo/Dojo package
- Publish a formal specification with proof of ideal equivalence, security assumptions, an integration guide, and tests
- Include the zkminestark adapter
- Build a second resource-exploration adapter with more than two categories
- Publish an article on VCLS and the F0/M2 latency results

## Future phase

Mainnet, transferable value, and paid entry belong to a later phase with its own technical, security, and legal gate.
