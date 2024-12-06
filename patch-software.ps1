# Ensure Winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not available. Please install it manually from https://aka.ms/winget" -ForegroundColor Red
    Exit
}

# Track failed and skipped updates
$failedPackages = @()
$skippedPackages = @()

# List of end-of-life packages to skip
$excludedPackages = @(
    "Microsoft.549981C3F5F10",
    "Microsoft.Getstarted"
)

# Update all Winget-managed packages
Write-Host "Updating all Winget-managed packages..." -ForegroundColor Cyan
try {
    winget upgrade --all --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "One or more Winget updates may have failed." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error during Winget update process." -ForegroundColor Red
    $failedPackages += "Winget packages"
}

# List all apps that can be updated via the Microsoft Store
Write-Host "Checking for Microsoft Store app updates..." -ForegroundColor Cyan
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

# Cleanup logs
Write-Host "Cleaning up deployment logs..." -ForegroundColor Cyan
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\AppRepository\*.rslc" -Force -ErrorAction SilentlyContinue

# Output results
Write-Host "-----------------------------" -ForegroundColor Cyan
Write-Host "Update Summary:" -ForegroundColor Cyan

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
