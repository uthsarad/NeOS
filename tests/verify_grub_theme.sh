#!/bin/bash
set -euo pipefail

echo "Verifying NeOS GRUB theme..."

THEME_DIR="profile/airootfs/usr/share/grub/themes/neos"
for f in theme.txt background.png; do
    if [[ ! -f "$THEME_DIR/$f" ]]; then
        echo "FAIL: missing $THEME_DIR/$f"
        exit 1
    fi
done

if ! grep -qE 'desktop-image:[[:space:]]*"background.png"' "$THEME_DIR/theme.txt"; then
    echo "FAIL: theme.txt must reference background.png"
    exit 1
fi

GRUB_DEFAULT="profile/airootfs/etc/default/grub"
if ! grep -qE '^GRUB_THEME="/usr/share/grub/themes/neos/theme.txt"' "$GRUB_DEFAULT"; then
    echo "FAIL: /etc/default/grub must point GRUB_THEME at the NeOS theme"
    exit 1
fi
if ! grep -qE '^GRUB_FONT="/usr/share/grub/themes/neos/neos.pf2"' "$GRUB_DEFAULT"; then
    echo "FAIL: /etc/default/grub must set GRUB_FONT to the generated neos.pf2"
    exit 1
fi

# The .pf2 is generated at build time; make sure build.sh actually does it.
if ! grep -q "grub-mkfont" build.sh; then
    echo "FAIL: build.sh must generate the GRUB theme font via grub-mkfont"
    exit 1
fi

echo "PASS: GRUB theme present and wired."
