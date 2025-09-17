## WSpace 
### Lista Operazioni 
- [ ] Cambiare nome a Lista Rettifiche Provvisorie 
- [ ] Tipo di Movimento non appare dopo group 
- [ ] Articolo non appare dopo group
- [ ] Tipo di Moviment non appare dopo group 
- [ ] Nella factbox aggiungere info su gruppo 
- [ ] O su entrata in caso di singola entrata 
- [ ] Opzione Per Ordini 
- [ ] Controllare WARInventoryEntryController per parametri ricevuti ed inviati 

### Ordini 
- [ ] Cambiare colore ordini a seconda dello stato 
	- [ ] In corso: 
	- [ ] Assegnato :
	- [ ] Terminato OK: 
	- [ ] Terminato Male: 
	- [ ] Confermato
- [ ] Aggiungere Barra di % di completamento 
- [ ] In Tablet con factbox 
- [ ] Copiare funzionamento icona Ordine di ricezione 
- [ ] Cambiare icone di ordine di inventario 
- [ ] Rimuovere Icone su header 
- [ ] Mostrare Ordini solo se non abbiamo ordine attivo. 
- [ ] Senno direttamente OrderDetails 
- [ ] Aggiungere onPasteActions con relativo RegEx per aprire ordini 
- [ ] Creare Utility Function per riportare oggetto mancante 
- [ ] Verificare se articolo nelle ManualEntries

### Ordine di inventario 

- [ ] Con barcode non seleziona la collocazione nel WEC
- [ ] Status 0 non considerato dal enum 
- [ ] Rimuovere delete Azioni di testata 
- [ ] Muovere Aggiungi alla barra del grid 
- [ ] Aggiungere Stampa alla barra del grid 
- [ ] Filtrare per collocazione attuale 
- [ ] Filtrare I completati 
- [ ] Aggiungere Segnala Mancante alle opzioni del modale con codice a barre 
- [ ] Assicurasi play pause funzionino 

### Ordine di Prelievo 
- [ ] Rimuovere Delete dalle azioni di testata 
- [ ] rimuovere aggiungi dalla barra testata 
- [ ] dove c'e la spunta nell'ultima cella della griglia implementare segnala mancante 
- [ ] OnPaste oggetto 
	- [ ] carico nel carrello se l'oggetto e presente nella collocazione attuale e nella lista 
		- [ ] Carica per completare l'ordine 
	 - [ ] chiedo collocazione se oggetto presente in varie collocazioni 
	 - [ ] scarico oggetto se collocazione di destinazione e selezionata 
	 - [ ] Righe da Scaricare se collocazione di destinazione 
- [ ] OnPaste collocazione mi sposto alla collocazione e visualizzo gli oggetti da prelevare

### Ordine di Carico / Scarico 
- [ ] Nome Fornitore 
- [ ] Articoli 
- [ ] Quantita Ordinata 
- [ ] Quantita Consegnata 
- [ ] Lotto con prime 4 lettere del fornitore come CF 
- [ ] Documento con report e firma della risorsa 
- [ ] Codice  a barre 

### Log 
- [ ] Estendere funzione di log dentro WSpace 
	- [ ] API 
	- [ ] UI 
	- [ ] Oggetti 
	- [ ] Modifiche 
	- [ ] Registrare tutti gli errori 
- [ ] Creare Logs in WEC 
	- [ ] Simili a quelli di WSpace 
	- [ ] Su file TXT o Tabella 


### Footbar 
- [ ] Dimensione unica bottoni 
- [ ] Collocazioni non si aggiornano dopo ordine 
- [ ] Icone Rosso

### Icone 
#### Ordini 
- Inventario per collocazione 
- Inventario per articolo 
- Inventario per 
#### Tabella 
- In mobile due righe, una col titolo una con i bottoni 
- Verificare perche nei bottoni non appare la scelta 
-  Opzione per togliere factbox 
#### Move Orders 
- Non mette gli ordini nel carrello 

#### Schermate 
- una doppia 
- Quella coi bottoni 
- Inventario 
- Rettifiche 
- Spostamento 
- Una con sidebar aperta 
- Mobile 