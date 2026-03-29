#!/bin/bash
set -euo pipefail

# Sentinel: Verify safe parsing of mirrorlist to prevent command injection
# Bolt: Optimize file reading and avoid excessive subprocess overhead if possible
MIRRORS=$(grep '^[[:space:]]*Server[[:space:]]*=' airootfs/etc/pacman.d/neos-mirrorlist | head -n 5)

echo "$MIRRORS" | while read -r MIRROR_LINE; do
    # Extract the URL part after the equals sign and strip leading/trailing whitespace
    URL=$(echo "$MIRROR_LINE" | awk -F'=' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Strip $repo/os/$arch variables to just check the base URL
    BASE_URL=$(echo "$URL" | sed 's/\$repo\/os\/\$arch//')

    echo "Testing connectivity to: $BASE_URL"

    # Bolt: Ensure the connectivity check avoids excessive timeouts
    # Palette: Ensure the format of the logged error message is clear and includes actionable steps
    if ! curl -I -s --max-time 10 "$BASE_URL" > /dev/null; then
        echo -e "\n❌ ERROR: Failed to connect to $BASE_URL" >&2
        echo -e "💡 How to fix:" >&2
        echo -e "  1. Check your internet connection." >&2
        echo -e "  2. Verify the mirror is currently online." >&2
        echo -e "  3. If the mirror is permanently down, remove it from airootfs/etc/pacman.d/neos-mirrorlist." >&2
        echo -e "  4. Update the mirrorlist using a tool like reflector or rankmirrors.\n" >&2
        exit 1
    fi
done

echo "Mirrorlist connectivity verified successfully."
exit 0
