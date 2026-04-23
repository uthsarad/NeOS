#!/bin/bash
set -e

OUT_DIR="out"

if [[ ! -d "$OUT_DIR" ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "❌ Missing output directory: $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    else
        echo -e "\n================================================================================"
        echo -e "⏭️  SKIPPED: Missing output directory: $OUT_DIR."
        echo -e "   ISO smoke test bypassed gracefully as REQUIRE_ISO!=1."
        echo -e "================================================================================\n"
        exit 0
    fi
fi

shopt -s nullglob
files=("$OUT_DIR"/*.iso)
ISO_COUNT=${#files[@]}

if [[ "$ISO_COUNT" -eq 0 ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "❌ No ISO found in $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    else
        echo -e "\n================================================================================"
        echo -e "⏭️  SKIPPED: No ISO found in $OUT_DIR."
        echo -e "   ISO smoke test bypassed gracefully as REQUIRE_ISO!=1."
        echo -e "================================================================================\n"
        exit 0
    fi
fi

echo "✅ Found $ISO_COUNT ISO file(s) in $OUT_DIR"
for file in "${files[@]}"; do
    # Bolt: Use native bash globbing and stat instead of slow find subprocesses
    size=$(stat -c%s "$file")
    name=$(basename "$file")
    echo "$name ($size bytes)"
done

echo "ISO smoke test passed."
