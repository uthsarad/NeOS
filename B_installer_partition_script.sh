You are a senior Arch Linux developer. Output ONLY code blocks with file paths. No explanations unless critical.

#!/bin/bash

# NeOS Btrfs Partitioning and Setup Script
# Usage: ./neos-installer.sh <device_path> [root_size(GiB)] [swap_size(GiB)]

set -euo pipefail

DEVICE="${1:-}"
ROOT_SIZE="${2:-0}"  # 0 means use remaining space
SWAP_SIZE="${3:-8}"  # Default 8GiB swap

if [[ -z "$DEVICE" ]]; then
    echo "Usage: $0 <device_path> [root_size(GiB)] [swap_size(GiB)]"
    echo "Example: $0 /dev/sda 50 8"
    exit 1
fi

if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a valid block device"
    exit 1
fi

echo "Warning: This will erase ALL data on $DEVICE. Press Ctrl+C to abort."
sleep 5

# Create GPT partition table
parted --script "$DEVICE" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart swap linux-swap 513MiB ${SWAP_SIZE}GiB \
    mkpart root btrfs ${SWAP_SIZE}GiB ${ROOT_SIZE:+$((SWAP_SIZE + ROOT_SIZE))}GiB

# Wait for partitions to be created
sleep 2

# Format partitions
ESP_PART="${DEVICE}1"
SWAP_PART="${DEVICE}2"
ROOT_PART="${DEVICE}3"

mkfs.fat -F32 "$ESP_PART"
mkswap "$SWAP_PART"
swapon "$SWAP_PART"
mkfs.btrfs -f "$ROOT_PART"

# Mount root filesystem
mount -o compress=zstd:3,ssd,noatime,space_cache=v2 "$ROOT_PART" /mnt

# Create Btrfs subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log

# Unmount root
umount /mnt

# Mount subvolumes with proper options
mount -o compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@ "$ROOT_PART" /mnt

# Create mountpoints for other subvolumes
mkdir -p /mnt/{boot,home,.snapshots,var/log}

mount -o compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@home "$ROOT_PART" /mnt/home
mount -o compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
mount -o compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@var_log "$ROOT_PART" /mnt/var/log
mount "$ESP_PART" /mnt/boot

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Add special Btrfs options to fstab
cat >> /mnt/etc/fstab << EOF
# Btrfs subvolumes
UUID=$(blkid -s UUID -o value "$ROOT_PART") /               btrfs   defaults,compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@ 0 0
UUID=$(blkid -s UUID -o value "$ROOT_PART") /home           btrfs   defaults,compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@home 0 0
UUID=$(blkid -s UUID -o value "$ROOT_PART") /.snapshots     btrfs   defaults,compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@snapshots 0 0
UUID=$(blkid -s UUID -o value "$ROOT_PART") /var/log        btrfs   defaults,compress=zstd:3,ssd,noatime,space_cache=v2,subvol=@var_log 0 0
EOF

echo "Partitioning and mounting completed successfully!"
echo "Root filesystem mounted at /mnt"
echo "Subvolumes created: @ (root), @home, @snapshots, @var_log"