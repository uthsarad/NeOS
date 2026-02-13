#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/default/grub"

echo "Verifying GRUB performance configuration in $CONFIG_FILE..."

# Extract the line (assuming standard format: GRUB_CMDLINE_LINUX_DEFAULT="params...")
# We use grep to find the line starting with the variable assignment, then cut to get the value inside quotes.
CMDLINE=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$CONFIG_FILE" | cut -d'"' -f2)

if [ -z "$CMDLINE" ]; then
    echo "❌ Could not find GRUB_CMDLINE_LINUX_DEFAULT in config"
    exit 1
fi

echo "Current cmdline: $CMDLINE"

# List of performance parameters to check
# Note: mce=ignore_ce is excluded as it suppresses hardware errors
PARAMS=("nowatchdog" "intel_pstate=enable" "amd_pstate=active")

ALL_PASSED=true

for PARAM in "${PARAMS[@]}"; do
    if [[ "$CMDLINE" == *"$PARAM"* ]]; then
        echo "✅ '$PARAM' found in active configuration"
    else
        echo "❌ '$PARAM' NOT found in active configuration"
        ALL_PASSED=false
    fi
done

if [ "$ALL_PASSED" = true ]; then
    echo "All GRUB performance checks passed!"
    exit 0
else
    echo "One or more performance checks failed."
    exit 1
fi
