#!/bin/bash
set -e

SERVICE_FILE="airootfs/etc/systemd/system/neos-driver-manager.service"

echo "Verifying service hardening in $SERVICE_FILE..."

if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ $SERVICE_FILE not found"
    exit 1
fi

# Check for ProtectSystem=strict
if grep -q "ProtectSystem=strict" "$SERVICE_FILE"; then
    echo "✅ ProtectSystem=strict found"
else
    echo "❌ ProtectSystem=strict NOT found"
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

# Check for ProtectKernelTunables=yes
if grep -q "ProtectKernelTunables=yes" "$SERVICE_FILE"; then
    echo "✅ ProtectKernelTunables=yes found"
else
    echo "❌ ProtectKernelTunables=yes NOT found"
    exit 1
fi

# Check for ProtectControlGroups=yes
if grep -q "ProtectControlGroups=yes" "$SERVICE_FILE"; then
    echo "✅ ProtectControlGroups=yes found"
else
    echo "❌ ProtectControlGroups=yes NOT found"
    exit 1
fi

# Check for RestrictRealtime=yes
if grep -q "RestrictRealtime=yes" "$SERVICE_FILE"; then
    echo "✅ RestrictRealtime=yes found"
else
    echo "❌ RestrictRealtime=yes NOT found"
    exit 1
fi

echo "All security checks passed!"
