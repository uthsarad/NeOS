#!/bin/bash
# Verify the installed system boots into the GUI, and the boot splash is the
# cat-only loader with static body and animated tail.
#
# - tty1 regression: the netinstalled system landed on a text console because
#   nothing set its default systemd target. The services-systemd module must set
#   graphical.target so it boots into SDDM/Plasma.
# - Boot splash: the Plymouth 'neos' theme shows ONLY the animated cat-NN.png
#   loader, dead centre — no wordmark, no tagline, no dots, no status text.
#   The cat body is perfectly still; only the tail moves. Cat frames are
#   generated from tools/loader-cat.gif (committed; CI does not run generators).
#   Repeated still frames at the end of the source GIF are trimmed so the loop
#   does not pause.
# - No KDE splash: ksplash after SDDM login is disabled via skel ksplashrc so
#   the Plymouth cat is the only boot screen.
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

# 2. Boot-splash cat frames are present (29 frames) and wired into the script.
frames=$(find "$THEME_DIR" -maxdepth 1 -name 'cat-*.png' | wc -l)
if [[ "$frames" -eq 29 ]]; then
    echo "✅ 29 cat boot-splash frames present"
else
    echo "❌ expected 29 cat-NN.png frames, found $frames"; FAIL=1
fi
if grep -q 'cat-\"' "$SCRIPT" || grep -q '\"cat-' "$SCRIPT"; then
    echo "✅ neos.script animates the cat frames"
else
    echo "❌ neos.script does not reference the cat- frames"; FAIL=1
fi

# 3. The cat is the ONLY element on the boot splash — no logo, wordmark,
#    tagline, dots, or status text in the theme or the script.
if [[ -f "$THEME_DIR/logo.png" ]]; then
    echo "❌ theme still ships logo.png (boot splash must be cat-only)"; FAIL=1
else
    echo "✅ no logo.png in the theme (cat-only splash)"
fi
# No wordmark or brand text
if grep -qE '"NeOS"' "$SCRIPT"; then
    echo "❌ neos.script still shows the NeOS wordmark"; FAIL=1
else
    echo "✅ neos.script has no wordmark"
fi
# No tagline
if grep -qE '"Arch Linux' "$SCRIPT"; then
    echo "❌ neos.script still shows the tagline"; FAIL=1
else
    echo "✅ neos.script has no tagline"
fi
# No dot indicator
if grep -qE 'dot_' "$SCRIPT"; then
    echo "❌ neos.script still has dot indicator elements"; FAIL=1
else
    echo "✅ neos.script has no dot indicator"
fi
# No status text
if grep -qE 'Starting\.\.\.' "$SCRIPT"; then
    echo "❌ neos.script still has status text"; FAIL=1
else
    echo "✅ neos.script has no status text"
fi

# 3b. The KDE/Plasma login splash (ksplash) is disabled — the Plymouth cat is
#     the only boot screen users see.
KSPLASHRC="profile/airootfs/etc/skel/.config/ksplashrc"
if [[ -f "$KSPLASHRC" ]] && grep -q '^Engine=none' "$KSPLASHRC" && grep -q '^Theme=None' "$KSPLASHRC"; then
    echo "✅ ksplash disabled via skel ksplashrc (no KDE boot screen)"
else
    echo "❌ $KSPLASHRC missing or does not disable ksplash"; FAIL=1
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
