#!/usr/bin/env python3

# Preliminary step: Import modules
import re # To work with regular expressions (regex) i.e. match patterns on log lines
import os # To use os functionality i.e. check if file path exists
import urllib.request # To make HTTP requests to ip-api.com
import json # To parse JSON response
from datetime import datetime # To store info a date/time objects i.e. timestamp for the report file

# Supplementary step: Geolocate IP address
ip_cache = {} 
def geolocate(ip):
    if ip in ip_cache: 
        return ip_cache[ip]
    try: 
        url = "http://ip-api.com/json/" + ip 
        response = urllib.request.urlopen(url, timeout=5)
        data = json.loads(response.read().decode())
        if data["status"] == "success": # Check if we got a successful response
            city = data.get("city", "Unknown")
            country = data.get("country", "Unknown")
            result = city + ", " + country
        else:
            result = "Location unknown"
    except Exception:
        result = "Lookup failed"
    
    ip_cache[ip] = result 
    
    return result

# Step 1: Parse log file(s)
def parse_log(filepath):
    events = []
    try:
        file = open(filepath, 'r')
        for line in file:
            if line == "" or line == "\n": 
                continue
            timestamp = ""
            parts = line.split()
            if len(parts) >= 3:
                timestamp = parts[0] + " " + parts[1] + " " + parts[2]
            else:
                timestamp = "Unknown"
            if "new user:" in line:
                match = re.search(r"name=(\w+)", line)
                if match:
                    username = match.group(1)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "NEW_USER",
                        "user": username,
                        "detail": "",
                        "raw": line
                    })
            if "delete user" in line:
                match = re.search(r"delete user '(\w+)'", line)
                if match:
                    username = match.group(1)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "DELETE_USER",
                        "user": username,
                        "detail": "",
                        "raw": line
                    })
            if "password changed" in line:
                match = re.search(r"for\s+(?:user\s+)?(\w+)", line)
                if match:
                    username = match.group(1)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "PASSWORD_CHANGE",
                        "user": username,
                        "detail": "",
                        "raw": line
                    })
            if "su[" in line and "session opened" in line:
                match = re.search(r"for user (\w+)", line)
                if match:
                    username = match.group(1)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "SU",
                        "user": username,
                        "detail": "",
                        "raw": line
                    })
            if "sudo" in line and "COMMAND=" in line:
                username = None
                is_failure = ("NOT in sudoers" in line or "incorrect password" in line)
                match = re.search(r"sudo\[\d+\]:\s+(\w+)\s+:", line)
                if match:
                    username = match.group(1)
                if username:
                    cmd_match = re.search(r"COMMAND=(.*)", line)
                    command = cmd_match.group(1).strip() if cmd_match else ""
                    if is_failure:
                        events.append({
                            "timestamp": timestamp,
                            "event_type": "SUDO_FAIL",
                            "user": username,
                            "detail": command,
                            "raw": line
                        })
                    else:
                        events.append({
                            "timestamp": timestamp,
                            "event_type": "SUDO_SUCCESS",
                            "user": username,
                            "detail": command,
                            "raw": line
                        })
            if "Failed password" in line:
                match = re.search(r"for (\w+) from ([\d.]+)", line)
                if match:
                    username = match.group(1)
                    ip = match.group(2)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "SSH_FAIL",
                        "user": username,
                        "detail": ip,
                        "raw": line
                    })
                else:
                    match = re.search(r"for invalid user (\w+) from ([\d.]+)", line)
                    if match:
                        username = match.group(1)
                        ip = match.group(2)
                        events.append({
                            "timestamp": timestamp,
                            "event_type": "SSH_FAIL",
                            "user": username,
                            "detail": ip,
                            "raw": line
                        })
            if "Accepted password" in line:
                match = re.search(r"for (\w+) from ([\d.]+)", line)
                if match:
                    username = match.group(1)
                    ip = match.group(2)
                    events.append({
                        "timestamp": timestamp,
                        "event_type": "SSH_SUCCESS",
                        "user": username,
                        "detail": ip,
                        "raw": line
                    })
        
        file.close()
        
    except FileNotFoundError:
        print(f"[ERROR] File not found: {filepath}") # No log file at filepath
    except PermissionError:
        print(f"[ERROR] Permission denied: {filepath}") # No read permission for log file
    
    return events

