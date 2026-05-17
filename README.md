# 🛡️ Linux Security Monitor (v3.2 Forensic Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring Magic Bytes Forensic Extraction, File Integrity Monitoring (FIM), SOAR Automation, and Network Port Baselining.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v3.2:**
We started with a passive monitor (v1.0), scaled into an automated SOAR platform (v3.0), and added cryptographic verification (v3.1). For the **v3.2 Forensic Update**, we integrated digital forensics and incident response (DFIR) capabilities. The script now bypasses deceptive file extensions entirely, stripping away malware cloaking techniques by analyzing raw file architecture directly inside volatile memory pathways.

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Deep DFIR Triaging:** Unmasks stealthy advanced persistent threats (APTs) and rootkit payloads hiding in world-writable system spaces using strict signature analysis.

---

## 🚀 How to Run: Ghost Mode (Fileless Execution) 👻

No installation required. A true auditor doesn't leave a footprint. This command downloads and executes the script directly in your machine's RAM without saving a single file to your hard drive.

```bash
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v3-monitor.sh)
```

*(Note: If you decide to set up Daily SOAR Automation inside the interactive menu, the script will automatically fetch its own binary and safely implant it into `/usr/local/bin/`.)*

---

## 🛠️ What's Inside v3.2?

- **Forensic Extraction (Magic Bytes Scan) [New!]:** Actively hunts for hidden executable payloads inside world-writable volatile directories (`/tmp`, `/var/tmp`, `/dev/shm`). Instead of blindly relying on fishy extensions, it conducts signature matching against the file headers. If a binary is cross-dressed as a harmless image (e.g., `backdoor.jpg`), the engine flags the raw **ELF** architecture instantly.
- **File Integrity Monitoring (FIM):** Generates `sha256sum` cryptographic hashes for critical authentication files (`/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, `/etc/group`). If an attacker secretly creates a backdoor user or alters sudo permissions, the FIM engine catches it immediately.
- **SOAR Automation:** Select option 5, and the script copies itself to `/usr/local/bin` and injects a root-level cronjob. It runs a headless audit every day at 02:00 AM, logging clean, color-stripped forensic logs to `/var/log/linux-security-monitor.log`.
- **Network Port Baselining:** Takes a snapshot of your network perimeter. Run it again, and it uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open.
- **Multilingual Bootloader:** Select English, Bahasa Indonesia, or Mandarin (中文) at startup. The entire UI adapts instantly using a high-performance memory-mapped language dictionary matrix.

---

## 🐛 Bug Fixes & Architecture Polish in v3.2

- **The Stdin Buffer Vacuum:** Fixed a notorious Bash edge-case where pasting massive chunks of clipboard text into the interactive menu would trigger an infinite error-loop. The triage loop now deploys a precise micro-timeout vacuum immediately following execution to flush out standard input pollution.
- **Volatile Directory Constraints:** Optimized the forensic scanner with a strict depth guard (`-maxdepth 3`) to ensure high-velocity directory sweeping without lagging the host machine's CPU pressure.
- **Shred-on-Exit Architecture:** Network baselines, FIM crypto logs, and temporary structures are tightly chained to the OPSEC exit sequence (Option 6), leaving the targeted disk space cleanly remediated.

---

## ⚠️ Current Limitations

- **Root Privileges:** Deep system logs, ACPI thermal zones, FIM shadow hashing, and Cronjob installations *require* `sudo` to function properly.
- **Point-in-Time Snapshot:** The tool is designed for rapid point-in-time triage and scheduled compliance snapshots, rather than running as a persistent real-time kernel module handler (like eBPF or Auditd).

---

## 🗺️ Future Roadmap (Kaizen)

We are always building. Here is the blueprint for turning this script into an Enterprise-ready SOC utility:

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [x] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [x] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [x] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files (e.g., `/etc/passwd`, `/etc/shadow`).
- [x] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes* instead of relying on file extensions.

### Phase 3: Enterprise Integration
- [ ] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
