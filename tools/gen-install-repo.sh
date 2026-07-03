#!/bin/bash
# gen-install-repo.sh — NeOS offline install repo generator.
#
# Downloads ALL packages needed for installation (from neos-packages.txt) and
# creates a local pacman database so the installer can bootstrap the target
# system without an internet connection.
#
# The repo lives outside the SquashFS — it is added to the ISO root by
# build.sh after mkarchiso finishes — so it does NOT inflate the live
# environment image.
#
# Output: REPO_DIR/
#   neos.db.tar.zst      pacman repository database
#   neos.files.tar.zst   package file list
#   *.pkg.tar.zst        the actual package files
#
# Usage: gen-install-repo.sh [options]
#   --repo-dir <path>    Output directory (default: profile/install-repo)
#   --work-dir <path>    mkarchiso work directory (reuses cached packages)
#   --profile <path>     Profile directory (default: profile)
#   --build-conf <path>  pacman-build.conf for accessing repos
#   --skip-download      Only generate metadata, skip package download
#   --refresh            Force fresh download even if cached
#
# Requires: pacman, repo-add (from pacman-contrib), and network access.

set -euo pipefail

SCRIPT_NAME="${0##*/}"

# ---- Defaults --------------------------------------------------------------
REPO_DIR="profile/install-repo"
WORK_DIR="work"
PROFILE_DIR="profile"
BUILD_CONF="pacman-build.conf"
SKIP_DOWNLOAD=false
FORCE_REFRESH=false

# ---- Parse arguments -------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo-dir)     REPO_DIR="$2"; shift 2 ;;
        --work-dir)     WORK_DIR="$2"; shift 2 ;;
        --profile)      PROFILE_DIR="$2"; shift 2 ;;
        --build-conf)   BUILD_CONF="$2"; shift 2 ;;
        --skip-download) SKIP_DOWNLOAD=true; shift ;;
        --refresh)      FORCE_REFRESH=true; shift ;;
        --help|-h)
            echo "Usage: $SCRIPT_NAME [options]"
            echo "  --repo-dir <path>     Output directory (default: profile/install-repo)"
            echo "  --work-dir <path>     mkarchiso work directory (reuses cached packages)"
            echo "  --profile <path>      Profile directory (default: profile)"
            echo "  --build-conf <path>   Build pacman.conf path"
            echo "  --skip-download       Only generate metadata, skip package download"
            echo "  --refresh             Force fresh download"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ---- Setup -----------------------------------------------------------------
REPO_DIR="$(realpath "$REPO_DIR")"
PACKAGE_LIST="$PROFILE_DIR/airootfs/etc/calamares/neos-packages.txt"
PACMAN_CACHE="$WORK_DIR/pkgs"  # mkarchiso caches packages here

mkdir -p "$REPO_DIR"

# ---- Resolve build pacman.conf ---------------------------------------------
if [[ ! -f "$BUILD_CONF" ]]; then
    echo "Generating build pacman.conf..."
    bash tools/gen-build-conf.sh "$PWD" "$BUILD_CONF"
fi

if [[ ! -f "$BUILD_CONF" ]]; then
    echo "Error: Build pacman.conf not found at $BUILD_CONF"
    exit 1
fi

# ---- Read package list ----------------------------------------------------
if [[ ! -f "$PACKAGE_LIST" ]]; then
    echo "Error: Package list not found at $PACKAGE_LIST"
    echo "Run tools/gen-manifests.sh first."
    exit 1
fi

mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$PACKAGE_LIST")
echo "Found ${#PKGS[@]} packages to cache"

