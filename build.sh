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

# Check for Chaotic-AUR configuration
# We need chaotic-aur for linux-lqx
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
    echo -e "${YELLOW}Warning: Chaotic-AUR repository not detected in /etc/pacman.conf.${NC}"
    echo "NeOS requires packages from Chaotic-AUR (e.g., linux-lqx)."
    echo "Please configure Chaotic-AUR on your host system before building, or ensure your custom mirrorlist includes it."
    read -p "Do you want to proceed anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for Chaotic-AUR keys
# Key ID: 3056513887B78AEB
if ! pacman-key --list-keys 3056513887B78AEB &> /dev/null; then
    echo -e "${YELLOW}Warning: Chaotic-AUR signing key (3056513887B78AEB) not found in keyring.${NC}"
    echo "This may cause package verification failures."
    echo "Please import and sign the key: "
    echo "  pacman-key --recv-key 3056513887B78AEB"
    echo "  pacman-key --lsign-key 3056513887B78AEB"
    read -p "Do you want to proceed anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
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

# Append NeOS repositories if not already present
# We point to the local mirrorlist using absolute path
REPO_ROOT=$(pwd)
MIRRORLIST_PATH="$REPO_ROOT/airootfs/etc/pacman.d/neos-mirrorlist"

if ! grep -q "neos-core" "$BUILD_CONF"; then
    cat >> "$BUILD_CONF" <<EOF

# NeOS Repositories (Local Build)
[neos-core]
Include = $MIRRORLIST_PATH

[neos-desktop]
Include = $MIRRORLIST_PATH

[neos-extra]
Include = $MIRRORLIST_PATH

[neos-multilib]
Include = $MIRRORLIST_PATH
EOF
fi

# Run mkarchiso
echo -e "${GREEN}Building ISO...${NC}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" .

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
