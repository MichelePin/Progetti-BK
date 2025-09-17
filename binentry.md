Documentazione: WEC.Controllers.WSpace.WARBinController (Italiano)
Panoramica
•	Scopo: fornisce funzionalità di utilità sulle collocazioni (bin) del magazzino: ricerca, filtro, arricchimento dati (factbox), gestione UoM, rilevamento stato bin e supporto per ordini di picking.
•	Route tipica: POST api/WARBin/{Action}.
•	Transazioni DB: ogni metodo usa using(DBK_SuiteEntities) → operazioni isolate per metodo.
•	Risposte: restituisce oggetti anonimi/JSON; in caso d'errore ritorna struttura con Error o BadRequest tramite Message.ErrorOutput.
Modelli di richiesta principali
•	JSWarFilterRequest (estende JSWarRequest): BinNo, FilterBinNo, GroupByBin, FilterItemNo, FilterLotNo, FilterBoxHeaderNo, UseContainsFilter, GroupByBox, GroupByItem, GroupByLot, IncludeTransit, AutomaticGroup, RequestResourceID, LocationNo, ZoneNo, ecc.
•	JSWarRequest / JSRequestBasicParams per casi generici.
Tipi utili
•	EXT_WAR_BinEntry: estensione di WAR_BinEntry usata per trasmettere campi addizionali (_OriginalBinNoQty).
•	WARBinEntry (GDB helper): fornisce GetGroupedBinItemList e GetList per recupero dati raggruppati.
Endpoint (metodi pubblici)
1.	GetFilteredBinItemList (POST)
•	Descrizione: restituisce lista articoli bin filtrata e arricchita con FactboxData.
•	Input: JSWarFilterRequest con filtri e opzioni di raggruppamento.
•	Flusso:
•	Valida request (WSpaceUtility.CheckBasicRequestData).
•	Recupera PageConfig.
•	Chiama WARBinEntry().GetGroupedBinItemList per ottenere liste raggruppate.
•	Carica eventuali picking virtuali assegnati alla risorsa (OrderUtility.GetAssignedPickingOrderForResource).
•	Integra entry manuali tramite BinUtility().ProcessManualInventoryEntries.
•	Risolve e, se possibile, persiste UnitOfMeasure e ItemDescription mancanti (tentativo best-effort).
•	Precarica allGrouped (incluso transit), mappa UoM e mappa bin bloccati.
•	Per ogni entry costruisce FactboxData (BuildFactboxData) contenente: ItemDescription, UnitOfMeasure, RemainingQuantity totale, BinList, LotBinList, IsBlocked/BlockedBy, InTransitQuantity.
•	Ritorna BinItemList arricchita, PageConfig e PickingOrderData.
•	Note:
•	Funzionalità di arricchimento è best-effort: in caso di errore ritorna risposta base senza arricchimenti.
•	Usa caching locale nelle variabili locali; evita modifiche globali.
2.	GetOrderBinItemList (POST)
•	Descrizione: come GetFilteredBinItemList ma filtra solo gli item presenti nelle righe dell'ordine attivo assegnato alla risorsa.
•	Input: JSWarFilterRequest.
•	Flusso:
•	Recupera ordine attivo per risorsa (WAR_PlanningHeader.IsActive && ResourceNo).
•	Se non trovato o righe vuote -> eccezione.
•	Recupera allEntries con WARBinEntry().GetGroupedBinItemList e filtra per item presenti nell'ordine.
•	Procede con integrazione entry manuali, risoluzione UoM/descrizioni e (opzionalmente) arricchimento; ritorna lista filtrata.
•	Note: utile per app che visualizzano solo articoli rilevanti per il picking assegnato.
3.	GetAllAvailableItems (POST)
•	Descrizione: ritorna elenco di tutti gli articoli disponibili (quantità positive) raggruppati per articolo + lista bin.
•	Flusso:
•	Recupera AllItems tramite WARBinEntry.GetGroupedBinItemList con IncludeTransit=false.
•	Risolve UoM dove mancante e persiste tentativamente.
•	Filtra per quantità positive e raggruppa per ItemNo/Descrizione con sommatoria quantità e BinList.
•	Ritorna AvailableItems e PageConfig.
4.	GetAllIntransit (POST)
•	Descrizione: ritorna tutte le WAR_BinEntry con Transit=true e RemainingQuantity>0 (ordini in transito).
•	Output: lista proiettata con campi rilevanti (EntryID, ItemNo, BinNo, RemainingQuantity, DeviceName, ResourceNo, OrderNo, InsertDateTime, ecc.).
•	Note: in caso di errore ritorna lista vuota per mantenere contract semplice.
Utility e logica ausiliaria
•	BuildUomMap(db, itemNos)
•	Scopo: risolvere unità di misura per un set di item (prima WAR_Item, fallback WARVIR_InfoItem).
•	Restituisce dictionary itemNo->MeasureNo.
•	BuildBlockedBinMap(db, binNos)
•	Scopo: mappa bin -> (IsBlocked, BlockedBy).
•	Usata da BuildFactboxData per rilevare blocchi su collocazioni.
•	BuildFactboxData(db, entry, allGrouped, uomMap, blockedBinMap, excludedBins)
•	Calcola:
•	UoM risolta (entry.UnitOfMeasure o mappa o PZ),
•	Quantità totale non transit per item,
•	Lista bin per item (esclusi eventuali excludedBins),
•	Lista bin per lotto se presente LotNo,
•	Stato bloccato (IsBlocked) e blockedBy,
•	Quantità in transito.
•	Restituisce dictionary con campi pronti per UI factbox.
•	CalculateBinStatusForZone / UpdateBinStatusForZone (se usati da altri controller)
•	Nel controller inventario sono disponibili funzioni analoghe; qui la logica di stato bin è riutilizzata quando necessario.
Errori / codici di stato
•	Restituzioni di errore:
•	Messaggi strutturati (BadRequest con Message.ErrorOutput) per errori DB o validazione.
•	In alcuni endpoint (GetFilteredBinItemList) vengono restituiti oggetti { Error = ex.Message } per semplificare il client.
•	Best-effort:
•	Molte operazioni di arricchimento/logging sono protette da try/catch per non interrompere la risposta principale.
Considerazioni implementative e best practice
•	Best-effort persistence: risoluzione UoM/descrizione cerca di aggiornare record esistenti; gli errori di persistenza vengono ignorati per non bloccare la UI.
•	Performance: Precaricamento di allGrouped, uomMap e blockedBinMap riduce chiamate DB per ogni entry; utile per grandi dataset.
•	Concorrenza: quando si scrive su WAR_BinEntry o su altre tabelle, SaveChanges è chiamato in blocchi; valutare lock/transaction se necessario.
•	Robustezza: le funzionalità di integrazione con picking virtuale e entry manuali sono tolleranti a errori (ignore exceptions).
•	Localizzazione: testi e PageConfig sono in italiano; PageConfigUtility restituisce configurazioni UI.
Esempi di Request/Response (semplificati)
•	Richiesta GetFilteredBinItemList: { "FilterBinNo": "COLL_01", "GroupByBin": true, "FilterItemNo": "ITEM01", "RequestResourceID": "R001", "LocationNo": "001" }
•	Risposta (sintesi): { "BinItemList": [ { /* entry properties + FactboxData / }, ... ], "PageConfig": [ ... ], "PickingOrderData": [ / se presente */ ] }