# Bootstrap Code Location

This document clarifies the location and implementation of bootstrap code within the NeOS project.

## Low-Level Bootloader Code (Assembly/C)

NeOS is an Arch Linux derivative built using the `archiso` tool. As such, this repository functions as an **archiso profile** and does not contain the source code for the low-level bootloader or kernel initialization.

The bootloader code (assembly and C code responsible for the initial system startup) is provided by upstream Arch Linux packages:

*   **GRUB**: Used for UEFI booting on x86_64. Source code is part of the `grub` package.
*   **Syslinux**: Used for BIOS booting on x86_64. Source code is part of the `syslinux` package.
*   **Linux Kernel**: The kernel initialization code is part of the `linux` package.

Configuration for these bootloaders lives in the archiso profile:
*   `profile/grub/grub.cfg`
*   `profile/syslinux/syslinux.cfg` and `profile/syslinux/archiso_sys.cfg`

For more details on bootloader configuration, see [BOOTLOADER.md](BOOTLOADER.md).

## System Bootstrap (Build Time)

The process of bootstrapping the ISO image (installing the base system into a chroot) is handled by the `mkarchiso` tool (part of the `archiso` package).

*   **Configuration**: The build process is configured via `profile/profiledef.sh`.
*   **Package Lists**: The live image's packages are listed in `profile/packages.x86_64`. `profile/bootstrap_packages.x86_64` is inherited from the upstream archiso template and is **not** consulted: `profiledef.sh` sets `buildmodes=('iso')` only.
*   **Execution**: The build is orchestrated by `build.sh` (the same entrypoint CI runs), which invokes `mkarchiso`.

## Live Environment Initialization

Scripts that run during the initialization of the live environment (after the kernel has booted) are located in:

*   `profile/airootfs/usr/local/bin/`: Contains custom scripts such as `neos-liveuser-setup` and `neos-autoupdate.sh`.
*   Standard system initialization is handled by `systemd` and `mkinitcpio` hooks provided by the base system packages.
