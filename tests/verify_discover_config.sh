#!/bin/bash
set -e
echo "Testing Phase 7 Discover Configuration..."
grep -q "discover" profile/packages.x86_64
grep -q "packagekit-qt6" profile/packages.x86_64
grep -q "flatpak" profile/packages.x86_64
grep -q "fwupd" profile/packages.x86_64

if [[ ! -f "profile/airootfs/etc/xdg/discoverrc" ]]; then
    echo "Error: discoverrc missing"
    exit 1
fi

DISCOVER_CONTENT=$(<"profile/airootfs/etc/xdg/discoverrc")
if [[ "$DISCOVER_CONTENT" != *"UseFlatpak=true"* ]]; then
    echo "Error: UseFlatpak=true missing"
    exit 1
fi
if [[ "$DISCOVER_CONTENT" != *"UseFwupd=true"* ]]; then
    echo "Error: UseFwupd=true missing"
    exit 1
fi

echo "Phase 7 Discover Configuration tests passed."
