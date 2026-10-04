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
    echo "[FAIL] $PALETTE not found"
    exit 1
fi

ACCENT=$(python3 -c "import json; print(json.load(open('$PALETTE'))['accent'])")
if [[ -z "$ACCENT" ]]; then
    echo "[FAIL] Could not read 'accent' from $PALETTE"
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
        echo "[FAIL] $f not found"
        FAIL=1
        continue
    fi
    if grep -qi "$ACCENT" "$f"; then
        echo "[PASS] $f carries the accent color"
    else
        echo "[FAIL] $f does not contain accent color $ACCENT"
        FAIL=1
    fi
done

if compgen -G "profile/airootfs/etc/calamares/branding/neos/img/partition-*.svg" > /dev/null; then
    for f in profile/airootfs/etc/calamares/branding/neos/img/partition-*.svg; do
        if grep -qi "$ACCENT" "$f"; then
            echo "[PASS] $f carries the accent color"
        else
            echo "[FAIL] $f does not contain accent color $ACCENT"
            FAIL=1
        fi
    done
else
    echo "[FAIL] no partition-*.svg icons found"
    FAIL=1
fi

# 2. The old borrowed NTB palette must never reappear on the shipped image.
if grep -rEqli '0088cf|0096d5|eb008b' profile/airootfs/ 2>/dev/null; then
    echo "[FAIL] retired NTB palette hex found under profile/airootfs/ — identity has drifted back:"
    grep -rEli '0088cf|0096d5|eb008b' profile/airootfs/ 2>/dev/null | sed 's/^/     /'
    FAIL=1
else
    echo "[PASS] no retired NTB palette hex anywhere under profile/airootfs/"
fi

if grep -rEqli 'nations trust bank|ntb[ _-]' profile/airootfs/ 2>/dev/null; then
    echo "[FAIL] 'NTB'/'Nations Trust Bank' wording found under profile/airootfs/:"
    grep -rEli 'nations trust bank|ntb[ _-]' profile/airootfs/ 2>/dev/null | sed 's/^/     /'
    FAIL=1
else
    echo "[PASS] no 'NTB'/'Nations Trust Bank' wording anywhere under profile/airootfs/"
fi

# 3. One accent family (reports/v2026.10.03/00-polish-plan.md Q4). The accent
#    moved to #38bdf8 but three files kept three different hover/pressed pairs
#    and the old #1F6FD6 survived as Qt.rgba(0.122, 0.435, 0.839) / 31;111;214.
read -r HOVER PRESSED ON_ACCENT < <(python3 -c "import json; p=json.load(open('$PALETTE')); print(p['accentHover'], p['accentPressed'], p['onAccent'])")
STALE='#1f6fd6|#3d82e0|#17569f|#22d3ee|#0284c7|0\.122, ?0\.435, ?0\.839|31;111;214|31, ?111, ?214|34,211,238'
if grep -rEqi "$STALE" profile/airootfs/ --include='*.qml' --include='*.qss' --include='*.desc' --include='*.colors' --include='os-release' --include='neos-welcome-app' 2>/dev/null; then
    echo "[FAIL] retired accent shades found (use accentHover $HOVER / accentPressed $PRESSED from $PALETTE):"
    grep -rEni "$STALE" profile/airootfs/ --include='*.qml' --include='*.qss' --include='*.desc' --include='*.colors' --include='os-release' --include='neos-welcome-app' 2>/dev/null | sed 's/^/     /'
    FAIL=1
else
    echo "[PASS] no retired accent shades (one accent family: $ACCENT / $HOVER / $PRESSED)"
fi

# 4. Text on accent fills must be the dark onAccent colour: white on the
#    accent is 2.1:1, below WCAG AA (4.5:1).
WHITE_ON_ACCENT="$(python3 - "$ACCENT" "$HOVER" "$PRESSED" <<'PY'
import re, sys, pathlib
fills = {c.lower() for c in sys.argv[1:]}
hits = []
qss = pathlib.Path("profile/airootfs/etc/calamares/branding/neos/stylesheet.qss")
welcome = pathlib.Path("profile/airootfs/usr/local/bin/neos-welcome-app")
for path in (qss, welcome):
    for block in re.findall(r"[^{}]*\{[^{}]*\}", path.read_text()):
        bg = re.search(r"(?<![-\w])background(?:-color)?:\s*(#[0-9a-fA-F]{6})", block)
        fg = re.search(r"(?<![-\w])color:\s*(#[0-9a-fA-F]{6}|white)", block)
        if bg and fg and bg.group(1).lower() in fills and fg.group(1).lower() in ("#ffffff", "white"):
            hits.append(f"{path}: {block.strip().splitlines()[0]}")
        sbg = re.search(r"selection-background-color:\s*(#[0-9a-fA-F]{6})", block)
        sfg = re.search(r"selection-color:\s*(#[0-9a-fA-F]{6})", block)
        if sbg and sfg and sbg.group(1).lower() in fills and sfg.group(1).lower() == "#ffffff":
            hits.append(f"{path}: selection in {block.strip().splitlines()[0]}")
desc = pathlib.Path("profile/airootfs/etc/calamares/branding/neos/branding.desc").read_text()
if re.search(r'SidebarTextCurrent:\s*"#FFFFFF"', desc, re.I):
    hits.append("branding.desc: SidebarTextCurrent is white on the accent")
for qml in ("profile/airootfs/usr/share/sddm/themes/neos/Main.qml",
            "profile/airootfs/etc/calamares/branding/neos/show.qml"):
    text = pathlib.Path(qml).read_text()
    for label in ("Log In", "Next Slide"):
        m = re.search(r'text:\s*(?:qsTr\()?"' + label + r'[^"]*"\)?;\s*color:\s*("white"|"#ffffff")', text, re.I)
        if m:
            hits.append(f"{qml}: '{label}' text is white on the accent")
print("\n".join(hits))
PY
)"
if [[ -n "$WHITE_ON_ACCENT" ]]; then
    echo "[FAIL] white text on accent fills (use onAccent $ON_ACCENT):"
    while IFS= read -r hit; do echo "     $hit"; done <<< "$WHITE_ON_ACCENT"
    FAIL=1
else
    echo "[PASS] text on accent fills uses onAccent ($ON_ACCENT)"
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Palette consistency verification FAILED."
    exit 1
fi
echo "Palette consistency verification passed!"
