#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh (Human-Readable Patch)
# Description    : Advanced System Health, Hardware & Security Triage Tool
# Author         : Nabil
# ---------------------------------------------------------------------------

# Define color codes for a professional look
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Define friendly names for cryptic thermal zone types
declare -A friendly_names
friendly_names["acpitz"]="Motherboard Zone"
friendly_names["x86_pkg_temp"]="CPU Package"
friendly_names["iwlwifi_1"]="WiFi Modul"
friendly_names["nvme"]="NVMe SSD"
# Names for other zones will be listed as-is

# Variable to accumulate all thermal data entries
final_thermal_output=""

# ---------------------------------------------------------------------------
# EXECUTION START
# ---------------------------------------------------------------------------

# Clear the terminal screen for a clean output before starting
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

# 2. Hardware & Storage Status
echo -e "\n${YELLOW}[*] HARDWARE & STORAGE STATUS${RESET}"

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

# RAM and Swap Allocation
mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
echo -e "RAM Memory  : $mem_info"
echo -e "Swap Memory : $swap_info"

# Advanced SSD/HDD Detection
main_drive=$(lsblk -d -n -o NAME | grep -E "^(sd|nvme)" | head -1)
if [[ "$main_drive" == *"nvme"* ]]; then
    disk_type="NVMe SSD"
else
    rota_check=$(cat /sys/block/"$main_drive"/queue/rotational 2>/dev/null)
    if [ "$rota_check" == "0" ]; then disk_type="SATA SSD"
    elif [ "$rota_check" == "1" ]; then disk_type="HDD"
    else disk_type="Unknown"; fi
fi

root_usage=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
echo -e "Storage (/) : $root_usage [Type: $disk_type]"

# 3. Dynamic Thermal Sensors (ALL COMPONENTS & Friendly Names)
echo -e "\n${YELLOW}[*] THERMAL SENSORS & HARDWARE LIMITS${RESET}"

# A. Deep Dive: Scan HWMon for granular core-level sensors
for hwmon_dir in /sys/class/hwmon/hwmon*; do
    [ ! -e "$hwmon_dir" ] && continue
    hwmon_name=$(cat "$hwmon_dir/name" 2>/dev/null)
    
    # Process only CPU Coretemp data
    if [ "$hwmon_name" == "coretemp" ]; then
        for input_file in "$hwmon_dir"/temp*_input; do
            [ ! -e "$input_file" ] && continue
            
            # Read current core label and input temp
            label_file="${input_file%_input}_label"
            core_label=$(cat "$label_file" 2>/dev/null)
            temp_raw=$(cat "$input_file" 2>/dev/null)
            
            # Formulate core friendly name
            if [[ "$core_label" == *"Package"* ]]; then
                human_name="CPU Package"
            elif [[ "$core_label" == *"Core"* ]]; then
                core_num=$(echo "$core_label" | awk '{print $2}')
                human_name="CPU Core $core_num"
            else
                human_name="CPU Part"
            fi
            
            temp_c=$((temp_raw / 1000))
            final_thermal_output+="  %-15s : %-6s (Critical Limit: N/A)\n" "$human_name" "${temp_c}°C"
        done
    fi
done

# B. Thermal Zones: Scan for broader zones and their critical limits
for zone in /sys/class/thermal/thermal_zone*; do
    [ ! -e "$zone" ] && continue
    
    sensor_type=$(cat "$zone/type" 2>/dev/null)
    temp_raw=$(cat "$zone/temp" 2>/dev/null)
    
    if [ -z "$temp_raw" ] || [ -z "$sensor_type" ] || [ "$temp_raw" -le 0 ]; then continue; fi
    
    temp_c=$((temp_raw / 1000))
    
    # Check if a friendly name exists for this zone
    if [[ -n "${friendly_names[$sensor_type]}" ]]; then
        human_name="${friendly_names[$sensor_type]}"
    else
        human_name="$sensor_type (Z)"
    fi

    # Check for core sensors already added via hwmon (Package temp) to avoid duplication
    if [[ "$human_name" == "CPU Package" ]] && [[ "$final_thermal_output" == *"CPU Package"* ]]; then
        continue
    fi
    
    # Check for other sensors that might be duplicated between interfaces
    if [[ "$final_thermal_output" == *"$human_name"* ]]; then
        continue
    fi

    # Dynamically find the critical trip point for this specific component
    limit="N/A"
    for trip_type_file in "$zone"/trip_point_*_type; do
        [ ! -e "$trip_type_file" ] && continue
        if [ "$(cat "$trip_type_file" 2>/dev/null)" == "critical" ]; then
            trip_temp_file="${trip_type_file%_type}_temp"
            limit_raw=$(cat "$trip_temp_file" 2>/dev/null)
            limit="$((limit_raw / 1000))°C"
            break
        fi
    done
    
    # Formatted output addition
    final_thermal_output+="  %-15s : %-6s (Critical Limit: %s)\n" "$human_name" "${temp_c}°C" "$limit"
done

# Print all accumulated data
if [ -z "$final_thermal_output" ]; then
    echo -e "  Sensors       : Thermal subsystem not detected."
else
    # Use echo to resolve newlines inside the variable
    echo -e "$final_thermal_output"
fi

# 4. Security Analysis (SOC Focus)
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
echo -e "${GREEN}Triage Complete. (No trace logs left on system)${RESET}"
echo -e "${CYAN}======================================================${RESET}"
