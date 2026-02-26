#!/bin/bash
set -euo pipefail

UNPACKFS_CONF="airootfs/etc/calamares/modules/unpackfs.conf"

echo "Verifying unpackfs exclusion in $UNPACKFS_CONF..."

# Check if file exists
if [ ! -f "$UNPACKFS_CONF" ]; then
    echo "⚠️ $UNPACKFS_CONF not found! Skipping unpackfs checks as Calamares is not present."
    exit 0
fi

# Check for 'exclude' directive
if grep -q "exclude:" "$UNPACKFS_CONF"; then
    echo "✅ 'exclude:' directive found"
else
    echo "❌ 'exclude:' directive NOT found"
    FAIL=1
fi

# Check for zz-live-wheel exclusion
if grep -q "etc/sudoers.d/zz-live-wheel" "$UNPACKFS_CONF"; then
    echo "✅ etc/sudoers.d/zz-live-wheel exclusion found"
else
    echo "❌ etc/sudoers.d/zz-live-wheel exclusion NOT found"
    FAIL=1
fi

# Check for autologin.conf exclusion
if grep -q "etc/sddm.conf.d/autologin.conf" "$UNPACKFS_CONF"; then
    echo "✅ etc/sddm.conf.d/autologin.conf exclusion found"
else
    echo "❌ etc/sddm.conf.d/autologin.conf exclusion NOT found"
    FAIL=1
fi

if [ "${FAIL:-0}" -eq 1 ]; then
    echo "Verification failed!"
    exit 1
fi

echo "Unpackfs exclusion verification passed!"
