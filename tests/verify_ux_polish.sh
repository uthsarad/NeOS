#!/bin/bash
set -e
echo "Testing Phase 6 UX Polish..."
grep -q "LookAndFeelPackage=org.kde.breezedark.desktop" profile/airootfs/etc/xdg/kdeglobals

SHORTCUTS_CONTENT=$(<"profile/airootfs/etc/xdg/kglobalshortcutsrc")
if [[ "$SHORTCUTS_CONTENT" != *"Show Desktop=Meta+D,Meta+D,Show Desktop"* ]]; then
    echo "Error: Show Desktop shortcut missing"
    exit 1
fi
if [[ "$SHORTCUTS_CONTENT" != *"_launch=Meta+E,Meta+E,Dolphin"* ]]; then
    echo "Error: Dolphin shortcut missing"
    exit 1
fi
echo "Phase 6 UX Polish tests passed."
