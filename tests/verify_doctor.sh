#!/bin/bash
set -euo pipefail

BIN="profile/airootfs/usr/local/bin/neos-doctor"
DESKTOP="profile/airootfs/usr/share/applications/neos-doctor.desktop"
PROFILE="profile/profiledef.sh"

echo "Verifying neos-doctor..."

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

if grep -q -- '--json' "$BIN"; then
    echo "  [PASS] supports --json for agents"
else
    echo "[FAIL] $BIN must support --json"
    FAIL=1
fi

if [[ -f "$DESKTOP" ]] && grep -q 'Exec=konsole -e /usr/local/bin/neos-doctor' "$DESKTOP"; then
    echo "  [PASS] desktop entry present"
else
    echo "[FAIL] $DESKTOP missing or wrong Exec"
    FAIL=1
fi

if grep -q 'neos-doctor' "$PROFILE"; then
    echo "  [PASS] profiledef.sh grants execute permission"
else
    echo "[FAIL] $PROFILE missing a permission entry for neos-doctor"
    FAIL=1
fi

# Running doctor here is fine: it is read-only diagnostics. --json must emit
# a single object even on a non-NeOS host (graphical.target will be inactive).
if command -v python3 >/dev/null 2>&1; then
    JSON="$("$BIN" --json || true)"
    if printf '%s' "$JSON" | python3 -c 'import json,sys; json.load(sys.stdin)'; then
        echo "  [PASS] --json emits valid JSON"
    else
        echo "[FAIL] --json did not emit valid JSON:"
        echo "$JSON"
        FAIL=1
    fi
else
    echo "  [INFO] python3 not available; skipped JSON parse check"
fi

if (( FAIL )); then
    echo "[FAIL] neos-doctor verification failed."
    exit 1
fi

echo "[PASS] neos-doctor verified."
