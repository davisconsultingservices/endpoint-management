# Ensure the script runs as Administrator
Write-Output "=== Checking for Administrator Privileges ==="
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Exit
}

# Ensure PSWindowsUpdate module is installed
Write-Output "=== Ensuring PSWindowsUpdate Module is Installed ==="
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Output "Installing PSWindowsUpdate module..."
    Install-Module -Name PSWindowsUpdate -Force -ErrorAction SilentlyContinue
}
Import-Module PSWindowsUpdate

# Track if a reboot is required
$rebootRequired = $false

# Perform Windows Updates
Write-Output "=== Performing Windows Updates ==="
try {
    Get-WindowsUpdate -AcceptAll -Install
    if ((Get-WindowsUpdate -KBArticleID "RebootRequired").Count -gt 0) {
        $rebootRequired = $true
    }
    Write-Host "Windows Updates completed successfully." -ForegroundColor Green
} catch {
    Write-Host "Error during Windows Updates: $_" -ForegroundColor Red
}

# Ensure Winget is available
Write-Output "=== Checking for Winget Availability ==="
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not available. Please install it manually from https://aka.ms/winget" -ForegroundColor Red
    Exit
}

# Update all Winget-managed packages
Write-Output "=== Updating Winget-Managed Packages ==="
$failedPackages = @()
$skippedPackages = @()
$wingetUpdated = $false

try {
    # Run the Winget update command
    winget upgrade --all --accept-source-agreements --accept-package-agreements | ForEach-Object {
        if ($_ -match "Upgrading") {
            $wingetUpdated = $true
        }
    }
    if ($wingetUpdated) {
        Write-Host "Winget-managed packages updated successfully." -ForegroundColor Green
        $rebootRequired = $true
    } else {
        Write-Host "No Winget-managed packages required updates." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error during Winget updates: $_" -ForegroundColor Red
    $failedPackages += "Winget packages"
}

# Microsoft Store App Updates
Write-Output "=== Checking for Microsoft Store App Updates ==="
$excludedPackages = @("Microsoft.549981C3F5F10", "Microsoft.Getstarted")  # List of end-of-life packages to skip

try {
    $updates = Get-AppxPackage -AllUsers | Where-Object { $_.PackageUserInformation.InstallState -eq 'Staged' }
    if ($updates.Count -gt 0) {
        foreach ($app in $updates) {
            if ($excludedPackages -contains $app.Name) {
                Write-Host "Skipping $($app.Name) (end of life)" -ForegroundColor Yellow
                $skippedPackages += $app.Name
                continue
            }
            try {
                Write-Host "Updating Microsoft Store app: $($app.Name)" -ForegroundColor Cyan
                Add-AppxPackage -Register "$($app.InstallLocation)\AppxManifest.xml" -DisableDevelopmentMode
                Write-Host "Updated: $($app.Name)" -ForegroundColor Green
            } catch {
                if ($_ -match "A higher version of this package is already installed") {
                    Write-Host "Skipped: $($app.Name) (higher version already installed)" -ForegroundColor Yellow
                    $skippedPackages += $app.Name
                } elseif ($_ -match "end of life and can no longer be installed") {
                    Write-Host "Skipped: $($app.Name) (end of life)" -ForegroundColor Yellow
                    $skippedPackages += $app.Name
                } elseif ($_ -match "apps need to be closed") {
                    Write-Host "Skipped: $($app.Name) (resource in use)" -ForegroundColor Yellow
                    $skippedPackages += $app.Name
                } else {
                    Write-Host "Failed to update: $($app.Name)" -ForegroundColor Red
                    $failedPackages += $app.Name
                }
            }
        }
    } else {
        Write-Host "No updates available for Microsoft Store apps." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error while checking for Microsoft Store updates." -ForegroundColor Red
    $failedPackages += "Microsoft Store apps"
}

# Output results
Write-Output "=== Update Summary ==="
if ($skippedPackages.Count -gt 0) {
    Write-Host "The following packages were skipped:" -ForegroundColor Yellow
    $skippedPackages | ForEach-Object { Write-Host "- $_" }
}

if ($failedPackages.Count -gt 0) {
    Write-Host "The following packages failed to update and may need manual intervention:" -ForegroundColor Red
    $failedPackages | ForEach-Object { Write-Host "- $_" }
} else {
    Write-Host "All updates completed successfully!" -ForegroundColor Green
}

# List installed software and versions
Write-Output "=== Installed Software and Versions ==="
Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Sort-Object Name | Format-Table


# Reboot if required
if ($rebootRequired) {
    Write-Output "System requires a reboot. Rebooting now..."
    Restart-Computer -Force
} else {
    Write-Output "No reboot required."
}
