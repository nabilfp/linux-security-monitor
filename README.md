# 🛡️ Linux Security Monitor (v3.0 SOAR Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring SOAR Automation, Network Port Baselining, Multilingual Support (i18n), and OPSEC self-destruct capabilities.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v3.0:**
We started with a basic one-liner script (v1.0) and moved to an active Threat Hunting tool (v2.2). But for the **v3.0 SOAR Update**, we breached the barrier of manual execution. The script can now install itself as a headless background process, providing hands-free, automated security auditing every single day.

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Automated (SOAR):** Capable of setting up its own root-level cronjobs for daily execution without spamming your storage with massive log files.

---

## 🚀 How to Run: Ghost Mode (Fileless Execution) 👻

No installation required. A true auditor doesn't leave a footprint. This command downloads and executes the script directly in your machine's RAM without saving a single file to your hard drive.

```
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v3-monitor.sh)
```

*(Note: If you decide to set up Daily SOAR Automation inside the interactive menu, the script will automatically fetch its own binary and safely implant it into `/usr/local/bin/`.)*

---

## 🛠️ What's Inside v3.0?

- **SOAR Automation (New!):** Select option 5, and the script will copy itself to `/usr/local/bin` and inject a safe, root-level cronjob. It will run a headless audit every day at 02:00 AM, stripping ANSI colors to generate clean logs at `/var/log/linux-security-monitor.log`.
- **Network Port Baselining:** Takes a snapshot of your network perimeter. Run it again, and it uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open.
- **Multilingual Bootloader:** Select English, Bahasa Indonesia, or Mandarin (中文) at startup. The entire UI, including threat alerts and Sudo prompts, adapts instantly.
- **High-Accuracy Health Telemetry:** 
  - **Battery:** Calculates true physical wear-level using manufacturer design capacity vs. current limits.
  - **RAM:** Reads raw memory pressure directly from `/proc/meminfo` to predict OOM (Out-of-Memory) risks.
  - **Storage:** Detects hardware-level "Read-Only" safety locks on failing NVMe/SATA SSDs.
- **Smart Thermal Heuristics:** Automatically scans deep ACPI Thermal Zones. If hardware vendors hide their critical limits, the script automatically applies standard SOC safety heuristics.

---

## 🐛 Bug Fixes & Architecture Polish in v3.0

- **Intelligent Ghost Mode Detection:** When setting up daily automation, the script now detects if it's running in RAM (Ghost Mode). If so, it dynamically fetches its own binary from GitHub to plant into the system securely.
- **Persistent vs Ephemeral Baselines:** Network baselines were moved to `/var/tmp/` so they survive system reboots for the daily cronjob, but they are still safely shredded by the OPSEC exit protocol.
- **Graceful Interrupts:** Implemented `trap` signals for `SIGINT/SIGTERM`. If you press `Ctrl+C` or accidentally paste a huge block of text into the terminal, the script will vacuum the stdin buffer and exit gracefully instead of causing a runaway spam loop.
- **i18n Matrix Implementation:** Solved the localization problem cleanly via a high-performance Language Dictionary Matrix loaded into memory before execution.

---

## ⚠️ Current Limitations

- **Root Privileges:** Deep system logs (like failed SSH attempts via `journalctl`), hardware limit overrides, and Cronjob installations *require* `sudo` to function properly.
- **Point-in-Time Snapshot:** While v3.0 introduces daily automation, the auditing is snapshot-based (runs at a specific time), not a real-time kernel hook like eBPF.

---

## 🗺️ Future Roadmap (Kaizen)

We are always building. Here is the blueprint for turning this script into an Enterprise-ready SOC utility:

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [x] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [x] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [ ] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [ ] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
