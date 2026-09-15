# NeOS Troubleshooting Guide

Welcome to the NeOS troubleshooting guide. This document provides solutions for common issues encountered while building or using NeOS.

## Build Failures

### "Target not found" during build
This usually means a package listed in `packages.x86_64` doesn't exist in the enabled repositories.
- Check your spelling.
- Check if the package was removed from Arch Linux upstream.

### Build fails with permission errors
Building the ISO requires root privileges. Ensure you are running `mkarchiso` with `sudo`.

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

## Display, Scaling & Input Issues

### Mouse pointer misaligned or staying at unrotated coordinates after screen rotation
In X11 environments, rotating the screen (`xrandr` or KDE Display Settings) rotates the visual buffer, but absolute pointing devices (VirtualBox/VMware tablet pointers, touchscreens, stylus digitizers) do not automatically transform their input matrices.
- **Automatic Fix:** NeOS includes `neos-display-sync`, which runs as a daemon at login (`neos-display-sync --daemon`) and monitors display rotation events, automatically synchronizing pointer coordinates 1:1.
- **Manual Sync:** Run `neos-display-sync` in a terminal or rotate directly via `neos-display-sync --rotate left|right|normal|inverted`.
- **Virtual Machine Tip:** In VirtualBox or VMware, disabling host "Mouse Integration" forces the guest to use relative mouse input, which also eliminates coordinate misalignment on rotated screens.

### Global display scaling not applying dynamically in KDE Plasma (X11)
Under X11, KDE Plasma 6 does not support dynamic Wayland-style fractional surface scaling for running applications without session restarts.
- **Applying Scale:** Use `neos-display-sync --scale <factor>` (e.g. `neos-display-sync --scale 1.25` for 125% / 120 DPI, or `1.5` for 150% / 144 DPI). This sets `Xft.dpi` via `xrdb`, updates KDE font/scale settings, and exports `QT_SCALE_FACTOR` and `GDK_DPI_SCALE`.
- Relaunch open applications or log out and log back in to fully apply the scaling across all toolkits.


