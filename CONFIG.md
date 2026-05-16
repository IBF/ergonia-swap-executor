# Ergonia DeFi Execution Assessment — Configuration

Set these environment variables before running `npm run monitor`.

| Variable | Required | Example | Description |
|---|---|---|---|
| `RPC_URL` | No | `http://127.0.0.1:8545` | Anvil fork RPC endpoint |
| `POLL_INTERVAL_MS` | No | `5000` | Milliseconds between reserve reads |
| `PRICE_DIFF_THRESHOLD_BPS` | No | `30` | Alert when price diff ≥ 0.30% (30 bps) |
| `PAIR_A` | **Yes** | `0x…` | Uniswap V2 pair address (pool 1) |
| `PAIR_B` | **Yes** | `0x…` | Uniswap V2 pair address (pool 2) |

## Example

```bash
export RPC_URL=http://127.0.0.1:8545
export PAIR_A=0xB4e16d0168e52d35CaCD2c6185b442883Ec8C7C0
export PAIR_B=0x…
npm run monitor
```

Replace pair addresses with two mainnet V2 pairs for the **same token pair** (document token symbols and decimals in your `SUBMISSION.md`).
