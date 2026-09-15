# Bootloader and Initramfs Defaults

[← Back to Documentation Index](../README.md#documentation)

NeOS configures GRUB and mkinitcpio defaults to improve early boot reliability across common VM hypervisors and filesystems. The settings below are conservative to avoid unnecessary probing while still supporting standard layouts.

## GRUB defaults
The GRUB configuration lives at `airootfs/etc/default/grub` and includes preload modules for common partition tables and filesystems:
- `part_gpt`, `part_msdos` for partition discovery
- `ext2`, `btrfs`, `zfs` for common root filesystem types

Adjust `GRUB_PRELOAD_MODULES` as needed for your target environment.

## Initramfs defaults
The initramfs configuration in `airootfs/etc/mkinitcpio.conf` includes:
- `systemd` hook for early userspace init
- VM guest modules and filesystem drivers for `btrfs` and `zfs`

If you remove or replace filesystem support, ensure the corresponding modules are removed from `MODULES` to avoid boot-time errors.

## Low-Level Initialization & Assembly Code Location

This repository serves as an **archiso profile** and does not contain the source code for the Linux kernel or the bootloader (GRUB/Syslinux).

The low-level initialization code—including the assembly code responsible for the bootstrap phase, CPU mode transition, and virtual memory translation (page table setup)—resides in the upstream source repositories for these projects.

### Configuration vs. Source Code

- **Configuration (In this Repo):**
    - `grub/grub.cfg`: Configures the GRUB boot menu and kernel command line arguments.
    - `syslinux/syslinux.cfg`: Configures the Syslinux boot menu (for BIOS boot).
    - `airootfs/etc/mkinitcpio.conf`: Configures the initial ramdisk (initramfs) generation, specifying which kernel modules and hooks are included for early userspace initialization.

- **Source Code (External):**
    - **Linux Kernel:** The assembly code for entry points (e.g., `arch/x86/boot/` and `arch/x86/kernel/head_64.S`) is downloaded and built via the `linux-neos-pkgbuild` script.
    - **Bootloaders:** The source code for GRUB and Syslinux is provided by their respective Arch Linux packages.
