#!/bin/bash
set -e

echo "Verifying ISO size optimization settings..."

PROFILE_FILE="profiledef.sh"
PACMAN_CONF="pacman.conf"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ $PROFILE_FILE not found"
    exit 1
fi

if [ ! -f "$PACMAN_CONF" ]; then
    echo "❌ $PACMAN_CONF not found"
    exit 1
fi

# 1. Verify Compression Settings in profiledef.sh
echo "Checking compression settings in $PROFILE_FILE..."
# We check for the x86_64 specific options which include BCJ
if grep -Fq "airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')" "$PROFILE_FILE"; then
    echo "✅ Compression settings are optimized for size (xz, 1M block/dict, BCJ)"
else
    echo "❌ Compression settings do NOT match optimized profile"
    echo "Expected: airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')"
    echo "Found:"
    grep "airootfs_image_tool_options" "$PROFILE_FILE" || true
    exit 1
fi

# 2. Verify NoExtract in pacman.conf
echo "Checking NoExtract settings in $PACMAN_CONF..."

REQUIRED_EXCLUDES=(
    "usr/share/man/*"
    "usr/share/doc/*"
    "usr/share/gtk-doc/*"
    "usr/share/locale/*"
)

MISSING=false
for pattern in "${REQUIRED_EXCLUDES[@]}"; do
    # Grep for the pattern. Note that * is regex special char, but here we treat it as literal string in grep if we escape it or just use Fgrep if possible.
    # But pattern has * which means wildcard in shell/config, but in grep regex it means "0 or more previous char".
    # So "usr/share/man/*" as regex matches "usr/share/mannnn".
    # We should use fixed string search for the pattern part if possible, or escape *
    ESC_PATTERN=$(echo "$pattern" | sed 's/\*/\\*/g')
    if grep -q "NoExtract.*$ESC_PATTERN" "$PACMAN_CONF"; then
        echo "✅ Exclude '$pattern' found"
    else
        echo "❌ Exclude '$pattern' NOT found"
        MISSING=true
    fi
done

if [ "$MISSING" = true ]; then
    echo "❌ Some required NoExtract patterns are missing"
    exit 1
fi

echo "All ISO size optimization checks passed!"
