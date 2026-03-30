#!/bin/bash

# ============================================
#   Phase 3: Automated System Info Extractor
# ============================================

DIVIDER="============================================"

echo "$DIVIDER"
echo "       AUTOMATED SYSTEM INFO EXTRACTOR"
echo "$DIVIDER"
echo ""

# ----------------------------
# 3.1 Public IP Address
# ----------------------------
echo ">>> 3.1 Public IP Address"
echo "----------------------------"
PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null \
  || curl -s --max-time 5 https://ifconfig.me 2>/dev/null \
  || echo "Unavailable (no internet access)")
echo "Public IP: $PUBLIC_IP"
echo ""

# ----------------------------
# 3.2 Private IP Address
# ----------------------------
echo ">>> 3.2 Private IP Address"
echo "----------------------------"
PRIVATE_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' \
  || hostname -I 2>/dev/null | awk '{print $1}' \
  || echo "Unavailable")
INTERFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}' || echo "N/A")
echo "Interface : $INTERFACE"
echo "Private IP: $PRIVATE_IP"
echo ""

# ----------------------------
# 3.3 MAC Address (masked)
# ----------------------------
echo ">>> 3.3 MAC Address (partially masked)"
echo "----------------------------"
MAC_RAW=$(ip link show 2>/dev/null | awk '/ether/{print $2; exit}' || echo "00:00:00:00:00:00")
# Mask the last 3 octets for security: show first 3, hide last 3
MAC_MASKED=$(echo "$MAC_RAW" | awk -F: '{printf "%s:%s:%s:XX:XX:XX\n", $1, $2, $3}')
echo "MAC Address: $MAC_MASKED"
echo ""

# ----------------------------
# 3.4 Top 5 CPU-consuming Processes
# ----------------------------
echo ">>> 3.4 Top 5 Processes by CPU Usage"
echo "----------------------------"
printf "%-8s %-10s %-s\n" "PID" "CPU(%)" "COMMAND"
ps aux --sort=-%cpu 2>/dev/null | awk 'NR>1 && NR<=6 {printf "%-8s %-10s %-s\n", $2, $3, $11}'
echo ""

# ----------------------------
# 3.5 Memory Usage Statistics
# ----------------------------
echo ">>> 3.5 Memory Usage Statistics"
echo "----------------------------"
if command -v free &>/dev/null; then
  TOTAL=$(free -h | awk '/^Mem:/{print $2}')
  USED=$(free -h  | awk '/^Mem:/{print $3}')
  AVAIL=$(free -h | awk '/^Mem:/{print $7}')
  echo "Total Memory    : $TOTAL"
  echo "Used Memory     : $USED"
  echo "Available Memory: $AVAIL"
else
  echo "Memory info unavailable"
fi
echo ""

# ----------------------------
# 3.6 Active System Services
# ----------------------------
echo ">>> 3.6 Active System Services"
echo "----------------------------"
if command -v systemctl &>/dev/null; then
  printf "%-45s %-10s\n" "SERVICE" "STATUS"
  systemctl list-units --type=service --state=active --no-pager --no-legend 2>/dev/null \
    | awk '{printf "%-45s %-10s\n", $1, $3}' \
    | head -20
else
  echo "systemctl not available"
fi
echo ""

# ----------------------------
# 3.7 Top 10 Largest Files in /home
# ----------------------------
echo ">>> 3.7 Top 10 Largest Files in /home"
echo "----------------------------"
if [ -d "/home" ]; then
  printf "%-12s %-s\n" "SIZE" "FILE PATH"
  find /home -type f -exec du -h {} + 2>/dev/null \
    | sort -rh \
    | head -10 \
    | awk '{printf "%-12s %-s\n", $1, $2}'
else
  echo "/home directory not found"
fi
echo ""

echo "$DIVIDER"
echo "           END OF SYSTEM REPORT"
echo "$DIVIDER"
