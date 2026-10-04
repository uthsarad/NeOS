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
# Correctness contract (the offline installer uses ONLY this repo, so it must
# be a self-contained transaction closure):
#   - The wanted set is the package list PLUS group members PLUS the full
#     recursive dependency closure. Matching files against the literal list
#     alone would delete every dependency (e.g. the `base` metapackage's
#     bash/glibc/coreutils) and offline installs would fail dep resolution.
#   - Downloads run against an EMPTY pacman dbpath so `pacman -Sw` fetches the
#     whole closure. Against the host db it skips whatever is already
#     installed on the build machine — and the install target is an empty
#     root that needs all of it.
#   - Cache reuse reads the HOST pacman cache (where mkarchiso - with `pacstrap
#     -c` - actually downloads to), not work/pkgs, which mkarchiso never writes.
#
# Output: REPO_DIR/
#   neos.db.tar.zst      pacman repository database
#   neos.files.tar.zst   package file list
#   *.pkg.tar.zst        the actual package files
#
# Usage: gen-install-repo.sh [options]
#   --repo-dir <path>    Output directory (default: profile/install-repo)
#   --work-dir <path>    mkarchiso work directory (legacy extra cache location)
#   --profile <path>     Profile directory (default: profile)
#   --build-conf <path>  pacman-build.conf for accessing repos
#   --skip-download      Only generate metadata, skip package download
#   --refresh            Delete cached packages first, then re-download all
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
            echo "  --work-dir <path>     mkarchiso work directory (legacy extra cache location)"
            echo "  --profile <path>      Profile directory (default: profile)"
            echo "  --build-conf <path>   Build pacman.conf path"
            echo "  --skip-download       Only generate metadata, skip package download"
            echo "  --refresh             Delete cached packages first, then re-download all"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ---- Setup -----------------------------------------------------------------
REPO_DIR="$(realpath "$REPO_DIR")"
PACKAGE_LIST="$PROFILE_DIR/airootfs/etc/calamares/neos-packages.txt"
LEGACY_CACHE="$WORK_DIR/pkgs"  # kept as a fallback; mkarchiso never writes here

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

# ---- Wanted set ------------------------------------------------------------
# Literal list members are always wanted. In download mode the set grows to
# the full install closure (group members + recursive dependencies); in
# --skip-download mode there are no sync DBs to expand from, so the literal
# list stands alone (this is also the mode tests/verify_install_repo.sh runs).
declare -A WANT=()
for pkg in "${PKGS[@]}"; do
    WANT["$pkg"]=1
done

# Exact-name lookup keyed by base package name (strip -VERSION-REL-ARCH).
# A prefix glob like "${pkg}-*.pkg.tar.zst" would wrongly match sibling
# packages (e.g. "base" matching "base-devel-..."), silently treating the
# real package as cached when it was never downloaded.
pkg_base_name() {
    local file="${1##*/}"
    file="${file%%.pkg.tar.*}"
    # Strip the trailing -VERSION-REL-ARCH triplet (dashes inside the name or
    # version survive: only the last three dash-separated segments go).
    file="${file%-*}"
    file="${file%-*}"
    file="${file%-*}"
    printf '%s' "$file"
}

# ---- Check what's already cached ------------------------------------------
# Runs for every invocation (including --skip-download), so the cached/missing
# accounting is exercised by tests/verify_install_repo.sh without a network.
CACHED_COUNT=0
MISSING_PKGS=()

