# 🛡️ Linux Security Monitor (Interactive Edition)

> A sleek, dependency-free Bash utility built for instant system health checks, hardware telemetry, and security triage. Now with 100% more interactive menus.

---

## 📖 The Story & Motivation

Let's be real—monitoring a Linux server or your daily-driver laptop usually goes one of two ways: you either stare at a chaotic wall of text from `top` and `ss`, or you install a massive, bloated monitoring suite that ironically eats up the very RAM it's supposed to monitor. 

As an Information Systems student diving deep into the Blue Team (SOC) side of cybersecurity, I wanted a third option. I needed a tool that acts like a quick "vibe check" for any Linux environment. Something you can drop into a server, run instantly without worrying about broken dependencies, and get a clean, human-readable breakdown of what's happening under the hood.

**The Evolution to v2.1:**
We started with a basic one-liner script (v1.0) and moved to a deeper, linear triage tool (v2.0). But hardcoded scripts aren't exactly flexible. For this major v2.1 update, I completely rewrote the architecture into a **Modular Bash** format. Why? Because sometimes you just want to check your hardware temps without scanning your entire network surface. 

### 🎯 Core Objectives of This Project
- **Zero Bloatware:** No `npm install`, no Python virtual environments required. Just pure, native Bash.
- **Stealth & Cleanliness:** It runs, it reports, and it closes. No temporary log files cluttering your system directories anymore. Leave no trace.
- **Aesthetic by Default:** Terminal tools don't have to be ugly. The new update includes a custom ASCII system fetch that natively pulls your OS, DE, and GTK themes without forcing you to install `neofetch` or `fastfetch`.

---

## 🚀 How to Install & Run (v2.1)

We've moved past the `curl | bash` wild west. To use the new interactive menu properly, grab the repository to your local machine. It takes less than 10 seconds.

```bash
# 1. Clone the repository
git clone [https://github.com/nabilfp/linux-security-monitor.git](https://github.com/nabilfp/linux-security-monitor.git)
cd linux-security-monitor

# 2. Make it executable
chmod +x v2-triage.sh

# 3. Launch the interactive menu
./v2-triage.sh
```

---

## 🛠️ What's Inside v2.1?

- **Interactive CLI Menu:** Choose exactly what you want to audit (System Identity, Hardware, Security, or a Full Sweep) by just pressing a number.
- **Native System Fetch:** A built-in Tux ASCII art that dynamically reads your OS release, Kernel, Uptime, and GNOME/GTK configurations natively via `gsettings`.
- **Smart Thermal Heuristics:** Automatically scans `/sys/class/hwmon/` for CPU, GPU, NVMe, and Wi-Fi temps. If hardware vendors (like AMD) hide their critical limits, the script automatically applies standard SOC safety heuristics (e.g., flagging CPUs at 95°C).
- **Anti-Observer Process Monitor:** The top CPU process tracker is now smart enough to exclude itself from the list, so you don't get false alarms during your threat hunting.
- **Threat Triage:** Instant mapping of failed SSH logins (brute-force hunting) and open internet-facing TCP/UDP ports.

---

## ⚠️ Current Limitations

- **Root Privileges:** Designed to run safely as a normal user. However, deep system logs (like certain failed SSH attempts via `journalctl`) might require `sudo` to display properly depending on your distro's permission settings.
- **Diagnostic, not IDS:** This is an active triage tool for quick audits, not a 24/7 background Intrusion Detection System. (Though automation is coming in phase 2!)

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
