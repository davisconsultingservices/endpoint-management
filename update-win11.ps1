# Import PSWindowsUpdate module
Import-Module PSWindowsUpdate

# Perform Windows Update
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# Update Microsoft Store apps using winget
winget upgrade --all
