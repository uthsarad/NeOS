#!/bin/bash
<<<<<<< HEAD
# NeOS ISO build entrypoint — the single build path shared by local builds and
# CI (.github/workflows/build-iso.yml calls this script, it no longer
# re-implements the build inline; see reports/v2026.09.22/UPDATES_NEEDED.md C2).
#
# Usage: sudo ./build.sh [--ci] [--no-offline-repo]
#   --ci               non-interactive: always remove a stale work/ directory
#   --no-offline-repo  skip the offline install package repo (tools/gen-install-repo.sh)
#                      and the xorriso step that embeds it. CI uses this: the
#                      published ISOs install from the network, and embedding
#                      ~200 packages would balloon the build. The offline repo
#                      remains available to local builds, which is the only
#                      path that produces an offline-capable ISO (README).
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

CI_BUILD="false"
OFFLINE_REPO="true"

usage() {
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
    case "$arg" in
        --ci)              CI_BUILD="true" ;;
        --no-offline-repo) OFFLINE_REPO="false" ;;
        -h|--help)         usage; exit 0 ;;
        *)
            echo "Unknown option: $arg" >&2
            usage >&2
            exit 2
            ;;
    esac
done

# Every path below (profile/, work/, out/, tools/, tests/) is relative to the
# repository root, so run from there whatever the caller's directory is.
cd "$(dirname "$(readlink -f "$0")")"

SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

=======
set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"


>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
<<<<<<< HEAD
    # Do not leave build scratch inside the git-tracked tree (reports/v2026.09.18
    # M8): the offline repo and a half-written temporary ISO are both rebuilt
    # from scratch on the next run.
    rm -f "${TMP_ISO:-}" 2>/dev/null || true
    rm -rf "${REPO_ROOT:-.}/profile/install-repo" 2>/dev/null || true
    printf -- "\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[31m[CRITICAL] SCRIPT FAILURE: %s\\e[0m\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[36mDIAGNOSTICS:\\e[0m\n  • Failed Command: \"%s\"\n  • File / Line:    %s:%s\n  • Exit Status:    %s\n\n\\e[1m\\e[36mACTIONABLE STEPS:\\e[0m\n  1. Inspect the system journal for detailed logs:\n     \\e[1mjournalctl -t neos-%s -n 50 --no-pager\\e[0m\n  2. Verify system state, permissions, and script configuration.\n\\e[1m\\e[31m================================================================================\\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$SCRIPT_NAME" "$line" "$err" "$SCRIPT_NAME" >&2 || true
=======
    # Palette: Ensure logged error messages are clear and contain actionable steps for users.
    # Bolt: Ensure trap commands and error logging minimize subshell overhead.
    printf -- "
