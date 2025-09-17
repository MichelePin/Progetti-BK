---
Progetto: WSpace
Linguaggio: CSharp
Tipo: Code-File
Ultima Modifica: 2025-08-05
Categoria: Endpoint
Argomento: Inventario
Versione: 2.60.4
---
**Tags**

#WSpace #CSharp #Code #WEC #rettifiche #endpoint #Ordini #Inventario  #v2604 #spiegazione 

# Endpoint `PostInventoryAdjustment`

--- 

```table-of-contents
maxLevel: 2
minLevel: 2
```

---


## Spiegazione dettagliata

L’endpoint `PostInventoryAdjustment` consente di registrare una rettifica di magazzino in modo semplificato. Riceve esattamente gli stessi parametri dell’endpoint `PostStockAdjustment` (oggetto `JSStockAdjustment`), ma si limita a creare una nuova riga nella tabella `WAR_InventoryEntry` senza effettuare controlli avanzati o aggiornamenti accessori.

## Flusso principale:

1. **Ricezione Parametri:**  
   L’endpoint riceve un oggetto `JSStockAdjustment` con tutte le informazioni necessarie (articolo, quantità, collocazione, ecc.).

2. **Validazione Minima:**  
   Viene verificata solo la presenza dei dati essenziali (`ItemLedgerEntry`, `ItemNo`, `LocationNo`). In caso di dati mancanti, viene restituito un errore.

3. **Registrazione Rettifica:**  
   Viene creato un nuovo oggetto `WAR_InventoryEntry` con i dati ricevuti.  
   - Non vengono effettuati controlli su permessi, regole di business, o coerenza con la giacenza.
   - Non vengono aggiornati log, imballi, bin o altre tabelle accessorie.
   - L’operazione viene marcata come confermata e di tipo “rettifica”.

4. **Risposta:**  
   L’oggetto restituito è identico a quello dell’endpoint `PostStockAdjustment`:
   - `BinBoxOperationResponse`: oggetto vuoto (non gestito qui)
   - `ILE`: la riga di rettifica ricevuta in input
   - `InventoryRow`: oggetto con articolo, magazzino, lotto e quantità rettificata
   - `WarningList`: lista vuota

## Note aggiuntive:
- L’endpoint è pensato per essere un sostituto diretto e trasparente di `PostStockAdjustment` lato front-end, senza necessità di modifiche nei parametri o nella gestione della risposta.
- Non vengono gestite transazioni complesse, rollback, o controlli di sicurezza: la rettifica viene semplicemente registrata così come ricevuta.

## ChangeLog
### 2.60.4
- Creato

---

## Codice 

```cs ccp fold title:PostInventoryAdjustment
        [HttpPost]

        public object PostInventoryAdjustment(JSInventoryAdjustment Adjustment)

        {
        try

            {

                string resourceId = Adjustment?.RequestParams?.RequestResourceID;

                string deviceName = Adjustment?.RequestParams?.RequestDevice;

                var ile = Adjustment?.ItemLedgerEntry;

                if (ile == null || string.IsNullOrWhiteSpace(ile.ItemNo) )

                    return BadRequest("Missing required ItemLedgerEntry data.");

  

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                {

                    var entry = new WAR_InventoryEntry

                    {

                        EntryID = Guid.NewGuid().ToString(),

                        InsertDateTime = DateTime.Now,

                        OrderNo = "ManualAdjustment",

                        OrderLineID = "ManualAdjustment" + DateTime.Now.Ticks,

                        FromBinNo = Adjustment.BinEntry?.BinNo ?? "",

                        ItemNo = ile.ItemNo,

                        ResourceNo = resourceId ?? "",

                        ActionPerformed = InventoryEntryOperation.ADJUSTED,

                        IsManualEntry = true   ,

                        AdjustmentQuantity = ile.AdjustmentQuantity,

                        CustDate1 = DateTime.Now

                    };

                    db.WAR_InventoryEntry.Add(entry);

                    db.SaveChanges();

  

                    // Compose the response object to match PostStockAdjustment

                    var response = new

                    {

                        BinBoxOperationResponse = new { }, // Empty, as not managed here

                        ILE = ile,

                        InventoryRow = new

                        {

                            ItemID = ile.ItemNo,

                            BinNo = ile.FromBinNo,

                            Quantity = ile.AdjustmentQuantity

                        },

                        WarningList = new List<string>()

                    };

                    return JObject.FromObject(response);

                }

            }

            catch (Exception e)

            {

                return BadRequest(Message.ErrorOutput(e, "PostInventoryAdjustment", Adjustment?.RequestParams?.RequestDevice));

            }

        }

    }
```

