# Analisi del Ciclo di Vita degli Oggetti Bin nel Sistema WEC

## Stato Attuale del Sistema

### Struttura WAR_BinEntry

La classe `WAR_BinEntry` rappresenta i movimenti fisici di articoli nelle collocazioni del magazzino. I campi principali sono:

- **EntryID**: ID univoco del movimento
- **ItemNo**: Codice articolo
- **BinNo**: Collocazione corrente  
- **OriginalBinNo**: Collocazione di origine del movimento
- **Quantity**: Quantità del movimento (può essere negativa per scarichi)
- **RemainingQuantity**: Quantità residua disponibile
- **OriginalQuantity**: Quantità originale dell'operazione
- **LinkEntryNo**: Riferimento al movimento precedente nella catena
- **LoadEntryNo**: Riferimento al carico originale
- **Type**: Tipo di movimento (Loading, Movement, Consumption, etc.)
- **Transit**: Flag che indica se l'articolo è in transito

### Struttura WAR_ItemLedgerEntry (ILE)

La classe `WAR_ItemLedgerEntry` rappresenta le giacenze fiscali del magazzino:

- **EntryID**: ID univoco della registrazione fiscale
- **ItemNo**: Codice articolo
- **BinNo**: Collocazione di riferimento
- **Quantity**: Quantità della registrazione fiscale
- **EntryType**: Tipo registrazione (PositiveAdjmt, NegativeAdjmt, etc.)
- **LinkEntryNo**: Campo presente ma non utilizzato correttamente

## Problemi Identificati

### 1. Inconsistenze nel Tracking delle Catene di Movimento

**Problema**: I campi `LinkEntryNo` e `LoadEntryNo` non sono utilizzati in modo coerente. In alcune operazioni vengono popolati, in altre no.

**Esempio**: Nel metodo `HandleAdjustmentBinEntryFromILE`:
```csharp
UnloadNewEntry.LoadEntryNo = UnloadNewEntry.LinkEntryNo = OrigLoadEntry.EntryID;
```

Ma in altri punti del codice questi campi rimangono nulli o inconsistenti.

### 2. Disconnessione tra BinEntry e ILE

**Problema**: Le `WAR_ItemLedgerEntry` dovrebbero riferire le `WAR_BinEntry` che le hanno generate, ma il collegamento non è implementato correttamente.

**Situazione attuale**: 
- Le ILE hanno un campo `LinkEntryNo` ma non viene utilizzato per collegare alle BinEntry
- Le BinEntry hanno un campo `ILENo` che viene popolato solo in alcuni casi

### 3. Tracking del Ciclo di Vita Incompleto

**Problema**: Non è possibile tracciare facilmente il percorso completo di un articolo dal momento del carico iniziale fino alla sua uscita dal magazzino.

## Proposta di Miglioramento

### 1. Ristrutturazione del Sistema di Linking

#### WAR_BinEntry
- **LoadEntryNo**: Sempre riferimento al primo carico originale dell'articolo
- **LinkEntryNo**: Riferimento al movimento precedente nella catena FIFO
- **ILENo**: Riferimento alla ILE che ha generato questo movimento (quando applicabile)

#### WAR_ItemLedgerEntry  
- **LinkEntryNo**: Riferimento alla BinEntry rappresentativa del movimento
- Nuovo campo **PrimaryBinEntryNo**: Riferimento alla BinEntry principale che ha generato questa ILE

### 2. Metodi di Tracking Migliorati

#### Nella classe WARBinEntry:

```csharp
public class WARBinEntry
{
    /// <summary>
    /// Crea una nuova entry per un articolo caricato ex-novo nel magazzino
    /// </summary>
    public WAR_BinEntry CreateInitialLoad(DBK_SuiteEntities db, string itemNo, string binNo, decimal quantity, JSWarRequest request)
    {
        var entry = new WAR_BinEntry
        {
            // Campi standard...
            LoadEntryNo = null,     // È il carico originale
            LinkEntryNo = null,     // Primo movimento della catena
            ILENo = null           // Verrà popolato quando si crea la ILE corrispondente
        };
        
        db.WAR_BinEntry.Add(entry);
        db.SaveChanges(); // Per ottenere EntryID
        
        // Auto-riferimento come carico originale
        entry.LoadEntryNo = entry.EntryID;
        db.SaveChanges();
        
        return entry;
    }

    /// <summary>
    /// Crea movimenti per spostare articoli tra collocazioni (senza impatto fiscale)
    /// </summary>
    public List<WAR_BinEntry> CreateMovementChain(DBK_SuiteEntities db, string itemNo, string fromBin, string toBin, decimal quantity, JSWarRequest request)
    {
        var result = new List<WAR_BinEntry>();
        
        // FIFO: preleva dai carichi più vecchi
        var sourceEntries = db.WAR_BinEntry
            .Where(be => be.ItemNo == itemNo && be.BinNo == fromBin && be.RemainingQuantity > 0)
            .OrderBy(be => be.InsertDateTime)
            .ToList();
        
        decimal remaining = quantity;
        foreach (var source in sourceEntries)
        {
            if (remaining <= 0) break;
            
            var moveQty = Math.Min(source.RemainingQuantity, remaining);
            
            // Scarico dalla collocazione origine
            var unload = new WAR_BinEntry
            {
                // Mantiene la catena di tracking
                LoadEntryNo = source.LoadEntryNo ?? source.EntryID,
                LinkEntryNo = source.EntryID,
                Quantity = -moveQty,
                RemainingQuantity = 0,
                Type = (int)EC.BinEntryType.Movement
                // Altri campi...
            };
            
            // Carico nella collocazione destinazione  
            var load = new WAR_BinEntry
            {
                // Mantiene la catena di tracking
                LoadEntryNo = source.LoadEntryNo ?? source.EntryID,
                LinkEntryNo = source.EntryID,
                Quantity = moveQty,
                RemainingQuantity = moveQty,
                Type = (int)EC.BinEntryType.Movement
                // Altri campi...
            };
            
            source.RemainingQuantity -= moveQty;
            remaining -= moveQty;
            
            result.AddRange(new[] { unload, load });
        }
        
        return result;
    }

    /// <summary>
    /// Traccia il ciclo di vita completo di un articolo
    /// </summary>
    public List<WAR_BinEntry> TraceItemLifecycle(DBK_SuiteEntities db, long entryId)
    {
        var entry = db.WAR_BinEntry.FirstOrDefault(be => be.EntryID == entryId);
        if (entry == null) return new List<WAR_BinEntry>();
        
        var rootId = entry.LoadEntryNo ?? entry.EntryID;
        
        // Tutti i movimenti collegati al carico originale, ordinati cronologicamente
        return db.WAR_BinEntry
            .Where(be => be.LoadEntryNo == rootId || be.EntryID == rootId)
            .OrderBy(be => be.InsertDateTime)
            .ToList();
    }
}
```

