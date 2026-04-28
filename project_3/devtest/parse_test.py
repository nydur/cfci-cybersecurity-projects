#!/usr/bin/env python3

# Converting bash to python test

import re
import os
from collections import Counter

log_file = 'sample_auth.log'

with open(log_file, 'r') as f:
    for line in f:
        print(line.strip())