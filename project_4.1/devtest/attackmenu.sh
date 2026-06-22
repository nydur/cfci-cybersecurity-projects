#!/bin/bash

# Attack Path Menu
attack_menu() {

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
