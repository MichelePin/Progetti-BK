Documentazione: WEC.Controllers.WSpace.WARInventoryOrderController (Italiano)
Panoramica
•	Scopo: gestione completa degli ordini di inventario (assegnazione, aggiunta righe, modifica quantità, conferma riga, conferma ordine, caricamento dati ordine, gestione collocazioni in modalità zona).
•	Route tipica: POST api/WARInventoryOrder/{Action} (tutti i metodi pubblici espongono POST).
•	Transazioni DB: ogni azione utilizza using(DBK_SuiteEntities) → operazioni atomiche per metodo.
•	Risposte: on success Ok con payload strutturato; on error BadRequest con Message.ErrorOutput (eccezioni catturate).
Modelli di richiesta principali
•	WarInventoryOrderRequest (base)
•	OrderNo: string
•	OrderMode: int
•	FilterZoneNo: string
•	RequestDevice, RequestResourceID, LocationNo, ZoneNo, Product, LoadConfig, ecc.
•	AssignOrderToResourceRequest
•	OrderNo, ResourceNo, RequestDevice, RequestResourceID, ecc.
•	AddLineToOrderRequest
•	OrderNo, BinNo, Entry: WAR_BinEntry, Quantity, RequestDevice, RequestResourceID, ZoneNo, LocationNo
•	ChangeQuantityRequest
•	OrderNo, OrderLineID, NewQuantity, RequestDevice, RequestResourceID, LocationNo, ZoneNo
•	ConfirmQuantityRequest
•	OrderNo, OrderLineID, RequestDevice, RequestResourceID, LocationNo, ZoneNo
•	ConfirmOrderRequest
•	OrderNo, RequestResourceID, RequestDevice, LocationNo, ZoneNo
Tipi e costanti utili
•	InventoryEntryOperation: CREATED, ADJUSTED, MOVED, DELETED, GROUPED, ADDED, QUANTITY_CHANGED.
•	PlanningOrderType, InventoryItemStatus, OrderMode, WarPlanningStatus, PlanningBinStatus: enumerazioni usate (spesso DTO usa int → cast esplicito richiesto).
Endpoint (metodi pubblici)
1.	AssignOrderToResource (POST)
•	Descrizione: assegna una testata ordine a una risorsa; imposta OrderStatus = INPROGRESS e IsActive = true.
•	Input obbligatorio: OrderNo, ResourceNo.
•	Validazioni: verifica esistenza testata; se ordine è già attivo con altra risorsa restituisce errore.
•	Azioni DB: aggiorna WAR_PlanningHeader.ResourceNo, OrderStatus, IsActive; SaveChanges.
•	Risposta: Ok con dati ordine aggiornati.
2.	AddLineToOrder (POST)
•	Descrizione: aggiunge una nuova riga inventario all’ordine o aggiorna una riga con stato Aggiunto esistente; crea la WAR_InventoryEntry correlata e la WAR_PlanningLine.
•	Input obbligatorio: OrderNo, Entry (WAR_BinEntry), Quantity.
•	Comportamento:
•	Se esiste riga con Status=Aggiunto per stesso Item/Bin → viene aggiornata (conteggio, link entry, inventory entry aggiornata).
•	Se non esiste e non esiste riga duplicata → crea WAR_InventoryEntry (ActionPerformed=ADDED) e nuova WAR_PlanningLine con CountedQuantity = Quantity.
•	Azioni DB: inserimenti/aggiornamenti, SaveChanges; in modalità Zona aggiorna planning bin status (UpdateBinStatusForZone).
•	Logging: ActivityLog.LogItemAction (best-effort).
•	Risposta: Ok con OrderLine e InventoryEntry.
Esempio AddLineToOrder: { "OrderNo":"ORD123", "BinNo":"COLL_01", "Entry":{ "EntryID":"..." }, "Quantity":5, "RequestResourceID":"R001" }
3.	ChangeQuantity (POST)
•	Descrizione: modifica la quantità contata per una riga; non crea WAR_BinEntry ma crea una WAR_InventoryEntry per tracciare la variazione.
•	Input obbligatorio: OrderNo, OrderLineID, NewQuantity.
•	Azioni DB:
•	Recupera planning line e testata.
•	ManageBinBlocking per bloccare la collocazione alla risorsa.
•	OrderUtility.UpdateLineStatusByCount per aggiornare stato/CountedQuantity; ottiene difference.
•	Se difference != 0 → inserisce WAR_InventoryEntry con ActionPerformed opportuno (CREATED/DELETED/QUANTITY_CHANGED).
•	SaveChanges; in modalità Zona aggiorna planning bin status.
•	Logging: ActivityLog.LogItemAction (best-effort).
•	Risposta: Ok con UpdatedOrder mappato.
Esempio ChangeQuantity: { "OrderNo":"ORD123", "OrderLineID":2, "NewQuantity":10, "RequestResourceID":"R001" }
4.	ConfirmQuantity (POST)
•	Descrizione: conferma la quantità di una riga; la marca come completata usando UpdateLineStatusByCount (conteggio = Quantity).
•	Input obbligatorio: OrderNo, OrderLineID.
•	Azioni DB:
•	ManageBinBlocking, UpdateLineStatusByCount su planningLine con target = planningLine.Quantity.
•	Imposta CompletedByResourceNo; SaveChanges.
•	Aggiorna bin status per modalità Zona se necessario.
•	Logging: ActivityLog.LogItemAction (best-effort).
•	Risposta: Ok con ordine aggiornato.
5.	ConfirmOrder (POST)
•	Descrizione: completa l'intero ordine di inventario se tutte le righe sono verificate; genera riepilogo (OrderUtility.GenerateOrderCompletionSummary) e marca ordine e righe come completati.
•	Input obbligatorio: OrderNo.
•	Validazioni: ordine esistente; non completato; tutte le righe verificate (no Status==0).
•	Azioni DB:
•	UnlockAllBinsForResource per sbloccare eventuali bin.
•	Imposta planningHeader.IsCompleted, EndingDate/Time, Summary, OrderStatus; marca righe come Completato.
•	SaveChanges.
•	Logging: ActivityLog.LogOrderAction (best-effort).
•	Risposta: Ok con riepilogo statistiche (totali, differenze, summary).
6.	LoadInventoryOrderData (POST)
•	Descrizione: carica testata, righe e WAR_InventoryEntry per un ordine; se LoadConfig=true include PageConfig; se OrderMode == Zona calcola BinList aggregato per ogni planning bin.
•	Input obbligatorio: OrderNo (WarInventoryOrderRequest).
•	Azioni DB:
•	Recupera WAR_PlanningHeader, WAR_PlanningLine, WAR_InventoryEntry, WAR_PlanningINBin.
•	OrderUtility.RecomputeInventoryOrderRowStats per aggiornare statistiche.
•	In modalità Zona: CalculateBinStatusForZone + costruzione BinList con Expected/Counted/Status.
•	Output: JSON con PageConfig (opzionale), OrderHeader, OrderRows, InventoryEntries, PlanningBins, BinList (zona), Summary.
•	Note: non crea righe automaticamente (LinesCreated=false).
Utility e logica ausiliaria
•	ManageBinBlocking(db, resourceId, newBinNo): sblocca bin bloccati dalla risorsa e blocca la nuova collocazione; usato per evitare collisioni.
•	UnlockAllBinsForResource(db, resourceId): sblocca tutti i bin bloccati dalla risorsa (alla conferma ordine).
•	CalculateBinStatusForZone(...): valuta stato planning bin (NotStarted, InProgress, Completed, CompletedWithIssues, CompletedWithSevereIssues) basato su CountedQuantity vs Quantity e percentuali.
•	UpdateBinStatusForZone(...): aggiorna PlanningINBin.BinStatus, ExpectedQuantity, CountedQuantity.
Errori / codici di stato
•	400 BadRequest: input mancante/errato, entità non trovata, violazioni logiche; i messaggi sono generati con Message.ErrorOutput.
•	Logging ed operazioni di auditing sono best-effort: eventuali errori di log non interrompono il flusso principale.
Considerazioni implementative e best practice
•	Enum vs int: DTO spesso usa int (OrderMode, Type, Status). Quando si invocano API/metodi che richiedono enum, effettuare cast esplicito (es. (PlanningOrderType)orderType).
•	Modalità Zona: molte logiche dipendono da OrderMode == Zona (3). Verificare sempre aggiornamento di WAR_PlanningINBin dopo modifiche quantità.
•	Bin blocking: chiamare ManageBinBlocking prima di operazioni che assegnano/aggiornano righe al fine di evitare conflitti concorrenti.
•	Tracciabilità: usare WAR_InventoryEntry per ogni modifica quantitativa; usare ActivityLog per audit (try/catch).
•	Concorrenza: operazioni multi-step possono richiedere transaction/lock se usate in ambienti ad alta concorrenza; attualmente SaveChanges è chiamato in punti specifici.
•	Validazioni: controllare esistenza testata/riga/entry e evitare duplicati righe prima di insert.
•	Localizzazione: messaggi in italiano; attenzione a internazionalizzazione se necessario.