#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting NeOS ISO Build Process...${NC}"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root.${NC}"
  exit 1
fi

# Check for dependencies
if ! command -v mkarchiso &> /dev/null; then
    echo -e "${RED}Error: mkarchiso could not be found. Please install 'archiso'.${NC}"
    exit 1
fi

if ! command -v mksquashfs &> /dev/null; then
    echo -e "${RED}Error: mksquashfs could not be found. Please install 'squashfs-tools'.${NC}"
    exit 1
fi

# Work and Out directories
WORK_DIR="work"
OUT_DIR="out"

# Clean previous build artifacts if requested
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Work directory '$WORK_DIR' exists.${NC}"
    read -p "Clean work directory before building? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing $WORK_DIR..."
        rm -rf "$WORK_DIR"
    fi
fi

# Generate temporary pacman.conf for build
echo "Generating temporary build configuration..."
BUILD_CONF="pacman-build.conf"

# Copy host pacman.conf as base
cp /etc/pacman.conf "$BUILD_CONF"

# Append Arch repositories if not already present
# We point to the local mirrorlist using absolute path
REPO_ROOT=$(pwd)
MIRRORLIST_PATH="$REPO_ROOT/airootfs/etc/pacman.d/neos-mirrorlist"

# Check if mirrorlist has active servers
if grep -q "^[[:space:]]*Server" "$MIRRORLIST_PATH"; then
    if ! grep -q "\[core\]" "$BUILD_CONF"; then
        echo "Appending Arch repositories to build configuration..."
        cat >> "$BUILD_CONF" <<EOF

# Arch Repositories (Local Build)
[core]
Include = $MIRRORLIST_PATH

[extra]
Include = $MIRRORLIST_PATH

[multilib]
Include = $MIRRORLIST_PATH
EOF
    fi
else
    echo -e "${YELLOW}Warning: No active servers found in $MIRRORLIST_PATH.${NC}"
    echo "Skipping NeOS repository configuration. Using standard repositories only."
fi

# Run mkarchiso
echo -e "${GREEN}Building ISO...${NC}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" .

echo -e "${GREEN}Running ISO validation...${NC}"
bash tests/verify_iso_grub.sh
bash tests/verify_iso_smoketest.sh

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
