#!/bin/bash
# Verify the installed system boots into the GUI, and the boot splash is the
# "plain" animated loader cat.
#
# - tty1 regression: the netinstalled system landed on a text console because
#   nothing set its default systemd target. The services-systemd module must set
#   graphical.target so it boots into SDDM/Plasma.
# - Boot splash: the Plymouth 'neos' theme animates cat-NN.png frames generated
#   from tools/loader-cat.gif (committed; CI does not run generators).
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

# 3. The old spinner/logo assets must be gone (replaced by the plain cat).
if find "$THEME_DIR" -maxdepth 1 \( -name 'spinner-*.png' -o -name 'logo.png' \) | grep -q .; then
    echo "❌ stale spinner-*/logo.png assets still present in the theme"; FAIL=1
else
    echo "✅ stale spinner/logo assets removed"
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
