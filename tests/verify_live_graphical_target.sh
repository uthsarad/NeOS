#!/bin/bash
# Verify the LIVE environment is wired to boot into the graphical session.
# Without graphical.target.wants/sddm.service the system reaches graphical.target
# but never starts SDDM, so it silently falls back to the tty1 getty autologin.
set -euo pipefail

SYSDIR="profile/airootfs/etc/systemd/system"
FAIL=0

echo "Verifying live graphical boot wiring..."

# 1. graphical.target.wants/sddm.service must exist so SDDM is started
#    when the live system reaches graphical.target.
SDDM_WANT="$SYSDIR/graphical.target.wants/sddm.service"
if [[ -L "$SDDM_WANT" ]]; then
    target=$(readlink "$SDDM_WANT")
    echo "✅ graphical.target.wants/sddm.service -> $target"
else
    echo "❌ $SDDM_WANT missing — live ISO boots to TTY instead of SDDM"; FAIL=1
fi

# 2. default.target must point to graphical.target
DEFAULT="$SYSDIR/default.target"
if [[ -L "$DEFAULT" ]]; then
    target=$(readlink "$DEFAULT")
    if [[ "$target" == *"graphical.target" ]]; then
        echo "✅ default.target -> $target"
    else
        echo "❌ default.target points to '$target', must be graphical.target"; FAIL=1
    fi
else
    echo "❌ $DEFAULT missing — systemd falls back to compiled-in default (may vary)"; FAIL=1
fi

# 3. SDDM autologin must be configured for liveuser
AUTOLOGIN="profile/airootfs/etc/sddm.conf.d/autologin.conf"
if grep -q "User=liveuser" "$AUTOLOGIN" && grep -q "Session=plasma" "$AUTOLOGIN"; then
    echo "✅ SDDM autologin configured for liveuser / plasma"
else
    echo "❌ $AUTOLOGIN must set User=liveuser and Session=plasma"; FAIL=1
fi

# 4. customize_airootfs.sh must exist — this script pre-creates liveuser
#    inside the archiso chroot at build time so the user is baked into the
#    squashfs. Without it, liveuser must be created at runtime by
#    neos-liveuser-setup.service; any failure in that service leaves SDDM
#    with no autologin target and drops the live session to TTY.
CUSTOMIZE="profile/airootfs/root/customize_airootfs.sh"
if [[ -f "$CUSTOMIZE" ]] && grep -q "useradd" "$CUSTOMIZE" && grep -q "liveuser" "$CUSTOMIZE"; then
    echo "✅ customize_airootfs.sh present and creates liveuser at build time"
else
    echo "❌ $CUSTOMIZE missing or does not create liveuser — live session will be unreliable"; FAIL=1
fi

# 5. neos-liveuser-setup.service must run before the display manager.
SERVICE="$SYSDIR/neos-liveuser-setup.service"
if grep -q "Before=.*sddm\.service" "$SERVICE"; then
    echo "✅ neos-liveuser-setup.service runs Before=sddm.service"
else
    echo "❌ neos-liveuser-setup.service missing Before=sddm.service"; FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Live graphical target verification FAILED."
    exit 1
fi
echo "Live graphical target verification passed!"
