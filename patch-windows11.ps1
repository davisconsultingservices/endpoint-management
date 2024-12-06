# Ensure the script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Exit
}

# Import PSWindowsUpdate module
Import-Module PSWindowsUpdate

# Perform Windows Update
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

