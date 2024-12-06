
# Ensure script is running as Administrator
Write-Output "=== Checking for Administrator Privileges ==="
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Exit
}


Write-Output "=== Secrets scanning todo ==="