#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh (Enhanced Edition)
# Description    : Advanced System Health & Security Triage Tool
# Author         : Nabil
# ---------------------------------------------------------------------------

# Define color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

LOG_FILE="/tmp/security_audit_$(date +%Y%m%d_%H%M%S).log"
REPORT_DATA=""

log_and_print() {
    echo -e "$1"
    clean_text=$(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    REPORT_DATA+="$clean_text\n"
}

log_and_print "${CYAN}======================================================${RESET}"
log_and_print "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.0-PRO) 🛡️   ${RESET}"
log_and_print "${CYAN}======================================================${RESET}"

# 1. System Identity & Connectivity
log_and_print "${YELLOW}[*] SYSTEM IDENTITY${RESET}"
log_and_print "Timestamp   : $(date)"
log_and_print "OS Release  : $(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'=' -f2 | tr -d '\"')"
log_and_print "Kernel      : $(uname -r)"
log_and_print "Uptime      : $(uptime -p)"

# Detect Public IP (Connectivity triage)
pub_ip=$(curl -s https://ifconfig.me || echo "Offline")
log_and_print "Public IP   : $pub_ip"

# 2. Hardware & Thermal Status
log_and_print "\n${YELLOW}[*] HARDWARE & THERMAL STATUS${RESET}"

# CPU Temperature (Native reading)
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp_c=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
    log_and_print "CPU Temp    : ${temp_c}°C"
else
    log_and_print "CPU Temp    : Sensor not found"
fi

# Resource Allocation
mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
log_and_print "Memory      : $mem_info"

# 3. Security Analysis (SOC Focus)
log_and_print "\n${YELLOW}[*] SECURITY & THREAT ANALYSIS${RESET}"

# Check for Failed Login Attempts (Common in SOC Triage)
# Note: Requires read access to /var/log/auth.log or journalctl
failed_logins=$(journalctl _SYSTEMD_UNIT=ssh.service | grep "Failed password" | wc -l 2>/dev/null || echo "N/A")
log_and_print "Failed SSH Logins : $failed_logins"

# Active Sessions
log_and_print "\n${CYAN}[+] Active User Sessions:${RESET}"
log_and_print "$(who)"

# Network Surface
log_and_print "\n${CYAN}[+] Active Listening Ports:${RESET}"
log_and_print "$(ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5)"

# Resource Hogs (Hunting for anomalies)
log_and_print "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
log_and_print "$(ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 4)"

log_and_print "\n${CYAN}======================================================${RESET}"
log_and_print "${GREEN}Triage Complete. Audit log saved to: $LOG_FILE${RESET}"
log_and_print "${CYAN}======================================================${RESET}"

echo -e "$REPORT_DATA" > "$LOG_FILE"