# NOTE: use assignment form (VAR=$((VAR + 1))), never a bare ((VAR++)).
# Under `set -e` a post-increment evaluates to the OLD value, so the very
# first increment from 0 returns exit status 1 and aborts the whole script
# before any package is fetched.
declare -A REPO_HAVE=()
for f in "$REPO_DIR"/*.pkg.tar.zst; do
    [[ -f "$f" ]] || continue
    REPO_HAVE["$(pkg_base_name "$f")"]="$f"
done

for pkg in "${PKGS[@]}"; do
    if [[ -n "${REPO_HAVE[$pkg]:-}" ]]; then
        CACHED_COUNT=$((CACHED_COUNT + 1))
    else
        MISSING_PKGS+=("$pkg")
    fi
done

echo "Already cached: $CACHED_COUNT"
echo "Missing: ${#MISSING_PKGS[@]}"

# ---- Expand the wanted set to the full install closure ---------------------
# Batched `pacman -Si` (one call per dependency level) collects Depends On
# entries; `pacman -Sg` expands groups; `pacman -Sp` resolves virtual
# (provides-only) names to the real packages pacman would download. Every
# call is best-effort: with no usable sync DBs the closure simply stays the
# literal list instead of failing the build.
expand_closure() {
    local line grp mem grew level
    local -A seen=()
    local -a frontier=("${PKGS[@]}")

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        grp="${line%% *}"
        mem="${line#* }"
        if [[ -n "${WANT[$grp]:-}" && -n "$mem" && "$mem" != "$grp" ]]; then
            WANT["$mem"]=1
        fi
    done < <(pacman -Sg --config "$BUILD_CONF" 2>/dev/null || true)

    for ((level = 0; level < 30; level++)); do
        local -a query=()
        local dep
        grew=0
        for dep in "${frontier[@]}"; do
            if [[ -z "${seen[$dep]:-}" ]]; then
                seen["$dep"]=1
                query+=("$dep")
            fi
        done
        frontier=()
        [[ ${#query[@]} -eq 0 ]] && break
        while IFS= read -r dep; do
            [[ -z "$dep" ]] && continue
            if [[ -z "${WANT[$dep]:-}" ]]; then
                WANT["$dep"]=1
                frontier+=("$dep")
                grew=1
            fi
        done < <(pacman -Si --config "$BUILD_CONF" "${query[@]}" 2>/dev/null | awk '
            /^Name[[:space:]]+:/ { indep = 0; next }
            /^Depends On[[:space:]]+:/ {
                indep = 1
                line = $0
                sub(/^[^:]*:[[:space:]]*/, "", line)
                emit(line)
                next
            }
            indep && /^[[:space:]]/ { emit($0); next }
            { indep = 0 }
            function emit(line,   n, parts, i, tok) {
                n = split(line, parts, /[[:space:]]+/)
                for (i = 1; i <= n; i++) {
                    tok = parts[i]
                    if (tok == "" || tok == "None") continue
                    sub(/[<=>].*$/, "", tok)
                    if (tok != "") print tok
                }
            }
        ' || true)
        [[ "$grew" -eq 0 ]] && break
    done

    # Names nothing provides as a real package (virtual deps such as `sh`
    # are already covered when their provider is in the closure another way;
    # this catches the rest) resolve to whatever pacman would download.
    local -a known_arr=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && known_arr+=("$line")
    done < <(pacman -Si --config "$BUILD_CONF" "${!WANT[@]}" 2>/dev/null | awk '/^Name[[:space:]]+:/{print $3}' || true)
    local -A is_real=()
    local k
    for k in "${known_arr[@]}"; do
        is_real["$k"]=1
    done
    local -a virtuals=()
    local w
    for w in "${!WANT[@]}"; do
        if [[ -z "${is_real[$w]:-}" ]]; then
            virtuals+=("$w")
        fi
    done
    if [[ ${#virtuals[@]} -gt 0 ]]; then
        local url f n
        while IFS= read -r url; do
            [[ -z "$url" ]] && continue
            f="${url##*/}"
            f="${f%%.pkg.tar.*}"
            n="${f%-*}"; n="${n%-*}"; n="${n%-*}"
            if [[ -n "$n" ]]; then
                WANT["$n"]=1
            fi
        done < <(pacman -Sp --config "$BUILD_CONF" "${virtuals[@]}" 2>/dev/null || true)
    fi
    echo "Install closure: ${#WANT[@]} packages (targets + groups + dependencies)"
}

if [[ "$SKIP_DOWNLOAD" == false ]]; then
    if [[ "$FORCE_REFRESH" == true ]]; then
        echo "Refreshing: deleting cached packages..."
        rm -f "$REPO_DIR"/*.pkg.tar.zst "$REPO_DIR"/*.pkg.tar.zst.sig 2>/dev/null || true
        REPO_HAVE=()
        CACHED_COUNT=0
        MISSING_PKGS=("${PKGS[@]}")
    fi

    expand_closure

    # ---- Reuse packages from the host pacman cache -------------------------
    # mkarchiso downloads through the host cache (`pacstrap -c`), so after a
    # build the whole live closure sits there ready to copy instead of
    # re-download. $LEGACY_CACHE (work/pkgs) is also scanned: mkarchiso never
    # writes it, but an operator may have staged packages there by hand.
    REUSED_COUNT=0
    CACHE_DIRS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && CACHE_DIRS+=("$line")
    done < <(pacman-conf --config "$BUILD_CONF" CacheDir 2>/dev/null || true)
    CACHE_DIRS+=("/var/cache/pacman/pkg" "$LEGACY_CACHE")
    for dir in "${CACHE_DIRS[@]}"; do
        [[ -d "$dir" ]] || continue
        for f in "$dir"/*.pkg.tar.zst; do
            [[ -f "$f" ]] || continue
            base="$(pkg_base_name "$f")"
            if [[ -n "${WANT[$base]:-}" && -z "${REPO_HAVE[$base]:-}" ]]; then
                if cp -n "$f" "$REPO_DIR/" 2>/dev/null; then
                    REPO_HAVE["$base"]="$REPO_DIR/${f##*/}"
                    REUSED_COUNT=$((REUSED_COUNT + 1))
                fi
            fi
        done
    done
    echo "Reused from pacman cache: $REUSED_COUNT"

    # ---- Download the remaining closure from the repos ---------------------
    # Against an EMPTY dbpath nothing counts as "already installed", so -Sw
    # fetches the complete closure the empty install target needs. The full
    # list is always resolved (not just the missing names): that is what pulls
    # in dependencies. Files already sitting in the cachedir are skipped by
    # pacman itself, so re-runs only fetch what is actually absent.
    TMPDB="$(mktemp -d /tmp/neos-pacdb.XXXXXX)"
    trap 'rm -rf "$TMPDB"' EXIT
    if pacman -Sy --noconfirm --config "$BUILD_CONF" --dbpath "$TMPDB" 2>/dev/null; then
        pacman -Sw --noconfirm \
            --config "$BUILD_CONF" \
            --dbpath "$TMPDB" \
            --cachedir "$REPO_DIR" \
            "${PKGS[@]}" 2>/dev/null || {
            echo "Warning: Some packages failed to download. Install will still work with internet."
        }
    else
        echo "Warning: Could not sync databases. Install will still work with internet."
    fi
    rm -rf "$TMPDB"
    trap - EXIT
else
    echo "--skip-download: metadata only — no packages will be downloaded."
fi

# ---- Cleanup: remove packages outside the wanted closure ------------------
# Stale packages (removed from the list, or left by an interrupted run) must
# not linger: they would bloat the ISO and could shadow fresher downloads.
# Matching runs against the closure — never the literal list alone — so real
# dependencies and group members are kept. Runs BEFORE repo-add so the
# database doesn't reference deleted files.
#
# Download mode only: in --skip-download mode there are no sync DBs, so the
# wanted set is just the literal list — pruning against it would delete every
# dependency a previous full run had fetched.
CLEANED=0
if [[ "$SKIP_DOWNLOAD" == false ]]; then
    for f in "$REPO_DIR"/*.pkg.tar.zst; do
        [[ -f "$f" ]] || continue
        base_name="$(pkg_base_name "$f")"
        if [[ -z "${WANT[$base_name]:-}" ]]; then
            rm -f "$f" "${f}.sig" 2>/dev/null || true
            CLEANED=$((CLEANED + 1))
        fi
    done
    [[ "$CLEANED" -gt 0 ]] && echo "Cleaned $CLEANED stale package(s)"
fi

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
