#!/bin/bash

# ===========================================================================
# Project        : Linux Security & System Monitor (v2.1)
# Description    : Interactive Triage Tool with Fastfetch-style OS Telemetry
# Author         : Nabil
# Architecture   : Modular Bash (Functions & Case Loop)
# ===========================================================================

# --- [ UI & THEME VARIABLES ] ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# --- [ FUNCTION 1: FASTFETCH & SYSTEM IDENTITY ] ---
function check_system_fastfetch() {
    echo -e "\n${YELLOW}[*] SYSTEM IDENTITY & GUI TELEMETRY${RESET}"
    
    # Data Extraction
    os_name=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'=' -f2 | tr -d '\"')
    kernel_ver=$(uname -r)
    uptime_val=$(uptime -p | sed 's/up //')
    pkg_dpkg=$(dpkg-query -f '.\n' -W 2>/dev/null | wc -l || echo "0")
    pkg_snap=$(snap list 2>/dev/null | tail -n +2 | wc -l || echo "0")
    shell_val=$(basename "$SHELL")
    
    # GUI & Display Telemetry (Native Fallbacks)
    de_val=${XDG_CURRENT_DESKTOP:-"CLI / Headless"}
    wm_val=${XDG_SESSION_TYPE:-"Unknown"}
    res_val=$(cat /sys/class/drm/card*/modes 2>/dev/null | head -1 || echo "Unknown")
    
    # GNOME Theming Extraction (Via gsettings)
    if command -v gsettings &> /dev/null; then
        theme_val=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
        icons_val=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
        cursor_val=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")
        font_val=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | tr -d "'")
    else
        theme_val="N/A"; icons_val="N/A"; cursor_val="N/A"; font_val="N/A"
    fi

    # Printing the Fastfetch-style ASCII Art (Tux)
    echo -e ""
    echo -e "${CYAN}       .---.      ${CYAN}${BOLD}$USER${RESET}@${CYAN}${BOLD}$(hostname)${RESET}"
    echo -e "${CYAN}      /     \     ${RESET}---------------------------------"
    echo -e "${CYAN}      \\.@-@./     ${YELLOW}OS${RESET}: $os_name"
    echo -e "${CYAN}      /\`\\_/\\`\\     ${YELLOW}Kernel${RESET}: Linux $kernel_ver"
    echo -e "${CYAN}     //  _  \\\\    ${YELLOW}Uptime${RESET}: $uptime_val"
    echo -e "${CYAN}    | \\     )|_   ${YELLOW}Packages${RESET}: $pkg_dpkg (dpkg), $pkg_snap (snap)"
    echo -e "${CYAN}    /\`\\_\`>  <_/ \\  ${YELLOW}Shell${RESET}: $shell_val"
    echo -e "${CYAN}    \\__/'---'\\__/ ${YELLOW}Resolution${RESET}: $res_val"
    echo -e "                  ${YELLOW}DE${RESET}: $de_val (${wm_val^^})"
    echo -e "                  ${YELLOW}Theme${RESET}: $theme_val"
    echo -e "                  ${YELLOW}Icons${RESET}: $icons_val"
    echo -e "                  ${YELLOW}Cursor${RESET}: $cursor_val"
    echo -e "                  ${YELLOW}Terminal${RESET}: $TERM"
    echo -e "                  ${YELLOW}Locale${RESET}: $LANG"
    echo -e ""
    
    pub_ip=$(curl -s --max-time 3 https://ifconfig.me || echo "Offline / Unreachable")
    echo -e "${GREEN}[+] Network Edge: ${RESET}Public IP is $pub_ip"
}

