# 🛡️ Linux Security Monitor

A professional, lightweight Bash-based tool designed to provide an instant overview of system health, resource allocation, and basic security triage. Built specifically for Linux environments (Ubuntu, Arch, Debian).

---

## 📖 Background & Motivation
This project was born out of the necessity for a fast, reliable, and dependency-free triage tool. As an Information Systems student exploring the defense side of cybersecurity, I needed a script that could execute instantly across different Linux servers to quickly identify performance bottlenecks and potential security attack vectors (like unauthorized active sessions or open ports).

## 🚀 Instant Usage (One-Liner)

### Version 2.0 (Advanced Triage & Auto-Logging)
The recommended version. It performs a deeper security check (active users, top CPU consumers to hunt anomalies) and safely generates a clean `.log` file in your `/tmp/` directory without cluttering your workspace.

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
3. **Thermal Monitoring:** Native CPU temperature check without external dependencies.
4. **Security Triage:** - Failed login attempt counter (via systemd journal).
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
Continuous improvement is key. Here are the planned updates for upcoming releases:
- [ ] **v2.1 (Interactive Mode):** Implement a simple interactive menu so users can choose to run specific checks (e.g., Network Only, Hardware Only).
- [ ] **v3.0 (Automation):** Add an installation script to automatically set up a Linux `cronjob` for daily background security auditing.
- [ ] **v3.1 (Baseline Comparison):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports.

---
**Maintained by:** [Nabil](https://github.com/nabilfp)
