# NeOS ISO Build Profile

This directory contains the `archiso` profile for NeOS.

## Prerequisites

*   Arch Linux (or derivative)
*   `archiso` package installed

## Setup

Before building, you must populate the bootloader configurations. These are standard configuration files that are typically copied from the `releng` profile.

1.  Copy the `efiboot` and `syslinux` directories from `/usr/share/archiso/configs/releng/` to this directory, merging/overwriting if necessary (but keep our directory structure).

    ```bash
    cp -r /usr/share/archiso/configs/releng/efiboot .
    cp -r /usr/share/archiso/configs/releng/syslinux .
    ```

## Building

Run the following command to build the ISO:

```bash
mkarchiso -v -w /tmp/archiso-work -o out .
```

## Notes

*   **Brave & Nomacs**: These packages are commented out in `packages.x86_64` because they reside in the AUR (or require a custom repository). To include them, you must set up a custom repo in `pacman.conf` or use a pre-built binary repo like Chaotic-AUR.
*   **Services**: `sddm` and `NetworkManager` are enabled via symlinks in `airootfs`.
