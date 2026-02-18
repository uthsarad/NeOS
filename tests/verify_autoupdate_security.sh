#!/bin/bash
# Verify that neos-autoupdate.sh contains a symlink check for the log file
# This is a security check to prevent privilege escalation via log file symlinking

SCRIPT_PATH="airootfs/usr/local/bin/neos-autoupdate.sh"
CHECK_PATTERN="if [ -L \"\$LOG_FILE\" ]; then"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ $SCRIPT_PATH not found!"
    exit 1
fi

# Use grep to search for the specific security check
if grep -Fq "$CHECK_PATTERN" "$SCRIPT_PATH"; then
    echo "✅ FIX VERIFIED: Symlink check found in neos-autoupdate.sh"
    exit 0
else
    echo "❌ SECURITY FAILURE: Symlink check missing in neos-autoupdate.sh!"
    exit 1
fi
