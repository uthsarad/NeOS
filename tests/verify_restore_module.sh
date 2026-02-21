#!/bin/bash
set -e

QML_FILE="airootfs/etc/calamares/branding/neos/neos-restore-module.qml"

echo "Verifying restore module implementation in $QML_FILE..."

if [ ! -f "$QML_FILE" ]; then
    echo "Error: QML file not found at $QML_FILE!"
    exit 1
fi

# Check for Timer
if grep -q "id: loadTimer" "$QML_FILE"; then
    echo "✅ Timer found."
else
    echo "❌ Timer 'loadTimer' missing!"
    exit 1
fi

# Check for Process and snapper command with secure path
if grep -q "Process {" "$QML_FILE" && grep -q "snapper list --xml > /root/snapshots.xml" "$QML_FILE"; then
    echo "✅ Process and snapper command with secure path found."
else
    echo "❌ Process or snapper command missing or using insecure path!"
    exit 1
fi

# Check for XmlListModel pointing to secure path
if grep -q "XmlListModel {" "$QML_FILE" && grep -q "source: \"file:///root/snapshots.xml\"" "$QML_FILE"; then
    echo "✅ XmlListModel source correct."
else
    echo "❌ XmlListModel source missing or incorrect!"
    exit 1
fi

# Check if snapper package is listed
if grep -q "snapper" packages.x86_64; then
    echo "✅ Snapper package is listed in packages.x86_64."
else
    echo "❌ Snapper package is missing from packages.x86_64!"
    exit 1
fi

echo "Restore module verification successful!"
