#!/bin/bash

# Network Attack Testing Script for MiniSOC Suricata
# =================================================
# This script tests various network attack detection rules

echo "🌐 Network Attack Testing Script for MiniSOC Suricata"
echo "===================================================="
echo ""

# Configuration
TARGET_HOST="localhost"
TARGET_PORT="8081"  # DVWA port
SSH_PORT="22"
HTTP_PORT="80"
HTTPS_PORT="443"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Function to test attack
test_attack() {
    local attack_name="$1"
    local attack_command="$2"
    local description="$3"
    
    log "${YELLOW}Testing: ${attack_name}${NC}"
    log "Description: ${description}"
    log "Command: ${attack_command}"
    
    # Execute the attack command
    eval "${attack_command}" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log "${GREEN}✓ Attack sent successfully${NC}"
    else
        log "${RED}✗ Failed to send attack${NC}"
    fi
    
    echo ""
    sleep 2
}

# Test 1: Port Scanning Attacks
echo "🔍 Testing Port Scanning Attacks"
echo "--------------------------------"

test_attack "Port Scan - TCP SYN" \
    "nmap -sS -p 22,80,443,8080,8081,8082 ${TARGET_HOST}" \
    "TCP SYN port scan"

test_attack "Port Scan - TCP Connect" \
    "nmap -sT -p 22,80,443,8080,8081,8082 ${TARGET_HOST}" \
    "TCP Connect port scan"

test_attack "Port Scan - UDP" \
    "nmap -sU -p 53,123,161 ${TARGET_HOST}" \
    "UDP port scan"

test_attack "Port Scan - Stealth" \
    "nmap -sS -T2 -p 22,80,443 ${TARGET_HOST}" \
    "Stealth port scan"

test_attack "Port Scan - Aggressive" \
    "nmap -sS -T4 -p- ${TARGET_HOST}" \
    "Aggressive full port scan"

# Test 2: DoS (Denial of Service) Attacks
echo "🔍 Testing DoS Attacks"
echo "----------------------"

test_attack "DoS - SYN Flood" \
    "hping3 -S -p 80 --flood ${TARGET_HOST}" \
    "SYN flood attack"

test_attack "DoS - UDP Flood" \
    "hping3 -2 -p 53 --flood ${TARGET_HOST}" \
    "UDP flood attack"

test_attack "DoS - ICMP Flood" \
    "hping3 -1 --flood ${TARGET_HOST}" \
    "ICMP flood attack"

test_attack "DoS - HTTP Flood" \
    "ab -n 1000 -c 10 http://${TARGET_HOST}:${TARGET_PORT}/" \
    "HTTP flood attack"

# Test 3: Brute Force Attacks
echo "🔍 Testing Brute Force Attacks"
echo "------------------------------"

test_attack "SSH Brute Force" \
    "hydra -l admin -P /usr/share/wordlists/rockyou.txt ${TARGET_HOST} ssh" \
    "SSH brute force attack"

test_attack "HTTP Brute Force" \
    "hydra -l admin -P /usr/share/wordlists/rockyou.txt ${TARGET_HOST} http-get /admin/" \
    "HTTP admin panel brute force"

test_attack "FTP Brute Force" \
    "hydra -l admin -P /usr/share/wordlists/rockyou.txt ${TARGET_HOST} ftp" \
    "FTP brute force attack"

# Test 4: Network Service Attacks
echo "🔍 Testing Network Service Attacks"
echo "----------------------------------"

test_attack "SSH Access Attempt" \
    "ssh -o ConnectTimeout=5 admin@${TARGET_HOST}" \
    "SSH access attempt"

test_attack "Telnet Access Attempt" \
    "telnet ${TARGET_HOST} 23" \
    "Telnet access attempt"

test_attack "FTP Access Attempt" \
    "ftp ${TARGET_HOST}" \
    "FTP access attempt"

test_attack "RDP Access Attempt" \
    "nc -w 5 ${TARGET_HOST} 3389" \
    "RDP access attempt"

test_attack "SMB Access Attempt" \
    "smbclient -L //${TARGET_HOST}" \
    "SMB access attempt"

# Test 5: DNS Attacks
echo "🔍 Testing DNS Attacks"
echo "----------------------"

test_attack "DNS Amplification" \
    "dig @${TARGET_HOST} ANY google.com" \
    "DNS amplification attack"

test_attack "DNS Zone Transfer" \
    "dig @${TARGET_HOST} AXFR" \
    "DNS zone transfer attempt"

