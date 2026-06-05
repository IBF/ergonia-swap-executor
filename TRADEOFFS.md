# Trade-offs & Design Decisions — Ergonia Swap Executor Take-Home

## Architecture & Implementation Choices
- Implemented `executeSwapExactIn` with proper access control (`onlyAuthorized`), reentrancy guard, deadline validation, slippage protection, and token handling.
- Used a clean `SwapRouterLib` for router interactions.
- Monitor script uses `viem` for real-time price monitoring across two Uniswap V2 pools.

## Key Trade-offs

**Latency & Performance**
- Monitor uses polling (5s interval). In production I would subscribe to pair `Sync` events via WebSockets for much lower latency.

**Safety & Robustness**
- Enforced `minAmountOut`, reentrancy protection, and authorization checks.
- Standard `transferFrom` + `approve` pattern used.
- Production version would add: private RPCs, Flashbots/Jito bundles for MEV protection, and circuit breakers.

**Shortcuts Taken**
- Simple quote implementation in library (sufficient for tests).
- Basic price calculation in monitor.

**EVM vs Solana**
EVM has deep liquidity and mature tooling, but suffers from higher latency and MEV. Solana (as demonstrated in my [solana-managed-trading-agent-pro](https://github.com/IBF/solana-managed-trading-agent-pro)) offers superior speed via bundles and single-slot finality — ideal for high-frequency execution.

**AI Usage**: Used for boilerplate and monitor structure. All core logic reviewed and adapted manually.

Time spent: ~5 hours
