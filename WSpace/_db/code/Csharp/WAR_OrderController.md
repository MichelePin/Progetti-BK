---
Progetto: WSpace
Linguaggio: CSharp
Tipo: Code-File
Ultima Modifica: 2025-07-18
---
**Tags**

#WSpace #CSharp #CreareOrdine #Ordini #Inventario  #Code #WEC

```table-of-contents
maxLevel: 1
```

# Introduzione

Controller per gestire la creazione e consulta degli ordini (punto di entrata unico per tutti i tipi di ordine). 


# Metodi Principali
### GetOrderList
Questo endpoint ritorna una lista di ordini, accetta `OrderStatus`, `OrderType` , `OrderMode` come filtri, di default per retrocompatibilità, ritorna gli ordini di tipo 0 

### CreateNewOrder 
Questo endpoint permette la creazione di un nuovo ordine, di default per creerà, ordini di tipo 0, questo endpoint creerà l'header dell'ordine. Gli si possono passare parametri opzionali come `OrderMode` ed i filtri `filterItemNo`, `filterZoneNo`, `filterBinNo`, che userà per i creare le `WAR_PlanningLine` 




# Codice 
```CSharp cpp fold title:WAR_OrderController 
// 
//

```

# Change Log
## 2.60.2
Esteso il controller per poter creare ordini 

