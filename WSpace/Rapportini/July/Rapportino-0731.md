---
Progetto: WSpace
Tipo: Rapportino
Tempo Impiegato: 8h
Ultima Modifica: 2025-07-31
Argomento: Ordini
Repo: WEC
Versione: 2.60.5
---
**Tags**

 #Rapportino #WSpace #WEC  #V2605 #Inventario #Ordini 

```table-of-contents
maxLevel: 2
```

# Introduzione
Chiusura e rifinitura degli ordini di inventario e di prelievo. 

# Cambiamenti Effettuati

## WSpace 
### Ordini di Inventario 
Implementato Ordini di inventario in WSpace, vengono gestiti tramite, `inventory-order-provider`. Sono ad ora disponibili varie funzionalita 
#### Creare ordine di Inventario di una Collocazione 
Nella schermata dedicata alla lista degli articoli nelle collocazioni, e stato aggiunto il pulsante "crea ordine di inventario per la collocazione", l'ordine viene creato in `Lista-Ordini`

#### Creare ordine di Inventario di un Articolo 
Nella schermata della lista degli articoli vedremo un bottone, crea ordine di inventario per articolo. questo creera un ordine per l'articolo selezionato, con le rispettive collocazioni dove sia presente. 

#### Elaborare Ordine 
Partendo dalla schermata 'Lista Ordini', si porta assegnare un ordine ad una risorsa, una volta assegnato, si potra mettere in lavorazione, procedendo a caricare, scaricare o inventariare i vari articoli presenti nell'ordine. Una volta completato si potra confermare, questo lo flagghera come completato (nel caso dell'ordine di inventario sara solo attivo il flag "isCompleted" , ma lo stato effettivo dell'ordine sara "da verificare")

### Ordini di Prelievo 
#### Assegnare ed Elaborare Ordine 
Possiamo assegnarci l'ordine di prelievo dalla schermata `OrderList` , una volta assegnato potremo iniziare a prelevare gli articoli dalle collocazioni indicate. 

#### Completare Ordine di Prelievo 
Una volta aggiunti al carrello gli articoli richiesti, possiamo completare l'ordine. 
#### Limitazioni 
Al momento siamo un po limitati su come gestiamo il completamento dell'ordine. Negli sviluppi attualmente in corso c'e quello di assegnare la proprieta `toBinNo` ad una collocazione ed aspettarsi che gli articoli vengano scaricati in quella collocazione 

### Lista Rettifiche 
Implementato nella sidebar un link per navigare alla lista delle rettifiche, qui appariranno le rettifiche fatte durante gli ordini di inventario, sara possibile confermarle o eliminarle, 
se confermate si creeranno delle `WAR_ItemLedgerEntry`, come succedeva gia quando si apriva `AdjustmentForm`

## WEC 

### Controllers 

Sono stati creati una serie di controllers per gestire gli ordini. 
#### WAR_OrderController 
Controller per gestire la parte generale degli ordini, ovvero la visualizzazione, la messa in lavorazione, l'assegnazione 

#### WAR_InventoryOrderController 
Controller per gestire le operazioni specifiche degli ordini di inventario, come confermare le quantita e le giacenze, questo controller si occupa anche di creare le `WAR_InventoryEntry` quando una quantita non combacia. 

#### WAR_PickingOrderController 
Controller per la gestione delle operazioni specifiche degli ordini di prelievo, come fornira una lista delle collocazioni dove possiamo andare a caricare gli articoli necessari 

#### WAR_InventoryEntryController 
Controller per la gestione delle `WAR_InventorEntry`, una serie di record che vengono generati automaticamente quando c'e una discrepanza tra le quantita registrate in giacenza e quelle effettive di una collocazione. Tra le operazioni possibili quelle di ritornare la lista dei record, l'eliminazione 
##### Atttenzione 
	 Per ora questa funzionalita e visualizzata nel WSpace, ma nelle prossime implementazioni la trasferiremo in eDoor, aggiungendo anche una funzionalita di conferma, per convertire le `InventoryEntry` in `BinEntry`, modificando le giacenze ed il contenuto delle collocazioni 


## Json 

### PageConfigs 
#### WAR_InventoryOperationList
Aggiunto il file per gestire la schermata di rettifica degli articoli negli ordini di inventario 

#### WAR_OrderList 
Esteso il file in compatibilità con le nuove implementazioni nel codice di WSpace 

#### WAR_InventoryOrderDetails 
Creato il file per gestire la visualizzazione degli ordini di Inventario 


