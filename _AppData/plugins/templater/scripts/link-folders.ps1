# mklink_cli.ps1 - A PowerShell CLI tool to create symbolic links from origin to destination folder
# Usage: .\mklink_cli.ps1 [OriginFolder] [DestinationFolder]

param(
    [string]$OriginFolder,
    [string]$DestinationFolder,
    [switch]$Help
)

# Function to display usage
function Show-Usage {
    Write-Host "`nUsage:" -ForegroundColor Blue
    Write-Host "  .\mklink_cli.ps1 <OriginFolder> <DestinationFolder>"
    Write-Host ""
    Write-Host "Description:" -ForegroundColor Blue
    Write-Host "  Creates symbolic links from all files/folders in OriginFolder to DestinationFolder"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Blue
    Write-Host "  .\mklink_cli.ps1 'C:\Source' 'C:\Destination'"
    Write-Host "  .\mklink_cli.ps1 'C:\My Source Folder' 'C:\My Destination'"
    Write-Host ""
    Write-Host "Interactive mode:" -ForegroundColor Blue
    Write-Host "  .\mklink_cli.ps1"
    Write-Host ""
}

# Function to create symbolic links
function New-SymbolicLinks {
    param(
        [string]$Origin,
        [string]$Destination
    )
    
    $count = 0
    $errors = 0
    
    Write-Host "`nCreating symbolic links..." -ForegroundColor Blue
    Write-Host "Origin: " -NoNewline -ForegroundColor Blue
    Write-Host $Origin -ForegroundColor Yellow
    Write-Host "Destination: " -NoNewline -ForegroundColor Blue
    Write-Host $Destination -ForegroundColor Yellow
    Write-Host ""
    
    # Get all items in the origin folder
    $items = Get-ChildItem -Path $Origin -Force
    
    foreach ($item in $items) {
        $destPath = Join-Path $Destination $item.Name
        
        try {
            if ($item.PSIsContainer) {
                # Directory - create directory junction
                Write-Host "Creating directory link: " -NoNewline
                Write-Host $item.Name -ForegroundColor Green
                
                # Use cmd to create junction (more reliable than New-Item)
                $result = & cmd /c "mklink /J `"$destPath`" `"$($item.FullName)`"" 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    $count++
                    Write-Host "  ✓ Success" -ForegroundColor Green
                }
                else {
                    $errors++
                    Write-Host "  ✗ Failed: $result" -ForegroundColor Red
                }
            }
            else {
                # File - create symbolic link
                Write-Host "Creating file link: " -NoNewline
                Write-Host $item.Name -ForegroundColor Green
                
                # Use cmd to create symbolic link
                $result = & cmd /c "mklink `"$destPath`" `"$($item.FullName)`"" 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    $count++
                    Write-Host "  ✓ Success" -ForegroundColor Green
                }
                else {
                    $errors++
                    Write-Host "  ✗ Failed: $result" -ForegroundColor Red
                }
            }
        }
        catch {
            $errors++
            Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Blue
    Write-Host "  Links created: " -NoNewline -ForegroundColor Blue
    Write-Host $count -ForegroundColor Green
    Write-Host "  Errors: " -NoNewline -ForegroundColor Blue
    Write-Host $errors -ForegroundColor Red
}

# Function to validate directories
function Test-Directories {
    param(
        [string]$Origin,
        [string]$Destination
    )
    
    # Check if origin exists
    if (-not (Test-Path $Origin -PathType Container)) {
        Write-Host "Error: Origin directory does not exist: $Origin" -ForegroundColor Red
        return $false
    }
    
    # Create destination directory if it doesn't exist
    if (-not (Test-Path $Destination -PathType Container)) {
        Write-Host "Destination directory does not exist. Creating: $Destination" -ForegroundColor Yellow
        try {
            New-Item -Path $Destination -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Host "Error: Could not create destination directory: $Destination" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            return $false
        }
    }
    
    # Check if origin is empty
    $items = Get-ChildItem -Path $Origin -Force
    if ($items.Count -eq 0) {
        Write-Host "Warning: Origin directory is empty: $Origin" -ForegroundColor Yellow
        $response = Read-Host "Continue anyway? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            return $false
        }
    }
    
    return $true
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main function
function Main {
    Write-Host "=== Symbolic Link Creator ===" -ForegroundColor Blue
    Write-Host ""
    
    # Check if running as administrator
    if (-not (Test-Administrator)) {
        Write-Host "Warning: Not running as administrator. Some operations may fail." -ForegroundColor Yellow
        Write-Host "For best results, run PowerShell as Administrator." -ForegroundColor Yellow
        Write-Host ""
    }
    
    $origin = $OriginFolder
    $destination = $DestinationFolder
    
    # Check if we need interactive mode
    if (-not $origin -or -not $destination) {
        Write-Host "Interactive mode - please provide the required information:" -ForegroundColor Blue
        Write-Host ""
        
        if (-not $origin) {
            $origin = Read-Host "Enter origin folder path"
        }
        
        if (-not $destination) {
            $destination = Read-Host "Enter destination folder path"
        }
    }
    
    # Remove quotes if present
    $origin = $origin.Trim('"')
    $destination = $destination.Trim('"')
    
    # Validate input
    if ([string]::IsNullOrWhiteSpace($origin) -or [string]::IsNullOrWhiteSpace($destination)) {
        Write-Host "Error: Both origin and destination folders must be specified" -ForegroundColor Red
        return
    }
    
    # Validate directories
    if (-not (Test-Directories $origin $destination)) {
        return
    }
    
    # Confirm action
    Write-Host ""
    Write-Host "About to create symbolic links:" -ForegroundColor Yellow
    Write-Host "  From: " -NoNewline -ForegroundColor Yellow
    Write-Host $origin -ForegroundColor Blue
    Write-Host "  To:   " -NoNewline -ForegroundColor Yellow
    Write-Host $destination -ForegroundColor Blue
    Write-Host ""
    
    $confirm = Read-Host "Continue? (y/N)"
    
    if ($confirm -match '^[Yy]$') {
        New-SymbolicLinks $origin $destination
    }
    else {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
    }
}

# Handle help flag
if ($Help) {
    Show-Usage
    return
}

# Run main function
Main