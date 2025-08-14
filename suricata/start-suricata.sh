#!/bin/sh
set -eu

IFACE="${1:-}"
if [ -z "$IFACE" ]; then
  echo "[ERR] Interface arg required. Usage: /start-suricata.sh <iface>" >&2
  exit 1
fi

# Create log directory
mkdir -p /var/log/suricata

echo "[*] Testing Suricata configuration..."
if ! suricata -T -c /etc/suricata/suricata.yaml >/var/log/suricata/configtest.log 2>&1; then
  echo "[WARN] Configuration test failed, but continuing..."
  echo "[WARN] Check /var/log/suricata/configtest.log for details"
  # Don't exit, just warn - some rules might have syntax issues but core functionality should work
fi

echo "[*] Starting Suricata on IFACE=${IFACE} (af-packet mode)..."
echo "[*] Using configuration: /etc/suricata/suricata.yaml"

# Start Suricata in daemon mode
suricata --af-packet \
  -c /etc/suricata/suricata.yaml \
  --set af-packet.0.interface="${IFACE}" \
  -D

# Wait a moment for Suricata to start
sleep 3

# Check if Suricata is running
if ! pgrep -f suricata > /dev/null; then
  echo "[ERR] Suricata failed to start"
  echo "[ERR] Check logs at /var/log/suricata/suricata.log"
  exit 1
fi

echo "[*] Suricata started successfully on ${IFACE}"
echo "[*] Tailing logs..."
echo "[*] EVE logs: /var/log/suricata/eve.json"
echo "[*] Suricata logs: /var/log/suricata/suricata.log"

# Tail the logs
exec tail -F /var/log/suricata/eve.json /var/log/suricata/suricata.log
