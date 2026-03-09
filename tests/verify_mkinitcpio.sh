#!/bin/bash
set -e

MKINITCPIO_CONF="airootfs/etc/mkinitcpio.conf"

if [ ! -f "$MKINITCPIO_CONF" ]; then
    echo "❌ $MKINITCPIO_CONF not found!"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Ensure mkinitcpio.conf is located at $MKINITCPIO_CONF."
    exit 1
fi

# Bolt: Consider using native bash or a more performant search for HOOKS to avoid grep subprocess.
HOOKS_LINE=$(grep "^HOOKS=" "$MKINITCPIO_CONF")

if [ -z "$HOOKS_LINE" ]; then
    echo "❌ HOOKS line not found in $MKINITCPIO_CONF"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Add a 'HOOKS=(...)' array to $MKINITCPIO_CONF."
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
    echo "   - Add '$REQUIRED_HOOK' to the HOOKS array in $MKINITCPIO_CONF."
    exit 1
fi

# Check for forbidden hooks
FORBIDDEN_HOOK="autodetect"
if [[ "$HOOKS_LINE" == *"$FORBIDDEN_HOOK"* ]]; then
    echo "❌ Forbidden hook found: $FORBIDDEN_HOOK (should be removed for generic ISO)"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Remove '$FORBIDDEN_HOOK' from the HOOKS array in $MKINITCPIO_CONF."
    exit 1
fi

FORBIDDEN_HOOK="fsck"
if [[ "$HOOKS_LINE" == *"$FORBIDDEN_HOOK"* ]]; then
    echo "❌ Forbidden hook found: $FORBIDDEN_HOOK (should be removed for live ISO)"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Remove '$FORBIDDEN_HOOK' from the HOOKS array in $MKINITCPIO_CONF."
    exit 1
fi

# Check for required modules
REQUIRED_MODULE="btrfs"
# Bolt: Consider using native bash or a more performant search to find MODULES array to avoid sed subprocess.
MODULES_SECTION=$(sed -n '/^MODULES=/,/)/p' "$MKINITCPIO_CONF")
if [[ "$MODULES_SECTION" != *"$REQUIRED_MODULE"* ]]; then
    echo "❌ Missing required module: $REQUIRED_MODULE"
    echo ""
    # Palette: Multi-line actionable formatting with bulleted list
    echo "💡 How to fix:"
    echo "   - Add '$REQUIRED_MODULE' to the MODULES array in $MKINITCPIO_CONF."
    exit 1
fi

echo "✅ verification passed: $MKINITCPIO_CONF contains '$REQUIRED_HOOK' hook, '$REQUIRED_MODULE' module, and does not contain forbidden hooks (autodetect, fsck)"
