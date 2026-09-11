#!/bin/bash
# Verify the NeOS brand palette hasn't drifted or reverted.
#
# tools/palette.json is the single source of truth for the accent color;
# every consuming file (QML/QSS/SVG/Python/KDE .colors/os-release) keeps its
# own literal hex copy since there's no shared import path across Calamares,
# SDDM, and the live-session welcome app (three independent runtimes). This
# guards two things: (1) the accent value in palette.json actually appears in
# every file that's supposed to carry it, so a value change here doesn't
# silently go unapplied elsewhere, and (2) the old borrowed "NTB" palette
# (#0088CF / #0096D5 / #EB008B) never reappears anywhere under
# profile/airootfs/ — nothing caught that identity drifting into three
# different disagreeing "NeOS blue" values before this test existed.
set -euo pipefail

PALETTE="tools/palette.json"
FAIL=0

echo "Verifying NeOS brand palette consistency..."

if [[ ! -f "$PALETTE" ]]; then
    echo "❌ $PALETTE not found"
    exit 1
fi

ACCENT=$(python3 -c "import json; print(json.load(open('$PALETTE'))['accent'])")
if [[ -z "$ACCENT" ]]; then
    echo "❌ Could not read 'accent' from $PALETTE"
    exit 1
fi
echo "Source of truth: accent = $ACCENT"

# 1. Every surface that's supposed to carry the accent still does.
TARGETS=(
    "profile/airootfs/etc/calamares/branding/neos/branding.desc"
    "profile/airootfs/etc/calamares/branding/neos/show.qml"
    "profile/airootfs/etc/calamares/branding/neos/stylesheet.qss"
    "profile/airootfs/usr/share/sddm/themes/neos/Main.qml"
    "profile/airootfs/usr/local/bin/neos-welcome-app"
)
for f in "${TARGETS[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "❌ $f not found"
        FAIL=1
        continue
    fi
    if grep -qi "$ACCENT" "$f"; then
        echo "✅ $f carries the accent color"
    else
        echo "❌ $f does not contain accent color $ACCENT"
        FAIL=1
    fi
done

if compgen -G "profile/airootfs/etc/calamares/branding/neos/img/partition-*.svg" > /dev/null; then
    for f in profile/airootfs/etc/calamares/branding/neos/img/partition-*.svg; do
        if grep -qi "$ACCENT" "$f"; then
            echo "✅ $f carries the accent color"
        else
            echo "❌ $f does not contain accent color $ACCENT"
            FAIL=1
        fi
    done
else
    echo "❌ no partition-*.svg icons found"
    FAIL=1
fi

# 2. The old borrowed NTB palette must never reappear on the shipped image.
if grep -rEqli '0088cf|0096d5|eb008b' profile/airootfs/ 2>/dev/null; then
    echo "❌ retired NTB palette hex found under profile/airootfs/ — identity has drifted back:"
    grep -rEli '0088cf|0096d5|eb008b' profile/airootfs/ 2>/dev/null | sed 's/^/     /'
    FAIL=1
else
    echo "✅ no retired NTB palette hex anywhere under profile/airootfs/"
fi

if grep -rEqli 'nations trust bank|ntb[ _-]' profile/airootfs/ 2>/dev/null; then
    echo "❌ 'NTB'/'Nations Trust Bank' wording found under profile/airootfs/:"
    grep -rEli 'nations trust bank|ntb[ _-]' profile/airootfs/ 2>/dev/null | sed 's/^/     /'
    FAIL=1
else
    echo "✅ no 'NTB'/'Nations Trust Bank' wording anywhere under profile/airootfs/"
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Palette consistency verification FAILED."
    exit 1
fi
echo "Palette consistency verification passed!"
