#!/bin/bash
if [ ! -x "profile/airootfs/usr/local/bin/neos-hardware-setup" ]; then
    echo "Hardware setup script is not executable or missing."
    exit 1
fi
echo "Hardware setup script exists and is executable."

# neos-driver-manager also runs as a boot-time systemd unit with no display,
# where an unconditional kdialog fails and marks the unit failed on every
# boot. The graphical report must be guarded by a display check with a
# stdout/journal fallback.
DM="profile/airootfs/usr/local/bin/neos-driver-manager"
if [ ! -x "$DM" ]; then
    echo "Driver manager script is not executable or missing."
    exit 1
fi
if grep -q 'WAYLAND_DISPLAY' "$DM" && grep -q 'DISPLAY:-' "$DM"; then
    echo "  [PASS] driver-manager kdialog is display-guarded (boot-unit safe)"
else
    echo "[FAIL] driver-manager must guard kdialog with a DISPLAY/WAYLAND_DISPLAY check"
    exit 1
fi
# The install suggestion must name the prebuilt module for the NeOS LTS
# kernel, not the DKMS 'nvidia' package (which would compile in the session).
if grep -q 'nvidia-open-lts' "$DM"; then
    echo "  [PASS] driver-manager suggests the prebuilt nvidia-open-lts"
else
    echo "[FAIL] driver-manager should suggest 'nvidia-open-lts' for NVIDIA GPUs"
    exit 1
fi
