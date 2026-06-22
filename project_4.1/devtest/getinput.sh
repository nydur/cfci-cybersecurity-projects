#!/bin/bash

# Global Variables
OUTPUT_DIR=""
NETWORK=""
SCAN_MODE=""
LOG_FILE=""

# Get User Input
get_user_input() {

    # Ask for network to scan
    read -p "[?] Enter the network to scan (e.g. 192.168.1.0/24): " NETWORK
    if [[ -z "$NETWORK" ]]; then
        echo "[!] No network provided. Exiting."
        exit 1
    fi

    # Ask for output directory name
    read -p "[?] Enter a name for the output directory: " OUTPUT_DIR
    if [[ -z "$OUTPUT_DIR" ]]; then
        echo "[!] No directory name provided. Exiting."
        exit 1
    fi
    
    # Create directory if it doesn't exist
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p "$OUTPUT_DIR"
        echo "[+] Directory '$OUTPUT_DIR' created."
    else
        echo "[*] Directory '$OUTPUT_DIR' already exists."
    fi

    # Ask for scan mode
    echo "[?] Select scan mode:"
    echo "    1) Basic (TCP, UDP, Service Version)"
    echo "    2) Full (Includes vulnerability analysis)"
    read -p "[?] Enter choice (1 or 2): " SCAN_CHOICE
    
    if [[ "$SCAN_CHOICE" == "1" ]]; then
        SCAN_MODE="Basic"
    elif [[ "$SCAN_CHOICE" == "2" ]]; then
        SCAN_MODE="Full"
    else
        echo "[!] Invalid choice. Using Basic mode."
        SCAN_MODE="Basic"
    fi
    echo "[+] Scan mode: $SCAN_MODE"

    # Ask for target IP
    read -p "[?] Enter target IP address: " TARGET_IP
    if [[ -z "$TARGET_IP" ]]; then
        echo "[!] No target IP provided. Exiting."
        exit 1
    fi

    # Create log file with timestamp
    LOG_FILE="$OUTPUT_DIR/session_$(date +"%Y%m%d_%H%M%S").log"
    echo "[+] Log file: $LOG_FILE"
}
