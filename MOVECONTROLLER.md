
Documentazione: WEC.Controllers.WSpace.WARMoveOrderController (Italiano)
Panoramica
•	Scopo: gestione ordini di movimentazione merci (creazione, completamento ingresso, caricamento dati, modifica quantità, conferma quantità).
•	Route tipica: POST api/WARMoveOrder/{Action} (controller usa metodi POST).
•	Transazioni DB: ogni azione usa using(DBK_SuiteEntities) => operazioni atomiche per metodo.
•	Risposte: in caso di successo viene restituito Ok con struttura tramite OrderUtility.BuildOkResponse; in caso di errore BadRequest con Message.ErrorOutput.
Modelli di richiesta principali
•	CreateMoveOrderRequest
•	VendorNo: string (facoltativo) — codice fornitore
•	Type: int — tipo ordine (mappato all'enum PlanningOrderType)
•	ToBinNo: string — collocazione destinazione preferita
•	OrderMode: int — modalità ordine
•	DocumentNo: string
•	ItemList: List<MoveOrderItem> — lista articoli (ItemNo, Quantity, LotNo, SerialNo)
•	MoveOrderRequest
•	OrderNo: string (obbligatorio per molte azioni)
•	ToBinNo: string (per CompleteIncomingOrder)
•	LocationNo, ZoneNo, BinNo, Options, ecc.
•	ChangeQuantityRequest
•	OrderNo, OrderLineID, NewQuantity
•	ConfirmQuantityRequest
•	OrderNo, OrderLineID
Endpoint (metodi pubblici)
1.	CreateMoveOrder (POST)
•	Descrizione: crea un nuovo ordine di movimentazione e relative WAR_PlanningLine per ogni articolo. Genera OrderID usando OrderUtility.GenerateOrderId.
•	Input obbligatorio: Request.ItemList non vuoto; Request.Type (int) e Request.OrderMode opzionale.
•	Validazioni:
•	Se VendorNo fornito verifica che esista; altrimenti errore.
•	Verifica che esistano WARVIR_InfoItem per gli ItemNo richiesti.
•	Azioni DB:
•	Inserisce WAR_PlanningHeader
•	Inserisce WAR_PlanningLine per ogni articolo
•	Risposta:
•	Successo: Ok con OrderID e mappatura ordine (MapToPlanningOrder).
•	Errore: BadRequest con messaggio.
•	Note:
•	Request.Type è int; quando si chiama GenerateOrderId assicurarsi di convertire a PlanningOrderType se l'overload lo richiede.
Esempio request (CreateMoveOrderRequest): { "VendorNo": "V001", "Type": 0, "ToBinNo": "COLL_001", "ItemList": [ { "ItemNo":"ITEM01", "Quantity": 10, "LotNo":"L01", "SerialNo": null } ] }
2.	CompleteIncomingOrder (POST)
•	Descrizione: finalizza un ordine di ingresso. Crea WAR_BinEntry per ogni riga (quantità consegnata), registra WAR_ItemLedgerEntry (ILE), imposta lo stato riga a completato e genera un ordine di picking collegato.
•	Input obbligatorio: Request.OrderNo, Request.ToBinNo
•	Azioni DB:
•	Recupera ordine e righe
•	Inserisce WAR_BinEntry (destination bin = Request.ToBinNo)
•	Aggiunge ILE tramite GDB.WARItemLedgerEntry e log tramite OrderUtility.AddIleLog
•	Imposta order.IsCompleted / order.OrderStatus e genera picking (WAR_PlanningHeader + WAR_PlanningLine)
•	Risposta: Ok con IncomingOrderID e PickingOrderID
•	Note: rispetta FilterLocationNo / FilterZoneNo per location/zone destinazione; il pickOrderId viene generato con tipo PlanningOrderType.Picking.
3.	LoadIncomingOrderData (POST)
•	Descrizione: ritorna header, righe e bin-entries per un ordine di ingresso; opzionalmente carica la PageConfig.
•	Input obbligatorio: Request.OrderNo
•	Output: JSON con OrderHeader, OrderRows, BinEntries, Summary (statistiche)
•	Note: usa OrderUtility.RecomputeIncomingOrderRowStats per ricalcolare statistiche.
4.	ChangeQuantity (POST)
•	Descrizione: aggiorna la quantità attesa per una singola riga ordine (non crea WAR_BinEntry).
•	Input obbligatorio: OrderNo, OrderLineID, NewQuantity
•	Azioni DB:
•	Aggiorna planningLine.NewQuantity / Quantity e usa OrderUtility.UpdateLineStatusByCount per aggiornare lo stato.
•	Salva e ritorna ordine aggiornato mappato.
•	Risposta: Ok con UpdatedOrder.
5.	ConfirmQuantity (POST)
•	Descrizione: conferma la quantità per una riga (conteggio finale). Imposta planningLine.Status=Arrivato, IsCompleted=true e CountedQuantity.
•	Input obbligatorio: OrderNo, OrderLineID
•	Azioni DB:
•	Imposta campi riga, salva.
•	Log dell'azione tramite ActivityLog.LogItemAction (best-effort).
•	Ritorna ordine aggiornato mappato.
•	Risposta: Ok con UpdatedOrder.
Errori / codici di stato
•	400 BadRequest: input mancante, entità non trovata, eccezione lato server (messaggi strutturati con Message.ErrorOutput).
•	Eventuali eccezioni vengono catturate e restituite tramite Message.ErrorOutput con contesto.
Considerazioni implementative e best practice
•	Tipi enum: molte API usano int nei DTO (es. Request.Type). Quando si passa a funzioni che richiedono enum (PlanningOrderType) effettuare cast esplicito: (PlanningOrderType)request.Type.
•	Validazioni: verificare sempre che ItemList contenga articoli e che info anagrafiche esistano.
•	Logging: usare OrderUtility.AddIleLog e ActivityLog.LogItemAction (uso try/catch per non rompere flusso).
•	Concorrenza: SaveChanges viene chiamato dopo gruppi di modifiche; valutare lock/transaction se operazioni multi-step critiche.
•	Localizzazione: messaggi di errore/testo sono in italiano.