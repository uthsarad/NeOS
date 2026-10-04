# NeOS Handbook

Welcome to the NeOS Handbook! This guide is designed for everyone, from complete beginners to experienced developers, to understand, use, and contribute to NeOS.

## Table of Contents

1.  [Introduction](#introduction)
2.  [Prerequisites](#prerequisites)
3.  [Getting Started (User Guide)](#getting-started-user-guide)
4.  [Getting Started (Developer Guide)](#getting-started-developer-guide)
5.  [Project Structure](#project-structure)
6.  [Building the ISO](#building-the-iso)
7.  [Customization](#customization)
8.  [Troubleshooting](#troubleshooting)

## Introduction

NeOS (Next Evolution Operating System) is a curated, snapshot-based Arch Linux desktop distribution. It aims to provide a stable, predictable, and Windows-familiar experience using the KDE Plasma desktop environment.

Unlike a standard Arch Linux installation which is "Do It Yourself" (DIY), NeOS comes pre-configured with drivers, essential applications, and sensible defaults so you can start using it immediately.

## Prerequisites

### For Users (Installing NeOS)
*   **Hardware**: A 64-bit (x86_64) computer.
<<<<<<< HEAD
    *   *Architecture Limitations:* `x86_64` is the only supported architecture, including the full GUI experience, Calamares installer, snapshots, and ZRAM compression.
=======
    *   *Architecture Limitations:*
        *   `x86_64` is the only officially supported architecture for the full GUI experience (including the Calamares installer, snapshots, and ZRAM compression).
        *   `i686` and `aarch64` are experimental and lack the full GUI experience (including Calamares installer, snapshots, and ZRAM compression).
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
*   **Storage**: At least 20GB of free disk space (SSD recommended).
*   **Memory**: At least 4GB RAM (8GB+ recommended).
*   **Boot Mode**: UEFI (recommended) or Legacy BIOS.
*   **USB Drive**: A USB flash drive (8GB+) for the installer.

### For Developers (Building NeOS)
*   **Operating System**: Ideally Arch Linux or an Arch-based distribution. You can also build inside a container (Docker/Podman) on other Linux distros.
*   **Disk Space**: At least 10GB of free space for build artifacts.
*   **Software**: `archiso`, `git`, `make` (optional but helpful).
*   **Privileges**: Root access (sudo) is required to build the ISO.

## Getting Started (User Guide)

### 1. Download the ISO
Grab the latest release from our [Releases page](https://github.com/uthsarad/NeOS/releases).

### 2. Create Bootable Media
Flash the ISO to your USB drive using a tool like:
*   **Ventoy** (Recommended): Drag and drop the ISO file onto the drive.
*   **Rufus** (Windows): Select the ISO and write in "DD Image" mode if prompted.
*   **Etcher** (Cross-platform): Simple and safe.

### 3. Boot NeOS
Insert the USB drive, restart your computer, and enter the Boot Menu (usually F12, F11, or Del). Select your USB drive.

<<<<<<< HEAD
The firmware boot menu (GRUB on UEFI, Syslinux on BIOS) is shown for 3 seconds.
The default entry is fine on most hardware. Other entries:

*   **Copy to RAM** — loads the live image into memory so you can unplug the USB stick. Needs enough RAM.
*   **Safe Graphics** — `nomodeset`, when the desktop never appears.
*   **Verbose** — full kernel/systemd messages, for a hung boot.
*   **Accessibility** — screen reader.

If the live session comes up looking wrong, run **NeOS Doctor** from the
application menu (or `neos-doctor --json` in a terminal) and keep the report.

### 4. Install
Once booted, the NeOS welcome app starts automatically and offers **Try NeOS** or **Install NeOS**; picking Install launches the Calamares wizard (the desktop "Install NeOS" shortcut does the same, so you can reopen it at any point). Follow the on-screen instructions:
=======
### 4. Install
Once booted, the temporary installer session starts Calamares automatically. Use the desktop "Install NeOS" shortcut if you close the installer and need to open it again. Follow the on-screen instructions:
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
*   **Location**: Set your timezone.
*   **Keyboard**: Choose your layout.
*   **Partitions**: "Erase Disk" is easiest for a clean install. "Manual Partitioning" is for advanced users.
*   **Users**: Create your username and password.

<<<<<<< HEAD
Internet is optional: a locally built ISO (`sudo ./build.sh`) embeds an offline
package repo, and Calamares no longer refuses to continue without a network.
CI-published ISOs still install from the network.

For a hands-off install (second volume labelled `cidata` with
`autoinstall.yaml`), see **[Unattended install](AUTOINSTALL.md)**.

### 5. First Boot
After installation, remove the USB drive and reboot. You will be greeted by the NeOS login screen.

### 6. Installing More Software
Desktop applications are easiest to find in **Discover** (the software centre in the
app menu). From a terminal, any Arch package installs with `sudo pacman -S <name>`.

A fresh install includes a lean developer core: `base-devel` (compilers and `make`), `git`,
Python with `pip`, and Node.js with `npm`. Other toolchains are one command away:

| Toolchain | Command |
| :-- | :-- |
| Rust | `sudo pacman -S rust` |
| Go | `sudo pacman -S go` |
| Java | `sudo pacman -S jdk-openjdk` |
| .NET | `sudo pacman -S dotnet-sdk` |
| Ruby | `sudo pacman -S ruby` |
| PHP | `sudo pacman -S php composer` |
| C/C++ tooling | `sudo pacman -S clang cmake ninja gdb` |
| Docker | `sudo pacman -S docker docker-compose && sudo systemctl enable --now docker` |

=======
### 5. First Boot
After installation, remove the USB drive and reboot. You will be greeted by the NeOS login screen.

>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
## Getting Started (Developer Guide)

If you want to modify NeOS or build your own ISO, follow these steps.

### 1. Clone the Repository
```bash
<<<<<<< HEAD
git clone https://github.com/uthsarad/NeOS.git
=======
git clone https://github.com/NimuthuGanegoda/NeOS.git
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
cd NeOS
```

### 2. Install Dependencies
On Arch Linux:
```bash
sudo pacman -S archiso git
```

### 3. Build the ISO
The build process requires root privileges because it mounts filesystems and creates device nodes.
```bash
<<<<<<< HEAD
sudo ./build.sh
```
`build.sh` is the supported entrypoint: it generates the build `pacman.conf` and the Calamares netinstall manifests, runs `mkarchiso` against `profile/`, embeds the offline install package repository, and validates the resulting ISO.

Invoking `mkarchiso` directly is possible but skips those steps — in particular the profile path is `profile/`, not the repository root:

```bash
sudo mkarchiso -v -w work -o out profile
```
=======
sudo mkarchiso -v -w work -o out .
```
*   `-v`: Verbose output.
*   `-w work`: Directory for temporary work files.
*   `-o out`: Directory for the final ISO image.
*   `.`: The current directory (profile root).
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)

Once finished, the ISO will be in the `out/` directory.

## Project Structure

This repository is an **Archiso profile**. If you are new, focus on these key paths first:

| Path | Purpose | When you should edit it |
| --- | --- | --- |
<<<<<<< HEAD
| `profile/profiledef.sh` | Core Archiso profile settings (ISO label, publisher, build modes, file permissions). | You need to change identity, metadata, permissions, or boot profile behavior. |
| `build.sh` | Wrapper script to build the ISO with project defaults. | You want to change build flow (output/work directories, cleanup, build args). |
| `profile/packages.x86_64` | Package list for the supported architecture. | You are adding or removing software from the live image. |
| `profile/bootstrap_packages.*` | Left over from Arch upstream's profile template. Unused here: `profiledef.sh` sets `buildmodes=('iso')` only, so nothing reads it. | Nothing — edit `profile/packages.x86_64` instead. |
| `profile/pacman.conf` | Package manager configuration for the build environment (repos, signatures, options). | Repositories or package trust configuration must change. |
| `profile/airootfs/` | Files copied directly into the live root filesystem. | You are changing system defaults, services, scripts, installer behavior, or branding. |
| `profile/grub/` and `profile/syslinux/` | UEFI/BIOS bootloader menus and boot parameters. | You need to adjust boot entries, kernel parameters, or boot UX. |
=======
| `profiledef.sh` | Core Archiso profile settings (ISO label, publisher, build modes, file permissions). | You need to change identity, metadata, permissions, or boot profile behavior. |
| `build.sh` | Wrapper script to build the ISO with project defaults. | You want to change build flow (output/work directories, cleanup, build args). |
| `packages.x86_64` | Main package manifest for the supported architecture. | You are adding/removing software from the live image. |
| `packages.i686` / `packages.aarch64` | Experimental architecture package lists. | You are working on non-x86_64 experiments. |
| `bootstrap_packages.*` | Minimal package sets used during bootstrap stages. | You are changing early build/bootstrap dependencies. |
| `pacman.conf` | Package manager configuration for the build environment (repos, signatures, options). | Repositories or package trust configuration must change. |
| `airootfs/` | Files copied directly into the live root filesystem. | You are changing system defaults, services, scripts, installer behavior, or branding. |
| `grub/` and `syslinux/` | UEFI/BIOS bootloader menus and boot parameters. | You need to adjust boot entries, kernel parameters, or boot UX. |
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
| `tests/` | Verification scripts for profile integrity and release gates. | You are validating or extending quality checks. |
| `docs/` | Architecture, roadmap, mission, and operational documentation. | You are updating design intent, process, or contributor guidance. |
| `.github/workflows/` | CI pipelines that run checks/builds in automation. | You need to change automated build/test behavior. |

<<<<<<< HEAD
### `profile/airootfs/` quick map

`profile/airootfs/` is the most important directory for day-to-day system customization:

*   `profile/airootfs/etc/`: System configuration shipped in the live/install image (systemd units, security defaults, Calamares settings, kernel/sysctl tuning).
*   `profile/airootfs/usr/local/bin/`: Project-maintained operational scripts (for example, auto-update and maintenance helpers).
*   `profile/airootfs/etc/calamares/`: Installer modules and branding behavior.
*   `profile/airootfs/etc/pacman.d/`: Mirrorlists and package-manager hooks that run on package transactions.
=======
### `airootfs/` quick map

`airootfs/` is the most important directory for day-to-day system customization:

*   `airootfs/etc/`: System configuration shipped in the live/install image (systemd units, security defaults, Calamares settings, kernel/sysctl tuning).
*   `airootfs/usr/local/bin/`: Project-maintained operational scripts (for example, auto-update and maintenance helpers).
*   `airootfs/etc/calamares/`: Installer modules and branding behavior.
*   `airootfs/etc/pacman.d/`: Mirrorlists and package-manager hooks that run on package transactions.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)

### Safe change workflow

When modifying key structure files:

<<<<<<< HEAD
1. Update the source file(s) (for example `profile/packages.x86_64`, `profile/profiledef.sh`, or files under `profile/airootfs/`).
2. Run the relevant script(s) in `tests/` that validate your change area.
3. If boot behavior was modified, verify both `profile/grub/` and `profile/syslinux/` paths stay consistent.
=======
1. Update the source file(s) (for example `packages.x86_64`, `profiledef.sh`, or files under `airootfs/`).
2. Run the relevant script(s) in `tests/` that validate your change area.
3. If boot behavior was modified, verify both `grub/` and `syslinux/` paths stay consistent.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)
4. Document intent in `docs/` whenever a change affects architecture, defaults, or contributor workflow.

## Customization

### Adding Packages
<<<<<<< HEAD
Edit `profile/packages.x86_64` and add the package name on a new line.

### Changing Default Settings
Modify files under `profile/airootfs/etc/`. For example, the default wallpaper is `profile/airootfs/usr/share/backgrounds/neos-wallpaper.png` (referenced from the KDE and SDDM configuration). It is rendered by `tools/gen-wallpaper.py`; `tools/wallpaper-reference.html` is the design it reproduces.

### Custom Scripts
Place your scripts in `profile/airootfs/usr/local/bin/` and ensure they are executable. You can set permissions in `profile/profiledef.sh`.
=======
Edit `packages.x86_64` and add the package name on a new line.

### Changing Default Settings
Modify files in `airootfs/etc/`. For example, to change the default wallpaper, you might edit `airootfs/usr/share/wallpapers/`.

### Custom Scripts
Place your scripts in `airootfs/usr/local/bin/` and ensure they are executable. You can set permissions in `profiledef.sh`.
>>>>>>> 5772ff2 (Redirect Jules PRs to testing branch and prevent merges to main)

## Troubleshooting

For common issues regarding build failures, boot problems, network configuration, and snapshot rollbacks, please refer to the dedicated **[Troubleshooting Guide](TROUBLESHOOTING.md)**.
