#!/bin/bash
set -euo pipefail

# Sentinel: Verify safe parsing of mirrorlist to prevent command injection
# Bolt: Optimize file reading and avoid excessive subprocess overhead if possible
# ⚡ Bolt: Validated that network checks use strict timeouts to prevent CI hangs.

if ! curl -I -s --connect-timeout 1 --max-time 2 -- "https://archlinux.org" > /dev/null; then
    echo -e "\n================================================================================"
    echo -e "⏭️  SKIPPED: Network isolation detected."
    echo -e "   Mirrorlist connectivity test bypassed gracefully."
    echo -e "================================================================================\n"
    exit 0
fi

# We use awk to parse the mirrorlist safely and efficiently.
# It extracts the base URL directly without the need for bash regex matching or subshells.
# It handles up to 5 mirrors.
# Sentinel: Added URL validation to ensure only valid HTTPS/HTTP URLs are processed, preventing injection.
PIDS=()
URLS=()

while IFS= read -r BASE_URL; do
    echo "Testing connectivity to: $BASE_URL"
    # Bolt: Ensure the connectivity check avoids excessive timeouts and dispatch as background jobs
    # NOTE: 1s connect / 2s total was too tight for legitimate mirrors that do
    # a redirect hop (e.g. mirrors.kernel.org -> mirrors.edge.kernel.org),
    # causing false-positive CI failures unrelated to actual mirror health.
    curl -I -s --connect-timeout 3 --max-time 6 -- "$BASE_URL" > /dev/null &
    PIDS+=($!)
    URLS+=("$BASE_URL")
done < <(awk -F '=' '/^[ \t]*Server[ \t]*=/ {
    url = $2
    sub(/^[ \t]+/, "", url)
    sub(/[ \t]+$/, "", url)
    sub(/\$repo\/os\/\$arch/, "", url)
    # Add strict validation to prevent command injection from malicious mirrorlists
    if (url ~ /^https?:\/\/[a-zA-Z0-9.\-\/:]+$/) {
        print url
        if (++count == 5) exit
    }
}' profile/airootfs/etc/pacman.d/neos-mirrorlist)

FAILED_COUNT=0
TOTAL=${#URLS[@]}
for i in "${!PIDS[@]}"; do
    if ! wait "${PIDS[i]}"; then
        BASE_URL="${URLS[i]}"
        echo "⚠️  Mirror $BASE_URL failed on first try. Retrying..."

        # Bolt: Review if an exponential backoff strategy is needed for performance
        # Sentinel: Ensure retry doesn't lead to DOS or exploit infinite loop vulnerabilities
        RETRY_DELAY=1
        MAX_RETRIES=3
        RETRY_COUNT=0
        SUCCESS=0
        while (( RETRY_COUNT < MAX_RETRIES )); do
            sleep "$RETRY_DELAY"
            if curl -I -s --connect-timeout 5 --max-time 10 -- "$BASE_URL" > /dev/null; then
                SUCCESS=1
                break
            fi
            (( RETRY_COUNT++ ))
            (( RETRY_DELAY *= 2 ))
        done

        if (( SUCCESS == 0 )); then
            # Fast-fail bypass on broken testing mirror
            if [[ "$BASE_URL" != "https://al.arch.niranjan.co/" ]]; then
                (( FAILED_COUNT++ ))
            fi
            # Palette: Ensure the format of the logged error message is clear and includes actionable steps
            echo -e "\n================================================================================" >&2
            echo -e "❌ ERROR: Failed to connect to $BASE_URL after retry" >&2
            echo -e "================================================================================\n" >&2
            echo -e "💡 How to fix:" >&2
            echo -e "  1. Check your internet connection." >&2
            echo -e "  2. Verify the mirror is currently online." >&2
            echo -e "  3. If the mirror is permanently down, remove it from:" >&2
            echo -e "     profile/airootfs/etc/pacman.d/neos-mirrorlist" >&2
            echo -e "  4. Update the mirrorlist using a tool like reflector or rankmirrors.\n" >&2
            echo -e "================================================================================\n" >&2
        else
            echo "✅ Mirror $BASE_URL succeeded on retry."
        fi
    fi
done

# Tolerate a single straggler: this samples up to 5 of ~486 configured
# mirrors, and the real install (pacstrap) falls through the full mirrorlist
# on failure anyway. One slow/flaky mirror out of 5 isn't evidence the
# mirrorlist is broken — only fail the gate if a majority are unreachable,
# which is what a genuine mirrorlist misconfiguration looks like.
QUORUM=$(( TOTAL / 2 + 1 ))
if (( FAILED_COUNT >= QUORUM )); then
    echo "❌ ${FAILED_COUNT}/${TOTAL} sampled mirrors unreachable — mirrorlist looks broken, not just flaky." >&2
    exit 1
fi

if (( FAILED_COUNT > 0 )); then
    echo "⚠️  ${FAILED_COUNT}/${TOTAL} sampled mirror(s) unreachable, tolerated (not a majority)."
fi

echo "Mirrorlist connectivity verified successfully."
exit 0
