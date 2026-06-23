#!/bin/bash
set -euo pipefail

# Verify that the Calamares binary in the freshly-built airootfs has every shared
# library resolved, and can at least print its version. This runs AFTER the
# airootfs is assembled (it inspects work/<arch>/airootfs) and is the guard that
# would have caught the libyaml-cpp.so.0.8 soname break that shipped a broken
# installer: a build that produces an unrunnable Calamares now FAILS instead of
# publishing a release.
#
# Skipped gracefully when there is no built airootfs or insufficient privileges
# (e.g. during the static pre-build test pass), unless REQUIRE_ISO=1.

skip_or_fail() {
    local msg="$1"
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "❌ $msg"
        exit 1
    fi
    echo "⏭️  SKIPPED: $msg"
    exit 0
}

AIROOTFS=""
for d in work/x86_64/airootfs work/*/airootfs; do
    if [[ -d "$d" ]]; then
        AIROOTFS="$d"
        break
    fi
done

[[ -n "$AIROOTFS" ]] || skip_or_fail "no built airootfs found (expected work/<arch>/airootfs); run during ISO build"

CALA_REL="usr/bin/calamares"
if [[ ! -x "$AIROOTFS/$CALA_REL" ]]; then
    echo "❌ Calamares binary not found at $AIROOTFS/$CALA_REL"
    echo "   The installer would be missing entirely on the live ISO."
    exit 1
fi

if ! command -v arch-chroot >/dev/null 2>&1 || [[ "$(id -u)" -ne 0 ]]; then
    skip_or_fail "need root + arch-chroot to inspect the target rootfs"
fi

echo "Checking Calamares shared libraries in $AIROOTFS ..."
MISSING="$(arch-chroot "$AIROOTFS" ldd "/$CALA_REL" 2>/dev/null | grep -i 'not found' || true)"
if [[ -n "$MISSING" ]]; then
    echo "❌ Calamares has unresolved shared libraries:"
    echo "$MISSING"
    echo "   This means the installer will fail to start (exit 127) on the live ISO."
    echo "   Most likely a soname bump in a dependency (e.g. yaml-cpp); update the"
    echo "   Calamares package source so it is rebuilt against current libraries."
    exit 1
fi
echo "✅ All Calamares shared libraries resolve."

if arch-chroot "$AIROOTFS" calamares --version >/dev/null 2>&1; then
    echo "✅ 'calamares --version' runs in the target rootfs."
else
    echo "❌ 'calamares --version' failed inside the target rootfs."
    echo "   Calamares is installed but cannot execute; the installer is broken."
    exit 1
fi

echo "Calamares runtime check passed!"
