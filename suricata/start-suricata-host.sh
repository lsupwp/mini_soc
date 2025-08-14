#!/bin/sh
set -eu

# Default interface - can be overridden by environment variable
IFACE="${IFACE_HOST:-wlan0}"

echo "[*] Starting Suricata (host mode) on interface: ${IFACE}"
echo "[*] Using configuration: /etc/suricata/suricata.yaml"

# Create log directory
mkdir -p /var/log/suricata

# Test configuration
echo "[*] Testing Suricata configuration..."
if ! suricata -T -c /etc/suricata/suricata.yaml >/var/log/suricata/configtest.log 2>&1; then
  echo "[WARN] Configuration test failed, but continuing..."
  echo "[WARN] Check /var/log/suricata/configtest.log for details"
fi

# Start Suricata in pcap mode for host interface
echo "[*] Starting Suricata in pcap mode..."
suricata -c /etc/suricata/suricata.yaml -i "$IFACE" -D

# Wait for Suricata to start
sleep 3

# Check if Suricata is running
if ! pgrep -f suricata > /dev/null; then
  echo "[ERR] Suricata failed to start"
  echo "[ERR] Check logs at /var/log/suricata/suricata.log"
  exit 1
fi

echo "[*] Suricata started successfully on ${IFACE}"
echo "[*] Tailing EVE logs..."

# Tail the EVE logs
exec tail -F /var/log/suricata/eve.json
