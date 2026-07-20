#!/bin/bash
set -e
echo "Testing Phase 6 UX Polish..."
grep -q "LookAndFeelPackage=org.kde.breezedark.desktop" profile/airootfs/etc/xdg/kdeglobals
grep -q "Show Desktop=Meta+D,Meta+D,Show Desktop" profile/airootfs/etc/xdg/kglobalshortcutsrc
grep -q "_launch=Meta+E,Meta+E,Dolphin" profile/airootfs/etc/xdg/kglobalshortcutsrc
echo "Phase 6 UX Polish tests passed."
