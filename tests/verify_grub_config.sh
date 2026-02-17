#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/default/grub"

echo "Verifying GRUB release configuration in $CONFIG_FILE..."

CMDLINE=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$CONFIG_FILE" | cut -d'"' -f2)

if [ -z "$CMDLINE" ]; then
    echo "❌ Could not find GRUB_CMDLINE_LINUX_DEFAULT in config"
    exit 1
fi

echo "Current cmdline: $CMDLINE"

REQUIRED_PARAMS=("quiet" "splash" "nowatchdog" "intel_pstate=enable" "amd_pstate=active")
FORBIDDEN_PARAMS=("mce=ignore_ce")

ALL_PASSED=true

for PARAM in "${REQUIRED_PARAMS[@]}"; do
    if [[ "$CMDLINE" == *"$PARAM"* ]]; then
        echo "✅ '$PARAM' found in active configuration"
    else
        echo "❌ '$PARAM' NOT found in active configuration"
        ALL_PASSED=false
    fi
done

for PARAM in "${FORBIDDEN_PARAMS[@]}"; do
    if [[ "$CMDLINE" == *"$PARAM"* ]]; then
        echo "❌ '$PARAM' should not be present in release configuration"
        ALL_PASSED=false
    else
        echo "✅ '$PARAM' is not present"
    fi
done

if [ "$ALL_PASSED" = true ]; then
    echo "GRUB release configuration checks passed!"
    exit 0
else
    echo "One or more GRUB checks failed."
    exit 1
fi
