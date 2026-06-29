#!/bin/bash
set -euo pipefail

# Verify both GRUB menus (the ISO boot menu and the installed-disk GRUB) are
# wired to the classic Arch 'starfield' theme, which ships natively with the
# grub package — so there is no committed font/image asset to validate, only
# correct activation.
echo "Verifying NeOS GRUB starfield theme wiring..."

# 1. ISO boot menu (profile/grub/grub.cfg): the theme must be activated, and the
#    PNG module + fonts must be loaded BEFORE `set theme` or it renders blank.
ISO_CFG="profile/grub/grub.cfg"
if ! grep -qE 'set theme=.*themes/starfield/theme\.txt' "$ISO_CFG"; then
    echo "FAIL: $ISO_CFG must 'set theme' to the starfield theme"
    exit 1
fi
if ! grep -qE '^\s*insmod png' "$ISO_CFG"; then
    echo "FAIL: $ISO_CFG must 'insmod png' (starfield uses PNG images)"
    exit 1
fi
if ! grep -qE '^\s*loadfont .*themes/starfield/.*\.pf2' "$ISO_CFG"; then
    echo "FAIL: $ISO_CFG must 'loadfont' the starfield bundled fonts before 'set theme'"
    exit 1
fi
# loadfont must precede set theme.
LOADFONT_LINE=$(grep -nE '^\s*loadfont .*starfield' "$ISO_CFG" | head -1 | cut -d: -f1)
SETTHEME_LINE=$(grep -nE 'set theme=.*starfield' "$ISO_CFG" | head -1 | cut -d: -f1)
if [[ -z "$LOADFONT_LINE" || -z "$SETTHEME_LINE" || "$LOADFONT_LINE" -ge "$SETTHEME_LINE" ]]; then
    echo "FAIL: loadfont must appear before 'set theme' in $ISO_CFG"
    exit 1
fi
echo "✅ ISO grub.cfg activates starfield with png + fonts loaded first"

# 2. Installed-disk GRUB (/etc/default/grub): GRUB_THEME points at the
#    package-provided starfield theme; no GRUB_FONT (grub-mkconfig auto-loads
#    the theme's bundled fonts).
GRUB_DEFAULT="profile/airootfs/etc/default/grub"
if ! grep -qE '^GRUB_THEME="/usr/share/grub/themes/starfield/theme.txt"' "$GRUB_DEFAULT"; then
    echo "FAIL: $GRUB_DEFAULT must set GRUB_THEME to the starfield theme"
    exit 1
fi
if grep -qE '^GRUB_FONT=' "$GRUB_DEFAULT"; then
    echo "FAIL: $GRUB_DEFAULT must NOT set GRUB_FONT (starfield bundles its own)"
    exit 1
fi
echo "✅ installed-disk /etc/default/grub points at starfield, no stale GRUB_FONT"

# 3. The dead NeOS GRUB theme assets must be gone (both menus and the overlay).
for stale in \
    profile/grub/themes/neos \
    profile/airootfs/usr/share/grub/themes/neos ; do
    if [[ -e "$stale" ]]; then
        echo "FAIL: stale NeOS GRUB theme still present: $stale"
        exit 1
    fi
done
if grep -qE 'grub/themes/neos' profile/airootfs/etc/calamares/neos-overlay.txt; then
    echo "FAIL: neos-overlay.txt still references the removed neos GRUB theme"
    exit 1
fi
echo "✅ stale NeOS GRUB theme assets removed"

echo "PASS: GRUB starfield theme wiring verified."
