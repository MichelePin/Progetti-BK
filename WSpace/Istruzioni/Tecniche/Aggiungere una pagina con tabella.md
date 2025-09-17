---
Progetto: WSpace
Tipo: Istruzioni-Tecniche
Categoria: Componenti
Argomento: Creare-Pagina
Linguaggio: Typescript
Versione: 2.60.2
---
**Tags**
#Tutorial #Componenti #Grid #StepByStep



  ```toc 
  maxLevel:2
```

## Panoramica Generale

  

Questa guida documenta il processo completo per creare pagine con tabelle nel progetto WSpace, seguendo i pattern architetturali consolidati. Il sistema è basato su un'architettura provider-model con gestione dedicata dei dati e navigazione strutturata.

  

## Architettura del Sistema

  

### Componenti Principali

  

Il sistema WSpace utilizza una struttura modulare composta da:

  

1. **PageDataContainer**: Container centralizzato per tutti i dati delle pagine

2. **TableListPageData**: Classe base per pagine con multiple griglie

3. **TablePageData**: Classe base per pagine con singola tabella

4. **ComponentBuilderProvider**: Gestore per la creazione di componenti UI

5. **NavProvider**: Gestore della navigazione tra pagine

6. **Provider Services**: Servizi specifici per ogni funzionalità

  

### Pattern Architetturali

  

- **Provider Pattern**: Ogni funzionalità ha un provider dedicato (es. `InventoryOrderListPageProvider`)

- **Data Container Pattern**: Dati centralizzati nel `PageDataContainer`

- **Template Pattern**: Uso di template per la renderizzazione consistente

- **Builder Pattern**: `ComponentBuilderProvider` per costruire componenti complessi

  

## Creazione di una Nuova Pagina con Tabella

  

### 1. Creazione della Classe Dati Dedicata

  

Ogni pagina deve avere una classe dati dedicata che estende `TableListPageData` o `TablePageData`:

  

**Per pagine con multiple tabelle** (come ordini di prelievo/inventario):

  

- Estendere `TableListPageData`

- Proprietà: `gridModelList` (array di griglie)

- Metodo chiave: `addGridModel()` per aggiungere griglie

  

**Per pagine con singola tabella** (come liste semplici):

  

- Estendere `TablePageData`

- Proprietà: `gridModel` (singola griglia)

- Metodo chiave: `setGridModel()` per impostare la griglia

  

### 2. Integrazione nel PageDataContainer

  

Il `PageDataContainer` deve essere aggiornato per includere la nuova classe dati:

  

**Elementi da aggiungere:**

  

- Import della nuova classe dati

- Campo privato per l'istanza della classe

- Metodo getter pubblico per accedere ai dati

- Inizializzazione nel costruttore (se necessario)

  

**Metodi chiave del PageDataContainer:**

  

- `getBinListPageData()`: Restituisce dati collocazioni

- `getPickingOrderData()`: Restituisce dati ordini prelievo

- `getInventoryOrderData()`: Restituisce dati ordini inventario

- `getOrderListData()`: Restituisce dati lista ordini generica

  

### 3. Creazione del Provider Service

  

Ogni pagina ha un provider dedicato che gestisce logica e navigazione:

  

**Struttura del Provider:**

  

- Decorator `@Injectable({ providedIn: "root" })`

- Dependency injection di servizi necessari

- Metodi per caricamento dati dal server

- Metodi per creazione template pagina

- Metodi per gestione azioni utente

  

**Metodi Standard del Provider:**

  

- `loadPage()`: Carica la pagina principale

- `loadPageData()`: Carica dati dal server

- `createPageTemplate()`: Crea il template della pagina

- `openDetails()`: Apre pagine di dettaglio

- `handleActions()`: Gestisce azioni specifiche

  

## Pattern di Implementazione Consolidati

  

### Pattern per Pagine Multi-Griglia (TableListPageData)

  

**Esempio: PickingOrderProvider e InventoryOrderListPageProvider**

  

**Metodi chiave per multi-griglia:**

  

1. `mergePageConfig()`: Merge configurazione dal server

2. Reset lista: `pageData.gridModelList = []`

3. `addGridModel()`: Aggiunge ogni griglia con ID univoco

4. `buildSubmenuModel()`: Crea menu con azioni header

5. `setTableListTemplateRoot()`: Naviga alla pagina

  

**Proprietà specifiche TableListPageData:**

  

- `gridModelList`: Array di modelli griglia

- `getOnlyActiveModel()`: Restituisce griglia attiva

- `getSelectedItem()`: Restituisce elemento selezionato

- `onItemSelected()`: Gestisce selezione elementi

  

### Pattern per Pagine Singola Griglia (TablePageData)

  

**Esempio: BinListPageProvider**

  

**Metodi chiave per singola griglia:**

  

1. `updateTablePageData()`: Aggiorna dati tabella

2. `setGridModel()`: Imposta la griglia principale

3. `buildSubmenuModel()`: Crea menu azioni

4. `setTableTemplateRoot()`: Naviga alla pagina

  

