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

BRANDING="profile/airootfs/etc/calamares/branding/neos/branding.desc"
# Modern slideshow API (matches show.qml Presentation).
if ! grep -qE "^slideshowAPI:[[:space:]]*2" "$BRANDING"; then
    echo "FAIL: branding.desc missing 'slideshowAPI: 2'"
    exit 1
fi
# Current Calamares uses the CAPITALISED Sidebar* style keys; the old lowercase
# names are silently ignored, so guard against regressing to them.
if ! grep -qE "^[[:space:]]*SidebarBackground:" "$BRANDING"; then
    echo "FAIL: branding.desc must use the capitalised 'SidebarBackground' key (lowercase is ignored)"
    exit 1
fi
if [[ ! -f "profile/airootfs/etc/calamares/branding/neos/stylesheet.qss" ]]; then
    echo "FAIL: branding stylesheet.qss missing"
    exit 1
fi
echo "PASS: Calamares defaults are present."
