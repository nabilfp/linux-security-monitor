# 🛡️ Linux Security Monitor (v2.2 Global Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring Network Port Baselining, Multilingual Support (i18n), and OPSEC self-destruct capabilities.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v2.2:**
We started with a basic one-liner script (v1.0) and moved to a modular triage tool (v2.1). But for the **v2.2 Global Update**, I wanted to push the boundaries of what pure Bash can do. We transformed this script from a *passive* monitor into an *active* Threat Hunting tool (Mini-IDS) and engineered a dynamic dictionary matrix so it can be deployed by international teams.

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Borderless (i18n):** Security has no language barrier. The UI dynamically shifts languages without duplicating script files or requiring external libraries.

---

## 🚀 How to Install & Run (v2.2)

Choose your execution style: the permanent local setup, or the stealthy "Ghost Mode."

### Option A: Standard Interactive (Local Repo)
Best if you plan to use this frequently on your personal machine.
```bash
# 1. Clone the repository
git clone https://github.com/nabilfp/linux-security-monitor.git
cd linux-security-monitor

# 2. Make it executable
chmod +x v2-triage.sh

# 3. Launch the interactive menu
./v2-triage.sh
```

### Option B: Ghost Mode (Fileless Execution) 👻
Running an audit on a remote server? Don't leave a footprint. This command downloads and executes the script directly in the machine's RAM.
```bash
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v2-triage.sh)
```

---

## 🛠️ What's Inside v2.2?

- **Network Port Baselining (New!):** Takes a snapshot of your network perimeter. Run it again, and it uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open!
- **Multilingual Bootloader (New!):** Select English, Bahasa Indonesia, or Mandarin (中文) at startup. The entire UI, including threat alerts and Sudo prompts, adapts instantly.
- **High-Accuracy Health Telemetry:** 
  - **Battery:** Calculates true physical wear-level using manufacturer design capacity vs. current limits.
  - **RAM:** Reads raw memory pressure directly from `/proc/meminfo` to predict OOM (Out-of-Memory) risks.
  - **Storage:** Detects hardware-level "Read-Only" safety locks on failing NVMe/SATA SSDs.
- **Smart Thermal Heuristics:** Automatically scans deep ACPI Thermal Zones. If hardware vendors hide their critical limits, the script automatically applies standard SOC safety heuristics.
- **Anti-Observer Process Monitor:** The top CPU process tracker is smart enough to exclude itself from the list, preventing false alarms during threat hunting.

---

## 🐛 Bug Fixes & Architecture Polish in v2.2

- **i18n Matrix Implementation:** Solved the localization problem cleanly. Instead of bloated `if/else` UI printing, v2.2 uses a high-performance Language Dictionary Matrix loaded into memory before execution.
- **Smart Battery Thresholds:** Fixed the scary "Not charging" status on business laptops (like ThinkPads) when Battery Conservation Mode is active. It now cross-references the AC adapter and identifies as `Plugged In (Idle)`.
- **Dynamic Vendor Detection:** The thermal scanner now reads BIOS/DMI data to dynamically name your motherboard (e.g., ASUS, Dell, LENOVO).
- **Ephemeral Baselining:** Network baseline snapshots are safely stored in `/tmp/` and are strictly linked to the OPSEC exit protocol (Option 5) to ensure zero forensic trace is left behind.

---

## ⚠️ Current Limitations

- **Root Privileges:** Designed to run safely as a normal user. However, deep system logs (like certain failed SSH attempts via `journalctl`) and hardware limit overrides *require* `sudo` to display properly.
- **Diagnostic, not a Daemon:** This is an active triage tool for quick audits, not a 24/7 background Intrusion Detection System. (Though automation is coming in Phase 2!)

---

## 🗺️ Future Roadmap (Kaizen)

We are always building. Here is the blueprint for turning this script into an Enterprise-ready SOC utility:

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [x] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [ ] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [ ] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [ ] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
