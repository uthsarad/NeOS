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

# 4b. On Wayland (the NeOS default) KWin handles rotation and scaling; the
# autostarted daemon must exit cleanly instead of driving xrandr/xinput.
if XDG_SESSION_TYPE=wayland DISPLAY=":99" timeout 5 "$SCRIPT" --daemon >/dev/null 2>&1; then
    echo "  [PASS] $SCRIPT --daemon is a clean no-op in a Wayland session"
else
    echo "[FAIL] $SCRIPT --daemon does not exit cleanly in a Wayland session"
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

# Exercise real synchronization with XRandR output and a VirtualBox tablet.
# Supported rotations appear on every line and must not change a normal screen.
# The mocks below are called indirectly by the sourced sync functions.
# shellcheck disable=SC2317,SC2329
(
    export XDG_SESSION_TYPE=x11 DISPLAY=:99
    # shellcheck disable=SC1090
    source "$SCRIPT" --help >/dev/null
    xrandr() { printf '%s\n' "$fixture"; }
    xinput() {
        case "$1" in
            list) echo '↳ VirtualBox USB Tablet id=10 [slave pointer (2)]' ;;
            list-props) echo 'Coordinate Transformation Matrix' ;;
            set-prop) printf '%s\n' "${*:4}" ;;
        esac
    }
    supported='(normal left inverted right x axis y axis)'
    for rotation in normal left right inverted; do
        active="$rotation"
        [[ "$rotation" == normal ]] && active=''
        fixture="Virtual-1 connected primary 1920x1080+0+0 $active $supported"
        actual=$(sync_rotation)
        expected=$(get_matrix_for_rotation "$rotation")
        if ! grep -qxF -- "$expected" <<< "$actual"; then
            echo "[FAIL] wrong tablet matrix for $rotation: $actual"; exit 1
        fi
    done
    fixture=$(printf '%s\n' \
        "Virtual-2 connected 1080x1920+1920+0 left $supported" \
        "Virtual-1 connected primary 1920x1080+0+0 $supported")
    [[ "$(get_primary_rotation)" == normal ]]
    fixture=$(printf '%s\n' "Virtual-2 connected $supported" \
        "Virtual-1 connected 1920x1080-1920+0 right $supported")
    [[ "$(get_primary_rotation)" == right ]]
    echo '  [PASS] normal/rotated VirtualBox tablet matrices, primary and inactive outputs'
)

echo "All display & input sync verification checks passed!"
exit 0
