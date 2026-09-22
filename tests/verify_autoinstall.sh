#!/bin/bash
# Parser + wiring for the cidata autoinstall path.
set -euo pipefail

BIN="profile/airootfs/usr/local/bin/neos-autoinstall"
DESKTOP="profile/airootfs/etc/xdg/autostart/neos-autoinstall.desktop"
OVERLAY="profile/airootfs/etc/calamares/neos-overlay.txt"
PROFILE="profile/profiledef.sh"
WELCOME="profile/airootfs/usr/local/bin/neos-welcome"
WELCOME_APP="profile/airootfs/usr/local/bin/neos-welcome-app"
GEN="tools/gen-manifests.sh"

echo "Verifying cidata autoinstall..."

FAIL=0

if [[ -x "$BIN" ]]; then
    echo "  [PASS] $BIN is executable"
else
    echo "[FAIL] $BIN missing or not executable"
    FAIL=1
fi

if bash -n "$BIN"; then
    echo "  [PASS] $BIN parses"
else
    echo "[FAIL] $BIN has syntax errors"
    FAIL=1
fi

if [[ -f "$DESKTOP" ]] && grep -q 'Exec=/usr/local/bin/neos-autoinstall apply' "$DESKTOP"; then
    echo "  [PASS] live autostart launches neos-autoinstall apply"
else
    echo "[FAIL] $DESKTOP missing or does not run apply"
    FAIL=1
fi

if grep -q 'neos-autoinstall' "$PROFILE"; then
    echo "  [PASS] profiledef.sh grants execute permission"
else
    echo "[FAIL] $PROFILE missing a permission entry for neos-autoinstall"
    FAIL=1
fi

if grep -q 'neos-autoinstall' "$GEN"; then
    echo "  [PASS] gen-manifests.sh excludes the live-only autoinstall bits"
else
    echo "[FAIL] $GEN no longer excludes neos-autoinstall from the overlay"
    FAIL=1
fi

if [[ -f "$OVERLAY" ]]; then
    if grep -qE 'neos-autoinstall' "$OVERLAY"; then
        echo "[FAIL] overlay must not ship neos-autoinstall onto installed disks"
        FAIL=1
    else
        echo "  [PASS] overlay excludes neos-autoinstall"
    fi
fi

if grep -q -- '--unattended' "$WELCOME" && grep -q -- '--config' "$WELCOME"; then
    echo "  [PASS] neos-welcome accepts --unattended / --config"
else
    echo "[FAIL] $WELCOME must accept --unattended and --config"
    FAIL=1
fi

if grep -q 'neos-autoinstall' "$WELCOME_APP"; then
    echo "  [PASS] welcome app hands off to autoinstall"
else
    echo "[FAIL] $WELCOME_APP does not probe neos-autoinstall"
    FAIL=1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cat > "$WORKDIR/autoinstall.yaml" <<'EOF'
# sample
hostname: testhost
username: alice
fullname: Alice Example
password: secret12
locale: en_US
keyboard: us
timezone: UTC
erase: true
reboot: true
EOF

OUT="$("$BIN" parse "$WORKDIR")"
echo "$OUT"

for needle in \
    'hostname=testhost' \
    'username=alice' \
    'erase=1' \
    'MODE=UNATTENDED'; do
    if printf '%s\n' "$OUT" | grep -qxF "$needle"; then
        echo "  [PASS] parse: $needle"
    else
        echo "[FAIL] parse output missing '$needle'"
        FAIL=1
    fi
done

cat > "$WORKDIR/prefill.yaml" <<'EOF'
hostname: only-name
username: bob
erase: false
EOF

OUT2="$("$BIN" parse "$WORKDIR/prefill.yaml")"
if printf '%s\n' "$OUT2" | grep -qxF 'MODE=PREFILL'; then
    echo "  [PASS] parse: MODE=PREFILL without erase+password"
else
    echo "[FAIL] expected MODE=PREFILL for a partial config"
    echo "$OUT2"
    FAIL=1
fi

if (( FAIL )); then
    echo "[FAIL] Autoinstall verification failed."
    exit 1
fi

echo "[PASS] Autoinstall verified."
