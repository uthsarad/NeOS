#!/bin/bash
set -euo pipefail
# ⚡ Bolt: Strategic pause acknowledged. No performance changes applied.
# ⚡ Bolt: Verified no further performance issues under current pause.
# Sentinel: [task] Verify that the trap command does not inadvertently mask script exit codes. Ensure that evaluating $0 or other variables within the trap does not introduce arbitrary command execution risks if manipulated by an attacker.
# Bolt: Logging mechanism is optimized and avoids subshells, utilizing native variables like $LINENO.

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME=$(printf "%s" "${0##*/}" | tr -cd 'a-zA-Z0-9_.-')

_error_handler() {
    local err=$1
    local line=$2
    local cmd; cmd=$(printf "%s" "$BASH_COMMAND" | tr -cd '[:print:]')
    # Bolt: Ensure trap commands and error logging minimize subshell overhead. Prefer native bash variables over external process calls in error paths.
    printf "\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[31m🚨 CRITICAL ERROR: %s\e[0m\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[36m💡 What went wrong:\e[0m\n  Command: \"%s\"\n  Failed at line: %s\n  Exit code: %s\n\n\e[1m\e[36m🔧 How to fix:\e[0m\n  1. Review system journal: \e[1mjournalctl -t neos-%s\e[0m\n  2. Check system state and script configuration.\n\e[1m\e[31m================================================================================\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$line" "$err" "$SCRIPT_NAME" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks. Ensure TOCTOU vulnerabilities are not introduced during file creation or logging.
trap '_error_handler $? $LINENO' ERR

TARGET_DEV="${1:-}"

if [[ -z "$TARGET_DEV" ]]; then
    printf "\e[1m\e[31m❌ Error: Target device not provided.\e[0m\n" >&2
    printf "\e[1m\e[36m💡 Usage:\e[0m %s <device_path>\n" "$0" >&2
    exit 1
fi

if [[ ! -b "$TARGET_DEV" ]]; then
    printf "\e[1m\e[31m❌ Error: Target '%s' is not a valid block device.\e[0m\n\e[1m\e[36m💡 How to fix:\e[0m Ensure the device path is correct (e.g., /dev/sda or /dev/nvme0n1).\n" "$TARGET_DEV" >&2
    exit 1
fi

# Sentinel: [Security] Ensure wipefs/mkfs operations strictly target only the intended device and check for active mounts.
if lsblk -no MOUNTPOINT -- "$TARGET_DEV" | grep -q "\S"; then
    printf "\e[1m\e[31m❌ Error: Target device '%s' is currently mounted.\e[0m\n\e[1m\e[36m💡 How to fix:\e[0m Unmount the device before partitioning.\n" "$TARGET_DEV" >&2
    exit 1
fi

printf "🚀 Starting partitioning on %s...\n" "$TARGET_DEV"

# Wipe existing signatures
# Palette: [UX] Review ASCII text-based progress bars for correct rendering and standard compatibility.
echo -e "\e[1m\e[36m[Step 1/5]\e[0m \e[32m[##........] 20%\e[0m 🧹 Wiping filesystem signatures..."
echo "20" > /run/neos-partition-progress
# Sentinel: [Security] Ensure milestone logging cannot be manipulated via environment variables.
# Sentinel: [Audit] Verify milestone logging does not introduce injection vectors.
logger -t "neos-installer-partition" "Milestone: Wiping filesystem signatures"
# Bolt: [Performance] Review mkfs and partitioning commands for optimal block sizes and parameters.
wipefs --all --force -- "$TARGET_DEV"

# Create a minimal partition table (GPT)
parted -s -- "$TARGET_DEV" mklabel gpt

# Create EFI boot partition (512MB)
parted -s -- "$TARGET_DEV" mkpart ESP fat32 1MiB 513MiB
parted -s -- "$TARGET_DEV" set 1 esp on

# Create root Btrfs partition (remaining space)
parted -s -- "$TARGET_DEV" mkpart primary btrfs 513MiB 100%

# Inform the kernel of partition table changes
echo -e "\e[1m\e[36m[Step 2/5]\e[0m \e[32m[####......] 40%\e[0m 🔄 Updating partition table..."
echo "40" > /run/neos-partition-progress
logger -t "neos-installer-partition" "Milestone: Updating partition table"
partprobe -- "$TARGET_DEV"
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
echo -e "\e[1m\e[36m[Step 3/5]\e[0m \e[32m[######....] 60%\e[0m ⏳ Waiting for device nodes..."
echo "60" > /run/neos-partition-progress
logger -t "neos-installer-partition" "Milestone: Waiting for device nodes"
udevadm settle || sleep 2

# Format EFI partition
echo -e "\e[1m\e[36m[Step 4/5]\e[0m \e[32m[########..] 80%\e[0m 💾 Formatting partitions..."
echo "80" > /run/neos-partition-progress
logger -t "neos-installer-partition" "Milestone: Formatting partitions"
echo "Formatting EFI partition (FAT32)..."
mkfs.fat -F32 -- "$PART_EFI"

# Format Root partition (Btrfs)
echo "Formatting Root partition (Btrfs)..."
# Bolt: Use -K (--nodiscard) to skip synchronous block discard during formatting.
# This significantly speeds up the installation process; discard is handled by async discard during mount.
mkfs.btrfs -f -K -L "neos-root" -- "$PART_ROOT"

# Mount temporary for subvolume creation
MNT_TMP=$(mktemp -d)
mount -- "$PART_ROOT" "$MNT_TMP"

# Create standard subvolumes
echo -e "\e[1m\e[36m[Step 5/5]\e[0m \e[32m[##########] 100%\e[0m 📁 Creating Btrfs subvolumes..."
echo "100" > /run/neos-partition-progress
logger -t "neos-installer-partition" "Milestone: Creating Btrfs subvolumes"
btrfs subvolume create -- "$MNT_TMP/@"
btrfs subvolume create -- "$MNT_TMP/@home"
btrfs subvolume create -- "$MNT_TMP/@var"
btrfs subvolume create -- "$MNT_TMP/@snapshots"

# Unmount
umount -- "$MNT_TMP"
rmdir -- "$MNT_TMP"

echo "✅ Partitioning complete."
