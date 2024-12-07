# run_and_log.ps1
# Ensures scripts in the same directory as this file are located and executed correctly.

# Set the working directory to the folder containing this script
$scriptFolder = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Set-Location -Path $scriptFolder

# Function to generate syslog-compatible timestamps
function Get-SyslogTimestamp {
    return (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.ffffK")
}

# Function to execute a script and capture its output
function Run-Script {
    param (
        [string]$ScriptPath,
        [string]$LogFile
    )

    if (-not (Test-Path $ScriptPath)) {
        Write-Host "Script not found: $ScriptPath" -ForegroundColor Red
        return
    }

    Write-Host "Running script: $ScriptPath" -ForegroundColor Cyan

    try {
        # Capture output and errors
        $output = & $ScriptPath *>&1
        $timestamp = Get-SyslogTimestamp

        # Write output to log in syslog format
        foreach ($line in $output) {
            Add-Content -Path $LogFile -Value "$timestamp INFO $($ScriptPath): $line"
        }

        Write-Host "Output saved to: $LogFile" -ForegroundColor Green
    }
    catch {
        $timestamp = Get-SyslogTimestamp
        $errorMsg = $_.Exception.Message
        Add-Content -Path $LogFile -Value "$timestamp ERROR $($ScriptPath): $errorMsg"
        Write-Host "Error running script: $ScriptPath" -ForegroundColor Red
    }
}

# Function to check for pending reboots after running patching.ps1
function Is-RebootPending {
    return Test-Path "C:\Windows\System32\RebootPending.txt"
}

# Main script execution with reboot handling
try {
    # Log file location
    $logFileName = "endpoint_management_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $logFilePath = Join-Path -Path (Get-Location) -ChildPath $logFileName

    # List of scripts to run
    $scripts = @(".\security.ps1", ".\patching.ps1", ".\secrets.ps1")

    # Check for a marker file to determine if resuming after a reboot
    $markerFile = Join-Path -Path (Get-Location) -ChildPath "reboot_marker.txt"

    if (Test-Path $markerFile) {
        Write-Host "Resuming execution after reboot..." -ForegroundColor Cyan
        $completedScripts = Get-Content $markerFile
        $scripts = $scripts | Where-Object { $_ -notin $completedScripts }
        Remove-Item $markerFile -Force
    }

    # Run each script and log output
    foreach ($script in $scripts) {
        # Log completed scripts in case of reboot
        Add-Content -Path $markerFile -Value $script
        Run-Script -ScriptPath $script -LogFile $logFilePath

        # Handle potential reboot from patching.ps1
        if ($script -eq ".\patching.ps1" -and (Is-RebootPending)) {
            Write-Host "Reboot triggered by patching.ps1. Saving progress and rebooting..." -ForegroundColor Cyan
            Restart-Computer -Force
        }
    }

    # Cleanup marker file if all scripts are completed
    if (Test-Path $markerFile) {
        Remove-Item $markerFile -Force
    }

    Write-Host "All scripts executed. Logs saved to: $logFilePath" -ForegroundColor Cyan
}
catch {
    Write-Host "An error occurred while executing scripts: $_" -ForegroundColor Red
}