# --- [ FUNCTION 2: HARDWARE & THERMAL ] ---
function check_hardware() {
    echo -e "\n${YELLOW}[*] HARDWARE & STORAGE STATUS${RESET}"

    if [ -d /sys/class/power_supply/BAT0 ]; then
        bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        bat_cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        echo -e "Battery     : ${bat_cap}% (${bat_status})"
    fi

    mem_info=$(free -h | awk 'NR==2{printf "Used: %s / Total: %s", $3,$2 }')
    swap_info=$(free -h | awk 'NR==3{printf "Used: %s / Total: %s", $3,$2 }')
    echo -e "RAM Memory  : $mem_info"
    echo -e "Swap Memory : $swap_info"

    main_drive=$(lsblk -d -n -o NAME | grep -E "^(sd|nvme)" | head -1)
    if [[ "$main_drive" == *"nvme"* ]]; then disk_type="NVMe SSD"
    else
        rota_check=$(cat /sys/block/"$main_drive"/queue/rotational 2>/dev/null)
        if [ "$rota_check" == "0" ]; then disk_type="SATA SSD"
        else disk_type="HDD"; fi
    fi
    root_usage=$(df -h / | tail -n 1 | awk '{print "Used: "$3" / Total: "$2" ("$5")"}')
    echo -e "Storage (/) : $root_usage [Type: $disk_type]"

    echo -e "\n${YELLOW}[*] THERMAL SENSORS & HARDWARE LIMITS${RESET}"
    declare -A sensor_temps
    declare -A sensor_limits

    # Scan HWMON (Universal Cross-Platform)
    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        [ ! -e "$hwmon_dir" ] && continue
        hwmon_name=$(cat "$hwmon_dir/name" 2>/dev/null)
        for input_file in "$hwmon_dir"/temp*_input; do
            [ ! -e "$input_file" ] && continue
            temp_raw=$(cat "$input_file" 2>/dev/null)
            [ -z "$temp_raw" ] || [ "$temp_raw" -le 0 ] && continue
            
            temp_c=$((temp_raw / 1000))
            label=$(cat "${input_file%_input}_label" 2>/dev/null)
            
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
                limit_raw=$(cat "$crit_file" 2>/dev/null)
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

    failed_logins=$(journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
    echo -e "Failed SSH Logins : $failed_logins"

    echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
    who

    echo -e "\n${CYAN}[+] Active Listening Ports (TCP/UDP):${RESET}"
    ss -tuln | awk 'NR>1 {print $1, $5}' | head -n 5

    echo -e "\n${CYAN}[+] Top 3 CPU Consuming Processes:${RESET}"
    ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 5 | grep -v "ps -eo" | head -n 4
}

# --- [ UTILITY FUNCTION: PAUSE ] ---
function pause_menu() {
    echo -e "\n${CYAN}======================================================${RESET}"
    read -p "Press [ENTER] to return to the Main Menu..."
}

# --- [ MAIN INTERACTIVE LOOP ] ---
while true; do
    printf '\033c'
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.1-INT) 🛡️   ${RESET}"
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "  ${BOLD}INTERACTIVE MENU${RESET}"
    echo -e "  1. System Identity & GUI Telemetry (Fastfetch)"
    echo -e "  2. Hardware & Thermal Status"
    echo -e "  3. Security & Threat Analysis"
    echo -e "  4. Execute Full System Audit (All of the above)"
    echo -e "  5. Exit"
    echo -e "${CYAN}------------------------------------------------------${RESET}"
    
    read -p "  Select an option [1-5]: " choice
    
    case $choice in
        1) 
            printf '\033c'
            check_system_fastfetch
            pause_menu
            ;;
        2) 
            printf '\033c'
            check_hardware
            pause_menu
            ;;
        3) 
            printf '\033c'
            check_security
            pause_menu
            ;;
        4) 
            printf '\033c'
            echo -e "${GREEN}Executing Full Audit...${RESET}"
            check_system_fastfetch
            check_hardware
            check_security
            pause_menu
            ;;
        5) 
            echo -e "\n${GREEN}Exiting Security Triage. Stay secure!${RESET}\n"
            exit 0
            ;;
        *) 
            echo -e "\n${RED}[!] Invalid option. Please enter a number between 1 and 5.${RESET}"
            sleep 1.5
            ;;
    esac
done
