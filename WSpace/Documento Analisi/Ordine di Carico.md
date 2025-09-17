---
Progetto: WSpace
Tipo: Documento-Analisi
Repo: WEC
Versione: 2.60.4
Argomento: Ordini
date: 2025-07-21
---
**Tags**
#Analisi  #Ordini #CreareOrdine #OrdineDiCarico #WSpace #WEC 

```toc
style:inlineFirstLevel
```
# Info
## Obiettivo 
Ci poniamo come obiettivo espandere la soluzione attuale ad avere un flusso ben definito di Ordini Di Carico 

## Terminologia 
### Ordine di Carico 
- Riferito come OdC
- Si intende per OdC un ordine di carico un ordine con degli articoli da prelevare, mettere nel carrello virtuale, ed opzionalmente scaricare in un altra collocazione 
### Carrello Virtuale 
- Riferito come carrello 
- Si intende per Carrello Virtuale, il carrello dove mettiamo gli articoli da spostare o caricare. 
- Il carrello virtuale potrebbe essere assegnato ad una risorsa 
# Requisiti 
## Necessari 
- [[#Gestione dell'ordine da inizio a fine ad eccezione della sua creazione]]
- [[#Verificare che l'oggetto scansionato sia nell'ordine in corso]]
  

## Opzionali

- [[#Spostare tra Collocazioni]]

- [[#Vedere solo gli ordini nella zona in cui siamo]]

- [[#Spostare tra collocazioni ]]

- [[#Consultare OdC in corso con RBAC]]

- [[# Vedere solo gli ordini nella zona in cui siamo ]]

## Brutti ma Bisogna

- [[#Standardizzare Orders ]]

- [[#Classi libreria nel WEC]]

- [[#Rivedere strutture Json]]

- [[#Documentazione ]]

- [[#Pulizia Generale ]]

# Tasks 
### Gestione dell'ordine da inizio a fine ad eccezione della sua creazione 
Programmeremo la nuova _feature_ dando per scontato che gli ordini ci arrivino da un getsionale o simili, questo pero non ci impedisce di adattare ed estendere gli endpoints gia presenti nel WEC per gestire gli ordini ad ora sono slegati dagli ordini di inventario a livello di endpoints, se il tempo lo permette procederemo ad una standardizzazione tra tipi di ordine. La buona notizia e che sembra ci sia gia buona parte della logica implementata, bisognerà verificare l'effettivo collegamento e risposte tra WSpace e WEC. 
#### Come lo Faremo 

- [ ] Ampliare  la logica lato WSpace per il controllo dello stato dell'ordine possibilmente unendolo con `moveItems`  (da 2 ore)
- [ ] Ampliare il controller [[WAR_PickingOrderController]] che, al momento, non prevede il cambio di stato dell'ordine, richiede un'analisi un po piu approfondita, ma vedo 2 approcci possibili 
	- [ ] Estendere il controller per fare riferimento all'OdC (20minuti)
	- [ ] Standardizzare il processo con il controller [[WAR_InventoryOrderController]] che gia prevede queste implementazioni, attraverso una libreria (minimo 2 ore per il primo, poi 10, 15 minuti)
- [ ] Aggiorniamo [[WAR_ORDERLIST]] per adattare i nuovi parametri (45secondi)
- [ ] Aggiorniamo la visualizzazione nel WSpace e per il momento abilitiamo completa l'ordine, e manualmente lo completerà (1ora) 

###  Verificare che l'oggetto scansionato sia nell'ordine in corso 
Quando apriamo una collocazione, e abbiamo un ordine in corso o accettato filtriamo gli articoli se `itemID` e nel nostro ordine 
#### Come lo faremo 
- [ ] Estendiamo la classe `Move-Items` per visualizzare solo gli articoli che dobbiamo prelevare per il nostro ordine, 
- [ ] Mettendo il focus sulla barra di ricerca e sparando, si potrebbe direttamente aggiungere al carrello, magari estendendo la funzione di aggiungere direttamente  al carrello se la quantita richiesta e 1, oppure far apparire un modale (no calcolatrice) per selezionare la quantita, prevedere bottone carica massima possibile 
- [ ] Modifichiamo la logica di `packing-order` in Wspace per consentirci di completare l'ordine 

### Spostare tra Collocazioni 
Ricevere un ordine che ci dice quali articoli spostare, da quale collocazione a quale collocazione.  Non dovrebbe essere troppo difficile, ci bastera creare e ritornare delle righe di [[WAR_PlanningLine]] con fromBinNo toBinNo
#### Come lo faremo 
- [ ] Estendiamo [[WAR_OrderController]] per creare questo tipo di ordine (40minuti)
- [ ] Creiamo un `PageConfig`  in modo da poter controllare il flusso dei dati senza complicazioni (10minuti)
- [ ] Nel frontend ci assicuriamo di controllare il tipo di inventario e di restuire un grid appropriato (1ora)
- [ ] Completiamo l'ordine con la logica implementata in [[[#Verificare che l'oggetto scansionato sia nell'ordine in corso]]

### Vedere solo gli ordini nella zona in cui siamo 
Prevedere per il futuro vedere solo gli ordini nella zona di pertinenza della risorsa, possiamo cercare in [[WAR_ResourceInBin]] con il parametro `resourceNo` che già ci passa la Request 
- [ ] Aggiungere filtri a [GetOrderList], per filtrare i risultati prima di ritornarli  (1ora)
### Standardizzare WAR_PlanningHeader 
Dedicare un po di tempo alla progettazione di come vengono gestiti gli ordini di tutti i tipi finora implementati. Sappiamo che sono tutti [[WAR_PlanningHeader]] , che hanno un parametro `Type` che decide di che tipo sono, basati su [[PlanningHeaderType-Json]]

### Classi libreria nel WEC
I controller iniziano ad essere molto intricati, e mi pacerebbe (sarebbe necessario) iniziare ad organizzarle da altre parti del codice, tipo nella cartella dedicata alle librerie del WSpace (3ore)
### Rivedere strutture Json
Guardando le Varie `PageConfigs` mi sono accorto che in eDoor si possono passare stili e simili attraverso il json, inoltre sono presenti funzionalita non implementate nel WSpace come il flag sortable. 
- [ ] Riveredere i parametri affinche ritornino le propieta ed i nomi correttamente in linea con le nuove modifiche apportate 
- [ ] Aggiornare i parametri con la base di dati 

### Documentazione 
Scrivere documentazione tecnica per i processi svolti, i cambi effettuati, e le nuove implementazioni (4ore)
- [ ] Processi Svolti
- [ ] Changelog 
- [ ] Possibili Problemi 
Scrivere documentazione funzionale
- [ ] Selezionare Ordine 
- [ ] Assegnare Ordine
- [ ] Controllare Ordine
- [ ] Concludere Ordine 
- [ ] Errori Ritornati 
### Pulizia Generale 
Bisogna fare pulizia, troppo disordine in varie parti del codice, le cose piu urgenti sono 
- [ ] il login ci mette 36 secondi, e si ripete ogni volta che si deve testare il minimo cambio, rende ogni sviluppo eterno. 
- [ ] il move-items ed il picking-order andrebbero uniti, fanno basicamente la stessa cosa 
- [ ] introdurre un nuovo servizio che sia responsabile degli ordini con funzioni utilitarie, in modo da avere tutte le chiamate alla Api nello stesso posto 
- [ ] creare design-Tokens cose tipo bk-verde bk-blu-selected, e cosi via 

