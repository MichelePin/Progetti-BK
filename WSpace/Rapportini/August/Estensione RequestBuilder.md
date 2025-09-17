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
# Estensione RequestBuilder per Ordini Specializzati

  

## Funzionalità implementate

  

- Estensione della classe `RequestBuilder` con nuovi metodi per creare richieste specializzate per diversi tipi di ordini

- Implementazione di interfacce TypeScript per garantire type safety

- Supporto per tutti i tipi di ordini richiesti dal sistema backend

  

## File modificati

  

- `src/app/classes/builder/request-builder.ts`: Aggiunta di 5 nuovi metodi statici per la creazione di richieste specializzate

- `src/app/classes/request/order-requests.ts`:  Definizione di interfacce TypeScript per i diversi tipi di richieste

  

## Nuove interfacce create

  

### JSWarOrderRequest

Estende `JSWarRequest` aggiungendo:

- `OrderNo: string` - Numero dell'ordine

  

### JSWarInventoryOrderRequest  

Estende `JSWarRequest` aggiungendo:

- `OrderMode: number` - Modalità dell'ordine

- `OrderNo: string` - Numero dell'ordine

- `FilterItemNo?: string` - Filtro per numero articolo (opzionale)

- `FilterZoneNo?: string` - Filtro per numero zona (opzionale)

- `BinNoList?: string[]` - Lista numeri collocazione (opzionale)

  

### JSWarManualInventoryEntryRequest

Estende `JSWarRequest` aggiungendo:

- `OrderNo: string` - Numero dell'ordine

- `ItemNo: string` - Numero articolo

- `LotNo?: string` - Numero lotto (opzionale)

- `SerialNo?: string` - Numero seriale (opzionale)

- `BinEntryNo: number` - Numero entry collocazione

- `Quantity: number` - Quantità

- `DueDate?: Date` - Data scadenza (opzionale)

  

### JSWarMoveOrderRequest

Estende `JSWarRequest` aggiungendo:

- `OrderMode: number` - Modalità dell'ordine

- `OrderNo: string` - Numero dell'ordine

- `ToBinNo?: string` - Collocazione destinazione (opzionale)

- `FilterItemNo?: string` - Filtro articolo (opzionale)

- `BinNoList?: string[]` - Lista collocazioni (opzionale)

- `FilterZoneNo?: string` - Filtro zona (opzionale)

- `Options?: JSWAROrderOptions[]` - Opzioni ordine (opzionale)

  

### JSWARCreateMoveOrderRequest

Estende `JSWarRequest` aggiungendo:

- `VendorNo?: string` - Numero fornitore (opzionale)

- `Type: number` - Tipo ordine

- `ToBinNo?: string` - Collocazione destinazione (opzionale)

- `OrderMode: number` - Modalità ordine (corretto typo da "OderMode")

- `DocumentNo?: string` - Numero documento (opzionale)

- `ItemList: CreateMoveOrderItem[]` - Lista articoli

  

## Nuovi metodi del RequestBuilder

  

### createJSWarOrderRequest(orderNo, loginParams?)

Crea una richiesta base per ordini con numero ordine.

  

**Parametri:**

- `orderNo: string` - Numero dell'ordine (obbligatorio)

- `loginParams?: LoginParams` - Parametri di login (opzionale)

  

**Esempio d'uso:**

```typescript

const request = RequestBuilder.createJSWarOrderRequest("ORD-001");

```

  

### createJSWarInventoryOrderRequest(params, loginParams?)

Crea una richiesta per ordini di inventario.

  

**Parametri:**

- `params.orderMode: number` - Modalità dell'ordine

- `params.orderNo: string` - Numero dell'ordine  

- `params.filterItemNo?: string` - Filtro articolo (opzionale)

- `params.filterZoneNo?: string` - Filtro zona (opzionale)

- `params.binNoList?: string[]` - Lista collocazioni (opzionale)

  

**Esempio d'uso:**

```typescript

const request = RequestBuilder.createJSWarInventoryOrderRequest({

  orderMode: 1,

  orderNo: "INV-001",

  filterItemNo: "ITEM123",

  binNoList: ["BIN001", "BIN002"]

});

```

  

### createJSWarManualInventoryEntryRequest(params, loginParams?)

Crea una richiesta per inserimenti manuali di inventario.

  

**Esempio d'uso:**

```typescript

const request = RequestBuilder.createJSWarManualInventoryEntryRequest({

  orderNo: "INV-001",

  itemNo: "ITEM123",

  binEntryNo: 12345,

  quantity: 10,

  lotNo: "LOT001",

  dueDate: new Date("2025-12-31")

});

```

  

### createJSWarMoveOrderRequest(params, loginParams?)

Crea una richiesta per ordini di movimento.

  

**Esempio d'uso:**

```typescript

const request = RequestBuilder.createJSWarMoveOrderRequest({

  orderMode: 2,

  orderNo: "MOVE-001",

  toBinNo: "BIN-DEST",

  filterItemNo: "ITEM123",

  options: [

    {

      OrderStatus: "PENDING",

      Destination: "WAREHOUSE-A",

      Source: "WAREHOUSE-B"

    }

  ]

});

```

  

### createJSWARCreateMoveOrderRequest(params, loginParams?)

Crea una richiesta per la creazione di nuovi ordini di movimento.

  

**Esempio d'uso:**

```typescript

const request = RequestBuilder.createJSWARCreateMoveOrderRequest({

  type: 1,

  orderMode: 2,

  vendorNo: "VEND001",

  documentNo: "DOC123",

  itemList: [

    {

      ItemNo: "ITEM001",

      Quantity: 5,

      LotNo: "LOT001",

      SerialNo: "SN001"

    },

    {

      ItemNo: "ITEM002",

      Quantity: 3

    }

  ]

});

```

  

## Vantaggi dell'implementazione

  

1. **Type Safety**: Le interfacce TypeScript garantiscono che i parametri siano corretti a tempo di compilazione

2. **Consistenza**: Tutti i metodi seguono lo stesso pattern del `RequestBuilder` esistente

3. **Riutilizzabilità**: I metodi possono essere usati in tutto il progetto per creare richieste standardizzate

4. **Manutenibilità**: Separazione delle interfacce in un file dedicato facilita la manutenzione

5. **Documentazione**: Ogni metodo è documentato con JSDoc in italiano seguendo le convenzioni del progetto

  

## Pattern di utilizzo

  

Tutti i metodi seguono il pattern esistente:

1. Chiamano `createJSWarRequest(loginParams)` per ottenere i parametri base

2. Aggiungono i parametri specifici per il tipo di richiesta

3. Restituiscono un oggetto tipizzato che estende `JSWarRequest`

  

Questo garantisce compatibilità con il sistema esistente e mantiene la coerenza del codice.

  

## Note tecniche

  

- Correzione del typo "OderMode" in "OrderMode" nell'interfaccia originale

- Tutte le proprietà opzionali sono marcate con `?`

- Le date utilizzano il tipo `Date` nativo di TypeScript

- Gli array sono tipizzati correttamente (es. `string[]`, `CreateMoveOrderItem[]`)