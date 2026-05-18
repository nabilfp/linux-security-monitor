# 🛡️ Linux Security Monitor (v4.0 Enterprise SIEM Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring Enterprise SIEM Ready (JSON) payloads, Magic Bytes Forensic Extraction, File Integrity Monitoring (FIM), and SOAR Automation.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v4.0:**
We started with a passive monitor (v1.0), scaled into an automated SOAR platform (v3.0), and integrated DFIR forensics (v3.2). For the **v4.0 SIEM Update**, we completely rebuilt the headless automation engine. Instead of dumping human-readable text into background logs, the script now natively generates strict, structured JSON payloads. This allows the logs to be instantly ingested, indexed, and visualized by industry-standard SIEM platforms (like Wazuh, Splunk, and Elastic Stack) without requiring any external formatting tools.

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, `jq`, or Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Enterprise Integration:** Seamlessly bridges the gap between lightweight endpoint scripting and centralized SOC monitoring dashboards.

---

## 🚀 How to Run: Ghost Mode (Fileless Execution) 👻

No installation required. A true auditor doesn't leave a footprint. This command downloads and executes the script directly in your machine's RAM without saving a single file to your hard drive.

```bash
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v4-monitor.sh)
```

*(Note: If you decide to set up Daily SOAR Automation inside the interactive menu, the script will automatically fetch its own binary and safely implant it into `/usr/local/bin/`.)*

---

## 🛠️ What's Inside v4.0?

- **Enterprise SIEM Ready (JSON Payloads) [New!]:** When running in automated SOAR mode (`--cron`), the script shifts into data-engineering mode. It compiles hardware telemetry, network baselines, FIM alerts, and forensic discoveries into strict ISO-8601 JSON format.
- **Forensic Extraction (Magic Bytes Scan):** Actively hunts for hidden executable payloads inside volatile directories (`/tmp`, `/var/tmp`, `/dev/shm`). It conducts signature matching against file headers. If a binary is cross-dressed as an image (e.g., `backdoor.jpg`), the engine flags the raw **ELF** architecture instantly.
- **File Integrity Monitoring (FIM):** Generates `sha256sum` cryptographic hashes for critical authentication files (`/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, `/etc/group`). If an attacker secretly creates a backdoor user, the FIM engine catches it immediately.
- **Network Port Baselining:** Takes a snapshot of your network perimeter. Run it again, and it uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open.
- **Multilingual Bootloader:** Select English, Bahasa Indonesia, or Mandarin (中文) at startup. The entire UI adapts instantly using a high-performance memory-mapped language dictionary matrix.

---

## 🐛 Bug Fixes & Architecture Polish in v4.0

- **Native JSON Array Building:** Removed the temptation to rely on `jq` for JSON construction. The script now utilizes advanced `awk` and `sed` string manipulation to format multi-line FIM and Forensic alerts into valid JSON arrays, maintaining the 100% dependency-free promise.
- **The Stdin Buffer Vacuum:** Features a precise micro-timeout vacuum immediately following execution to flush out standard input pollution, preventing infinite loops if a user accidentally pastes huge clipboard data.
- **Volatile Directory Constraints:** Optimized the forensic scanner with a strict depth guard (`-maxdepth 3`) to ensure high-velocity sweeping without lagging the host machine's CPU.

---

## ⚠️ Current Limitations

- **Root Privileges:** Deep system logs, ACPI thermal zones, FIM shadow hashing, and Cronjob installations *require* `sudo` to function properly.
- **Point-in-Time Snapshot:** The tool is designed for rapid triage and scheduled compliance snapshots, rather than running as a persistent real-time kernel module handler (like eBPF or Auditd).

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
- [x] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [ ] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
