#!/bin/bash
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-driver-manager"
if grep -q "\${mod/_/-}" "$SCRIPT"; then
    echo "❌ Bug found: neos-driver-manager still uses \${mod/_/-}"
    # Return a non-zero status
    false
elif grep -q "\${mod//-/_}" "$SCRIPT"; then
    echo "✅ Fix verified: neos-driver-manager correctly uses \${mod//-/_}"
else
    echo "❌ Bug not fixed properly in neos-driver-manager"
    # Return a non-zero status
    false
fi
