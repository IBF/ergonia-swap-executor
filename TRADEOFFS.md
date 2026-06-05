# Trade-offs & Design Decisions — Ergonia Swap Executor

## Architecture & Implementation Choices
- **Conformità della Firma**: Implementata la funzione `executeSwapExactIn` rispettando tutti i 6 parametri richiesti dalla traccia, incluso l'array di instradamento dinamico `path` per consentire sia trade diretti sia multi-hop.
- **Robustezza nel Polling**: Sviluppato il monitor in TypeScript basandosi rigorosamente sul polling a intervalli regolari (configurabile tramite variabile d'ambiente `POLL_INTERVAL_MS`) come indicato dalle specifiche.
- **Sicurezza On-Chain**: Introdotti i `Custom Errors` per ottimizzare radicalmente il consumo di gas, accoppiati a verifiche di sicurezza essenziali quali `nonReentrant`, controlli sulla validità del `deadline` e l'esclusione di trasferimenti con importi a zero.

## Key Trade-offs & Latency Factors
- **Latenza del Polling (5s)**: Il tempo di polling predefinito a 5 secondi rappresenta il fattore di latenza dominante nel monitoraggio. In ambiente di produzione industriale, questo approccio verrebbe rimpiazzato da una sottoscrizione WebSocket agli eventi di blocco o ai log di `Sync` per intercettare i movimenti all'interno del medesimo blocco.
- **Rischio di Esecuzione**: Il divario temporale tra il calcolo del gap di prezzo nel ciclo di polling e il completamento della transazione on-chain espone al rischio di variazioni repentine delle riserve (Slippage) o ad attacchi di frontrunning/sandwich nel mempool pubblico.
- **Shortcuts per Vincolo Temporale (7-9 Ore)**: 
  1. *Simulazione Semplificata*: La verifica dell'output atteso nel monitor si affida a chiamate computazionali standard di lettura anziché integrare algoritmi predittivi complessi basati sullo stato esatto delle pool di destinazione.
  2. *Gestione del Flusso di Riconnessione*: In caso di anomalie di rete, lo script salta l'esecuzione corrente affidandosi al recupero nativo nel ciclo di intervallo successivo, omettendo logiche sofisticate di backoff esponenziale.
- **Osservazione EVM vs Solana**: L'architettura EVM garantisce una componibilità sincrona immediata (fondamentale per interazioni atomiche via contratti), ma soffre della latenza determinata dal tempo di blocco e dalle insidie del MEV nel mempool. Al contrario, Solana offre un'esecuzione parallela a bassissima latenza e transazioni finalizzate nello spazio di frazioni di secondo, mitigando il MEV tossico grazie a mercati di commissioni localizzati e all'invio diretto tramite bundle.
