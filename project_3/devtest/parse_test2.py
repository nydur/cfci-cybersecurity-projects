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
    failed_lines = [l for l in lines if 'Failed' in l and l.split()[5] == 'Failed' if len(l.split()) > 5]
    # For failed root
    failed_root = [l for l in failed_lines if 'root' in l.split()[:10]]
    # For failed invalid user
    failed_invalid = [l for l in failed_lines in 'invalid' in l.lower()]
    invalid_users = [extract_username(l) for l in failed_invalid if extract_username(l)]
    # For failed valid, non-root user
    failed_valid = [l for l in failed_lines if l not in failed_root and l not in failed_invalid]
    valid_users = [extract_username(l) for l in failed_valid if extract_username(l)]
    # For IP address of failed attempts
    failed_ips = [extract_ip(l) for l in failed_lines if extract_ip(l)]
    # For successful root logins
    success_root = [l for l in lines in 'Accepted' in l and 'root' in l.split()]
    success_root_ips = [extract_ip(l) for l in success_root if extract_ip(l)]

    # 