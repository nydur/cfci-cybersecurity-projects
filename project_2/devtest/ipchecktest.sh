#!/bin/bash

# Function to validate an IPv4 address
valid_ipv4() {
    local ip=$1
    local stat=1
    # Set Internal Field Separator to '.'
    local IFS=.
    # Create an array 'a' from the IP string using the custom IFS
    local -a a=($ip)
    # Restore original IFS
    local IFS=$OIFS

    # Check the format using a regex and ensure exactly 4 parts
    if [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] && [ ${#a[@]} -eq 4 ]; then
        # Check if each octet is within the 0-255 range
        for quad in {0..3}; do
            # Use 10# to force base 10 interpretation and avoid issues with leading zeros
            if [[ 10#${a[$quad]} -gt 255 ]]; then
                return 1
            fi
        done
        stat=0
    fi
    return $stat
}

# Read input from the user
read -p "Enter an IP address to validate: " user_input

# Call the function and check the return status
if valid_ipv4 "$user_input"; then
    echo "Success: $user_input is a valid IPv4 address."
else
    echo "Fail: $user_input is not a valid IPv4 address." >&2
fi