\e[1m\e[31m================================================================================\e[0m
\e[1m\e[31m[CRITICAL] SCRIPT FAILURE: %s\e[0m
\e[1m\e[31m================================================================================\e[0m
\e[1m\e[36mDIAGNOSTICS:\e[0m
  - Failed Command: \"%s\"
  - File / Line:    %s:%s
  - Exit Status:    %s

\e[1m\e[36mACTIONABLE STEPS:\e[0m
  1. Inspect the system journal for detailed logs:
     \e[1mjournalctl -t neos-%s -n 50 --no-pager\e[0m
  2. Check your system's network connectivity.
  3. Verify you have sufficient free disk space.
  4. Verify system state, permissions, and script configuration.
\e[1m\e[31m================================================================================\e[0m

" "$SCRIPT_NAME" "$cmd" "$SCRIPT_NAME" "$line" "$err" "$SCRIPT_NAME" >&2 || true
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

<<<<<<< HEAD
=======

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
trap '_error_handler $? $LINENO' ERR


# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting NeOS ISO Build Process...${NC}"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root.${NC}" >&2
  exit 1
fi

# Check for dependencies
if ! command -v mkarchiso &> /dev/null; then
<<<<<<< HEAD
    echo -e "${RED}Error: mkarchiso could not be found. Please install 'archiso' (sudo pacman -S archiso).${NC}" >&2
=======
    echo -e "${RED}Error: mkarchiso could not be found. Please install 'archiso'.${NC}" >&2
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    exit 1
fi

if ! command -v mksquashfs &> /dev/null; then
<<<<<<< HEAD
    echo -e "${RED}Error: mksquashfs could not be found. Please install 'squashfs-tools' (sudo pacman -S squashfs-tools).${NC}" >&2
=======
    echo -e "${RED}Error: mksquashfs could not be found. Please install 'squashfs-tools'.${NC}" >&2
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    exit 1
fi

# Sentinel: [Security] Ensure required compression dependencies are present for pipelines
if ! command -v zstd &> /dev/null; then
<<<<<<< HEAD
    echo -e "${RED}Error: zstd could not be found. Please install 'zstd' (sudo pacman -S zstd).${NC}" >&2
=======
    echo -e "${RED}Error: zstd could not be found. Please install 'zstd'.${NC}" >&2
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    exit 1
fi

# Configuration
PROFILE_DIR="profile"
WORK_DIR="work"
OUT_DIR="out"

# Clean previous build artifacts if requested
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Work directory '$WORK_DIR' exists.${NC}"
<<<<<<< HEAD
    if [[ "$CI_BUILD" == "true" || "${CI:-}" == "true" ]]; then
        echo "Running in CI mode. Removing $WORK_DIR..."
        rm -rf -- "$WORK_DIR"
    elif [[ ! -t 0 ]]; then
        # No TTY (e.g. piped/automated invocation): a bare `read` would hit EOF
        # and abort the whole build through the ERR trap. Skip the prompt and
        # keep the existing directory instead.
        echo "Not running interactively: keeping the existing $WORK_DIR (pass --ci to remove it)."
=======
    if [[ "${CI:-}" == "true" ]]; then
        echo "Running in CI environment. Removing $WORK_DIR..."
        rm -rf -- "$WORK_DIR"
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
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
# NOTE: this build is NOT hermetic -- it syncs the host's pacman databases,
# updates the host keyring package, and imports/lsigns third-party keys into
# the host keyring below. Run inside a container/nspawn (as CI does) if you do
# not want your host mutated.
echo -e "${YELLOW}Note: build updates the host keyring and imports signing keys into it.${NC}"
echo "Updating Arch Linux Keyring..."
<<<<<<< HEAD
pacman -Sy --noconfirm --needed -- archlinux-keyring
=======
pacman -Sy --noconfirm -- archlinux-keyring
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)

# Setup Chaotic-AUR keys
echo "Setting up Chaotic-AUR keys..."

# Bolt: [Performance] Cache keyring to avoid multiple pacman-key --list-keys subprocesses
CURRENT_KEYS="$(pacman-key --list-keys 2>/dev/null || true)"

# Check if key exists to avoid redundant imports and keyserver hits
if [[ "$CURRENT_KEYS" != *"3056513887B78AEB"* ]]; then
    echo "Importing Chaotic-AUR key..."
<<<<<<< HEAD
    pacman-key --recv-key 3056513887B78AEB --keyserver hkps://keyserver.ubuntu.com
=======
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    pacman-key --lsign-key 3056513887B78AEB
else
    echo "Chaotic-AUR key already imported."
fi

# Setup Garuda signing key (signs calamares-garuda in the [garuda] repo)
if [[ "$CURRENT_KEYS" != *"349BC7808577C592"* ]]; then
    echo "Importing Garuda signing key..."
<<<<<<< HEAD
    pacman-key --recv-key 349BC7808577C592 --keyserver hkps://keyserver.ubuntu.com
=======
    pacman-key --recv-key 349BC7808577C592 --keyserver keyserver.ubuntu.com
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    pacman-key --lsign-key 349BC7808577C592
else
    echo "Garuda key already imported."
fi

<<<<<<< HEAD
if [[ "$CURRENT_KEYS" != *"BFB13EA507EFDADB64A944813A40CB5E7E5CBC30"* ]]; then
    echo "Importing Chaotic-AUR package maintainer key..."
    pacman-key --recv-key BFB13EA507EFDADB64A944813A40CB5E7E5CBC30 --keyserver hkps://keyserver.ubuntu.com
=======
# Sentinel: [Security] Import and locally sign the package maintainer key required to verify the keyring package signature
if [[ "$CURRENT_KEYS" != *"BFB13EA507EFDADB64A944813A40CB5E7E5CBC30"* ]]; then
    echo "Importing Chaotic-AUR package maintainer key..."
    pacman-key --recv-key BFB13EA507EFDADB64A944813A40CB5E7E5CBC30 --keyserver keyserver.ubuntu.com
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
    pacman-key --lsign-key BFB13EA507EFDADB64A944813A40CB5E7E5CBC30
fi

# Cache keyring package locally and only update if remote is newer
CHAOTIC_KEYRING_PKG="chaotic-keyring.pkg.tar.zst"
CHAOTIC_KEYRING_SIG="${CHAOTIC_KEYRING_PKG}.sig"

# --retry: cdn-mirror.chaotic.cx intermittently returns 503, which previously
# failed the whole build on a single bad request. Fall back to geo-mirror
# (virtual/auto-routing, different backing infra) if cdn-mirror stays down
# across all retries -- a real outage, not just a blip, has been observed.
# Sentinel: [Security] Enforce strict HTTPS and TLS v1.2+ for curl to prevent protocol downgrade attacks
CURL_RETRY=(--retry 5 --retry-delay 3 --retry-all-errors --proto '=https' --tlsv1.2)
CHAOTIC_HOSTS=(
    'https://cdn-mirror.chaotic.cx/chaotic-aur'
    'https://geo-mirror.chaotic.cx/chaotic-aur'
)

neos_fetch_chaotic() {
    local name="$1" out="$2" ztime="$3" host
    for host in "${CHAOTIC_HOSTS[@]}"; do
        echo "Fetching $name from $host ..."
        if [[ -n "$ztime" ]]; then
            curl -fL "${CURL_RETRY[@]}" -z "$ztime" -o "$out" "$host/$name" && return 0
        else
            curl -fL "${CURL_RETRY[@]}" -o "$out" "$host/$name" && return 0
        fi
    done
    return 1
}

if [ ! -f "$CHAOTIC_KEYRING_PKG" ]; then
    echo "Downloading Chaotic-AUR keyring..."
    neos_fetch_chaotic chaotic-keyring.pkg.tar.zst "$CHAOTIC_KEYRING_PKG" ""
    neos_fetch_chaotic chaotic-keyring.pkg.tar.zst.sig "$CHAOTIC_KEYRING_SIG" ""
else
    echo "Updating cached Chaotic-AUR keyring..."
    neos_fetch_chaotic chaotic-keyring.pkg.tar.zst "$CHAOTIC_KEYRING_PKG" "$CHAOTIC_KEYRING_PKG"
    neos_fetch_chaotic chaotic-keyring.pkg.tar.zst.sig "$CHAOTIC_KEYRING_SIG" "$CHAOTIC_KEYRING_SIG"
fi

<<<<<<< HEAD
=======
# Sentinel: [Security] Mitigate supply chain attacks by verifying package signature before installation
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
echo "Verifying Chaotic-AUR keyring signature..."
if ! pacman-key --verify "$CHAOTIC_KEYRING_SIG" "$CHAOTIC_KEYRING_PKG"; then
    echo -e "${RED}Error: Chaotic-AUR keyring signature verification failed!${NC}"
    exit 1
fi

# We intentionally DO NOT install the chaotic-keyring to the host via pacman -U.
# The host already has the key imported via pacman-key above, which is enough
# for mkarchiso to verify packages. The ISO will install its own chaotic-keyring
# via packages.x86_64.

# Generate the build pacman.conf (shared with CI -- tools/gen-build-conf.sh is
# the single source of truth for this logic).
REPO_ROOT="$PWD"
echo "Generating temporary build configuration..."
bash tools/gen-build-conf.sh "$REPO_ROOT" "$REPO_ROOT/$BUILD_CONF"

# NOTE: GRUB uses the classic 'starfield' theme. On the ISO it is committed
# under profile/grub/themes/starfield/; on the installed disk it comes from the
# grub package natively. Neither needs a generated font, so there is nothing to
# build here.

# Generate the netinstall manifests (Calamares pacstrap package list + overlay
# copy manifest). Shared with CI -- tools/gen-manifests.sh is the single source
# of truth; a stale manifest means installed systems silently miss files.
bash tools/gen-manifests.sh "$REPO_ROOT"

# Bolt: [Performance] Optimize subprocess overhead in packaging and compression pipelines (Delegated by Architect)
# Run mkarchiso
<<<<<<< HEAD
#
# `yes ""` feeds blank answers to any prompt mkarchiso may emit. When mkarchiso
# exits it stops reading, so `yes` is killed by SIGPIPE — exit status 141 — and
# with `pipefail` that 141 becomes the *pipeline's* status, which the ERR trap
# would turn into a failed build moments after a successful one (observed as
# "Process completed with exit code 141" in the first CI run that executed this
# script). errexit/pipefail are therefore suspended around the pipeline and only
# mkarchiso's own status (PIPESTATUS[1]) is judged. The pre-unification CI build
# did exactly this; build.sh never had it, so the developer path aborted at the
# end of every successful build and nobody noticed because CI was not running
# this script at all (reports/v2026.09.22/UPDATES_NEEDED.md C2).
echo -e "${GREEN}Building ISO...${NC}"
set +e +o pipefail
yes "" | mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" "$PROFILE_DIR"
MKARCHISO_EXIT=${PIPESTATUS[1]:-$?}
set -e -o pipefail
if [[ "$MKARCHISO_EXIT" -ne 0 ]]; then
    echo -e "${RED}Error: mkarchiso failed with exit code $MKARCHISO_EXIT${NC}" >&2
    exit "$MKARCHISO_EXIT"
fi

# ---- Build offline install repo (local package cache for the ISO) ---------
# Downloads the full install closure for neos-packages.txt (targets + group
# members + recursive dependencies) and creates a pacman repo database.
# Reuses packages already sitting in the host pacman cache (where mkarchiso
# downloads through `pacstrap -c`) to avoid redundant downloads. This repo
# sits OUTSIDE the SquashFS — it gets added to the ISO root below — so it
# does not inflate the live environment.
if [[ "$OFFLINE_REPO" == "true" ]]; then
    echo -e "${YELLOW}Building offline install package repo...${NC}"
    bash tools/gen-install-repo.sh \
        --repo-dir "$REPO_ROOT/$PROFILE_DIR/install-repo" \
        --work-dir "$REPO_ROOT/$WORK_DIR" \
        --profile "$REPO_ROOT/$PROFILE_DIR" \
        --build-conf "$REPO_ROOT/$BUILD_CONF"

    # ---- Embed the install repo into the ISO ------------------------------
    # After mkarchiso produces the ISO, we add the local package repo as a new
    # directory on the ISO filesystem. This keeps packages accessible to the
    # installer at /run/archiso/bootmnt/neos/pkg/ without bloating the SquashFS.
    INSTALL_REPO="$REPO_ROOT/$PROFILE_DIR/install-repo"
    TMP_ISO=""
    # A failed xorriso run must not leave a *-with-repo.iso behind: it sorts
    # before the real image and used to be picked up by the first-glob ISO
    # consumers (reports/v2026.09.18 M5).
    trap 'rm -f "${TMP_ISO:-}"' EXIT
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
                TMP_ISO=""
                echo "Offline install repo added to ISO at /neos/pkg/"
            fi
        else
            echo -e "${YELLOW}Warning: xorriso not found or no ISO to patch. Install will need internet.${NC}"
        fi
        # Clean up the build-time repo (no longer needed)
        rm -rf "$INSTALL_REPO" 2>/dev/null || true
    fi
else
    echo -e "${YELLOW}--no-offline-repo: skipping the offline install package repo "
    echo -e "(the ISO will require a network connection to install).${NC}"
=======
echo -e "${GREEN}Building ISO...${NC}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" -C "$BUILD_CONF" "$PROFILE_DIR" < /dev/null

# ---- Build offline install repo (local package cache for the ISO) ---------
# Downloads all packages listed in neos-packages.txt and creates a pacman
# repo database. Reuses packages already cached by mkarchiso in work/pkgs/
# to avoid redundant downloads. This repo sits OUTSIDE the SquashFS -- it gets
# added to the ISO root below -- so it does not inflate the live environment.
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

# Bolt: Use bash native nullglob instead of a subshell and ls subprocess overhead
has_pkgs=0
shopt -s nullglob
for _ in "$INSTALL_REPO"/*.pkg.tar.zst; do
    has_pkgs=1
    break
done
shopt -u nullglob

if [[ -d "$INSTALL_REPO" ]] && (( has_pkgs )); then
    echo -e "${YELLOW}Adding offline package repo to ISO...${NC}"

    # Bolt: Replace find/sort/head/cut pipeline with native bash globbing and -nt
    ISO_PATH=""
    shopt -s nullglob
    for _iso in "$REPO_ROOT/$OUT_DIR"/*.iso; do
        [[ -z "$ISO_PATH" || "$_iso" -nt "$ISO_PATH" ]] && ISO_PATH="$_iso"
    done
    shopt -u nullglob

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
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
fi

echo -e "${GREEN}Running ISO validation...${NC}"
bash tests/verify_iso_grub.sh
REQUIRE_ISO=1 bash tests/verify_iso_calamares_libs.sh
bash tests/verify_iso_smoketest.sh

echo -e "${GREEN}Build complete! ISO is in $OUT_DIR${NC}"
