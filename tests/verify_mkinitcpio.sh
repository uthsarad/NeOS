#!/bin/bash
set -e

# Wrapper to ensure script does not block indefinitely
if [ "$1" != "--wrapped" ]; then
    timeout 60s bash "$0" --wrapped "$@" || { exit_code=$?; echo "⚠️ $0 failed or timed out"; exit $exit_code; }
    exit 0
fi
shift

MKINITCPIO_CONF="airootfs/etc/mkinitcpio.conf"

if [ ! -f "$MKINITCPIO_CONF" ]; then
    echo "❌ $MKINITCPIO_CONF not found!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Create the missing configuration file."
    echo "   - Ensure mkinitcpio.conf is located at $MKINITCPIO_CONF."
    exit 1
fi

# Bolt: Read file once using native bash to extract HOOKS and MODULES efficiently, avoiding grep/sed subprocesses.
HOOKS_LINE=""
MODULES_SECTION=""
IN_MODULES=0

while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" == HOOKS=* ]]; then
        HOOKS_LINE="$line"
    elif [[ "$line" == MODULES=* ]]; then
        IN_MODULES=1
        MODULES_SECTION="$line"$'\n'
    elif [[ $IN_MODULES -eq 1 ]]; then
        MODULES_SECTION+="$line"$'\n'
        if [[ "$line" == *")"* ]]; then
            IN_MODULES=0
        fi
    fi
done < "$MKINITCPIO_CONF"

if [ -z "$HOOKS_LINE" ]; then
    echo "❌ HOOKS line not found in $MKINITCPIO_CONF"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $MKINITCPIO_CONF."
    echo "   - Add a 'HOOKS=(...)' array to define the required initialization hooks."
    exit 1
fi

echo "Found HOOKS: $HOOKS_LINE"

# Check for required hooks
REQUIRED_HOOK="archiso"
if [[ "$HOOKS_LINE" != *"$REQUIRED_HOOK"* ]]; then
    echo "❌ Missing required hook: $REQUIRED_HOOK"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $MKINITCPIO_CONF."
    echo "   - Locate the HOOKS array."
    echo "   - Add '$REQUIRED_HOOK' to ensure the ISO boots correctly."
    exit 1
fi

# Check for forbidden hooks
FORBIDDEN_HOOK="autodetect"
if [[ "$HOOKS_LINE" == *"$FORBIDDEN_HOOK"* ]]; then
    echo "❌ Forbidden hook found: $FORBIDDEN_HOOK (should be removed for generic ISO)"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $MKINITCPIO_CONF."
    echo "   - Locate the HOOKS array."
    echo "   - Remove the forbidden '$FORBIDDEN_HOOK' hook to prevent generic ISO boot failures."
    exit 1
fi

FORBIDDEN_HOOK="fsck"
if [[ "$HOOKS_LINE" == *"$FORBIDDEN_HOOK"* ]]; then
    echo "❌ Forbidden hook found: $FORBIDDEN_HOOK (should be removed for live ISO)"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $MKINITCPIO_CONF."
    echo "   - Locate the HOOKS array."
    echo "   - Remove the forbidden '$FORBIDDEN_HOOK' hook to prevent live ISO boot failures."
    exit 1
fi

# Check for required modules
REQUIRED_MODULE="btrfs"
if [[ "$MODULES_SECTION" != *"$REQUIRED_MODULE"* ]]; then
    echo "❌ Missing required module: $REQUIRED_MODULE"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Open $MKINITCPIO_CONF."
    echo "   - Locate the MODULES array."
    echo "   - Add the required '$REQUIRED_MODULE' module."
    exit 1
fi

echo "✅ verification passed: $MKINITCPIO_CONF contains '$REQUIRED_HOOK' hook, '$REQUIRED_MODULE' module, and does not contain forbidden hooks (autodetect, fsck)"
