#!/bin/bash
# Verify the installed system boots into the GUI, and the boot splash is the
# "plain" animated loader cat.
#
# - tty1 regression: the netinstalled system landed on a text console because
#   nothing set its default systemd target. The services-systemd module must set
#   graphical.target so it boots into SDDM/Plasma.
# - Boot splash: the Plymouth 'neos' theme uses a Windows-11-style layout — the
#   NeOS logo (logo.png) centered above mid-screen, with the animated cat-NN.png
#   loader below it. Cat frames are generated from tools/loader-cat.gif
#   (committed; CI does not run generators).
set -euo pipefail

SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
THEME_DIR="profile/airootfs/usr/share/plymouth/themes/neos"
SCRIPT="$THEME_DIR/neos.script"
FAIL=0

echo "Verifying graphical boot target + boot-logo cat..."

# 1. Installed system defaults to graphical.target (fixes boot-to-tty1).
if grep -qE '^\s*targets:' "$SERVICES" \
   && grep -qE 'name:\s*"?graphical"?' "$SERVICES"; then
    echo "✅ services-systemd sets default target to graphical"
else
    echo "❌ services-systemd must set 'targets: [graphical]' or it boots to tty1"; FAIL=1
fi
if grep -qE 'name:\s*"?sddm"?' "$SERVICES"; then
    echo "✅ sddm display manager is enabled"
else
    echo "❌ sddm is not enabled"; FAIL=1
fi

# 2. Boot-splash cat frames are present (32 frames) and wired into the script.
frames=$(find "$THEME_DIR" -maxdepth 1 -name 'cat-*.png' | wc -l)
if [[ "$frames" -eq 32 ]]; then
    echo "✅ 32 cat boot-splash frames present"
else
    echo "❌ expected 32 cat-NN.png frames, found $frames"; FAIL=1
fi
if grep -q 'cat-"' "$SCRIPT" || grep -q '"cat-' "$SCRIPT"; then
    echo "✅ neos.script animates the cat frames"
else
    echo "❌ neos.script does not reference the cat- frames"; FAIL=1
fi

# 3. The NeOS logo is present and wired in (Windows-11-style logo-above-cat).
if [[ -f "$THEME_DIR/logo.png" ]]; then
    echo "✅ NeOS logo.png present in the theme"
else
    echo "❌ theme is missing logo.png (Windows-11 layout needs it)"; FAIL=1
fi
if grep -q '"logo.png"' "$SCRIPT"; then
    echo "✅ neos.script loads the logo"
else
    echo "❌ neos.script does not reference logo.png"; FAIL=1
fi

# 4. The old animated-spinner assets must stay gone (replaced by the cat loader).
if find "$THEME_DIR" -maxdepth 1 -name 'spinner-*.png' | grep -q .; then
    echo "❌ stale spinner-*.png assets still present in the theme"; FAIL=1
else
    echo "✅ stale spinner assets removed"
fi
if grep -q 'spinner' "$SCRIPT"; then
    echo "❌ neos.script still references removed spinner frames"; FAIL=1
else
    echo "✅ neos.script has no stale spinner references"
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Boot/GUI verification FAILED."
    exit 1
fi
echo "Boot/GUI verification passed!"
