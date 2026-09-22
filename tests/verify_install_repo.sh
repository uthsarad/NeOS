#!/bin/bash
# Executes tools/gen-install-repo.sh so the offline-install path is covered by
# automation at last.
#
# The script that builds the ISO's offline package repository aborted on every
# normal build because of bare `((VAR++))` arithmetic under `set -e`
# (reports/v2026.09.18 C1). It was invisible because no job, test or CI step
# ever ran it — the bug was only reachable from a real `sudo ./build.sh`
# (reports/v2026.09.18 C2/H3 note). This test runs the script in --skip-download
# mode against a scratch repo directory, so the cached/missing accounting, the
# stale-package cleanup and the exit-status behaviour are all exercised without
# touching the network.
#
# Requires pacman + repo-add (Arch). Skips with a warning elsewhere.
set -euo pipefail

SCRIPT="tools/gen-install-repo.sh"
PROFILE_DIR="profile"
PKG_LIST="$PROFILE_DIR/airootfs/etc/calamares/neos-packages.txt"

echo "Verifying offline install-repo generator (tools/gen-install-repo.sh)..."

if ! command -v pacman >/dev/null 2>&1; then
    echo "[WARN] pacman not installed — skipping (Arch-only path; CI runs it in the archlinux container)."
    exit 0
fi

if [[ ! -f "$SCRIPT" ]]; then
    echo "[FAIL] Missing $SCRIPT"
    exit 1
fi
if [[ ! -f "$PKG_LIST" ]]; then
    echo "[FAIL] Missing $PKG_LIST — run tools/gen-manifests.sh first"
    exit 1
fi

WORK=$(mktemp -d /tmp/neos-install-repo.XXXXXX)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# A minimal pacman.conf: the test never downloads, so no servers are needed.
cat > "$WORK/pacman.conf" <<'CONF'
[options]
HoldPkg = pacman glibc
Architecture = auto
SigLevel = Required DatabaseOptional
CONF

# Scratch profile containing only the package list the script reads.
mkdir -p "$WORK/profile/airootfs/etc/calamares"
cp "$PKG_LIST" "$WORK/profile/airootfs/etc/calamares/neos-packages.txt"

# Plant one cached package (matches the first entry in the list) and one stale
# package that must be cleaned up — both exercise an arithmetic increment that
# used to kill the script when it started from zero.
FIRST_PKG=$(grep -vE '^\s*(#|$)' "$PKG_LIST" | head -1)
REPO_DIR="$WORK/repo"
mkdir -p "$REPO_DIR"
: > "$REPO_DIR/${FIRST_PKG}-1.0-1-x86_64.pkg.tar.zst"
: > "$REPO_DIR/zzz-stale-package-1.0-1-x86_64.pkg.tar.zst"

set +e
OUT=$(bash "$SCRIPT" \
    --repo-dir "$REPO_DIR" \
    --work-dir "$WORK/work" \
    --profile "$WORK/profile" \
    --build-conf "$WORK/pacman.conf" \
    --skip-download 2>&1)
RC=$?
set -e

while IFS= read -r line; do printf '    %s\n' "$line"; done <<<"$OUT"

if [[ $RC -ne 0 ]]; then
    echo "[FAIL] gen-install-repo.sh exited $RC in --skip-download mode (this is the C1 class of failure)"
    exit 1
fi

if ! grep -q "Already cached: 1" <<<"$OUT"; then
    echo "[FAIL] Expected 'Already cached: 1' — the cached-package accounting did not run"
    exit 1
fi

if ! grep -q "Cleaned 1 stale package" <<<"$OUT"; then
    echo "[FAIL] Expected the stale package to be cleaned up"
    exit 1
fi

if [[ -f "$REPO_DIR/zzz-stale-package-1.0-1-x86_64.pkg.tar.zst" ]]; then
    echo "[FAIL] Stale package survived the cleanup pass"
    exit 1
fi

if [[ ! -f "$REPO_DIR/${FIRST_PKG}-1.0-1-x86_64.pkg.tar.zst" ]]; then
    echo "[FAIL] Cached package for a listed package was removed"
    exit 1
fi

echo "[PASS] Offline install-repo generator exercised successfully."
