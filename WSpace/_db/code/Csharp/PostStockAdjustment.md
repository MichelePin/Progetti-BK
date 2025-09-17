---
Progetto: WSpace
Linguaggio: CSharp
Tipo: Code-File
Ultima Modifica: 2025-08-05
Categoria: Endpoint
Argomento: Giacenze
Versione: 2.60.4
---
**Tags**

#WSpace #CSharp #Code #WEC #Giacenze #endpoint  

---
# Endpoint `PostStockAdjustment` 
```table-of-contents
maxLevel: 2
minLevel: 2
```


## Introduzione

L’endpoint `PostStockAdjustment` gestisce l’inserimento di una rettifica di magazzino (stock adjustment) nel sistema WEC. Questo metodo riceve in input un oggetto `JSStockAdjustment` che contiene tutte le informazioni necessarie per eseguire la rettifica, come l’articolo, la quantità, la collocazione (bin), eventuali dati di imballo e parametri di richiesta.

## Flusso principale:

1. **Validazione Input:**  
    Vengono controllati la presenza e la correttezza dei dati fondamentali (articolo, magazzino, risorsa, ecc.). Se mancano dati essenziali, viene restituito un errore.
    
2. **Recupero regole e setup:**  
    Si recuperano le regole di business e le impostazioni di magazzino per la risorsa/dispositivo corrente. Vengono verificati i permessi per eseguire rettifiche e la presenza dell’articolo in anagrafica.
    
3. **Gestione modalità di rettifica:**  
    In base alla configurazione e alla provenienza della rettifica (da collocazione o meno), viene calcolata la quantità da rettificare, tenendo conto della giacenza attuale e della modalità di inventario impostata.
    
4. **Controlli di coerenza:**  
    Si verifica che la rettifica non porti la giacenza in negativo e che rispetti le regole di permesso (es. blocco rettifiche positive/negative/zero).
    
5. **Transazione e scrittura dati:**  
    All’interno di una transazione vengono:
    
    - Inseriti o aggiornati i movimenti di rettifica (`ItemLedgerEntry`)
    - Inserita una riga di log della rettifica
    - Aggiornate eventuali unità inventariali (imballi, bin, ecc.)
    - Gestite le operazioni di creazione/aggiornamento imballo se richiesto
6. **Controlli post-scrittura:**  
    Dopo la rettifica, viene verificata la coerenza tra i movimenti e i log, e vengono restituite eventuali segnalazioni di warning.
    
7. **Risposta:**  
    Viene restituito l’oggetto della rettifica, eventuali dati di imballo creati/aggiornati e la riga di inventario aggiornata.
    

##  Note aggiuntive:

- L’endpoint gestisce sia rettifiche standard che rettifiche da collocazione, con logiche specifiche per la gestione di imballi.
- Tutte le operazioni critiche sono protette da transazione per garantire la coerenza dei dati.
- Sono presenti numerosi controlli di sicurezza e coerenza per evitare errori di inventario e garantire la tracciabilità delle operazioni.


