#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh (Enhanced Edition)
# Description    : Advanced System Health, Hardware & Security Triage Tool
# Author         : Nabil
# ---------------------------------------------------------------------------

# Define color codes for a professional look
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Set dynamic log file location
LOG_FILE="/tmp/security_audit_$(date +%Y%m%d_%H%M%S).log"
REPORT_DATA=""

# Function to handle both terminal output and plain text logging
log_and_print() {
    echo -e "$1"
    # Strip ANSI color codes to keep the log file clean using regex
    clean_text=$(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    REPORT_DATA+="$clean_text\n"
}

# ---------------------------------------------------------------------------
# EXECUTION START
# ---------------------------------------------------------------------------

# Clear the terminal screen for better readability before showing the report
printf '\033c'

log_and_print "${CYAN}======================================================${RESET}"
log_and_print "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.0-PRO) 🛡️   ${RESET}"
log_and_print "${CYAN}======================================================${RESET}"

# 1. System Identity & Connectivity
log_and_print "${YELLOW}[*] SYSTEM IDENTITY${RESET}"
log_and_print "Timestamp   : $(date)"
log_and_print "OS Release  : $(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'=' -f2 | tr -d '\"')"
log_and_print "Kernel      : $(uname -r)"
log_and_print "Uptime      : $(uptime -p)"

# Detect Public IP safely
pub_ip=$(curl -s https://ifconfig.me || echo "Offline / Unreachable")
log_and_print "Public IP   : $pub_ip"

# 2. Hardware & Thermal Status (Enhanced)
log_and_print "\n${YELLOW}[*] HARDWARE & THERMAL STATUS${RESET}"

# Battery Health (Checking standard BAT0 or BAT1 interfaces)
if [ -d /sys/class/power_supply/BAT0 ]; then
    bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    bat_cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    log_and_print "Battery     : ${bat_cap}% (${bat_status})"
elif [ -d /sys/class/power_supply/BAT1 ]; then
    bat_status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
    bat_cap=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
    log_and_print "Battery     : ${bat_cap}% (${bat_status})"
else
    log_and_print "Battery     : Not present (Desktop / VM)"
fi

# CPU Temperature and Native Critical Thresholds
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp_c=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
    # Attempt to read the hardware's programmed critical trip point
    if [ -f /sys/class/thermal/thermal_zone0/trip_point_0_temp ]; then
        trip_c=$(( $(cat /sys/class/thermal/thermal_zone0/trip_point_0_temp) / 1000 ))
        log_and_print "CPU Temp    : ${temp_c}°C (Critical Limit: ${trip_c}°C)"
    else
        log_and_print "CPU Temp    : ${temp_c}°C"
    fi
else
    log_and_print "CPU Temp    : Sensor not found"
fi

# Detailed RAM and Swap Allocation
mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
log_and_print "RAM Memory  : $mem_info"
log_and_print "Swap Memory : $swap_info"

# SSD/HDD Storage Detection and Usage
# lsblk checks if the drive is rotational (1 = HDD) or solid state (0 = SSD/NVMe)
rota_check=$(lsblk -d -o ROTA | awk 'NR==2')
if [ "$rota_check" == "0" ]; then disk_type="SSD/NVMe"; else disk_type="HDD"; fi
root_usage=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
log_and_print "Storage (/) : $root_usage [Type: $disk_type]"

# 3. Security Analysis (SOC Focus)
log_and_print "\n${YELLOW}[*] SECURITY & THREAT ANALYSIS${RESET}"

# Check for Failed Login Attempts (Hunting for brute-force attacks)
failed_logins=$(journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
log_and_print "Failed SSH Logins : $failed_logins"

# Active Sessions
log_and_print "\n${CYAN}[+] Active User Sessions:${RESET}"
log_and_print "$(who)"

# Network Surface (Mapping listening ports)
log_and_print "\n${CYAN}[+] Active Listening Ports:${RESET}"
log_and_print "$(ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5)"

# Resource Hogs (Hunting for anomalies/miners)
log_and_print "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
log_and_print "$(ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 4)"

log_and_print "\n${CYAN}======================================================${RESET}"
log_and_print "${GREEN}Triage Complete. Audit log saved to: $LOG_FILE${RESET}"
log_and_print "${CYAN}======================================================${RESET}"

# Save the clean report data to the temporary directory
echo -e "$REPORT_DATA" > "$LOG_FILE"
