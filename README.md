### **README for `main.ps1`**

---

# Script Runner for Patching, Security, and Secrets

This repository contains a collection of PowerShell scripts designed for system management tasks such as security checks, patching, and (future) secrets scanning. The primary script, `main.ps1`, orchestrates the execution of the individual scripts in sequence and provides a unified interface.

---

## **Scripts Overview**

### **1. main.ps1**
The main orchestration script:
- Executes `security.ps1` (security checks) and `patching.ps1` (system updates) in sequence.
- Prepares for the future addition of `secrets.ps1` (sensitive data scanning).
- Outputs results to the console for real-time visibility.
- Handles errors and ensures scripts are executed in the correct order.

### **2. security.ps1**
Performs system-level security checks, such as:
- Firewall status and active rules.
- Open ports and associated processes.
- Installed software and versions.
- Failed login attempts.
- Public IP address.

### **3. patching.ps1**
Handles system updates, including:
- Windows Updates.
- Application updates via `winget` and the Microsoft Store.
- Ensures a reboot only occurs if required.

### **4. secrets.ps1** *(Placeholder for Future)*
Will perform secrets scanning (e.g., API keys, passwords) using tools like `ripgrep` or similar.

---

## **Requirements**

- PowerShell 5.1 or later.
- Administrator privileges to execute all scripts.
- Internet access for downloading updates and scanning tools.

---

## **Usage**

1. Clone or download the repository:
   ```bash
   git clone https://github.com/your-repo-name.git
   cd your-repo-name
   ```

2. Open PowerShell as Administrator.

3. Run the main script:
   ```powershell
   .\main.ps1
   ```

---

## **File Structure**

```plaintext
.
├── main.ps1          # Primary script to orchestrate all tasks
├── security.ps1      # Security checks script
├── patching.ps1      # System updates and patching script
└── secrets.ps1       # Placeholder for secrets scanning (future feature)
```

---

## **Script Execution Flow**

1. **Security Checks:**
   - Executes `security.ps1` to check for security-related issues.
2. **System Updates:**
   - Runs `patching.ps1` to apply updates and check if a reboot is required.
3. **Future Secrets Scanning:**
   - Reserved for the `secrets.ps1` script to scan for sensitive data.

---

## **Customization**

### **Modify the Script Sequence**
To change the sequence or add new scripts, update the `$scriptsToRun` array in `main.ps1`:
```powershell
$scriptsToRun = @(
    ".\security.ps1",
    ".\patching.ps1"
)
```

---

## **Example Output**

```plaintext
=== Checking for Administrator Privileges ===
=== Starting Scripts ===
=== Running Script: .\security.ps1 ===
[Output from security.ps1 script]
=== Completed Script: .\security.ps1 ===
=== Running Script: .\patching.ps1 ===
[Output from patching.ps1 script]
=== Completed Script: .\patching.ps1 ===
=== All Scripts Completed ===
```

---

## **Contributing**

Contributions are welcome! If you have ideas for improvements or additional features, feel free to fork the repository and submit a pull request.

---

## **License**

This project is licensed under the MIT License. See `LICENSE` for details.

---

Let me know if you'd like further refinements!