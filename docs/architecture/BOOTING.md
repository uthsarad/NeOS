# Booting Process in NeOS

[← Back to Documentation Index](../README.md#documentation)

The starting code for the booting process in NeOS is primarily located within
`profile/grub/` and `profile/syslinux/`, configured via `profile/profiledef.sh`.

The live kernel is **`linux-lts`** (`vmlinuz-linux-lts` /
`initramfs-linux-lts.img`). Older revisions of this page named `vmlinuz-linux`,
which this profile does not ship.

## UEFI Booting (GRUB)

The UEFI boot process is handled by GRUB. The configuration file is:

*   **`profile/grub/grub.cfg`**: menu entries for booting NeOS in UEFI mode.
    The menu is shown for 3 seconds (`timeout=3`, `timeout_style=menu`) so
    Copy-to-RAM / Safe Graphics / Verbose are reachable without holding a key.
    ESC/SHIFT still interrupt.

Entries (BIOS and UEFI share the same set):

| Entry | What it does |
| :--- | :--- |
| **NeOS (LTS Kernel)** | Default. Quiet splash, overlay on the boot media (`copytoram=n`). |
| **NeOS (Copy to RAM)** | `copytoram=y` — the live image is copied into RAM and the USB stick can be removed. Needs enough RAM for the squashfs plus a 4G overlay. |
| **NeOS (Safe Graphics)** | `nomodeset`. Use when the desktop does not appear. |
| **NeOS (Verbose)** | No `quiet`/`splash`, `loglevel=7`. Use with `neos-doctor` when a boot hangs. |
| **NeOS (Accessibility - Speech)** | `accessibility=on` starts the live screen-reader stack. |

Every live entry passes `console=tty0 console=ttyS0,115200` so CI's QEMU smoke
test can read the `NEOS-BOOT-OK` marker from `neos-boot-probe.service`.

## BIOS Booting (Syslinux)

The BIOS boot process is handled by Syslinux in `profile/syslinux/`:

*   **`syslinux.cfg`**: dispatches PXE vs local boot.
*   **`archiso_sys.cfg`**: the same menu entries as GRUB, including Copy-to-RAM.
*   **`archiso_pxe.cfg`**: PXE.
*   **`archiso_head.cfg`**: 3 second timeout (`TIMEOUT 30`, units of 1/10 s).

## After the kernel

1. `mkinitcpio` hooks (`archiso`, `archiso_loop_mnt`, Plymouth) find the ISO
   (`archisolabel=NEOS_ISO`) and pivot onto the squashfs.
2. systemd's default target is `graphical.target`; SDDM autologs in `liveuser`
   to the X11 Plasma session (`plasmax11`).
3. If a volume labelled `cidata` / `NEOSCIDATA` is present,
   `neos-autoinstall` may start Calamares unattended — see
   [Unattended install](../user-guide/AUTOINSTALL.md).
4. Otherwise the welcome app offers Try / Install.

`neos-doctor` (and `neos-doctor --json`) reports whether `graphical.target`
and SDDM actually came up — the same evidence the ISO smoke test asserts.

## Profile Definition

*   **`profile/profiledef.sh`**: `bootmodes` lists GRUB (UEFI, including ia32)
    and Syslinux (BIOS). `iso_label="NEOS_ISO"` is what the bootloaders search
    for.
