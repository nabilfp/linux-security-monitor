#!/bin/bash

# ===========================================================================
# Project        : Linux Security & System Monitor (v2.2)
# Description    : OPSEC Triage Tool with Network Baselining
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
echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.2-INT) 🛡️   ${RESET}"
echo -e "${CYAN}======================================================${RESET}"
echo -e "${YELLOW}[*] Requesting Root (sudo) access for deep hardware telemetry...${RESET}"
sudo -v || { echo -e "${RED}[!] Access Denied. Sudo is required for accurate scanning.${RESET}"; exit 1; }

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

    # 1. Advanced Battery Health
    bat_dir=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
    if [ -n "$bat_dir" ]; then
        bat_status=$(cat "$bat_dir/status" 2>/dev/null)
        bat_cap=$(cat "$bat_dir/capacity" 2>/dev/null)
        
        ac_online=$(grep -h "1" /sys/class/power_supply/*/online 2>/dev/null | head -1)
        if [[ "$bat_status" == "Not charging" ]] && [[ -n "$ac_online" ]]; then
            bat_status="Plugged In (Threshold/Idle)"
        fi
        
        design=$(sudo cat "$bat_dir/energy_full_design" 2>/dev/null || sudo cat "$bat_dir/charge_full_design" 2>/dev/null)
        current=$(sudo cat "$bat_dir/energy_full" 2>/dev/null || sudo cat "$bat_dir/charge_full" 2>/dev/null)
        
        if [[ -n "$design" && -n "$current" && "$design" -gt 0 ]]; then
            health_pct=$(( 100 * current / design ))
            [ "$health_pct" -gt 100 ] && health_pct=100
            
            if [ "$health_pct" -ge 50 ]; then 
                hlth_str="[ Health : ${GREEN}${health_pct}%${RESET} ]"
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

    # 2. RAM Memory Health
    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    
    if [[ -n "$mem_total" && -n "$mem_avail" ]]; then
        ram_health_pct=$(( 100 * mem_avail / mem_total ))
        if [ "$ram_health_pct" -ge 50 ]; then 
            ram_str="[ Health : ${GREEN}${ram_health_pct}%${RESET} ]"
        else 
            ram_str="[ Bad : ${RED}${ram_health_pct}%${RESET} ]"
        fi
    else
        ram_str="[ Health : N/A ]"
    fi
    
    mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s", $3,$2 }')
    swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
    echo -e "RAM Memory  : $mem_info $ram_str"
    echo -e "Swap Memory : $swap_info"

    # 3. Storage Type & Hardware Lock Detection
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
    
    if [ "$ro_flag" == "1" ]; then 
        storage_str="[ Bad : ${RED}0%${RESET} ]"
    elif [ "$usage_pct" -gt 90 ]; then 
        free_space=$(( 100 - usage_pct ))
        storage_str="[ Bad : ${RED}${free_space}%${RESET} ]"
    else 
        storage_str="[ Health : ${GREEN}100%${RESET} ]"
    fi

    echo -e "Storage (/) : $root_usage [Type: $disk_type] $storage_str"

    # 4. Deep Thermal Sensors (Sudo Enabled)
    echo -e "\n${YELLOW}[*] THERMAL SENSORS & HARDWARE LIMITS${RESET}"
    
    sys_vendor=$(sudo cat /sys/class/dmi/id/sys_vendor 2>/dev/null | awk '{print $1}')
    [ -z "$sys_vendor" ] && sys_vendor="System"
    
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
            elif [[ "${hwmon_name,,}" == *"mt7921"* || "${hwmon_name,,}" == *"mt7922"* || "${hwmon_name,,}" == *"iwlwifi"* ]]; then human_name="Wi-Fi Module"
            elif [[ "${hwmon_name,,}" == *"nvme"* ]]; then human_name="NVMe SSD"
            elif [[ "${hwmon_name,,}" == *"acpitz"* || "${hwmon_name,,}" == *"thinkpad"* || "${hwmon_name,,}" == *"asus"* || "${hwmon_name,,}" == *"dell"* ]]; then 
                human_name="${sys_vendor} Mainboard"
            else human_name="$hwmon_name"
            fi
            
            limit="N/A"
            for ext in emergency crit max; do
                lim_file="${input_file%_input}_${ext}"
                if [ -f "$lim_file" ]; then
                    limit_raw=$(sudo cat "$lim_file" 2>/dev/null)
                    if [[ "$limit_raw" =~ ^[0-9]+$ ]] && [ "$limit_raw" -gt 0 ]; then
                        lim_c=$((limit_raw / 1000))
                        if [ "$lim_c" -lt 130 ] && [ "$lim_c" -gt 30 ]; then
                            limit="${lim_c}°C"
                            [ "$ext" == "max" ] && limit="${lim_c}°C (Max)"
                            break
                        fi
                    fi
                fi
            done
            
            if [ "$limit" == "N/A" ]; then
                for zone in /sys/class/thermal/thermal_zone*; do
                    z_type=$(sudo cat "$zone/type" 2>/dev/null)
                    if [[ "${z_type,,}" == *"${hwmon_name,,}"* ]] || [[ "${hwmon_name,,}" == *"${z_type,,}"* ]]; then
                        for trip_type in "$zone"/trip_point_*_type; do
                            t_type=$(sudo cat "$trip_type" 2>/dev/null)
                            if [[ "$t_type" == "critical" ]]; then
                                trip_temp_file="${trip_type%_type}_temp"
                                limit_raw=$(sudo cat "$trip_temp_file" 2>/dev/null)
                                if [[ "$limit_raw" =~ ^[0-9]+$ ]] && [ "$limit_raw" -gt 0 ]; then
                                    lim_c=$((limit_raw / 1000))
                                    if [ "$lim_c" -lt 130 ] && [ "$lim_c" -gt 30 ]; then
                                        limit="${lim_c}°C (Zone)"
                                        break 2
                                    fi
                                fi
                            fi
                        done
                    fi
                done
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

# --- [ FUNCTION 3: SECURITY & THREATS (V2.2 BASELINING) ] ---
function check_security() {
    echo -e "\n${YELLOW}[*] SECURITY, THREAT & NETWORK BASELINE${RESET}"

    failed_logins=$(sudo journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
    echo -e "Failed SSH Logins : $failed_logins"

    echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
    who

    # --- NETWORK BASELINING LOGIC ---
    echo -e "\n${CYAN}[+] Network Port Baselining (TCP/UDP):${RESET}"
    BASELINE_FILE="/tmp/.v2_net_baseline.txt"
    
    # Capture current state
    sudo ss -tuln | awk 'NR>1 {print $1, $5}' | sort -u > /tmp/.v2_current_ports.txt
    
    if [ ! -f "$BASELINE_FILE" ]; then
        # First Run: Establish Baseline
        cp /tmp/.v2_current_ports.txt "$BASELINE_FILE"
        echo -e "${GREEN}[V] Initial network baseline established! (${BOLD}$(wc -l < "$BASELINE_FILE")${RESET}${GREEN} ports saved)${RESET}"
        echo -e "    Subsequent checks will flag newly opened ports as suspicious."
        echo -e "\n  Current Open Ports:"
        while read p; do echo -e "    $p"; done < "$BASELINE_FILE"
    else
        # Subsequent Runs: Compare & Hunt
        echo -e "${YELLOW}[*] Comparing current perimeter against saved baseline...${RESET}"
        
        # Mathematical set comparison
        new_ports=$(comm -13 "$BASELINE_FILE" /tmp/.v2_current_ports.txt)
        closed_ports=$(comm -23 "$BASELINE_FILE" /tmp/.v2_current_ports.txt)
        
        if [ -z "$new_ports" ]; then
            echo -e "${GREEN}[V] No anomalous new ports detected. Network matches baseline.${RESET}"
        else
            echo -e "${RED}${BOLD}[!] ALERT: NEW UNRECOGNIZED PORTS DETECTED! Potential Backdoor!${RESET}"
        fi
        
        echo -e "\n  Current Open Ports State:"
        while read port; do
            if echo "$new_ports" | grep -F -q -x "$port"; then
                # Sudo-powered PID/Process Hunter for the rogue port
                pid_info=$(sudo ss -tulnp | grep -F "$port" | awk '{print $7}' | cut -d'"' -f2 | head -n 1)
                [ -z "$pid_info" ] && pid_info="Unknown/Hidden Process"
                echo -e "    ${RED}${BOLD}$port  <-- [NEW / SUSPICIOUS] (App: $pid_info)${RESET}"
            else
                echo -e "    ${GREEN}$port  (Baseline)${RESET}"
            fi
        done < /tmp/.v2_current_ports.txt
        
        if [ -n "$closed_ports" ]; then
            echo -e "\n  ${CYAN}[i] Note: Some baseline ports have closed:${RESET}"
            while read port; do echo -e "    ${YELLOW}$port  (Closed)${RESET}"; done <<< "$closed_ports"
        fi
        
        echo -e "\n  ${CYAN}Tip: To permanently reset this baseline, use the OPSEC Exit (Option 5).${RESET}"
    fi

    echo -e "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
    ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 5 | grep -v "ps -eo" | head -n 4
    
    # Cleanup temp state
    rm -f /tmp/.v2_current_ports.txt
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
    
    echo -e "${CYAN}[+] Purging memory, baselines, and sweeping directories...${RESET}"
    sleep 1.5
    
    # Nuke the baseline file regardless of where we are
    rm -f /tmp/.v2_net_baseline.txt
    
    if [[ "$(basename "$SCRIPT_DIR")" == *"linux-security-monitor"* ]]; then
        cd /tmp || exit
        rm -rf "$SCRIPT_DIR"
        echo -e "${GREEN}[V] Baseline purged. Project directory shredded. Leave no trace.${RESET}\n"
    else
        rm -f "$SCRIPT_DIR/$SCRIPT_NAME"
        echo -e "${GREEN}[V] Baseline purged. Script self-destructed. Leave no trace.${RESET}\n"
    fi
    exit 0
}

# --- [ MAIN INTERACTIVE LOOP ] ---
while true; do
    printf '\033c'
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.2-INT) 🛡️   ${RESET}"
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "  ${BOLD}INTERACTIVE MENU${RESET}"
    echo -e "  1. System Identity & GUI Telemetry (Fastfetch)"
    echo -e "  2. Hardware & Thermal Status (With Deep Health Scan)"
    echo -e "  3. Security & Threat Analysis (Network Baselining)"
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
