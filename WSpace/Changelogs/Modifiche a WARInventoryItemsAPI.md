---
Progetto: WSpace
Tipo: Documento-Cambi
Argomento: Ordini
Versione: 2.60.2
Repo: WEC
Linguaggio: C#
Categoria: API
---
```toc 
maxLevel:1
```

---

#  Introduzione

L'implementazione del controller `WARInventoryOrderController` si occuperà della gestione degli ordini di inventario e delle relative righe.

---

#  Implementazioni

### 1. **Aggiunta di una nuova classe di risposta**

- Creata la classe `InventoryOrderResponse` per restituire sia le testate che le righe degli ordini.

### 2. **Implementazione del metodo GetInventoryOrderItems**

Questo metodo:

- Riceve una proprietà `OrderNo` nella richiesta.
- Trova l'oggetto `WAR_PlanningHeader` corrispondente all'ordine.
- Recupera tutte le voci `WAR_PlanningINBin` che corrispondono all'`OrderNo`.
- Per ogni bin, utilizza `GDB.WARBinEntry.GetBinItemList()` per ottenere gli articoli contenuti.
- Crea voci `WAR_PlanningLine` con:
    - `OrderLineID` auto-incrementale (1, 2, 3, ecc.)
    - Proprietà mappate dagli articoli del bin
    - Generazione corretta della chiave `OrderKey`
- Restituisce la testata e le righe insieme.

### 3. **Implementazione del metodo CreateInventoryOrderLines**

Questo metodo:

- Esegue le stesse operazioni di `GetInventoryOrderItems`, ma salva anche le righe nel database.
- Include una validazione per evitare la creazione di righe duplicate.
- Utilizza `db.WAR_PlanningLine.AddRange()` per salvare tutte le righe.
- Restituisce un messaggio di successo con il numero di righe create.

---

#  API Endpoints

**Per visualizzare gli articoli dell’ordine di inventario:**

```
POST /api/WARInventoryOrder/GetInventoryOrderItems
```

**Per creare e salvare le righe dell’ordine di inventario:**

```
POST /api/WARInventoryOrder/CreateInventoryOrderLines
```

---

#  Esempio di Request Body

```Json
{
  "OrderNo": "inv-01-250119-1430",
  "RequestResourceID": "RESOURCE001",
  "RequestDevice": "DEVICE001",
  "LocationNo": "LOC001",
  "ZoneNo": "ZONE001"
}
```

---

#  Esempio di Risposta

```Json
{
  "Success": true,
  "Message": "Create 5 righe per l'ordine inv-01-250119-1430",
  "Data": {
    "Header": { /* Oggetto WAR_PlanningHeader */ },
    "Lines": [ /* Array di oggetti WAR_PlanningLine */ ],
    "PageConfig": [ /* Configurazione della pagina */ ]
  }
}
```

---

