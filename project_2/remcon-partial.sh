#!/bin/bash

# Define separators for readability
SEPARATOR="--------------------------------------------------"
DIVIDER="=================================================="

echo "AUTOMATED IP SCANNER & STUFF"
echo "$DIVIDER"

# Lists of functions that will be called in the later steps
# Function to run IP validity
function ipcheck() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r a b c d <<< "$1"
    for octet in "$a" "$b" "$c" "$d"; do
        (( octet < 0 || octet > 255 )) && return 1
    done
    return 0
}

# Function to install any required or missing dependencies/packages on the machine
function install_dep() {
    local packages=(nmap hydra)
    missing=()

    for pkg in "${packages[@]}"; do
        command -v "$pkg" &>/dev/null || missing+=("$pkg")
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "Nice! All required packages are already installed."
        return 0
    fi

    echo "Missing packages: ${missing[*]}"
    echo "Installing..."
    sudo apt-get install -y "${missing[@]}"
    echo ""
}

# Function to scan for active services
function scan_service() {
    echo "Scanning in progress on $USERIP for SSH..." >&2
    local ssh_status=$(nmap -sV "$USERIP" | grep '^22/tcp' | awk '{print $2}')
    echo "${ssh_status:-not detected}"
    echo ""
}

# Function to cleanup only newly installed dependencies/packages on the machine
function cleanup_dep() {
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Removing packages that were installed for this scan: ${missing[*]}"
        if [[ ${EUID} -eq 0 ]]; then
            apt-get purge -y "${missing[@]}"
            apt-get autoremove -y
        else
            sudo apt-get purge -y "${missing[@]}"
            sudo apt-get autoremove -y
        fi
    fi
}

#STEP 1: User inputs an IP range to begin process
read -p "Hi, what is the IP address? " userip
echo ""

#Step 1a: While statement that will refer to ipcheck Function (if IP is invalid)
while ! ipcheck "$userip"; do
    echo "Uh-oh! The IP address, $userip is invalid!"
    echo ""
    sleep 1
    read -p "Let's try again...what is the IP address? " userip
    echo ""
done

#Step 1b: If IP is valid, will proceed to Step 2
echo "Great! The IP address, $userip is valid!"
echo ""
sleep 1
echo "Now, let's have a quick look..."
echo ""

#Step 2: Scanning for SSH service
install_dep
scan_service "$userip"


#3 credential brute force with hydra without interactive shell
...

#4 run series  of commands on successful login
...

#5 generate report of post-scan and login
...

cleanup_dep
echo "$DIVIDER"
echo "END OF AUTOMATED IP SCANNER & STUFF"