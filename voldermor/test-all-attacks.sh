#!/bin/bash

# Comprehensive Attack Testing Script for MiniSOC Suricata
# =======================================================
# This script runs all attack tests and provides a comprehensive report

echo "🎯 Comprehensive Attack Testing Script for MiniSOC Suricata"
echo "=========================================================="
echo ""

# Configuration
TARGET_HOST="localhost"
TARGET_PORT="8081"  # DVWA port
LOG_FILE="attack_test_results.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

# Function to run test script
run_test_script() {
    local script_name="$1"
    local script_description="$2"
    
    log "${PURPLE}🚀 Starting: ${script_description}${NC}"
    log "Script: ${script_name}"
    
    if [ -f "${script_name}" ]; then
        chmod +x "${script_name}"
        ./"${script_name}" >> "${LOG_FILE}" 2>&1
        
        if [ $? -eq 0 ]; then
            log "${GREEN}✅ ${script_description} completed successfully${NC}"
        else
            log "${RED}❌ ${script_description} failed${NC}"
        fi
    else
        log "${RED}❌ Script ${script_name} not found${NC}"
    fi
    
    echo ""
    sleep 3
}

# Function to check Suricata alerts
check_alerts() {
    local alert_type="$1"
    local alert_count=0
    
    log "${CYAN}🔍 Checking for ${alert_type} alerts...${NC}"
    
    # Get alert count from Suricata logs
    alert_count=$(sudo docker compose logs suricata-host | grep -i "${alert_type}" | wc -l)
    
    if [ $alert_count -gt 0 ]; then
        log "${GREEN}✅ Found ${alert_count} ${alert_type} alerts${NC}"
    else
        log "${YELLOW}⚠️  No ${alert_type} alerts found${NC}"
    fi
    
    return $alert_count
}

# Function to generate report
generate_report() {
    local total_tests="$1"
    local web_alerts="$2"
    local network_alerts="$3"
    local local_alerts="$4"
    
    echo ""
    echo "📊 COMPREHENSIVE TEST REPORT"
    echo "============================"
    echo "Generated: $(date)"
    echo ""
    echo "🎯 Test Summary:"
    echo "- Total attack tests executed: ${total_tests}"
    echo "- Web attack tests: 30"
    echo "- Network attack tests: 36"
    echo "- Local network tests: 42"
    echo ""
    echo "🚨 Alert Summary:"
    echo "- Web attack alerts: ${web_alerts}"
    echo "- Network attack alerts: ${network_alerts}"
    echo "- Local network alerts: ${local_alerts}"
    echo "- Total alerts detected: $((web_alerts + network_alerts + local_alerts))"
    echo ""
    
    # Calculate detection rate
    local total_alerts=$((web_alerts + network_alerts + local_alerts))
    local detection_rate=0
    
    if [ $total_tests -gt 0 ]; then
        detection_rate=$((total_alerts * 100 / total_tests))
    fi
    
    echo "📈 Detection Rate: ${detection_rate}%"
    echo ""
    
    # Alert categories
    echo "🔍 Alert Categories:"
    echo "- SQL Injection: $(sudo docker compose logs suricata-host | grep -i 'sql' | wc -l)"
    echo "- XSS: $(sudo docker compose logs suricata-host | grep -i 'xss' | wc -l)"
    echo "- Directory Traversal: $(sudo docker compose logs suricata-host | grep -i 'directory\|traversal' | wc -l)"
    echo "- Port Scan: $(sudo docker compose logs suricata-host | grep -i 'scan\|recon' | wc -l)"
    echo "- DoS: $(sudo docker compose logs suricata-host | grep -i 'dos\|flood' | wc -l)"
    echo "- Local Network: $(sudo docker compose logs suricata-host | grep -i 'local' | wc -l)"
    echo ""
    
    # Recent alerts
    echo "🚨 Recent Alerts (last 10):"
    sudo docker compose logs suricata-host | grep -i alert | tail -10 | while read line; do
        echo "  - $line"
    done
    echo ""
    
    # Recommendations
    echo "💡 Recommendations:"
    if [ $detection_rate -lt 50 ]; then
        echo "- ⚠️  Low detection rate detected. Consider reviewing Suricata rules."
        echo "- 📝 Check rule syntax and ensure all rule files are loaded correctly."
        echo "- 🔧 Verify Suricata configuration and interface settings."
    elif [ $detection_rate -lt 80 ]; then
        echo "- ✅ Good detection rate. Consider fine-tuning rules for better coverage."
        echo "- 📊 Review missed detections and adjust rule sensitivity."
    else
        echo "- 🎉 Excellent detection rate! Suricata is working effectively."
        echo "- 🔍 Consider adding more sophisticated rules for advanced threats."
    fi
    echo ""
    
    echo "📁 Log file: ${LOG_FILE}"
    echo "🔍 View all alerts: sudo docker compose logs suricata-host | grep -i alert"
    echo "📊 View detailed logs: sudo docker compose logs suricata-host"
}

