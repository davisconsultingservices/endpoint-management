# PowerShell Scripts for Security, Patching, and Secrets Reporting

This repository includes PowerShell scripts designed for **security checks**, **patch management**, and **secrets reporting**. Each script provides a focused and modular functionality, offering actionable insights and maintaining system hygiene.

---

## **Scripts Overview**

### **1. `security.ps1`**
Performs comprehensive system-level security checks:
- Verifies the firewall status and active rules.
- Scans for open ports and their associated processes.
- Audits installed software and versions to check for outdated or vulnerable applications.
- Analyzes failed login attempts for suspicious activity.
- Displays the system’s public IP for network validation.

---

### **2. `patching.ps1`**
Handles patch management and updates:
- Installs Windows updates.
- Updates third-party applications via `winget` and the Microsoft Store.
- Detects and schedules system reboots if necessary.
- Logs all updates for later review and provides a summary of completed tasks.

---

### **3. `secrets.ps1`**
A **reporting tool** for scanning files and directories for sensitive data:
- Detects patterns related to:
  - Personally Identifiable Information (PII) such as Social Security Numbers and emails.
  - Financial data like IBANs, SWIFT codes, US routing numbers, and account numbers.
  - Cryptographic secrets, including API keys, JSON Web Tokens (JWTs), private keys, and passwords.
- Supports a wide variety of file formats, including text files, logs, JSON, CSV, Office documents, and compressed archives.
- Outputs a detailed, actionable report to the console.

---

## **Requirements**

- **PowerShell 5.1 or later**.
- **Administrator privileges** to run security and patching scripts.
- **Internet access** for updates and certain checks (e.g., public IP lookups).

---

## **Usage**

### **Run Individual Scripts**

1. **Clone or download the repository**:
   ```bash
   git clone https://github.com/your-repo-name.git
   cd your-repo-name
   ```

2. **Open PowerShell as Administrator**.

3. **Execute the desired script**:

   - **Security Checks**:
     ```powershell
     .\security.ps1
     ```

   - **System Updates**:
     ```powershell
     .\patching.ps1
     ```

   - **Secrets Reporting**:
     ```powershell
     .\secrets.ps1
     ```

---

## **File Structure**

```plaintext
.
├── security.ps1      # Script for security checks
├── patching.ps1      # Script for patch management
└── secrets.ps1       # Reporting tool for secrets scanning
```

---

## **Output Examples**

### Security Checks:
```plaintext
=== Security Summary ===
Firewall Status: Enabled
Open Ports:
  - Port 80: ServiceName (PID 1234)
  - Port 443: ServiceName (PID 5678)
Failed Login Attempts: 3
Public IP Address: 203.0.113.25
```

### Patching:
```plaintext
=== Patching Summary ===
Installed Windows Updates:
  - KB12345678: Security Update
  - KB87654321: Feature Update
Updated Applications:
  - Google Chrome: Updated to version 123.4.5
  - Zoom: Updated to version 5.12.3
Reboot Required: Yes
```

### Secrets Reporting:
```plaintext
=== Secrets Report ===
Files Scanned: 200
Findings:
  - File: C:\Sensitive\info.txt
    - Pattern: SSN
    - Matches: 123-45-6789
  - File: C:\Logs\secrets.log
    - Pattern: API Key
    - Matches: AIzaSyD123456789abcdef
```

---

## **Customization**

### Modify the `secrets.ps1` Scan Configuration
You can adjust the file extensions and patterns in `secrets.ps1` to suit your specific needs:
- Add or remove **file types** from the `$ScanFileExtensions` array.
- Expand **sensitive data patterns** in the `$Patterns` hashtable.

---

## **Contributing**

Contributions are welcome! If you have ideas for improvements or additional features, feel free to fork the repository and submit a pull request.

---

## **License**

This project is licensed under the MIT License. See `LICENSE` for details.

--- 

Let me know if you'd like more details or refinements!
