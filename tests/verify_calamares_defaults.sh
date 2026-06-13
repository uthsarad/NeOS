#!/bin/bash
set -euo pipefail

echo "Verifying calamares defaults..."
if [[ ! -f "profile/airootfs/etc/calamares/modules/partition.conf" ]]; then
    echo "FAIL: partition.conf missing"
    exit 1
fi
if ! grep -q "defaultFileSystemType:.*btrfs" "profile/airootfs/etc/calamares/modules/partition.conf"; then
    echo "FAIL: partition.conf does not set btrfs"
    exit 1
fi
if [[ ! -f "profile/airootfs/etc/calamares/modules/welcome.conf" ]]; then
    echo "FAIL: welcome.conf missing"
    exit 1
fi
echo "PASS: Calamares defaults are present."
