#!/usr/bin/env python3

# Converting from the sample bash script (auth_log_analyse.sh) to python script

import re
from collections import Counter

# Define functions
def read_log(filename='sample_auth.log'):
    with open(filename, 'r') as f:
        return f.readlines()

def extract_username_postion(line, position_from_end=5):
    """Extracts username from end (similar to awk command in sample bash script)"""
    parts = line.split()
    if len(parts) > position_from_end:
        return parts[-(position_from_end + 1)]
    return None

def extract_username_field(line, field_index):
    """Extracts username from specific field"""
    parts = line.split()
    if len(parts) > field_index:
        return parts[field_index]
    return None

def extract_ip(line):
    """Extracts IP address from auth log line"""
    parts = line.split()
    if len(parts) >= 3:
        return parts[-3]
    return None

def analyse_auth_log(filename='sample_auth.log'):
    lines = read_log(filename)

    # For failed attempts
    failed_lines = []
    for line in lines:
        if 'Failed' in line:
            parts = line.split()
            if len(parts) > 5 and parts[5] == 'Failed':
                failed_lines.append(line)
    # For failed root
    failed_root = [l for l in failed_lines if 'root' in l.split()[:10]]
    # For failed invalid user attempts
    failed_invalid = []
    for line in failed_lines:
        if 'invalid' in line.lower():
            failed_invalid.append(line)
    # Extract for invalid usernames
    invalid_usernames = []
    for line in failed_invalid:
        parts = line.split()
        if len(parts) >= 6:
            username = parts[-6]
            invalid_usernames.append(username)
    # For failed valid, non-root attempts
    failed_valid = [l for l in failed_lines if l not in failed_root and l not in failed_invalid]
    # Extract for valid usernames
    valid_usernames = []
    for line in failed_valid:
        parts = line.split()
        if len(parts) >= 6:
            username = parts[-6]
            valid_usernames.append(username)
    # Extract for IP address of failed attempts
    failed_ips = []
    for line in failed_lines:
        parts = line.split()
        if len(parts) >= 3:
            ip = parts[-3]
            if re.match(r'^[0-9.]+$', ip):
                failed_ips.append(ip)
    # For successful root logins
    success_root = []
    for line in lines:
        if 'Accepted' in line and 'root' in line.split():
            success_root.append(line)
    # Extract for IP address of successful root logins
    success_root_ips = []
    for line in success_root:
        parts = line.split()
        if len(parts) >= 3:
            ip = parts[-3]
            if re.match(r'^[0-9.]+$', ip):
                success_root_ips.append(ip)

    # Print results
    print(f"The number of failed attempts: {len(failed_lines)}")
    print(f"The number of failed attempts by root: {len(failed_root)}")
    print(f"The number of failed attempts by invalid users: {len(failed_invalid)}")
    print(f"The number of failed attempts by valid users (non-root): {len(failed_valid)}")

    if failed_ips:
        ip_counter = Counter(failed_ips)
        most_common_ip, highest_count = ip_counter.most_common(1)[0]
        print(f"IP with the highest failed attempts: {most_common_ip}")
    else:
        print("IP with the highest failed attempts: None")

    if invalid_usernames:
        invalid_counter = Counter(invalid_usernames)
        most_common_invalid, invalid_attempts = invalid_counter.most_common(1)[0]
        print(f"Invalid username that has the most number of failed attempts: {most_common_invalid}")
        print(f"The number of attempts for that invalid username: {invalid_attempts}")
    else:
        print("Invalid username that has the most number of failed attempts: None")
        print("The number of attempts for that invalid username: 0")

    if valid_usernames:
        valid_counter = Counter(valid_usernames)
        most_common_valid, valid_attempts = valid_counter.most_common(1)[0]
        print(f"Valid username that has the most number of failed attempts: {most_common_valid}")
    else:
        print("Valid username that has the most number of failed attempts: None")

    print(f"The number of successful attempts as root: {len(success_root)}")

    if success_root_ips:
        success_ip_counter = Counter(success_root_ips)
        most_common_success_ip, success_count = success_ip_counter.most_common(1)[0]
        print(f"IP with the highest successful attempts as root: {most_common_success_ip}")
    else:
        print("IP with the highest successful attempts as root: None")

if __name__ == "__main__":
    analyse_auth_log('sample_auth.log')
