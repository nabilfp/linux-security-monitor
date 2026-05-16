# 🛡️ Linux Security Monitor (v3.1 FIM Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring File Integrity Monitoring (FIM), SOAR Automation, Network Port Baselining, and OPSEC self-destruct capabilities.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v3.1:**
We started with a passive monitor (v1.0), moved to an active Threat Hunting tool (v2.2), and introduced headless daily automation (v3.0). But for the **v3.1 Update**, we stepped into the territory of a true Intrusion Detection System (IDS). The script now performs cryptographic hashing (FIM) to catch stealthy privilege escalation attempts.

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Proactive Defense:** Capable of establishing cryptographic baselines for critical system files to detect unauthorized modifications.

---

## 🚀 How to Run: Ghost Mode (Fileless Execution) 👻

No installation required. A true auditor doesn't leave a footprint. This command downloads and executes the script directly in your machine's RAM without saving a single file to your hard drive.

```bash
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v3-monitor.sh)
```

*(Note: If you decide to set up Daily SOAR Automation inside the interactive menu, the script will automatically fetch its own binary and safely implant it into `/usr/local/bin/`.)*

---

## 🛠️ What's Inside v3.1?

- **File Integrity Monitoring (FIM) [New!]:** Generates `sha256sum` cryptographic hashes for critical authentication files (`/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, `/etc/group`). If an attacker secretly creates a backdoor user, the FIM engine will immediately flag the breached integrity during the next audit.
- **SOAR Automation:** Select option 5, and the script will copy itself to `/usr/local/bin` and inject a safe, root-level cronjob. It runs a headless audit every day at 02:00 AM, logging clean, color-stripped data to `/var/log/linux-security-monitor.log`.
- **Network Port Baselining:** Takes a snapshot of your network perimeter. Run it again, and it uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open.
- **Multilingual Bootloader:** Select English, Bahasa Indonesia, or Mandarin (中文) at startup. The entire UI adapts instantly using a dynamic dictionary matrix.
- **High-Accuracy Health Telemetry:** - **Battery:** Calculates true physical wear-level using manufacturer design capacity vs. current limits.
  - **RAM:** Reads raw memory pressure directly from `/proc/meminfo` to predict OOM risks.
  - **Storage:** Detects hardware-level "Read-Only" safety locks on failing SSDs.
- **Smart Thermal Heuristics:** Automatically scans deep ACPI Thermal Zones and applies standard SOC safety heuristics if vendors hide their hardware limits.

---

## 🐛 Bug Fixes & Architecture Polish in v3.1

- **The Stdin Vacuum Cleaner:** Fixed a classic Bash edge-case where accidentally pasting large blocks of text into the interactive menu would cause an infinite spam loop. The script now utilizes a micro-timeout `read` function to instantly flush and vacuum the terminal buffer after user inputs.
- **Persistent vs Ephemeral Baselines:** Both Network and FIM baselines are stored in `/var/tmp/` so they survive system reboots for the daily cronjob, but they are completely shredded when initiating the OPSEC exit protocol.
- **Intelligent Ghost Mode Detection:** When setting up daily automation, the script detects if it's running in RAM (Ghost Mode) and dynamically fetches its own binary from GitHub to plant into the system safely.
- **Graceful Interrupts:** Implemented `trap` signals for `SIGINT/SIGTERM`. Pressing `Ctrl+C` will exit the script gracefully without leaving ghost processes.

---

## ⚠️ Current Limitations

- **Root Privileges:** Deep system logs, hardware limit overrides, FIM hashing for `/etc/shadow`, and Cronjob installations *require* `sudo` to function properly.
- **Point-in-Time Snapshot:** While v3.1 features daily automation, the auditing is snapshot-based (runs at a specific scheduled time), not a real-time kernel hook like eBPF.

---

## 🗺️ Future Roadmap (Kaizen)

We are always building. Here is the blueprint for turning this script into an Enterprise-ready SOC utility:

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [x] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [x] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [x] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [ ] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
