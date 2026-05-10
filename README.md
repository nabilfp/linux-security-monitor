# 🛡️ Linux Security Monitor

A professional, lightweight Bash-based tool designed to provide an instant overview of system health, resource allocation, and basic security triage. Built specifically for Linux environments (Ubuntu, Arch, Debian).

---

## 📖 Background & Motivation
This project was born out of the necessity for a fast, reliable, and dependency-free triage tool. As an Information Systems student exploring the defense side of cybersecurity, I needed a script that could execute instantly across different Linux servers to quickly identify performance bottlenecks and potential security attack vectors (like unauthorized active sessions or open ports).

## 🚀 Instant Usage (One-Liner)

### Version 2.0 (Advanced Triage & Auto-Logging)
The recommended version. It performs a deeper security check (active users, top CPU consumers to hunt anomalies) and hardware profiling without leaving any trace files on your system.

```bash
curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v2-triage.sh | bash
```

### Version 1.0 (Basic Health Check)
The legacy version for a quick, terminal-only visual check.
```bash
curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/sys-monitor.sh | bash
```

---

## 🛠️ Features inside v2.0 (Enhanced)
1. **System Identity:** Detailed OS version, Kernel info, and Uptime.
2. **Connectivity Audit:** Instant Public IP detection to map your network perimeter.
3. **Advanced Hardware Telemetry:** - **Battery Health:** Detects battery capacity and charging status natively.
    - **Thermal Limits:** Reads CPU temperature alongside the hardware's programmed critical thermal threshold.
    - **Memory Deep-Dive:** Displays both RAM and Swap memory utilization.
    - **Storage Recognition:** Automatically distinguishes between SSD/NVMe and HDD, alongside root partition usage.
4. **Security Triage:** - Failed login attempt counter (hunting brute-force via systemd journal).
    - Top process monitoring to detect suspicious resource spikes.
    - Active session and open port mapping.

## ⚠️ Weaknesses & Limitations
- **No Root Required, But...:** This script is designed to run safely without `sudo`. However, some process details might be hidden by the Linux kernel unless executed by a root user.
- **Temporary Logs:** The audit logs are stored in `/tmp/`. This means they will be permanently deleted when you restart your computer.
- **Basic Triage Level:** This is a diagnostic tool for quick audits, not a full-scale Intrusion Detection System (IDS).

## 🛑 How to Stop
The execution is nearly instantaneous (usually under 2 seconds). If it hangs due to a system or network error, use **`Ctrl + C`** on your keyboard to send a SIGINT (Interrupt Signal) and force close the script.

---

## 🗺️ Future Roadmap
Continuous improvement (Kaizen) is key. Here is the planned evolution of this project, moving from a basic triage script to an Enterprise-ready SOC tool:

### Phase 1: Usability & Baselining
- [ ] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose to run specific targeted checks (e.g., Network Only, Hardware Only, or Full Audit).
- [ ] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [ ] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [ ] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [ ] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads. This allows the tool's output to be easily ingested by modern SIEM platforms like Wazuh, Splunk, or Elastic Security.
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks (e.g., ensuring strict SSH hardening).rts.

---
**Maintained by:** [Nabil](https://github.com/nabilfp)
