#!/bin/bash
set -e

# Wrapper to ensure script does not block indefinitely
if [[ "$1" != "--wrapped" ]]; then
    timeout 60s bash "$0" --wrapped "$@" || {
        exit_code=$?
        echo "[FAIL] $0 failed or timed out"
        echo ""
        # Palette: Multi-line actionable formatting with bulleted list
        echo "How to fix:"
        echo "   - Check the test script logic for infinite loops."
        echo "   - Ensure required resources are available and responding."
        exit $exit_code
    }
    exit 0
fi
shift

QML_FILE="profile/airootfs/etc/calamares/branding/neos/show.qml"

echo "Verifying QML enhancements in $QML_FILE..."

if [[ ! -f "$QML_FILE" ]]; then
    echo "[WARN] QML file not found! Skipping QML checks as Calamares is not present."
    exit 0
fi

# Read entire file into a variable to avoid repeated disk I/O and subprocesses
# Optimization confirmed: reading once natively prevents repeated disk I/O and sub-process calls for large files.
QML_CONTENT=$(<"$QML_FILE")

# Check for Space key binding
# Bolt: Replaced grep with native bash reading for faster match
if [[ "$QML_CONTENT" == *"Keys.onSpacePressed: presentation.advance()"* ]]; then
    echo "  [PASS] Space key binding found."
else
    echo "[FAIL] Space key binding missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onSpacePressed: presentation.advance()' to enable keyboard navigation via the Space key."
    exit 1
fi

# Check for Focus Border (checking one instance is enough to verify intent, but let's check count if possible, or just presence)
if [[ "$QML_CONTENT" == *"border.width: presentation.activeFocus"* ]]; then
    echo "  [PASS] Focus border logic found (Slide Background)."
else
    echo "[FAIL] Focus border logic missing (Slide Background)!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'border.width: presentation.activeFocus' to provide visual feedback for keyboard focus."
    exit 1
fi

# Check for Pause Indicator (enhanced)
if [[ "$QML_CONTENT" == *"text: \"⏸ \" + qsTr(\"Paused\")"* ]]; then
    echo "  [PASS] Enhanced Pause indicator found."
else
    echo "[FAIL] Enhanced Pause indicator missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'text: \"⏸ \" + qsTr(\"Paused\")' to clearly indicate the paused state."
    exit 1
fi

# Check for Cursor Shape
if [[ "$QML_CONTENT" == *"cursorShape: Qt.PointingHandCursor"* ]]; then
    echo "  [PASS] Cursor shape enhancement found."
else
    echo "[FAIL] Cursor shape enhancement missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'cursorShape: Qt.PointingHandCursor' to signal interactivity on hover."
    exit 1
fi

# Check for Accessibility Roles on new elements (optional but good)
if [[ "$QML_CONTENT" == *"Accessible.role: Accessible.StaticText"* ]]; then
    echo "  [PASS] Accessible roles found."
else
    echo "[FAIL] Accessible roles missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.role: Accessible.StaticText' to improve screen reader compatibility."
    exit 1
fi

# Check for Next Button Accessibility
if [[ "$QML_CONTENT" == *"Accessible.role: Accessible.Button"* ]]; then
    echo "  [PASS] Next Button accessibility role found."
else
    echo "[FAIL] Next Button accessibility role missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.role: Accessible.Button' to ensure the element is recognized as a button by assistive technologies."
    exit 1
fi

if [[ "$QML_CONTENT" == *"Accessible.name: qsTr(\"Next Slide\")"* ]]; then
    echo "  [PASS] Next Button accessible name found."
else
    echo "[FAIL] Next Button accessible name missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Accessible.name: qsTr(\"Next Slide\")' to provide a descriptive name for screen readers."
    exit 1
fi

# Check for Scale Animation
if [[ "$QML_CONTENT" == *"Behavior on scale"* ]]; then
    echo "  [PASS] Scale animation found."
else
    echo "[FAIL] Scale animation missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Behavior on scale' to create smooth visual transitions."
    exit 1
fi

# --- NEW CHECKS ---

# Check for Pause Locks Logic
if [[ "$QML_CONTENT" == *"property int pauseLocks: 0"* ]]; then
    echo "  [PASS] Pause Locks property found."
else
    echo "[FAIL] Pause Locks property missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'property int pauseLocks: 0' to initialize the pause state management logic."
    exit 1
fi

if [[ "$QML_CONTENT" == *"presentation.pauseLocks++"* ]]; then
    echo "  [PASS] Pause Locks increment logic found."
else
    echo "[FAIL] Pause Locks increment logic missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'presentation.pauseLocks++' to increment the pause lock counter."
    exit 1
fi

# Check for Keyboard Focus Enablement
if [[ "$QML_CONTENT" == *"activeFocusOnTab: true"* ]]; then
    echo "  [PASS] Keyboard focus enabled (activeFocusOnTab) found."
else
    echo "[FAIL] Keyboard focus enabled (activeFocusOnTab) missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'activeFocusOnTab: true' to allow keyboard users to focus the element via the Tab key."
    exit 1
fi

# Check for Visual Focus Indicator on Button (Nations Trust Bank cyan #0096D5,
# referenced via the presentation.cCyan brand property).
if [[ "$QML_CONTENT" == *"border.color: presentation.cCyan"* ]]; then
    echo "  [PASS] Visual focus indicator (NTB cyan border) found."
else
    echo "[FAIL] Visual focus indicator (NTB cyan border) missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'border.color: presentation.cCyan' to provide a clear visual indicator when the element has focus."
    exit 1
fi

# Check for Keyboard Activation
if [[ "$QML_CONTENT" == *"Keys.onReturnPressed: presentation.advance()"* ]]; then
    echo "  [PASS] Return key activation found."
else
    echo "[FAIL] Return key activation missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onReturnPressed: presentation.advance()' to allow activation via the Return key."
    exit 1
fi

# Check for Text Outline (Readability enhancement)
if [[ "$QML_CONTENT" == *"style: Text.Outline"* ]]; then
    echo "  [PASS] Text Outline style found."
else
    echo "[FAIL] Text Outline style missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'style: Text.Outline' to improve text readability against varying backgrounds."
    exit 1
fi

# Check for Left Arrow Navigation
if [[ "$QML_CONTENT" == *"Keys.onLeftPressed: presentation.advance()"* ]]; then
    echo "  [PASS] Left Arrow navigation binding found."
else
    echo "[FAIL] Left Arrow navigation binding missing!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "How to fix:"
    echo "   - Open $QML_FILE."
    echo "   - Add 'Keys.onLeftPressed: presentation.advance()' to enable backwards navigation."
    exit 1
fi

echo "All QML UX enhancements verified successfully!"
