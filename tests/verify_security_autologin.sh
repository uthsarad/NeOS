#!/bin/bash
# Verify the installed-system login model.
#
# PRODUCT DECISION (full live parity): the installed NeOS system intentionally
# mirrors the live ISO — it autologins a passwordless 'liveuser' straight into
# Plasma, instead of asking for a username/password. This is a deliberate
# kiosk-style choice, NOT the hardened multi-user model. This test guards that
# the wiring for that decision is intact (and that the live session itself still
# uses the unprivileged liveuser).
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
SDDM_AUTOLOGIN="profile/airootfs/etc/sddm.conf.d/autologin.conf"
IDENTITY="profile/airootfs/usr/local/bin/neos-install-identity"
FAIL=0

echo "Verifying installed-system login model (liveuser parity)..."

# 1. The installer pacstraps a fresh base (it must NOT clone the live squashfs).
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "❌ installer still runs unpackfs (live clone)"; FAIL=1
else
    echo "✅ no unpackfs (fresh pacstrap)"
fi
if grep -q "shellprocess@pacstrap" "$SETTINGS"; then
    echo "✅ installer pacstraps a fresh base"
else
    echo "❌ installer does not pacstrap a fresh base"; FAIL=1
fi

# 2. The Calamares users page is removed (no username/password is asked).
if grep -qE '^\s*-\s*users\s*$' "$SETTINGS"; then
    echo "❌ Calamares 'users' module still in sequence (would prompt for a user)"; FAIL=1
else
    echo "✅ Calamares users page removed (no username/password prompt)"
fi

# 3. The installer runs the liveuser identity step, which sets up the
#    passwordless autologin user on the target.
if grep -q "shellprocess@liveuser" "$SETTINGS"; then
    echo "✅ installer runs shellprocess@liveuser"
else
    echo "❌ installer does not run shellprocess@liveuser"; FAIL=1
fi
if [[ -f "$IDENTITY" ]] \
   && grep -q 'USERNAME="liveuser"' "$IDENTITY" \
   && grep -q "useradd" "$IDENTITY" \
   && grep -q "passwd -d" "$IDENTITY" \
   && grep -q "autologin.conf" "$IDENTITY" \
   && grep -q "NOPASSWD" "$IDENTITY"; then
    echo "✅ neos-install-identity creates a passwordless liveuser with autologin + sudo"
else
    echo "❌ neos-install-identity missing/incomplete (liveuser/passwd/autologin/NOPASSWD)"; FAIL=1
fi

# 4. The live session autologin still uses the unprivileged liveuser (not root).
if grep -q "^User=liveuser$" "$SDDM_AUTOLOGIN"; then
    echo "✅ live SDDM autologin user is liveuser"
else
    echo "❌ live SDDM autologin user is not liveuser"; FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Login-model verification FAILED."
    exit 1
fi
echo "Login-model verification passed!"
