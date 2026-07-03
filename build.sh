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

# Build pacman.conf path (generated below by tools/gen-build-conf.sh)
BUILD_CONF="pacman-build.conf"

# Update Arch Linux Keyring to prevent signature errors.
# NOTE: this build is NOT hermetic — it syncs the host's pacman databases,
# updates the host keyring package, and imports/lsigns third-party keys into
# the host keyring below. Run inside a container/nspawn (as CI does) if you do
# not want your host mutated.
echo -e "${YELLOW}Note: build updates the host keyring and imports signing keys into it.${NC}"
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

# Setup Garuda signing key (signs calamares-garuda in the [garuda] repo)
if ! pacman-key --list-keys 349BC7808577C592 >/dev/null 2>&1; then
    echo "Importing Garuda signing key..."
    pacman-key --recv-key 349BC7808577C592 --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 349BC7808577C592
else
    echo "Garuda key already imported."
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

# We intentionally DO NOT install the chaotic-keyring to the host via pacman -U.
# The host already has the key imported via pacman-key above, which is enough
# for mkarchiso to verify packages. The ISO will install its own chaotic-keyring
# via packages.x86_64.

# Generate the build pacman.conf (shared with CI — tools/gen-build-conf.sh is
# the single source of truth for this logic).
REPO_ROOT="$PWD"
echo "Generating temporary build configuration..."
bash tools/gen-build-conf.sh "$REPO_ROOT" "$REPO_ROOT/$BUILD_CONF"

# NOTE: GRUB uses the classic 'starfield' theme. On the ISO it is committed
# under profile/grub/themes/starfield/; on the installed disk it comes from the
# grub package natively. Neither needs a generated font, so there is nothing to
# build here.

# Generate the netinstall manifests (Calamares pacstrap package list + overlay
# copy manifest). Shared with CI — tools/gen-manifests.sh is the single source
# of truth; a stale manifest means installed systems silently miss files.
bash tools/gen-manifests.sh "$REPO_ROOT"

# Run mkarchiso
echo -e "${GREEN}Building ISO...${NC}"
yes "" | mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" "$PROFILE_DIR"

# ---- Build offline install repo (local package cache for the ISO) ---------
# Downloads all packages listed in neos-packages.txt and creates a pacman
# repo database. Reuses packages already cached by mkarchiso in work/pkgs/
# to avoid redundant downloads. This repo sits OUTSIDE the SquashFS — it gets
# added to the ISO root below — so it does not inflate the live environment.
echo -e "${YELLOW}Building offline install package repo...${NC}"
bash tools/gen-install-repo.sh \
    --repo-dir "$REPO_ROOT/$PROFILE_DIR/install-repo" \
    --work-dir "$REPO_ROOT/$WORK_DIR" \
    --profile "$REPO_ROOT/$PROFILE_DIR" \
    --build-conf "$REPO_ROOT/$BUILD_CONF"

# ---- Embed the install repo into the ISO ----------------------------------
# After mkarchiso produces the ISO, we add the local package repo as a new
# directory on the ISO filesystem. This keeps packages accessible to the
# installer at /run/archiso/bootmnt/neos/pkg/ without bloating the SquashFS.
INSTALL_REPO="$REPO_ROOT/$PROFILE_DIR/install-repo"
if [[ -d "$INSTALL_REPO" ]] && [[ -n "$(ls -A "$INSTALL_REPO"/*.pkg.tar.zst 2>/dev/null || true)" ]]; then
    echo -e "${YELLOW}Adding offline package repo to ISO...${NC}"
    ISO_PATH=$(find "$REPO_ROOT/$OUT_DIR" -maxdepth 1 -name '*.iso' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n "$ISO_PATH" ]] && command -v xorriso &>/dev/null; then
        # Create a temporary ISO with the repo added
        TMP_ISO="${ISO_PATH%.iso}-with-repo.iso"
        xorriso -indev "$ISO_PATH" \
                -outdev "$TMP_ISO" \
                -map "$INSTALL_REPO" /neos/pkg \
                -boot_image any replay 2>&1 | tail -n 5 || {
            echo -e "${YELLOW}Warning: Could not add repo to ISO. Install will still work with internet.${NC}"
            rm -f "$TMP_ISO" 2>/dev/null || true
        }
        if [[ -f "$TMP_ISO" ]]; then
            mv -f "$TMP_ISO" "$ISO_PATH"
            echo "Offline install repo added to ISO at /neos/pkg/"
        fi
    else
        echo -e "${YELLOW}Warning: xorriso not found or no ISO to patch. Install will need internet.${NC}"
    fi
    # Clean up the build-time repo (no longer needed)
    rm -rf "$INSTALL_REPO" 2>/dev/null || true
fi

echo -e "${GREEN}Running ISO validation...${NC}"
bash tests/verify_iso_grub.sh
REQUIRE_ISO=1 bash tests/verify_iso_calamares_libs.sh
bash tests/verify_iso_smoketest.sh

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
