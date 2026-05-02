#!/usr/bin/env python3

# Converting from the sample bash script (auth_log_analyse.sh) to python script

import re
from collections import Counter

# Define functions
def read_log(filename='sample_auth.log'):
    with open(filename, 'r') as f:
        return f.readlines()

def extract_username(line):
    """Extract username from auth log line"""
    match = re.search(r'for (\S+)', line)
    return match.group(1) if match else None

def extract_ip(line):
    """Extract IP address from auth log line"""
    match = re.search(r'(\d+\.\d+\.\d+\.\d+)', line)
    return match.group(1) if match else None

def analyse_auth_log(filename='sample_auth.log'):
    lines = read_log(filename)

    # For failed attempts
    failed_lines = [l for l in lines if 'Failed' in l and len(l.split()) > 5 and l.split()[5] == 'Failed']
    # For failed root
    failed_root = [l for l in failed_lines if 'root' in l.split()[:10]]
    # For failed invalid user
    failed_invalid = [l for l in failed_lines if 'invalid' in l.lower()]
    invalid_users = [extract_username(l) for l in failed_invalid if extract_username(l)]
    # For failed valid, non-root user
    failed_valid = [l for l in failed_lines if l not in failed_root and l not in failed_invalid]
    valid_users = [extract_username(l) for l in failed_valid if extract_username(l)]
    # For IP address of failed attempts
    failed_ips = [extract_ip(l) for l in failed_lines if extract_ip(l)]
    # For successful root logins
    success_root = [l for l in lines if 'Accepted' in l and 'root' in l.split()]
    success_root_ips = [extract_ip(l) for l in success_root if extract_ip(l)]

    # Print results
    print(f"The number of failed attempts: {len(failed_lines)}")
    print(f"The number of failed attempts by root: {len(failed_root)}")
    print(f"The number of failed attempts by invalid users: {len(failed_invalid)}")
    print(f"The number of failed attempts by valid users: {len(failed_valid)}")

    if failed_ips:
        print(f"IP with the highest failed attempts: {Counter(failed_ips).most_common(1)[0][0]}")

    if invalid_users:
        invalid_counter = Counter(invalid_users)
        most_invalid, inv_count = invalid_counter.most_common(1)[0]
        print(f"Invalid username that has the most number of failed attempts: {most_invalid}")
        print(f"The number of attempts for that invalid username: {inv_count}")

    if valid_users:
        print(f"Valid username that has the most number of failed attempts: {Counter(valid_users).most_common(1)[0][0]}")

    print(f"The number of successful attempts as root: {len(success_root)}")

    if success_root_ips:
        print(f"IP with the highest successful attempts as root: {Counter(success_root_ips).most_common(1)[0][0]}")

if __name__ == "__main__":
    analyse_auth_log('sample_auth.log')
