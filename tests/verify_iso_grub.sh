#!/bin/bash
set -e

GRUB_FILE="grub/grub.cfg"
PROFILE_FILE="profiledef.sh"

if [ ! -f "$GRUB_FILE" ]; then
    echo "❌ Missing $GRUB_FILE"
    exit 1
fi

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ Missing $PROFILE_FILE"
    exit 1
fi

echo "Verifying ISO GRUB entries in $GRUB_FILE..."

# Required boot paths and parameters
REQUIRED_STRINGS=(
    "linux /neos/boot/x86_64/vmlinuz-linux-lqx"
    "initrd /neos/boot/x86_64/initramfs-linux-lqx.img"
    "archisobasedir=neos"
    "archisolabel=NEOS_LIVE"
    "nowatchdog"
    "intel_pstate=enable"
    "amd_pstate=active"
)

for STR in "${REQUIRED_STRINGS[@]}"; do
    if grep -q "$STR" "$GRUB_FILE"; then
        echo "✅ '$STR' found"
    else
        echo "❌ '$STR' NOT found"
        exit 1
    fi
done

echo "Verifying profile settings in $PROFILE_FILE..."

PROFILE_STRINGS=(
    "iso_label=\"NEOS_LIVE\""
    "install_dir=\"neos\""
    "amd_pstate=active"
    "intel_pstate=enable"
)

for STR in "${PROFILE_STRINGS[@]}"; do
    if grep -q "$STR" "$PROFILE_FILE"; then
        echo "✅ '$STR' found"
    else
        echo "❌ '$STR' NOT found"
        exit 1
    fi
done

echo "ISO GRUB validation passed."
