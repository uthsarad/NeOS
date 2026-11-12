#!/bin/bash
# Verify sudoers configuration and live user setup

SUDOERS_FILE="profile/airootfs/etc/sudoers.d/wheel"
LIVE_SETUP_FILE="profile/airootfs/usr/local/bin/neos-liveuser-setup"

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

if grep -q '"/etc/sudoers.d/wheel"\]="0:0:440"' profile/profiledef.sh \
   && grep -q 'chmod 0440 "\$ROOT/etc/sudoers.d/wheel"' profile/airootfs/usr/local/bin/neos-pacstrap; then
    echo "PASS: /etc/sudoers.d/wheel is enforced as mode 0440 on both live and installed systems."
else
    echo "FAIL: /etc/sudoers.d/wheel is missing 0440 permission enforcement."
    exit 1
fi

echo "All checks passed!"
exit 0
