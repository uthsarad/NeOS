#!/bin/bash
# Guards the wiring that makes boot verification real rather than decorative.
#
# tests/verify_iso_smoketest.sh only passes when the live session reports an
# active graphical.target (marker) and the framebuffer is not blank. That is
# only possible if:
#   - the probe unit exists, is pulled in by graphical.target and emits exactly
#     the marker the smoke test greps for,
#   - the live ISO kernel command line points at a serial console the test can
#     capture (otherwise the guest log is empty and panic detection is vacuous),
#   - the probe never reaches an installed system.
#
# Without this test a future edit could quietly re-open the hole that
# reports/v2026.09.18 H4 describes (timeout treated as a pass).
set -euo pipefail

PROBE_UNIT="profile/airootfs/etc/systemd/system/neos-boot-probe.service"
PROBE_WANTS="profile/airootfs/etc/systemd/system/graphical.target.wants/neos-boot-probe.service"
SMOKETEST="tests/verify_iso_smoketest.sh"
SYSLINUX_CFG="profile/syslinux/archiso_sys.cfg"
GRUB_CFG="profile/grub/grub.cfg"
OVERLAY="profile/airootfs/etc/calamares/neos-overlay.txt"

echo "Verifying boot-evidence wiring..."

FAIL=0

# 1. Marker contract: the smoke test must grep for the exact string the unit
#    writes to the serial console.
MARKER_LINE=$(grep -oE 'printf "[^"]*NEOS-BOOT-OK[^"]*"' "$PROBE_UNIT" | head -1 \
    | sed -e 's/^printf "//' -e 's/"$//' -e 's/\\n//g')
MARKER_FROM_UNIT="${MARKER_LINE%% *}"
MARKER_FROM_TEST=$(grep -oE '^MARKER="[^"]*"' "$SMOKETEST" | head -1 | sed -e 's/^MARKER="//' -e 's/"$//')

if [[ -z "$MARKER_FROM_UNIT" ]]; then
    echo "[FAIL] $PROBE_UNIT does not printf a NEOS-BOOT-OK marker"
    FAIL=1
elif [[ -z "$MARKER_FROM_TEST" ]]; then
    echo "[FAIL] $SMOKETEST no longer defines a MARKER to grep the guest log for"
    FAIL=1
elif [[ "$MARKER_FROM_UNIT" != "$MARKER_FROM_TEST" ]]; then
    echo "[FAIL] Marker strings diverged: unit='$MARKER_FROM_UNIT' smoke test='$MARKER_FROM_TEST'"
    FAIL=1
else
    echo "  [PASS] smoke test and probe unit share the '$MARKER_FROM_TEST' marker"
fi

# 2. The unit must only fire once graphical.target is active, and must be
#    pulled in by it (a unit nothing wants never runs).
for needle in "After=graphical.target" "WantedBy=graphical.target" "is-active --quiet graphical.target" "/dev/ttyS0"; do
    if grep -qF -- "$needle" "$PROBE_UNIT"; then
        echo "  [PASS] $PROBE_UNIT declares '$needle'"
    else
        echo "[FAIL] $PROBE_UNIT is missing '$needle'"
        FAIL=1
    fi
done

if [[ -L "$PROBE_WANTS" ]]; then
    echo "  [PASS] probe unit is enabled for graphical.target"
else
    echo "[FAIL] Missing enablement symlink: $PROBE_WANTS"
    FAIL=1
fi

# 3. Serial console on every live ISO boot entry, so the smoke test actually
#    receives guest output (BIOS/syslinux and UEFI/GRUB paths alike).
for cfg in "$SYSLINUX_CFG" "$GRUB_CFG"; do
    ENTRIES=$(grep -cE '^(APPEND|    linux) .*(archisobasedir=)' "$cfg" || true)
    WITH_CONSOLE=$(grep -cE '^(APPEND|    linux) .*archisobasedir=.*console=ttyS0' "$cfg" || true)
    if (( ENTRIES > 0 && ENTRIES == WITH_CONSOLE )); then
        echo "  [PASS] $cfg: all $ENTRIES boot entries pass console=ttyS0"
    else
        echo "[FAIL] $cfg: $WITH_CONSOLE/$ENTRIES boot entries pass console=ttyS0"
        FAIL=1
    fi
done

# 4. The probe is live-media-only: it must be excluded from the installed-system
#    overlay manifest (a serial marker has no business on an installed disk).
if [[ -f "$OVERLAY" ]]; then
    if grep -q '^etc/systemd/system/neos-boot-probe\.service$' "$OVERLAY"; then
        echo "[FAIL] neos-boot-probe.service is listed in the installed-system overlay manifest"
        FAIL=1
    else
        echo "  [PASS] probe unit is excluded from the installed-system overlay"
    fi
fi

if grep -q 'neos-boot-probe' tools/gen-manifests.sh; then
    echo "  [PASS] gen-manifests.sh excludes the probe from the installed overlay"
else
    echo "[FAIL] tools/gen-manifests.sh no longer excludes neos-boot-probe.service"
    FAIL=1
fi

if (( FAIL )); then
    echo "[FAIL] Boot-evidence wiring is broken."
    exit 1
fi

echo "[PASS] Boot-evidence wiring verified."
