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

# neos.pf2 is a COMMITTED asset (CI builds with mkarchiso directly and never
# runs build.sh, so the font must already exist in the tree). Verify it is
# present and is a real GRUB PF2 font (header begins with "FILE...PFF2").
PF2="$THEME_DIR/neos.pf2"
if [[ ! -f "$PF2" ]]; then
    echo "FAIL: $PF2 missing (run tools/gen-grub-theme.py to generate it)"
    exit 1
fi
if [[ "$(head -c4 "$PF2")" != "FILE" ]] || ! head -c16 "$PF2" | grep -q "PFF2"; then
    echo "FAIL: $PF2 is not a valid GRUB PF2 font"
    exit 1
fi
# The font must ship to installed disks via the overlay manifest.
if ! grep -qx "usr/share/grub/themes/neos/neos.pf2" \
        profile/airootfs/etc/calamares/neos-overlay.txt; then
    echo "FAIL: neos.pf2 missing from neos-overlay.txt (won't reach installed disks)"
    exit 1
fi

echo "PASS: GRUB theme present and wired."
