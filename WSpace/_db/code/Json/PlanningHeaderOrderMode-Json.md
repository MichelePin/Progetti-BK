---
Progetto: WSpace
Linguaggio: Json
Tipo: Code-File
Ultima Modifica: 2025-07-18
tags:
  - WSpace
  - Json
  - Code
  - DBK_Suite
Versione: 2.60.3
Repo: WEC
Categoria: Enums
---
**Tags**

#WSpace #Json #Code #DBK_Suite #Ordini #CreareOrdine #Inferface

**Riferimenti**
[[WAR_PlanningHeader]]
```table-of-contents
maxLevel: 1
```

# Introduzione

Interfaccia per la gestione del metodo di ordine, per ora con riferimento a quelli di inventario 
- `NotNeeded` : placeholder e campo standard, sia per retrocompatibilità che per quelli che non lo utilizzano 
-  `BinInventory` :  inventariare tutti gli articoli di una collocazione, si farà riferimento al parametro `filterBinNo` in `WAR_PlanningHeader`
-  `ZoneInventory` :  inventariare tutti gli articoli di una zona, si farà riferimento al parametro `filterZoneNo` in `WAR_PlanningHeader`
- `ItemInventory` :  inventariare tutti gli articoli di una collocazione, si farà riferimento al parametro `filterItemNo` in `WAR_PlanningHeader`

# Codice 
```Json cpp fold title:PlanningHeaderOrderStatus 
{"PlanningHeaderType": {

    0: "notNeeded",

    1: "BinInventory",

    2: "ZoneInventory",
    3: "itemInventory"
  }
}
```

# Change Log
## 2.60.3
Creato
