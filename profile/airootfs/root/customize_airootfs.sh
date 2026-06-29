#!/usr/bin/env bash
# Runs inside the archiso chroot after all packages are installed.
# mkarchiso executes this automatically when it exists at this path.
#
# WHY THIS EXISTS: the liveuser must be baked into the squashfs so SDDM
# autologin works reliably. Creating the user at runtime via a systemd
# service introduces race conditions and can fail if the service errors —
# leaving SDDM with no autologin target, which drops the live session to TTY.
# Pre-creating the user here matches the approach used by Nyarch and other
# Arch-based desktop live ISOs.
set -euo pipefail

# At this point all packages are installed, so all system groups exist.
useradd -m -u 1000 -g users \
    -G wheel,video,audio,storage,power,rfkill,optical,scanner,lp \
    -s /usr/bin/zsh \
    liveuser

# No password: SDDM autologin handles session start; the user never types one.
passwd -d liveuser

# Sudoers: wheel members get passwordless sudo in the live environment so
# tools like gparted and pacman work without prompts during install.
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/zz-live-wheel
chmod 0440 /etc/sudoers.d/zz-live-wheel

# Belt-and-suspenders ownership — useradd -m sets it, but make it explicit.
chown -R liveuser:users /home/liveuser
