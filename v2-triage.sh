#!/bin/bash

# ===========================================================================
# Project        : Linux Security & System Monitor (v2.2-Global)
# Description    : OPSEC Triage Tool with Network Baselining & i18n Support
# Author         : Nabil
# Architecture   : Modular Bash (Dictionary Matrix, Functions & Case Loop)
# ===========================================================================

# --- [ UI COLOR VARIABLES ] ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# --- [ LANGUAGE DICTIONARY (i18n) ] ---
function set_lang_en() {
    UI_MENU_TITLE="INTERACTIVE MENU"
    UI_OPT1="System Identity & GUI Telemetry"
    UI_OPT2="Hardware & Thermal Status (Deep Scan)"
    UI_OPT3="Security & Threat Analysis (Network Baseline)"
    UI_OPT4="Execute Full System Audit"
    UI_OPT5="Exit & Destroy Trace (OPSEC)"
    UI_PROMPT="Select an option [1-5]: "
    UI_INVALID="[!] Invalid option. Please enter a number between 1 and 5."
    UI_PAUSE="Press [ENTER] to return to the Main Menu..."
    UI_SUDO_REQ="[*] Requesting Root (sudo) access for deep hardware telemetry..."
    UI_SUDO_FAIL="[!] Access Denied. Sudo is required for accurate scanning."
    UI_HDR_SYS="[*] SYSTEM IDENTITY & GUI TELEMETRY"
    UI_HDR_HW="[*] HARDWARE, HEALTH & STORAGE STATUS"
    UI_HDR_THERM="[*] THERMAL SENSORS & HARDWARE LIMITS"
    UI_HDR_SEC="[*] SECURITY, THREAT & NETWORK BASELINE"
    UI_NET_EDGE="Network Edge"
    UI_HLT="Health"
    UI_BAD="Bad"
    UI_BASE_EST="[V] Initial network baseline established!"
    UI_BASE_SUB="Subsequent checks will flag newly opened ports as suspicious."
    UI_BASE_COMP="[*] Comparing current perimeter against saved baseline..."
    UI_BASE_OK="[V] No anomalous new ports detected. Network matches baseline."
    UI_BASE_ALERT="[!] ALERT: NEW UNRECOGNIZED PORTS DETECTED! Potential Backdoor!"
    UI_NEW_SUSP="[NEW / SUSPICIOUS]"
    UI_OPSEC_INIT="[!] Initiating OPSEC Cleanup Sequence..."
    UI_OPSEC_DO="[+] Purging memory, baselines, and sweeping directories..."
    UI_OPSEC_DONE="[V] Baseline purged. Trace destroyed. Leave no trace."
}

function set_lang_id() {
    UI_MENU_TITLE="MENU INTERAKTIF"
    UI_OPT1="Identitas Sistem & Telemetri GUI"
    UI_OPT2="Status Perangkat Keras & Suhu (Pindai Mendalam)"
    UI_OPT3="Analisis Keamanan & Ancaman (Network Baseline)"
    UI_OPT4="Jalankan Audit Sistem Penuh"
    UI_OPT5="Keluar & Hapus Jejak (Protokol OPSEC)"
    UI_PROMPT="Pilih opsi [1-5]: "
    UI_INVALID="[!] Pilihan tidak valid. Masukkan angka 1 sampai 5."
    UI_PAUSE="Tekan [ENTER] untuk kembali ke Menu Utama..."
    UI_SUDO_REQ="[*] Meminta akses Root (sudo) untuk akurasi telemetri perangkat keras..."
    UI_SUDO_FAIL="[!] Akses Ditolak. Sudo diwajibkan untuk pemindaian akurat."
    UI_HDR_SYS="[*] IDENTITAS SISTEM & TELEMETRI GUI"
    UI_HDR_HW="[*] STATUS PERANGKAT KERAS, KESEHATAN & PENYIMPANAN"
    UI_HDR_THERM="[*] SENSOR SUHU & BATAS PERANGKAT KERAS"
    UI_HDR_SEC="[*] KEAMANAN, ANCAMAN & NETWORK BASELINE"
    UI_NET_EDGE="Ujung Jaringan"
    UI_HLT="Sehat"
    UI_BAD="Buruk"
    UI_BASE_EST="[V] Baseline jaringan awal berhasil dibuat!"
    UI_BASE_SUB="Pengecekan berikutnya akan menandai port baru sebagai mencurigakan."
    UI_BASE_COMP="[*] Membandingkan perimeter saat ini dengan baseline tersimpan..."
    UI_BASE_OK="[V] Tidak ada port anomali. Jaringan aman sesuai baseline."
    UI_BASE_ALERT="[!] AWAS: PORT BARU TAK DIKENAL TERDETEKSI! Potensi Backdoor!"
    UI_NEW_SUSP="[BARU / MENCURIGAKAN]"
    UI_OPSEC_INIT="[!] Memulai Sekuens Pembersihan OPSEC..."
    UI_OPSEC_DO="[+] Menghapus memori, baseline, dan membersihkan direktori..."
    UI_OPSEC_DONE="[V] Baseline dihapus. Jejak dihancurkan. Tanpa jejak."
}

