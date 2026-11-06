#!/bin/bash
# Verify the NeOS Welcome & Onboarding Application logic.
set -euo pipefail

WELCOME_APP="profile/airootfs/usr/local/bin/neos-welcome-app"
DESKTOP_SETUP="profile/airootfs/usr/local/bin/neos-desktop-setup"

echo "Verifying NeOS Welcome App & First-Boot Onboarding..."

# 1. Existence and syntax
if [[ ! -f "$WELCOME_APP" ]]; then
    echo "[FAIL] $WELCOME_APP missing"
    exit 1
fi

python3 -m py_compile "$WELCOME_APP"
echo "  [PASS] neos-welcome-app passes Python compilation"

# 2. Dual-mode support (Live ISO vs Installed System)
if grep -q "is_live_mode" "$WELCOME_APP"; then
    echo "  [PASS] contains is_live_mode detection logic"
else
    echo "[FAIL] missing is_live_mode detection"; exit 1
fi

# 3. Dynamic versioning (no hardcoded obsolete versions)
if grep -q "v2026.07" "$WELCOME_APP"; then
    echo "[FAIL] contains stale hardcoded version v2026.07"; exit 1
else
    echo "  [PASS] dynamic versioning configured (no stale v2026.07)"
fi

# 4. First-boot completion flag
if grep -q "firstboot-done" "$WELCOME_APP"; then
    echo "  [PASS] first-boot completion flag persistence configured"
else
    echo "[FAIL] missing firstboot-done handling"; exit 1
fi

# 5. Installed quick action handlers
for handler in launch_drivers launch_discover; do
    if grep -q "$handler" "$WELCOME_APP"; then
        echo "  [PASS] contains '$handler' action"
    else
        echo "[FAIL] missing action '$handler'"; exit 1
    fi
done

# 6. Flathub & Windows double-click configuration in desktop setup
if grep -q "flathub" "$DESKTOP_SETUP" && grep -q "SingleClick false" "$DESKTOP_SETUP"; then
    echo "  [PASS] neos-desktop-setup configures Flathub and double-click defaults"
else
    echo "[FAIL] neos-desktop-setup missing Flathub or double-click configuration"; exit 1
fi

echo "All Welcome App & First-Boot Onboarding checks passed!"

if python3 -c 'import PyQt6.QtWidgets' >/dev/null 2>&1; then
    python3 tests/welcome_installer_runtime.py
elif [[ "${REQUIRE_TOOLS:-0}" == 1 ]]; then
    echo '[FAIL] PyQt6 is required for installer lifecycle checks'; exit 1
else
    echo '[WARN] PyQt6 unavailable; skipping installer lifecycle checks'
fi
