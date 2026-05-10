#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh (Enhanced Edition - Patch 2)
# Description    : Advanced System Health & Security Triage (No-Log Version)
# Author         : Nabil
# ---------------------------------------------------------------------------

# Define color codes for a professional look
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# EXECUTION START
# ---------------------------------------------------------------------------

# Clear the terminal screen for a clean, professional output
printf '\033c'

echo -e "${CYAN}======================================================${RESET}"
echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.0-PRO) 🛡️   ${RESET}"
echo -e "${CYAN}======================================================${RESET}"

# 1. System Identity & Connectivity
echo -e "${YELLOW}[*] SYSTEM IDENTITY${RESET}"
echo -e "Timestamp   : $(date)"
echo -e "OS Release  : $(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'=' -f2 | tr -d '\"')"
echo -e "Kernel      : $(uname -r)"
echo -e "Uptime      : $(uptime -p)"

# Detect Public IP safely
pub_ip=$(curl -s https://ifconfig.me || echo "Offline / Unreachable")
echo -e "Public IP   : $pub_ip"

# 2. Hardware & Thermal Status
echo -e "\n${YELLOW}[*] HARDWARE & THERMAL STATUS${RESET}"

# Battery Health
if [ -d /sys/class/power_supply/BAT0 ]; then
    bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    bat_cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    echo -e "Battery     : ${bat_cap}% (${bat_status})"
elif [ -d /sys/class/power_supply/BAT1 ]; then
    bat_status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
    bat_cap=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
    echo -e "Battery     : ${bat_cap}% (${bat_status})"
else
    echo -e "Battery     : Not present (Desktop / VM)"
fi

# CPU Temperature and Critical Limits
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp_c=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
    if [ -f /sys/class/thermal/thermal_zone0/trip_point_0_temp ]; then
        trip_c=$(( $(cat /sys/class/thermal/thermal_zone0/trip_point_0_temp) / 1000 ))
        echo -e "CPU Temp    : ${temp_c}°C (Critical Limit: ${trip_c}°C)"
    else
        echo -e "CPU Temp    : ${temp_c}°C"
    fi
else
    echo -e "CPU Temp    : Sensor not found"
fi

# RAM and Swap Allocation
mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
echo -e "RAM Memory  : $mem_info"
echo -e "Swap Memory : $swap_info"

# Advanced SSD/HDD Detection (Bypassing Virtual/LVM loops)
# Directly hunts for the primary physical drive name
main_drive=$(lsblk -d -n -o NAME | grep -E "^(sd|nvme)" | head -1)

if [[ "$main_drive" == *"nvme"* ]]; then
    disk_type="NVMe SSD"
else
    # Check rotational status directly from the kernel
    rota_check=$(cat /sys/block/"$main_drive"/queue/rotational 2>/dev/null)
    if [ "$rota_check" == "0" ]; then 
        disk_type="SATA SSD"
    elif [ "$rota_check" == "1" ]; then
        disk_type="HDD"
    else 
        disk_type="Unknown"
    fi
fi

root_usage=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
echo -e "Storage (/) : $root_usage [Type: $disk_type]"

# 3. Security Analysis (SOC Focus)
echo -e "\n${YELLOW}[*] SECURITY & THREAT ANALYSIS${RESET}"

# Failed SSH Logins
failed_logins=$(journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
echo -e "Failed SSH Logins : $failed_logins"

# Active Sessions
echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
echo -e "$(who)"

# Mapping listening ports
echo -e "\n${CYAN}[+] Active Listening Ports:${RESET}"
echo -e "$(ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5)"

# Resource Hogs
echo -e "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
echo -e "$(ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 4)"

echo -e "\n${CYAN}======================================================${RESET}"
echo -e "${GREEN}Triage Complete.${RESET}"
echo -e "${CYAN}======================================================${RESET}"
