# 🎯 MiniSOC Suricata Attack Testing Suite

This folder contains comprehensive testing scripts for validating MiniSOC Suricata rules and detection capabilities.

## 📁 Files Overview

### 🔧 Setup Scripts
- **`install-tools.sh`** - Installs all necessary tools for attack testing
- **`README.md`** - This documentation file

### 🧪 Testing Scripts
- **`test-web-attacks.sh`** - Tests web application attack detection (30 tests)
- **`test-network-attacks.sh`** - Tests network-based attack detection (36 tests)
- **`test-local-rules.sh`** - Tests local network rules specifically (42 tests)
- **`test-all-attacks.sh`** - Comprehensive testing with report generation (108 total tests)

## 🚀 Quick Start

### 1. Install Required Tools
```bash
chmod +x install-tools.sh
./install-tools.sh
```

### 2. Run Comprehensive Testing
```bash
chmod +x test-all-attacks.sh
./test-all-attacks.sh
```

### 3. Run Individual Test Categories
```bash
# Web attacks only
./test-web-attacks.sh

# Network attacks only
./test-network-attacks.sh

# Local network rules only
./test-local-rules.sh
```

## 📊 Test Categories

### 🌐 Web Attack Tests (30 tests)
- **SQL Injection**: UNION SELECT, OR 1=1, DROP TABLE, INSERT
- **XSS (Cross-Site Scripting)**: Basic script, JavaScript events, encoded scripts
- **Directory Traversal**: Basic, encoded, double dot
- **Command Injection**: Pipe, semicolon, AND, backticks
- **File Upload**: PHP, JSP, ASP shells
- **Information Disclosure**: PHP info, Git config, environment files
- **Authentication Bypass**: Admin panels, login pages
- **API Security**: SQL injection, XSS in APIs
- **Social Engineering**: Fake bank, PayPal, Amazon pages
- **Advanced Evasion**: Case manipulation, comment injection, null bytes

### 🌐 Network Attack Tests (36 tests)
- **Port Scanning**: TCP SYN, TCP Connect, UDP, stealth, aggressive
- **DoS (Denial of Service)**: SYN flood, UDP flood, ICMP flood, HTTP flood
- **Brute Force**: SSH, HTTP admin, FTP
- **Network Services**: SSH, Telnet, FTP, RDP, SMB access attempts
- **DNS Attacks**: Amplification, zone transfer, cache poisoning
- **IoT/Embedded Devices**: HTTP flood, device discovery
- **Data Exfiltration**: Large transfers, database dumps
- **Cryptocurrency Mining**: Mining pools, mining scripts
- **Malware C2**: Command & control communication, suspicious downloads
- **APT (Advanced Persistent Threat)**: PowerShell, WMI, registry modification
- **Zero-Day Exploits**: Buffer overflow, format string attacks
- **Social Engineering**: Network-based phishing attempts

### 🏠 Local Network Tests (42 tests)
- **Internal Network Access**: HTTP, HTTPS, SSH to internal networks
- **Internal Network Outbound**: HTTP, HTTPS, DNS from internal networks
- **Local Service Monitoring**: SSH, HTTP, HTTPS access to internal networks
- **Local Network Scanning**: Port scans, service discovery on internal networks
- **Local Network DoS**: SYN flood, HTTP flood against internal networks
- **Local Network Web Attacks**: SQL injection, XSS, directory traversal
- **Local Network File Upload**: PHP, JSP, ASP uploads to internal networks
- **Local Network Info Disclosure**: PHP info, Git config, environment files
- **Local Network Auth Bypass**: Admin panels, login pages on internal networks
- **Local Network IoT**: Telnet, FTP, RDP, SMB access to internal networks
- **Local Network Data Exfiltration**: Large transfers, database dumps
- **Local Network Social Engineering**: Phishing attempts from internal networks
- **Local Network Crypto Mining**: Mining pools, scripts from internal networks
- **Local Network IoT Botnet**: DNS amplification, HTTP flood from internal networks
- **Local Network Compliance**: SSH, RDP, FTP access logging

