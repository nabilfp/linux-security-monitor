#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh
# Description    : Advanced System Health & Security Triage Tool
# Author         : Nabil
# ---------------------------------------------------------------------------

# Define color codes for clean CLI output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Define dynamic log file location in the temporary directory
LOG_FILE="/tmp/security_audit_$(date +%Y%m%d_%H%M%S).log"
REPORT_DATA=""

# Helper function to print to terminal and append to log variable
log_and_print() {
    echo -e "$1"
    # Strip ANSI colors for clean text logging using regex
    clean_text=$(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    REPORT_DATA+="$clean_text\n"
}

log_and_print "${CYAN}======================================================${RESET}"
log_and_print "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.0) 🛡️   ${RESET}"
log_and_print "${CYAN}======================================================${RESET}"
log_and_print "Timestamp : $(date)"
log_and_print "Hostname  : $(hostname)"
log_and_print "Kernel    : $(uname -r)"
log_and_print "------------------------------------------------------"

# 1. Hardware & Resource Check
log_and_print "\n${YELLOW}[*] SYSTEM RESOURCES & HARDWARE${RESET}"

# CPU Load Average
load_avg=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)
log_and_print "Load Average   : $load_avg"

# Memory Allocation
mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
log_and_print "Memory Status  : $mem_info"

# Root Storage
disk_info=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
log_and_print "Root Partition : $disk_info"

# System Uptime
echo -e "\n[+] System Uptime:${NC}"
uptime -p

# 2. Security Triage (SOC Analyst Perspective)
log_and_print "\n${YELLOW}[*] SECURITY POSTURE & THREAT TRIAGE${RESET}"

# Check currently logged-in users
log_and_print "\n${CYAN}[+] Active User Sessions:${RESET}"
log_and_print "$(who)"

# Check for open internet-facing ports (Potential attack vectors)
log_and_print "\n${CYAN}[+] Active Listening Ports (TCP/UDP):${RESET}"
log_and_print "$(ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5)"

# Identify top CPU-consuming processes (Hunting for cryptominers/malware)
log_and_print "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
log_and_print "$(ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 4)"

log_and_print "\n${CYAN}======================================================${RESET}"
log_and_print "${GREEN}Triage Complete.${RESET}"
log_and_print "${CYAN}======================================================${RESET}"

# 3. Post-Processing: Generate Audit Log
echo -e "$REPORT_DATA" > "$LOG_FILE"
echo -e " ${GREEN}[✔] A clean audit report has been saved to:${RESET} ${YELLOW}$LOG_FILE${RESET}"
