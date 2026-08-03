#!/bin/bash
set -e
echo "Testing Phase 7 Discover Configuration..."
PACKAGES_CONTENT=$(<"profile/packages.x86_64")
for pkg in discover packagekit-qt6 flatpak fwupd; do
    if [[ "$PACKAGES_CONTENT" != *"$pkg"* ]]; then
        echo "Error: $pkg missing"
        exit 1
    fi
done

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
