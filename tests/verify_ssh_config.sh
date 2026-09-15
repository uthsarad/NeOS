#!/bin/bash
set -e

CONFIG_FILE="profile/airootfs/etc/ssh/sshd_config"

echo "Verifying SSH configuration in $CONFIG_FILE..."

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[FAIL] SSH config file not found!"
    exit 1
fi

if grep -q "PermitEmptyPasswords no" "$CONFIG_FILE"; then
    echo "  [PASS] PermitEmptyPasswords no found"
else
    echo "[FAIL] PermitEmptyPasswords no NOT found"
    exit 1
fi

if grep -q "PermitRootLogin no" "$CONFIG_FILE"; then
    echo "  [PASS] PermitRootLogin no found"
else
    echo "[FAIL] PermitRootLogin no NOT found"
    exit 1
fi

echo "SSH security verification passed!"
