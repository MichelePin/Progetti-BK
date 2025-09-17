---
Progetto: WSpace
Linguaggio: SQL
Tipo: Code-File
Ultima Modifica: 2025-07-18
Tags: ["WSpace", "SQL", "Code", "DBK_Suite"]
---
**Tags**

#WSpace #SQL #Code #DBK_Suite  #Ordini #eDoor #Tabella



```table-of-contents
maxLevel: 1
```

# Introduzione

Tabella creata per gestire gli articoli che, alla fine dell'ordine di inventario, abbiano giacenze negative, viene poi richiamata nel gestionale per assemblare le conferme di rettifica 

# Campi principali 

## Relazioni 
`ItemNo` `OrderLineNo` `FromBinNo` `ToBinNo` `ItemNo`

## Quantità 
- `AdjustmentQuantity`  Differenza tra quantità registrata ed effettiva 
-  `isConfirmed` Lo stato dell'articolo, una volta confermato nel gestionale, si aggiustano le giacenze effettive nel magazzino 

# Codice 
```SQL cpp fold title:WAR_PlanningInventoryItem 
  

CREATE TABLE [dbo].[WAR_InventoryEntry]

(

    [EntryID] NVARCHAR(50) NOT NULL,

    [InsertDateTime] DATETIME NOT NULL DEFAULT GETDATE(),

    [OrderNo] NVARCHAR(20) NULL,

    [OrderLineID] NVARCHAR(50) NULL,

    [FromBinNo] NVARCHAR(50) NULL,

    [ToBinNo] NVARCHAR(50) NULL,  

    [ItemNo] NVARCHAR(50) NULL,

    [AdjustmentQuantity] INT NOT NULL DEFAULT 0,

    [ActionPerformed] INT NOT NULL DEFAULT 0,

    [IsManualEntry] BIT NOT NULL DEFAULT 0,

    [isConfirmed] BIT NOT NULL DEFAULT 0,

    [CustString3] NVARCHAR(50) NULL,

    [CustString1] NVARCHAR(50) NULL,

    [CustString2] NVARCHAR(50) NULL,

    [CustDecimal3] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustDecimal1] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustDecimal2] DECIMAL(18, 5) NOT NULL DEFAULT 0,

    [CustBool2] BIT NOT NULL DEFAULT 0,

    [CustBool1] BIT NOT NULL DEFAULT 0,

    [CustDate1] DATE NULL,

    CONSTRAINT [PK_WAR_InventoryEntry] PRIMARY KEY ([EntryID])

)

```

# Change Log
## 2.60.2
Creato 



