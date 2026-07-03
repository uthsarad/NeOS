#!/bin/bash
# NeOS branding alpha fixer (ImageMagick, no Pillow needed).
#
# The NeOS badge artwork ships as a circular swirl baked onto an opaque black
# square (with white remnants in the corners). On the Plymouth splash and the
# Calamares sidebar that square renders as a visible black box over the navy
# gradient. This script cuts the badge out with an anti-aliased circular alpha
# mask and regenerates the Plymouth cat frames from the transparent source GIF
# (the committed frames predate tools/gen-bootlogo-frames.py and carry an
# opaque grey box from an older pipeline).
#
# Idempotent — safe to re-run. Regenerate order of preference:
#   cat frames: python3 tools/gen-bootlogo-frames.py (canonical, Pillow)
#               or this script (ImageMagick fallback, same layout rules)
#
# Usage: tools/fix-branding-alpha.sh [REPO_ROOT]

set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

REPO_ROOT="${1:-$PWD}"
THEME="$REPO_ROOT/profile/airootfs/usr/share/plymouth/themes/neos"
BRANDING="$REPO_ROOT/profile/airootfs/etc/calamares/branding/neos"
SRC_GIF="$REPO_ROOT/tools/loader-cat.gif"

command -v convert >/dev/null || { echo "ImageMagick 'convert' required" >&2; exit 1; }

# --- 1. Circular alpha mask for the badge logos ------------------------------
# The swirl is centred; everything outside the inscribed circle (black square,
# white corner junk) becomes transparent. 4x supersampled mask for a smooth
# anti-aliased rim.
circle_cut() {
    local img="$1"
    local w h d r
    w=$(identify -format '%w' "$img")
    h=$(identify -format '%h' "$img")
    d=$(( w < h ? w : h ))
    r=$(( (d / 2 - 1) * 4 ))
    # -alpha off must follow BOTH images: it strips the mask's alpha channel so
    # CopyOpacity reads the mask's grayscale intensity, not its (opaque) alpha.
    convert "$img" \
        \( -size "$((w * 4))x$((h * 4))" xc:black \
           -fill white -draw "circle $((w * 2)),$((h * 2)) $((w * 2 + r)),$((h * 2))" \
           -resize 25% \) \
        -alpha off -compose CopyOpacity -composite "$img"
    echo "circle-cut: $img (${w}x${h}, r=$((r / 4))px)"
}

circle_cut "$THEME/logo.png"
circle_cut "$BRANDING/logo.png"

# --- 2. Regenerate Plymouth cat frames from the transparent source GIF -------
# Same layout rules as tools/gen-bootlogo-frames.py: composite GIF disposal,
# crop each cel to its visible pixels, scale 2x, centre all frames on one
# shared canvas (largest cel + 20px margin) so the cat never wobbles.
SCALE=200%   # 2x
MARGIN=20

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

convert "$SRC_GIF" -coalesce "$WORK/cel-%02d.png"

max_w=0 max_h=0
for f in "$WORK"/cel-*.png; do
    convert "$f" -trim +repage "$f"
    w=$(identify -format '%w' "$f"); h=$(identify -format '%h' "$f")
    (( w > max_w )) && max_w=$w
    (( h > max_h )) && max_h=$h
done

out_w=$((max_w * 2 + 2 * MARGIN))
out_h=$((max_h * 2 + 2 * MARGIN))

i=0
for f in "$WORK"/cel-*.png; do
    convert "$f" -filter Lanczos -resize "$SCALE" \
        -background none -gravity center -extent "${out_w}x${out_h}" \
        "$THEME/$(printf 'cat-%02d.png' "$i")"
    i=$((i + 1))
done
echo "Wrote $i centred cat frames (${out_w}x${out_h}) to $THEME"
