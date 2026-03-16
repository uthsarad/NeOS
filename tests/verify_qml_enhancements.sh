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

# Read entire file into a variable to avoid repeated disk I/O and subprocesses
QML_CONTENT=$(<"$QML_FILE")

# Check for Space key binding
# Bolt: Replaced grep with native bash reading for faster match
if [[ "$QML_CONTENT" == *"Keys.onSpacePressed: presentation.advance()"* ]]; then
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
if [[ "$QML_CONTENT" == *"border.width: presentation.activeFocus"* ]]; then
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
if [[ "$QML_CONTENT" == *"text: \"⏸ \" + qsTr(\"Paused\")"* ]]; then
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
if [[ "$QML_CONTENT" == *"cursorShape: Qt.PointingHandCursor"* ]]; then
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
if [[ "$QML_CONTENT" == *"Accessible.role: Accessible.StaticText"* ]]; then
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
if [[ "$QML_CONTENT" == *"Accessible.role: Accessible.Button"* ]]; then
    echo "✅ Next Button accessibility role found."
else
    echo "❌ Next Button accessibility role missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.role: Accessible.Button' to ensure the element is recognized as a button by assistive technologies."
    exit 1
fi

if [[ "$QML_CONTENT" == *"Accessible.name: qsTr(\"Next Slide\")"* ]]; then
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
if [[ "$QML_CONTENT" == *"Behavior on scale"* ]]; then
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
if [[ "$QML_CONTENT" == *"property int pauseLocks: 0"* ]]; then
    echo "✅ Pause Locks property found."
else
    echo "❌ Pause Locks property missing!"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'property int pauseLocks: 0' to initialize the pause state management logic."
    exit 1
fi

if [[ "$QML_CONTENT" == *"presentation.pauseLocks++"* ]]; then
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
if [[ "$QML_CONTENT" == *"activeFocusOnTab: true"* ]]; then
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
if [[ "$QML_CONTENT" == *"border.color: \"#3daee9\""* ]]; then
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
if [[ "$QML_CONTENT" == *"Keys.onReturnPressed: presentation.advance()"* ]]; then
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
if [[ "$QML_CONTENT" == *"style: Text.Outline"* ]]; then
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
if [[ "$QML_CONTENT" == *"Keys.onLeftPressed: presentation.advance()"* ]]; then
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
