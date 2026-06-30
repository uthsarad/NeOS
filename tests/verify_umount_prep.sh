#!/bin/bash
# Verify the pre-umount /dev-tree cleanup step that works around the Calamares
# "Could not unmount target system." (/dev/pts) install failure.
#
# Background: /dev is bind-mounted from the shared live host, so the devpts
# stacked on target/dev/pts is detached by mount propagation before the C++
# `umount` module runs; `umount` then returns exit 32 ("not mounted") and the
# module aborts the whole (otherwise-successful) install. A host-side
# shellprocess (unmount-prep.conf) recursively/lazily unmounts the target /dev
# tree first, so umount only sees mounts that unmount cleanly.
#
# CI never performs a real install, so this guards the fix statically.
set -euo pipefail

CONF="profile/airootfs/etc/calamares/modules/unmount-prep.conf"
SETTINGS="profile/airootfs/etc/calamares/settings.conf"
FAIL=0

echo "Verifying pre-umount /dev cleanup step..."

# 1. The config file exists and runs on the host (not chrooted).
if [[ ! -f "$CONF" ]]; then
    echo "❌ $CONF missing"; FAIL=1
else
    if grep -qE "^dontChroot:[[:space:]]*true" "$CONF"; then
        echo "✅ unmount-prep.conf runs on the host (dontChroot: true)"
    else
        echo "❌ unmount-prep.conf must set 'dontChroot: true' (needs host mount namespace)"; FAIL=1
    fi
    # Must recursively unmount the target /dev subtree.
    if grep -qE "umount .*-R.*\\\$\{ROOT\}/dev" "$CONF"; then
        echo "✅ recursively unmounts \${ROOT}/dev"
    else
        echo "❌ unmount-prep.conf must run a recursive 'umount -R ... \${ROOT}/dev'"; FAIL=1
    fi
fi

# 2. settings.conf registers the instance.
if grep -qE "id:[[:space:]]*unmountprep" "$SETTINGS" \
   && grep -qE "config:[[:space:]]*unmount-prep.conf" "$SETTINGS"; then
    echo "✅ 'unmountprep' shellprocess instance registered"
else
    echo "❌ settings.conf missing 'unmountprep' instance (id + config: unmount-prep.conf)"; FAIL=1
fi

# 3. Sequence order: cleanup -> unmountprep -> umount (single awk pass).
if awk '
    /^[[:space:]]*-[[:space:]]*shellprocess@cleanup/     { c = NR }
    /^[[:space:]]*-[[:space:]]*shellprocess@unmountprep/ { p = NR }
    /^[[:space:]]*-[[:space:]]*umount[[:space:]]*$/      { u = NR }
    END { exit !(c && p && u && c < p && p < u) }
' "$SETTINGS"; then
    echo "✅ exec order: cleanup -> unmountprep -> umount"
else
    echo "❌ exec sequence must be cleanup -> shellprocess@unmountprep -> umount"; FAIL=1
fi

if [[ "$FAIL" -eq 0 ]]; then
    echo "PASS: pre-umount /dev cleanup step is configured correctly."
fi
exit "$FAIL"