**Proprietà specifiche TablePageData:**

  

- `gridModel`: Singolo modello griglia

- `createGridModel()`: Crea modello griglia

- `getSelectedItem()`: Restituisce elemento selezionato

  

### Pattern di Navigazione

  

**Navigazione Multi-Griglia:**

  

- Utilizza `NavProvider.setTableListTemplateRoot(pageData)`

- Gestisce multiple griglie attive/inattive

- Supporta selezione cross-griglia

  

**Navigazione Singola Griglia:**

  

- Utilizza `NavProvider.setTableTemplateRoot(pageData)`

- Gestione semplificata selezione

- Focus su singola tabella

  

## Gestione delle Azioni e Menu

  

### SubmenuModel e Azioni Header

  

**Creazione del Menu Header:**

  

- `buildSubmenuModel()`: Accetta titolo, lista azioni e oggetto sorgente

- Supporta pattern di titolo dinamico tramite `TitleSourcePattern`

- Gestione automatica visibilità azioni su schermi diversi

  

**Tipi di Azioni:**

  

- `BasicAction`: Azioni semplici header

- `Action`: Azioni complete con ID per tracking

- Azioni riga: `leftActions`, `lastCellAction`

  

**ActionID e Tracking:**

  

- Ogni azione ha un ID univoco per debugging

- Pattern naming: `MODULENAME_ACTIONNAME`

- Esempi: `BINITEMLIST_ADDITEM`, `INVENTORYORDERLIST_ASSIGNTORESOURCE`

  

### GridBuilderParams e Configurazione Griglie

  

**Parametri di Configurazione Griglia:**

  

- `createRowFn`: Funzione per creare righe personalizzate

- `defaultTitle`: Titolo della griglia

- `id`: Identificativo univoco (per multi-griglia)

- `tableJsonConfig`: Configurazione colonne dal server

- `records`: Dati da visualizzare

- `selectRowOnCreate`: Selezione automatica prima riga

  

**Configurazioni Avanzate:**

  

- `gridActionList`: Azioni header griglia

- `recordToSelect`: Record da selezionare automaticamente

- `recordToSelectFieldNames`: Campi per matching record

- `pageJsonConfigServer`: Configurazione completa dal server

  

## Comunicazione con il Server

  

### RequestBuilder e Pattern Richieste

  

**Creazione Richieste Standard:**

  

- `RequestBuilder.createJSWarRequest()`: Richiesta base WAR

- Include automaticamente: token, device, risorsa, zona

- Pattern per richieste specifiche con classi dedicate

  

**Classi Richieste Specializzate:**

  

- `JSWarInventoryOrderRequest`: Per ordini inventario

- `JSWarFilterRequest`: Per ricerche filtrate

- Estendono sempre classe base con parametri comuni

  

**Metodi Server Standard:**

  

- `httpPost()`: Chiamata POST standard

- Pattern URL: `/Api/ModuleName/ActionName`

- Gestione errori automatica con response validation

  

### Pattern Caricamento Dati

  

**Flusso Standard Caricamento:**

  

1. Validazione parametri input

2. Creazione richiesta con `RequestBuilder`

3. Chiamata server con `ServerProvider.httpPost()`

4. Validazione response ricevuta

5. Merge configurazione pagina

6. Assegnazione dati a pageData

7. Creazione template e navigazione

  

**Gestione Errori:**

  

- Validazione parametri obbligatori

- Check presenza dati in response

- Gestione flag `Success` nelle response

- Display errori tramite `ControllerProvider.showErrorAlert()`

  

## ComponentBuilderProvider e Gestione UI

  

### Metodi di Creazione Componenti

  

**Per TableListPageData (Multi-Griglia):**

  

- `addGridModel()`: Aggiunge griglia a lista esistente

- Gestisce ID univoci per ogni griglia

- Supporta stato attivo/inattivo griglie

  

**Per TablePageData (Singola Griglia):**

  

- `setGridModel()`: Imposta griglia principale

- `updateTablePageData()`: Aggiorna dati esistenti

- Gestione semplificata senza ID griglia

  

**Metodi Comuni:**

  

- `createForm()`: Crea form dinamiche

- `openModalForm()`: Apre form in modale

- `createTemplatePageData()`: Crea template pagina

  

### Configurazione JSON e PageConfig

  

**Merge Configurazione:**

  

- `mergePageConfig()`: Unisce config server con locale

- `createPageConfig()`: Processa configurazione iniziale

- Supporto configurazioni multiple per griglie diverse

  

**Strutture Configurazione:**

  

- `TablePageConfig`: Configurazione base tabella

- `BinItemListPageConfig`: Estensione per collocazioni

- Configurazioni form: `FormJsonConfig`

- Configurazioni modal: parametri stile e comportamento

  

## Gestione dello Stato e Selezione

  

### GridModel e Stato Griglie

  

**Gestione Stato Multi-Griglia:**

  

- `getOnlyActiveModel()`: Restituisce unica griglia attiva

- `onItemSelected()`: Disattiva altre griglie quando una è selezionata

