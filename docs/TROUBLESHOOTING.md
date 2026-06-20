# NeOS Troubleshooting Guide

## Build Failures
- Ensure you have the `archiso` and `squashfs-tools` packages installed.
- Check the `pacman.conf` used for building (e.g., `pacman.conf` in the profile directory) for incorrect settings like `SigLevel = Required DatabaseRequired` which might block the build.
- Review the `mkarchiso` output for missing dependencies or profile errors.

## Boot Issues
- Check the GRUB or Syslinux configuration for incorrect kernel parameters.
- If the system fails to mount the root filesystem, verify the Btrfs partition and subvolume layout.
- Ensure the appropriate microcode package (e.g., `intel-ucode` or `amd-ucode`) is loaded early in the boot process.

## Network Problems
- Verify that `NetworkManager` or `systemd-networkd` is running.
- Check for missing firmware packages (`linux-firmware`).
- If DNS resolution fails, check the `/etc/resolv.conf` file or the `systemd-resolved` status.

## Snapshot Rollback
- If the system is unbootable, use a live USB, chroot into the system, and restore a working Snapper snapshot.
- From a running system, use `snapper list` to identify a good snapshot and `snapper rollback <id>` to restore it.
- Ensure the Btrfs subvolumes are mounted correctly after rollback.

## Driver Issues
- Use the `neos-driver-manager` script to identify and install missing drivers.
- For graphics issues, check the Xorg or Wayland logs.
- Ensure the appropriate kernel modules are loaded using `lsmod`.
