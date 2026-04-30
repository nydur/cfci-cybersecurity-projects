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

