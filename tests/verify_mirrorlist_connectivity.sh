#!/bin/bash
set -euo pipefail

# Sentinel: Verify safe parsing of mirrorlist to prevent command injection
# Bolt: Optimize file reading and avoid excessive subprocess overhead if possible

# We use awk to parse the mirrorlist safely and efficiently.
# It extracts the base URL directly without the need for bash regex matching or subshells.
# It handles up to 5 mirrors.
# Sentinel: Added URL validation to ensure only valid HTTPS/HTTP URLs are processed, preventing injection.
PIDS=()
URLS=()

while read -r BASE_URL; do
    if [[ -n "$BASE_URL" ]]; then
        echo "Testing connectivity to: $BASE_URL"
        # Bolt: Ensure the connectivity check avoids excessive timeouts
        # Palette: Ensure the format of the logged error message is clear and includes actionable steps
        if ! curl -I -s --connect-timeout 2 --max-time 3 "$BASE_URL" > /dev/null; then
            echo -e "\n================================================================================" >&2
            echo -e "❌ ERROR: Failed to connect to $BASE_URL" >&2
            echo -e "================================================================================\n" >&2
            echo -e "💡 How to fix:" >&2
            echo -e "  1. Check your internet connection." >&2
            echo -e "  2. Verify the mirror is currently online." >&2
            echo -e "  3. If the mirror is permanently down, remove it from:" >&2
            echo -e "     airootfs/etc/pacman.d/neos-mirrorlist" >&2
            echo -e "  4. Update the mirrorlist using a tool like reflector or rankmirrors.\n" >&2
            echo -e "================================================================================\n" >&2
            exit 1
        fi
    fi
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
}' airootfs/etc/pacman.d/neos-mirrorlist)

FAILED=0
for i in "${!PIDS[@]}"; do
    if ! wait "${PIDS[i]}"; then
        FAILED=1
        BASE_URL="${URLS[i]}"
        # Palette: Ensure the format of the logged error message is clear and includes actionable steps
        echo -e "\n❌ ERROR: Failed to connect to $BASE_URL" >&2
        echo -e "💡 How to fix:" >&2
        echo -e "  1. Check your internet connection." >&2
        echo -e "  2. Verify the mirror is currently online." >&2
        echo -e "  3. If the mirror is permanently down, remove it from airootfs/etc/pacman.d/neos-mirrorlist." >&2
        echo -e "  4. Update the mirrorlist using a tool like reflector or rankmirrors.\n" >&2
    fi
done

if [[ $FAILED -ne 0 ]]; then
    exit 1
fi

echo "Mirrorlist connectivity verified successfully."
exit 0
