---
Progetto: WSpace
Categoria: Enums
Linguaggio: Json
Tipo: Code-File
Ultima Modifica: 2025-07-18
Versione: 2.60.3
Repo: WEC
---
**Tags**

#WSpace #Json  #Code #DBK_Suite #Ordini #VerificaOrdine #Inferface

**Usato da**
[[WAR_PlanningHeader]]
```toc
maxLevel: 1
```

# Introduzione

Interfaccia per la gestione dello status dell'ordine 

- `Pending` : placeholder e campo standard, sia per retrocompatibilità che per quelli che non lo utilizzano 
- `assigned` : la risorsa ha confermato che si autoassegna un ordine 
- `confirmed` : nel gestionale vengono confermate le rettifiche  
- `revisionNeeded` : nel magazzino e stato portato a termine l'ordine, ma bisogna confermarlo nel gestionale 
- `ongoing` : l'ordine e in fase di lavorazione 


# Codice 


```Json cpp fold title:OrderStatus 
  {  "ItemStatus": {

    0: "pending",

    1: "confirmed",

    2: "revisionNeeded",

    3: "inProgress",

	4: "active"
    }
 }
```

```cs cpp fold title:OrderStatus 
public enum ItemStatus

{

    Pending = 0,

    Confirmed = 1,

    RevisionNeeded = 2,

    InProgress = 3,

    Active = 4

}
```

```ts cpp fold title:OrderStatus 
enum ItemStatus {

    Pending = 0,

    Confirmed = 1,

    RevisionNeeded = 2,

    InProgress = 3,

    Active = 4

}
```