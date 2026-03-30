#!/bin/bash

check_ip() {
    local userip=$1
    local readip='^([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'

    if [[ $userip =~ $readip ]];
    then
        return 0
    else
        return 1
    fi
}

get_valid_ip() {
    local userip=""

    while true;
    do
    read -p "Hi, what is your IP address? " userip

    if check_ip "$userip"
    then
        echo "Great! The IP address, $userip is valid!"
        sleep 1
        echo "Now, let's have a quick look..."
        return 0
    else
        echo "Uh-oh! The IP address, $userip is invalid!"
        sleep 1
        echo "Let's try again..."
    fi
done
}

echo "ip address validate"
echo "======="
valid_ip=$(get_valid_ip)

echo ""
echo "Processing..."