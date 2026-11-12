#!/bin/bash
# Verify cross-module Snapper, pacman hook, Xfce Polkit, and rescue contracts.
set -euo pipefail

FAIL=0
pass() { echo "  [PASS] $1"; }
fail() { echo "[FAIL] $1"; FAIL=1; }

echo "Verifying Snapper, Xfce Polkit, and rescue shell contracts..."

SNAPPER_CONFD="profile/airootfs/etc/conf.d/snapper"
SNAPPER_ROOT="profile/airootfs/etc/snapper/configs/root"
PRE_HOOK="profile/airootfs/usr/share/neos/hooks/49-neos-snapshot-pre.hook"
POST_HOOK="profile/airootfs/usr/share/neos/hooks/99-neos-snapshot-post.hook"
AUTOUPDATE="profile/airootfs/usr/local/bin/neos-autoupdate.sh"
HUB="profile/airootfs/usr/local/bin/neos-operations-hub"

if [[ -f "$SNAPPER_CONFD" ]] && grep -q '^SNAPPER_CONFIGS="root"$' "$SNAPPER_CONFD"; then
    pass "etc/conf.d/snapper registers SNAPPER_CONFIGS=\"root\""
else
    fail "etc/conf.d/snapper missing or lacks SNAPPER_CONFIGS=\"root\""
fi

if [[ -f "$SNAPPER_ROOT" ]] && grep -q '^FSTYPE="btrfs"$' "$SNAPPER_ROOT" && grep -q '^SUBVOLUME="/"$' "$SNAPPER_ROOT"; then
    pass "etc/snapper/configs/root defines FSTYPE=\"btrfs\" and SUBVOLUME=\"/\""
else
    fail "etc/snapper/configs/root missing FSTYPE=\"btrfs\" or SUBVOLUME=\"/\""
fi

if grep -q -- '--type pre --columns' "$POST_HOOK"; then
    fail "99-neos-snapshot-post.hook uses invalid 'snapper list --type pre' flag"
else
    pass "99-neos-snapshot-post.hook avoids invalid 'snapper list --type pre'"
fi

if grep -q 'NEOS_AUTOUPDATE_ACTIVE' "$PRE_HOOK" \
   && grep -q 'NEOS_AUTOUPDATE_ACTIVE' "$POST_HOOK" \
   && grep -q 'NEOS_AUTOUPDATE_ACTIVE=1' "$AUTOUPDATE"; then
    pass "neos-autoupdate.sh and libalpm snapshot hooks coordinate via NEOS_AUTOUPDATE_ACTIVE"
else
    fail "Missing NEOS_AUTOUPDATE_ACTIVE deduplication between neos-autoupdate.sh and libalpm hooks"
fi

if grep -q 'if ! snapper --config=root list' "$HUB"; then
    pass "neos-operations-hub checks snapper exit status directly"
else
    fail "neos-operations-hub does not check snapper exit status directly"
fi

# Check Xfce Polkit authentication agent wiring
if [[ -x "profile/airootfs/usr/local/bin/neos-polkit-agent" ]] \
   && [[ -f "profile/airootfs/etc/xdg/autostart/neos-polkit-xfce.desktop" ]] \
   && grep -qx 'polkit-gnome' profile/packages.x86_64 \
   && grep -qx 'polkit-kde-agent' profile/packages.x86_64; then
    pass "Xfce and KDE Polkit authentication agents are wired and packaged"
else
    fail "Xfce/KDE Polkit agent wiring incomplete"
fi

# Check emergency & rescue sulogin unlock for locked root password
for unit in rescue emergency; do
    dropin="profile/airootfs/etc/systemd/system/${unit}.service.d/10-neos-sulogin.conf"
    if [[ -f "$dropin" ]] && grep -q '^Environment=SYSTEMD_SULOGIN_FORCE=1$' "$dropin"; then
        pass "${unit}.service drop-in sets SYSTEMD_SULOGIN_FORCE=1"
    else
        fail "${dropin} missing SYSTEMD_SULOGIN_FORCE=1"
    fi
done

if (( FAIL )); then
    echo "[FAIL] Contract verification failed."
    exit 1
fi
echo "[PASS] All Snapper, Xfce Polkit, and rescue contracts verified."
