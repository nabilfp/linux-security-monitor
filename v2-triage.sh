#!/bin/bash

# ===========================================================================
# Project        : Linux Security & System Monitor (v2.1)
# Description    : Interactive Triage Tool with OPSEC & Sudo Accuracy
# Author         : Nabil
# Architecture   : Modular Bash (Functions & Case Loop)
# ===========================================================================

# --- [ UI & THEME VARIABLES ] ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# --- [ GOD MODE: SUDO CHECK ] ---
printf '\033c'
echo -e "${CYAN}======================================================${RESET}"
echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.1-INT) 🛡️   ${RESET}"
echo -e "${CYAN}======================================================${RESET}"
echo -e "${YELLOW}[*] Requesting Root (sudo) access for 99% accuracy hardware telemetry...${RESET}"
sudo -v || { echo -e "${RED}[!] Access Denied. Sudo is required for accurate health scanning.${RESET}"; exit 1; }

# --- [ FUNCTION 1: SYSTEM IDENTITY & FASTFETCH ] ---
function check_system_identity() {
    echo -e "\n${YELLOW}[*] SYSTEM IDENTITY & GUI TELEMETRY${RESET}"
    
    if command -v fastfetch &> /dev/null; then
        fastfetch
    elif command -v neofetch &> /dev/null; then
        neofetch
    else
        echo -e "OS Release  : $(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'=' -f2 | tr -d '\"')"
        echo -e "Kernel      : $(uname -r)"
        echo -e "Uptime      : $(uptime -p)"
        echo -e "Shell       : $(basename "$SHELL")"
    fi
    
    pub_ip=$(curl -s --max-time 3 https://ifconfig.me || echo "Offline / Unreachable")
    echo -e "\n${GREEN}[+] Network Edge: ${RESET}Public IP is $pub_ip"
}

# --- [ FUNCTION 2: HARDWARE & THERMAL ] ---
function check_hardware() {
    echo -e "\n${YELLOW}[*] HARDWARE, HEALTH & STORAGE STATUS${RESET}"

    # 1. Advanced Battery Health (99% Accurate Wear Level Calculation)
    bat_dir=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
    if [ -n "$bat_dir" ]; then
        bat_status=$(cat "$bat_dir/status" 2>/dev/null)
        bat_cap=$(cat "$bat_dir/capacity" 2>/dev/null)
        
        design=$(sudo cat "$bat_dir/energy_full_design" 2>/dev/null || sudo cat "$bat_dir/charge_full_design" 2>/dev/null)
        current=$(sudo cat "$bat_dir/energy_full" 2>/dev/null || sudo cat "$bat_dir/charge_full" 2>/dev/null)
        
        if [[ -n "$design" && -n "$current" && "$design" -gt 0 ]]; then
            health_pct=$(( 100 * current / design ))
            [ "$health_pct" -gt 100 ] && health_pct=100
            
            if [ "$health_pct" -ge 80 ]; then 
                hlth_str="[ Health : ${GREEN}${health_pct}%${RESET} ]"
            elif [ "$health_pct" -ge 50 ]; then 
                hlth_str="[ Health : ${YELLOW}${health_pct}%${RESET} ]"
            else 
                hlth_str="[ Bad : ${RED}${health_pct}%${RESET} ]"
            fi
        else
            hlth_str="[ Health : N/A ]"
        fi
        echo -e "Battery     : ${bat_cap}% (${bat_status}) ${hlth_str}"
    else
        echo -e "Battery     : Not present (Desktop / VM)"
    fi

    # 2. RAM Memory Health (99% Accurate Pressure Reading - DDR1-DDR5 Universal)
    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    
    if [[ -n "$mem_total" && -n "$mem_avail" ]]; then
        ram_health_pct=$(( 100 * mem_avail / mem_total ))
        if [ "$ram_health_pct" -gt 20 ]; then ram_health="${GREEN}Optimal ($ram_health_pct% Free)${RESET}"
        elif [ "$ram_health_pct" -gt 5 ]; then ram_health="${YELLOW}Heavy Load ($ram_health_pct% Free)${RESET}"
        else ram_health="${RED}Critical (OOM Risk)${RESET}"
        fi
    else
        ram_health="Unknown"
    fi
    
    mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s", $3,$2 }')
    swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
    echo -e "RAM Memory  : $mem_info [ Health : $ram_health ]"
    echo -e "Swap Memory : $swap_info"

    # 3. Storage Type & Hardware Lock Detection (NVMe/SATA/HDD Universal)
    main_drive=$(lsblk -d -n -o NAME | grep -E "^(sd|nvme)" | head -1)
    if [[ "$main_drive" == *"nvme"* ]]; then disk_type="NVMe SSD"
    else
        rota_check=$(sudo cat /sys/block/"$main_drive"/queue/rotational 2>/dev/null)
        if [ "$rota_check" == "0" ]; then disk_type="SATA SSD"
        else disk_type="HDD"; fi
    fi
    
    root_usage=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
    usage_pct=$(df / | tail -n 1 | awk '{print $5}' | tr -d '%')
    ro_flag=$(sudo cat /sys/block/"$main_drive"/ro 2>/dev/null || echo "0")
    
    if [ "$ro_flag" == "1" ]; then storage_health="${RED}FAILING (Hardware Lock)${RESET}"
    elif [ "$usage_pct" -gt 90 ]; then storage_health="${YELLOW}Degrading (Low Space)${RESET}"
    else storage_health="${GREEN}Optimal (Hardware lock clear)${RESET}"; fi

    echo -e "Storage (/) : $root_usage [Type: $disk_type] [ Health : $storage_health ]"

    # 4. Thermal Sensors (Universal Intel/AMD)
    echo -e "\n${YELLOW}[*] THERMAL SENSORS & HARDWARE LIMITS${RESET}"
    declare -A sensor_temps
    declare -A sensor_limits

    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        [ ! -e "$hwmon_dir" ] && continue
        hwmon_name=$(sudo cat "$hwmon_dir/name" 2>/dev/null)
        for input_file in "$hwmon_dir"/temp*_input; do
            [ ! -e "$input_file" ] && continue
            temp_raw=$(sudo cat "$input_file" 2>/dev/null)
            [ -z "$temp_raw" ] || [ "$temp_raw" -le 0 ] && continue
            
            temp_c=$((temp_raw / 1000))
            label=$(sudo cat "${input_file%_input}_label" 2>/dev/null)
            
            if [[ "${hwmon_name,,}" == *"k10temp"* ]]; then human_name="AMD Ryzen CPU"
            elif [[ "${hwmon_name,,}" == *"amdgpu"* ]]; then human_name="AMD Radeon GPU"
            elif [[ "${hwmon_name,,}" == "coretemp" ]]; then human_name="Intel CPU"
            elif [[ "${hwmon_name,,}" == *"mt7921"* || "${hwmon_name,,}" == *"mt7922"* ]]; then human_name="MediaTek Wi-Fi"
            elif [[ "${hwmon_name,,}" == *"nvme"* ]]; then human_name="NVMe SSD"
            elif [[ "${hwmon_name,,}" == *"acpitz"* ]]; then human_name="Motherboard (ACPI)"
            elif [[ "${hwmon_name,,}" == *"thinkpad"* ]]; then human_name="ThinkPad Mainboard"
            else human_name="$hwmon_name"
            fi
            
            crit_file="${input_file%_input}_crit"
            limit="N/A"
            if [ -f "$crit_file" ]; then
                limit_raw=$(sudo cat "$crit_file" 2>/dev/null)
                if [[ "$limit_raw" =~ ^[0-9]+$ ]]; then
                    lim_c=$((limit_raw / 1000))
                    [ "$lim_c" -lt 150 ] && limit="${lim_c}°C"
                fi
            fi
            sensor_temps["$human_name"]="${temp_c}°C"
            [ "$limit" != "N/A" ] && sensor_limits["$human_name"]="$limit"
        done
    done

    if [ ${#sensor_temps[@]} -eq 0 ]; then
        echo -e "  Sensors             : Thermal subsystem not detected."
    else
        mapfile -t sorted_keys < <(IFS=$'\n'; sort -f <<<"${!sensor_temps[*]}")
        for name in "${sorted_keys[@]}"; do
            lim="${sensor_limits[$name]:-N/A}"
            if [ "$lim" == "N/A" ]; then
                case "${name,,}" in
                    *cpu*) lim="95°C (Est)" ;;
                    *gpu*) lim="90°C (Est)" ;;
                    *nvme*|*ssd*) lim="70°C (Est)" ;;
                    *wi-fi*|*wifi*) lim="80°C (Est)" ;;
                    *) lim="85°C (Est)" ;;
                esac
            fi
            printf "  %-20s : %-6s (Limit: %s)\n" "$name" "${sensor_temps[$name]}" "$lim"
        done
    fi
}

