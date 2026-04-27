#!/bin/bash

#The number of Failed attempts
FAILED=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | wc -l)
echo "The number of failed attempts: $FAILED"

#The number of Failed attempts as root only
FAILED_ROOT=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep -w 'root' | wc -l)
echo "The number of failed attempts by root: $FAILED_ROOT"

#The number of Failed attempts as invalid users only
FAILED_INVALID=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep -w 'invalid' | wc -l)
echo "The number of failed attempts by invalid users: $FAILED_INVALID"

#The number of Failed attempts as valid users only (non-root)
FAILED_VALID=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep -v 'root' | grep -v 'invalid' | wc -l)
echo "The number of failed attempts by valid users (non-root): $FAILED_VALID"

#The IP Address that has the most number of Failed attempts
FAILED_IP=$(cat sample_auth.log | grep 'Failed' | awk '{print $(NF-3)}' | grep ^[0-9] | sort | uniq -c | sort -n | tail -n 1 | awk '{print $2}')
echo "IP with highest failed attempts: $FAILED_IP"

#Find the invalid username that has the most number of Failed attempts
FAILED_USER=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep 'invalid' | awk '{print $(NF-5)}' | sort | uniq -c | sort -n | tail -n 1 | awk '{print $2}')
echo "Invalid username that has the most number of failed attempts: $FAILED_USER"

#Times did the invalid user login
FAILED_ATTEMPTS=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep 'invalid' | awk '{print $(NF-5)}' | sort | uniq -c | sort -n | tail -n 1 | awk '{print $1}')
echo "Invalid username that has the most number of failed attempts: $FAILED_ATTEMPTS"

#Find the valid username that has the most number of Failed attempts
VALID_FAILED=$(cat sample_auth.log | grep 'Failed' | awk '$6 == "Failed"' | grep -v 'invalid' | awk '{print $(NF-5)}' | sort | uniq -c | sort -n | tail -n 1 | awk '{print $2}')
echo "Valid username that has the most number of failed attempts: $VALID_FAILED"

#Find the number of successful attempts as root
ROOT_SUCCESS=$(cat sample_auth.log | grep 'Accepted' | grep -w 'root' | wc -l)
echo "Number of successful attempts as root: $ROOT_SUCCESS"

#Find the IP Address that has the most number of successful login as root
SUCCESS_IP=$(cat sample_auth.log | grep 'Accepted' | grep -w 'root' | awk '{print $(NF-3)}' | sort | uniq -c | sort -n | tail -n 1 | awk '{print $2}')
echo "IP with highest failed attempts: $SUCCESS_IP"
