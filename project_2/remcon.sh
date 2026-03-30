#!/bin/bash

# Define separators for readability
SEPARATOR="--------------------------------------------------"
DIVIDER="=================================================="

echo "AUTOMATED IP SCANNER & STUFF"
echo "$DIVIDER"

#STEP 1: User inputs an IP range to begin process

function ipcheck() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r a b c d <<< "$1"
    for octet in $a $b $c $d; do
        (( octet < 0 || octet > 255 )) && return 1
    done
    return 0
}

read -p "Hi, what is the IP address? " userip
echo ""

while ! ipcheck "$userip"; do
    echo "Uh-oh! The IP address, $userip is invalid!"
    echo ""
    sleep 1
    read -p "Let's try again...what is the IP address? " userip
    echo ""
done

echo "Great! The IP address, $userip is valid!"
echo ""
sleep 1
echo "Now, let's have a quick look..."
echo ""

#2 ssh service scan


#3 credential brute force


#4 run series  of commands on successful login


#5 generate report of post-scan and brute force login
# user keys only once at the start (IP)
# installs any package/tools on the kali machine needed (if unavailable) for the whole process automatically (this should be after the user keys in IP)
# no interactive shell for the brute force login