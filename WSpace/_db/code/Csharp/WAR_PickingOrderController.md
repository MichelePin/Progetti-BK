---
Progetto: WSpace
Linguaggio: Csharp
Tipo: Code-File
Ultima Modifica: 2025-07-23
Tags: ["WSpace", "Csharp", "Code", "WEC"]
---
**Tags**

#WSpace #Csharp #Code #WEC

```table-of-contents
maxLevel: 1
```

# Introduzione

Descrizione del file e la sua funzionalità


# Codice 
```Csharp cpp fold title:WAR_PickingOrderController 
using ABK;

using ABK.Library.Utility;

using ABK.Library.WSpace;

using Newtonsoft.Json.Linq;

using SCL.JSON;

using System;

using System.Linq;

using System.Web.Http;

  

namespace WEC.Controllers

{

    /// <summary>

    /// Controller per la gestione degli ordini di prelievo nel magazzino (Warehouse Picking Orders).

    /// Fornisce funzionalità per il caricamento, prelievo e rimozione di righe ordine nel sistema WEC.

    ///

    /// Funzionalità principali:

    /// - Caricamento dati ordini di prelievo con calcolo quantità in transito

    /// - Gestione prelievo righe ordine con creazione movimenti di magazzino

    /// - Rimozione righe dal carrello virtuale

    ///

    /// Versione: 2.3.0.241 - Aggiornamenti per gestione quantità in transito con segno positivo

    /// </summary>

    /// <remarks>

    /// IMPORTANTE: Questo controller gestisce il "carrello virtuale" per i prelievi.

    /// Le quantità in transito vengono ora gestite con segno positivo (BKPRV#23017).

    /// </remarks>

    public class WARPickingOrderController : ApiController

    {

        /// <summary>

        /// Carica i dati di un ordine di prelievo specifico includendo le righe ordine e gli elementi del carrello virtuale.

        /// </summary>

        /// <param name="Request">Richiesta contenente l'ID dell'ordine da caricare</param>

        /// <returns>

        /// Oggetto JSON contenente:

        /// - PageConfig: Configurazione pagina per l'interfaccia utente

        /// - OrderRows: Lista delle righe dell'ordine di prelievo con quantità aggiornate

        /// - BinEntryList: Lista degli elementi del carrello virtuale in transito

        /// </returns>

        /// <exception cref="ArgumentException">Quando l'OrderID non è fornito o è vuoto</exception>

        /// <remarks>

        /// Versione: 2.3.0.112 BKPRV#21076 - Implementazione iniziale

        /// Versione: 2.3.0.241 BKPRV#23017 - Aggiornamento gestione quantità con segno positivo

        ///

        /// LOGICA CALCOLO QUANTITÀ:

        /// - TransitQuantity: Somma delle quantità rimanenti per righe in transito (segno positivo)

        /// - RemainingQuantity: Quantità originale - Quantità in transito

        ///

        /// TODO: La gestione del carico dal carrello virtuale necessita di revisione futura

        /// </remarks>

        [HttpPost]

        public object LoadPickingOrderData(JSWarPlanning Request)

        {

            try

            {

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                {

                    // Validazione input obbligatorio

                    if (string.IsNullOrEmpty(Request?.OrderID))

                        SCL.Utility.ErrorOutput("Id ordine non ricevuto!", "LoadPickingOrder");

  

                    // Caricamento righe ordine dal database

                    var OrderRows = db.WAR_PlanningLine.Where(p => p.OrderID == Request.OrderID).ToList();

  

                    var GDBBinEntry = new GDB.WARBinEntry();

  

                    // Caricamento elementi carrello virtuale per l'ordine specifico

                    // NOTA: Al momento vengono caricate solo le righe del carrello in transito

                    var VirtualRowEntryList = GDBBinEntry.GetList(db, new GDB.FilterWARBinEntry

                    {

                        _AnyType = true,

                        OrderNo = Request.OrderID,

                        Transit = true

                    });

  

                    // Calcolo quantità per ogni riga ordine

                    foreach (var Row in OrderRows)

                    {

                        // Filtro elementi carrello per la riga corrente

                        var RowBinEntryList = VirtualRowEntryList.Where(p => p.OrderLineNo == Row.OrderLineID).ToList();

  

                        // Calcolo quantità in transito (somma elementi con flag Transit = true)

                        Row.TransitQuantity = RowBinEntryList.Where(p => p.Transit).Sum(t => t.RemainingQuantity);

  

                        // Calcolo quantità rimanente (da semplificare in versioni future)

                        Row.RemainingQuantity = Row.Quantity - Row.TransitQuantity;

                    }

  

                    // Costruzione risposta JSON

                    return JObject.FromObject(new

                    {

                        PageConfig = PageConfigUtility.GetConfigPages("WAR_PickingOrder", Request),

                        OrderRows,

                        BinEntryList = VirtualRowEntryList // Righe del carrello virtuale

                    });

                }

            }

            catch (Exception e)

            {

                return BadRequest(Message.ErrorOutput(e, "LoadPickingOrder", Request.RequestDevice));

            }

        }

  

        /// <summary>

        /// Registra il prelievo di una riga ordine creando un nuovo movimento nel carrello virtuale.

        /// </summary>

        /// <param name="Request">Richiesta contenente i dati della riga da prelevare</param>

        /// <returns>Risultato OK se l'operazione è completata con successo</returns>

        /// <exception cref="ArgumentException">Quando la riga non è fornita o la quantità non è valida</exception>

        /// <exception cref="ArgumentOutOfRangeException">Quando la quantità è minore o uguale a zero</exception>

        /// <changes>

        /// Versione: 2.3.0.112 BKPRV#21076 - Implementazione iniziale

        /// Versione: 2.3.0.241 BKPRV#23017 - Allineamento modifiche quantità e segno

        /// </changes>

        /// <remarks>

        ///

        /// PROCESSO DI PRELIEVO:

        /// 1. Validazione dati input (riga e quantità)

        /// 2. Creazione nuovo record WAR_BinEntry con flag Transit = true

        /// 3. Salvataggio nel database

        ///

        /// CAMPI UTILIZZATI DALL'APP:

        /// - FromBinNo: Collocazione di partenza

        /// - NewQuantity: Quantità da prelevare

        /// - FromLocationNo: Dovrebbe rimanere fissa

        ///

        /// </remarks>      

        ///  <todo>

        /// - Controllare corrispondenza magazzino di login con riga ordine

        /// - Implementare gestione doppio movimento con collocazione partenza

        /// </todo>

        [HttpPost]

        public object OrderRowPicked(OrderRowPickingRequest Request)

        {

            try

            {

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                {

                    // Validazione richiesta base

                    WSpaceUtility.CheckBasicRequestData(Request.Request);

  

                    // Validazione dati specifici

                    if (Request?.PlanningLine == null)

                        SCL.Utility.ErrorOutput("Riga non ricevuta", "OrderRowPicked");

  

                    if (Request.PlanningLine.NewQuantity <= 0)

                        SCL.Utility.MessageOutput("Inserire una quantità positiva!", "OrderRowPicked");

  

                    var Line = Request.PlanningLine;

  

                    // Creazione nuovo movimento di prelievo nel carrello virtuale

                    var NewBinEntry = new WAR_BinEntry

                    {

                        InsertDateTime = DateTime.Now,

                        OrderNo = Line.OrderID,

                        OrderLineNo = Line.OrderLineID,

                        OrderKey = Line.OrderKey,

                        Type = (int)SCL.EC.WarehousePlanningType.Picking,

                        ItemNo = Line.ItemNo,

                        Quantity = Line.NewQuantity,                    // Quantità prelevata

                        RemainingQuantity = Line.NewQuantity,           // Quantità rimanente (inizialmente = quantità)

                        OriginalQuantity = Line.RemainingQuantity,      // Quantità originale riga

                        UnitOfMeasure = Line.UnitOfMeasure,

                        BinNo = Line.FromBinNo,                         // Collocazione di prelievo

                        Transit = true                                  // Flag carrello virtuale

                    };

  

                    // Impostazione campi aggiuntivi dalla richiesta

                    new GDB.WARBinEntry().SetFieldsFromRequest(NewBinEntry, Request.Request);

  

                    // Salvataggio nel database

                    db.WAR_BinEntry.Add(NewBinEntry);

                    db.SaveChanges();

  

                    return Ok();

                }

            }

            catch (Exception e)

            {

                return BadRequest(Message.ErrorOutput(e, "OrderRowPicked", Request.Request.RequestDevice));

            }

        }

  

        /// <summary>

        /// Rimuove una riga dal carrello virtuale eliminando il movimento di prelievo precedentemente registrato.

        /// </summary>

        /// <param name="Request">Richiesta contenente i dati della riga da rimuovere</param>

        /// <returns>Risultato OK se l'operazione è completata con successo</returns>

        /// <exception cref="ArgumentException">Quando la riga o l'ID non sono forniti</exception>

        /// <exception cref="InvalidOperationException">Quando la riga non viene trovata nel database</exception>

        /// <remarks>

        /// Versione: 2.3.0.112 BKPRV#21076 - Implementazione iniziale

        /// Versione: 2.3.0.241 BKPRV#23017 - Limitazioni attuali documentate

        ///

        /// LIMITAZIONI ATTUALI:

        /// - Non è possibile fare storno + carico in questo punto

        /// - Non sempre è presente la collocazione di partenza originale

        /// - Operazione limitata alla semplice cancellazione del record

        ///

        /// TODO:

        /// - Modificare dopo conferma gestione prelievo come spostamento manuale

        /// - Implementare gestione completa storno con collocazione partenza

        ///

        /// ATTENZIONE: Questa funzione non può essere modificata facilmente

        /// a causa delle limitazioni architetturali attuali.

        /// </remarks>

        [HttpPost]

        public object OrderRowRemoved(DeleteVirtualBinEntryRequest Request)

        {

            string Where = "OrderRowRemoved";

  

            try

            {

                using (DBK_SuiteEntities db = new DBK_SuiteEntities())

                {

                    // Validazione input

                    if (Request?.BinEntry == null)

                        SCL.Utility.ErrorOutput("Riga non ricevuta", Where);

  

                    if (Request.BinEntry.EntryID == 0)

                        SCL.Utility.ErrorOutput("Id riga non ricevuto", Where);

  

                    var Line = Request.BinEntry;

  

                    // Ricerca riga nel database

                    var BinEntry = db.WAR_BinEntry.FirstOrDefault(b => b.EntryID == Request.BinEntry.EntryID);

  

                    if (BinEntry == null)

                        SCL.Utility.ErrorOutput("Riga non trovata!", Where);

  

                    // Rimozione fisica del record

                    db.WAR_BinEntry.Remove(BinEntry);

                    db.SaveChanges();

  

                    return Ok();

                }

            }

            catch (Exception e)

            {

                return BadRequest(Message.ErrorOutput(e, Where, Request?.Request?.RequestDevice));

            }

        }

    }

  

    /// <summary>

    /// Classe per le richieste di pianificazione magazzino.

    /// Estende JSWarRequest aggiungendo l'identificativo dell'ordine.

    /// </summary>

    public class JSWarPlanning : JSWarRequest

    {

        /// <summary>

        /// Identificativo univoco dell'ordine di prelievo da gestire.

        /// Campo obbligatorio per tutte le operazioni.

        /// </summary>

        public string OrderID { get; set; }

    }

  

    /// <summary>

    /// Classe per le richieste di prelievo riga ordine.

    /// Contiene i dati necessari per registrare un prelievo.

    /// </summary>

    public class OrderRowPickingRequest

    {

        /// <summary>

        /// Dati base della richiesta (utente, dispositivo, sessione, etc.)

        /// </summary>

        public JSWarRequest Request { get; set; }

  

        /// <summary>

        /// Riga dell'ordine di pianificazione da prelevare.

        /// Deve contenere: OrderID, OrderLineID, NewQuantity, FromBinNo

        /// </summary>

        public WAR_PlanningLine PlanningLine { get; set; }

    }

}

```

# Change Log
## 2.60.2

