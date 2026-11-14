#!/bin/bash
# Verifies the BitTorrent generator script and workflow integration.
set -euo pipefail

echo "Verifying NeOS BitTorrent generator..."

SCRIPT="tools/gen-torrent.sh"
WORKFLOW=".github/workflows/build-iso.yml"

# 1. Verify script presence and syntax
if [[ ! -f "$SCRIPT" ]]; then
    echo "[FAIL] Error: $SCRIPT is missing."
    exit 1
fi
echo "[PASS] $SCRIPT exists."

if ! bash -n "$SCRIPT"; then
    echo "[FAIL] Error: $SCRIPT contains syntax errors."
    exit 1
fi
echo "[PASS] $SCRIPT syntax is valid."

# 2. Verify workflow references
if ! grep -q "tools/gen-torrent.sh" "$WORKFLOW"; then
    echo "[FAIL] Error: $WORKFLOW does not call $SCRIPT."
    exit 1
fi
echo "[PASS] $WORKFLOW references $SCRIPT."

if ! grep -q "mktorrent" "$WORKFLOW"; then
    echo "[FAIL] Error: $WORKFLOW does not install mktorrent."
    exit 1
fi
echo "[PASS] $WORKFLOW includes mktorrent dependency."

# 3. Functional test if mktorrent is installed
if command -v mktorrent >/dev/null 2>&1; then
    echo "Testing torrent generation with mktorrent..."
    TMP_DIR=$(mktemp -d /tmp/neos-torrent-test.XXXXXX)
    cleanup() { rm -rf "$TMP_DIR"; }
    trap cleanup EXIT

    # Create dummy 1MB file disguised as an ISO
    DUMMY_ISO="$TMP_DIR/neos-test-x86_64.iso"
    head -c 1048576 </dev/zero > "$DUMMY_ISO"

    bash "$SCRIPT" "$TMP_DIR" >/dev/null

    if [[ ! -s "${DUMMY_ISO}.torrent" ]]; then
        echo "[FAIL] Error: Torrent file was not generated or is empty."
        exit 1
    fi
    echo "[PASS] Torrent generation successfully verified with mock ISO."
else
    echo "[INFO] mktorrent not installed on current host — functional generation skipped."
fi

echo "All BitTorrent generator checks passed!"
