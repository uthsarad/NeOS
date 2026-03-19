#!/bin/bash
set -e

SERVICE_FILE="airootfs/etc/systemd/system/neos-driver-manager.service"

echo "Verifying service hardening in $SERVICE_FILE..."

# Check for ProtectSystem=full
if grep -q "ProtectSystem=full" "$SERVICE_FILE"; then
    echo "✅ ProtectSystem=full found"
else
    echo "❌ ProtectSystem=full NOT found"
    exit 1
fi

# Check for ProtectHome=yes
if grep -q "ProtectHome=yes" "$SERVICE_FILE"; then
    echo "✅ ProtectHome=yes found"
else
    echo "❌ ProtectHome=yes NOT found"
    exit 1
fi

# Check for PrivateTmp=yes
if grep -q "PrivateTmp=yes" "$SERVICE_FILE"; then
    echo "✅ PrivateTmp=yes found"
else
    echo "❌ PrivateTmp=yes NOT found"
    exit 1
fi

# Check for NoNewPrivileges=yes
if grep -q "NoNewPrivileges=yes" "$SERVICE_FILE"; then
    echo "✅ NoNewPrivileges=yes found"
else
    echo "❌ NoNewPrivileges=yes NOT found"
    exit 1
fi

echo "All security checks passed!"
