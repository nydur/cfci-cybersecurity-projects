#!/usr/bin/env python3

# Converting from the sample bash script (auth_log_analyse.sh) to python script

import re
import os
from collections import Counter

def parse_auth_log(filename='sample_auth.log'): # Parsing from a single log file
    """Parse authentication log file and extract relevant information"""
    # For 'failed' results
    failed_attempts=[]
    failed_root=[]
    failed_invalid=[]
    failed_valid=[]
    # For IP
    failed_ips=[]
    # For username
    invalid_usernames=[]
    valid_usernames=[]
    # For 'successful' results
    success_root=[]
    success_root_ips=[]
    