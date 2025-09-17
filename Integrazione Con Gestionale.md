# Documentazione WARExternalController  

## GetAllInventoryEntries

### `/api/WARExternal/GetAllInventoryEntries`

**Spiegazione Dettagliata:** Restituisce tutte le voci di inventario presenti nella tabella WAR_InventoryEntry. È un'operazione di sola lettura che non modifica alcun dato nel database.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/GetAllInventoryEntries`

**Body:**

```json
(empty body)
```

**Postman Response:**

```
(da compilare dopo il test)
```

---

## ConfirmEntry

### `/api/WARExternal/ConfirmEntry`

**Spiegazione Dettagliata:** Marca una voce di inventario specifica come confermata impostando il flag `isConfirmed = true`. Richiede l'ID della voce da confermare.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/ConfirmEntry`

**Body:**

```json
1
```

_Nota: Passare direttamente l'ID come numero intero nel body_

**Postman Response:**

```
(da compilare dopo il test)
```

---

## CreateExternalOrder

### `/api/WARExternal/CreateExternalOrder`

**Spiegazione Dettagliata:** Crea un nuovo ordine in ingresso generato da un sistema esterno. L'endpoint genera automaticamente un ID ordine, crea l'header di pianificazione e le righe associate per ogni articolo specificato. Valida la presenza degli articoli nel sistema prima della creazione.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/CreateExternalOrder`

**Body:**

```json
{
  "VendorNo": "VENDOR001",
  "DocumentNo": "DOC123",
  "LocationNo": "MAIN",
  "Items": [
    {
      "ItemNo": "ITEM001",
      "Description": "Pezzo A",
      "Quantity": 10.0,
      "LotNo": "LOT123",
      "SerialNo": "SN001"
    },
    {
      "ItemNo": "ITEM002",
      "Quantity": 5.5
    }
  ]
}
```

**Postman Response:**

```
(da compilare dopo il test)
```

---

## CompleteExternalOrderReceipt

### `/api/WARExternal/CompleteExternalOrderReceipt`

**Spiegazione Dettagliata:** Completa la ricezione fisica di un ordine esterno. Crea le entry nel bin per le quantità ricevute, traccia le discrepanze in WAR_InventoryEntry e imposta l'ordine in stato "WAITINGCONFIRMATION". Confronta le quantità attese con quelle effettivamente ricevute.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/CompleteExternalOrderReceipt`

**Body:**

```json
{
  "OrderNo": "ORD-20250911-001",
  "RequestDevice": "ExternalAPI",
  "RequestResourceID": "EXTERNAL",
  "ReceivedItems": [
    {
      "OrderLineID": 1,
      "ReceivedQuantity": 10,
      "LotNo": "LOT123",
      "SerialNo": "SN001"
    },
    {
      "OrderLineID": 2,
      "ReceivedQuantity": 4
    }
  ]
}
```

**Postman Response:**

```
(da compilare dopo il test)
```

---

## GetOrdersToConfirm

### `/api/WARExternal/GetOrdersToConfirm`

**Spiegazione Dettagliata:** Recupera tutti gli ordini in stato "WAITINGCONFIRMATION" che necessitano di conferma. Per ogni ordine fornisce un riepilogo delle righe (quantità attese vs ricevute) e le entry di inventario non ancora confermate.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/GetOrdersToConfirm`

**Body:**

```json
(empty body)
```

**Postman Response:**

```
(da compilare dopo il test)
```

---

## ConfirmExternalOrder

### `/api/WARExternal/ConfirmExternalOrder`

**Spiegazione Dettagliata:** Finalizza un ordine dopo la ricezione, permettendo di approvare o rifiutare le discrepanze trovate. Se approvato, crea le entry nel ledger articoli e completa l'ordine. Se rifiutato, resetta l'ordine allo stato iniziale rimuovendo le discrepanze registrate.

**Esempio pratico:**

**Method:** POST

**Endpoint:** `/api/WARExternal/ConfirmExternalOrder`

**Body:**

```json
{
  "OrderNo": "ORD-123",
  "ApproveDiscrepancies": true,
  "ConfirmationNotes": "OK, approvato"
}
```

**Postman Response:**

```
(da compilare dopo il test)
```

---

## Note Generali

- **Autenticazione:** Tutti gli endpoint sono configurati con `[AllowAnonymous]`
- **Content-Type:** Utilizzare sempre `application/json` negli header
- **Errori:** Gli errori di validazione ritornano HTTP 400 con messaggio descrittivo
- **Successo:** Le operazioni riuscite ritornano HTTP 200 con payload strutturato