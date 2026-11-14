#!/bin/bash
# Package hygiene (reports/v2026.10.03/00-polish-plan.md Q3). The live list is
# also the installed-system list (tools/gen-manifests.sh), so anything here
# lands on every NeOS desktop. Keeps out the Arch rescue-ISO extras and the
# dormant-installer stack the Omarchy merge brought in, and keeps the
# installed-only developer block to its lean core.
set -euo pipefail

cd "$(dirname "$0")/.."
PACKAGES="profile/packages.x86_64"
MANIFEST="profile/airootfs/etc/calamares/neos-packages.txt"
FAIL=0

echo "Verifying package hygiene..."

for pkg in archinstall gum python-textual python-pydantic clonezilla drbl partclone partimage \
           fsarchiver darkhttpd livecd-sounds irssi lynx mc wvdial pptpclient xl2tpd vpnc \
           openconnect linux-atm nmap tcpdump refind edk2-shell memtest86+ memtest86+-efi dmraid \
           cloud-init; do
    if grep -qx "$pkg" "$PACKAGES"; then
        echo "[FAIL] $pkg is in $PACKAGES (rescue-ISO / dormant-installer package; it would ship on every install)"
        FAIL=1
    fi
done
(( FAIL )) || echo "  [PASS] no rescue-ISO or dormant-installer packages"

for pkg in zig nim bun gleam elixir odin crystal php composer jdk-openjdk dotnet-sdk docker deno; do
    if grep -qx "$pkg" "$MANIFEST"; then
        echo "[FAIL] $pkg is installed on every system ($MANIFEST); keep the developer block to its core"
        FAIL=1
    fi
done
(( FAIL )) || echo "  [PASS] developer block limited to its core"

for pkg in base-devel python-pip nodejs npm; do
    if ! grep -qx "$pkg" "$MANIFEST"; then
        echo "[FAIL] developer core package $pkg is missing from $MANIFEST"
        FAIL=1
    fi
done
(( FAIL )) || echo "  [PASS] developer core present"

dups="$(grep -vE '^\s*(#|$)' "$MANIFEST" | sort | uniq -d)"
if [[ -n "$dups" ]]; then
    echo "[FAIL] duplicate entries in $MANIFEST: $dups"
    FAIL=1
fi

if (( FAIL )); then
    echo "[FAIL] Package hygiene verification failed."
    exit 1
fi
echo "[PASS] Package hygiene verified."
