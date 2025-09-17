---
Progetto: WSpace
Argomento: Inventario
Tipo: Documento-Analisi
date: 2025-07-16
tags:
  - WSpace
  - Inventario
  - Documento
  - Analisi
Versione: 2.60.2
---
**Tags**
#Analisi  #Ordini #CreareOrdine #Inventario #WSpace #WEC #DBK_Suite 

```toc
maxLevel: 1

```

# Introduzione

Documento di analisi per la feature ordini di inventario e di ricezione, questo ci permetterà di creare ordini di inventario dal front end del gestionale. 




# Obiettivo

La risorsa dovrà avere i permessi per creare l'ordine. 
Una risorsa nel magazzino lo metterà in lavorazione 
La risorsa assegnata inizierà il conteggio 
La risorsa con permessi conferma i cambi di giacenze 

# Approccio

## Frontend

### Nuovo

#### Componenti
- `ModalCountConfirm` Nuovo modale, visualizzeremo gli oggetti nell'ordine, e potremo confermare, o modificare con giacenze effettive temporanee, senza modificare quelle che abbiamo in record, faremo riferimento a [[WAR_PlanningInventoryItem-SQL]] invece che quelli presenti, preservando le giacenze registrate 
- `CreateOrderForm` Nuovo componente in cui dovremo inserire il tipo di ordine in linea con [[PlanningHeaderType-Json]] e [[PlanningHeaderOrderMode-Json]]
- `ActiveOrderButton` Nuovo componente in cui se siamo in fase di processazione di un ordine, andremo a visualizzare un'icona per accedere direttamente all'ordine in corso 

#### Flussi
- Creazione ordine: creiamo ordine, chiamiamo il nuovo endpoint , riceviamo conferma o errore 
- Verifica degli articoli: si procede all'accettazione dell'ordine, in questo momento chiameremo il nuovo endpoint, e ritorniamo la lista degli articoli da inventariare.
- Conferma Ordine: una volta inventariata una collocazione, una zona etc, confermeremo l'ordine chiamando il nuovo endpoint, ricevendo conferma o errore 
- Conferma rettifiche: Accediamo al gestionale e confermiamo le nuove rettifiche 


### Modificato

#### Componenti
- `OrderList` Modificare la visualizzazione della tabella esistente per adattarla alle nuove implementazioni, visualizzando un tipo di ordine alla volta 

#### Flussi
- Elenco degli ordini, come da sopra, modifichiamo il flusso per filtrare per tipo di ordine 



## Backend

### Nuovo
- `Api/WAR_InventoryOrder` : gestisce gli ordini di inventario, si faccia riferimento a [[WAR_OrderController]]
-  `Api/WAR_PlanningItem` : gestisce i singoli record degli articoli nell'ordine, si faccia riferimento a [[WAR_PlanningItemController]]
### Modificato
- `WAR_OrderController` : aggiunti filtri alla chiamata `getOrderList`, per ritornare liste di ordini pertinenti. si faccia rifermento a [[WAR_OrderController]]

## Database

### Nuovo
- [[WAR_InventoryEntry-SQL]] 
- [[WAR_PlanningInventoryItem-SQL]]

### Modificato
- [[WAR_PlanningHeader]]


# Tasks 
## Frontend 
- [ ] Creato `ModalCountConfirm`
- [ ] Creato `CreateOrderForm`
- [ ] Creato `ActiveOrderButton`
- [ ] Creata logica per controllare ordini 
- [ ] Creata logica per creare ordini 
- [ ] Creata logica per confermare ordini 
- [ ] Creare logica per conferma rettifiche 
- [ ] Modificato `OrderList`
## Backend 
- [ ] WAR_OrderController 
	- [ ] Esteso GetOrderList per accettare i filtri 
	- [ ] Implementata la funzione CreateNewOrder
		- [ ] PickingOrders 
		- [ ] Filtri 
			- [ ] OrderMode 
			- [ ] filterItemNo 
			- [ ] filterBinNo 
		- [ ] Creazione WAR_PlanningLine 
- [ ] WAR_InventoryOrderController 
	- [ ] Implementato getInventoryOrders 
	- [ ] Implementato getResourceOrders 
	- [ ] Implementato getOrderByType
	- [ ] implementato getOrderByStatus
	- [ ] implementato assignOrder 
	- [ ] implementato submitOrder 
	- [ ] implementato completeOrder 
- [ ] WAR_PlanningItemController 
	- [ ] implementato getFilteredItems
	- [ ] implementato getItemsByStatus 
	- [ ] implementato getItemsByOrderLine
	- [ ] implementato postQuantityAdjustment
