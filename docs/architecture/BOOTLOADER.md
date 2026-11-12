# Bootloader and Initramfs Defaults

[← Back to Documentation Index](../README.md#documentation)

NeOS configures GRUB and mkinitcpio defaults to improve early boot reliability across common VM hypervisors and filesystems. The settings below are conservative to avoid unnecessary probing while still supporting standard layouts.

## GRUB defaults
The GRUB configuration lives at `profile/airootfs/etc/default/grub` (installed systems) and `profile/grub/grub.cfg` (live ISO), preloading modules for standard partition tables and filesystems:
- `part_gpt`, `part_msdos` for partition discovery
- `btrfs`, `ext2`, `fat` for installed Btrfs (`/@`, `/@.snapshots`) and EFI System Partition layouts
- `grub-btrfsd` integration on installed Btrfs systems for booting read-only Snapper snapshots directly from GRUB

## Initramfs defaults
The initramfs configuration in `profile/airootfs/etc/mkinitcpio.conf` (live ISO) and `profile/airootfs/etc/mkinitcpio.conf.d/neos-snapshot-boot.conf` (installed systems) configures:
- `udev`, `autodetect`, `microcode`, `modconf`, `kms`, `keyboard`, `block`, `filesystems`, and `plymouth` hooks
- Btrfs and read-only snapshot boot overlay support (`grub-btrfs-overlayfs` where applicable)

## Low-Level Initialization & Assembly Code Location

This repository serves as an **archiso profile** and does not contain the source code for the Linux kernel or the bootloader (GRUB/Syslinux).

The low-level initialization code—including the assembly code responsible for the bootstrap phase, CPU mode transition, and virtual memory translation (page table setup)—resides in the upstream source repositories for these projects.

### Configuration vs. Source Code

- **Configuration (In this Repo):**
    - `profile/grub/grub.cfg`: Configures the live ISO GRUB boot menu and kernel command line arguments.
    - `profile/syslinux/syslinux.cfg`: Configures the live ISO Syslinux boot menu (for BIOS boot).
    - `profile/airootfs/etc/mkinitcpio.conf`: Configures live ISO initial ramdisk (`initramfs-linux-lts.img`) generation.

- **Source Code (External):**
    - **Linux Kernel:** Shipped via the official Arch Linux `linux-lts` package.
    - **Bootloaders:** Shipped via the official Arch Linux `grub` and `syslinux` packages.