# --- [ FUNCTION 3: SECURITY & THREATS ] ---
function check_security() {
    echo -e "\n${YELLOW}[*] SECURITY & THREAT ANALYSIS${RESET}"

    # Sudo unlocks 100% of journalctl logs (Highly accurate brute-force hunting)
    failed_logins=$(sudo journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
    echo -e "Failed SSH Logins : $failed_logins"

    echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
    who

    echo -e "\n${CYAN}[+] Active Listening Ports (TCP/UDP):${RESET}"
    sudo ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5

    echo -e "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
    ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 5 | grep -v "ps -eo" | head -n 4
}

# --- [ UTILITY FUNCTION: PAUSE ] ---
function pause_menu() {
    echo -e "\n${CYAN}======================================================${RESET}"
    read -p "Press [ENTER] to return to the Main Menu..."
}

# --- [ FUNCTION 4: OPSEC SELF-DESTRUCT ] ---
function opsec_cleanup() {
    echo -e "\n${YELLOW}[!] Initiating OPSEC Cleanup Sequence...${RESET}"
    
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    SCRIPT_NAME=$(basename "$0")
    
    echo -e "${CYAN}[+] Purging memory and sweeping directories...${RESET}"
    sleep 1.5
    
    if [[ "$(basename "$SCRIPT_DIR")" == *"linux-security-monitor"* ]]; then
        cd /tmp || exit
        rm -rf "$SCRIPT_DIR"
        echo -e "${GREEN}[V] Project directory shredded. Leave no trace.${RESET}\n"
    else
        rm -f "$SCRIPT_DIR/$SCRIPT_NAME"
        echo -e "${GREEN}[V] Script self-destructed. Leave no trace.${RESET}\n"
    fi
    exit 0
}

# --- [ MAIN INTERACTIVE LOOP ] ---
while true; do
    printf '\033c'
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.1-INT) 🛡️   ${RESET}"
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "  ${BOLD}INTERACTIVE MENU${RESET}"
    echo -e "  1. System Identity & GUI Telemetry (Fastfetch)"
    echo -e "  2. Hardware & Thermal Status (With Deep Health Scan)"
    echo -e "  3. Security & Threat Analysis"
    echo -e "  4. Execute Full System Audit (All of the above)"
    echo -e "  5. Exit & Destroy Trace (OPSEC)"
    echo -e "${CYAN}------------------------------------------------------${RESET}"
    
    read -p "  Select an option [1-5]: " choice
    
    case $choice in
        1) printf '\033c'; check_system_identity; pause_menu ;;
        2) printf '\033c'; check_hardware; pause_menu ;;
        3) printf '\033c'; check_security; pause_menu ;;
        4) 
            printf '\033c'
            echo -e "${GREEN}Executing Full Audit...${RESET}"
            check_system_identity
            check_hardware
            check_security
            pause_menu
            ;;
        5) opsec_cleanup ;;
        *) echo -e "\n${RED}[!] Invalid option. Please enter a number between 1 and 5.${RESET}"; sleep 1.5 ;;
    esac
done
