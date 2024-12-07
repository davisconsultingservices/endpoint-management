### **Updated README for Endpoint Management**

---

# PowerShell Scripts for Security, Patching, Secrets Reporting, and Logging

This repository includes PowerShell scripts designed for endpoint management, covering tasks such as **security checks**, **patch management**, **secrets reporting**, and **logging script outputs** for audit and review purposes. Each script is modular and can be executed individually or orchestrated using the provided logging script.

---

## **Scripts Overview**

### **1. `security.ps1`**
Performs system-level security assessments:
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
- Logs skipped, failed, and successfully updated packages.
- Detects and schedules system reboots if necessary.
- Cleans up deployment logs for better system hygiene.

---

### **3. `secrets.ps1`**
A **reporting tool** for scanning files and directories for sensitive data:
- Detects patterns such as:
  - Personally Identifiable Information (PII) like Social Security Numbers and emails.
  - Financial data like IBANs, SWIFT codes, and US routing/account numbers.
  - Cryptographic secrets, including API keys, JSON Web Tokens (JWTs), private keys, and passwords.
- Supports a variety of file formats including text files, logs, JSON, CSV, Office documents, and compressed archives.
- Outputs a detailed, actionable report to the console.

---

### **4. `run_log.ps1`**
The **logging and orchestration script**:
- Executes `security.ps1`, `patching.ps1`, and `secrets.ps1` in sequence.
- Captures console output from each script and saves it in a **syslog-compatible format**.
- Handles system reboots triggered by `patching.ps1`:
  - Tracks completed scripts using a marker file (`reboot_marker.txt`).
  - Resumes execution after the system restarts.
- Ensures all logs are saved in a single file for audit purposes.

---

## **Requirements**

- **PowerShell 5.1 or later**.
- **Administrator privileges** to execute the scripts.
- **Internet access** for updates and certain features (e.g., public IP lookups).

---

## **Usage**

### **Run Individual Scripts**
1. Clone or download the repository:
   ```bash
   git clone https://github.com/davisconsultingservices/endpoint-management.git
   cd endpoint-management
   ```

2. Open PowerShell as Administrator.

3. Run the desired script:
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

### **Run and Log All Scripts**
1. Run `run_log.ps1` to execute all scripts and log outputs:
   ```powershell
   .\run_log.ps1
   ```

2. **Logging**:
   - The script saves all console outputs in a log file named:
     ```plaintext
     endpoint_management_YYYYMMDD_HHMMSS.log
     ```
   - The log file is saved in the same directory as the script.

3. **Reboot Handling**:
   - If a reboot is triggered by `patching.ps1`, the script:
     - Saves progress in `reboot_marker.txt`.
     - Resumes execution of pending scripts after the system restarts.

---

## **File Structure**

```plaintext
.
├── security.ps1      # Script for security checks
├── patching.ps1      # Script for patch management
├── secrets.ps1       # Reporting tool for secrets scanning
└── run_log.ps1       # Logging and orchestration script
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

### Logs (Syslog-Compatible):
```plaintext
2024-12-06T14:22:10.1234Z INFO .\security.ps1: Firewall is active
2024-12-06T14:22:10.5678Z INFO .\patching.ps1: Updates installed successfully
2024-12-06T14:22:11.5678Z ERROR .\secrets.ps1: File not found: C:\sensitive_data.txt
```

---

## **Customization**

### Modify the Scripts
You can adjust the behavior of individual scripts as needed:
- Add or remove checks and updates in `security.ps1` and `patching.ps1`.
- Expand or refine the patterns in `secrets.ps1`.
- Update the sequence or add new scripts in `run_log.ps1`.

---

## **Contributing**

Contributions are welcome! If you have ideas for improvements or additional features, feel free to fork the repository and submit a pull request.

---

## **License**

This project is licensed under the MIT License. See `LICENSE` for details.

---

Let me know if you need further adjustments!