# Trade-offs & Design Decisions — Ergonia Swap Executor

## Architecture & Implementation Choices
- **Event-Driven Architecture**: Sostituito il meccanismo di polling con una sottoscrizione in tempo reale agli eventi `Sync` delle pool tramite WebSockets (`watchContractEvent`). Riduce la latenza di esecuzione da 5 secondi a pochi millisecondi (sub-block).
- **Simulazione Preventiva**: Implementato `publicClient.simulateContract` (`eth_call`) prima dell'invio a blocchi per azzerare lo spreco di gas dovuto a transazioni destinate a fallire nel mempool.
- **Gas-Optimized Smart Contract**: Rimosse le stringhe di errore standard dei `require` in favore dei `Custom Errors` di Solidity, abbattendo drasticamente il costo di deployment e di esecuzione di ogni swap.
- **Slippage Dinamico & MEV Protection**: Integrato un moltiplicatore dello slippage rigido (0.5%) calcolato direttamente prima della simulazione per mitigare il rischio di Sandwich Attacks (MEV) sui blocchi pubblici.

## Key Trade-offs
- **WebSocket vs HTTP**: I WebSocket offrono la latenza minima necessaria per sistemi quantitativi ma soffrono di disconnessioni saltuarie; è stato integrato un loop nativo di auto-riconnessione del client con 10 tentativi di fallback.
- **Mancanza di Flashbots Bundle**: Per questo specifico test locale si utilizza un RPC standard, ma in produzione l'invio verrebbe instradato tramite la rete Flashbots Builder (usando `mev_sendBundle`) per garantire l'esclusione totale dal mempool pubblico.
- **EVM vs Solana**: L'infrastruttura EVM offre un livello di liquidità globale consolidato ma espone a problemi strutturali legati all'ordinamento dei blocchi e all'estrazione di MEV tossico. Solana, grazie ai canali di sottomissione diretta tramite bundle Jito e alla finalità a slot singolo, permette una reattività sensibilmente superiore per l'esecuzione ad alta frequenza.
