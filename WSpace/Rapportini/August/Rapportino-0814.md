---
Progetto: WSpace
Tipo: Rapportino
Tempo Impiegato: 40
Ultima Modifica: 2025-08-14
Tags: ["WSpace", "Rapportino"]
---
**Tags**

#WSpace #Rapportino

```table-of-contents
maxLevel: 1
```

# Introduzione

Finalizzazione degli ordini di inventario. 

# Tipi di Ordine 
## Articolo 
Questo tipo di inventario richiede di verificare le giacenze di un determinato articolo in tutto il magazzino. 
### Procedimento 
1. L'ordine viene creato dal gestionale nella sezione apposita (Da implementare)
2. In WSpace selezioniamo l'ordine e lo mettiamo in lavorazione. 
3. Una volta messo in lavorazione lo possiamo vedere nel footer verde e col numero di ordine 
4. Selezionando il bottone del footer o l'ordine da `OrderList` potremo accedere ai dettagli dell'ordine. 
5. Dentro la schermata "Dettagli Ordine" possiamo mettere in lavorazione l'ordine o metterlo in pausa 
6. Usando la barra di ricerca possiamo filtrare per collocazione, inserendo `itemNo` nella barra di ricerca (o sparando sul codice) potremo registrare le giacenze di quell'articolo nella collocazione dove ci troviamo 
7. Sara possibile stampare etichette degli articoli selezionati 
8. Sara possibile aggiungere articoli a collocazioni non registrate nell'ordine
9. Quando tutti gli articoli saranno stati verificati ci apparira il bottone "Completa Ordine" selezionandolo l'ordine verra segnato come completato e ci sara la possibilita di aggiornare le giacenze da eDoor (da implementare), tramite `Lista Rettifiche Provvisorie` o direttamente aggiornare le giacenze in caso di configurazione 
## Collocazione 
Questo tipo di inventario richiede di verificare le giacenze di tutti gli articoli nella collocazione selezionata. 

### Procedimento 
1. L'ordine viene creato dal gestionale nella sezione apposita (Da implementare)
2. In WSpace selezioniamo l'ordine e lo mettiamo in lavorazione. 
3. Una volta messo in lavorazione lo possiamo vedere nel footer verde e col numero di ordine 
4. Selezionando il bottone del footer o l'ordine da `OrderList` potremo accedere ai dettagli dell'ordine. 
5. Dentro la schermata "Dettagli Ordine" possiamo mettere in lavorazione l'ordine o metterlo in pausa 
6. Usando la barra di ricerca possiamo filtrare per collocazione, inserendo `itemNo` nella barra di ricerca (o sparando sul codice) potremo registrare le giacenze di quell'articolo nella collocazione dove ci troviamo 
7. Sara possibile stampare etichette degli articoli selezionati 
8. Sara possibile aggiungere articoli non registrati nell'ordine alla collocazione specifica, non ad altre
9. Quando tutti gli articoli saranno stati verificati ci apparira il bottone "Completa Ordine" selezionandolo l'ordine verra segnato come completato e ci sara la possibilita di aggiornare le giacenze da eDoor (da implementare), tramite `Lista Rettifiche Provvisorie` o direttamente aggiornare le giacenze in caso di configurazione 

## Zona 
Questo tipo di inventario richiede di verificare le giacenze di tutti gli articoli nella zona selezionata, funziona come l'ordine di inventario per collocazione, ma con svariate collocazioni. 



# Cambiamenti Effettuati

## WSpace 
### Services 
#### InventoryOrderPageProvider
Aggiunto il provider `InventoryOrderPageProvider`, questo gestisce tutta la logica inerente all'ordine in corso, visualizzando le quantità registrate, quelle effettive e il progresso totale. 

#### InventoryOperationList 
Aggiunto il provider `InventoryOperationList`, questo gestisce tutta la logica delle rettifiche provvisorie dandoci la possibilita di confermare le rettifiche, modificarle e raggrupparle. Vedasi nota 


## WEC

### Controllers 
Implementati una serie di nuovi controller ed esteso il controller WAROrderController

#### WAROrderController 
Esteso questo controller per maneggiare le operazioni di creazione, eliminazione, messa in lavorazione degli ordini in generale 
##### GetOrderList 
Restituisce la lista completa degli ordini e la pagina di configurazione `WAR_OderList` 
##### StartOrder
Mette l'ordine selezionato in lavorazione 
##### StopOrder
Toglie lo stato di lavorazione dell'ordine
##### CreateInventoryOrder
Crea un ordine di Inventario, endpoint universale che ci consente di creare ordini di collocazione, articolo o zona a seconda dei parametri che gli passiamo 
##### DeleteOrder
Elimina l'ordine selezionato


#### WARInventoryOrderController 

##### LoadInventoryOrderData
Restituisce i dettagli dell'ordine di Inventario selezionato 
##### AssignOrderToResource 
Assegna l'ordine alla risorsa attiva 
##### ChangeQuantity
Cambia la quantità di una riga di inventario specifica 
##### ConfirmQuantity
Conferma la quantità di una riga di inventario confermando di avere la stessa quantità che le giacenze registrate 
##### AddLineToOrder
Aggiunge una nuova riga di inventario, verificando collocazioni ed articoli, e la aggiunge a WAR_InventoryEntry 
##### CompleteInventoryOrder
Completa l'ordine di inventario selezionato, aggiustando le giacenze (ove permesso) o creando WAR_InventoryEntry  