function set_lang_zh() {
    UI_MENU_TITLE="交互式菜单 (INTERACTIVE MENU)"
    UI_OPT1="系统身份与 GUI 遥测"
    UI_OPT2="硬件与温度状态 (高精度扫描)"
    UI_OPT3="安全与威胁分析 (网络基线)"
    UI_OPT4="执行完整系统审计"
    UI_OPT5="退出并销毁痕迹 (OPSEC 协议)"
    UI_PROMPT="请选择一个选项 [1-5]: "
    UI_INVALID="[!] 无效选项。请输入 1 到 5 之间的数字。"
    UI_PAUSE="按 [ENTER] 键返回主菜单..."
    UI_SUDO_REQ="[*] 请求 Root (sudo) 权限以进行深度硬件遥测..."
    UI_SUDO_FAIL="[!] 访问被拒绝。高精度扫描需要 Sudo 权限。"
    UI_HDR_SYS="[*] 系统身份与 GUI 遥测"
    UI_HDR_HW="[*] 硬件、健康状况与存储状态"
    UI_HDR_THERM="[*] 温度传感器与硬件限制"
    UI_HDR_SEC="[*] 安全、威胁与网络基线"
    UI_NET_EDGE="网络边缘"
    UI_HLT="健康"
    UI_BAD="危险"
    UI_BASE_EST="[V] 初始网络基线已建立！"
    UI_BASE_SUB="随后的检查会将新打开的端口标记为可疑。"
    UI_BASE_COMP="[*] 正在将当前边界与保存的基线进行比较..."
    UI_BASE_OK="[V] 未检测到异常的新端口。网络与基线匹配。"
    UI_BASE_ALERT="[!] 警告：检测到无法识别的新端口！潜在的后门！"
    UI_NEW_SUSP="[新 / 可疑]"
    UI_OPSEC_INIT="[!] 正在启动 OPSEC 清理程序..."
    UI_OPSEC_DO="[+] 正在清除内存、基线并扫描目录..."
    UI_OPSEC_DONE="[V] 基线已清除。痕迹已销毁。不留痕迹。"
}

# --- [ LANGUAGE SELECTION BOOTLOADER ] ---
printf '\033c'
echo -e "${CYAN}======================================================${RESET}"
echo -e "${GREEN} 🌍 SELECT YOUR LANGUAGE / PILIH BAHASA / 选择语言 🌍 ${RESET}"
echo -e "${CYAN}======================================================${RESET}"
echo -e "  1. English (Default)"
echo -e "  2. Bahasa Indonesia"
echo -e "  3. Mandarin (中文)"
echo -e "${CYAN}------------------------------------------------------${RESET}"
read -p "  [1-3]: " lang_choice

case $lang_choice in
    2) set_lang_id ;;
    3) set_lang_zh ;;
    *) set_lang_en ;;
esac

# --- [ GOD MODE: SUDO CHECK (Translated) ] ---
printf '\033c'
echo -e "${CYAN}======================================================${RESET}"
echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.2-INT) 🛡️   ${RESET}"
echo -e "${CYAN}======================================================${RESET}"
echo -e "${YELLOW}${UI_SUDO_REQ}${RESET}"
sudo -v || { echo -e "${RED}${UI_SUDO_FAIL}${RESET}"; exit 1; }

