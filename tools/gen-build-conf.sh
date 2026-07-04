#!/bin/bash
# NeOS build pacman.conf generator — single source of truth for build.sh and
# the CI workflow (previously duplicated in both, which risked drift).
# Copies profile/pacman.conf to pacman-build.conf and rewrites the mirrorlist
# includes to absolute host paths so mkarchiso resolves them outside the chroot.
#
# Usage: gen-build-conf.sh [REPO_ROOT] [OUTPUT_CONF]
#   REPO_ROOT   repository root (default: $PWD)
#   OUTPUT_CONF output path (default: REPO_ROOT/pacman-build.conf)

set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

REPO_ROOT="${1:-$PWD}"
BUILD_CONF="${2:-$REPO_ROOT/pacman-build.conf}"
PROFILE_DIR="$REPO_ROOT/profile"

MIRRORLIST_PATH="$PROFILE_DIR/airootfs/etc/pacman.d/neos-mirrorlist"
CHAOTIC_MIRRORLIST_PATH="$PROFILE_DIR/airootfs/etc/pacman.d/chaotic-mirrorlist"

if ! grep -q "^[[:space:]]*Server" "$MIRRORLIST_PATH"; then
    echo "Error: No active servers found in $MIRRORLIST_PATH." >&2
    echo "The build cannot proceed without valid repositories." >&2
    exit 1
fi

cp "$PROFILE_DIR/pacman.conf" "$BUILD_CONF"

# Use | as sed delimiter to avoid conflict with / in paths
sed -i "s|/etc/pacman.d/neos-mirrorlist|$MIRRORLIST_PATH|g" "$BUILD_CONF"
sed -i "s|/etc/pacman.d/chaotic-mirrorlist|$CHAOTIC_MIRRORLIST_PATH|g" "$BUILD_CONF"

echo "Generated $BUILD_CONF"
