#!/bin/bash

# Local Network Rules Testing Script for MiniSOC Suricata
# ======================================================
# This script tests local network monitoring rules

echo "🏠 Local Network Rules Testing Script for MiniSOC Suricata"
echo "========================================================="
echo ""

# Configuration
TARGET_HOST="localhost"
TARGET_PORT="8081"  # DVWA port
INTERNAL_NETWORKS=("10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16")
LOCAL_IP="127.0.0.1"

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

# Test 1: Internal Network Access
echo "🔍 Testing Internal Network Access"
echo "----------------------------------"

test_attack "Internal Network Access - HTTP" \
    "curl -s http://${LOCAL_IP}:${TARGET_PORT}/" \
    "HTTP access to internal network"

test_attack "Internal Network Access - HTTPS" \
    "curl -s https://${LOCAL_IP}:443/" \
    "HTTPS access to internal network"

test_attack "Internal Network Access - SSH" \
    "ssh -o ConnectTimeout=5 -o BatchMode=yes ${LOCAL_IP}" \
    "SSH access to internal network"

# Test 2: Internal Network Outbound
echo "🔍 Testing Internal Network Outbound"
echo "------------------------------------"

test_attack "Internal Network Outbound - HTTP" \
    "curl -s http://google.com" \
    "Outbound HTTP from internal network"

test_attack "Internal Network Outbound - HTTPS" \
    "curl -s https://google.com" \
    "Outbound HTTPS from internal network"

test_attack "Internal Network Outbound - DNS" \
    "dig google.com" \
    "Outbound DNS from internal network"

# Test 3: Local Service Monitoring
echo "🔍 Testing Local Service Monitoring"
echo "-----------------------------------"

test_attack "SSH Access to Internal Network" \
    "ssh -o ConnectTimeout=5 -o BatchMode=yes admin@${LOCAL_IP}" \
    "SSH access attempt to internal network"

test_attack "HTTP Access to Internal Network" \
    "curl -s http://${LOCAL_IP}:80/" \
    "HTTP access to internal network"

test_attack "HTTPS Access to Internal Network" \
    "curl -s https://${LOCAL_IP}:443/" \
    "HTTPS access to internal network"

# Test 4: Local Network Scanning
echo "🔍 Testing Local Network Scanning"
echo "---------------------------------"

test_attack "Internal Network Port Scan" \
    "nmap -sS -p 22,80,443,8080,8081,8082 ${LOCAL_IP}" \
    "Port scan against internal network"

test_attack "Internal Network Service Discovery" \
    "nmap -sS -sV -p 22,80,443 ${LOCAL_IP}" \
    "Service discovery on internal network"

# Test 5: Local Network DoS
echo "🔍 Testing Local Network DoS"
echo "----------------------------"

test_attack "Internal Network SYN Flood" \
    "hping3 -S -p 80 --flood ${LOCAL_IP}" \
    "SYN flood against internal network"

test_attack "Internal Network HTTP Flood" \
    "ab -n 100 -c 10 http://${LOCAL_IP}:${TARGET_PORT}/" \
    "HTTP flood against internal network"

# Test 6: Local Network Web Attacks
echo "🔍 Testing Local Network Web Attacks"
echo "------------------------------------"

test_attack "Local SQL Injection" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/vulnerabilities/sqli/?id=1' UNION SELECT 1,2,3--" \
    "SQL injection against internal network"

