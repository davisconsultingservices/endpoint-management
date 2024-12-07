#Requires -RunAsAdministrator

class SensitiveDataScanner {
    [string]$ScanRoot
    [int]$MaxDepth
    [array]$Findings
    [hashtable]$Patterns
    [string[]]$ScanFileExtensions

    # Constructor
    SensitiveDataScanner(
        [string]$ScanRoot = 'C:\',
        [int]$MaxDepth = 3
    ) {
        $this.ScanRoot = $ScanRoot
        $this.MaxDepth = $MaxDepth
        $this.Findings = @()

        # Define Sensitive Data Patterns
        $this.Patterns = @{
            # PII
            SSN             = '\b\d{3}-\d{2}-\d{4}\b'
            Email           = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'
            PhoneNumber     = '\b(?:\+\d{1,2}\s?)?(?:\(\d{3}\)|\d{3})[\s.-]?\d{3}[\s.-]?\d{4}\b'

            # Financial Data
            # USRoutingNumber = '\b\d{9}\b'
            # USAccountNumber = '\b\d{8,17}\b'  # Typical range for US account numbers
            # IBAN            = '\b[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}\b'
            # SWIFT           = '\b[A-Z]{4}[A-Z0-9]{2}[A-Z0-9]{2}([A-Z0-9]{3})?\b'
            # TIN             = '\b\d{2}-\d{7}\b'

            # Cryptocurrency
            BitcoinAddress  = '\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b'
            EthereumAddress = '\b0x[a-fA-F0-9]{40}\b'
            LitecoinAddress = '\b[L3][a-km-zA-HJ-NP-Z1-9]{26,34}\b'

            # Miscellaneous Patterns
            IPAddress       = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
            Password        = '(?i)\bpassword\b\s*[:=]\s*[^\s]+'
            CreditCard      = '\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|6(?:011|5[0-9]{2})[0-9]{12}|(?:2131|1800|35\d{3})\d{11})\b'
            JSONWebToken    = '\beyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\b'
        }

        # Supported File Types (Expanded)
        $this.ScanFileExtensions = @(
            "*.txt", "*.log", "*.cfg", "*.conf", "*.ini", "*.yaml", "*.json", "*.xml", "*.md", "*.html", "*.css", "*.js",
            "*.doc", "*.docx", "*.pdf", "*.xls", "*.xlsx", "*.ppt", "*.pptx", "*.odt", "*.ods", "*.odp",
            "*.py", "*.rb", "*.php", "*.java", "*.c", "*.cpp", "*.cs", "*.sh", "*.bat", "*.ps1", "*.sql", "*.go", "*.ts",
            "*.db", "*.sqlite", "*.csv", "*.tsv", "*.dat", "*.bak",
            "*.zip", "*.tar", "*.gz", "*.7z", "*.rar",
            "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff", "*.mp3", "*.mp4", "*.mov",
            "*.eml", "*.msg", "*.pst", "*.mbox",
            "*.tmp", "*.bak", "*.bin", "*.key", "*.pem", "*.crt", "*.cer"
        )
    }

    # Scan File
    [void] ScanFile([System.IO.FileInfo]$File) {
        try {
            $content = Get-Content -Path $File.FullName -Raw -ErrorAction Stop
            foreach ($patternName in $this.Patterns.Keys) {
                $matches = [regex]::Matches($content, $this.Patterns[$patternName])
                if ($matches.Count -gt 0) {
                    $finding = @{
                        FilePath      = $File.FullName
                        PatternType   = $patternName
                        MatchCount    = $matches.Count
                        SampleMatches = ($matches | ForEach-Object { $_.Value } | Select-Object -First 3) -join ', '
                    }
                    $this.Findings += $finding
                    Write-Host "Sensitive data found in [$($File.FullName)] - Type: $patternName" -ForegroundColor Yellow
                }
            }
        }
        catch {
            Write-Host "Error scanning file: $($File.FullName) - $_" -ForegroundColor Red
        }
    }

    # Scan Directory
    [void] ScanDirectory([string]$Path, [int]$Depth) {
        if ($Depth -ge $this.MaxDepth) {
            return
        }

        foreach ($ext in $this.ScanFileExtensions) {
            Get-ChildItem -Path $Path -Filter $ext -File -ErrorAction SilentlyContinue | ForEach-Object {
                $this.ScanFile($_)
            }
        }

        Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $this.ScanDirectory($_.FullName, $Depth + 1)
        }
    }

    # Generate Summary
    [void] GenerateSummary() {
        Write-Host "=== Scan Summary ===" -ForegroundColor Cyan
        Write-Host "Total Findings: $($this.Findings.Count)" -ForegroundColor Cyan
        Write-Host "Findings by Type:" -ForegroundColor Cyan
        $this.Findings | Group-Object PatternType | ForEach-Object {
            Write-Host " - $($_.Name): $($_.Count)" -ForegroundColor Green
        }

        Write-Host "Detailed Findings:" -ForegroundColor Cyan
        $this.Findings | ForEach-Object {
            Write-Host "File: $($_.FilePath), Type: $($_.PatternType), Matches: $($_.SampleMatches)" -ForegroundColor Yellow
        }
    }

    # Perform Scan
    [void] PerformScan() {
        Write-Host "=== Starting Sensitive Data Scan ===" -ForegroundColor Cyan
        Write-Host "Scanning Root: $this.ScanRoot" -ForegroundColor Cyan
        $this.ScanDirectory($this.ScanRoot, 0)
        Write-Host "=== Scan Completed ===" -ForegroundColor Cyan
        $this.GenerateSummary()
    }
}

# Main Script
try {
    $scanner = [SensitiveDataScanner]::new('C:\', 3)
    $scanner.PerformScan()
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
