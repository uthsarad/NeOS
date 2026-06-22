#!/bin/bash
set -e

echo "Verifying ISO size optimization settings..."

PROFILE_FILE="profile/profiledef.sh"
PACMAN_CONF="profile/pacman.conf"

if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "❌ $PROFILE_FILE not found"
    exit 1
fi

if [[ ! -f "$PACMAN_CONF" ]]; then
    echo "❌ $PACMAN_CONF not found"
    exit 1
fi

# 1. Verify compression settings in profiledef.sh (zstd for fast boot, or xz for max compression)
echo "Checking compression settings in $PROFILE_FILE..."
mapfile -t PROFILE_LINES < "$PROFILE_FILE"
COMPRESSION_FOUND=false
for line in "${PROFILE_LINES[@]}"; do
    if [[ "$line" == *"airootfs_image_tool_options"* && ("$line" == *"'zstd'"* || "$line" == *"'xz'"*) ]]; then
        COMPRESSION_FOUND=true
        break
    fi
done

if [[ "$COMPRESSION_FOUND" == true ]]; then
    echo "✅ Compression settings configured"
else
    echo "❌ No valid compression settings found in airootfs_image_tool_options"
    exit 1
fi

# 2. Verify NoExtract in pacman.conf for size optimization
echo "Checking NoExtract settings in $PACMAN_CONF..."

REQUIRED_EXCLUDES=(
    "usr/share/doc/*"
    "usr/share/gtk-doc/*"
    "usr/share/help/*"
    "usr/include/*"
    "usr/share/locale/*"
)

mapfile -t PACMAN_LINES < "$PACMAN_CONF"

MISSING=false
for pattern in "${REQUIRED_EXCLUDES[@]}"; do
    PATTERN_FOUND=false
    for line in "${PACMAN_LINES[@]}"; do
        if [[ "$line" == *"NoExtract"* && "$line" == *"$pattern"* ]]; then
            PATTERN_FOUND=true
            break
        fi
    done

    if [[ "$PATTERN_FOUND" == true ]]; then
        echo "✅ Exclude '$pattern' found"
    else
        echo "❌ Exclude '$pattern' NOT found"
        MISSING=true
    fi
done

if [[ "$MISSING" == true ]]; then
    echo "❌ Some required NoExtract patterns are missing"
    exit 1
fi

echo "All ISO size optimization checks passed!"
