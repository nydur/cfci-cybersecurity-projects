#!/bin/bash

# Global Variables
OUTPUT_DIR=""
NETWORK=""
TARGET_IP=""
SCAN_MODE=""
LOG_FILE=""

# Session Summary
session_summary() {

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
