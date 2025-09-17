---
Progetto: WSpace
Tipo: Pianificazione
Settimana: 23
Versione: 2.40.01
Argomento: Ordini
Feature: Ordini di Carico
---
# Introduzione 
Ci dedicheremo agli ordini di carico e scarico. Entrambi hanno una lista di articoli, entrambi vanno verificate, poi una aggiunge ILE, mentre l'alrta le toglie. 

# Procedimento di sviluppo 
## WEC 
### WAROrderController 
Verifichiamo la compatibilità per creare, assegnare, ricevere e spedire ordini di carico e spedizione. 
#### WARPlanningType 
Estendiamo il nostro Enum per comprendere i tipi `Ricezione` e uscita  `Uscita`   
#### WARPlanningStatus 
Estendiamo il nostro Enum per includere, `inTransit` `arrived`  `waiting` `toCollect`
### WARLoadingOrderController 
Creiamo questo controller per gestire gli ordini di Carico e Scarico 

## WSpace 

### OrderList 
- [ ] Estendiamo OrderList per visualizzare i due nuovi tipi di ordine.
- [ ] Nuove Icone per ordine di carico e di ricezione 
- [ ] Stessa `OrderListDeatils` ma con ordine di Scarico. 
- [ ] Creiamo un Modale come quello delle collocazioni e degli ordini ma per vedere le opzioni degli ordini (la lista dei tipi, o quelli assegnati a me)
- [ ] Aggiungiamo % di completamento per i vari ordini 
- [ ] Estediamo Ordine di zona Per Avere La lista delle collocazioni 

