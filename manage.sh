#!/bin/bash

# MiniSOC Management Script
# =========================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        print_error ".env file not found. Please create it first."
        exit 1
    fi
}

# Function to check network interfaces
check_interfaces() {
    print_status "Checking network interfaces..."
    
    # Load environment variables
    source .env
    
    # Check each interface
    for interface in "$IFACE_DOCKER" "$IFACE_LAN" "$IFACE_HOST"; do
        if ! ip link show "$interface" > /dev/null 2>&1; then
            print_warning "Interface $interface not found"
        else
            print_status "Interface $interface is available"
        fi
    done
}

# Function to start MiniSOC
start() {
    print_header "Starting MiniSOC"
    
    check_docker
    check_env
    check_interfaces
    
    print_status "Starting all services..."
    docker-compose up -d
    
    print_status "Waiting for services to start..."
    sleep 30
    
    print_status "Checking service status..."
    docker-compose ps
    
    print_status "MiniSOC started successfully!"
    print_status "Access points:"
    echo "  - Kibana: http://localhost:5601 (elastic/minisoc123)"
    echo "  - API: http://localhost:8080"
    echo "  - DVWA: http://localhost:8081"
    echo "  - Juice Shop: http://localhost:8082"
}

# Function to stop MiniSOC
stop() {
    print_header "Stopping MiniSOC"
    
    check_docker
    
    print_status "Stopping all services..."
    docker-compose down
    
    print_status "MiniSOC stopped successfully!"
}

# Function to restart MiniSOC
restart() {
    print_header "Restarting MiniSOC"
    
    stop
    sleep 5
    start
}

# Function to show status
status() {
    print_header "MiniSOC Status"
    
    check_docker
    
    print_status "Container status:"
    docker-compose ps
    
    print_status "Recent logs:"
    docker-compose logs --tail=20
}

# Function to show logs
logs() {
    print_header "MiniSOC Logs"
    
    check_docker
    
    if [ -z "$1" ]; then
        print_status "Showing logs for all services..."
        docker-compose logs -f
    else
        print_status "Showing logs for service: $1"
        docker-compose logs -f "$1"
    fi
}

# Function to test Suricata
test_suricata() {
    print_header "Testing Suricata Configuration"
    
    check_docker
    
    print_status "Testing Suricata configuration..."
    
    # Test each Suricata container
    for container in suricata-docker suricata-lan suricata-host; do
        if docker-compose ps | grep -q "$container.*Up"; then
            print_status "Testing $container..."
            docker-compose exec "$container" suricata -T -c /etc/suricata/suricata.yaml
        else
            print_warning "$container is not running"
        fi
    done
}

# Function to clean up
cleanup() {
    print_header "Cleaning Up MiniSOC"
    
    check_docker
    
    print_warning "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping and removing all containers..."
        docker-compose down -v
        
        print_status "Removing all images..."
        docker-compose down --rmi all
        
        print_status "Cleaning up completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to show help
show_help() {
    print_header "MiniSOC Management Script"
    
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start MiniSOC services"
    echo "  stop        Stop MiniSOC services"
    echo "  restart     Restart MiniSOC services"
    echo "  status      Show service status"
    echo "  logs [SERVICE] Show logs (all services or specific service)"
    echo "  test        Test Suricata configuration"
    echo "  cleanup     Remove all containers and data"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs suricata-docker"
    echo "  $0 test"
}

# Main script logic
case "${1:-help}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs "$2"
        ;;
    test)
        test_suricata
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
