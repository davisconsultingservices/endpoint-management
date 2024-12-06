# Ensure script is running as Administrator
Write-Output "=== Checking for Administrator Privileges ==="
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Exit
}

# Define the scripts to run
$scriptsToRun = @(
    ".\security.ps1",
    ".\patching.ps1"
)

# Function to run a script and display output
function Run-Script {
    param (
        [string]$scriptPath
    )
    
    if (Test-Path $scriptPath) {
        Write-Output "=== Running Script: $scriptPath ==="
        try {
            & $scriptPath
            Write-Host "=== Completed Script: $scriptPath ===" -ForegroundColor Green
        } catch {
            Write-Host "Error running script: $scriptPath - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Script not found: $scriptPath" -ForegroundColor Yellow
    }
}

# Run scripts in sequence
Write-Output "=== Starting Scripts ==="
foreach ($script in $scriptsToRun) {
    Run-Script -scriptPath $script
}
Write-Output "=== All Scripts Completed ==="
