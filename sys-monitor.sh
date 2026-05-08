# 🛡️ Linux Security Monitor

A professional, lightweight Bash-based tool designed to provide an instant overview of system health and security posture. Built specifically for Linux environments (Ubuntu, Arch, Debian).

## 🚀 Instant Usage
You don't need to install anything. Run this command directly in your terminal:

```bash
curl -sL [https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/sys-monitor.sh](https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/sys-monitor.sh) | bash
```

---

## 🛠️ How It's Made (Technical Details)
This project was developed using **Bash Scripting** and standard Linux binaries. The script automates several manual checks that a System Administrator or SOC Analyst typically performs:

1.  **Core Logic:** Uses `awk` and `grep` for data parsing and filtering.
2.  **Resource Monitoring:** Utilizes `free` and `df` for real-time hardware status.
3.  **Security Layer:** Implements `ss` (Socket Statistics) to identify listening ports that could be potential entry points for unauthorized access.
4.  **UI/UX:** Uses ANSI color codes to provide a clear, readable interface in the terminal.

## ⚠️ Weaknesses & Limitations
As a lightweight monitoring tool, users should be aware of:
- **No Persistence:** This script does not save logs to a file (yet). It only shows real-time data.
- **Root Permissions:** Some security information (like specific process names on ports) might require `sudo` to be fully visible.
- **Basic Level:** This is a diagnostic tool, not a full-scale Intrusion Detection System (IDS).

## 🛑 How to Stop
Since this script runs a sequence of commands and then finishes, it will stop automatically. However, if you want to terminate the execution while it's running, simply press:
**`Ctrl + C`** on your keyboard.

## 📈 Future Roadmap
- [ ] Add auto-logging to a `.log` file.
- [ ] Add Slack/Discord notification alerts.
- [ ] Add CPU temperature monitoring.

---
**Maintained by:** [Nabil](https://github.com/nabilfp)  
*Currently pursuing Information Systems degree.*
