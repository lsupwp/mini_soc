#!/bin/bash

# Tools Installation Script for MiniSOC Attack Testing
# ===================================================
# This script installs all necessary tools for running attack tests

echo "🔧 Tools Installation Script for MiniSOC Attack Testing"
echo "======================================================="
echo ""

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package
install_package() {
    local package="$1"
    local description="$2"
    
    log "${YELLOW}Installing: ${description}${NC}"
    
    if command_exists "$package"; then
        log "${GREEN}✅ ${description} is already installed${NC}"
    else
        log "Installing ${package}..."
        sudo apt update
        sudo apt install -y "$package"
        
        if command_exists "$package"; then
            log "${GREEN}✅ ${description} installed successfully${NC}"
        else
            log "${RED}❌ Failed to install ${description}${NC}"
        fi
    fi
    
    echo ""
}

# Function to install Python package
install_python_package() {
    local package="$1"
    local description="$2"
    
    log "${YELLOW}Installing Python package: ${description}${NC}"
    
    if python3 -c "import $package" 2>/dev/null; then
        log "${GREEN}✅ ${description} is already installed${NC}"
    else
        log "Installing ${package}..."
        pip3 install "$package"
        
        if python3 -c "import $package" 2>/dev/null; then
            log "${GREEN}✅ ${description} installed successfully${NC}"
        else
            log "${RED}❌ Failed to install ${description}${NC}"
        fi
    fi
    
    echo ""
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log "${YELLOW}⚠️  Some installations may require sudo privileges${NC}"
    echo ""
fi

# Update package list
log "${CYAN}🔄 Updating package list...${NC}"
sudo apt update
echo ""

# Install basic networking tools
echo "🌐 Installing Basic Networking Tools"
echo "===================================="

install_package "curl" "cURL (HTTP client)"
install_package "wget" "Wget (HTTP client)"
install_package "netcat" "Netcat (network utility)"
install_package "dig" "DNS utilities"
install_package "nslookup" "DNS lookup utility"

# Install network scanning tools
echo "🔍 Installing Network Scanning Tools"
echo "===================================="

install_package "nmap" "Nmap (network scanner)"
install_package "hping3" "Hping3 (packet generator)"
install_package "masscan" "Masscan (fast port scanner)"

# Install penetration testing tools
echo "⚔️  Installing Penetration Testing Tools"
echo "========================================"

install_package "hydra" "Hydra (brute force tool)"
install_package "sqlmap" "SQLMap (SQL injection tool)"
install_package "nikto" "Nikto (web vulnerability scanner)"
install_package "dirb" "Dirb (web directory scanner)"
install_package "gobuster" "Gobuster (directory/file brute forcer)"

# Install web testing tools
echo "🌐 Installing Web Testing Tools"
echo "==============================="

install_package "apache2-utils" "Apache Bench (HTTP testing)"
install_package "siege" "Siege (HTTP load tester)"
install_package "ab" "Apache Bench (HTTP benchmarking)"

# Install additional utilities
echo "🛠️  Installing Additional Utilities"
echo "==================================="

install_package "telnet" "Telnet client"
install_package "ftp" "FTP client"
install_package "ssh" "SSH client"
install_package "smbclient" "SMB client"
install_package "python3" "Python 3"
install_package "python3-pip" "Python 3 pip"
install_package "jq" "JSON processor"
install_package "hexdump" "Hex dump utility"
install_package "xxd" "Hex dump utility"

# Install Python packages
echo "🐍 Installing Python Packages"
echo "============================="

install_python_package "requests" "Requests (HTTP library)"
install_python_package "beautifulsoup4" "BeautifulSoup (HTML parser)"
install_python_package "lxml" "LXML (XML/HTML parser)"
install_python_package "paramiko" "Paramiko (SSH library)"
install_python_package "scapy" "Scapy (packet manipulation)"

# Install wordlists
echo "📚 Installing Wordlists"
echo "======================="

log "${YELLOW}Installing wordlists...${NC}"

# Create wordlists directory
sudo mkdir -p /usr/share/wordlists

# Download common wordlists
if [ ! -f "/usr/share/wordlists/rockyou.txt" ]; then
    log "Downloading rockyou.txt wordlist..."
    sudo wget -O /usr/share/wordlists/rockyou.txt.gz https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt.gz
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
    log "${GREEN}✅ rockyou.txt downloaded${NC}"
else
    log "${GREEN}✅ rockyou.txt already exists${NC}"
fi

# Download SecLists
if [ ! -d "/usr/share/wordlists/SecLists" ]; then
    log "Downloading SecLists..."
    sudo git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists
    log "${GREEN}✅ SecLists downloaded${NC}"
else
    log "${GREEN}✅ SecLists already exists${NC}"
fi

echo ""

# Install additional security tools
echo "🔒 Installing Security Tools"
echo "============================"

install_package "tcpdump" "Tcpdump (packet analyzer)"
install_package "wireshark" "Wireshark (network protocol analyzer)"
install_package "tshark" "TShark (Wireshark CLI)"
install_package "tcpflow" "Tcpflow (TCP flow recorder)"
install_package "ngrep" "Ngrep (network grep)"

# Install development tools
echo "💻 Installing Development Tools"
echo "==============================="

install_package "build-essential" "Build essentials"
install_package "git" "Git (version control)"
install_package "vim" "Vim (text editor)"
install_package "nano" "Nano (text editor)"

# Verify installations
echo "✅ Verifying Installations"
echo "========================="

tools=(
    "curl:cURL"
    "wget:Wget"
    "nc:Netcat"
    "dig:Dig"
    "nmap:Nmap"
    "hping3:Hping3"
    "hydra:Hydra"
    "sqlmap:SQLMap"
    "nikto:Nikto"
    "ab:Apache Bench"
    "telnet:Telnet"
    "ftp:FTP"
    "ssh:SSH"
    "python3:Python 3"
    "git:Git"
    "tcpdump:Tcpdump"
)

log "${CYAN}🔍 Verifying tool installations...${NC}"

for tool in "${tools[@]}"; do
    IFS=':' read -r command name <<< "$tool"
    if command_exists "$command"; then
        log "${GREEN}✅ ${name} is available${NC}"
    else
        log "${RED}❌ ${name} is not available${NC}"
    fi
done

echo ""

# Create test environment
echo "🏗️  Setting Up Test Environment"
echo "==============================="

# Create test directories
log "${YELLOW}Creating test directories...${NC}"
mkdir -p ~/test-attacks
mkdir -p ~/test-results
mkdir -p ~/test-logs

log "${GREEN}✅ Test directories created${NC}"

# Set permissions
log "${YELLOW}Setting permissions...${NC}"
chmod +x *.sh
log "${GREEN}✅ Scripts made executable${NC}"

echo ""

# Final summary
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "📋 Installed Tools Summary:"
echo "- Network scanning: nmap, hping3, masscan"
echo "- Web testing: curl, wget, ab, siege"
echo "- Penetration testing: hydra, sqlmap, nikto"
echo "- Network analysis: tcpdump, wireshark, ngrep"
echo "- Wordlists: rockyou.txt, SecLists"
echo "- Python packages: requests, beautifulsoup4, scapy"
echo ""
echo "🔧 Test Environment:"
echo "- Test scripts: $(pwd)/*.sh"
echo "- Test directories: ~/test-attacks, ~/test-results, ~/test-logs"
echo ""
echo "🚀 Next Steps:"
echo "1. Run: ./test-all-attacks.sh"
echo "2. Or run individual tests:"
echo "   - ./test-web-attacks.sh"
echo "   - ./test-network-attacks.sh"
echo "   - ./test-local-rules.sh"
echo ""
echo "📚 Documentation:"
echo "- Nmap: man nmap"
echo "- Hping3: man hping3"
echo "- Hydra: man hydra"
echo "- SQLMap: sqlmap -h"
echo ""
