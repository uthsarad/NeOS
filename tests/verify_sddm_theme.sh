#!/bin/bash
set -euo pipefail

echo "Verifying NeOS SDDM login theme..."

THEME_DIR="profile/airootfs/usr/share/sddm/themes/neos"
for f in Main.qml theme.conf metadata.desktop; do
    if [[ ! -f "$THEME_DIR/$f" ]]; then
        echo "FAIL: missing $THEME_DIR/$f"
        exit 1
    fi
done

if ! grep -qE "^MainScript=Main.qml" "$THEME_DIR/metadata.desktop"; then
    echo "FAIL: metadata.desktop must declare MainScript=Main.qml"
    exit 1
fi

# The greeter must actually select the NeOS theme.
THEME_CONF="profile/airootfs/etc/sddm.conf.d/20-theme.conf"
if [[ ! -f "$THEME_CONF" ]] || ! grep -qE "^Current=neos" "$THEME_CONF"; then
    echo "FAIL: $THEME_CONF must set Current=neos"
    exit 1
fi

# Software-render safety: the theme must not pull GPU-only effects that break
# the login screen in VMs without 3D (the greeter runs QT_QUICK_BACKEND=software).
if grep -qE "ShaderEffect|FastBlur|GaussianBlur|DropShadow" "$THEME_DIR/Main.qml"; then
    echo "FAIL: Main.qml uses a GPU-only effect; keep it software-render-safe"
    exit 1
fi

echo "PASS: SDDM theme present and selected."
