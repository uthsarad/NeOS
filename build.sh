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

# Copy repository pacman.conf as base to ensure reproducible and secure builds
cp pacman.conf "$BUILD_CONF"

# We point to the local mirrorlist using absolute path
REPO_ROOT=$(pwd)
MIRRORLIST_PATH="$REPO_ROOT/airootfs/etc/pacman.d/neos-mirrorlist"

# Check if mirrorlist has active servers
if grep -q "^[[:space:]]*Server" "$MIRRORLIST_PATH"; then
    echo "Injecting NeOS mirrorlist path into build configuration..."
    # Replace the relative path in pacman.conf with the absolute path on the host
    # We use | as delimiter to avoid conflict with / in paths
    sed -i "s|/etc/pacman.d/neos-mirrorlist|$MIRRORLIST_PATH|g" "$BUILD_CONF"
else
    echo -e "${RED}Error: No active servers found in $MIRRORLIST_PATH.${NC}"
    echo "The build cannot proceed without valid repositories."
    exit 1
fi

# Run mkarchiso
echo -e "${GREEN}Building ISO...${NC}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" .

echo -e "${GREEN}Running ISO validation...${NC}"
bash tests/verify_iso_grub.sh
bash tests/verify_iso_smoketest.sh

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
