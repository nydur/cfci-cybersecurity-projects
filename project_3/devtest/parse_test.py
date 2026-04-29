#!/usr/bin/env python3

# Converting from the sample bash script (auth_log_analyse.sh) to python script

import re
import os
from collections import Counter

def parse_auth_log(filename='sample_auth.log'): # Parsing from a single log file
    """Parse authentication log file and extract relevant information"""
    # For 'failed' results
    failed_attempt = []
    failed_root = []
    failed_invalid = []
    failed_valid = []
    # For IP
    failed_ips = []
    # For username
    invalid_usernames = []
    valid_usernames = []
    # For 'successful' results
    success_root = []
    success_root_ips = []
    
    try:
        with open(filename, 'r') as f:
            for line in f:
                # Failed attempts
                if 'Failed' in line:
                    parts = line.split()
                    if len(parts) < 6:
                        continue
                    # Check if it's a "Failed" only
                    if len(parts) > 6 and parts[5] == 'Failed': # awk '$6 == "Failed"'
                        failed_attempt.append(line)
                        # Extract username
                        username = None
                        for i, part in enumerate(parts):
                            if part == 'for' and i+1 < len(parts):
                                username = parts[i+1]
                                break
                        # Extract IP address
                        ip = parts[-3] if len(parts) >= 3 else None
                        if ip and re.match(r'^[0-9.]+$', ip):
                            failed_ips.append(ip)
                        # Categorise attempts
                        if username:
                            if username == 'root':
                                failed_root.append(line)
                            elif 'invalid' in line.lower():
                                failed_invalid.append(line)
                                invalid_usernames.append(username)
                            else:
                                failed_valid.append(line)
                                valid_usernames.append(username)
                # Successful attempts
                elif 'Accepted' in line:
                    if 'root' in line.split():
                        success_root.append(line)
                        parts = line.split()
                        if len(parts) >= 3:
                            ip = parts[-3]
                            if ip and re.match(r'^[0-9.]+$', ip):
                                success_root_ips.append(ip)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return
    # Calculate statistics

    failed_count = len(failed_attempt)
    failed_root_count = len(failed_root)
    failed_invalid_count = len(failed_invalid)
    failed_valid_count = len(failed_valid)

    print(f"The number of failed attempts: {failed_count}")
    print(f"The number of failed attempts by root: {failed_root_count}")
    print(f"The number of failed attempts by invalid users: {failed_invalid_count}")
    print(f"The number of failed attempts by valid users (non-root): {failed_valid_count}")

    # IP with most failed attempts
    if failed_ips:
        ip_counter = Counter(failed_ips)
        most_common_ip, highest_count = ip_counter.most_common(1)[0]
        print(f"IP with highest failed attempts: {most_common_ip}")
    else:
        print("IP with highest failed attempts: None")

    # Invalid username with most failed attempts
    if invalid_usernames:
        invalid_counter = Counter(invalid_usernames)
        most_common_invalid, invalid_attempts = invalid_counter.most_common(1)[0]
        print(f"Invalid username that has the most number of failed attempts: {most_common_invalid}")
        print(f"Number of attempts for that invalid username: {invalid_attempts}")
    else:
        print("Invalid username that has the most number of failed attempts: None")
        print("Number of attempts for that invalid username: 0")

    # Valid username with most failed attempts
    if valid_usernames:
        valid_counter = Counter(valid_usernames)
        most_common_valid, valid_attempts = valid_counter.most_common(1)[0]
        print(f"Valid username that has the most number of failed attempts: {most_common_valid}")
    else:
        print("Valid username that has the most number of failed attempts: None")

    # Successful attempts as root
    print(f"Number of successful attempts as root: {len(success_root)}")

    # IP with most successful root logins
    if success_root_ips:
        success_ip_counter = Counter(success_root_ips)
        most_common_success_ip, success_count = success_ip_counter.most_common(1)[0]
        print(f"IP with highest successful root attempts: {most_common_success_ip}")
    else:
        print("IP with highest successful root attempts: None")
    
if __name__ == "__main__":
    parse_auth_log('sample_auth.log')
