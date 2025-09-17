Write-Host '=== MD File Linker ===' -ForegroundColor Blue

$origin = Read-Host 'Enter origin folder path'
$destination = Read-Host 'Enter destination folder path'

$origin = $origin.Trim('"')
$destination = $destination.Trim('"')

if (-not (Test-Path $origin)) {
    Write-Host 'Origin folder not found!' -ForegroundColor Red
    exit
}

if (-not (Test-Path $destination)) {
    New-Item -Path $destination -ItemType Directory -Force | Out-Null
    Write-Host 'Created destination folder' -ForegroundColor Green
}

$count = 0

# Link .md files
$mdFiles = Get-ChildItem -Path $origin -Filter '*.md' -Force
foreach ($file in $mdFiles) {
    $destPath = Join-Path $destination $file.Name
    cmd /c "mklink `"$destPath`" `"$($file.FullName)`"" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " Linked: $($file.Name)" -ForegroundColor Green
        $count++
    }
}

# Link directories with .md files
$dirs = Get-ChildItem -Path $origin -Directory -Force
foreach ($dir in $dirs) {
    $mdInDir = Get-ChildItem -Path $dir.FullName -Filter '*.md' -Recurse -Force -ErrorAction SilentlyContinue
    if ($mdInDir.Count -gt 0) {
        $destPath = Join-Path $destination $dir.Name
        cmd /c "mklink /J `"$destPath`" `"$($dir.FullName)`"" | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " Linked directory: $($dir.Name) ($($mdInDir.Count) .md files)" -ForegroundColor Green
            $count++
        }
    } else {
        Write-Host " Skipped: $($dir.Name) (no .md files)" -ForegroundColor DarkGray
    }
}

Write-Host "
Created $count links" -ForegroundColor Blue