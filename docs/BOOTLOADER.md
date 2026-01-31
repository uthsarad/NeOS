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
