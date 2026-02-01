#!/bin/bash
# NeOS Btrfs Partitioning Script
# Creates Btrfs subvolumes and sets up fstab for NeOS installation

set -euo pipefail

# Configuration
DEVICE=${1:-""}
BOOT_SIZE=${2:-"512M"}
SWAP_SIZE=${3:-"4G"}

if [[ -z "$DEVICE" ]]; then
    echo "Usage: $0 <device> [boot_size] [swap_size]"
    echo "Example: $0 /dev/sda 1G 8G"
    exit 1
fi

echo "WARNING: This will erase all data on $DEVICE. Press Ctrl+C to abort."
sleep 5

# Partition the device
echo "Creating partitions on $DEVICE..."
parted --script "$DEVICE" \
    mklabel gpt \
    mkpart ESP fat32 1MiB "$BOOT_SIZE" \
    set 1 esp on \
    mkpart primary linux-swap "$BOOT_SIZE" "$(echo "$BOOT_SIZE + $SWAP_SIZE" | bc -l)" \
    mkpart primary btrfs "$(echo "$BOOT_SIZE + $SWAP_SIZE" | bc -l)" 100%

# Get partition names
EFI_PARTITION="${DEVICE}1"
SWAP_PARTITION="${DEVICE}2"
ROOT_PARTITION="${DEVICE}3"

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 "$EFI_PARTITION"
mkswap "$SWAP_PARTITION"
swapon "$SWAP_PARTITION"
mkfs.btrfs -f "$ROOT_PARTITION"

# Mount root filesystem
mount "$ROOT_PARTITION" /mnt

# Create Btrfs subvolumes
echo "Creating Btrfs subvolumes..."
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log

# Unmount root
umount /mnt

# Mount subvolumes with proper options
echo "Mounting subvolumes..."
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@ "$ROOT_PARTITION" /mnt

# Create mount points
mkdir -p /mnt/{boot,home,.snapshots,var/log}

# Mount other subvolumes
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@var_log "$ROOT_PARTITION" /mnt/var/log

# Mount EFI partition
mkdir -p /mnt/boot
mount "$EFI_PARTITION" /mnt/boot

# Create fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Verify fstab entries
echo "Current fstab contents:"
cat /mnt/etc/fstab

echo "Partitioning and subvolume creation completed!"
echo "Root filesystem mounted at /mnt with subvolumes:"
echo "  / (root): subvol=@"
echo "  /home: subvol=@home"
echo "  /.snapshots: subvol=@snapshots"
echo "  /var/log: subvol=@var_log"