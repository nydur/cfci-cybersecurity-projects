#!/bin/bash

# Global Variables
OUTPUT_DIR=""
NETWORK=""
SCAN_MODE=""

# Run Nmap Scan
run_scan() {

    local SCAN_OUTPUT="$OUTPUT_DIR/nmap_scan_$(date +"%Y%m%d_%H%M%S")"
    local PORTS

    # Determine port range based on NETWORK type (CIDR vs single IP)
    if [[ "$NETWORK" =~ "/" ]]; then
        # CIDR subnet — limit ports for speed
        PORTS="-p T:1-10000,U:53,123,161,162,445,500,5353"
    else
        # Single IP — scan all ports
        PORTS="-p-"
    fi

    if [[ "$SCAN_MODE" == "Basic" ]]; then
        echo "[*] Running Basic scan on $NETWORK..."
        echo "[*] (Estimated time: 1-2 minutes for subnet, 10-15 seconds for single IP)"
        # Basic nmap scan - Fast reconnaissance of common ports and services
        sudo nmap -sS -sU -F -T4 --min-rate 1000 --max-retries 1 "$NETWORK" -oN "$SCAN_OUTPUT.txt"
        echo "[+] Basic scan complete."

    elif [[ "$SCAN_MODE" == "Full" ]]; then
        echo "[*] Running Full scan on $NETWORK..."
        echo "[*] (Estimated time: 15-25 minutes for subnet, 2-5 minutes for single IP)"
        # Full nmap scan - Comprehensive reconnaissance with vulnerability detection
        sudo nmap -sS -sU $PORTS -sV --version-intensity 4 --script vuln --script-timeout 10s -T4 "$NETWORK" -oN "$SCAN_OUTPUT.txt"
        echo "[+] Full scan complete."

        echo "[*] Running Searchsploit to find exploits..."
        # searchsploit --nmap: Parse nmap output and search for known exploits in Exploit-DB
        # Automatically matches discovered services/versions against known public exploits
        searchsploit --nmap "$SCAN_OUTPUT.txt"
        echo "[+] Searchsploit complete."
    fi

    echo "[+] Results saved to: $SCAN_OUTPUT.txt"
}
