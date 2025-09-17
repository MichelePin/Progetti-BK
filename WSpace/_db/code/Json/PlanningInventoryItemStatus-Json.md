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

#WSpace #Json #Code #DBK_Suite #Ordini  #Inferface 

**Usato In**
[[WAR_PlanningInventoryItem-SQL]]

```table-of-contents
maxLevel: 1
```

# Introduzione

Gestione dello Status di un articolo nell'ordine di inventario 

# Campi 
- `Pending` : Status di default, in attesa di revisione da parte dell'utente 
- `Confirmed` : Status finale dell'articolo, una volta completato l'ordine e confermato (se necessario) dal supervisore 
- `RevisionNeeded` : Status in cui mettiamo l'articolo al completamento dell'ordine, una volta inventariato.
- `ongoing` : Status Intermedio in cui mettiamo l'articolo una volta iniziato l'ordine,
- `needsMoving` : Status che assegniamo in caso la riconciliazione sia prevista al termine del conteggio 
- `missing` : Status in cui mettiamo se l'articolo non si trova 



# Codice 
```Json cpp fold title:PlanningInventoryItemStatus 
{

  "ItemStatus": {

    0: "pending",

    1: "confirmed",

    2: "revisionNeeded",

    3: "ongoing",
    
    4: "needsMoving",
    5: "missing"

  }

}

```

# Change Log
## 2.60.2
Creato 


