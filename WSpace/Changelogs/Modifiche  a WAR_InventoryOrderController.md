---
Progetto: WSpace
Categoria: API
Tipo: Documento-Cambi
Argomento: Ordini
Versione: 2.60.3
Repo: WEC
Linguaggio: C#
---

---

**Tags**  
#Backend #Controller #getInventoryItems #contareInventario

## Intro 
Documentazione sui cambi effetuati su [[WAR_InventoryOrderController]]
## 🔧 Modifiche Implementate

### 1. **Aggiornamento `JSWarInventoryOrderRequest`**

- Aggiunta proprietà `OrderNo` per supportare operazioni sulle righe
    
- Reso `BinNo` opzionale per maggiore flessibilità
    

### 2. **Nuovi Metodi nel Provider**

#### `createInventoryOrderLines(orderNo: string)`

- Invoca endpoint `/Api/WARInventoryOrder/CreateInventoryOrderLines`
    
- Crea le righe dell’inventario in base ai contenuti attuali dei bin
    
- Esegue controlli di validazione (ordine esistente, righe già create)
    

#### `getInventoryOrderItems(orderNo: string)`

- Invoca endpoint `/Api/WARInventoryOrder/GetInventoryOrderItems`
    
- Recupera i dati dell’ordine con tutte le righe generate
    
- Utile per visualizzare il contenuto di un ordine
    

---

## 🔄 Flusso Completo (Ora Supportato)

1. **Creazione Ordine**  
    `createInventoryOrder("COLL_01")` → genera l’header dell’ordine
    
2. **Generazione Righe**  
    `createInventoryOrderLines(orderID)` → popola le righe con i contenuti dei bin
    
3. **Visualizzazione**  
    `getInventoryOrderItems(orderID)` → mostra le righe create
    

---

## ✅ Nuovo Endpoint: `UpdateInventoryOrderLine`

### Richiesta (Request)

- Nuova classe: `UpdateInventoryLineRequest` estende `JSWarInventoryOrderRequest`
    
- Campi aggiuntivi:
    
    - `OrderLineID`
        
    - `AdjustmentQuantity`: stringa (“+1”, “-2”)
        
    - `CountedQuantity`: numero decimale
        

### Endpoint API

```
POST /api/WARInventoryOrder/UpdateInventoryOrderLine
```

#### 🔑 Funzionalità principali

1. **Gestione Flessibile dell’Input**
    
    - Accetta `AdjustmentQuantity` in formato “+n” o “-n”, oppure
        
    - Accetta `CountedQuantity` decimale (calcolo automatico della variazione)
        
2. **Aggiornamenti su `WAR_PlanningLine`**
    
    - `CountedQuantity` aggiornato
        
    - Stato salvato su campo `CustDecimal1`
        
    - `Status = 1` se la variazione è zero o la quantità conteggiata corrisponde a quella prevista
        
3. **Creazione di `WAR_InventoryEntry`**
    
    - Nuova entry con tutti i campi necessari
        
    - Memorizza la quantità di variazione (± richiesta)
        
    - Registra azione effettuata:
        
        - 1 = aggiustamento
            
        - 2 = conteggio diretto
            
    - Campi personalizzati:
        
        - `CustString1`: RequestResourceID
            
        - `CustString2`: RequestDevice
            
        - `CustDecimal1`: nuova quantità conteggiata
            
        - `CustDecimal2`: quantità prevista originale
            
        - `CustDecimal3`: valore della variazione
            

---

### 🧪 Esempi di Request

**Con `AdjustmentQuantity`**

```json
{
  "OrderNo": "inv-01-250119-1430",
  "OrderLineID": 1,
  "AdjustmentQuantity": "+2",
  "RequestResourceID": "RESOURCE001",
  "RequestDevice": "DEVICE001"
}
```

**Con `CountedQuantity`**

```json
{
  "OrderNo": "inv-01-250119-1430",
  "OrderLineID": 1,
  "CountedQuantity": 15.5,
  "RequestResourceID": "RESOURCE001",
  "RequestDevice": "DEVICE001"
}
```

#### 🖥️ Esempio di risposta

```json
{
  "Success": true,
  "Message": "Riga inventario aggiornata con successo",
  "Data": {
    "PlanningLine": { /* oggetto aggiornato */ },
    "InventoryEntry": { /* nuova entry inventario */ },
    "PreviousCountedQuantity": 10,
    "NewCountedQuantity": 12,
    "AdjustmentValue": 2,
    "IsCompleted": false
  }
}
```

---

## 📦 Endpoint `CreateInventoryOrder`

### Route e Dettagli

```
POST /api/WAROrder/CreateInventoryOrder
```

- **URL completo** (esempio): `https://yourserver.com/api/WAROrder/CreateInventoryOrder`
    
- **Metodo:** POST
    
- **Content-Type:** `application/json`
    
- **Body:** oggetto JSON con struttura `JSWarInventoryOrderRequest`
    

#### 📌 Esempio di request body

```json
{
  "BinNo": "BIN001",
  "LocationNo": "LOC001",
  "ZoneNo": "ZONE001",
  "RequestResourceID": "RESOURCE001",
  "RequestDevice": "DEVICE001",
  "Product": 1,
  "Type": 1,
  "OrderMode": 0,
  "OrderStatus": 0,
  "ItemNo": "",
  "LoadConfig": false
}
```

#### ✅ Risposta attesa

```json
{
  "Success": true,
  "Message": "Nuovo documento di inventario creato!",
  "OrderID": "inv-01-250119-1430"
}
```

> ⚠️ **Nota**: la proprietà `BinNo` è fondamentale — viene usata sia come `FilterBinNo` in `WAR_PlanningHeader`, sia come `BinNo` in `WAR_PlanningINBin`.

---

