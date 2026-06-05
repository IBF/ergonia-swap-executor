import { createPublicClient, createWalletClient, webSocket, http, parseAbi } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { mainnet } from 'viem/chains';

const WS_RPC = process.env.WS_RPC_URL || "wss://://alchemy.com";
const HTTP_RPC = process.env.HTTP_RPC_URL || "https://://alchemy.com";
const PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}` || "0x0000000000000000000000000000000000000000000000000000000000000000";

const account = privateKeyToAccount(PRIVATE_KEY);

const publicClient = createPublicClient({
  chain: mainnet,
  transport: webSocket(WS_RPC, { reconnect: { attempts: 10, delay: 2000 } })
});

const walletClient = createWalletClient({
  account,
  chain: mainnet,
  transport: http(HTTP_RPC)
});

const EXECUTOR_ADDRESS = "0x0000000000000000000000000000000000000000";
const POOL_A = "0x0000000000000000000000000000000000000000";
const POOL_B = "0x0000000000000000000000000000000000000000";

const UNISWAP_V2_PAIR_ABI = parseAbi([
  'event Sync(uint112 reserve0, uint112 reserve1)'
]);

const EXECUTOR_ABI = parseAbi([
  'function executeSwapExactIn(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut, uint256 deadline) external'
]);

async function startMonitoring() {
  console.log("🚀 Monitor avviato in modalità Real-Time WebSocket...");

  publicClient.watchContractEvent({
    address: [POOL_A, POOL_B],
    abi: UNISWAP_V2_PAIR_ABI,
    eventName: 'Sync',
    onLogs: async (logs) => {
      for (const log of logs) {
        console.log(`⚡ Nuova sincronizzazione rilevata sulla pool: ${log.address}`);
        await checkArbitrageAndExecute();
      }
    },
    onError: (error) => {
      console.error("❌ Errore WebSocket, tentativo di riconnessione...", error);
    }
  });
}

async function checkArbitrageAndExecute() {
  try {
    const priceGapDetected = true; 
    
    if (priceGapDetected) {
      const amountIn = 1000000000000000000n; 
      const expectedOut = 2000000000000000000n; 
      
      const minAmountOut = (expectedOut * 995n) / 1000n; 
      const deadline = BigInt(Math.floor(Date.now() / 1000) + 60);

      console.log("🎯 Opportunità rilevata. Simulazione transazione in corso...");

      const { request } = await publicClient.simulateContract({
        account,
        address: EXECUTOR_ADDRESS,
        abi: EXECUTOR_ABI,
        functionName: 'executeSwapExactIn',
        args: ["0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000", amountIn, minAmountOut, deadline],
      });

      console.log("✅ Simulazione superata con successo! Invio transazione...");
      
      const hash = await walletClient.writeContract(request);
      console.log(`📦 Transazione inviata! Hash: ${hash}`);
    }
  } catch (error) {
    console.error("⚠️ Calcolo o Simulazione fallita (Transazione bloccata per evitare perdite di Gas):", error);
  }
}

startMonitoring();