## 📈 Expected Results

### 🎯 Detection Targets
- **Web Application Attacks**: Should trigger `web-application-attack` alerts
- **Network Reconnaissance**: Should trigger `attempted-recon` alerts
- **Denial of Service**: Should trigger `attempted-dos` alerts
- **Local Network Activity**: Should trigger `LOCAL_*` alerts
- **Policy Violations**: Should trigger `policy-violation` alerts
- **Data Leakage**: Should trigger `data-leak` alerts
- **Social Engineering**: Should trigger `social-engineering` alerts

### 📊 Performance Metrics
- **Detection Rate**: Percentage of attacks successfully detected
- **False Positives**: Legitimate traffic incorrectly flagged
- **False Negatives**: Attacks that went undetected
- **Response Time**: Time between attack and alert generation

## 🔍 Monitoring and Analysis

### 📋 Check Suricata Logs
```bash
# View all alerts
sudo docker compose logs suricata-host | grep -i alert

# View specific alert types
sudo docker compose logs suricata-host | grep -i "web-application-attack"
sudo docker compose logs suricata-host | grep -i "attempted-recon"
sudo docker compose logs suricata-host | grep -i "local"

# View real-time logs
sudo docker compose logs -f suricata-host
```

### 📊 Analyze Results
```bash
# Count alerts by type
sudo docker compose logs suricata-host | grep -i alert | cut -d' ' -f1 | sort | uniq -c

# View recent alerts
sudo docker compose logs suricata-host | grep -i alert | tail -20

# Export alerts to file
sudo docker compose logs suricata-host | grep -i alert > alerts.log
```

## 🛠️ Troubleshooting

### Common Issues
1. **Suricata not running**: Start with `sudo docker compose up -d suricata-host`
2. **No alerts generated**: Check if target services are running
3. **Permission denied**: Run with `sudo` for network scanning tools
4. **Tools not found**: Run `./install-tools.sh` to install missing tools

### Debug Commands
```bash
# Check Suricata status
sudo docker compose ps suricata-host

# Check Suricata configuration
sudo docker exec minisoc-suricata-host cat /etc/suricata/suricata.yaml

# Check loaded rules
sudo docker compose logs suricata-host | grep "rules successfully loaded"

# Check interface status
sudo docker compose logs suricata-host | grep "ioctl"
```

## 📚 Tool Documentation

### Essential Tools
- **Nmap**: `man nmap` - Network scanning
- **Hping3**: `man hping3` - Packet generation
- **Hydra**: `man hydra` - Brute force attacks
- **SQLMap**: `sqlmap -h` - SQL injection testing
- **cURL**: `man curl` - HTTP requests

### Wordlists
- **rockyou.txt**: `/usr/share/wordlists/rockyou.txt`
- **SecLists**: `/usr/share/wordlists/SecLists/`

## 🔒 Security Considerations

### ⚠️ Important Notes
- These scripts generate real attack traffic
- Use only in controlled, authorized environments
- Some tests may trigger security systems
- Monitor system resources during testing
- Ensure proper authorization before testing

### 🛡️ Safe Testing Practices
- Test in isolated environments
- Use dedicated test machines
- Monitor network impact
- Have rollback procedures ready
- Document all testing activities

## 📞 Support

### Getting Help
1. Check Suricata logs for errors
2. Verify all tools are installed
3. Ensure target services are running
4. Review this documentation
5. Check MiniSOC main documentation

### Useful Commands
```bash
# Check all container status
sudo docker compose ps

# View all logs
sudo docker compose logs

# Restart Suricata
sudo docker compose restart suricata-host

# Check disk space
df -h

# Check memory usage
free -h
```

## 🎉 Success Criteria

A successful test run should show:
- ✅ All test scripts execute without errors
- ✅ Suricata generates alerts for various attack types
- ✅ Detection rate above 70%
- ✅ No false positives on legitimate traffic
- ✅ Comprehensive coverage of rule categories
- ✅ Proper logging and reporting

---

**Happy Testing! 🎯**
