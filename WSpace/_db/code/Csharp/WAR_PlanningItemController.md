---
Progetto: WSpace
Linguaggio: CSharp
Tipo: Code-File
Ultima Modifica: 2025-07-18
Versione: 2.60.2
Repo: WEC
---

**Tags**

#WSpace #CSharp  #Ordini #Inventario #Code #WEC 

```table-of-contents
maxLevel: 1
```

# Introduzione

Controller per la gestione degli articoli negli ordini di inventario. Questi articoli vengono creati in parallelo alle giacenze in modo da non confondere in caso bisognasse fare altre modifiche. 



# Metodi principali 

## LISTE
### getFilteredItems
Questo endpoint ritorna la lista filtrata degli articoli, si aspetta il parametro `filter` basato sulla proprietà `inventoryMode` di `WAR_PlanningHeader` 
### getItemsByStatus
Questo endpoint ritorna la lista filtrata degli articoli, si aspetta il parametro `filter` basato sulla proprietà `ItemStatus` dell'articolo 

### getItemsByOrderLine
Questo endpoint ritorna la lista filtrata degli articoli in base al loro ordine, si aspetta il parametro `oderLine` basato sulla proprietà `OrderLineNo` dell'articolo 

## MUTAZIONI 

### postQuantityAdjustment
Questo endpoint riceve l'identificativo dell'articolo e la quantità da inserire in `ActualQuantity`, controllerà poi il parametro `Adjustment` e nel caso fosse negativo, creerà un record di `WAR_InventoryEntry`


# Codice 
```C# cpp fold title:WAR_InventoryOrderController 
// 
//

```

# Change Log
## 2.60.2
Creato


