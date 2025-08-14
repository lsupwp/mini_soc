# MiniSOC - Mini Security Operations Center

A comprehensive security monitoring and threat detection platform built with Docker containers.

## 🚀 Features

- **Multi-Interface Monitoring**: Monitor Docker, LAN, and Host network interfaces
- **Real-time Threat Detection**: Suricata IDS with custom and community rules
- **Log Analysis**: Elasticsearch + Kibana for log aggregation and visualization
- **Network Analysis**: Zeek for network protocol analysis
- **API Integration**: RESTful API for data access and management
- **Attack Simulation**: Built-in vulnerable applications for testing

## 📋 Prerequisites

- Docker and Docker Compose
- Linux system with network interfaces
- At least 4GB RAM (8GB recommended)
- Root/sudo access for network monitoring

## 🛠️ Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd mini_soc
   ```

2. **Configure network interfaces**:
   Edit `.env` file to match your system's network interfaces:
   ```bash
   # Check your network interfaces
   ip addr show
   
   # Update .env file with correct interface names
   IFACE_DOCKER=docker0
   IFACE_LAN=eth0
   IFACE_HOST=wlan0
   ```

3. **Start the platform**:
   ```bash
   docker-compose up -d
   ```

## 🏗️ Architecture

### Core Components

- **Suricata IDS**: Three instances monitoring different network interfaces
  - `suricata-docker`: Monitors Docker network traffic
  - `suricata-lan`: Monitors LAN traffic
  - `suricata-host`: Monitors host machine traffic

- **Elastic Stack**: Log aggregation and visualization
  - Elasticsearch: Data storage and indexing
  - Kibana: Web interface for data visualization

- **Zeek**: Network protocol analysis and logging

- **Filebeat**: Log shipping from Suricata to Elasticsearch

- **API**: RESTful API for data access and management

### Attack Simulation Tools

- **DVWA**: Damn Vulnerable Web Application
- **Juice Shop**: Modern vulnerable web application
- **Attacker Tools**: Alpine container with penetration testing tools

## 🔧 Configuration

### Environment Variables

Key configuration options in `.env`:

```bash
# Elasticsearch
ELASTIC_PASSWORD=minisoc123
KIBANA_PASSWORD=minisoc123

# Network Interfaces
IFACE_DOCKER=docker0
IFACE_LAN=eth0
IFACE_HOST=wlan0

# Suricata
SURICATA_VERSION=7.0.5
```

### Suricata Rules

Custom rules are located in `suricata/rules/`:
- `suricata.rules`: Custom MiniSOC detection rules
- `local.rules`: Local custom rules
- `host-monitoring.rules`: Host-specific monitoring rules

## 📊 Monitoring

### Access Points

- **Kibana**: http://localhost:5601
  - Username: `elastic`
  - Password: `minisoc123`

- **API**: http://localhost:8080
- **DVWA**: http://localhost:8081
- **Juice Shop**: http://localhost:8082

### Log Locations

- **Suricata EVE logs**: `/var/log/suricata/eve.json`
- **Suricata logs**: `/var/log/suricata/suricata.log`
- **Zeek logs**: `/opt/zeek/logs/current/`

## 🧪 Testing

### Attack Simulation

1. **Access vulnerable applications**:
   - DVWA: http://localhost:8081
   - Juice Shop: http://localhost:8082

2. **Use attacker tools**:
   ```bash
   docker exec -it minisoc-attacker sh
   ```

3. **Run test scripts**:
   ```bash
   # Test local rules
   ./voldermor/test-local-rules.sh
   
   # Test network attacks
   ./voldermor/test-network-attacks.sh
   
   # Test web attacks
   ./voldermor/test-web-attacks.sh
   ```

### Monitoring Alerts

Check for alerts in:
- Kibana dashboards
- Suricata logs
- API endpoints

## 🔍 Troubleshooting

### Common Issues

1. **Suricata containers not starting**:
   ```bash
   # Check interface names
   ip addr show
   
   # Update .env file
   # Restart containers
   docker-compose restart suricata-docker suricata-lan suricata-host
   ```

2. **Permission denied errors**:
   ```bash
   # Ensure scripts are executable
   chmod +x suricata/start-suricata.sh
   chmod +x suricata/start-suricata-host.sh
   ```

3. **Elasticsearch not starting**:
   ```bash
   # Check system resources
   free -h
   
   # Increase virtual memory
   sudo sysctl -w vm.max_map_count=262144
   ```

### Log Analysis

```bash
# Check Suricata logs
docker-compose logs suricata-docker
docker-compose logs suricata-lan
docker-compose logs suricata-host

# Check Elasticsearch logs
docker-compose logs elasticsearch

# Check all services
docker-compose logs
```

## 📈 Performance Tuning

### Resource Allocation

- **Elasticsearch**: Minimum 2GB RAM
- **Suricata**: 1GB RAM per instance
- **Kibana**: 1GB RAM

### Network Performance

- Use `af-packet` mode for high-performance packet capture
- Configure appropriate buffer sizes for your network
- Monitor system resources during high traffic

## 🔒 Security Considerations

- Change default passwords in `.env`
- Restrict network access to monitoring interfaces
- Regularly update container images
- Monitor for unauthorized access attempts
- Backup configuration and data regularly

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
- Check the troubleshooting section
- Review logs for error messages
- Open an issue on GitHub
