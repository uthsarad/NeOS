#!/bin/bash
set -e

SERVICE_FILE="profile/airootfs/etc/systemd/system/neos-driver-manager.service"

echo "Verifying service hardening in $SERVICE_FILE..."

# ⚡ Bolt: Load file content once to eliminate repeated fork/exec overhead
CONTENT=$(<"$SERVICE_FILE")

# Check for ProtectSystem=strict
if [[ "$CONTENT" == *"ProtectSystem=strict"* ]]; then
    echo "✅ ProtectSystem=strict found"
else
    echo "❌ ProtectSystem=strict NOT found"
    exit 1
fi

# Check for ProtectHome=yes
if [[ "$CONTENT" == *"ProtectHome=yes"* ]]; then
    echo "✅ ProtectHome=yes found"
else
    echo "❌ ProtectHome=yes NOT found"
    exit 1
fi

# Check for PrivateTmp=yes
if [[ "$CONTENT" == *"PrivateTmp=yes"* ]]; then
    echo "✅ PrivateTmp=yes found"
else
    echo "❌ PrivateTmp=yes NOT found"
    exit 1
fi

# Check for NoNewPrivileges=yes
if [[ "$CONTENT" == *"NoNewPrivileges=yes"* ]]; then
    echo "✅ NoNewPrivileges=yes found"
else
    echo "❌ NoNewPrivileges=yes NOT found"
    exit 1
fi

echo "All security checks passed!"
