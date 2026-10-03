#!/bin/bash
set -e

CONFIG_FILE="profile/airootfs/etc/default/grub"

echo "Verifying GRUB release configuration in $CONFIG_FILE..."

CMDLINE=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$CONFIG_FILE" | cut -d'"' -f2)

if [ -z "$CMDLINE" ]; then
    echo "[FAIL] Could not find GRUB_CMDLINE_LINUX_DEFAULT in config"
    exit 1
fi

echo "Current cmdline: $CMDLINE"

REQUIRED_PARAMS=("quiet" "splash" "nowatchdog" "intel_pstate=enable" "amd_pstate=active")
FORBIDDEN_PARAMS=("mce=ignore_ce")

ALL_PASSED=true

for PARAM in "${REQUIRED_PARAMS[@]}"; do
    if [[ "$CMDLINE" == *"$PARAM"* ]]; then
        echo "  [PASS] '$PARAM' found in active configuration"
    else
        echo "[FAIL] '$PARAM' NOT found in active configuration"
        ALL_PASSED=false
    fi
done

for PARAM in "${FORBIDDEN_PARAMS[@]}"; do
    if [[ "$CMDLINE" == *"$PARAM"* ]]; then
        echo "[FAIL] '$PARAM' should not be present in release configuration"
        ALL_PASSED=false
    else
        echo "  [PASS] '$PARAM' is not present"
    fi
done

# This file only reaches installed systems if Calamares edits it in place;
# grubcfg's `overwrite: true` regenerated it and dropped everything below.
GRUBCFG="profile/airootfs/etc/calamares/modules/grubcfg.conf"
if grep -qE '^overwrite:[[:space:]]*false' "$GRUBCFG"; then
    echo "  [PASS] $GRUBCFG edits /etc/default/grub in place"
else
    echo "[FAIL] $GRUBCFG must set 'overwrite: false' or the installed system loses $CONFIG_FILE"
    ALL_PASSED=false
fi

TIMEOUT=$(sed -n 's/^GRUB_TIMEOUT=//p' "$CONFIG_FILE" | tr -d '"')
if [[ "$TIMEOUT" =~ ^[0-9]+$ ]] && (( TIMEOUT >= 3 )); then
    echo "  [PASS] GRUB_TIMEOUT=$TIMEOUT leaves time to reach the snapshot submenu"
else
    echo "[FAIL] GRUB_TIMEOUT='$TIMEOUT' is too short to reach the menu when recovering (need >= 3)"
    ALL_PASSED=false
fi

if grep -qx 'GRUB_DISABLE_OS_PROBER=false' "$CONFIG_FILE"; then
    echo "  [PASS] os-prober enabled (dual-boot systems appear in the menu)"
else
    echo "[FAIL] GRUB_DISABLE_OS_PROBER=false missing: GRUB 2.06+ would hide Windows on dual-boot installs"
    ALL_PASSED=false
fi

if [ "$ALL_PASSED" = true ]; then
    echo "GRUB release configuration checks passed!"
    exit 0
else
    echo "One or more GRUB checks failed."
    exit 1
fi
