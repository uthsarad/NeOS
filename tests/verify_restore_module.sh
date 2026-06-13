#!/bin/bash
set -e

QML_FILE="profile/airootfs/etc/calamares/branding/neos/neos-restore-module.qml"

echo "Verifying QML restore module: $QML_FILE..."

if [[ ! -f "$QML_FILE" ]]; then
    echo "Error: QML file not found!"
    exit 1
fi

CONTENT="$(<"$QML_FILE")"

# Check for rollbackToSnapshot function
if [[ "$CONTENT" == *"function rollbackToSnapshot(snapshotNumber)"* ]]; then
    echo "✅ rollbackToSnapshot function found."
else
    echo "❌ rollbackToSnapshot function missing!"
    exit 1
fi

# Check for Process component
if [[ "$CONTENT" == *"Process {"* ]]; then
    echo "✅ Process component found."
else
    echo "❌ Process component missing!"
    exit 1
fi

# Check for snapper command
if [[ "$CONTENT" == *"snapper"* ]]; then
    echo "✅ snapper command found."
else
    echo "❌ snapper command missing!"
    exit 1
fi

# Check for config=root
if [[ "$CONTENT" == *"--config=root"* ]]; then
    echo "✅ --config=root parameter found."
else
    echo "❌ --config=root parameter missing!"
    exit 1
fi

echo "QML restore module verification successful!"
