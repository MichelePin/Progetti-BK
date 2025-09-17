---
project: Globale
feature: Deploy
type: Istruzioni
topic: Procedura
linked_documents: 
date: 2025-07-17
tags: ["Globale", "Deploy", "Istruzioni", "Procedura"]
---

```table-of-contents
style: nestedList
maxLevel: 0
includeLinks: true
debugInConsole: false
```

  

# Aggiornare tabelle del WEC

## Progetti necessari

- WEC

- DBK SUITE

- SQL Server Manager (facoltativo, per verificare)

## Prima di iniziare
### DBK Suite

Apriamo il progetto e ci assicuriamo di averlo in line con la ultima versione del main

    git fetch origin

### WEC

In ABK, assicuriamoci che il `webconfig`, punti al database di base DBK Suite BASE

## DBK SUITE

###  Lavoriamo con le Tabelle
Creiamo o modifichiamo le tabelle, poi quando siamo pronti clickiamo sul file `DBK Suite.publish`. Confermiamo che il  assicuriamoci che si punti al database di base DBK Suite BASE Questo allineerà le tabelle del DB di base.
### Aggiorniamo le Tabelle del database
Una fatto il passaggio di Sincronizzazione nel WEC, siamo pronti ad allineare le tabelle nel database reale della Soluzione, facciamo nuovamente pubblish, ma stavolta puntando al DB in uso dal WEC (lo possiamo trovare  nella pagina del WEC sul bowser)
## WEC

### Sincronizzazione

Apriamo `ABKModel.edmx` click destro -> aggiorna modello con database

ctrl s e buildiamo la soluzione, risolviamo eventuali errori
## Sostituzione massiva file autogenerati

Allineare i database genererà in automatico dei file, una volta seguite le procedure apriamo in Visual Studio Code la soluzione ABK prensente nel WEC, e sostituiamo

```bash ccp fold title:Sostituzione-Manuale copy

Get-ChildItem -Path "c:\Code\Progetti-BK\NET\BK-Suite\ABK" -Filter "*.cs" | ForEach-Object { $content = Get-Content $_.FullName -Raw; $newContent = $content -replace '(\s*)(\[Newtonsoft\.Json\.JsonIgnore\]\s*)*public virtual ICollection', '$1[Newtonsoft.Json.JsonIgnore] public virtual ICollection'; if ($content -ne $newContent) { Set-Content $_.FullName $newContent -NoNewline; Write-Host "Updated: $($_.Name)" } }

```

  
  

## Build Generale

A questo punto se non ci sono errori, facciamo build sia nel WEC che in DBK Suite e facciamo anche commit al repository di DBK Suite, garantendo la sincronizzazione con altri membri del team. 