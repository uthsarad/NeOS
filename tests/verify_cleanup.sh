#!/bin/bash
SHELLPROCESS_CONF="airootfs/etc/calamares/modules/shellprocess.conf"

echo "Verifying cleanup configuration in $SHELLPROCESS_CONF..."

# Check if removal of zz-live-wheel is present
if grep -q "rm -f /etc/sudoers.d/zz-live-wheel" "$SHELLPROCESS_CONF"; then
    echo "✅ rm -f /etc/sudoers.d/zz-live-wheel found"
    exit 0
else
    echo "❌ rm -f /etc/sudoers.d/zz-live-wheel NOT found"
    exit 1
fi
