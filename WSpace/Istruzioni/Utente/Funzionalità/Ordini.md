# Introduzione 
Il modulo Ordini introduce una serie di strumenti, logiche e componenti per gestire il nostro magazzino. 
Ci sono 3 Tipi di ordine : Ordine di Inventario , Ordine di Prelievo, Ordine di Carico
# Caratteristiche Globali 
## Status 
Tutti gli ordini hanno dei passaggi di stato a seconda di dove si incontano nella loro lavorazione : 

- `In Attesa` 
- `Assegnato`
- `In Lavorazione`
- `Verifica`
- `Accettato`

## Assegnare un Ordine 
L'ordine puo essere assegnato o dal lato gestionale, o direttamente nella schermata `Lista Ordini` in WSpace 
### Lista Ordini 
Nella testata della pagina ci possiamo vedere il bottone `"Assegna a risorsa"` questo assegnera l'ordine 
# Ordine di Inventario 
## Introduzione 
La funzionalità di Ordine di Inventario ci consente di creare un flusso per verificare le giacenze nel nostro magazzino. L'ordine di Inventario puo essere di due tipi: 
- Spaziale (una o piu collocazioni)
- Unitario (un articolo in particolare )
## Spaziale 
Questo tipo di ordine assegna alla risorsa il compito di verificare i contenuti di una o piu collocazioni. Per completare l'ordine la risorsa dovra verificare tutti i contenuti delle collocazioni assegnate, confermando la quantita e segnalando possibili : rettifiche mancanze o eccessi di articoli. 

## Unitario 
Questo tipo di ordine assegna alla risorsa il compito di verificarele giacenze di un determinato articolo  una o piu collocazioni. Per completare l'ordine la risorsa dovra verificare tutte le collocazioni assegnate, confermando la quantita e segnalando possibili : rettifiche mancanze o eccessi di articoli. 