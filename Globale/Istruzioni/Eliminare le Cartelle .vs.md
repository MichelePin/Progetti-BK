---
Progetto: Globale
Tipo: Istruzioni
Argomento: Installazione
Categoria: Debugging
linked_documents:
date: 2025-07-17
tags:
  - Globale
  - Deploy
  - Istruzioni
  - Procedura
---



  
## Intro 
Guida su come rimuovere le cartelle .vs in un progetto 

```powershell ccpfold title:delete-all-.vs-folders
# Set the root folder to start from
$rootPath = "C:\Code\Progetti-BK\NET"

# Find all .vs folders recursively
$vsFolders = Get-ChildItem -Path $rootPath -Recurse -Directory -Force | Where-Object { $_.Name -eq ".vs" }

# Show how many folders were found
Write-Host "`nFound $($vsFolders.Count) .vs folder(s) to delete.`n" -ForegroundColor Cyan

# Loop through and delete each folder with visual feedback
$counter = 1
foreach ($folder in $vsFolders) {
    Write-Host "[$counter/$($vsFolders.Count)] Deleting: $($folder.FullName)" -ForegroundColor Yellow
    try {
        Remove-Item -Path $folder.FullName -Recurse -Force
        Write-Host "✅ Deleted: $($folder.FullName)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to delete: $($folder.FullName)" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor DarkRed
    }
    $counter++
}

Write-Host "`n🎉 Cleanup complete!" -ForegroundColor Magenta
```