test_attack "DNS Cache Poisoning" \
    "dig @${TARGET_HOST} A malicious.com" \
    "DNS cache poisoning attempt"

# Test 6: IoT/Embedded Device Attacks
echo "🔍 Testing IoT/Embedded Device Attacks"
echo "--------------------------------------"

test_attack "IoT HTTP Flood" \
    "for i in {1..100}; do curl -s http://${TARGET_HOST}:${TARGET_PORT}/ > /dev/null; done" \
    "IoT HTTP flood attack"

test_attack "IoT Device Discovery" \
    "nmap -sS -p 80,443,8080,8443 --script http-title ${TARGET_HOST}" \
    "IoT device discovery"

# Test 7: Data Exfiltration
echo "🔍 Testing Data Exfiltration"
echo "-----------------------------"

test_attack "Large Data Transfer" \
    "dd if=/dev/zero bs=1M count=100 | nc ${TARGET_HOST} 8080" \
    "Large data transfer simulation"

test_attack "Database Dump" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/vulnerabilities/sqli/?id=1' UNION SELECT 1,2,3--" \
    "Database dump attempt"

# Test 8: Cryptocurrency Mining
echo "🔍 Testing Cryptocurrency Mining"
echo "--------------------------------"

test_attack "Crypto Mining Pool" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/pool?stratum+tcp://pool.example.com:3333'" \
    "Crypto mining pool connection"

test_attack "Crypto Mining Script" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/miner.js'" \
    "Crypto mining script download"

# Test 9: Malware Command & Control
echo "🔍 Testing Malware Command & Control"
echo "------------------------------------"

test_attack "C2 Communication" \
    "curl -X POST -d 'data=malware_payload' http://${TARGET_HOST}:${TARGET_PORT}/upload/" \
    "C2 communication simulation"

test_attack "Suspicious Download" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/download.php?file=malware.exe'" \
    "Suspicious file download"

# Test 10: Advanced Persistent Threat (APT)
echo "🔍 Testing Advanced Persistent Threat (APT)"
echo "--------------------------------------------"

test_attack "PowerShell Execution" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/exec?cmd=powershell'" \
    "PowerShell execution attempt"

test_attack "WMI Execution" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/exec?cmd=wmic'" \
    "WMI execution attempt"

test_attack "Registry Modification" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/exec?cmd=reg%20add'" \
    "Registry modification attempt"

# Test 11: Zero-Day Exploit Attempts
echo "🔍 Testing Zero-Day Exploit Attempts"
echo "------------------------------------"

test_attack "Buffer Overflow" \
    "python3 -c \"import socket; s=socket.socket(); s.connect(('${TARGET_HOST}', ${TARGET_PORT})); s.send(b'A'*1000); s.close()\"" \
    "Buffer overflow attempt"

test_attack "Format String Attack" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/vulnerabilities/exec/?ip=%x%x%x%x'" \
    "Format string attack"

# Test 12: Social Engineering Network Attacks
echo "🔍 Testing Social Engineering Network Attacks"
echo "---------------------------------------------"

test_attack "Fake Bank Login" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/login-bank.php'" \
    "Fake bank login page access"

test_attack "Fake PayPal Login" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/login-paypal.php'" \
    "Fake PayPal login page access"

test_attack "Fake Amazon Login" \
    "curl -s 'http://${TARGET_HOST}:${TARGET_PORT}/login-amazon.php'" \
    "Fake Amazon login page access"

echo "🎯 Network Attack Testing Complete!"
echo "==================================="
echo ""
echo "📊 Summary:"
echo "- Port Scanning tests: 5"
echo "- DoS tests: 4"
echo "- Brute Force tests: 3"
echo "- Network Service tests: 5"
echo "- DNS tests: 3"
echo "- IoT/Embedded Device tests: 2"
echo "- Data Exfiltration tests: 2"
echo "- Cryptocurrency Mining tests: 2"
echo "- Malware C2 tests: 2"
echo "- APT tests: 3"
echo "- Zero-Day Exploit tests: 2"
echo "- Social Engineering tests: 3"
echo ""
echo "Total tests executed: 36"
echo ""
echo "🔍 Check Suricata logs for alerts:"
echo "sudo docker compose logs suricata-host | grep -i alert"
echo ""
echo "⚠️  Note: Some attacks may require specific tools (nmap, hping3, hydra)"
echo "   Install them if needed: sudo apt install nmap hping3 hydra"
echo ""
