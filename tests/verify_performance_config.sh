#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/calamares/modules/fstab.conf"

echo "Verifying performance configuration in $CONFIG_FILE..."

# Check for space_cache=v2 in btrfs mount options
# We expect it alongside compress=zstd to ensure it's in the main mountOptions block, not just ssdExtraMountOptions
if grep -E "btrfs:.*compress=zstd.*space_cache=v2" "$CONFIG_FILE"; then
    echo "✅ space_cache=v2 found in main Btrfs mount options"
else
    echo "❌ space_cache=v2 NOT found in main Btrfs mount options (or not correctly placed)"
    # Show context for debugging
    grep "btrfs:" "$CONFIG_FILE" || true
    exit 1
fi

echo "All performance checks passed!"