### 3. Gestione delle ILE Collegate

```csharp
public class WARItemLedgerEntry
{
    /// <summary>
    /// Crea ILE con collegamento corretto alla BinEntry
    /// </summary>
    public WAR_ItemLedgerEntry CreateLinkedILE(DBK_SuiteEntities db, WAR_BinEntry primaryBinEntry, decimal fiscalQuantity, string resourceId, string deviceName)
    {
        var ile = new WAR_ItemLedgerEntry
        {
            ItemNo = primaryBinEntry.ItemNo,
            BinNo = primaryBinEntry.BinNo,
            Quantity = fiscalQuantity,
            LinkEntryNo = primaryBinEntry.EntryID,  // Collegamento alla BinEntry principale
            // Altri campi...
        };
        
        db.WAR_ItemLedgerEntry.Add(ile);
        db.SaveChanges();
        
        // Aggiorna la BinEntry con il riferimento alla ILE
        primaryBinEntry.ILENo = ile.EntryID;
        db.SaveChanges();
        
        return ile;
    }
}
```

## Flussi di Esempio

### 1. Carico ex-novo
```
1. Articolo X arriva → CreateInitialLoad()
   BinEntry: ID=100, LoadEntryNo=100, LinkEntryNo=null, Quantity=10, RemainingQuantity=10
   
2. Creazione ILE fiscale → CreateLinkedILE()
   ILE: ID=200, LinkEntryNo=100, Quantity=10
   BinEntry aggiornata: ILENo=200
```

### 2. Spostamento tra collocazioni
```
1. Spostamento 5 pz da BIN-A a BIN-B → CreateMovementChain()
   
   Scarico: ID=101, LoadEntryNo=100, LinkEntryNo=100, Quantity=-5, RemainingQuantity=0
   Carico: ID=102, LoadEntryNo=100, LinkEntryNo=100, Quantity=5, RemainingQuantity=5
   
   BinEntry originale: RemainingQuantity=5
   
   Nessuna ILE creata (movimento interno senza impatto fiscale)
```

### 3. Uscita dal magazzino
```
1. Prelievo 3 pz per spedizione → CreateItemRemoval()
   
   Consumo: ID=103, LoadEntryNo=100, LinkEntryNo=102, Quantity=-3, RemainingQuantity=0
   BinEntry 102: RemainingQuantity=2
   
2. Creazione ILE fiscale negativa → CreateLinkedILE()
   ILE: ID=201, LinkEntryNo=103, Quantity=-3
   BinEntry 103: ILENo=201
```

## Vantaggi della Proposta

1. **Tracciabilità Completa**: Ogni articolo può essere tracciato dal carico iniziale all'uscita
2. **Coerenza FIFO**: I movimenti rispettano sempre l'ordine cronologico
3. **Separazione Fiscale/Fisica**: Le ILE registrano solo le variazioni fiscali, le BinEntry tutti i movimenti fisici
4. **Collegamento Bidirezionale**: ILE ↔ BinEntry con riferimenti corretti
5. **Debugging Semplificato**: La catena di movimenti è facilmente ricostruibile

## Implementazione

### Fase 1: Correzione dei Metodi Esistenti
- Aggiornare `HandleAdjustmentBinEntryFromILE` per popolare correttamente i campi di linking
- Modificare `CreateLoadAndUnloadRows` per mantenere la catena FIFO
- Correggere tutti i punti dove vengono create BinEntry senza linking

### Fase 2: Nuovi Metodi di Utilità
- Implementare `TraceItemLifecycle`
- Implementare `GetAvailableQuantityByOriginalLoad`
- Aggiungere metodi di validazione della coerenza delle catene

### Fase 3: Migrazione Dati Esistenti
- Script per ricostruire i LinkEntryNo mancanti basandosi sui timestamp
- Validazione della coerenza dopo la migrazione

### Valutazione dell'Approccio Proposto

Il tuo approccio di base è corretto:
- ✅ BinEntry per tracciare posizioni fisiche
- ✅ ILE per giacenze fiscali
- ✅ Collegamento tramite LinkEntryNo

Tuttavia, consiglio questi miglioramenti:
- **LoadEntryNo** sempre riferito al carico originale (non al movimento precedente)
- **Collegamento bidirezionale** ILE ↔ BinEntry
- **Metodi standardizzati** per tutti i tipi di movimento
- **Validazione della catena** ad ogni operazione

Il sistema risultante sarà più robusto, tracciabile e manutenibile.