#!/bin/bash

# Global Variables
OUTPUT_DIR=""
NETWORK=""
TARGET_IP=""
SCAN_MODE=""
PASSWORD_LIST="/usr/share/john/password.lst"
LOG_FILE=""

# Stage Logger // Prints a formatted banner to clearly mark each major stage of the script execution
log_stage() {
    echo ""
    echo "========================================"
    echo "  [*] $1"
    echo "========================================"
    echo ""
}

# Get User Input // Collects initial configuration from user: target network, output directory, scan mode, and target IP
get_user_input() {
    log_stage "Stage 1: Getting User Input"

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

# Run Nmap Scan // Performs network reconnaissance using nmap: discovers hosts, open ports, and service versions
run_scan() {
    log_stage "Stage 2: Running Nmap Scan ($SCAN_MODE)"

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
        # -sS: SYN scan (half-open scan, fast and stealthy, requires root/sudo)
        # -sU: UDP scan (discovers UDP services like DNS, NTP, SNMP)
        # -F: Fast mode (scan only 100 most common ports instead of 65535)
        # -T4: Timing template 4 (aggressive, speeds up scan significantly)
        # --min-rate 1000: Minimum packet rate of 1000 packets/second (very fast)
        # --max-retries 1: Only retry failed probes once (skip if no response, saves time)
        sudo nmap -sS -sU -F -T4 --min-rate 1000 --max-retries 1 "$NETWORK" -oN "$SCAN_OUTPUT.txt"
        echo "[+] Basic scan complete."

    elif [[ "$SCAN_MODE" == "Full" ]]; then
        echo "[*] Running Full scan on $NETWORK..."
        echo "[*] (Estimated time: 15-25 minutes for subnet, 2-5 minutes for single IP)"
        # Full nmap scan - Comprehensive reconnaissance with vulnerability detection
        # -sS: SYN scan (stealthy TCP port scanning)
        # -sU: UDP scan (discovers UDP services)
        # $PORTS: Variable containing port range (limited for subnet, all for single IP)
        # -sV: Service version detection (fingerprints what services are running and their versions)
        # --version-intensity 4: Moderate service detection (balances speed vs accuracy)
        # --script vuln: Run Nmap Scripting Engine (NSE) vulnerability detection scripts
        # --script-timeout 10s: Kill any script that takes longer than 10 seconds (prevents hangs)
        # -T4: Aggressive timing (speeds up scan)
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

# Attack Path Menu // Main interactive menu that lets user choose and execute different attack modules
attack_menu() {
    log_stage "Stage 3: Attack Path Selection"

    local CHOICE
    while true; do
        echo "[?] What would you like to do next?"
        echo "    1) Check for weak credentials (Hydra)"
        echo "    2) Generate Metasploit RC file"
        echo "    3) Generate a payload"
        echo "    4) Get data exfiltration commands"
        echo "    5) Exit and show summary"
        read -p "[?] Enter choice: " CHOICE

        case "$CHOICE" in
            1) weak_credentials ;;
            2) metasploit_rc ;;
            3) payload_gen ;;
            4) data_exfil ;;
            5) session_summary; exit 0 ;;
            *) echo "[!] Invalid choice. Try again." ;;
        esac
    done
}

# Weak Credentials // Uses Hydra to brute force login credentials on a target service (SSH, FTP, RDP, SMB)
weak_credentials() {
    log_stage "Stage 3a: Weak Credential Check"

}

# Metasploit RC Generator // Generates Metasploit resource files (.rc) for automated exploitation
metasploit_rc() {
    log_stage "Stage 3b: Metasploit RC File Generator"

}

# Payload Generation // Creates executable payloads using msfvenom that establish reverse shells back to attacker
payload_gen() {
    log_stage "Stage 3c: Payload Generation"

}

# Data Exfiltration // Generates commands to locate sensitive files, compress, encode, and transfer to attacker
data_exfil() {
    log_stage "Stage 3d: Data Exfiltration"

}

# Session Summary // Displays session summary and allows user to search through results before exiting
session_summary() {
    log_stage "Session Summary"

    echo "[*] Session Details:"
    echo "    Network scanned: $NETWORK"
    echo "    Target IP:       $TARGET_IP"
    echo "    Scan mode:       $SCAN_MODE"
    echo "    Output folder:   $OUTPUT_DIR"
    echo ""

    echo "[*] Files created:"
    ls -lh "$OUTPUT_DIR"
    echo ""

    # Let user search results
    while true; do
        echo "[?] What do you want to do?"
        echo "    1) Search in log file"
        echo "    2) Exit"
        read -p "[?] Enter choice: " CHOICE

        case "$CHOICE" in
            1)
                read -p "[?] Search for: " SEARCH_TERM
                grep -i "$SEARCH_TERM" "$LOG_FILE"
                if [[ $? -ne 0 ]]; then
                    echo "[-] No results found."
                fi
                ;;
            2)
                echo "[+] Goodbye!"
                return
                ;;
            *)
                echo "[!] Invalid choice."
                ;;
        esac
    done
}

# Main Entry Point
main() {
    clear
    echo "========================================"
    echo "   Project Breach Point - Pen Testing"
    echo "========================================"
    get_user_input
    run_scan
    attack_menu
}

main
