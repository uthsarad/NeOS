#!/bin/bash
# Guard against the shipped system pointing users at a repo that cannot answer.
#
# The canonical project is uthsarad/NeOS. The repository this work happens in is
# a fork (NimuthuGanegoda/NeOS) with Issues disabled, so support/bug URLs that
# name the fork ship a dead end inside every installed system — and the Calamares
# branding links do the same during installation
# (reports/v2026.09.22/UPDATES_NEEDED.md, section 3).
set -euo pipefail

CANONICAL="uthsarad/NeOS"
FORK="NimuthuGanegoda/NeOS"

OS_RELEASE="profile/airootfs/etc/os-release"
BRANDING="profile/airootfs/etc/calamares/branding/neos/branding.desc"
PROFILEDEF="profile/profiledef.sh"

echo "Verifying shipped support URLs point at the canonical repository..."

FAIL=0

for file in "$OS_RELEASE" "$BRANDING" "$PROFILEDEF"; do
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Missing $file"
        FAIL=1
        continue
    fi
    if grep -q "$FORK" "$file"; then
        echo "[FAIL] $file still points at the fork ($FORK), whose Issues are disabled"
        grep -n "$FORK" "$file" | sed 's/^/       /'
        FAIL=1
    fi
    if grep -q "$CANONICAL" "$file"; then
        echo "  [PASS] $file names $CANONICAL"
    else
        echo "[FAIL] $file does not name $CANONICAL"
        FAIL=1
    fi
done

# os-release is consumed by tools and by the ISO metadata; the support channels
# must exist and match the canonical repo.
for key in HOME_URL DOCUMENTATION_URL SUPPORT_URL BUG_REPORT_URL; do
    VALUE=$(grep -E "^${key}=" "$OS_RELEASE" | cut -d'"' -f2)
    if [[ -z "$VALUE" ]]; then
        echo "[FAIL] $OS_RELEASE is missing $key"
        FAIL=1
    elif [[ "$VALUE" != *"$CANONICAL"* ]]; then
        echo "[FAIL] $key does not point at $CANONICAL: $VALUE"
        FAIL=1
    fi
done

if (( FAIL )); then
    echo "[FAIL] Shipped support URLs are wrong."
    exit 1
fi

echo "[PASS] Shipped support URLs verified."
