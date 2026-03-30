#!/bin/bash

# Define separator for readability
SEPARATOR="----------------------------------------"

echo "### System Information Report ###"
echo "$SEPARATOR"

# 1. Hostname and OS Information
echo "Host name: $(hostname)"
echo "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2 | tr -d \")"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "$SEPARATOR"

# 2. CPU Information
echo "CPU Model: $(grep \"model name\" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^ *//')"
echo "CPU Cores: $(grep -c ^processor /proc/cpuinfo)"
echo "$SEPARATOR"

# 3. Memory Information (in MB)
echo "Memory Usage:"
free -m | awk 'NR==2{printf "  Used: %sMB / Total: %sMB (%.2f%%)\n", $3, $2, $3*100/$2}'
echo "$SEPARATOR"

# 4. Disk Space Usage for the root partition
echo "Disk Usage (Root /):"
df -h | awk '$NF=="/"{printf "  Used: %s / Total: %s (Used: %s)\n", $3, $2, $5}'
echo "$SEPARATOR"

# 5. Network Information (IP Address)
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo "$SEPARATOR"

echo "### Report Complete ###"
