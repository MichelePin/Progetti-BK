---
Progetto: Globale
Tipo: Istruzioni
Argomento: Installazione
Categoria: Onboarding
linked_documents:
date: 2025-07-17
tags:
  - Globale
  - Deploy
  - Istruzioni
  - Procedura
---

```table-of-contents
style: nestedList
maxLevel: 0
includeLinks: true
debugInConsole: false
```

  
## Intro 
Guida di onboarding per iniziare ad usare le repo di BKSolutions nel nostro PC


## Requisiti 
- PC 
- Accesso a internet 
- Accesso ai Repository 
- Speanza 

## Organizzazione delle cartelle 
Per facilita ed uniformita creiamo la cartella `C:/ProgettiBK/Repos/` dentro di questa creiamo cartelle per i tre linguaggi di programmazione usati in azienda `/NET` , `/ANGULAR` , `/NODE` 

## Scarichiamo le Repo 

### WEC
Il backend comune della Suite, contiene tutte le logiche ed utilita che fanno funzionare le nostre app, dovremmo scaricarlo con tutto il pacchetto legato alla suite. 
[Scarica il Progetto](https://bksolutions.visualstudio.com/BKS%20-%20BKSuite)

### BK Suite Dati 
Il database della nostra suite (e dell'asistenza) basato su SQL Server Manager 
[Scarica il Progetto](https://bksolutions.visualstudio.com/BKS%20-%20SUITE%20DATI)

### Mex System 
Soluzione per gestire la produzione in fabbrica 
[Scarica il Progetto](https://bksolutions.visualstudio.com/_git/APPBS%20-%20M.EX.SYSTEM%20OLD)

### eDoor 
Gestionale che premette di gestire dati ed operazioni nelle varie app 
[Scarica il Progetto](https://bksolutions.visualstudio.com/_git/APPBS%20-%20eDoor)

### WSpace 
Software per la gestione del magazzino 
[Scarica il Progetto](https://bksolutions.visualstudio.com/APPBS%20-%20WSpace)


## Creiamo siti nel nostro pc (opzionale)
Creare un collegamento simbolico (symlink) tra la cartella del progetto:

e la cartella di IIS:

Se esiste già un collegamento o una cartella con lo stesso nome, lo script la elimina prima di crearne uno nuovo.

### Procedimento

1. 	Apri PowerShell come amministratore
	• 	Cerca "PowerShell" nel menu Start
	• 	Fai clic destro su "Windows PowerShell" e seleziona "Esegui come amministratore"
2. 	Copia e incolla lo script seguente nella finestra di PowerShell:
   
	```powershell ccpfold title:CreateLinkedFolders
$target = "WSpace"
$link = "C:\inetpub\wwwroot\wspace"

# Controlla se il collegamento esiste
if (Test-Path $link) {
    # Rimuove l'elemento esistente (file, cartella o symlink)
    Remove-Item $link -Force
    Write-Host "Collegamento o cartella esistente rimossa: $link"
}

# Crea un nuovo collegamento simbolico
New-Item -ItemType SymbolicLink -Path $link -Target "C:\Code\Progetti-BK\IONIC\$target\www"
Write-Host "Nuovo collegamento simbolico creato: $link → $target"
```

3. 	Premi Invio per eseguire lo script.

⚠️ Note importanti
• 	È necessario avere diritti di amministratore per creare collegamenti simbolici in cartelle di sistema come .
• 	Se hai attivato la Modalità sviluppatore su Windows 10 o successivi, puoi creare symlink anche senza privilegi elevati, ma per IIS è comunque consigliato usare PowerShell come amministratore.
