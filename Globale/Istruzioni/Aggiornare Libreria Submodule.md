## Intro 
Come installare la libreria di BKSolutions "LIB_TYPESCRIPT" nel nostro repo locale 

### 1. Login 
Ci logghiamo dentro a https://bksolutions.visualstudio.com/ e copiamo l'indirizzo del repo `LIB_TYPESCRIPT` se non abbiamo accesso rivolgiamoci a chi di dovere 

### 2. Pulizia 
Prima di installare, puliamo il progetto, questo disistallera le librerie e riparira da zero 

```powershell ccp fold title:Resettare-Moduli 
Set-Location -LiteralPath 'C:\Code\Progetti-BK\IONIC\WSpace'; git submodule deinit -f --all; if (Test-Path .gitmodules) { git rm -f .gitmodules; Remove-Item -LiteralPath .gitmodules -Force }; git rm -f --cached LIB_TYPESCRIPT 2>$null; if (Test-Path '.git\modules\LIB_TYPESCRIPT') { Remove-Item -LiteralPath '.git\modules\LIB_TYPESCRIPT' -Recurse -Force }; if (Test-Path 'LIB_TYPESCRIPT') { Remove-Item -LiteralPath 'LIB_TYPESCRIPT' -Recurse -Force }; git add -A; $st = git status --porcelain; if ($st) { git commit -m 'Remove broken submodules and .gitmodules' } else { Write-Output 'No commit created' }; git status --porcelain; if (Test-Path '.git\modules') { Get-ChildItem -Path '.git\modules' -Force | Select-Object Name } else { Write-Output '.git/modules not present' }
```

### 3. Installazione 
Installiamo la libreria nel progetto

```powershell ccp fold title:Installare Libreria
Set-Location -LiteralPath 'C:\Code\Progetti-BK\IONIC\WSpace'; git submodule add 'https://bksolutions.visualstudio.com/LIB%20-%20TYPESCRIPT/_git/LIB%20-%20TYPESCRIPT' 'LIB_TYPESCRIPT'; git submodule update --init --recursive --progress; git add .gitmodules LIB_TYPESCRIPT; $st = git status --porcelain; if ($st) { git commit -m 'Add LIB_TYPESCRIPT submodule' } else { Write-Output 'No commit created' }; git status --porcelain; if (Test-Path '.git\modules') { Get-ChildItem -Path '.git\modules' -Force | Select-Object Name } else { Write-Output '.git/modules not present' }
```

### 4. Verifichiamo 
Verifichiamo che il submodule sia installato correttamente  con `ionic build`
