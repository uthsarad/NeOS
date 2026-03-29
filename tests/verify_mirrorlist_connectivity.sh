#!/bin/bash
set -euo pipefail

# Sentinel: Verify safe parsing of mirrorlist to prevent command injection
# Bolt: Optimize file reading and avoid excessive subprocess overhead if possible
MIRRORS=$(awk -F'=' '/^[[:space:]]*Server[[:space:]]*=/ {
    url = $2
    sub(/^[[:space:]]*/, "", url)
    sub(/[[:space:]]*$/, "", url)
    sub(/\$repo\/os\/\$arch/, "", url)
    print url
    if (++count == 5) exit
}' airootfs/etc/pacman.d/neos-mirrorlist)

echo "$MIRRORS" | while read -r BASE_URL; do
    echo "Testing connectivity to: $BASE_URL"

    # Bolt: Ensure the connectivity check avoids excessive timeouts
    # Palette: Ensure the format of the logged error message is clear and includes actionable steps
    if ! curl -I -s --max-time 10 "$BASE_URL" > /dev/null; then
        echo "Failed to connect to $BASE_URL"
        exit 1
    fi
done

echo "Mirrorlist connectivity verified successfully."
exit 0
