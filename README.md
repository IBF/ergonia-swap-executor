# Ergonia — DeFi Engineer Take-Home

**Estimated time:** 7–9 hours  
**Stack:** Solidity 0.8.x + Foundry, TypeScript + viem  
**Role reference:** DeFi Engineer (on-chain execution, trading systems, EVM)

This project evaluates your ability to ship pragmatic DeFi systems: secure on-chain execution, low-latency data reading, and sensible trade-offs under time pressure.

You may choose **EVM (required track below)**. A Solana track is optional bonus — not required for submission.

---

## Overview

You are picking up an in-progress **desk swap executor** branch. **Part A boilerplate is in this repo** — access control works, but the swap path is blocked (`ERG-EXEC-12`).

Your job: wire `executeSwapExactIn`, pass Foundry tests, then build the monitor script (Part B).

Clone → `./setup.sh` → read `TICKETS.md` → unblock tickets in `src/` (see tree below).

```
desk-swap-executor/
├── config/desk/
├── docs/{architecture,runbooks}/
├── scripts/{deploy,monitor}/
├── src/
│   ├── auth/                # Owned.sol
│   ├── constants/
│   ├── execution/
│   │   ├── SwapExecutor.sol ← main work (ERG-EXEC-12)
│   │   ├── ExecutionContext.sol
│   │   ├── libraries/SwapRouterLib.sol
│   │   └── strategies/
│   ├── interfaces/{external,internal}/
│   ├── registry/            # TokenAllowlist (context only)
│   └── utils/guards/
└── test/
    ├── mocks/{tokens,external}/
    ├── unit/execution/
    └── integration/
```

**Estimated time:** 7–9 hours (Part A ~3–4h · Part B ~3–4h · TRADEOFFS.md ~1h)

---

## Part A — Smart contract (`src/`, ~3–4 hours) — **boilerplate provided**

> Start: `TICKETS.md` · `./setup.sh` · `test/unit/execution/SwapExecutor.t.sol` · mock router in `test/mocks/`

`src/execution/SwapExecutor.sol` ships with owner/executor ACL complete. **Unblock ERG-EXEC-12** in `executeSwapExactIn` (see `src/execution/libraries/SwapRouterLib.sol`).

### `SwapExecutor.sol` (complete the blocked function)

A contract that executes a **Uniswap V2-style** single-hop swap via an external pair/router interface.

**Interfaces** (define yourself or use minimal interfaces in `src/interfaces/`):

- `IUniswapV2Router02` — at minimum `swapExactTokensForTokens`
- `IERC20` — `transferFrom`, `transfer`, `approve`, `balanceOf`

**Required behaviour:**

| Function | Spec |
|---|---|
| `constructor(address router, address owner)` | Store router address; set owner. |
| `executeSwapExactIn(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut, address[] path, uint256 deadline)` | Pull `tokenIn` from caller, approve router, execute swap, send output tokens back to caller. Revert if output < `minAmountOut`. Only callable by owner OR an authorized executor address. |
| `setExecutor(address executor, bool allowed)` | Owner toggles who may call `executeSwapExactIn`. |
| `rescueTokens(address token, address to, uint256 amount)` | Owner-only emergency withdraw. |

**Safety:**

- `ReentrancyGuard` on swap.
- Revert on expired deadline, empty path, zero amounts.
- Do not hardcode mainnet addresses inside the contract — pass via constructor.

### Foundry tests (`test/`, minimum **6 tests**)

Use a local mock router or mock pair (implement `MockUniswapV2Router.sol` in `test/` or `src/mocks/`):

| # | Scenario |
|---|---|
| 1 | Successful swap returns expected output |
| 2 | Reverts when output below `minAmountOut` |
| 3 | Reverts when deadline expired (`vm.warp`) |
| 4 | Non-authorized caller reverts |
| 5 | Authorized executor can swap |
| 6 | Reentrancy attempt fails |

All tests pass with `forge test`.

---

## Part B — Monitor script (`scripts/monitor.ts`, ~3–4 hours)

TypeScript script using **viem** that:

1. Connects to a **local Anvil fork** of Ethereum mainnet (default `http://127.0.0.1:8545`).
2. Reads reserves from **two Uniswap V2 pairs** for the same token pair (e.g. WETH/USDC) — you choose the pair addresses and document them in `CONFIG.md`.
3. Computes spot price from reserves (`reserve1/reserve0`, adjusted for decimals).
4. Logs prices every poll interval (default **5 seconds**).
5. When absolute price difference exceeds a threshold (default **0.30%**), log:
   - timestamp
   - both prices
   - direction of arb (buy low pool / sell high pool)
   - **simulated** output amount if swapping `1 ETH` worth through the cheaper pool (read-only `eth_call` or router simulation — no private key required for submission)
6. Gracefully handles RPC errors (retry or exit with clear message).

**Configuration via environment variables** (document in `CONFIG.md`):

| Variable | Default | Description |
|---|---|---|
| `RPC_URL` | `http://127.0.0.1:8545` | Anvil fork RPC |
| `POLL_INTERVAL_MS` | `5000` | Poll frequency |
| `PRICE_DIFF_THRESHOLD_BPS` | `30` | Trigger threshold (0.30%) |
| `PAIR_A` | *(candidate sets)* | First V2 pair address |
| `PAIR_B` | *(candidate sets)* | Second V2 pair address |

**Run:**

```bash
npm install
# Start fork: anvil --fork-url $MAINNET_RPC_URL
npm run monitor
```

---

## Part C — Trade-offs doc (`TRADEOFFS.md`, ~1 hour)

Max 2 pages. Cover:

1. **Latency:** what dominates latency in your monitor (RPC, polling interval, block time)?
2. **Execution risk:** what could go wrong between detection and landing a tx (slippage, frontrunning, stale reserves)?
3. **Two shortcuts** you took to fit 7–9 hours and what you'd improve for production at a trading desk.
4. **One Solana vs EVM observation** (even if you only built EVM) — optional but valued.

---

## Suggested time breakdown

| Task | Hours |
|---|---|
| Part A — SwapExecutor + tests | 3–4 |
| Part B — monitor script | 3–4 |
| Part C — TRADEOFFS.md | 1 |
| **Total** | **7–9** |

---

## Setup

### Foundry

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge build
forge test
```

### TypeScript

```bash
npm install
npm run typecheck
```

### Fork (example)

```bash
export MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
anvil --fork-url $MAINNET_RPC_URL
```

---

## Submission

1. Push to GitHub (public or private with access granted).
2. Include `SUBMISSION.md` with:
   - `forge test` output summary
   - screenshot or log snippet of monitor detecting a price diff (or note if threshold not hit on your fork — explain)
   - instructions to run your project in < 5 commands
3. Do not commit RPC API keys or private keys.

---

## Evaluation criteria

| Area | Weight |
|---|---|
| SwapExecutor correctness and access control | High |
| Foundry test quality | High |
| Monitor: correct reserve math and polling logic | High |
| TRADEOFFS.md — execution and latency awareness | High |
| Code clarity and pragmatic scope control | Medium |

---

## Allowed

- OpenZeppelin, viem, Foundry
- Mock contracts for testing
- AI tools (note in TRADEOFFS.md if used)

## Not allowed

- Submitting only Part A or only Part B (both required)
- Hardcoded private keys
- Copy-paste of a full MEV bot without understanding (keep scope to spec above)

---

## Optional bonus (not required)

Solana program (Rust/Anchor) that logs a similar reserve/price read from a Raydium/Orca pool — max +2 hours, mention in TRADEOFFS.md only.

---

## Questions

Reply on the same thread you received this project from.

Good luck.
