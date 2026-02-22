#!/bin/bash
set -e

QML_FILE="airootfs/etc/calamares/branding/neos/show.qml"

echo "Verifying QML enhancements in $QML_FILE..."

if [ ! -f "$QML_FILE" ]; then
    echo "Error: QML file not found!"
    exit 1
fi

# Check for Space key binding
if grep -q "Keys.onSpacePressed: presentation.advance()" "$QML_FILE"; then
    echo "✅ Space key binding found."
else
    echo "❌ Space key binding missing!"
    exit 1
fi

# Check for Focus Border (checking one instance is enough to verify intent, but let's check count if possible, or just presence)
if grep -q "border.width: presentation.activeFocus" "$QML_FILE"; then
    echo "✅ Focus border logic found."
else
    echo "❌ Focus border logic missing!"
    exit 1
fi

# Check for Pause Indicator (enhanced)
if grep -q "text: \"⏸ \" + qsTr(\"Paused\")" "$QML_FILE"; then
    echo "✅ Enhanced Pause indicator found."
else
    echo "❌ Enhanced Pause indicator missing!"
    exit 1
fi

# Check for Cursor Shape
if grep -q "cursorShape: Qt.PointingHandCursor" "$QML_FILE"; then
    echo "✅ Cursor shape enhancement found."
else
    echo "❌ Cursor shape enhancement missing!"
    exit 1
fi

# Check for Accessibility Roles on new elements (optional but good)
if grep -q "Accessible.role: Accessible.StaticText" "$QML_FILE"; then
    echo "✅ Accessible roles found."
else
    echo "❌ Accessible roles missing!"
    exit 1
fi

# Check for Next Button Accessibility
if grep -q "Accessible.role: Accessible.Button" "$QML_FILE"; then
    echo "✅ Next Button accessibility role found."
else
    echo "❌ Next Button accessibility role missing!"
    exit 1
fi

if grep -q "Accessible.name: qsTr(\"Next Slide\")" "$QML_FILE"; then
    echo "✅ Next Button accessible name found."
else
    echo "❌ Next Button accessible name missing!"
    exit 1
fi

echo "All QML UX enhancements verified successfully!"
