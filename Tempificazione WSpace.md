## **Controllo e verifica inventario manuale**



### **Mostrare un flusso da ordine d’inventario**

#### Spaziale

o   preparare un esempio per una zona

o   preparare un esempio per collocazione specifica

#### Oggetti

o   preparare un esempio per un inventario di lotto

o   preparare un esempio per un inventario di articolo

## **Predisporre in e-door per il consenso all’inventario**
come detto in precedenza non posso quantificare il tempo o gli sviluppi necessari per implementare questo su e-door l'app e ancora in ionic 3, ci sarebbe da considerare alemno una giornata solo per far girare la repo visti i vari intoppi avuti con le altre, per non parlare delle problematiche che verrebbero da dover lavorare su qualcosa su cui non ho mai messo le mani. Valutare di assegnare questo a Francesco se valuta di metterci meno di 40 ore 

·        Creare una voce di menu w-Space

·        Creare una pagina lista per mostrare i possibili inventari non autorizzati con possibili azioni:

o   Crea un ordine d’inventario per collocazione, articolo, lotto per la riga selezionata della lista.

o   Cancellare un movimento di rettifica

o   Autorizzare uno o più movimenti di rettifica non necessariamente tutti

## **Gestione prelievo**

### **Predisporre un esempio per il prelievo manuale** 

·        Predisporre un esempio completo 

·        Predisporre un esempio per l’ordine di prelievo

o   Prevedere in riga dell’ordine di prelievo le possibili collocazioni di destinazione: Collocazione1|Collocazione2|etc(. implementato)

o   Rendere impossibile il trasferimento di merce in destinazioni diverse (4ore)
- creazione di nuovi controller
- estensione di controller gia esistenti 
- visualizzazione in wspace (portebbe essere un problema uscire dagli schemi di visualizzazione attuale)

o   È possibile trasferire solo la merce nelle destinazioni consentite e solo dopo aver indicato la collocazione di destinazione. 
Vorrei far notare che è sempre possibile sparare su un bar-code e rilevare che è una collocazione in autonomia.(ad oggi la funzionalita di riconoscimento barcode e qr di wspace ci permette di riconoscere: atricoli, collocazioni, ed imballi )

## **Ricezione manuale**

·        **Tipo di carico:** In base alla zona prevedere se esiste solo un modo per ricevere la merce, in alternativa far selezionare all’utente: Carico manuale, Carico per bar-code, Carico con AI (al momento disabilitato) (4ore )
Nessun tipo di logicadi questo tipo e presente in wspace al momento 

·        **Se il carico è manuale:**

o   Chiedere il nome del fornitore, il nr. Dell’ordine e procedere a filtrare le righe della Pla_orders (16ore minimo) 
Nessuna di queste funzionalita o logiche e ad oggi presente in WSpace 

o   Permettere di selezionare una riga e indicare le quantità ricevute (2ore)

o   Registrare la pre-bolla simile alla Pla-Order con il Nr.2 un intero progressivo per nr. Ordine che parte sempre da 1. (2ore + 1ora almeno per tabelle)

o   Mostrare il riepilogo della pre-bolla con la possibilità di fare delle correzioni, cancellare delle righe e autorizzare la registrazione (8 ore)
Di nuovo ci scontreremo con creare un novo componente con molteplici logiche di cambio e vari livelli di autorizzazione, ricordiamoci che solo per testare ogni bottone, riga, flusso, bisogna ricaricare l'App 40 secondi alla volta. 

o   A seconda di un setup la registrazione:

§  Crea i movimenti fiscali e le bin entry (2ore)
Non dovrebbe essere poi cosi diverso da WAR_ILE

§  Mette il documento in uno stato in attesa di autorizzazione(1ora)


o   Sviluppare una rest-api per autorizzare lo stato della pre-bolla in autorizzato accertandosi che il nr. Della pre-bolla si corretto, i record siano uguali, che la lista degli articoli siano gli stessi, che le unità di misura siano uguali, che le quantità siano uguali. Ci aspettiamo quindi un Json con le righe caricate nel gestionale. (10ore minimo )

o   Prevedere la possibilità di stampare un’etichetta (1ora)
Si puo attaccare un barcode e richiamare il numero di bolla, per poi visualizzarla sullo schermo. Impossibile da realizzare se la task richiede accesso a Telerik, sono sprovvisto delle credenziali come evidenziato e riportato molteplici volte negli ultimi mesi. 

o   Prevedere di dichiarare fin da subito l’imballo oggi presente in W-Space (vedi lavoro di Francesco) 
ad ora la funzionalita degli imballi sembra abbastanza completa : ci permette di creare imballi, cercarli, caricare e scaricare, e anche aprire ed aggiungere o rimuovere articoli 

o   Prevedere di generare le matricole manuali o automatiche da Serial No. (20 ore)
stravolgerebbe completamernte il processo di WSpace, ora gli oggetti sono riferiti con ItemNo, sono intesi come identificativi di quel tipo di oggetto e TUTTA la soluzione WSpace si basa su questo fondamentale, implementare qualcosa del gemere significherebbe, riscrivere gran parte della business logic praticamente da zero, tanto nel frontend che nel backend. 

o   Prevedere di generare i lotti manualmente o automaticamente da Serial No. 
Se come nel caso di henge i lotti fossero "impliciti" sarebbe piu facile, ma richiederebbe comunque uno sforzo impegnativo visto che la logica del lotto e praticamente assente tranne `lotTracking` un booleano, non presente in controller, e pattern di sviluppo. 

·        **Se il carico è bar-code**

o   Leggo il bar-code e trovo il fornitore e l’ordine apro la stessa lista manuale

o   Con i successivi bar-code cerco solo gli articoli, non posso scansionare etichette di altri fornitori diversi dal primo.

o   Se mi da un errore posso lavorare in manuale come per il punto precedente.

