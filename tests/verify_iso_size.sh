#!/bin/bash
set -e

echo "Verifying ISO size optimization settings..."

PROFILE_FILE="profiledef.sh"
PACMAN_CONF="pacman.conf"

if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "❌ $PROFILE_FILE not found"
    echo ""
    echo "💡 How to fix:"
    echo "   - Ensure you are running this script from the root of the repository."
    echo "   - Verify that '$PROFILE_FILE' exists in the current directory."
    exit 1
fi

if [[ ! -f "$PACMAN_CONF" ]]; then
    echo "❌ $PACMAN_CONF not found"
    echo ""
    echo "💡 How to fix:"
    echo "   - Ensure you are running this script from the root of the repository."
    echo "   - Verify that '$PACMAN_CONF' exists in the current directory."
    exit 1
fi

# 1. Verify Compression Settings in profiledef.sh
echo "Checking compression settings in $PROFILE_FILE..."
# We check for the x86_64 specific options which include BCJ
mapfile -t PROFILE_LINES < "$PROFILE_FILE"
COMPRESSION_FOUND=false
for line in "${PROFILE_LINES[@]}"; do
    if [[ "$line" == *"airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M')"* ]]; then
        COMPRESSION_FOUND=true
        break
    fi
done

if [[ "$COMPRESSION_FOUND" == true ]]; then
    echo "✅ Compression settings are optimized for size (xz, 1M block, BCJ)"
else
    echo "❌ Compression settings do NOT match optimized profile"
    echo "Expected: airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M')"
    echo "Found:"
    for line in "${PROFILE_LINES[@]}"; do
        if [[ "$line" == *"airootfs_image_tool_options"* ]]; then
            echo "$line"
        fi
    done
    echo ""
    echo "💡 How to fix:"
    echo "   - Open '$PROFILE_FILE'."
    echo "   - Update 'airootfs_image_tool_options' to match the expected value."
    exit 1
fi

# 2. Verify NoExtract in pacman.conf
# Bolt: Replace repeated external subprocess calls (like grep) with native bash logic (like substring matching) wherever possible to eliminate fork/exec overhead.
echo "Checking NoExtract settings in $PACMAN_CONF..."

REQUIRED_EXCLUDES=(
    "usr/share/man/*"
    "usr/share/doc/*"
    "usr/share/gtk-doc/*"
    "usr/share/locale/*"
    "usr/share/help/*"
    "usr/include/*"
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
    # Palette: Ensure error messages are multi-line and feature a clear '💡 How to fix:' block with actionable, bulleted steps to reduce developer cognitive load on failure.
    echo "❌ Some required NoExtract patterns are missing"
    echo ""
    echo "💡 How to fix:"
    echo "   - Open '$PACMAN_CONF'."
    echo "   - Ensure all of the following are listed in the 'NoExtract' array under [options]:"
    for p in "${REQUIRED_EXCLUDES[@]}"; do
        echo "     - $p"
    done
    exit 1
fi

echo "All ISO size optimization checks passed!"