# Step 2: Analyse log file(s) for report prep
def analyse_events(events):
    new_users = []
    deleted_users = []
    password_changes = []
    su_usage = []
    sudo_success = []
    sudo_fail = []
    ssh_fail = []
    ssh_success = []
    
    for event in events:
        if event["event_type"] == "NEW_USER":
            new_users.append(event)
        elif event["event_type"] == "DELETE_USER":
            deleted_users.append(event)
        elif event["event_type"] == "PASSWORD_CHANGE":
            password_changes.append(event)
        elif event["event_type"] == "SU":
            su_usage.append(event)
        elif event["event_type"] == "SUDO_SUCCESS":
            sudo_success.append(event)
        elif event["event_type"] == "SUDO_FAIL":
            sudo_fail.append(event)
        elif event["event_type"] == "SSH_FAIL":
            ssh_fail.append(event)
        elif event["event_type"] == "SSH_SUCCESS":
            ssh_success.append(event)
    
    print("\n" + "=" * 50)
    print("         LOG RECON ANALYSIS")
    print("-" * 50)
    
    print(f"\n[+] New Users Added ({len(new_users)}):")
    for item in new_users:
        print(f"{item['timestamp']} - {item['user']}")
    print(f"\n[+] Deleted Users ({len(deleted_users)}):")
    for item in deleted_users:
        print(f"{item['timestamp']} - {item['user']}")
    print(f"\n[+] Password Changes ({len(password_changes)}):")
    for item in password_changes:
        print(f"{item['timestamp']} - {item['user']}")
    print(f"\n[+] SU Usage ({len(su_usage)}):")
    for item in su_usage:
        print(f"{item['timestamp']} - {item['user']}")
    print(f"\n[+] SUDO Usage ({len(sudo_success)}):")
    for item in sudo_success:
        if item["detail"] != "":
            print(f"{item['timestamp']} - {item['user']} - {item['detail']}")
        else:
            print(f"{item['timestamp']} - {item['user']}")
    print(f"\n[+] SUDO Failures ({len(sudo_fail)}):")
    for item in sudo_fail:
        if "NOT in sudoers" in item["raw"]:
            reason = "NOT in sudoers"
        else:
            reason = "incorrect password"
        print(f"ALERT! {item['timestamp']} - {item['user']} - {reason}")
        if item["detail"] != "":
            print(f"COMMAND: {item['detail']}")
    print(f"\n[+] Failed SSH Logins ({len(ssh_fail)}):")
    
    ip_count = {}
    for item in ssh_fail:
        ip = item["detail"]
        if ip in ip_count:
            ip_count[ip] = ip_count[ip] + 1
        else:
            ip_count[ip] = 1
        location = geolocate(ip) # Look up the location for this IP
        print(f"{item['timestamp']} - {item['user']} from {ip} ({location})")
    
    print(f"\n[+] Top Attacking IPs:")
    
    ip_list = []
    for ip in ip_count:
        ip_list.append(ip)
    
    for i in range(len(ip_list)):
        for j in range(i + 1, len(ip_list)):
            if ip_count[ip_list[i]] < ip_count[ip_list[j]]:
                # Swap
                temp = ip_list[i]
                ip_list[i] = ip_list[j]
                ip_list[j] = temp
    
    count = 0
    for ip in ip_list:
        if count < 5:
            location = geolocate(ip) 
            print(f"{ip:<18} {ip_count[ip]} attempts ({location})")
            count = count + 1
    
    print(f"\n[+] IP Cache: Looked up {len(ip_cache)} unique IP addresses")
    
    print(f"\n[+] Successful SSH Logins ({len(ssh_success)}):")
    for item in ssh_success:
        location = geolocate(item["detail"])  # Uses cache too!
        print(f"{item['timestamp']} - {item['user']} from {item['detail']} ({location})")
    
    print("\n" + "=" * 50)
    
    findings = {
        "NEW_USER": new_users,
        "DELETE_USER": deleted_users,
        "PASSWORD_CHANGE": password_changes,
        "SU": su_usage,
        "SUDO_SUCCESS": sudo_success,
        "SUDO_FAIL": sudo_fail,
        "SSH_FAIL": ssh_fail,
        "SSH_SUCCESS": ssh_success,
    }
    
    return findings

