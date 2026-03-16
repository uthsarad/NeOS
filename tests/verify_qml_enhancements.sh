#!/bin/bash
set -e

# Wrapper to ensure script does not block indefinitely
if [ "$1" != "--wrapped" ]; then
    timeout 60s bash "$0" --wrapped "$@" || { exit_code=$?; echo "⚠️ $0 failed or timed out"; exit $exit_code; }
    exit 0
fi
shift

QML_FILE="airootfs/etc/calamares/branding/neos/show.qml"

echo "Verifying QML enhancements in $QML_FILE..."

if [ ! -f "$QML_FILE" ]; then
    echo "⚠️ QML file not found! Skipping QML checks as Calamares is not present."
    exit 0
fi

# Check for Space key binding
# Bolt: Consider replacing grep with native bash reading or a faster match if file is large.
if grep -q "Keys.onSpacePressed: presentation.advance()" "$QML_FILE"; then
    echo "✅ Space key binding found."
else
    echo "❌ Space key binding missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onSpacePressed: presentation.advance()' to enable keyboard navigation via the Space key."
    exit 1
fi

# Check for Focus Border (checking one instance is enough to verify intent, but let's check count if possible, or just presence)
if grep -q "border.width: presentation.activeFocus" "$QML_FILE"; then
    echo "✅ Focus border logic found (Slide Background)."
else
    echo "❌ Focus border logic missing (Slide Background)!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'border.width: presentation.activeFocus' to provide visual feedback for keyboard focus."
    exit 1
fi

# Check for Pause Indicator (enhanced)
if grep -q "text: \"⏸ \" + qsTr(\"Paused\")" "$QML_FILE"; then
    echo "✅ Enhanced Pause indicator found."
else
    echo "❌ Enhanced Pause indicator missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'text: \"⏸ \" + qsTr(\"Paused\")' to clearly indicate the paused state."
    exit 1
fi

# Check for Cursor Shape
if grep -q "cursorShape: Qt.PointingHandCursor" "$QML_FILE"; then
    echo "✅ Cursor shape enhancement found."
else
    echo "❌ Cursor shape enhancement missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'cursorShape: Qt.PointingHandCursor' to signal interactivity on hover."
    exit 1
fi

# Check for Accessibility Roles on new elements (optional but good)
if grep -q "Accessible.role: Accessible.StaticText" "$QML_FILE"; then
    echo "✅ Accessible roles found."
else
    echo "❌ Accessible roles missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.role: Accessible.StaticText' to improve screen reader compatibility."
    exit 1
fi

# Check for Next Button Accessibility
if grep -q "Accessible.role: Accessible.Button" "$QML_FILE"; then
    echo "✅ Next Button accessibility role found."
else
    echo "❌ Next Button accessibility role missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.role: Accessible.Button' to ensure the element is recognized as a button by assistive technologies."
    exit 1
fi

if grep -q "Accessible.name: qsTr(\"Next Slide\")" "$QML_FILE"; then
    echo "✅ Next Button accessible name found."
else
    echo "❌ Next Button accessible name missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.name: qsTr(\"Next Slide\")' to provide a descriptive name for screen readers."
    exit 1
fi

# Check for Scale Animation
if grep -q "Behavior on scale" "$QML_FILE"; then
    echo "✅ Scale animation found."
else
    echo "❌ Scale animation missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Behavior on scale' to create smooth visual transitions."
    exit 1
fi

# --- NEW CHECKS ---

# Check for Pause Locks Logic
if grep -q "property int pauseLocks: 0" "$QML_FILE"; then
    echo "✅ Pause Locks property found."
else
    echo "❌ Pause Locks property missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'property int pauseLocks: 0' to initialize the pause state management logic."
    exit 1
fi

if grep -q "presentation.pauseLocks++" "$QML_FILE"; then
    echo "✅ Pause Locks increment logic found."
else
    echo "❌ Pause Locks increment logic missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'presentation.pauseLocks++' to increment the pause lock counter."
    exit 1
fi

# Check for Keyboard Focus Enablement
if grep -q "activeFocusOnTab: true" "$QML_FILE"; then
    echo "✅ Keyboard focus enabled (activeFocusOnTab) found."
else
    echo "❌ Keyboard focus enabled (activeFocusOnTab) missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'activeFocusOnTab: true' to allow keyboard users to focus the element via the Tab key."
    exit 1
fi

# Check for Visual Focus Indicator on Button
if grep -q "border.color: \"#3daee9\"" "$QML_FILE"; then
    echo "✅ Visual focus indicator (blue border) found."
else
    echo "❌ Visual focus indicator (blue border) missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'border.color: \"#3daee9\"' to provide a clear visual indicator when the element has focus."
    exit 1
fi

# Check for Keyboard Activation
if grep -q "Keys.onReturnPressed: presentation.advance()" "$QML_FILE"; then
    echo "✅ Return key activation found."
else
    echo "❌ Return key activation missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onReturnPressed: presentation.advance()' to allow activation via the Return key."
    exit 1
fi

# Check for Text Outline (Readability enhancement)
if grep -q "style: Text.Outline" "$QML_FILE"; then
    echo "✅ Text Outline style found."
else
    echo "❌ Text Outline style missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'style: Text.Outline' to improve text readability against varying backgrounds."
    exit 1
fi

# Check for Left Arrow Navigation
if grep -q "Keys.onLeftPressed: presentation.advance()" "$QML_FILE"; then
    echo "✅ Left Arrow navigation binding found."
else
    echo "❌ Left Arrow navigation binding missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onLeftPressed: presentation.advance()' to enable backwards navigation."
    exit 1
fi

echo "All QML UX enhancements verified successfully!"
