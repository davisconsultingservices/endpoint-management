# Update Defender signatures
Write-Output "=== Updating Windows Defender Signatures ==="
Update-MpSignature

# Perform a quick scan
Write-Output "=== Performing Windows Defender Quick Scan ==="
Start-MpScan -ScanType QuickScan

# Check firewall status and active rules
Write-Output "=== Firewall Status and Active Rules ==="
Get-NetFirewallProfile | Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction

# List administrative user accounts
Write-Output "=== Administrative User Accounts ==="
Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Description -like "*Administrator*" } | 
Select-Object Name, Enabled, LastLogon | Format-Table

# Check for open ports and associated processes
Write-Output "=== Open Ports and Associated Processes ==="
Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' } | 
Select-Object LocalAddress, LocalPort, OwningProcess | 
Format-Table

# Public IP Address
Write-Output "=== Public IP Address ==="
try {
    $publicIP = Invoke-RestMethod -Uri "https://api64.ipify.org?format=json"
    $machineName = $env:COMPUTERNAME
    Write-Host "Public IP address for machine '$machineName' is: $($publicIP.ip)" -ForegroundColor Green
}
catch {
    Write-Host "Failed to retrieve public IP address for machine '$env:COMPUTERNAME'." -ForegroundColor Red
}


# List installed software and versions
Write-Output "=== Installed Software and Versions ==="
Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Sort-Object Name | Format-Table

# Check for failed login attempts
Write-Output "=== Failed Login Attempts ==="
try {
    $failedLogins = Get-WinEvent -LogName Security -FilterHashtable @{Id = 4625 } -MaxEvents 10
    if ($failedLogins) {
        $failedLogins | Select-Object TimeCreated, Message | Format-Table
    }
    else {
        Write-Output "No failed login attempts found in the Security log."
    }
}
catch {
    Write-Output "Error retrieving failed login attempts: $_"
}

# Scan for missing Windows updates
Write-Output "=== Scanning for Missing Windows Updates ==="
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Output "PSWindowsUpdate module not found. Installing..."
    Install-Module -Name PSWindowsUpdate -Force -ErrorAction SilentlyContinue
}
Import-Module PSWindowsUpdate
Get-WindowsUpdate | Select-Object KBArticle, Title | Format-Table

# Check system file integrity
Write-Output "=== Checking System File Integrity ==="
sfc /scannow

# Generate summary report
Write-Output "=== Security Check Completed ==="
Write-Output "Please review the output above for potential issues or irregularities."
