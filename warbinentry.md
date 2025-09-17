Documentazione: GDB.WARBinEntry (Italiano)
Panoramica
•	Scopo: utilità per la manipolazione e il tracciamento delle righe di magazzino (WAR_BinEntry). Fornisce CRUD, raggruppamento, redistribuzione FIFO, integrazione con ILE (Item Ledger Entry) e strumenti di validazione/repair della catena di tracciamento.
•	Ambito: layer GDB — lavora direttamente con DBK_SuiteEntities e le entità ABK.WAR_BinEntry, WAR_InventoryEntry, WAR_ItemLedgerEntry, WAR_PlanningINBin ecc.
•	Transazioni: la classe chiama db.SaveChanges() in vari punti; le chiamate multiple possono richiedere transaction esterne se si vuole atomicità su operazioni composte.
Principali responsabilità
•	Lettura/filtri: GetAll, GetList, GetQueryable, GetBinItemList, GetGroupedBinItemList.
•	Raggruppamento: GroupBinEntries, GetGroupedListWithTotalQuantity, GroupBinEntries overload.
•	Manipolazione fisica delle giacenze: CreateInitialLoad, CreateMovementChain, CreateItemRemoval, HandleAdjustmentBinEntryFromILE, RedistributeBinEntries, RedistributeFromInventoryEntries.
•	Integrazione contabile: CreateLinkedILE collega un ILE a una BinEntry e aggiorna ILENo.
•	Tracciamento FIFO: TraceItemLifecycle, ValidateTrackingChain, RepairTrackingChain, ValidateAllItems.
•	Utility e helper: AssignBoxReference, HasBoxReference, HasSameData, IsSuitable, SetFieldsFromRequest, GetAvailableQuantityByOriginalLoad, Test/validation helpers.
Metodi chiave (riepilogo)
•	GetQueryable(db, FilterWARBinEntry): costruisce IQueryable applicando filtri (Location, Bin, Item, Lot, Transit, testo contenuto). Usare per query composabili.
•	GetGroupedBinItemList(db, Request, ...): ottiene lista raggruppata (EXT_WAR_BinEntry) configurabile (group by bin/item/lot/box, include transit). Usa GroupBinEntries internamente.
•	GroupBinEntries(...): raggruppa per chiavi composite (BinNo, BoxHeaderNo, DeviceName quando transit, ItemNo, LotNo) e ritorna Dictionary<BinGroup, List<WAR_BinEntry>>.
•	GetGroupedListWithTotalQuantity(BinGroups): converte gruppi in EXT_WAR_BinEntry con somme, quantità in box, transit, _OriginalBinNoQty utile per UI.
•	CreateInitialLoad(db, itemNo, binNo, quantity, request, lotNo): crea nuova bin entry di inventario; imposta LoadEntryNo self-reference e salva.
•	CreateMovementChain(db, itemNo, fromBin, toBin, quantity, request): genera coppie unload/load rispettando FIFO, aggiorna RemainingQuantity delle source; salva.
•	CreateItemRemoval(db, itemNo, binNo, quantity, request, ...): consuma quantità FIFO creando consumption entries (type Consumption) con LinkEntryNo->source.
•	RedistributeBinEntries(db, entries): redistribuisce tra bin positivi/negativi per stesso item/lot; crea trasferimenti e aggiorna RemainingQuantity; salva.
•	HandleAdjustmentBinEntryFromILE(db, ILE, OriginalBinEntry, ActualBinItemData...): allinea bin a seguito di ILE (rettifica); crea bin entries di adjustment con corretto linking LoadEntryNo/LinkEntryNo; ritorna nuove entries (da aggiungere al DB).
•	CreateLinkedILE(db, primaryBinEntry, fiscalQuantity, resourceId, deviceName): crea WAR_ItemLedgerEntry collegato al primaryBinEntry e aggiorna ILENo della bin entry.
•	TraceItemLifecycle(db, entryId): ritorna tutta la sequenza di movimenti legati al load root (LoadEntryNo o EntryID).
•	ValidateTrackingChain / RepairTrackingChain: controllano e riparano inconsistenze LinkEntryNo nella catena FIFO.
•	GetAvailableQuantityByOriginalLoad(db, itemNo): mappa loadId -> quantità disponibile (RemainingQuantity).
Comportamenti e vincoli importanti
•	FIFO tracking: LoadEntryNo identifica la "catena" originale; LinkEntryNo collega ogni nuova entry all'entry precedente nella catena. Molti metodi preservano/aggiornano questi link per tracciabilità.
•	SaveChanges: molti metodi invocano SaveChanges internamente per ottenere EntryID (self-reference LoadEntryNo) o per applicare aggiornamenti; chiamare metodi multipli in un transaction se è richiesta atomicità.
•	Error handling: la classe usa SCL.Utility.ErrorOutput per validazioni critiche (lancia eccezione) e try/catch locale in punti non critici; i caller devono gestire eccezioni.
•	Quantità negative/positive: metodi come Redistribute* gestiscono valori positivi/negativi per bilanciare rettifiche; attenzione a segni e unità.
•	Transit e DeviceName: quando Transit=true alcuni raggruppamenti usano DeviceName come chiave (GroupByDevice).
•	Persistenza best-effort: alcune funzioni di redistribuzione o creazione impostano LoadEntryNo dopo il SaveChanges per ottenere EntryID.
Performance e best practice
•	Pre-filtrare via GetQueryable per evitare caricamento inutile di righe in memoria.
•	Usare transaction esterne se si combinano più chiamate che richiedono rollback atomico.
•	Evitare modifiche concorrenti sulle stesse load chain da più thread/processi senza lock DB; valutare row locking/transaction isolation livelli adeguati.
•	Usare i metodi di validazione (ValidateTrackingChain, ValidateAllItems) periodicamente per rilevare e riparare catene inconsistenti.
Esempio d'uso tipico
•	Carico iniziale: CreateInitialLoad -> ottieni EntryID e LoadEntryNo self-reference.
•	Movimento interno: CreateMovementChain prende dalle source più vecchie (FIFO) e crea unload/load mantenendo LinkEntryNo/LoadEntryNo.
•	Conferma contabile: CreateLinkedILE crea ILE e aggiorna ILENo sulla bin entry.
•	Rettifica inventariale: HandleAdjustmentBinEntryFromILE crea entry di aggiustamento e mantiene link corretto verso le entries coinvolte.
Note tecniche
•	Tipi restituiti: usa entità ABK.WAR_BinEntry e wrapper EXT_WAR_BinEntry per output UI raggruppati.
•	Dipendenze: SCL.Utility, CompareUtility, LinqUtility, OrderUtility/WSpaceUtility usati in vari metodi; verificare presenza di tabelle WARVIR_InfoItem in schema per fallback.
•	Logging: la classe non esegue logging estensivo; caller dovrebbe loggare azioni significative.