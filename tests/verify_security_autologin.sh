#!/bin/bash
# Verify the installed-system login model.
#
# PRODUCT DECISION: The installed NeOS system asks the user for their
# username and password during installation, providing a public-ready
# multi-user experience like Ubuntu Desktop.
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
SDDM_AUTOLOGIN="profile/airootfs/etc/sddm.conf.d/autologin.conf"
FAIL=0

echo "Verifying installed-system login model (multi-user public OS)..."

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

# 2. The Calamares users page IS present so the user can configure their account.
if grep -qE '^\s*-\s*users\s*$' "$SETTINGS"; then
    echo "✅ Calamares 'users' module is in sequence (prompts for user/password)"
else
    echo "❌ Calamares 'users' module missing (no username/password prompt)"; FAIL=1
fi

# 3. The installer does NOT run the liveuser identity step on the installed system.
if grep -q "shellprocess@liveuser" "$SETTINGS"; then
    echo "❌ installer runs shellprocess@liveuser (kiosk mode left over)"; FAIL=1
else
    echo "✅ installer does not run shellprocess@liveuser"
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
