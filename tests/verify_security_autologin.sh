#!/bin/bash
set -euo pipefail

UNPACKFS_CONF="airootfs/etc/calamares/modules/unpackfs.conf"
SHELLPROCESS_CONF="airootfs/etc/calamares/modules/shellprocess.conf"
TARGET_FILE="etc/systemd/system/getty@tty1.service.d/autologin.conf"

echo "Verifying security configuration for autologin cleanup..."

# 1. Verify unpackfs exclusion
if grep -q "$TARGET_FILE" "$UNPACKFS_CONF"; then
    echo "PASS: $TARGET_FILE is excluded in $UNPACKFS_CONF"
else
    echo "FAIL: $TARGET_FILE is NOT excluded in $UNPACKFS_CONF"
    exit 1
fi

# 2. Verify shellprocess removal
# Note: shellprocess uses absolute path /etc/...
TARGET_FILE_ABS="/$TARGET_FILE"
if grep -q "rm -f $TARGET_FILE_ABS" "$SHELLPROCESS_CONF"; then
    echo "PASS: removal command for $TARGET_FILE_ABS found in $SHELLPROCESS_CONF"
else
    echo "FAIL: removal command for $TARGET_FILE_ABS NOT found in $SHELLPROCESS_CONF"
    exit 1
fi

# 3. Verify existence of the risk file
if [ -f "airootfs/$TARGET_FILE" ]; then
    echo "INFO: Vulnerable file exists in source (as expected): airootfs/$TARGET_FILE"
else
    echo "WARN: Vulnerable file NOT found in source. Is the fix necessary?"
fi

echo "Security verification passed!"
