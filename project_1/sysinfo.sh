#!/bin/bash

# Define separators for readability
SEPARATOR="--------------------------------------------------"
DIVIDER="=================================================="

echo "SYSTEM INFORMATION"
echo "$DIVIDER"
echo ""

# Section for the system's network information; Public, Private, MAC addresses
echo "Part A: Network Information (Public, Private, MAC Addresses)"
echo ""
echo "$DIVIDER"
PUBLIC_IP=$(curl -s ifconfig.io) #Retrieves the public IP via curl
echo "Public IP Address: $PUBLIC_IP"
echo "$SEPARATOR"
PRIVATE_IP=$(ifconfig | grep broadcast | awk '{print $2}') #Retrieves the private IP, Option C via ifconfig
##hostname -I | awk '{print $1}') #Option A via hostname
##ip addr show $(ip route | awk '/default/ {print $5}') | grep inet | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1) #Option B via ip addr
echo "Private IP Address: $PRIVATE_IP"
echo "$SEPARATOR"
INTERFACE=$(ip route show default | awk '/default/ {print $5}') #Retrieves the network interface card info, eth0
MAC_ADDRESS=$(ip link show "$INTERFACE" | awk '/ether/ {print $2}') #Retrieves the MAC address of the network interface
MAC_MASKED=$(echo "$MAC_ADDRESS" | cut -c 1-9)xx:xx:xx #Partially masked the MAC address by extracting only characters 1 to 9
echo "MAC Address (Partially Masked): $MAC_MASKED"
echo "$DIVIDER"
echo ""

# Section for the system's processes information; CPU, Memory, Active System Services, Largest Files
echo "Part B: Processes Information (CPU Usage, Memory Usage, Active System Services, Largest Files in /home Directory)"
echo ""
echo "$DIVIDER"
echo "CPU Consuming Processes (Top 5)"
echo ""
printf "%-15s %-10s %-10s %-5s\n" "PROCESS ID" "USER" "CPU(%)" "COMMAND" #Replaces the top header output with desired header
ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "%-15s %-10s %-10s %-5s\n", $1, $2, $3, $4}' #Option B.2, via ps -eo
##top -b -n 1 | awk 'NR>7 && NR<=12 {printf "%-15s %-10s %-10s %-5s\n", $1, $2, $9, $12}' #Option A, via top
##ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {printf "%-15s %-10s %-10s %-5s\n", $2, $1, $3, $11}' #Option B.1 via ps aux
echo ""
echo "$SEPARATOR"
echo "Memory Usage Statistics"
echo ""
TOTAL_MEMORY=$(free -m | awk 'NR==2{print $2}') #Retrieves total memory in MB
AVAIL_MEMORY=$(free -m | awk 'NR==2{print $4}') #Retrieves available memory in MB
echo "Total Memory: $TOTAL_MEMORY MB"
echo "Available Memory: $AVAIL_MEMORY MB"
echo ""
echo "$SEPARATOR"
echo "Active System Services (Top 15)"
echo ""
printf "%-45s %-10s\n" "SERVICE" "STATUS" #Replaces the top header output with desired header
systemctl list-units --type=service --state=active | awk 'NR>1 {printf "%-45s %-10s\n", $1, $3}' | head -15 #Retrieves Top 15 active services and removes top row
echo ""
echo "$SEPARATOR"
echo "Largest Files in /home (Top 10)"
echo ""
printf "%-12s %-s\n" "SIZE" "FILE PATH" #Replaces the top header output with desired header
find /home -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10 | awk '{printf "%-12s %-s\n", $1, $2}' #Retrieves and sorts the Top 10 files in /home, determines the file path and estimates file size
echo ""
echo "$DIVIDER"
echo "END OF SYSTEM INFORMATION"