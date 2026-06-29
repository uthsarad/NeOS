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
if grep -q "User=liveuser" "$AUTOLOGIN" && grep -q "Session=plasmax11" "$AUTOLOGIN"; then
    echo "✅ SDDM autologin configured for liveuser / plasmax11"
else
    echo "❌ $AUTOLOGIN must set User=liveuser and Session=plasmax11"; FAIL=1
fi

# 4. neos-liveuser-setup.service must run before the display manager.
#    We use both the alias (display-manager.service) and the real unit name
#    (sddm.service) because the alias is only created by `systemctl enable`,
#    which archiso does not run; without sddm.service in Before=, the ordering
#    constraint is silently dropped and SDDM can start before liveuser exists.
SERVICE="$SYSDIR/neos-liveuser-setup.service"
if grep -q "Before=.*sddm\.service" "$SERVICE"; then
    echo "✅ neos-liveuser-setup.service runs Before=sddm.service"
else
    echo "❌ neos-liveuser-setup.service missing Before=sddm.service — liveuser may not exist when SDDM autologin fires"; FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Live graphical target verification FAILED."
    exit 1
fi
echo "Live graphical target verification passed!"