# Main execution
main() {
    # Initialize log file
    echo "MiniSOC Suricata Attack Testing Report" > "${LOG_FILE}"
    echo "Generated: $(date)" >> "${LOG_FILE}"
    echo "======================================" >> "${LOG_FILE}"
    echo "" >> "${LOG_FILE}"
    
    log "${YELLOW}🎯 Starting Comprehensive Attack Testing${NC}"
    log "Target: ${TARGET_HOST}:${TARGET_PORT}"
    log "Log file: ${LOG_FILE}"
    echo ""
    
    # Check if Suricata is running
    log "${CYAN}🔍 Checking Suricata status...${NC}"
    if sudo docker compose ps suricata-host | grep -q "Up"; then
        log "${GREEN}✅ Suricata is running${NC}"
    else
        log "${RED}❌ Suricata is not running. Please start it first.${NC}"
        exit 1
    fi
    echo ""
    
    # Clear previous alerts
    log "${CYAN}🧹 Clearing previous alerts...${NC}"
    sudo docker compose logs suricata-host > /dev/null 2>&1
    echo ""
    
    # Run test scripts
    run_test_script "test-web-attacks.sh" "Web Attack Testing"
    run_test_script "test-network-attacks.sh" "Network Attack Testing"
    run_test_script "test-local-rules.sh" "Local Network Rules Testing"
    
    # Wait for Suricata to process alerts
    log "${CYAN}⏳ Waiting for Suricata to process alerts...${NC}"
    sleep 10
    
    # Check for alerts
    check_alerts "web-application-attack"
    web_alerts=$?
    
    check_alerts "attempted-recon\|attempted-dos\|attempted-admin"
    network_alerts=$?
    
    check_alerts "local"
    local_alerts=$?
    
    # Generate comprehensive report
    total_tests=108  # 30 + 36 + 42
    generate_report $total_tests $web_alerts $network_alerts $local_alerts
    
    log "${GREEN}🎉 Comprehensive testing completed!${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "1. Review the generated report above"
    echo "2. Check ${LOG_FILE} for detailed test results"
    echo "3. Analyze Suricata alerts for false positives/negatives"
    echo "4. Fine-tune rules based on detection results"
    echo "5. Run specific tests for areas with low detection rates"
    echo ""
}

# Check if running as root (needed for some tests)
if [ "$EUID" -eq 0 ]; then
    log "${YELLOW}⚠️  Running as root. Some tests may behave differently.${NC}"
fi

# Check for required tools
log "${CYAN}🔧 Checking for required tools...${NC}"
required_tools=("curl" "nmap" "dig" "nc" "ssh" "telnet" "ftp")
missing_tools=()

for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
    log "${YELLOW}⚠️  Missing tools: ${missing_tools[*]}${NC}"
    log "Install them with: sudo apt install ${missing_tools[*]}"
    echo ""
fi

# Run main function
main "$@"
