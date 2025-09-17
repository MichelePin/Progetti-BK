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
Categoria: Tabella
---
**Tags**

#WSpace #Json #Code #DBK_Suite #Ordini #CreareOrdine #Inferface

**Usato in**
[[WAR_PlanningHeader]]
```table-of-contents
maxLevel: 1
```

# Introduzione

Interfaccia per la gestione del tipo di Ordine 0 di default: 
-  `Picking` : ordine di prelievo, già presente ed implementato 
-  `Inventory` : ordine di inventario 
- `Incoming` : ordine di ricezione 

# Codice 
```Json cpp fold title:PlanningHeaderType 
{"PlanningHeaderType": {

    0: "inventory",

    1: "picking",

    2: "incoming",
	
	3 : "moving"
  }
}
```

# Change Log
## 2.60.2
Creato