- `inactive` property: Controlla stato attivo/inattivo

  

**Selezione Elementi:**

  

- `getSelectedItem()`: Restituisce elemento corrente

- `selectCell()`: Selezione programmatica

- `selectRowOnCreate`: Selezione automatica alla creazione

  

**Gestione Factbox:**

  

- `updateDetailFactbox()`: Aggiorna pannello dettagli

- Configurazione tramite `DetailFactboxConfig`

- Sincronizzazione automatica con selezione

  

### Pattern di Ricaricamento e Aggiornamento

  

**Ricaricamento Pagina:**

  

- Mantenimento selezione tramite `recordToSelect`

- Aggiornamento dati senza perdere stato UI

- Gestione loading states con `AppManagerProvider`

  

**Parametri Persistenza:**

  

- `originalRow`: Record precedentemente selezionato

- `recordToSelectFieldNames`: Campi per matching record

- Ricostruzione stato dopo operazioni server

  

## Integrazione con Sistema Esistente

  

### Dependency Injection e Provider

  

**Provider Standard Richiesti:**

  

- `AppManagerProvider`: Gestione loading e stati app

- `ControllerProvider`: Gestione alert, modal, toast

- `NavProvider`: Navigazione tra pagine

- `ServerProvider`: Comunicazione server

- `ComponentBuilderProvider`: Creazione componenti UI

  

**Provider Specializzati:**

  

- `BinProvider`: Gestione collocazioni

- `ItemListPageProvider`: Gestione articoli

- `PackagingProvider`: Gestione imballi

- Provider custom per funzionalità specifiche

  

### AppModel e Gestione Stato Globale

  

**Accesso Stato Globale:**

  

- `AppModel.getInstance()`: Singleton pattern

- `getPageDataContainer()`: Accesso container dati

- `getWarehouseModel()`: Dati magazzino corrente

- `getResource()`: Risorsa utente corrente

  

**Configurazioni Globali:**

  

- `getGeneralConfig()`: Configurazioni generali

- `getDeviceSetup()`: Setup dispositivo

- Configurazioni default per tabelle e form

  

## Best Practices e Convenzioni

  

### Naming Conventions

  

**Classi Dati:**

  

- Pattern: `[Functionality]Data` (es. `InventoryOrderData`)

- Estensione: `TableListPageData` o `TablePageData`

- Location: `src/app/classes/page-data/`

  

**Provider Services:**

  

- Pattern: `[Functionality]PageProvider` (es. `InventoryOrderListPageProvider`)

- Decorator: `@Injectable({ providedIn: "root" })`

- Location: `src/app/services/page/`

  

**Metodi Standard:**

  

- `load[Page]Page()`: Caricamento pagina principale

- `load[Page]Data()`: Caricamento dati dal server

- `create[Page]Template()`: Creazione template

- `open[Detail]()`: Apertura dettagli

  

### Gestione Errori

  

**Pattern Validazione:**

  

- Validazione parametri all'inizio metodi

- Throw di messaggi descrittivi

- Utilizzo `Warning` class per avvisi non critici

  

**Gestione Response Server:**

  

- Check esistenza response

- Validazione flag `Success`

- Gestione messaggi errore custom

  

**User Feedback:**

  

- `showErrorAlert()`: Errori critici

- `showToast()`: Conferme e info

- `showWarning()`: Avvisi non bloccanti

  

### Performance e Ottimizzazione

  

**Caricamento Dati:**

  

- Lazy loading dove possibile

- `handleDefaultLoading()`: Indicatori loading

- Caching configurazioni statiche

  

**Gestione Memoria:**

  

- Reset `gridModelList` prima ricaricamento

- Cleanup listener e subscription

- Riutilizzo istanze PageData

  

## Troubleshooting Comune

  

### Problemi di Navigazione

  

**Pagina vuota con solo titolo:**

  

- Verificare uso corretto `addGridModel()` vs `setGridModel()`

- Controllare `setTableListTemplateRoot()` vs `setTableTemplateRoot()`

- Validare presenza `pageData.gridModelList = []` per multi-griglia

  

**Errori container dati:**

  

- Verificare presenza metodo getter in `PageDataContainer`

- Controllare import classe dati

- Validare inizializzazione campo privato

  

### Problemi Configurazione

  

**Configurazione mancante:**

  

- Verificare `mergePageConfig()` chiamato prima creazione template

- Controllare presenza `PageConfig` in response server

- Validare struttura JSON configurazione

  

**Errori ID griglia:**

  

- Assegnare ID univoci a ogni griglia in multi-griglia

- Verificare coerenza ID tra `addGridModel()` e riferimenti

  

### Problemi Server Communication

  

**Errori chiamate API:**

  

- Validare URL endpoint formato `/Api/Module/Action`

- Controllare parametri richiesta con `RequestBuilder`

- Verificare response format e flag `Success`

  

**Timeout o errori rete:**

  

- Implementare retry logic dove necessario

- Gestire stati loading appropriati

- Fornire feedback utente significativo

  

---

  

_Documento aggiornato per WSpace 2.3.0.62