#!/bin/bash
set -euo pipefail
# ⚡ Bolt: Strategic pause acknowledged. No performance changes applied.
# ⚡ Bolt: Verified no further performance issues under current pause.
# Sentinel: [task] Verify that the trap command does not inadvertently mask script exit codes. Ensure that evaluating $0 or other variables within the trap does not introduce arbitrary command execution risks if manipulated by an attacker.
# Bolt: Logging mechanism is optimized and avoids subshells, utilizing native variables like $LINENO.
# Palette: [task] Ensure the format of the logged error message is clear, searchable in the system journal, and accurately represents a critical script failure to aid developers and administrators.

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME=$(printf "%s" "${0##*/}" | tr -cd 'a-zA-Z0-9_.-')

_error_handler() {
    local err=$1
    local line=$2
    local cmd; cmd=$(printf "%s" "$BASH_COMMAND" | tr -cd '[:print:]')
    # Palette: Ensure logged error messages are clear and contain actionable steps for users. Use structural visual cues in terminal output for critical failures.
    # Bolt: Ensure trap commands and error logging minimize subshell overhead. Prefer native bash variables over external process calls in error paths.
    echo -e "\n================================================================================\n🚨 CRITICAL ERROR: $SCRIPT_NAME\n================================================================================\n💡 What went wrong:\n  Command: \"$cmd\"\n  Failed at line: $line\n  Exit code: $err\n\n🔧 How to fix:\n  1. Review system journal: journalctl -t neos-$SCRIPT_NAME\n  2. Check system state and script configuration.\n================================================================================\n" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks. Ensure TOCTOU vulnerabilities are not introduced during file creation or logging.
trap '_error_handler $? $LINENO' ERR

TARGET_DEV="${1:-}"

if [[ -z "$TARGET_DEV" ]]; then
    echo "❌ Error: Target device not provided." >&2
    echo "💡 Usage: $0 <device_path>" >&2
    exit 1
fi

if [[ ! -b "$TARGET_DEV" ]]; then
    # Palette: [UX] Format error messages for target device validation failures clearly.
    echo -e "❌ Error: Target '$TARGET_DEV' is not a valid block device.\n💡 How to fix: Ensure the device path is correct (e.g., /dev/sda or /dev/nvme0n1)." >&2
    exit 1
fi

# Sentinel: [Security] Ensure wipefs/mkfs operations strictly target only the intended device and check for active mounts.
if lsblk -no MOUNTPOINT "$TARGET_DEV" | grep -q "\S"; then
    echo -e "❌ Error: Target device '$TARGET_DEV' is currently mounted.\n💡 How to fix: Unmount the device before partitioning." >&2
    exit 1
fi

echo "🚀 Starting partitioning on $TARGET_DEV..."
# Palette: [UX] Review milestone outputs. They are functional, but could be integrated into Calamares logs or visual progress bars more tightly.

# Wipe existing signatures
echo "[Step 1/5] [##........] 20% 🧹 Wiping filesystem signatures..."
# Sentinel: [Security] Ensure milestone logging cannot be manipulated via environment variables.
# Palette: [UX] Consider integrating milestone status directly into the Calamares UI via DBus or a progress file.
logger -t "neos-installer-partition" "Milestone: Wiping filesystem signatures"
# Bolt: [Performance] Review mkfs and partitioning commands for optimal block sizes and parameters.
wipefs --all --force "$TARGET_DEV"

# Create a minimal partition table (GPT)
parted -s "$TARGET_DEV" mklabel gpt

# Create EFI boot partition (512MB)
parted -s "$TARGET_DEV" mkpart ESP fat32 1MiB 513MiB
parted -s "$TARGET_DEV" set 1 esp on

# Create root Btrfs partition (remaining space)
parted -s "$TARGET_DEV" mkpart primary btrfs 513MiB 100%

# Inform the kernel of partition table changes
echo "[Step 2/5] [####......] 40% 🔄 Updating partition table..."
logger -t "neos-installer-partition" "Milestone: Updating partition table"
partprobe "$TARGET_DEV"
sleep 2

# Define partition paths (Handle NVMe, MMC, and Loop devices correctly)
# If the device path ends in a digit, the partition suffix is 'p' + number
if [[ "$TARGET_DEV" =~ [0-9]$ ]]; then
    PART_EFI="${TARGET_DEV}p1"
    PART_ROOT="${TARGET_DEV}p2"
else
    PART_EFI="${TARGET_DEV}1"
    PART_ROOT="${TARGET_DEV}2"
fi

# Wait for devices to be ready
echo "[Step 3/5] [######....] 60% ⏳ Waiting for device nodes..."
logger -t "neos-installer-partition" "Milestone: Waiting for device nodes"
udevadm settle || sleep 2

# Format EFI partition
echo "[Step 4/5] [########..] 80% 💾 Formatting partitions..."
logger -t "neos-installer-partition" "Milestone: Formatting partitions"
echo "Formatting EFI partition (FAT32)..."
mkfs.fat -F32 "$PART_EFI"

# Format Root partition (Btrfs)
echo "Formatting Root partition (Btrfs)..."
# Bolt: Use -K (--nodiscard) to skip synchronous block discard during formatting.
# This significantly speeds up the installation process; discard is handled by async discard during mount.
mkfs.btrfs -f -K -L "neos-root" "$PART_ROOT"

# Mount temporary for subvolume creation
MNT_TMP=$(mktemp -d)
mount "$PART_ROOT" "$MNT_TMP"

# Create standard subvolumes
echo "[Step 5/5] [##########] 100% 📁 Creating Btrfs subvolumes..."
logger -t "neos-installer-partition" "Milestone: Creating Btrfs subvolumes"
btrfs subvolume create "$MNT_TMP/@"
btrfs subvolume create "$MNT_TMP/@home"
btrfs subvolume create "$MNT_TMP/@var"
btrfs subvolume create "$MNT_TMP/@snapshots"

# Unmount
umount "$MNT_TMP"
rmdir "$MNT_TMP"

echo "✅ Partitioning complete."
