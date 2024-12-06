try {
    $publicIP = Invoke-RestMethod -Uri "https://api64.ipify.org?format=json"
    Write-Host "Your public IP address is: $($publicIP.ip)" -ForegroundColor Green
} catch {
    Write-Host "Failed to retrieve public IP address." -ForegroundColor Red
}
