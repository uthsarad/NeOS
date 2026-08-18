#!/bin/bash
set -e

GRUB_FILE="profile/grub/grub.cfg"
PROFILE_FILE="profile/profiledef.sh"

if [[ ! -f "$GRUB_FILE" ]]; then
    echo "❌ Missing $GRUB_FILE"
    exit 1
fi

if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "❌ Missing $PROFILE_FILE"
    exit 1
fi

echo "Verifying ISO GRUB entries in $GRUB_FILE..."

REQUIRED_STRINGS=(
    "menuentry \"NeOS"
    "linux /neos/boot/x86_64/vmlinuz-linux-lts"
    "initrd /neos/boot/x86_64/initramfs-linux-lts.img"
    "archisobasedir=neos"
    "archisolabel=NEOS_ISO"
    "cow_spacesize=4G"
    "quiet splash"
    "nomodeset"
)

FORBIDDEN_STRINGS=(
    "Try or Install"
    "nowatchdog"
    "intel_pstate=enable"
    "amd_pstate=active"
)

# ⚡ Bolt: Load file content once to eliminate repeated fork/exec overhead
GRUB_CONTENT=$(<"$GRUB_FILE")

for STR in "${REQUIRED_STRINGS[@]}"; do
    if [[ "$GRUB_CONTENT" == *"$STR"* ]]; then
        echo "✅ '$STR' found"
    else
        echo "❌ '$STR' NOT found"
        exit 1
    fi
done

for STR in "${FORBIDDEN_STRINGS[@]}"; do
    if [[ "$GRUB_CONTENT" == *"$STR"* ]]; then
        echo "❌ '$STR' should not be present"
        exit 1
    else
        echo "✅ '$STR' not present"
    fi
done

echo "Verifying profile settings in $PROFILE_FILE..."

PROFILE_STRINGS=(
    "iso_label=\"NEOS_ISO\""
    "install_dir=\"neos\""
    "iso_application=\"NeOS Installation Media\""
)

PROFILE_CONTENT=$(<"$PROFILE_FILE")

for STR in "${PROFILE_STRINGS[@]}"; do
    if [[ "$PROFILE_CONTENT" == *"$STR"* ]]; then
        echo "✅ '$STR' found"
    else
        echo "❌ '$STR' NOT found"
        exit 1
    fi
done

echo "ISO GRUB validation passed."
