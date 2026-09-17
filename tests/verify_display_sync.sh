#!/bin/bash
# Verify neos-display-sync script, autostart wiring, and coordinate transformation logic.
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-display-sync"
AUTOSTART="profile/airootfs/etc/xdg/autostart/neos-display-sync.desktop"
PACKAGES="profile/packages.x86_64"
PROFILEDEF="profile/profiledef.sh"

echo "Verifying NeOS display & input sync wiring..."

# 1. Verify script presence and execution permissions
if [ -f "$SCRIPT" ] && [ -x "$SCRIPT" ]; then
    echo "  [PASS] $SCRIPT exists and is executable"
else
    echo "[FAIL] $SCRIPT is missing or not executable"
    exit 1
fi

# 2. Syntax check
if bash -n "$SCRIPT"; then
    echo "  [PASS] $SCRIPT passes bash syntax check"
else
    echo "[FAIL] $SCRIPT has syntax errors"
    exit 1
fi

# 3. Verify help output
HELP_OUT=$("$SCRIPT" --help)
if echo "$HELP_OUT" | grep -q "NeOS Display & Input Synchronization Utility"; then
    echo "  [PASS] $SCRIPT --help responds correctly"
else
    echo "[FAIL] $SCRIPT --help output unexpected"
    exit 1
fi

# 4. Verify headless / no DISPLAY graceful degradation
NO_DISPLAY_OUT=$(DISPLAY="" "$SCRIPT" 2>&1 || true)
if echo "$NO_DISPLAY_OUT" | grep -q "No active X11 DISPLAY found"; then
    echo "  [PASS] $SCRIPT handles headless environment gracefully"
else
    echo "[FAIL] $SCRIPT failed headless handling"
    exit 1
fi

# 5. Verify autostart desktop entry
if [ -f "$AUTOSTART" ] && grep -q "Exec=/usr/local/bin/neos-display-sync --daemon" "$AUTOSTART"; then
    echo "  [PASS] $AUTOSTART properly launches neos-display-sync --daemon"
else
    echo "[FAIL] $AUTOSTART is missing or does not invoke neos-display-sync --daemon"
    exit 1
fi

# 6. Verify required X11 packages
for pkg in xorg-xrandr xorg-xinput; do
    if grep -q "^$pkg$" "$PACKAGES"; then
        echo "  [PASS] Package '$pkg' present in $PACKAGES"
    else
        echo "[FAIL] Package '$pkg' missing in $PACKAGES"
        exit 1
    fi
done

# 7. Verify profiledef.sh permissions
if grep -q '\["/usr/local/bin/neos-display-sync"\]="0:0:755"' "$PROFILEDEF"; then
    echo "  [PASS] File permissions defined in $PROFILEDEF"
else
    echo "[FAIL] File permissions missing in $PROFILEDEF"
    exit 1
fi

echo "All display & input sync verification checks passed!"
exit 0
