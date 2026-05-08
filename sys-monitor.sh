#!/bin/bash

# =================================================================
# Project: Linux Security & System Monitor
# Description: Quick health and security check for Linux systems.
# Author: Nabil (Information Systems Student)
# =================================================================

# Define Colors for Professional Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}====================================================${NC}"
echo -e "${GREEN}      🛡️  LINUX SYSTEM & SECURITY CHECKER 🛡️      ${NC}"
echo -e "${YELLOW}====================================================${NC}"
echo -e "Time: $(date)"
echo -e "System: $(hostname)"
echo -e "----------------------------------------------------"

# 1. System Uptime
echo -e "\n${GREEN}[+] System Uptime:${NC}"
uptime -p

# 2. Memory Usage
echo -e "\n${GREEN}[+] Memory Usage:${NC}"
free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)\n", $3,$2,$3*100/$2 }'

# 3. Disk Usage (Critical Partitions)
echo -e "\n${GREEN}[+] Disk Usage:${NC}"
df -h --output=source,pcent,target -x tmpfs -x devtmpfs | grep '^/'

# 4. Security: Check for Open Ports
echo -e "\n${RED}[!] Active Listening Ports (Security Check):${NC}"
# Menggunakan 'ss' karena lebih modern daripada 'netstat'
ss -tunlp | grep LISTEN | awk '{print $1, $5}' | head -n 10

echo -e "\n${YELLOW}----------------------------------------------------${NC}"
echo -e "${GREEN}Analysis Complete. Use Ctrl+C to terminate if needed.${NC}"
echo -e "${YELLOW}====================================================${NC}"
