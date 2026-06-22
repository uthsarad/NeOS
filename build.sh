#!/bin/bash
set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
    # Palette: Ensure logged error messages are clear and contain actionable steps for users.
    # Bolt: Ensure trap commands and error logging minimize subshell overhead.
    printf -- "\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[31m🚨 [%s] CRITICAL SCRIPT FAILURE\\e[0m\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[36m💡 DIAGNOSTICS:\\e[0m\n  • Failed Command: \"%s\"\n  • File / Line:    %s:%s\n  • Exit Status:    %s\n\n\\e[1m\\e[36m🔧 ACTIONABLE STEPS:\\e[0m\n  1. Inspect the system journal for detailed logs:\n     \\e[1mjournalctl -t neos-%s -n 50 --no-pager\\e[0m\n  2. Verify system state, permissions, and script configuration.\n\\e[1m\\e[31m================================================================================\\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$SCRIPT_NAME" "$line" "$err" "$SCRIPT_NAME" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks.
trap '_error_handler $? $LINENO' ERR


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

# Configuration
PROFILE_DIR="profile"
WORK_DIR="work"
OUT_DIR="out"

# Clean previous build artifacts if requested
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Work directory '$WORK_DIR' exists.${NC}"
    if [[ "${CI:-}" == "true" ]]; then
        echo "Running in CI environment. Removing $WORK_DIR..."
        rm -rf -- "$WORK_DIR"
    else
        read -p "Clean work directory before building? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing $WORK_DIR..."
            rm -rf -- "$WORK_DIR"
        fi
    fi
fi

# Generate temporary pacman.conf for build
echo "Generating temporary build configuration..."
BUILD_CONF="pacman-build.conf"

# Copy repository pacman.conf as base to ensure reproducible and secure builds
cp "$PROFILE_DIR/pacman.conf" "$BUILD_CONF"

# Update Arch Linux Keyring to prevent signature errors
echo "Updating Arch Linux Keyring..."
pacman -Sy --noconfirm -- archlinux-keyring

# Setup Chaotic-AUR keys
echo "Setting up Chaotic-AUR keys..."

# ⚡ Bolt: Check if key exists to avoid redundant imports and keyserver hits
if ! pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1; then
    echo "Importing Chaotic-AUR key..."
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 3056513887B78AEB
else
    echo "Chaotic-AUR key already imported."
fi

# Sentinel: [Security] Import and locally sign the package maintainer key required to verify the keyring package signature
if ! pacman-key --list-keys BFB13EA507EFDADB64A944813A40CB5E7E5CBC30 >/dev/null 2>&1; then
    echo "Importing Chaotic-AUR package maintainer key..."
    pacman-key --recv-key BFB13EA507EFDADB64A944813A40CB5E7E5CBC30 --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key BFB13EA507EFDADB64A944813A40CB5E7E5CBC30
fi

# ⚡ Bolt: Cache keyring package locally and only update if remote is newer
CHAOTIC_KEYRING_PKG="chaotic-keyring.pkg.tar.zst"
CHAOTIC_KEYRING_SIG="${CHAOTIC_KEYRING_PKG}.sig"

if [ ! -f "$CHAOTIC_KEYRING_PKG" ]; then
    echo "Downloading Chaotic-AUR keyring..."
    curl -L -o "$CHAOTIC_KEYRING_PKG" 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    curl -L -o "$CHAOTIC_KEYRING_SIG" 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst.sig'
else
    echo "Updating cached Chaotic-AUR keyring..."
    curl -L -z "$CHAOTIC_KEYRING_PKG" -o "$CHAOTIC_KEYRING_PKG" 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    curl -L -z "$CHAOTIC_KEYRING_SIG" -o "$CHAOTIC_KEYRING_SIG" 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst.sig'
fi

# Sentinel: [Security] Mitigate supply chain attacks by verifying package signature before installation
echo "Verifying Chaotic-AUR keyring signature..."
if ! pacman-key --verify "$CHAOTIC_KEYRING_SIG" "$CHAOTIC_KEYRING_PKG"; then
    echo -e "${RED}Error: Chaotic-AUR keyring signature verification failed!${NC}"
    exit 1
fi

# Install/Update
yes | pacman -U --noconfirm --needed --noprogressbar -- "$CHAOTIC_KEYRING_PKG"

# We point to the local mirrorlist using absolute path
REPO_ROOT="$PWD"
MIRRORLIST_PATH="$REPO_ROOT/$PROFILE_DIR/airootfs/etc/pacman.d/neos-mirrorlist"
CHAOTIC_MIRRORLIST_PATH="$REPO_ROOT/$PROFILE_DIR/airootfs/etc/pacman.d/chaotic-mirrorlist"

# Check if mirrorlist has active servers
if grep -q "^[[:space:]]*Server" "$MIRRORLIST_PATH"; then
    echo "Injecting NeOS mirrorlist path into build configuration..."
    # Replace the relative path in pacman.conf with the absolute path on the host
    # We use | as delimiter to avoid conflict with / in paths
    sed -i "s|/etc/pacman.d/neos-mirrorlist|$MIRRORLIST_PATH|g" "$BUILD_CONF"
    sed -i "s|/etc/pacman.d/chaotic-mirrorlist|$CHAOTIC_MIRRORLIST_PATH|g" "$BUILD_CONF"
else
    echo -e "${RED}Error: No active servers found in $MIRRORLIST_PATH.${NC}"
    echo "The build cannot proceed without valid repositories."
    exit 1
fi

# Run mkarchiso
echo -e "${GREEN}Building ISO...${NC}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" "$PROFILE_DIR"

echo -e "${GREEN}Running ISO validation...${NC}"
bash tests/verify_iso_grub.sh
bash tests/verify_iso_smoketest.sh

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
