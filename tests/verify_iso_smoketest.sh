#!/bin/bash
set -e

OUT_DIR="out"

if [ ! -d "$OUT_DIR" ]; then
    echo "❌ Missing output directory: $OUT_DIR"
    echo "Run: sudo ./build.sh"
    exit 1
fi

ISO_COUNT=$(find "$OUT_DIR" -maxdepth 1 -type f -name "*.iso" | wc -l)

if [ "$ISO_COUNT" -eq 0 ]; then
    echo "❌ No ISO found in $OUT_DIR"
    echo "Run: sudo ./build.sh"
    exit 1
fi

echo "✅ Found $ISO_COUNT ISO file(s) in $OUT_DIR"
find "$OUT_DIR" -maxdepth 1 -type f -name "*.iso" -printf "%f (%s bytes)\n"

echo "ISO smoke test passed."
