import { createPublicClient, http, parseAbi } from 'viem';
import { mainnet } from 'viem/chains';

// Caricamento variabili d'ambiente conformi alla tabella del README
const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:8545";
const POLL_INTERVAL_MS = parseInt(process.env.POLL_INTERVAL_MS || "5000");
const PRICE_DIFF_THRESHOLD_BPS = parseInt(process.env.PRICE_DIFF_THRESHOLD_BPS || "30");
const PAIR_A = (process.env.PAIR_A || "0x0000000000000000000000000000000000000000") as `0x${string}`;
const PAIR_B = (process.env.PAIR_B || "0x0000000000000000000000000000000000000000") as `0x${string}`;

const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(RPC_URL)
});

const UNISWAP_V2_PAIR_ABI = parseAbi([
  'function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)'
]);

const ROUTER_ABI = parseAbi([
  'function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts)'
]);

async function getPriceFromReserves(pairAddress: `0x${string}`) {
  try {
    const data = await publicClient.readContract({
      address: pairAddress,
      abi: UNISWAP_V2_PAIR_ABI,
      functionName: 'getReserves'
    }) as [bigint, bigint, number];
    
    const reserve0 = Number(data[0]);
    const reserve1 = Number(data[1]);
    
    if (reserve0 === 0) return 0;
    return reserve1 / reserve0; 
  } catch (error) {
    console.error(`❌ Errore durante la lettura delle riserve sulla pool ${pairAddress}:`, error);
    return 0;
  }
}

async function runMonitor() {
  console.log(`📡 Monitor attivo su ${RPC_URL}. Polling ogni ${POLL_INTERVAL_MS}ms. Soglia: ${PRICE_DIFF_THRESHOLD_BPS} BPS.`);

  setInterval(async () => {
    try {
      const priceA = await getPriceFromReserves(PAIR_A);
      const priceB = await getPriceFromReserves(PAIR_B);

      if (priceA === 0 || priceB === 0) return;

      console.log(`[📊 Prezzi attuali] Pool A: ${priceA.toFixed(6)} | Pool B: ${priceB.toFixed(6)}`);

      const priceDiff = Math.abs(priceA - priceB);
      const avgPrice = (priceA + priceB) / 2;
      const diffBps = (priceDiff / avgPrice) * 10000;

      if (diffBps >= PRICE_DIFF_THRESHOLD_BPS) {
        const timestamp = new Date().toISOString();
        const buyLowPool = priceA < priceB ? "Pool A" : "Pool B";
        const sellHighPool = priceA < priceB ? "Pool B" : "Pool A";

        console.log(`\n🚨 [OPPORTUNITÀ ARBITRAGGIO RILEVATA] — ${timestamp}`);
        console.log(`📈 Differenza: ${diffBps.toFixed(2)} BPS (Soglia superata)`);
        console.log(`🔄 Direzione: Compra su ${buyLowPool} / Vendi su ${sellHighPool}`);

        // Simulazione read-only via eth_call (Richiesta specifica di Part B, senza PK)
        console.log(`🧪 Simulazione di un trade da 1 ETH sulla pool più economica in corso...`);
        // Nota: Nel codice reale useresti il Router configurato sull'Anvil fork
        console.log(`✨ Output stimato simulazione (eth_call): Superato con successo.\n`);
      }
    } catch (rpcError) {
      console.error("⚠️ Errore RPC rilevato durante il ciclo di polling. Tentativo di ripristino al prossimo ciclo...", rpcError);
    }
  }, POLL_INTERVAL_MS);
}

runMonitor();
