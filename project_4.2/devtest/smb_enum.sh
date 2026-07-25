#!/bin/bash

# Global Variables
TARGET_IP=""
LOG_FILE=""
OUTPUT_DIR=""
ENUM_OUTPUT_FILE=""

smb_enum() {
    {
        echo ""
        echo "========================================"
        echo "  [*] STAGE 3E: SMB Share Enumeration"
        echo "========================================"
        echo ""
    } | tee -a "$LOG_FILE"

    local ENUM_TOOL        # Stores which tool the user selected (1=smbclient, 2=enum4linux)
    local CREDENTIALS_CHOICE  # Whether to use anonymous or credential-based access
    local USERNAME         # Username for authenticated enumeration
    local PASSWORD         # Password for authenticated enumeration
    local DOMAIN           # Windows domain or workgroup name

    echo "[*] SMB Share Enumeration Tool"
    echo ""

    # Step 1: Get Target IP
    read -p "[?] Enter target IP (Windows Client/Domain Controller): " TARGET_IP

    # Exit function if no IP is provided
    if [[ -z "$TARGET_IP" ]]; then
        echo "[!] No target IP provided. Returning to menu."
        return
    fi

    if ! [[ "$TARGET_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "[!] Invalid IP format. Returning to menu."
        return
    fi

    echo "[*] Target IP: $TARGET_IP"
    echo ""

    # Step 2: Select Enumeration Tool
    echo "[?] Select enumeration method:"
    echo "    1) smbclient  - Interactive SMB client (supports credentials)"
    echo "    2) enum4linux - Automated full enumeration (no credentials needed)"
    read -p "[?] Enter choice (1 or 2): " ENUM_TOOL

    # Prepare a timestamped output file for enumeration results
    ENUM_OUTPUT_FILE="$OUTPUT_DIR/smb_enum_${TARGET_IP}_$(date +"%Y%m%d_%H%M%S").txt"

    # Enumeration Tool
    case "$ENUM_TOOL" in
        1)
            echo ""
            echo "[?] Credentials method:"
            echo "    1) Anonymous (no credentials - null session)"
            echo "    2) Provide username and password"
            read -p "[?] Enter choice (1 or 2): " CREDENTIALS_CHOICE

            case "$CREDENTIALS_CHOICE" in
                1)
                    echo "[*] Attempting anonymous SMB enumeration..."
                    echo "[*] Enumerating SMB shares on $TARGET_IP (Anonymous)" | tee -a "$LOG_FILE"

                    smbclient -L //$TARGET_IP -N 2>&1 | tee -a "$ENUM_OUTPUT_FILE"

                    echo "" | tee -a "$LOG_FILE"
                    echo "[+] Enumeration complete. Results saved to: $ENUM_OUTPUT_FILE" | tee -a "$LOG_FILE"
                    ;;

                2)
                    read -p "[?] Enter username: " USERNAME

                    read -sp "[?] Enter password: " PASSWORD
                    echo ""

                    read -p "[?] Enter domain (or press Enter for WORKGROUP): " DOMAIN

                    if [[ -z "$DOMAIN" ]]; then
                        DOMAIN="WORKGROUP"
                    fi

                    echo "[*] Attempting SMB enumeration with credentials..."
                    echo "[*] Enumerating SMB shares on $TARGET_IP (User: $USERNAME)" | tee -a "$LOG_FILE"

                    smbclient -L //$TARGET_IP -U "$DOMAIN/$USERNAME%$PASSWORD" 2>&1 | tee -a "$ENUM_OUTPUT_FILE"

                    echo "" | tee -a "$LOG_FILE"
                    echo "[+] Enumeration complete. Results saved to: $ENUM_OUTPUT_FILE" | tee -a "$LOG_FILE"
                    ;;

                *)
                    echo "[!] Invalid choice. Returning to menu."
                    return
                    ;;
            esac
            ;;

        2)
            echo "[*] Checking if enum4linux is installed..."

            if ! command -v enum4linux &> /dev/null; then
                echo "[!] enum4linux not found. Install with: apt-get install enum4linux"
                echo "[*] Falling back to smbclient anonymous enumeration..."

                echo "[*] Enumerating SMB shares on $TARGET_IP (smbclient fallback)" | tee -a "$LOG_FILE"
                smbclient -L //$TARGET_IP -N 2>&1 | tee -a "$ENUM_OUTPUT_FILE"
            else
                echo "[*] Running enum4linux against $TARGET_IP..."
                echo "[*] Running enum4linux on $TARGET_IP" | tee -a "$LOG_FILE"

                enum4linux -a "$TARGET_IP" 2>&1 | tee -a "$ENUM_OUTPUT_FILE"

                echo "" | tee -a "$LOG_FILE"
            fi

            echo "[+] Enumeration complete. Results saved to: $ENUM_OUTPUT_FILE" | tee -a "$LOG_FILE"
            ;;

        *)
            echo "[!] Invalid choice. Returning to menu."
            return
            ;;
    esac

    # Step 3: Append Summary to Log
    {
        echo "=== SMB Enumeration Details ==="
        echo "Target IP:   $TARGET_IP"
        echo "Tool Used:   $([[ $ENUM_TOOL -eq 1 ]] && echo 'smbclient' || echo 'enum4linux')"
        echo "Timestamp:   $(date +"%Y-%m-%d %H:%M:%S")"
        echo "Output File: $ENUM_OUTPUT_FILE"
        echo ""
    } >> "$LOG_FILE"

    echo "" | tee -a "$LOG_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    OUTPUT_DIR="${OUTPUT_DIR:-.}"               # Default current directory
    LOG_FILE="${LOG_FILE:-/tmp/smb_enum_test.log}"  # Default temp log file

    echo "[*] Stage 3E SMB Enumeratione"
    echo "[*] Log file: $LOG_FILE"
    echo "[*] Output directory: $OUTPUT_DIR"
    echo ""

    smb_enumeration
fi
