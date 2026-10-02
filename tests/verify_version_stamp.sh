#!/bin/bash
# VERSION must be stamped into the live/installed os-release so the welcome
# app and `neos-doctor` can show a real number (reports/v2026.09.22 M10).
set -euo pipefail

VERSION_FILE="VERSION"
OS_RELEASE="profile/airootfs/etc/os-release"

echo "Verifying VERSION is stamped into os-release..."

if [[ ! -f "$VERSION_FILE" ]]; then
    echo "[FAIL] Missing $VERSION_FILE"
    exit 1
fi
if [[ ! -f "$OS_RELEASE" ]]; then
    echo "[FAIL] Missing $OS_RELEASE"
    exit 1
fi

VER="$(tr -d '[:space:]' < "$VERSION_FILE")"
GOT="$(grep -E '^VERSION_ID=' "$OS_RELEASE" | cut -d= -f2- | tr -d '"')"

if [[ -z "$VER" ]]; then
    echo "[FAIL] $VERSION_FILE is empty"
    exit 1
fi

if [[ "$GOT" == "$VER" ]]; then
    echo "  [PASS] VERSION_ID=$GOT matches VERSION"
else
    echo "[FAIL] os-release VERSION_ID='$GOT' does not match VERSION='$VER'"
    exit 1
fi

# The tool version constants are bumped by hand alongside VERSION (M10); fail
# when one is left behind instead of shipping a tool that reports an old release.
FAIL=0
for entry in \
    "profile/airootfs/etc/os-release|^VERSION=\"([^\"]+)\"" \
    "tools/neosctl/main.go|Version[[:space:]]*=[[:space:]]*\"([^\"]+)\"" \
    "tools/neos_tasks.rb|VERSION[[:space:]]*=[[:space:]]*'([^']+)'" \
    "tools/NeosDiagnostics/SecurityInspector.cs|PlatformVersion[^\"]*\"([^\"]+)\""; do
    file="${entry%%|*}"
    pattern="${entry#*|}"
    found="$(grep -oE "$pattern" "$file" | head -1 | sed -E "s/$pattern/\\1/")"
    if [[ "$found" == "$VER" ]]; then
        echo "  [PASS] $file carries $VER"
    else
        echo "[FAIL] $file carries '${found:-nothing}', VERSION is '$VER'"
        FAIL=1
    fi
done
if (( FAIL )); then
    exit 1
fi

if grep -qE "^## \[$VER\]" CHANGELOG.md; then
    echo "  [PASS] CHANGELOG.md has a section for $VER (the release body source)"
else
    echo "[FAIL] CHANGELOG.md has no '## [$VER]' section; the release body would be empty"
    exit 1
fi

echo "[PASS] Version stamp verified."
