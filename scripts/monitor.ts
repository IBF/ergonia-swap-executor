import { createPublicClient, http, formatUnits } from 'viem';
import { mainnet } from 'viem/chains';

const config = {
  rpcUrl: process.env.RPC_URL || 'http://127.0.0.1:8545',
  pollInterval: Number(process.env.POLL_INTERVAL_MS) || 5000,
  priceDiffThresholdBps: Number(process.env.PRICE_DIFF_THRESHOLD_BPS) || 30,
  // Add your pair addresses here (from CONFIG.md or mainnet)
  pairA: '0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc' as `0x${string}`, // Example: USDC/WETH
  pairB: '0xAE461cA67B15dc8dc81CE2A2F6c2A0f6fC5f9f0a' as `0x${string}`, // Replace with real pairs
};

const client = createPublicClient({
  chain: mainnet,
  transport: http(config.rpcUrl),
});

async function getReserves(pair: `0x${string}`) {
  try {
    const reserves = await client.readContract({
      address: pair,
      abi: [
        { "inputs": [], "name": "getReserves", "outputs": [{"type":"uint112"},{"type":"uint112"},{"type":"uint32"}], "stateMutability": "view", "type": "function" },
        { "inputs": [], "name": "token0", "outputs": [{"type":"address"}], "stateMutability": "view", "type": "function" }
      ],
      functionName: 'getReserves',
    });

    return { reserve0: reserves[0], reserve1: reserves[1] };
  } catch (e) {
    console.error(`Error reading pair ${pair}:`, e);
    return null;
  }
}

function calculatePrice(reserve0: bigint, reserve1: bigint) {
  return Number(formatUnits(reserve1, 6)) / Number(formatUnits(reserve0, 18)); // Adjust decimals if needed
}

async function main() {
  console.log("🚀 Ergonia Price Monitor Started (looking for arbitrage)...");
  console.log(`Polling every ${config.pollInterval}ms | Threshold: ${config.priceDiffThresholdBps} bps\n`);

  while (true) {
    try {
      const [resA, resB] = await Promise.all([
        getReserves(config.pairA),
        getReserves(config.pairB)
      ]);

      if (!resA || !resB) {
        await new Promise(r => setTimeout(r, config.pollInterval));
        continue;
      }

      const priceA = calculatePrice(resA.reserve0, resA.reserve1);
      const priceB = calculatePrice(resB.reserve0, resB.reserve1);

      const diffBps = Math.abs((priceA - priceB) / ((priceA + priceB)/2)) * 10000;

      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] Price A: ${priceA.toFixed(6)} | Price B: ${priceB.toFixed(6)} | Diff: ${diffBps.toFixed(1)} bps`);

      if (diffBps > config.priceDiffThresholdBps) {
        console.log(`\n✅ ARBITRAGE OPPORTUNITY DETECTED! Buy on ${priceA < priceB ? 'Pool A' : 'Pool B'}`);
      }
    } catch (error) {
      console.error("Error during monitoring:", error);
    }

    await new Promise(r => setTimeout(r, config.pollInterval));
  }
}

main().catch(console.error);
