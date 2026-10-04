#!/bin/bash
# Verify the installed system boots into the GUI, and the boot splash is the
<<<<<<< HEAD
# NeOS logo with a pulsing progress indicator.
=======
# cat-only loader with static body and animated tail.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
#
# - tty1 regression: the netinstalled system landed on a text console because
#   nothing set its default systemd target. The services-systemd module must set
#   graphical.target so it boots into SDDM/Plasma.
<<<<<<< HEAD
# - Boot splash: the Plymouth 'neos' theme shows the logo (logo.png from
#   tools/gen-logo.py --all) with three pulsing dots (dot.png from
#   tools/gen-brand-images.py) and handles the disk-unlock prompt.
# - No KDE splash: ksplash after SDDM login is disabled via skel ksplashrc so
#   the Plymouth splash is the only boot screen.
=======
# - Boot splash: the Plymouth 'neos' theme shows ONLY a single still cat-00.png
#   loader image, dead centre — no wordmark, no tagline, no dots, no status
#   text, no animation. The cat-NN.png frame set is generated from
#   tools/loader-cat.gif (committed; CI does not run generators) and kept as
#   source material even though only frame 00 is wired into the script.
# - No KDE splash: ksplash after SDDM login is disabled via skel ksplashrc so
#   the Plymouth cat is the only boot screen.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
set -euo pipefail

SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
THEME_DIR="profile/airootfs/usr/share/plymouth/themes/neos"
SCRIPT="$THEME_DIR/neos.script"
FAIL=0

<<<<<<< HEAD
echo "Verifying graphical boot target + boot splash..."
=======
echo "Verifying graphical boot target + boot-logo cat..."
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)

# 1. Installed system defaults to graphical.target (fixes boot-to-tty1).
SERVICES_CONTENT=""
if [[ -f "$SERVICES" ]]; then
    SERVICES_CONTENT=$(<"$SERVICES")
fi

<<<<<<< HEAD
if [[ "$SERVICES_CONTENT" =~ (^|$'\n')[[:space:]]*units: ]] && [[ "$SERVICES_CONTENT" =~ name:[[:space:]]*\"?graphical(\.target)?\"? ]] && [[ "$SERVICES_CONTENT" =~ action:[[:space:]]*\"?set-default\"? ]]; then
    echo "PASS: services-systemd sets default target to graphical"
else
    echo "[FAIL] services-systemd must set 'graphical.target' with action 'set-default' or it boots to tty1"; FAIL=1
=======
if [[ "$SERVICES_CONTENT" =~ (^|$'\n')[[:space:]]*targets: ]] && [[ "$SERVICES_CONTENT" =~ name:[[:space:]]*\"?graphical\"? ]]; then
    echo "PASS: services-systemd sets default target to graphical"
else
    echo "[FAIL] services-systemd must set 'targets: [graphical]' or it boots to tty1"; FAIL=1
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
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

<<<<<<< HEAD
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
=======
# 2. Boot-splash cat source frames are present (29 frames) and cat-00 is
#    wired into the script as the single still image.
frames=$(find "$THEME_DIR" -maxdepth 1 -name 'cat-*.png' | wc -l)
if [[ "$frames" -eq 29 ]]; then
    echo "PASS: 29 cat source frames present"
else
    echo "[FAIL] expected 29 cat-NN.png frames, found $frames"; FAIL=1
fi
if [[ "$SCRIPT_CONTENT" == *'"cat-00.png"'* ]]; then
    echo "PASS: neos.script shows the still cat-00 frame"
else
    echo "[FAIL] neos.script does not reference cat-00.png"; FAIL=1
fi
if [[ "$SCRIPT_CONTENT" == *'SetRefreshFunction'* ]]; then
    echo "[FAIL] neos.script still animates the cat (SetRefreshFunction present)"; FAIL=1
else
    echo "PASS: neos.script has no cat animation"
fi

# 3. The cat is the ONLY element on the boot splash — no logo, wordmark,
#    tagline, dots, or status text in the theme or the script.
if [[ -f "$THEME_DIR/logo.png" ]]; then
    echo "[FAIL] theme still ships logo.png (boot splash must be cat-only)"; FAIL=1
else
    echo "PASS: no logo.png in the theme (cat-only splash)"
fi
# No wordmark or brand text
if [[ "$SCRIPT_CONTENT" == *'"NeOS"'* ]]; then
    echo "[FAIL] neos.script still shows the NeOS wordmark"; FAIL=1
else
    echo "PASS: neos.script has no wordmark"
fi
# No tagline
if [[ "$SCRIPT_CONTENT" == *'"Arch Linux'* ]]; then
    echo "[FAIL] neos.script still shows the tagline"; FAIL=1
else
    echo "PASS: neos.script has no tagline"
fi
# No dot indicator
if [[ "$SCRIPT_CONTENT" == *'dot_'* ]]; then
    echo "[FAIL] neos.script still has dot indicator elements"; FAIL=1
else
    echo "PASS: neos.script has no dot indicator"
fi
# No status text
if [[ "$SCRIPT_CONTENT" == *'Starting...'* ]]; then
    echo "[FAIL] neos.script still has status text"; FAIL=1
else
    echo "PASS: neos.script has no status text"
fi

# 3b. The KDE/Plasma login splash (ksplash) is disabled — the Plymouth cat is
#     the only boot screen users see.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
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

<<<<<<< HEAD
# 4. The old animated-spinner assets must stay gone.
=======
# 4. The old animated-spinner assets must stay gone (replaced by the cat loader).
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
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
