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

## Installer Problems

### Finding the installer log
The installer keeps its log on the machine; nothing is uploaded anywhere.

- **Live session:** `~/.cache/neos-installer.log` (also `/var/log/Calamares.log`
  if the installer ran as root).
- **Summary for a bug report:** run `neos-doctor` in a terminal (or `neos-doctor --json`).
  It reports the boot state, failed services and the installer log's path.

Attach the log to an issue at https://github.com/uthsarad/NeOS/issues. Check it first:
it contains your hostname, user name and disk layout.

## Network Problems

### No Internet connection in the live environment
- Ensure your network cable is plugged in, or you are connected to a Wi-Fi network.
- Try restarting the NetworkManager service: `systemctl restart NetworkManager`.

## Snapshot Rollback

### How to rollback to a previous snapshot
NeOS takes a Btrfs snapshot before and after every package transaction (including
automatic updates) and hourly timeline snapshots. Your home folder is a separate
subvolume and is never rolled back.

**If the system still starts:** open **NeOS Operations Hub → System Snapshot &
Rollback**, note the number of the snapshot from before the problem, enter it and
reboot. From a terminal, the same is:

```bash
sudo neos-rollback --list      # find the snapshot number
sudo neos-rollback 42          # make snapshot 42 the system root
sudo reboot
```

**If the system no longer reaches the desktop:** in the GRUB menu choose
**NeOS snapshots**, pick a snapshot from before the update and boot it. The
snapshot runs with a temporary writable layer, so it works normally but nothing
you change is kept. Once you are sure it is good, make it permanent with
`sudo neos-rollback <number>` and reboot.

The system as it was before the rollback is kept as a subvolume named
`@.pre-rollback-<date>`; `neos-rollback` prints how to delete it once you no
longer need it.

> Do not use `snapper rollback` on NeOS. It switches the Btrfs default
> subvolume, but NeOS mounts the root subvolume by name, so it has no effect.

## Driver Issues

### Graphics drivers not loading
NeOS attempts to include common drivers. If your specific hardware is not supported, you may need to install the appropriate drivers manually after installation.

## Display, Scaling & Input Issues

### Mouse pointer misaligned or staying at unrotated coordinates after screen rotation
This applies to X11 sessions only; on Wayland, KWin keeps input aligned itself. In X11 environments, rotating the screen (`xrandr` or KDE Display Settings) rotates the visual buffer, but absolute pointing devices (VirtualBox/VMware tablet pointers, touchscreens, stylus digitizers) do not automatically transform their input matrices.
- **Automatic Fix:** NeOS includes `neos-display-sync`, which runs as a daemon at login (`neos-display-sync --daemon`) and monitors display rotation events, automatically synchronizing pointer coordinates 1:1.
- **Manual Sync:** Run `neos-display-sync` in a terminal or rotate directly via `neos-display-sync --rotate left|right|normal|inverted`.
- **Virtual Machine Tip:** In VirtualBox or VMware, disabling host "Mouse Integration" forces the guest to use relative mouse input, which also eliminates coordinate misalignment on rotated screens.

### Choosing Wayland or X11
NeOS runs Plasma on **Wayland** on Intel, AMD and NVIDIA (proprietary driver)
graphics. It uses **X11** in virtual machines (Wayland freezes there without 3D
acceleration), with the Safe Graphics boot entry, and on other display drivers.
The choice is made at every boot by `neos-session-select`; `journalctl -u
neos-session-select` shows what it picked and why.

- **For one login:** pick *Plasma (Wayland)* or *Plasma (X11)* from the session
  menu on the login screen. SDDM remembers the choice.
- **Permanently:** set `SESSION=wayland` or `SESSION=x11` in
  `/etc/neos/session.conf` (default `auto`) and reboot.
- **For one boot:** add `neos.session=wayland` or `neos.session=x11` to the
  kernel command line (press `e` in the GRUB menu).

### Global display scaling not applying dynamically in KDE Plasma (X11)
Under X11, KDE Plasma 6 does not support dynamic Wayland-style fractional surface scaling for running applications without session restarts.
- **Applying Scale:** Use `neos-display-sync --scale <factor>` (e.g. `neos-display-sync --scale 1.25` for 125% / 120 DPI, or `1.5` for 150% / 144 DPI). This sets `Xft.dpi` via `xrdb`, updates KDE font/scale settings, and exports `QT_SCALE_FACTOR` and `GDK_DPI_SCALE`.
- Relaunch open applications or log out and log back in to fully apply the scaling across all toolkits.


