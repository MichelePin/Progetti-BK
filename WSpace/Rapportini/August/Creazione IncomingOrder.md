---
Progetto: WSpace
Tipo: Rapportino
Tempo Impiegato: 4
Ultima Modifica: 2025-08-11
tags:
  - WSpace
  - Rapportino
Versione: 2.40.01
Categoria: Componenti
Argomento: Ordini di Ricezione
---
## Panoramica

  

Implementato il provider per la gestione degli ordini in arrivo (incoming orders) seguendo il pattern del `InventoryOrderListPageProvider`. Il nuovo provider supporta la visualizzazione, gestione e completamento degli ordini di movimentazione in arrivo.

  

## File Creati

  

### 1. `src/app/classes/page-data/incoming-order-data.ts`

Classe per i dati della pagina degli ordini in arrivo, contiene:

- `binEntryList`: Lista delle bin entries per l'ordine

- `orderRowList`: Lista delle righe dell'ordine in arrivo  

- `orderHeader`: Header dell'ordine in arrivo

- `summary`: Riassunto statistiche dell'ordine

  

### 2. `src/app/services/page/incoming-order-list.ts`

Provider principale per la gestione degli ordini in arrivo con le seguenti funzionalità:

  

#### Metodi Principali

- `openIncomingOrderDetails(orderNo)`: Apre i dettagli di un ordine in arrivo

- `loadIncomingOrderData(orderNo)`: Carica i dati dal server tramite `/Api/WarMoveOrder/LoadIncomingOrderData`

- `createIncomingOrderDetailsPage(data)`: Crea la pagina dei dettagli con griglia e azioni

  

#### Gestione Quantità

- `handleQuantityActions(line, origin)`: Gestisce le azioni di quantità tramite modal

- `confirmQuantity(line)`: Conferma la ricezione di una quantità

- `changeQuantity(line)`: Permette di modificare la quantità ricevuta

  

#### Gestione Ordini  

- `completeIncomingOrder(orderNo)`: Completa l'ordine chiamando `/Api/WARMoveOrder/CompleteIncomingOrder`

- `startIncomingOrder(orderNo)`: Avvia un ordine in arrivo

- `pauseIncomingOrder(orderNo)`: Mette in pausa un ordine

- `deleteIncomingOrder(orderNo)`: Cancella un ordine dopo conferma

- `assignOrderToResource(orderNo, callback)`: Assegna ordine a risorsa

  

## File Modificati

  

### 1. `src/app/classes/page-data-container.ts`

- Aggiunto import di `IncomingOrderData`

- Aggiunta proprietà privata `incomingOrderData`

- Aggiunto metodo `getIncomingOrderData()`

  

### 2. `src/app/services/page/order-list.ts`

- Aggiunto import di `IncomingOrderListPageProvider`

- Aggiunto provider nel constructor con dependency injection

- Aggiunto supporto per `WarPlanningType.INCOMING` nel metodo `openOrder()`

- Aggiunta gestione ordini in arrivo nella griglia con icona container

  

## Endpoint API utilizzati

  

### Caricamento Dati

- **POST** `/Api/WarMoveOrder/LoadIncomingOrderData`

  - Input: `{ OrderNo: string, LoadConfig: boolean }`

  - Output: Dati completi dell'ordine con righe, bin entries e statistiche

  

### Completamento Ordine

- **POST** `/Api/WARMoveOrder/CompleteIncomingOrder`  

  - Input: `{ OrderNo: string, ToBinNo: string }`

  - Output: Conferma completamento con creazione BinEntries e ItemLedgerEntries

  

### Gestione Stato

- **POST** `/Api/WAROrder/StartOrder` - Avvio ordine

- **POST** `/Api/WAROrder/PauseOrder` - Pausa ordine  

- **POST** `/Api/WAROrder/DeleteOrder` - Cancellazione ordine

  

### Gestione Quantità (da implementare lato server)

- **POST** `/Api/WarMoveOrder/ConfirmReceive` - Conferma ricezione

- **POST** `/Api/WarMoveOrder/ChangeReceivedQuantity` - Modifica quantità ricevuta

  

## Funzionalità Implementate

  

### Visualizzazione Ordini

- ✅ Lista ordini in arrivo nella griglia principale con icona container

- ✅ Apertura dettagli ordine in modalità dedicata

- ✅ Visualizzazione righe ordine con stato ricezione

  

### Gestione Quantità  

- ✅ Modal per conferma/modifica quantità ricevuta

- ✅ Disabilitazione azioni per righe già completate

- ✅ Aggiornamento UI dopo modifiche

  

### Azioni Ordine

- ✅ Avvio, pausa, completamento ordini

- ✅ Cancellazione con conferma utente

- ✅ Assegnazione a risorsa corrente

- ✅ Navigazione indietro alla lista principale

  

### UI/UX

- ✅ Modal con lista azioni per gestione quantità  

- ✅ Modal per gestione stato ordine

- ✅ Toast notifications per feedback utente

- ✅ Gestione errori con alert appropriati

  

## Pattern di Sviluppo

  

Il provider segue fedelmente il pattern di `InventoryOrderListPageProvider`:

- Stessa struttura di metodi e responsabilità

- Utilizzo degli stessi component (ModalButtonListPage)

- Gestione errori e loading consistente

- Naming convention e documentazione uniforme

  

## Note Tecniche

  

- Utilizzati gli stessi ActionID del provider inventory per coerenza

- Supporto per `WarPlanningType.INCOMING = 3`

- Navigazione gestita tramite `orderListPageProvider.loadOrderListPage()`

- Configurazione pagina caricata dinamicamente dal server quando `LoadConfig = true`

- Gestione statistiche ordine (righe completate, quantità ricevute, differenze)

  

## Test e Validazione

  

Per testare l'implementazione:

1. Creare ordini di movimentazione mock tramite `MOCKADDMOVEORDER`

2. Verificare apertura dettagli dalla lista ordini

3. Testare gestione quantità e completamento ordini

4. Validare navigazione e gestione errori