# Codice 
```CSharp cpp fold title:PostStockAdjustment 
        [HttpPost]

        public object PostStockAdjustment(JSStockAdjustment Adjustment)

        {

            string Where = "PostStockAdjustment";

  

            try

            {

                string ResourceID = Adjustment?.RequestParams?.RequestResourceID;

                string DeviceName = Adjustment?.RequestParams?.RequestDevice;

  

                if (Adjustment?.InfoItem == null) SCL.Utility.ErrorOutput("Non è stato ricevuta la riga di inventario da rettificare!", "PostStockAdjustment");

  

                if (Adjustment?.ItemLedgerEntry == null) SCL.Utility.ErrorOutput("Non è stato ricevuta la riga di rettifica!", "PostStockAdjustment");

                if (string.IsNullOrWhiteSpace(Adjustment?.ItemLedgerEntry.ItemNo)) SCL.Utility.ErrorOutput("Non è stato ricevuto l'articolo!", "PostStockAdjustment");

                if (string.IsNullOrWhiteSpace(Adjustment?.ItemLedgerEntry.LocationNo)) SCL.Utility.ErrorOutput("Non è stato ricevuto il magazzino!", "PostStockAdjustment");

                if (string.IsNullOrWhiteSpace(ResourceID)) SCL.Utility.ErrorOutput("Non è stato ricevuta la risorsa!", "PostStockAdjustment");

  

                List<string> WarningList = new List<string>();

  

                decimal AdjstQuantity = 0;

  

                // 2.3.0.371 #24013: oggetto valorizzato solo nel caso in cui la rettifica sia effettuata a partire da una collocazione con gestione di un imballo.

                BinBoxOperationResponse BinBoxOperationResponse = new BinBoxOperationResponse();

  

                WAR_ItemLedgerEntry ILE = Adjustment.ItemLedgerEntry;

                string ItemNo = ILE.ItemNo;

                string LotNo = ILE.LotNo;

  

                bool LotPosted = !string.IsNullOrEmpty(LotNo);

  

                // 2.3.0.369 #24013: Si verifica se la rettifica proviene dalla collocazione e si inizializzino variabili di utilità.

                var BinEntry = Adjustment.BinEntry;

  

                bool FromBinEntry = Adjustment.BinEntry != null;

  

                // 2.3.0.371 #24013: si gestisce il nuovo caso di creazione dell'imballo in collocazione con la rettifica.

                // Si blocca al momento la creazione di un imballo per un articolo gestito a lotti.

                // Dovrebbe essere rivista la logica funzionale per gestirlo e verificare bene i lotti e gli imballi anche nel resto delle pagine,

                // in particolare per lo spostamento manuale.

                bool IsCreatingBox = !string.IsNullOrEmpty(Adjustment.NewBoxModelID);

                if (IsCreatingBox && !FromBinEntry) SCL.Utility.ErrorOutput("La creazione dell'imballo deve partire da una collocazione!", Where);

                // 2.3.0.373 #25004 2G): si rimuove il blocco sulla gestione di un articolo a lotti nell'imballo, che è ora possibile.

                // if (IsCreatingBox && (LotPosted || !string.IsNullOrEmpty(BinEntry.LotNo)))

  

                // 2.3.0.320 #24062: Introdotta la transazione per consentire di salvare nel record di log il riferimento all'ILE.

                // È la soluzione più logica al problema che si aveva di doverla recuperare in via di cancellazione.

                // Il metodo senza blocco poteva essere quello di creare un record "sporco" di ILE,

                // salvare il db per avere l'id e modificare i dati in seguito, senza dover usare la transazione.

                // Un eventuale errore successivo avrebbe prodotto semplicemente un record "sporco".

                // Questa soluzione costringe però a dover scrivere codice più contorto.

                // 2.3.0.369 #24013: La transazione viene utilizzata anche per salvare in un solo passaggio le modifiche eventuali alla WAR_BinEntry.

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                using (var transaction = db.Database.BeginTransaction())

                {

                    // Si prende il gruppo di regole.

                    WAR_Rule Rule = WSpaceUtility.GetWSpaceRule(db, DeviceName, ResourceID);

                    if (Rule.DisableAdjustments) SCL.Utility.MessageOutput("Non hai il permesso per fare rettifiche!");

  

                    // Si controlla per sicurezza che l'articolo sia presente in anagrafica.

                    WAR_Item Item = db.WAR_Item.FirstOrDefault(i => i.ItemID == ItemNo);

                    if (Item == null) SCL.Utility.ErrorOutput("L'articolo non è stato trovato in anagrafica!", "PostStockAdjustment");

  

                    WAR_Setup Setup = db.WAR_Setup.First();

  

                    // 2.3.0.52: In base al setup si verifica se l'articolo richiede la tracciatura.

                    if (Setup.ForceTrackingMode == (int)EC.ForceTrackingMode.CheckLotAllItems)

                    {

                        if (Item.IsLotTracking && !LotPosted) SCL.Utility.MessageOutput("L'articolo richiede l'inserimento di un lotto!");

                        if (!Item.IsLotTracking && LotPosted) SCL.Utility.MessageOutput("L'articolo non è gestito a lotti!");

                    }

  

                    decimal WSpaceQuantity = ILE.Quantity;

                    decimal CurrentQuantity = 0;

  

                    var GDBBinEntry = new GDB.WARBinEntry();

  

                    List<WAR_BinEntry> ActualBinItemData = new List<WAR_BinEntry>();

  

                    // 2.3.0.369 #24013: Si gestisce anche il caso di rettifica proveniente dalla collocazione per il calcolo della giacenza attuale.

                    if (FromBinEntry)

                    {

                        // Si verificano i dati passati dalla riga di collocazione dalla quale è partita la rettifica.

                        if (string.IsNullOrEmpty(BinEntry.BinNo)) SCL.Utility.ErrorOutput("Collocazione non presente!", Where);

                        if (string.IsNullOrEmpty(BinEntry.ZoneNo)) SCL.Utility.ErrorOutput("Zona non presente!", Where);

                        if (string.IsNullOrEmpty(BinEntry.LocationNo)) SCL.Utility.ErrorOutput("Magazzino non presente!", Where);

  

                        var Req = new JSWarRequest { LocationNo = BinEntry.LocationNo, ZoneNo = BinEntry.ZoneNo };

  

                        // 2.3.0.371 #24013: Nel caso di creazione di un nuovo imballo, il contenuto della collocazione è indifferente e non sarà mai

                        // toccato (si sta creando un nuovo imballo e non interagendo con la giacenza già presente).

                        if (!IsCreatingBox)

                        {

                            ActualBinItemData = GDBBinEntry.GetBinItemList(db, Req, BinEntry.BinNo, FilterItemNo: BinEntry.ItemNo)

                                .Where(a => GDBBinEntry.IsSuitable(a, BinEntry) && a.RemainingQuantity > 0).ToList();

                        }

  

                        // Si verifica che la quantità giacente in collocazione sia la stessa che vede l'utente, per evitare di operare su dati non aggiornati.

                        var NewBinQuantity = LinqUtility.Sum(ActualBinItemData, a => a.RemainingQuantity);

  

                        CurrentQuantity = BinEntry.RemainingQuantity;

                        if (NewBinQuantity != CurrentQuantity)

                        {

                            SCL.Utility.MessageOutput("La quantità presente nella collocazione è stata aggiornata. Ricaricare la pagina!");

                        }

                    }

                    // Rettifica standard a partire dall'InfoItem

                    else

                    {

                        // 2.3.0.52: Si controlla anche il lotto.

                        WARVIR_InfoItem CurrentInventory = GetInfoItemFromILE(db, ILE);

  

                        // La riga di inventario può essere null se non ho giacenza per un magazzino e articolo specifico.

                        CurrentQuantity = CurrentInventory != null ? CurrentInventory.Quantity : 0;

                    }

  

                    int InventoryMode = Setup.InventoryMode;

  

                    // Cambia la modalità di registrazione, la quantità inserita nell'ILE dal WSpace è quella digitata dall'operatore.

                    // Ci pensa il WEC a calcolare la quantità della rettifica, inserendo i campi aggiuntivi.

                    // 2.3.0.369 #24013: Si gestisce anche per la rettifica creata dalla collocazione il calcolo della quantità di rettifica sulla base della giacenza attuale nella collocazione

                    // e della nuova giacenza nella collocazione inserita dall'utente (e scritta in ILE.Quantity).

                    if (FromBinEntry) InventoryMode = (int)SCL.EC.InventoryMode.TotalQuantity;

  

                    if (InventoryMode == (int)SCL.EC.InventoryMode.TotalQuantity || InventoryMode == (int)SCL.EC.InventoryMode.SumQuantityAsTotal)

                    {

                        // Si calcola il valore della quantità corrente e si calcola la rettifica in base a quella (non

                        // rispetto a quello che vedeva l'operatore quando ha fatto la rettifica.

                        // 2.3.0.369 #24013: Si gestisce la stessa modalità anche se si proviene da una collocazione.

                        if (InventoryMode == (int)SCL.EC.InventoryMode.TotalQuantity) ILE.Quantity = WSpaceQuantity - CurrentQuantity;

  

                        else ILE.Quantity = WSpaceQuantity + Adjustment.InfoItem.Quantity - CurrentQuantity;

                    }

  

                    decimal OriginalAdjstQuantity = ILE.Quantity;

  

                    decimal NewInventory = CurrentQuantity + ILE.Quantity;

  

                    // Se la giacenza va in negativo si fa un'autocorrezione.

                    // 2.3.0.320 #24062: Si blocca ora l'autocorrezione, non è possibile avere giacenza negativa e si blocca la rettifica, senza introdurre per ora un setup.

                    if (NewInventory < 0)

                    {

                        SCL.Utility.MessageOutput($"Non è possibile effettuare la rettifica in quanto si avrebbe una giacenza negativa ({NewInventory}) per l'articolo!");

                        // 2.3.0.320 #24062: bloccata l'autocorrezione;

                    }

  

                    // Se Setup.InventoryMode == (int)SCL.EC.InventoryMode.SumQuantityAsILE la quantità inserita viene inserita come rettifica

                    // senza controllare la giacenza attuale o quella che si aveva al momento dell'inventario.

  

                    AdjstQuantity = ILE.Quantity;

                    int AdjstEntryType = (int)(AdjstQuantity >= 0 ? SCL.EC.EntryTypeILE.PositiveAdjmt : SCL.EC.EntryTypeILE.NegativeAdjmt);

  

                    DateTime Now = DateTime.Now;

  

                    // Dati fissi

                    ILE.DeviceName = DeviceName;

                    ILE.PostingDate = Now.Date;

                    ILE.ResourceNo = ResourceID;

                    ILE.SerialNo = null;

  

                    // La rettifica nulla ora non viene bloccata, si scrive il Log ma non l'ILE. Se il setup blocca la rettifica negativa invece

                    // si restituisce l'errore, dopo aver scritto il log.

                    // 2.3.0.320 #24062: EDIT: Si verificano ora tutti i permessi sulla rettifica e si blocca subito in caso di errore, senza scrivere alcun log.

                    // Si gestisce anche un setup per bloccare le rettifiche positive.

  

                    if (OriginalAdjstQuantity == 0 && Rule.DisableEmptyAdjustments) SCL.Utility.MessageOutput("Il setup non consente di fare rettifiche a quantità 0!");

                    if (OriginalAdjstQuantity > 0 && Rule.DisablePositiveAdjustments) SCL.Utility.MessageOutput("Il setup non consente di fare rettifiche con quantità positiva!");

                    if (OriginalAdjstQuantity < 0 && Rule.DisableNegativeAdjustments) SCL.Utility.MessageOutput("Il setup non consente di fare rettifiche con quantità negativa!");

  

                    // Dati fissi

                    ILE.EntryType = (int)(ILE.Quantity > 0 ? SCL.EC.EntryTypeILE.PositiveAdjmt : SCL.EC.EntryTypeILE.NegativeAdjmt);

  

                    WSpaceUtility.AddILEOrReplace(db, ILE, Adjustment.InfoItem.Quantity);

  

                    // 2.3.0.320 #24062: Con l'introduzione della transazione, si inserisce in questo punto il salvataggio del db per validare l'id della rettifica inserita.

                    db.SaveChanges();

  

                    // Si inserisce una riga di log della rettifica.

  

                    WAR_ItemLedgerEntryLog Log = SCL.Utility.Cast<WAR_ItemLedgerEntryLog>(ILE);

  

                    Log.PreviousTotalQuantity = Adjustment.InfoItem.Quantity;

                    Log.Quantity = AdjstQuantity;

                    Log.EntryType = AdjstEntryType;

                    Log.PostingDate = Now.Date;

                    Log.PostingTime = Now.TimeOfDay;

                    if (Adjustment.InventoryBin != null) Log.InventoryBinNo = Adjustment.InventoryBin.ID;

                    Log.WSpaceQuantity = WSpaceQuantity;

                    // 2.3.0.320 #24062: Si valorizza il riferimento al movimento di rettifica.

                    Log.LinkEntryNo = ILE.EntryID;

  

                    WSpaceUtility.AddLog(db, Log);

  

                    // Il metodo AddILEOrReplace potrebe aver modificato la quantità dell'ILE. Si riporta quindi il campo al valore originale della rettifica,

                    // senza contare un possibile aggiornamento dovuto all'aggregazione con precedenti ILE.

                    ILE.Quantity = AdjstQuantity;

  

                    // Se viene passata un'unità inventariale si fa la registrazione.

                    if (Adjustment.InventoryBin != null)

                    {

                        // Se l'unità inventariale è già presente non si restituisce un errore dalla funzione di rettifica.

  

                        WAR_InventoryBin IB = Adjustment.InventoryBin;

  

                        WAR_InventoryBin dbInventoryBin = db.WAR_InventoryBin.FirstOrDefault(i => i.ItemNo == IB.ItemNo && i.LocationID == IB.LocationID && i.ID == IB.ID);

  

                        if (dbInventoryBin == null) InventoryBin.AddItemToInventoryBin(db, Adjustment.InventoryBin);

                    }

  

                    // 2.3.0.369 #24013: Se la rettifica proviene da una collocazione si allinea la giacenza presente in collocazione.

                    // Sono state caricate all'inizio della funzione le righe di articolo presenti in collocazione ed effettuati i controlli di congruenza.

                    if (FromBinEntry)

                    {

                        // 2.3.0.371 #24013: se è stata richiesta da collocazione la creazione di un nuovo imballo (la funzione di creazione dell'imballo è stata unificata)

                        // la quantità di rettifica deve essere necessariamente positiva.

                        if (IsCreatingBox && ILE.Quantity <= 0) SCL.Utility.ErrorOutput("Quantità di rettifica non valida per la creazione di un imballo!", Where);

  

                        var NewBinEntries = GDBBinEntry.HandleAdjustmentBinEntryFromILE(db, ILE, BinEntry, ActualBinItemData, ResourceID, DeviceName);

  

                        // 2.3.0.371 #24013: gestione del caso della creazione dell'imballo.

                        if (IsCreatingBox)

                        {

                            // Controlli di sicurezza, non dovrebbero mai servire per come vengono create le righe di WAR_BinEntry, ma aggiunti per prudenza.

                            // Ci si aspetta che venga creato un singolo movimento di carico in quanto si sta facendo una rettifica positiva nel caso di imballo.

                            // Il movimento dovrà avere ovviamente una quantità positiva.                          

                            if (NewBinEntries?.Count != 1) SCL.Utility.ErrorOutput("Non è stata creata correttamente la lista di righe da aggiungere in collocazione!", Where);

  

                            var NewBinEntry = NewBinEntries[0];

  

                            if (NewBinEntry.Quantity <= 0) SCL.Utility.ErrorOutput("Trovata una quantità negativa nel movimento di collocazione!", Where);

  

                            // Si richiama la funzione utilizzata anche dallo spostamento della merce.

                            // Si deve passare un parametro per bloccare la creazione di una transizione (non può essere creata una seconda transazione, darebbe errore).

                            PackingManager.CreateBoxFromBinEntryList(db, Adjustment.RequestParams, Adjustment.NewBoxModelID, BinBoxOperationResponse, NewBinEntries, Rule, SkipTransaction: true);

                        }

  

                        // 2.3.0.372 #24013: gestione della modifica della quantità di imballo nel caso in cui la rettifica sia collegata ad un imballo.

                        if (!string.IsNullOrEmpty(BinEntry.BoxHeaderNo))

                        {

                            if (IsCreatingBox) SCL.Utility.ErrorOutput("Errore nella funzione, l'imballo è in fase di creazione!", Where);

                            // Si richiama la stessa funzione utilizzata anche dallo spostamento della merce.

                            // Come per il caso della creazione dell'imballo si deve passare un parametro per bloccare la creazione di una transizione.

                            PackingManager.UpdateBoxFromBinEntryList(db, Adjustment.RequestParams, BinEntry.BoxHeaderNo, BinBoxOperationResponse, NewBinEntries, Rule, Now, SkipTransaction: true);

                        }

                    }

  

                    db.SaveChanges();

  

                    // 2.3.0.320 #24062: Si completa in questo punto la transazione.

                    transaction.Commit();

                }

  

                // Una volta effettuata la rettifica si controlla il valore della quantità corrente inserita nell'ILE e nel Log.

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                {

                    WARVIR_InfoItem InventoryRow = GetInfoItemFromILE(db, ILE);

  

                    if (InventoryRow == null) SCL.Utility.ErrorOutput("Non è stata trovata la riga di inventario inserita!", "PostStockAdjustment");

  

                    // Si controlla che la quantità dell'ILE sia pari a quella inserita nel log.

                    // Il controllo può essere sbloccato o limitato al giorno corrente.

  

                    WAR_Setup Setup = db.WAR_Setup.First();

  

                    if (Setup.CheckLogQuantityMode != (int)SCL.EC.CheckLogQuantityMode.Disabled)

                    {

                        List<WAR_ItemLedgerEntry> ILEList = db.WAR_ItemLedgerEntry.Where(i =>

                                                            i.ItemNo == ILE.ItemNo &&

                                                            (i.EntryType == (int)SCL.EC.EntryTypeILE.PositiveAdjmt || i.EntryType == (int)SCL.EC.EntryTypeILE.NegativeAdjmt)

                                                            ).ToList();

  

                        List<WAR_ItemLedgerEntryLog> ILELogList = db.WAR_ItemLedgerEntryLog.Where(i => i.ItemNo == ILE.ItemNo && string.IsNullOrEmpty(i.ErrorDescription)).ToList();

  

                        if (Setup.CheckLogQuantityMode == (int)SCL.EC.CheckLogQuantityMode.Day)

                        {

                            DateTime Today = DateTime.Now.Date;

  

                            ILEList = ILEList.Where(i => i.PostingDate == Today).ToList();

  

                            ILELogList = ILELogList.Where(i => i.PostingDate == Today).ToList();

                        }

  

                        decimal ILEQuantity = ILEList.Sum(i => i.Quantity);

  

                        decimal ILELogQuantity = ILELogList.Sum(i => i.Quantity);

  

                        if (ILEQuantity != ILELogQuantity) WarningList.Add($"Attenzione, ci sono movimenti non coerenti per l'articolo '{ILE.ItemNo}!");

                    }

  

                    // 2.3.0.65 [BKTD#3159]: Si restituisce il movimento di rettifica inserito. Viene inserita la quantità effettivamente rettificata.

                    ILE.Quantity = AdjstQuantity;

  

                    // 2.3.0.371 #24013: se la richiesta proviene da una collocazione, ed è stato creato un imballo, si restituiscono i dati.

                    if (IsCreatingBox)

                    {

                        BinBoxOperationResponse.BoxHeader = new GDB.WARBoxHeader().Get(db, BinBoxOperationResponse.UpdatedOrCreatedBoxNo);

                    }

  

                    return JObject.FromObject(new

                    {

                        // 2.3.0.371 #24013: si restituisce all'app anche il nuovo oggetto di risposta, valorizzato nel caso di operazioni effettuate negli imballi.

                        BinBoxOperationResponse,

                        ILE,

                        InventoryRow,

                        WarningList

                    });

                }

            }

            catch (Exception er)

            {

                return BadRequest(Message.ErrorOutput(er, "PostStockAdjustment"));

            }

        }

```

# Change Log
## 2.60.4 
Creato