# --- [ FUNCTION 1: SYSTEM IDENTITY & FASTFETCH ] ---
function check_system_identity() {
    echo -e "\n${YELLOW}${UI_HDR_SYS}${RESET}"
    
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
    echo -e "\n${GREEN}[+] ${UI_NET_EDGE}: ${RESET}$pub_ip"
}

# --- [ FUNCTION 2: HARDWARE & THERMAL ] ---
function check_hardware() {
    echo -e "\n${YELLOW}${UI_HDR_HW}${RESET}"

    # 1. Advanced Battery Health
    bat_dir=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
    if [ -n "$bat_dir" ]; then
        bat_status=$(cat "$bat_dir/status" 2>/dev/null)
        bat_cap=$(cat "$bat_dir/capacity" 2>/dev/null)
        
        ac_online=$(grep -h "1" /sys/class/power_supply/*/online 2>/dev/null | head -1)
        if [[ "$bat_status" == "Not charging" ]] && [[ -n "$ac_online" ]]; then
            bat_status="Plugged In (Idle)"
        fi
        
        design=$(sudo cat "$bat_dir/energy_full_design" 2>/dev/null || sudo cat "$bat_dir/charge_full_design" 2>/dev/null)
        current=$(sudo cat "$bat_dir/energy_full" 2>/dev/null || sudo cat "$bat_dir/charge_full" 2>/dev/null)
        
        if [[ -n "$design" && -n "$current" && "$design" -gt 0 ]]; then
            health_pct=$(( 100 * current / design ))
            [ "$health_pct" -gt 100 ] && health_pct=100
            if [ "$health_pct" -ge 50 ]; then hlth_str="[ ${UI_HLT} : ${GREEN}${health_pct}%${RESET} ]"
            else hlth_str="[ ${UI_BAD} : ${RED}${health_pct}%${RESET} ]"; fi
        else
            hlth_str="[ ${UI_HLT} : N/A ]"
        fi
        echo -e "Battery     : ${bat_cap}% (${bat_status}) ${hlth_str}"
    else
        echo -e "Battery     : Not present"
    fi

    # 2. RAM Memory Health
    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    
    if [[ -n "$mem_total" && -n "$mem_avail" ]]; then
        ram_health_pct=$(( 100 * mem_avail / mem_total ))
        if [ "$ram_health_pct" -ge 50 ]; then ram_str="[ ${UI_HLT} : ${GREEN}${ram_health_pct}%${RESET} ]"
        else ram_str="[ ${UI_BAD} : ${RED}${ram_health_pct}%${RESET} ]"; fi
    else
        ram_str="[ ${UI_HLT} : N/A ]"
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
    
    if [ "$ro_flag" == "1" ]; then storage_str="[ ${UI_BAD} : ${RED}0%${RESET} ]"
    elif [ "$usage_pct" -gt 90 ]; then free_space=$(( 100 - usage_pct )); storage_str="[ ${UI_BAD} : ${RED}${free_space}%${RESET} ]"
    else storage_str="[ ${UI_HLT} : ${GREEN}100%${RESET} ]"; fi

    echo -e "Storage (/) : $root_usage [Type: $disk_type] $storage_str"

    # 4. Deep Thermal Sensors
    echo -e "\n${YELLOW}${UI_HDR_THERM}${RESET}"
    
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

    if [ ${#sensor_temps[@]} -gt 0 ]; then
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
    echo -e "\n${YELLOW}${UI_HDR_SEC}${RESET}"

    failed_logins=$(sudo journalctl _SYSTEMD_UNIT=ssh.service 2>/dev/null | grep "Failed password" | wc -l || echo "N/A")
    echo -e "Failed SSH Logins : $failed_logins"

    echo -e "\n${CYAN}[+] Active User Sessions:${RESET}"
    who

    # --- NETWORK BASELINING LOGIC ---
    echo -e "\n${CYAN}[+] TCP/UDP Ports:${RESET}"
    BASELINE_FILE="/tmp/.v2_net_baseline.txt"
    
    sudo ss -tuln | awk 'NR>1 {print $1, $5}' | sort -u > /tmp/.v2_current_ports.txt
    
    if [ ! -f "$BASELINE_FILE" ]; then
        cp /tmp/.v2_current_ports.txt "$BASELINE_FILE"
        echo -e "${GREEN}${UI_BASE_EST}${RESET}"
        echo -e "    ${UI_BASE_SUB}"
        echo -e "\n  Ports:"
        while read p; do echo -e "    $p"; done < "$BASELINE_FILE"
    else
        echo -e "${YELLOW}${UI_BASE_COMP}${RESET}"
        
        new_ports=$(comm -13 "$BASELINE_FILE" /tmp/.v2_current_ports.txt)
        closed_ports=$(comm -23 "$BASELINE_FILE" /tmp/.v2_current_ports.txt)
        
        if [ -z "$new_ports" ]; then
            echo -e "${GREEN}${UI_BASE_OK}${RESET}"
        else
            echo -e "${RED}${BOLD}${UI_BASE_ALERT}${RESET}"
        fi
        
        echo -e "\n  Current State:"
        while read port; do
            if echo "$new_ports" | grep -F -q -x "$port"; then
                pid_info=$(sudo ss -tulnp | grep -F "$port" | awk '{print $7}' | cut -d'"' -f2 | head -n 1)
                [ -z "$pid_info" ] && pid_info="Unknown Process"
                echo -e "    ${RED}${BOLD}$port  <-- ${UI_NEW_SUSP} (App: $pid_info)${RESET}"
            else
                echo -e "    ${GREEN}$port  (Baseline)${RESET}"
            fi
        done < /tmp/.v2_current_ports.txt
    fi

    echo -e "\n${CYAN}[+] Top 3 CPU Processes:${RESET}"
    ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 5 | grep -v "ps -eo" | head -n 4
    
    rm -f /tmp/.v2_current_ports.txt
}

# --- [ UTILITY FUNCTION: PAUSE ] ---
function pause_menu() {
    echo -e "\n${CYAN}======================================================${RESET}"
    read -p "${UI_PAUSE}"
}

# --- [ FUNCTION 4: OPSEC SELF-DESTRUCT ] ---
function opsec_cleanup() {
    echo -e "\n${YELLOW}${UI_OPSEC_INIT}${RESET}"
    
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    SCRIPT_NAME=$(basename "$0")
    
    echo -e "${CYAN}${UI_OPSEC_DO}${RESET}"
    sleep 1.5
    
    rm -f /tmp/.v2_net_baseline.txt
    
    if [[ "$(basename "$SCRIPT_DIR")" == *"linux-security-monitor"* ]]; then
        cd /tmp || exit
        rm -rf "$SCRIPT_DIR"
        echo -e "${GREEN}${UI_OPSEC_DONE}${RESET}\n"
    else
        rm -f "$SCRIPT_DIR/$SCRIPT_NAME"
        echo -e "${GREEN}${UI_OPSEC_DONE}${RESET}\n"
    fi
    exit 0
}

# --- [ MAIN INTERACTIVE LOOP ] ---
while true; do
    printf '\033c'
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "${GREEN}   🛡️  LINUX SECURITY & HEALTH TRIAGE (v2.2-INT) 🛡️   ${RESET}"
    echo -e "${CYAN}======================================================${RESET}"
    echo -e "  ${BOLD}${UI_MENU_TITLE}${RESET}"
    echo -e "  1. ${UI_OPT1}"
    echo -e "  2. ${UI_OPT2}"
    echo -e "  3. ${UI_OPT3}"
    echo -e "  4. ${UI_OPT4}"
    echo -e "  5. ${UI_OPT5}"
    echo -e "${CYAN}------------------------------------------------------${RESET}"
    
    read -p "  ${UI_PROMPT}" choice
    
    case $choice in
        1) printf '\033c'; check_system_identity; pause_menu ;;
        2) printf '\033c'; check_hardware; pause_menu ;;
        3) printf '\033c'; check_security; pause_menu ;;
        4) 
            printf '\033c'
            check_system_identity
            check_hardware
            check_security
            pause_menu
            ;;
        5) opsec_cleanup ;;
        *) echo -e "\n${RED}${UI_INVALID}${RESET}"; sleep 1.5 ;;
    esac
done
