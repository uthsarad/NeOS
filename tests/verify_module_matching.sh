#!/bin/bash
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-driver-manager"
if grep -q "\${mod/_/-}" "$SCRIPT"; then
    echo "[FAIL] Bug found: neos-driver-manager still uses \${mod/_/-}"
    # Return a non-zero status
    false
elif grep -q "\${mod//-/_}" "$SCRIPT"; then
    echo "[PASS] Fix verified: neos-driver-manager correctly uses \${mod//-/_}"
else
    echo "[FAIL] Bug not fixed properly in neos-driver-manager"
    # Return a non-zero status
    false
fi
