---
Progetto: WSpace
Linguaggio: SQL
Tipo: Code-File
Ultima Modifica: 2025-07-18
Tags: ["WSpace", "SQL", "Code", "DBK_Suite"]
---
**Tags**

#WSpace #SQL #Code #DBK_Suite #CreareOrdine #Ordini #Tabella


```table-of-contents
Style: nestedList
maxLevel: 1
IncludeLinks: true
DebugInConsole: false
```

# Introduzione

Tabella creata per gestire i singoli oggetti nel db, viene calcolata la prima volta che apriamo l'ordine di inventario in WSpace. 

# Campi principali 

## Relazioni 
`ItemNo` `BinNo` `OrderLineNo`

## Quantità 
- `ExpectedQuantity`  Giacenze registrate 
 - `ActualQuantity` Giacenze effettive, quelle che si riscontrano quando andiamo a contare gli articoli assegnati 
 - `Adjustment` Calcolo della differenza tra quantità 
 

# Codice 
```SQL cpp fold title:WAR_PlanningInventoryItem 
  

CREATE TABLE [dbo].[WAR_PlanningInventoryItem]

(

    [EntryID] NVARCHAR(50) NOT NULL,

    [InsertDateTime] DATETIME NOT NULL DEFAULT GETDATE(),

    [ItemNo] NVARCHAR(50) NULL,

    [ItemDescription] NVARCHAR(100) NULL,

    [BinNo] NVARCHAR(50) NULL,

    [OrderLineNo] NVARCHAR(50) NULL,

    [ExpectedQuantity] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [ActualQuantity] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [Adjustment] AS (CAST([ActualQuantity] - [ExpectedQuantity] AS INT)) PERSISTED,

    [ItemStatus] INT NOT NULL DEFAULT 0,

    [CustString3] NVARCHAR(50) NULL,

    [CustString1] NVARCHAR(50) NULL,

    [CustString2] NVARCHAR(50) NULL,

    [CustDecimal3] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustDecimal1] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustDecimal2] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustBool2] BIT NOT NULL DEFAULT 0,

    [CustBool1] BIT NOT NULL DEFAULT 0,

    [CustDate1] DATE NULL,

    CONSTRAINT [PK_WAR_PlanningInventoryItem] PRIMARY KEY ([ID])

)

```

# Change Log
## 2.60.2
Creato 


