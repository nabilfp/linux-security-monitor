#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name    : v2-triage.sh
# Description    : Advanced System Health, Hardware & Security Triage Tool
# Author         : Nabil
# ---------------------------------------------------------------------------

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# EXECUTION START
# ---------------------------------------------------------------------------

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

pub_ip=$(curl -s https://ifconfig.me || echo "Offline / Unreachable")
echo -e "Public IP   : $pub_ip"

# 2. Hardware & Storage Status
echo -e "\n${YELLOW}[*] HARDWARE & STORAGE STATUS${RESET}"

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

mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)", $3,$2,$3*100/$2 }')
swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
echo -e "RAM Memory  : $mem_info"
echo -e "Swap Memory : $swap_info"

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

# 3. Dynamic Thermal Sensors
echo -e "\n${YELLOW}[*] THERMAL SENSORS & HARDWARE LIMITS${RESET}"

declare -A sensor_temps
declare -A sensor_limits

# A. Scan HWMON
for hwmon_dir in /sys/class/hwmon/hwmon*; do
    [ ! -e "$hwmon_dir" ] && continue
    hwmon_name=$(cat "$hwmon_dir/name" 2>/dev/null)
    
    for input_file in "$hwmon_dir"/temp*_input; do
        [ ! -e "$input_file" ] && continue
        temp_raw=$(cat "$input_file" 2>/dev/null)
        [ -z "$temp_raw" ] || [ "$temp_raw" -le 0 ] && continue
        
        temp_c=$((temp_raw / 1000))
        label_file="${input_file%_input}_label"
        label=$(cat "$label_file" 2>/dev/null)
        
        # Friendly Names
        if [[ "${hwmon_name,,}" == *"k10temp"* ]]; then human_name="AMD Ryzen CPU"
        elif [[ "${hwmon_name,,}" == *"amdgpu"* ]]; then human_name="AMD Radeon GPU"
        elif [[ "${hwmon_name,,}" == "coretemp" ]]; then 
            if [[ "${label,,}" == *"package"* ]]; then human_name="Intel CPU Package"
            elif [[ "${label,,}" == *"core"* ]]; then human_name="Intel ${label}"
            else human_name="Intel CPU"
            fi
        elif [[ "${hwmon_name,,}" == *"mt7921"* || "${hwmon_name,,}" == *"mt7922"* ]]; then human_name="MediaTek Wi-Fi"
        elif [[ "${hwmon_name,,}" == *"iwlwifi"* ]]; then human_name="Intel Wi-Fi"
        elif [[ "${hwmon_name,,}" == *"nvme"* ]]; then human_name="NVMe SSD"
        elif [[ "${hwmon_name,,}" == *"acpitz"* ]]; then human_name="Motherboard (ACPI)"
        elif [[ "${hwmon_name,,}" == *"thinkpad"* ]]; then human_name="ThinkPad Mainboard"
        else 
            human_name="$hwmon_name"
            [ -n "$label" ] && human_name="$hwmon_name ($label)"
        fi
        
        # Strict Sanity Check for hardware limits using Regex
        crit_file="${input_file%_input}_crit"
        max_file="${input_file%_input}_max"
        limit="N/A"
        
        if [ -f "$crit_file" ]; then
            limit_raw=$(cat "$crit_file" 2>/dev/null)
            if [[ "$limit_raw" =~ ^[0-9]+$ ]]; then
                lim_c=$((limit_raw / 1000))
                [ "$lim_c" -lt 150 ] && limit="${lim_c}°C"
            fi
        fi
        
        if [ "$limit" == "N/A" ] && [ -f "$max_file" ]; then
            limit_raw=$(cat "$max_file" 2>/dev/null)
            if [[ "$limit_raw" =~ ^[0-9]+$ ]]; then
                lim_c=$((limit_raw / 1000))
                [ "$lim_c" -lt 150 ] && limit="${lim_c}°C (Max)"
            fi
        fi
        
        sensor_temps["$human_name"]="${temp_c}°C"
        [ "$limit" != "N/A" ] && sensor_limits["$human_name"]="$limit"
    done
