# 🛡️ Linux Security Monitor (v4.1 Enterprise CIS Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and active security triage. Now featuring CIS Benchmarks Auditing, Enterprise SIEM (JSON) payloads, Magic Bytes Forensic Extraction, FIM, and SOAR Automation.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v4.1 (Final Milestone):**
We started with a passive monitor (v1.0), scaled into an automated SOAR platform (v3.0), and integrated SIEM JSON payloads (v4.0). For the **v4.1 Final Update**, we introduced Automated CIS Auditing. The script now inspects the host machine against the Center for Internet Security (CIS) Level 1 Server benchmarks, instantly flagging severe misconfigurations like unauthorized SSH root access and disabled memory protections (ASLR).

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, `jq`, or Python virtual environments required. Just pure, native Bash.
- **OPSEC-First (Leave No Trace):** A true auditor doesn't leave their tools behind. This update features ephemeral execution and a self-destruct mechanism to wipe both the project folder and temporary baselines upon exit.
- **Enterprise Integration:** Seamlessly bridges the gap between lightweight endpoint scripting, compliance auditing (CIS), and centralized SOC monitoring dashboards.

---

## 🚀 How to Run: Ghost Mode (Fileless Execution) 👻

No installation required. A true auditor doesn't leave a footprint. This command downloads and executes the script directly in your machine's RAM without saving a single file to your hard drive.

```bash
bash <(curl -sL https://raw.githubusercontent.com/nabilfp/linux-security-monitor/main/v4-monitor.sh)
```

*(Note: If you decide to set up Daily SOAR Automation inside the interactive menu, the script will automatically fetch its own binary and safely implant it into `/usr/local/bin/`.)*

---

## 🛠️ What's Inside v4.1?

- **CIS Benchmarks Auditing [New!]:** Evaluates the host system's configuration against strict CIS guidelines. It verifies if Kernel ASLR is enabled, ensures IPv4 forwarding is disabled to prevent rogue routing, and scans active SSH daemon configs to block empty passwords and direct root logins.
- **Enterprise SIEM Ready (JSON Payloads):** When running in automated SOAR mode (`--cron`), the script outputs strict ISO-8601 JSON format. It encapsulates CIS results, telemetry, and forensic alerts natively, ready to be ingested by Wazuh, Splunk, or Elastic Stack.
- **Forensic Extraction (Magic Bytes Scan):** Actively hunts for hidden executable payloads inside volatile directories (`/tmp`, `/var/tmp`, `/dev/shm`). If a binary is cross-dressed as an image (e.g., `backdoor.jpg`), the engine flags the raw **ELF** architecture instantly.
- **File Integrity Monitoring (FIM):** Generates `sha256sum` hashes for critical authentication files (`/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, `/etc/group`).
- **Network Port Baselining:** Uses set-theory mathematics to hunt down newly opened suspicious ports (e.g., Reverse Shells) and directly identifies the rogue process PIDs holding them open.

---

## 🐛 Bug Fixes & Architecture Polish in v4.1

- **Daemon Config Parsing:** The CIS SSH check utilizes `sshd -T` to parse the *effective* configuration loaded in memory, avoiding false positives caused by manually reading heavily commented `/etc/ssh/sshd_config` files.
- **Native JSON Array Building:** Uses advanced `awk` and `sed` string manipulation to format multi-line FIM and Forensic alerts into valid JSON arrays, maintaining the 100% dependency-free promise.
- **The Stdin Buffer Vacuum:** Features a precise micro-timeout vacuum immediately following execution to flush out standard input pollution, preventing infinite loops.

---

## ⚠️ Current Limitations

- **Root Privileges:** Deep system logs, ACPI thermal zones, FIM shadow hashing, CIS parameter extraction, and Cronjob installations *require* `sudo` to function properly.
- **Point-in-Time Snapshot:** The tool is designed for rapid triage and scheduled compliance snapshots, rather than running as a persistent real-time kernel module handler (like eBPF or Auditd).

---

## 🗺️ Project Roadmap (Completed)

This project has successfully completed all planned development phases, evolving from a simple monitoring script into a robust Enterprise SOC utility.

### Phase 1: Usability & Baselining
- [x] **v2.1 (Interactive Mode):** Implement a simple interactive CLI menu so users can choose specific targeted checks.
- [x] **v2.2 (Network Baselining):** Introduce a mechanism to compare current open ports with a saved baseline to automatically flag *new* suspicious ports or potential reverse shells.

### Phase 2: Automation & Threat Hunting
- [x] **v3.0 (Automation / SOAR):** Add an installation script to automatically set up a Linux `cronjob` for daily, hands-free background security auditing.
- [x] **v3.1 (Proactive Threat Hunting):** Implement lightweight FIM (File Integrity Monitoring) using `sha256sum` to detect unauthorized modifications to critical system files.
- [x] **v3.2 (Forensic Extraction):** Add capabilities to scan temporary directories (like `/tmp/`) for disguised malware by reading *magic bytes*.

### Phase 3: Enterprise Integration
- [x] **v4.0 (Enterprise SIEM Ready):** Convert the plain-text audit logs into structured JSON payloads for modern SIEM platforms (Wazuh, Splunk, Elastic).
- [x] **v4.1 (CIS Auditing):** Automate server configuration checks against the Center for Internet Security (CIS) benchmarks.

---
**Maintained with ☕ by:** [Nabil](https://github.com/nabilfp)
