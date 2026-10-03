#!/bin/bash
# Verify the installed system boots into the GUI, and the boot splash is the
# NeOS logo with a pulsing progress indicator.
#
# - tty1 regression: the netinstalled system landed on a text console because
#   nothing set its default systemd target. The services-systemd module must set
#   graphical.target so it boots into SDDM/Plasma.
# - Boot splash: the Plymouth 'neos' theme shows the logo (logo.png from
#   tools/gen-logo.py --all) with three pulsing dots (dot.png from
#   tools/gen-brand-images.py) and handles the disk-unlock prompt.
# - No KDE splash: ksplash after SDDM login is disabled via skel ksplashrc so
#   the Plymouth splash is the only boot screen.
set -euo pipefail

SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
THEME_DIR="profile/airootfs/usr/share/plymouth/themes/neos"
SCRIPT="$THEME_DIR/neos.script"
FAIL=0

echo "Verifying graphical boot target + boot splash..."

# 1. Installed system defaults to graphical.target (fixes boot-to-tty1).
SERVICES_CONTENT=""
if [[ -f "$SERVICES" ]]; then
    SERVICES_CONTENT=$(<"$SERVICES")
fi

if [[ "$SERVICES_CONTENT" =~ (^|$'\n')[[:space:]]*units: ]] && [[ "$SERVICES_CONTENT" =~ name:[[:space:]]*\"?graphical(\.target)?\"? ]] && [[ "$SERVICES_CONTENT" =~ action:[[:space:]]*\"?set-default\"? ]]; then
    echo "PASS: services-systemd sets default target to graphical"
else
    echo "[FAIL] services-systemd must set 'graphical.target' with action 'set-default' or it boots to tty1"; FAIL=1
fi
if [[ "$SERVICES_CONTENT" =~ name:[[:space:]]*\"?sddm\"? ]]; then
    echo "PASS: sddm display manager is enabled"
else
    echo "[FAIL] sddm is not enabled"; FAIL=1
fi

# Read script content once to avoid repeated fork/exec overhead for substring checks
SCRIPT_CONTENT=""
if [[ -f "$SCRIPT" ]]; then
    SCRIPT_CONTENT=$(<"$SCRIPT")
fi

# 2. Boot splash (reports/v2026.10.03 Q7): the NeOS logo with a pulsing
#    progress indicator and a disk-unlock prompt. It replaced the cartoon cat
#    loader at the maintainer's request.
for asset in logo.png dot.png; do
    if [[ -f "$THEME_DIR/$asset" ]]; then
        echo "PASS: theme ships $asset"
    else
        echo "[FAIL] theme is missing $asset"; FAIL=1
    fi
    if [[ "$SCRIPT_CONTENT" == *"\"$asset\""* ]]; then
        echo "PASS: neos.script uses $asset"
    else
        echo "[FAIL] neos.script does not load $asset"; FAIL=1
    fi
done
if [[ "$SCRIPT_CONTENT" == *'SetRefreshFunction'* ]]; then
    echo "PASS: progress indicator is animated"
else
    echo "[FAIL] neos.script has no refresh callback (static splash looks frozen)"; FAIL=1
fi
if [[ "$SCRIPT_CONTENT" == *'SetDisplayPasswordFunction'* ]]; then
    echo "PASS: disk-unlock prompt handled"
else
    echo "[FAIL] neos.script does not handle the LUKS passphrase prompt"; FAIL=1
fi
if find "$THEME_DIR" -maxdepth 1 -name 'cat-*.png' | grep -q . || [[ "$SCRIPT_CONTENT" == *'cat'*'.png'* ]]; then
    echo "[FAIL] retired cat loader assets are back"; FAIL=1
else
    echo "PASS: no cat loader assets"
fi
# Every image the script loads must exist in the theme directory.
while IFS= read -r img; do
    if [[ ! -f "$THEME_DIR/$img" ]]; then
        echo "[FAIL] neos.script loads $img, which the theme does not ship"; FAIL=1
    fi
done < <(grep -oE 'Image\("[^"]+"\)' "$SCRIPT" | sed -E 's/Image\("([^"]+)"\)/\1/')

# 3b. The KDE/Plasma login splash (ksplash) is disabled — the Plymouth splash
#     is the only boot screen users see.
KSPLASHRC="profile/airootfs/etc/skel/.config/ksplashrc"
KSPLASHRC_CONTENT=""
if [[ -f "$KSPLASHRC" ]]; then
    KSPLASHRC_CONTENT=$(<"$KSPLASHRC")
fi

if [[ -f "$KSPLASHRC" ]] && [[ "$KSPLASHRC_CONTENT" == *$'\nEngine=none'* || "$KSPLASHRC_CONTENT" == 'Engine=none'* ]] && [[ "$KSPLASHRC_CONTENT" == *$'\nTheme=None'* || "$KSPLASHRC_CONTENT" == 'Theme=None'* ]]; then
    echo "PASS: ksplash disabled via skel ksplashrc (no KDE boot screen)"
else
    echo "[FAIL] $KSPLASHRC missing or does not disable ksplash"; FAIL=1
fi

# 4. The old animated-spinner assets must stay gone.
if find "$THEME_DIR" -maxdepth 1 -name 'spinner-*.png' | grep -q .; then
    echo "[FAIL] stale spinner-*.png assets still present in the theme"; FAIL=1
else
    echo "PASS: stale spinner assets removed"
fi
if [[ "$SCRIPT_CONTENT" == *'spinner'* ]]; then
    echo "[FAIL] neos.script still references removed spinner frames"; FAIL=1
else
    echo "PASS: neos.script has no stale spinner references"
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Boot/GUI verification FAILED."
    exit 1
fi
echo "Boot/GUI verification passed!"
