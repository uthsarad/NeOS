# Booting Process in NeOS

The starting code for the booting process in NeOS is primarily located within the `grub/` and `syslinux/` directories, configured via the `profiledef.sh` script.

## UEFI Booting (GRUB)

The UEFI boot process is handled by GRUB. The configuration file is located at:

*   **`grub/grub.cfg`**: This file defines the GRUB menu entries for booting NeOS Linux in UEFI mode. It specifies the kernel (`vmlinuz-linux`) and initramfs (`initramfs-linux.img`) locations, along with boot parameters.

## BIOS Booting (Syslinux)

The BIOS boot process is handled by Syslinux. The configuration files are located in the `syslinux/` directory:

*   **`syslinux/syslinux.cfg`**: The main configuration file that includes other configuration files.
*   **`syslinux/archiso_sys.cfg`**: Contains the menu entries for booting NeOS Linux in BIOS mode. It defines the kernel and initramfs paths similar to GRUB.
*   **`syslinux/archiso_pxe.cfg`**: Configuration for PXE booting.

## Profile Definition

The overall boot configuration is tied together in the `archiso` profile definition:

*   **`profiledef.sh`**: This script defines the `bootmodes` variable, which specifies which bootloaders are used for different architectures (e.g., `uefi.grub` for x86_64 and aarch64, `bios.syslinux` for x86_64 and i686). It also sets the ISO label used by the bootloaders to find the boot medium.
