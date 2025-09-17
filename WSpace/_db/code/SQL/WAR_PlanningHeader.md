---
Progetto: WSpace
Tipo: Code-Block
Categoria: Database
Versione: 2.60.2
Linguaggio: SQL
Repo: DBK_Suite
---
**Tags**

#Code #SQL  #WSpace #Backend #CreareOrdine #Tabella 
```toc
maxLevel:1
```

# Introduzione

Tabella che gestisce la creazione di nuovi ordini, modificata ed estesa nella Versione2.60.2, per supportare vari tipi di ordine. 

# Campi principali 

## Relazioni 
`ResourceNo` `CustomerNo` `FromBinNo` `ToBinNo` `ItemNo`

## Parametri Principali  
- `Type`  Il tipo di ordine, si veda [[PlanningHeaderType-Json]]
-  `OrderMode`  La modalità  dell'ordine, si veda [[PlanningHeaderOrderMode-Json]]
- `OrderStatus` Lo stato dell'ordine, si veda [[PlanningHeaderOrderStatus-Json]]
-  `IsCompleted` Lo stato finale dell'ordine, una volta che `OrderStatus` passa a `completed` lo si flagga con questo per rimuoverlo dall'interfaccia di WSpace 

# Codice 

```SQL cpp fold title:WAR_PlanningHeader
CREATE TABLE [dbo].[WAR_PlanningHeader] (

    [OrderID]              NVARCHAR (20)   NOT NULL,

    [Type]                 INT             DEFAULT ((0)) NOT NULL,

    [OrderMode]            INT             DEFAULT ((0)) NOT NULL,

    [OrderStatus]          INT             DEFAULT ((0)) NOT NULL,

    [ResourceNo]           NVARCHAR (20)   NULL,

    [CustomerNo]           NVARCHAR (20)   NULL,

    [CustomerName]         NVARCHAR (200)  NULL,

    [VendorNo]             NVARCHAR (50)   NULL,

    [VendorName]           NVARCHAR (100)  NULL,

    [DocumentNo]           NVARCHAR (50)   NULL,

    [FilterItemNo]         NVARCHAR (50)   NULL,

    [FilterItemCategoryNo] NVARCHAR (20)   NULL,

    [FilterLocationNo]     NVARCHAR (50)   NULL,

    [FilterZoneNo]         NVARCHAR (50)   NULL,

    [FilterBinNo]          NVARCHAR (50)   NULL,

    [StartDateTime]        DATE            NULL,

    [DueDate]              DATE            NULL,

    [CreatedDate]          DATE            NULL,

    [CreatedTime]          TIME (7)        NULL,

    [EndingDate]           DATE            NULL,

    [EndingTime]           TIME (7)        NULL,

    [IsCompleted]          BIT             DEFAULT ((0)) NOT NULL,

    [IsActive]             BIT             DEFAULT ((0)) NOT NULL,

    [CustString1]          NVARCHAR (200)  NULL,

    [CustString2]          NVARCHAR (200)  NULL,

    [CustDecimal1]         DECIMAL (18, 5) DEFAULT ((0)) NOT NULL,

    [CustDecimal2]         DECIMAL (18, 5) DEFAULT ((0)) NOT NULL,

    [CustBool1]            BIT             DEFAULT ((0)) NOT NULL,

    [CustBool2]            BIT             DEFAULT ((0)) NOT NULL,

    [CustDate1]            DATE            NULL,

    [CustDate2]            DATE            NULL,

    CONSTRAINT [PK_WAR_PlanningHeader] PRIMARY KEY CLUSTERED ([OrderID] ASC)

);

```


# Versioni

## 2.60.2 

### Colonne Rimosse 
Le seguenti colonne sono state rimosse dalla SELECT della vista perché non esistono nella struttura attuale della tabella:
- `h.IsItemInventory`
- `h.IsBinInventory`
- `h.IsLotCategoryInventory`
- `h.IsMatrixInventory`
- `h.IsLocationInventory`
- `h.IsZoneInventory`

### Colonne Aggiunte 
Le seguenti colonne sono state aggiunte alla vista per allinearla alla struttura corrente della tabella:
- `h.OrderMode` - Modalità dell'ordine
- `h.OrderStatus` - Stato dell'ordine
- `h.ResourceNo` - Numero risorsa
- `h.DocumentNo` - Numero documento





