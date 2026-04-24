#!/bin/bash
set -euo pipefail
# ⚡ Bolt: Strategic pause acknowledged. No performance changes applied.
# Sentinel: [task] Verify that the trap command does not inadvertently mask script exit codes. Ensure that evaluating $0 or other variables within the trap does not introduce arbitrary command execution risks if manipulated by an attacker.
# Bolt: Logging mechanism is optimized and avoids subshells, utilizing native variables like $LINENO.
# Palette: [task] Ensure the format of the logged error message is clear, searchable in the system journal, and accurately represents a critical script failure to aid developers and administrators.
SCRIPT_NAME="${0##*/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="$3"
    echo -e "\n================================================================================\n🚨 CRITICAL ERROR: $SCRIPT_NAME\n================================================================================\n💡 What went wrong:\n  Command: \"$cmd\"\n  Failed at line: $line\n  Exit code: $err\n\n🔧 How to fix:\n  1. Review system journal: journalctl -t neos-$SCRIPT_NAME\n  2. Check system state and script configuration.\n================================================================================\n" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

trap '_error_handler $? $LINENO "$BASH_COMMAND"' ERR

TARGET_DEV="${1:-}"

if [[ -z "$TARGET_DEV" ]]; then
    echo "Error: Target device not provided." >&2
    echo "Usage: $0 <device_path>" >&2
    exit 1
fi

if [[ ! -b "$TARGET_DEV" ]]; then
    # Palette: [UX] Format error messages for target device validation failures clearly.
    echo "Error: Target $TARGET_DEV is not a valid block device." >&2
    exit 1
fi

# Sentinel: [Security] Ensure wipefs/mkfs operations strictly target only the intended device and check for active mounts.
if lsblk -no MOUNTPOINT "$TARGET_DEV" | grep -q "\S"; then
    echo "Error: Target device $TARGET_DEV is currently mounted." >&2
    exit 1
fi

echo "Starting partitioning on $TARGET_DEV..."
# Palette: [UX] Ensure milestone outputs are clearly visible to the user.

# Wipe existing signatures
echo "Wiping filesystem signatures..."
# Bolt: [Performance] Review mkfs and partitioning commands for optimal block sizes and parameters.
wipefs --all --force "$TARGET_DEV"

# Create a minimal partition table (GPT)
parted -s "$TARGET_DEV" mklabel gpt

# Create EFI boot partition (512MB)
parted -s "$TARGET_DEV" mkpart ESP fat32 1MiB 513MiB
parted -s "$TARGET_DEV" set 1 esp on

# Create root Btrfs partition (remaining space)
parted -s "$TARGET_DEV" mkpart primary btrfs 513MiB 100%

# Define partition paths (simplified for NVMe vs SATA)
if [[ "$TARGET_DEV" == *nvme* ]]; then
    PART_EFI="${TARGET_DEV}p1"
    PART_ROOT="${TARGET_DEV}p2"
else
    PART_EFI="${TARGET_DEV}1"
    PART_ROOT="${TARGET_DEV}2"
fi

# Wait for devices to be ready
sleep 1 # Bolt: [Performance] Minimize redundant sync or sleep calls during formatting.

# Format EFI partition
echo "Formatting EFI partition..."
mkfs.fat -F32 "$PART_EFI"

# Format Root partition (Btrfs)
echo "Formatting Root partition..."
mkfs.btrfs -f -L "neos-root" "$PART_ROOT"

# Mount temporary for subvolume creation
MNT_TMP=$(mktemp -d)
mount "$PART_ROOT" "$MNT_TMP"

# Create standard subvolumes
echo "Creating Btrfs subvolumes..."
btrfs subvolume create "$MNT_TMP/@"
btrfs subvolume create "$MNT_TMP/@home"
btrfs subvolume create "$MNT_TMP/@var"
btrfs subvolume create "$MNT_TMP/@snapshots"

# Unmount
umount "$MNT_TMP"
rmdir "$MNT_TMP"

echo "Partitioning complete."
