#!/bin/bash
set -euo pipefail

# Sentinel: Verify safe parsing of mirrorlist to prevent command injection
# Bolt: Optimize file reading and avoid excessive subprocess overhead if possible
count=0
while read -r line; do
    if [[ "$line" =~ ^[[:space:]]*Server[[:space:]]*=[[:space:]]*([^[:space:]]+) ]]; then
        BASE_URL="${BASH_REMATCH[1]}"
        BASE_URL="${BASE_URL//\$repo\/os\/\$arch/}"      # remove suffix

        echo "Testing connectivity to: $BASE_URL"

        # Bolt: Ensure the connectivity check avoids excessive timeouts
        # Palette: Ensure the format of the logged error message is clear and includes actionable steps
        if ! curl -I -s --connect-timeout 2 --max-time 3 "$BASE_URL" > /dev/null; then
            echo -e "\n❌ ERROR: Failed to connect to $BASE_URL" >&2
            echo -e "💡 How to fix:" >&2
            echo -e "  1. Check your internet connection." >&2
            echo -e "  2. Verify the mirror is currently online." >&2
            echo -e "  3. If the mirror is permanently down, remove it from airootfs/etc/pacman.d/neos-mirrorlist." >&2
            echo -e "  4. Update the mirrorlist using a tool like reflector or rankmirrors.\n" >&2
            exit 1
        fi

        count=$((count + 1))
        if (( count == 5 )); then
            break
        fi
    fi
done < airootfs/etc/pacman.d/neos-mirrorlist

echo "Mirrorlist connectivity verified successfully."
exit 0