done

# B. Scan Thermal Zones (Fallback)
for zone in /sys/class/thermal/thermal_zone*; do
    [ ! -e "$zone" ] && continue
    sensor_type=$(cat "$zone/type" 2>/dev/null)
    temp_raw=$(cat "$zone/temp" 2>/dev/null)
    
    [ -z "$temp_raw" ] || [ -z "$sensor_type" ] || [ "$temp_raw" -le 0 ] && continue
    temp_c=$((temp_raw / 1000))
    
    if [[ "${sensor_type,,}" == *"acpitz"* ]]; then human_name="Motherboard (ACPI)"
    elif [[ "${sensor_type,,}" == *"x86_pkg_temp"* ]]; then human_name="Intel CPU Package"
    elif [[ "${sensor_type,,}" == *"iwlwifi"* ]]; then human_name="Intel Wi-Fi"
    elif [[ "${sensor_type,,}" == *"mt7921"* ]]; then human_name="MediaTek Wi-Fi"
    elif [[ "${sensor_type,,}" == *"nvme"* ]]; then human_name="NVMe SSD"
    else human_name="$sensor_type"
    fi
    
    limit="N/A"
    for trip_type_file in "$zone"/trip_point_*_type; do
        [ ! -e "$trip_type_file" ] && continue
        if [ "$(cat "$trip_type_file" 2>/dev/null)" == "critical" ]; then
            trip_temp_file="${trip_type_file%_type}_temp"
            limit_raw=$(cat "$trip_temp_file" 2>/dev/null)
            if [[ "$limit_raw" =~ ^[0-9]+$ ]]; then
                lim_c=$((limit_raw / 1000))
                [ "$lim_c" -lt 150 ] && limit="${lim_c}°C"
            fi
            break
        fi
    done
    
    if [ -z "${sensor_temps[$human_name]}" ]; then
        sensor_temps["$human_name"]="${temp_c}°C"
        [ "$limit" != "N/A" ] && sensor_limits["$human_name"]="$limit"
    fi
done

# C. Print Merged Data
if [ ${#sensor_temps[@]} -eq 0 ]; then
    echo -e "  Sensors             : Thermal subsystem not detected."
else
    mapfile -t sorted_keys < <(IFS=$'\n'; sort -f <<<"${!sensor_temps[*]}")
    for name in "${sorted_keys[@]}"; do
        lim="${sensor_limits[$name]:-N/A}"
        
        # Apply Standard Limits if hardware reports N/A
        if [ "$lim" == "N/A" ]; then
            case "${name,,}" in
                *cpu*) lim="95°C (Est)" ;;
                *gpu*) lim="90°C (Est)" ;;
                *nvme*|*ssd*) lim="70°C (Est)" ;;
                *wi-fi*|*wifi*) lim="80°C (Est)" ;;
                *motherboard*|*mainboard*|*acpi*) lim="85°C (Est)" ;;
                *) lim="80°C (Est)" ;;
            esac
        fi
        
        printf "  %-20s : %-6s (Limit: %s)\n" "$name" "${sensor_temps[$name]}" "$lim"
    done
fi

# 4. Security Analysis (SOC Focus)
echo -e "\n${YELLOW}[*] SECURITY & THREAT ANALYSIS${RESET}"

failed_logins=$(journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
echo -e "Failed SSH Logins : $failed_logins"

echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
echo -e "$(who)"

echo -e "\n${CYAN}[+] Active Listening Ports:${RESET}"
echo -e "$(ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5)"

echo -e "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
echo -e "$(ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 5 | grep -v "ps -eo" | head -n 4)"

echo -e "\n${CYAN}======================================================${RESET}"
echo -e "${GREEN}Triage Complete.${RESET}"
echo -e "${CYAN}======================================================${RESET}"
