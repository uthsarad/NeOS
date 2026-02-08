#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/sysctl.d/90-neos-security.conf"

echo "Verifying security configuration in $CONFIG_FILE..."

# Check for fs.protected_hardlinks
if grep -q "fs.protected_hardlinks = 1" "$CONFIG_FILE"; then
    echo "✅ fs.protected_hardlinks found"
else
    echo "❌ fs.protected_hardlinks NOT found"
    exit 1
fi

# Check for fs.protected_symlinks
if grep -q "fs.protected_symlinks = 1" "$CONFIG_FILE"; then
    echo "✅ fs.protected_symlinks found"
else
    echo "❌ fs.protected_symlinks NOT found"
    exit 1
fi

# Check for kernel.unprivileged_bpf_disabled
if grep -q "kernel.unprivileged_bpf_disabled = 1" "$CONFIG_FILE"; then
    echo "✅ kernel.unprivileged_bpf_disabled found"
else
    echo "❌ kernel.unprivileged_bpf_disabled NOT found"
    exit 1
fi

echo "All security checks passed!"
