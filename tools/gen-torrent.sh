#!/bin/bash
# NeOS BitTorrent Generator
# Generates a .torrent file for the built ISO with public trackers and SourceForge web-seeding.

set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
    printf "\n\033[1;31m[CRITICAL] SCRIPT FAILURE: %s\033[0m\n" "$SCRIPT_NAME" >&2
    printf "  • Failed Command: \"%s\"\n  • File / Line:    %s:%s\n  • Exit Status:    %s\n\n" "$cmd" "$SCRIPT_NAME" "$line" "$err" >&2
    exit "$err"
}

trap '_error_handler $? $LINENO' ERR

TARGET_DIR="${1:-out}"
SOURCEFORGE_PROJECT="${SOURCEFORGE_PROJECT:-neos-linux}"
REF_NAME="${REF_NAME:-testing}"
TAG_VAL="${TAG_VAL:-latest}"

echo "=========================================="
echo "NeOS BitTorrent Generator ($SCRIPT_NAME)"
echo "Target directory: $TARGET_DIR"
echo "=========================================="

if ! command -v mktorrent >/dev/null 2>&1; then
    echo "::error::mktorrent is not installed. Please install mktorrent first."
    exit 1
fi

if [[ -f "$TARGET_DIR" && "$TARGET_DIR" == *.iso ]]; then
    ISO_PATH="$TARGET_DIR"
elif [[ -d "$TARGET_DIR" ]]; then
    ISO_PATH=$(find "$TARGET_DIR" -maxdepth 1 -name '*.iso' | sort | head -1)
else
    echo "::error::Target '$TARGET_DIR' is not a valid directory or ISO file."
    exit 1
fi

if [[ -z "${ISO_PATH:-}" || ! -f "$ISO_PATH" ]]; then
    echo "::error::No ISO file found in '$TARGET_DIR' to generate torrent for."
    exit 1
fi

ISO_DIR="$(cd "$(dirname "$ISO_PATH")" && pwd)"
ISO_BASENAME="$(basename "$ISO_PATH")"
TORRENT_PATH="${ISO_DIR}/${ISO_BASENAME}.torrent"
WEB_SEED_URL="https://downloads.sourceforge.net/project/${SOURCEFORGE_PROJECT}/${REF_NAME}/${TAG_VAL}/${ISO_BASENAME}"

echo "Target ISO:   $ISO_BASENAME"
echo "Output Path:  $TORRENT_PATH"
echo "Web Seed URL: $WEB_SEED_URL"

# Piece size 2^21 = 2MB (-l 21)
# Trackers: OpenTrackr, InternetWarriors, Desync
cd "$ISO_DIR"
mktorrent -v -l 21 \
    -a "udp://tracker.opentrackr.org:1337/announce" \
    -a "udp://tracker.internetwarriors.net:1337/announce" \
    -a "udp://exodus.desync.com:6969/announce" \
    -c "NeOS Linux $TAG_VAL ($REF_NAME)" \
    -w "$WEB_SEED_URL" \
    -o "$TORRENT_PATH" \
    "$ISO_BASENAME"

if [[ -s "$TORRENT_PATH" ]]; then
    echo "✅ BitTorrent file successfully created:"
    ls -lh "$TORRENT_PATH"
else
    echo "::error::Generated torrent file is missing or empty."
    exit 1
fi
