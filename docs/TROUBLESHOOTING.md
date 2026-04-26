# NeOS Troubleshooting Guide

Welcome to the NeOS troubleshooting guide. This document provides solutions for common issues encountered while building or using NeOS.

<!-- ⚡ Bolt: Consider adding an index/TOC if this file grows to avoid user scroll fatigue and improve navigation speed. -->
<!-- 🎨 Palette: Ensure heading hierarchy (H2, H3) remains consistent and scannable. -->

## Build Failures

### "Target not found" during build
This usually means a package listed in `packages.x86_64` doesn't exist in the enabled repositories.
- Check your spelling.
- Check if the package was removed from Arch Linux upstream.

### Build fails with permission errors
Building the ISO requires root privileges. Ensure you are running `mkarchiso` with `sudo`.

<!-- 🛡️ Sentinel: If adding workarounds for build issues, ensure we do not recommend building as root without understanding the implications or modifying permissions insecurely. -->

## Boot Issues

### ISO doesn't boot
- Check if Secure Boot is disabled in your BIOS/UEFI. NeOS may not support Secure Boot out of the box.
- Try a different USB port or write the ISO to a different USB drive.
- Verify the ISO checksum.

## Network Problems

### No Internet connection in the live environment
- Ensure your network cable is plugged in, or you are connected to a Wi-Fi network.
- Try restarting the NetworkManager service: `systemctl restart NetworkManager`.

## Snapshot Rollback

### How to rollback to a previous snapshot
NeOS uses Btrfs snapshots for system recovery. If your system fails to boot after an update, you can select a previous snapshot from the GRUB boot menu to boot into a known good state.

## Driver Issues

### Graphics drivers not loading
NeOS attempts to include common drivers. If your specific hardware is not supported, you may need to install the appropriate drivers manually after installation.

<!-- 🛡️ Sentinel: Avoid recommending `pacman -Sy` without a full upgrade when installing drivers to prevent partial upgrades. -->
