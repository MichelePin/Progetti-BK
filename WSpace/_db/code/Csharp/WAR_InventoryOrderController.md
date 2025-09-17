---
Progetto: WSpace
Linguaggio: CSharp
Tipo: Code-File
Ultima Modifica: 2025-07-18
Versione: 2.60.2
Categoria: ControllerAPI
Argomento: Inventario
---
**Tags**

#WSpace #Inventario #Ordini #Controller #Backend 
#Code #WEC #CSharp #CreareOrdineInventario #ConfermareOrdine


```table-of-contents
maxLevel:1
```

# Introduzione

Controller per la gestione degli ordini di inventario 


# Metodi principali 

## LISTE
### getInventoryOrders
Questo endpoint ritorna la lista completa degli ordini di inventario non completati, non serve nessun parametro
### getResourceOrders 
Questo endpoint ritorna la lista degli ordini di una risorsa, avrà il parametro `includeCompleted` per verificare tutti gli ordini che quella risorsa ha portato a termine 
### getOrderByStatus 
Questo endpoint ritorna la lista degli ordini, filtrati per status, dovremo passargli lo status che vogliamo consultare 
### getOrderByType 
Questo endpoint ritorna la lista degli ordini, filtrati per status, dovremo passargli lo status che vogliamo consultare 
## MUTAZIONI 

### assignOrder
Questo endpoint riceve l'identificativo dell'ordine, e con quello della risorsa presente nella request, lo assegna. Creando la lista di `PlanningInventoryItem` 

### submitOrder
Questo endpoint riceve l'identificativo dell'ordine, controlla se soddisfa i requisiti, e cambia lo status a `revisionNeeded`

### completeOrder 
Questo endpoint riceve l'identificativo dell'ordine, controlla se soddisfa i requisiti, se l'utente ha i permessi, in questo momento verifichiamo le `InventoryEntry`, e modifica le giacenze,  infine cambia lo status a `completed`

# Codice 
```C# cpp fold title:WAR_InventoryOrderController 
// 
//

```

# Change Log
## 2.60.2

