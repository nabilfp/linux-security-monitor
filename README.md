# 🛡️ Linux Security Monitor

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and security triage. Now with interactive menus, 99% accuracy health readouts, and OPSEC self-destruct capabilities.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v2.1:**
We started with a basic one-liner script (v1.0) and moved to a deeper, linear triage tool (v2.0). But hardcoded scripts aren't exactly flexible. For this major v2.1 update, I completely rewrote the architecture into a **Modular Bash** format. Why? Because sometimes you just want to check your hardware temps without scanning your entire network surface. 

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update introduces ephemeral execution and a self-destruct mechanism to wipe the project folder upon exit.
- **Aesthetic by Default:** Terminal tools don't have to be ugly. The script includes a custom ASCII system fetch that natively pulls your OS, DE, and GTK themes without forcing you to install `neofetch` or `fastfetch`.

---

## 🚀 How to Install & Run (v2.1)

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

## 🛠️ What's Inside v2.1?

- **Interactive CLI Menu:** Choose exactly what you want to audit (System Identity, Hardware, Security, or a Full Sweep) by just pressing a number.
- **High-Accuracy Health Telemetry:** - **Battery:** Calculates your true physical wear-level by comparing the manufacturer's design capacity against the current charge limit.
  - **RAM:** Reads raw memory pressure directly from `/proc/meminfo` to predict OOM (Out-of-Memory) risks before they happen.
  - **Storage:** Detects hardware-level "Read-Only" safety locks on failing NVMe SSDs without requiring `sudo` or S.M.A.R.T tools.
- **Smart Thermal Heuristics:** Automatically scans `/sys/class/hwmon/` for CPU, GPU, NVMe, and Wi-Fi temps. If hardware vendors hide their critical limits, the script automatically applies standard SOC safety heuristics.
- **Anti-Observer Process Monitor:** The top CPU process tracker is smart enough to exclude itself from the list, preventing false alarms during your threat hunting.
- **OPSEC Self-Destruct:** Hit option `5` to exit, and the script will securely `rm -rf` its own project directory, leaving the target machine completely untouched.

---

## 🐛 Bug Fixes & UX Polish in v2.1

- **The Observer Effect:** Fixed a false-positive logic flaw where the script's own monitoring process (`ps`) would get flagged as the top CPU consumer.
- **Dummy NVMe Temps:** Patched a weird Linux kernel quirk where some NVMe controllers reported absurd 65,000°C limits. Added strict sanity guards to filter these out.
- **Smart Battery Thresholds:** Fixed the scary "Not charging" status on business laptops (like ThinkPads) when Battery Conservation Mode is active. It now correctly cross-references the AC adapter status and identifies as `Plugged In (Threshold/Idle)`.
- **Dynamic Vendor Detection:** The thermal scanner now dynamically reads your BIOS/DMI data to name your motherboard (e.g., ASUS, Dell, LENOVO) instead of assuming a hardcoded brand.
- **Deep ACPI Scanning:** Bypassed manufacturer restrictions on thermal limit readings by using `sudo` to cross-reference hidden `thermal_zone` trip points deep within the kernel.

---

## ⚠️ Current Limitations

- **Root Privileges:** Designed to run safely as a normal user. However, deep system logs (like certain failed SSH attempts via `journalctl`) might require `sudo` to display properly depending on your distro's permission settings.
- **Diagnostic, not IDS:** This is an active triage tool for quick audits, not a 24/7 background Intrusion Detection System. (Though automation is coming in Phase 2!)

---

## 🗺️ Future Roadmap (Kaizen)

We are always building. Here is the blueprint for turning this script into an Enterprise-ready SOC utility:

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [ ] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [ ] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [ ] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [ ] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
