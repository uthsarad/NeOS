#!/bin/bash
set -euo pipefail

UNPACKFS_CONF="profile/airootfs/etc/calamares/modules/unpackfs.conf"

echo "Verifying unpackfs exclusion in $UNPACKFS_CONF..."

# Check if file exists
if [[ ! -f "$UNPACKFS_CONF" ]]; then
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

# Check for required 'sourcefs' key — without it Calamares unpackfs/main.py
# raises a KeyError and the install fails with "main.py ... raised an exception"
if grep -q "sourcefs:" "$UNPACKFS_CONF"; then
    echo "✅ 'sourcefs:' key found"
else
    echo "❌ 'sourcefs:' key NOT found (unpackfs job will raise an exception)"
    FAIL=1
fi

# Validate the sourcefs VALUE. Calamares unpackfs validates sourcefs against
# ["file"] + /proc/filesystems. "directory" is NOT valid and fails at the END
# of the install with "Bad unpackfs configuration ... not supported by your
# current kernel". Only "squashfs", "erofs", or "file" are meaningful here.
SOURCEFS_VALUE=$(grep -oP 'sourcefs:\s*"?\K[A-Za-z0-9]+' "$UNPACKFS_CONF" | head -1)
case "$SOURCEFS_VALUE" in
    squashfs|erofs|file)
        echo "✅ sourcefs value '$SOURCEFS_VALUE' is valid"
        ;;
    *)
        echo "❌ sourcefs value '$SOURCEFS_VALUE' is INVALID (must be squashfs/erofs/file, NOT 'directory')"
        FAIL=1
        ;;
esac

# When sourcefs is squashfs/erofs, source must point at the image FILE
# (loop-mounted), not the already-mounted /run/archiso/airootfs directory.
if [[ "$SOURCEFS_VALUE" == "squashfs" || "$SOURCEFS_VALUE" == "erofs" ]]; then
    if grep -qE 'source:\s*"[^"]*\.(sfs|erofs)"' "$UNPACKFS_CONF"; then
        echo "✅ source points at an image file"
    else
        echo "❌ sourcefs is '$SOURCEFS_VALUE' but source is not an image file (.sfs/.erofs)"
        FAIL=1
    fi
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

if (( ${FAIL:-0} == 1 )); then
    echo "Verification failed!"
    exit 1
fi

echo "Unpackfs exclusion verification passed!"