# Step 3: Compile and prepare report
def save_report(findings, output_file, log_files):
    file = open(output_file, 'w', encoding='utf-8')
    file.write("=" * 50 + "\n")
    file.write("               LOG RECON REPORT\n")
    file.write(f"      Generated: {datetime.now().strftime('%Y-%m-%d at %H:%M:%S')}\n")
    file.write(f"      Log(s) scanned:\n")
    for log in log_files:
        file.write(f"      - {log}\n")
    file.write("-" * 50 + "\n")
    
    file.write(f"\n[+] New Users Added ({len(findings['NEW_USER'])}):\n")
    for item in findings['NEW_USER']:
        file.write(f"{item['timestamp']} - {item['user']}\n")
    
    file.write(f"\n[+] Deleted Users ({len(findings['DELETE_USER'])}):\n")
    for item in findings['DELETE_USER']:
        file.write(f"{item['timestamp']} - {item['user']}\n")
    
    file.write(f"\n[+] Password Changes ({len(findings['PASSWORD_CHANGE'])}):\n")
    for item in findings['PASSWORD_CHANGE']:
        file.write(f"{item['timestamp']} - {item['user']}\n")
    
    file.write(f"\n[+] SU Usage ({len(findings['SU'])}):\n")
    for item in findings['SU']:
        file.write(f"{item['timestamp']} - {item['user']}\n")
    
    file.write(f"\n[+] SUDO Usage ({len(findings['SUDO_SUCCESS'])}):\n")
    for item in findings['SUDO_SUCCESS']:
        if item["detail"] != "":
            file.write(f"{item['timestamp']} - {item['user']} - {item['detail']}\n")
        else:
            file.write(f"{item['timestamp']} - {item['user']}\n")
    
    file.write(f"\n[+] SUDO Failures ({len(findings['SUDO_FAIL'])}):\n")
    for item in findings['SUDO_FAIL']:
        if "NOT in sudoers" in item["raw"]:
            reason = "NOT in sudoers"
        else:
            reason = "incorrect password"
        file.write(f"ALERT! {item['timestamp']} - {item['user']} - {reason}\n")
        if item["detail"] != "":
            file.write(f"COMMAND: {item['detail']}\n")
    
    file.write(f"\n[+] Failed SSH Logins ({len(findings['SSH_FAIL'])}):\n")
    for item in findings['SSH_FAIL']:
        location = geolocate(item["detail"])
        file.write(f"{item['timestamp']} - {item['user']} from {item['detail']} ({location})\n")
    
    file.write(f"\n[+] Successful SSH Logins ({len(findings['SSH_SUCCESS'])}):\n")
    for item in findings['SSH_SUCCESS']:
        location = geolocate(item["detail"])
        file.write(f"{item['timestamp']} - {item['user']} from {item['detail']} ({location})\n")
    
    file.write("\n" + "-" * 50 + "\n")
    file.write(f"IP Geolocation Cache: {len(ip_cache)} unique IPs looked up\n")
    
    file.write("-" * 50 + "\n")
    file.write("               END OF REPORT\n")
    file.write("=" * 50 + "\n")
    
    file.close()
    
    print(f"\n[✓] Report saved to {output_file}")
    print(f"[✓] Cached {len(ip_cache)} IP addresses for faster lookups")

# Main step: For overall process to run
if __name__ == "__main__":
    
    print("=" * 50)
    print("             LOG RECON TOOL")
    print("-" * 50)
    print("Enter log file paths one at a time.")
    print("Press ENTER without any input when done.\n")
    
    log_files = []
    
    while True:
        path = input("Log file path: ").strip()
        if path == "":
            break
        if os.path.exists(path): 
            log_files.append(path)
        else:
            print(f"    [!] File not found: {path}")
    
    if len(log_files) == 0:
        print("[ERROR] No valid log files found. Exiting.")
        exit()
    
    all_events = []
    for filepath in log_files:
        print(f"\n[*] Parsing: {filepath}")
        events = parse_log(filepath)
        print(f"    {len(events)} events found.")
        for event in events:
            all_events.append(event)
    
    findings = analyse_events(all_events)
    
    now = datetime.now()
    timestamp = now.strftime("%y%m%d_%H%M%S")
    output_file = timestamp + "_log-recon_report.md"
    
    save_report(findings, output_file, log_files)
    