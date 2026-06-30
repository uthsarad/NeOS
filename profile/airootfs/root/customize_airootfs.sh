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

# Generate the locale the live system is configured to use. /etc/locale.gen and
# /etc/locale.conf ship en_US.UTF-8 in the overlay, but nothing compiles the
# locale unless we run locale-gen here (stock archiso does this too). Without it
# the live session falls back to the C locale and apps emit locale warnings.
locale-gen

# Create the live user with just a primary group, then add the desktop
# supplementary groups one at a time and tolerate any that don't exist on this
# build. A hard, comma-separated `-G a,b,c` aborts the whole build under
# `set -e` if even one group is missing; this loop never breaks the build.
useradd -m -u 1000 -g users -s /usr/bin/zsh liveuser
for grp in wheel video audio storage power rfkill optical scanner lp input network; do
    if getent group "$grp" >/dev/null 2>&1; then
        gpasswd -a liveuser "$grp" >/dev/null 2>&1 || true
    fi
done

# No password: SDDM autologin handles session start; the user never types one.
passwd -d liveuser

# Sudoers: wheel members get passwordless sudo in the live environment so
# tools like gparted and pacman work without prompts during install.
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/zz-live-wheel
chmod 0440 /etc/sudoers.d/zz-live-wheel

# Belt-and-suspenders ownership — useradd -m sets it, but make it explicit.
chown -R liveuser:users /home/liveuser
