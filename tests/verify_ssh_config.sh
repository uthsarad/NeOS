#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/ssh/sshd_config"

echo "Verifying SSH configuration in $CONFIG_FILE..."

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ SSH config file not found!"
    exit 1
fi

if grep -q "PermitEmptyPasswords no" "$CONFIG_FILE"; then
    echo "✅ PermitEmptyPasswords no found"
else
    echo "❌ PermitEmptyPasswords no NOT found"
    exit 1
fi

if grep -q "PermitRootLogin no" "$CONFIG_FILE"; then
    echo "✅ PermitRootLogin no found"
else
    echo "❌ PermitRootLogin no NOT found"
    exit 1
fi

echo "SSH security verification passed!"
