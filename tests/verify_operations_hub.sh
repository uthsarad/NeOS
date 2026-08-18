#!/bin/bash
set -e

echo "Verifying NeOS Operations Hub..."

# Check if script exists and is executable
if [ ! -x "profile/airootfs/usr/local/bin/neos-operations-hub" ]; then
    echo "❌ Error: neos-operations-hub is missing or not executable."
    exit 1
fi
echo "✅ neos-operations-hub is present and executable."

# Check script syntax
if ! bash -n "profile/airootfs/usr/local/bin/neos-operations-hub"; then
    echo "❌ Error: neos-operations-hub contains syntax errors."
    exit 1
fi
echo "✅ neos-operations-hub syntax is valid."

# Check if desktop entry exists
if [ ! -f "profile/airootfs/usr/share/applications/neos-operations-hub.desktop" ]; then
    echo "❌ Error: neos-operations-hub.desktop is missing."
    exit 1
fi
echo "✅ neos-operations-hub.desktop is present."

echo "All NeOS Operations Hub tests passed!"
