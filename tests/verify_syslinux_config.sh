#!/bin/bash
set -e

SYSLINUX_DIR="profile/syslinux"

echo "Verifying Syslinux configuration files in $SYSLINUX_DIR..."

ALL_PASSED=true

# Check each .cfg file in the syslinux directory
for cfg in "$SYSLINUX_DIR"/*.cfg; do
    echo "Checking $cfg..."

    # Check for the redundant prefix
    if grep -q "boot/syslinux/" "$cfg"; then
        echo "❌ $cfg contains redundant 'boot/syslinux/' prefix"
        grep -Hn "boot/syslinux/" "$cfg"
        ALL_PASSED=false
    else
        echo "✅ $cfg does not contain redundant prefixes"
    fi

    if grep -q "Try or Install" "$cfg"; then
        echo "❌ $cfg uses live-OS wording instead of installer-media wording"
        grep -Hn "Try or Install" "$cfg"
        ALL_PASSED=false
    else
        echo "✅ $cfg uses installer-media wording"
    fi
done

if [ "$ALL_PASSED" = true ]; then
    echo "All Syslinux configuration checks passed!"
    exit 0
else
    echo "One or more Syslinux configuration checks failed."
    exit 1
fi
