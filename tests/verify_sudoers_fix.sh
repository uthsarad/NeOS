#!/bin/bash
# Verify sudoers configuration and live user setup

SUDOERS_FILE="airootfs/etc/sudoers.d/wheel"
LIVE_SETUP_FILE="airootfs/usr/local/bin/neos-liveuser-setup"

echo "Checking sudoers configuration..."

# Check if NOPASSWD is removed from sudoers file
if grep -q "NOPASSWD" "$SUDOERS_FILE"; then
    echo "FAIL: $SUDOERS_FILE still contains NOPASSWD."
    grep "NOPASSWD" "$SUDOERS_FILE"
    exit 1
else
    echo "PASS: NOPASSWD removed from $SUDOERS_FILE."
fi

echo "Checking live user setup..."

# Check if live user setup creates the temporary override
if grep -q "echo.*NOPASSWD.*zz-live-wheel" "$LIVE_SETUP_FILE"; then
    echo "PASS: $LIVE_SETUP_FILE creates temporary override."
else
    echo "FAIL: $LIVE_SETUP_FILE does not create temporary override."
    exit 1
fi

echo "All checks passed!"
exit 0