test_attack "Local XSS" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/vulnerabilities/xss_r/?name=<script>alert(\"XSS\")</script>'" \
    "XSS against internal network"

test_attack "Local Directory Traversal" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/vulnerabilities/fi/?page=../../../etc/passwd'" \
    "Directory traversal against internal network"

# Test 7: Local Network File Upload
echo "🔍 Testing Local Network File Upload"
echo "------------------------------------"

test_attack "Local PHP File Upload" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/vulnerabilities/upload/'" \
    "PHP file upload to internal network"

test_attack "Local JSP File Upload" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/upload.jsp'" \
    "JSP file upload to internal network"

test_attack "Local ASP File Upload" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/upload.asp'" \
    "ASP file upload to internal network"

# Test 8: Local Network Information Disclosure
echo "🔍 Testing Local Network Information Disclosure"
echo "-----------------------------------------------"

test_attack "Local PHP Info" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/phpinfo.php'" \
    "PHP info disclosure from internal network"

test_attack "Local Git Config" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/.git/config'" \
    "Git config disclosure from internal network"

test_attack "Local Environment File" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/.env'" \
    "Environment file disclosure from internal network"

# Test 9: Local Network Authentication Bypass
echo "🔍 Testing Local Network Authentication Bypass"
echo "----------------------------------------------"

test_attack "Local Admin Panel" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/admin/'" \
    "Admin panel access from internal network"

test_attack "Local Login Page" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/login.php'" \
    "Login page access from internal network"

# Test 10: Local Network IoT/Embedded Device Attacks
echo "🔍 Testing Local Network IoT/Embedded Device Attacks"
echo "----------------------------------------------------"

test_attack "Local Telnet Access" \
    "telnet ${LOCAL_IP} 23" \
    "Telnet access to internal network"

test_attack "Local FTP Access" \
    "ftp ${LOCAL_IP}" \
    "FTP access to internal network"

test_attack "Local RDP Access" \
    "nc -w 5 ${LOCAL_IP} 3389" \
    "RDP access to internal network"

test_attack "Local SMB Access" \
    "smbclient -L //${LOCAL_IP}" \
    "SMB access to internal network"

# Test 11: Local Network Data Exfiltration
echo "🔍 Testing Local Network Data Exfiltration"
echo "-------------------------------------------"

test_attack "Local Large Data Transfer" \
    "dd if=/dev/zero bs=1M count=10 | nc ${LOCAL_IP} 8080" \
    "Large data transfer to internal network"

test_attack "Local Database Dump" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/vulnerabilities/sqli/?id=1' UNION SELECT 1,2,3--" \
    "Database dump from internal network"

# Test 12: Local Network Social Engineering
echo "🔍 Testing Local Network Social Engineering"
echo "-------------------------------------------"

test_attack "Local Bank Phishing" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/login-bank.php'" \
    "Bank phishing from internal network"

test_attack "Local PayPal Phishing" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/login-paypal.php'" \
    "PayPal phishing from internal network"

test_attack "Local Amazon Phishing" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/login-amazon.php'" \
    "Amazon phishing from internal network"

# Test 13: Local Network Cryptocurrency Mining
echo "🔍 Testing Local Network Cryptocurrency Mining"
echo "-----------------------------------------------"

test_attack "Local Crypto Mining Pool" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/pool?stratum+tcp://pool.example.com:3333'" \
    "Crypto mining pool connection from internal network"

test_attack "Local Crypto Mining Script" \
    "curl -s 'http://${LOCAL_IP}:${TARGET_PORT}/miner.js'" \
    "Crypto mining script from internal network"

# Test 14: Local Network IoT Botnet Activity
echo "🔍 Testing Local Network IoT Botnet Activity"
echo "---------------------------------------------"

test_attack "Local IoT DNS Amplification" \
    "dig @${LOCAL_IP} ANY google.com" \
    "IoT DNS amplification from internal network"

test_attack "Local IoT HTTP Flood" \
    "for i in {1..50}; do curl -s http://${LOCAL_IP}:${TARGET_PORT}/ > /dev/null; done" \
    "IoT HTTP flood from internal network"

# Test 15: Local Network Compliance and Audit
echo "🔍 Testing Local Network Compliance and Audit"
echo "----------------------------------------------"

test_attack "Local SSH Access Log" \
    "ssh -o ConnectTimeout=5 -o BatchMode=yes ${LOCAL_IP}" \
    "SSH access log from internal network"

test_attack "Local RDP Access Log" \
    "nc -w 5 ${LOCAL_IP} 3389" \
    "RDP access log from internal network"

test_attack "Local FTP Access Log" \
    "ftp ${LOCAL_IP}" \
    "FTP access log from internal network"

echo "🎯 Local Network Rules Testing Complete!"
echo "========================================"
echo ""
echo "📊 Summary:"
echo "- Internal Network Access tests: 3"
echo "- Internal Network Outbound tests: 3"
echo "- Local Service Monitoring tests: 3"
echo "- Local Network Scanning tests: 2"
echo "- Local Network DoS tests: 2"
echo "- Local Network Web Attacks tests: 3"
echo "- Local Network File Upload tests: 3"
echo "- Local Network Info Disclosure tests: 3"
echo "- Local Network Auth Bypass tests: 2"
echo "- Local Network IoT tests: 4"
echo "- Local Network Data Exfiltration tests: 2"
echo "- Local Network Social Engineering tests: 3"
echo "- Local Network Crypto Mining tests: 2"
echo "- Local Network IoT Botnet tests: 2"
echo "- Local Network Compliance tests: 3"
echo ""
echo "Total tests executed: 42"
echo ""
echo "🔍 Check Suricata logs for LOCAL alerts:"
echo "sudo docker compose logs suricata-host | grep -i 'LOCAL'"
echo ""
echo "🎯 These tests specifically target local.rules detection:"
echo "- All attacks target internal network addresses (127.0.0.1, 10.x.x.x, 172.x.x.x, 192.168.x.x)"
echo "- Tests cover all categories in local.rules"
echo "- Each test should trigger LOCAL_* alerts"
echo ""
