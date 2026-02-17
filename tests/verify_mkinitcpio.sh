#!/bin/bash
set -e

MKINITCPIO_CONF="airootfs/etc/mkinitcpio.conf"

if [ ! -f "$MKINITCPIO_CONF" ]; then
    echo "❌ $MKINITCPIO_CONF not found!"
    exit 1
fi

HOOKS_LINE=$(grep "^HOOKS=" "$MKINITCPIO_CONF")

if [ -z "$HOOKS_LINE" ]; then
    echo "❌ HOOKS line not found in $MKINITCPIO_CONF"
    exit 1
fi

echo "Found HOOKS: $HOOKS_LINE"

# Check for required hooks
REQUIRED_HOOK="archiso"
if [[ "$HOOKS_LINE" != *"$REQUIRED_HOOK"* ]]; then
    echo "❌ Missing required hook: $REQUIRED_HOOK"
    exit 1
fi

# Check for forbidden hooks
FORBIDDEN_HOOK="autodetect"
if [[ "$HOOKS_LINE" == *"$FORBIDDEN_HOOK"* ]]; then
    echo "❌ Forbidden hook found: $FORBIDDEN_HOOK (should be removed for generic ISO)"
    exit 1
fi

# Check for required modules
REQUIRED_MODULE="btrfs"
MODULES_SECTION=$(sed -n '/^MODULES=/,/)/p' "$MKINITCPIO_CONF")
if [[ "$MODULES_SECTION" != *"$REQUIRED_MODULE"* ]]; then
    echo "❌ Missing required module: $REQUIRED_MODULE"
    exit 1
fi

echo "✅ verification passed: $MKINITCPIO_CONF contains '$REQUIRED_HOOK' hook, '$REQUIRED_MODULE' module, and does not contain '$FORBIDDEN_HOOK' hook"