if [[ ${#PKGS[@]} -eq 0 ]]; then
    echo "Error: Package list is empty"
    exit 1
fi

# ---- Check what's already cached ------------------------------------------
CACHED_COUNT=0
MISSING_PKGS=()

if [[ "$SKIP_DOWNLOAD" == false ]]; then
    for pkg in "${PKGS[@]}"; do
        # Check if any version of this package exists in the repo
        found=0
        for f in "$REPO_DIR"/"${pkg}"-*.pkg.tar.zst; do
            if [[ -f "$f" ]]; then
                found=1
                break
            fi
        done
        if [[ "$found" -eq 0 ]]; then
            MISSING_PKGS+=("$pkg")
        else
            ((CACHED_COUNT++))
        fi
    done

    echo "Already cached: $CACHED_COUNT"
    echo "Missing: ${#MISSING_PKGS[@]}"

    if [[ ${#MISSING_PKGS[@]} -gt 0 || "$FORCE_REFRESH" == true ]]; then
        # ---- First, try to reuse packages from mkarchiso's cache ------------
        REUSED_COUNT=0
        DOWNLOAD_PKGS=()

        if [[ -d "$PACMAN_CACHE" ]]; then
            echo "Checking mkarchiso cache at $PACMAN_CACHE..."
            for pkg in "${MISSING_PKGS[@]}"; do
                found=0
                for f in "$PACMAN_CACHE"/"${pkg}"-*.pkg.tar.zst; do
                    if [[ -f "$f" ]]; then
                        cp -n "$f" "$REPO_DIR/" 2>/dev/null || true
                        found=1
                        ((REUSED_COUNT++))
                        break
                    fi
                done
                if [[ "$found" -eq 0 ]]; then
                    DOWNLOAD_PKGS+=("$pkg")
                fi
            done
            echo "Reused from mkarchiso cache: $REUSED_COUNT"
        else
            DOWNLOAD_PKGS=("${MISSING_PKGS[@]}")
        fi

        # ---- Download remaining missing packages from repos -----------------
        if [[ ${#DOWNLOAD_PKGS[@]} -gt 0 ]]; then
            echo "Downloading ${#DOWNLOAD_PKGS[@]} packages from repos..."
            pacman -Sw --noconfirm \
                --config "$BUILD_CONF" \
                --cachedir "$REPO_DIR" \
                "${DOWNLOAD_PKGS[@]}" || {
                echo "Warning: Some packages failed to download. Install will still work with internet."
            }
        fi

        # ---- Force refresh: re-download all if requested -------------------
        if [[ "$FORCE_REFRESH" == true ]]; then
            echo "Refreshing all packages..."
            pacman -Sw --noconfirm \
                --config "$BUILD_CONF" \
                --cachedir "$REPO_DIR" \
                "${PKGS[@]}" || true
        fi
    fi
fi

# ---- Cleanup: remove stale packages not in the package list --------------
# This prevents old packages from lingering when the package list changes.
# Runs BEFORE repo-add so the database doesn't reference deleted files.
CLEANED=0
for f in "$REPO_DIR"/*.pkg.tar.zst; do
    [[ -f "$f" ]] || continue
    pkg_name="${f##*/}"
    # Strip version to get the base package name
    # pacman package format: <name>-<version>-<arch>.pkg.tar.zst
    base_name="${pkg_name%%-[0-9]*}"
    found=0
    for wanted in "${PKGS[@]}"; do
        if [[ "$base_name" == "$wanted" ]]; then
            found=1
            break
        fi
    done
    if [[ "$found" -eq 0 ]]; then
        rm -f "$f" "${f}.sig" 2>/dev/null || true
        ((CLEANED++))
    fi
done
[[ "$CLEANED" -gt 0 ]] && echo "Cleaned $CLEANED stale package(s)"

# ---- Generate pacman repository database -----------------------------------
echo "Generating package database..."
cd "$REPO_DIR"

# Remove any stale databases
rm -f neos.db* neos.files* 2>/dev/null || true

# Create repo database with all packages (stale packages already removed above)
repo-add --quiet neos.db.tar.zst ./*.pkg.tar.zst 2>/dev/null || {
    echo "Warning: repo-add failed. Some packages may be missing."
    echo "Install will still work with internet connection."
}

# ---- Report ----------------------------------------------------------------
PKG_COUNT=$(find "$REPO_DIR" -name '*.pkg.tar.zst' 2>/dev/null | wc -l)
DB_SIZE=$(du -sh "$REPO_DIR" 2>/dev/null | cut -f1 || echo "0")

echo ""
echo "========== Install Repo Summary =========="
echo "  Packages cached:  $PKG_COUNT"
echo "  Repo size:        $DB_SIZE"
echo "  Repo location:    $REPO_DIR"
echo "=========================================="
echo ""
echo "This repo will be added to the ISO by build.sh."
echo "During installation, it provides offline package access."
