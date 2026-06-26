#!/bin/bash
# Verify the installed system can never inherit the live autologin / empty
# password configuration.
#
# Under the netinstall model the target is a fresh pacstrap from the repos, not
# a copy of the live medium, so the live-only autologin drop-ins are never
# written to the target in the first place. This test guards that property:
# the installer must NOT clone the live root (no unpackfs), while the live
# session itself still autologins as the unprivileged 'liveuser'.
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
SDDM_AUTOLOGIN="profile/airootfs/etc/sddm.conf.d/autologin.conf"

echo "Verifying autologin cannot leak to the installed system..."

# 1. Installer must not clone the live filesystem (which is where the live
#    autologin drop-ins live). A fresh pacstrap cannot carry them over.
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "FAIL: installer still runs unpackfs (would clone live autologin to target)"
    exit 1
fi
echo "PASS: installer does not clone the live root (no unpackfs)"

if grep -q "shellprocess@pacstrap" "$SETTINGS"; then
    echo "PASS: installer pacstraps a fresh base (no live autologin present)"
else
    echo "FAIL: installer does not pacstrap a fresh base"
    exit 1
fi

# 2. The live session autologin must use the unprivileged liveuser (not root).
if grep -q "^User=liveuser$" "$SDDM_AUTOLOGIN"; then
    echo "PASS: live SDDM autologin user is liveuser in $SDDM_AUTOLOGIN"
else
    echo "FAIL: live SDDM autologin user is not liveuser in $SDDM_AUTOLOGIN"
    exit 1
fi

echo "Security verification passed!"
