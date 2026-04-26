#!/bin/bash
set -euo pipefail

SCRIPT_PATH="profile/airootfs/usr/local/bin/neos-installer-partition.sh"

echo "Verifying $SCRIPT_PATH exists and is executable..."
if [[ ! -x "$SCRIPT_PATH" ]]; then
    echo "FAIL: Script does not exist or is not executable."
    exit 1
fi

echo "Verifying subvolume creation logic..."
if ! grep -q "btrfs subvolume create.*@" "$SCRIPT_PATH" || \
   ! grep -q "btrfs subvolume create.*@home" "$SCRIPT_PATH" || \
   ! grep -q "btrfs subvolume create.*@var" "$SCRIPT_PATH" || \
   ! grep -q "btrfs subvolume create.*@snapshots" "$SCRIPT_PATH"; then
    echo "FAIL: Missing subvolume creation commands."
    exit 1
fi

echo "Verifying safety checks..."
if ! grep -q "lsblk" "$SCRIPT_PATH"; then
    echo "FAIL: Missing mount check."
    exit 1
fi
if ! grep -q "\! -b" "$SCRIPT_PATH"; then
    echo "FAIL: Missing block device check."
    exit 1
fi

echo "PASS: Basic static checks passed."
