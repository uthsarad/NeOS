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
*   **Hardware**: A 64-bit (x86_64) computer. (x86_64 is the only officially supported architecture; i686 and aarch64 are experimental).
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
Grab the latest release from our [Releases page](https://github.com/neos-project/neos/releases).

### 2. Create Bootable Media
Flash the ISO to your USB drive using a tool like:
*   **Ventoy** (Recommended): Drag and drop the ISO file onto the drive.
*   **Rufus** (Windows): Select the ISO and write in "DD Image" mode if prompted.
*   **Etcher** (Cross-platform): Simple and safe.

### 3. Boot NeOS
Insert the USB drive, restart your computer, and enter the Boot Menu (usually F12, F11, or Del). Select your USB drive.

### 4. Install
Once booted into the live environment, you'll see a "Welcome to NeOS" window. Click "Install NeOS" to launch the Calamares installer. Follow the on-screen instructions:
*   **Location**: Set your timezone.
*   **Keyboard**: Choose your layout.
*   **Partitions**: "Erase Disk" is easiest for a clean install. "Manual Partitioning" is for advanced users.
*   **Users**: Create your username and password.

### 5. First Boot
After installation, remove the USB drive and reboot. You will be greeted by the NeOS login screen.

## Getting Started (Developer Guide)

If you want to modify NeOS or build your own ISO, follow these steps.

### 1. Clone the Repository
```bash
git clone https://github.com/neos-project/neos.git
cd neos
```

### 2. Install Dependencies
On Arch Linux:
```bash
sudo pacman -S archiso git
```

### 3. Build the ISO
The build process requires root privileges because it mounts filesystems and creates device nodes.
```bash
sudo mkarchiso -v -w work -o out .
```
*   `-v`: Verbose output.
*   `-w work`: Directory for temporary work files.
*   `-o out`: Directory for the final ISO image.
*   `.`: The current directory (profile root).

Once finished, the ISO will be in the `out/` directory.

## Project Structure

This repository is an **Archiso profile**. If you are new, focus on these key paths first:

| Path | Purpose | When you should edit it |
| --- | --- | --- |
| `profiledef.sh` | Core Archiso profile settings (ISO label, publisher, build modes, file permissions). | You need to change identity, metadata, permissions, or boot profile behavior. |
| `build.sh` | Wrapper script to build the ISO with project defaults. | You want to change build flow (output/work directories, cleanup, build args). |
| `packages.x86_64` | Main package manifest for the supported architecture. | You are adding/removing software from the live image. |
| `packages.i686` / `packages.aarch64` | Experimental architecture package lists. | You are working on non-x86_64 experiments. |
| `bootstrap_packages.*` | Minimal package sets used during bootstrap stages. | You are changing early build/bootstrap dependencies. |
| `pacman.conf` | Package manager configuration for the build environment (repos, signatures, options). | Repositories or package trust configuration must change. |
| `airootfs/` | Files copied directly into the live root filesystem. | You are changing system defaults, services, scripts, installer behavior, or branding. |
| `grub/` and `syslinux/` | UEFI/BIOS bootloader menus and boot parameters. | You need to adjust boot entries, kernel parameters, or boot UX. |
| `tests/` | Verification scripts for profile integrity and release gates. | You are validating or extending quality checks. |
| `docs/` | Architecture, roadmap, mission, and operational documentation. | You are updating design intent, process, or contributor guidance. |
| `.github/workflows/` | CI pipelines that run checks/builds in automation. | You need to change automated build/test behavior. |

### `airootfs/` quick map

`airootfs/` is the most important directory for day-to-day system customization:

*   `airootfs/etc/`: System configuration shipped in the live/install image (systemd units, security defaults, Calamares settings, kernel/sysctl tuning).
*   `airootfs/usr/local/bin/`: Project-maintained operational scripts (for example, auto-update and maintenance helpers).
*   `airootfs/etc/calamares/`: Installer modules and branding behavior.
*   `airootfs/etc/pacman.d/`: Mirrorlists and package-manager hooks that run on package transactions.

### Safe change workflow

When modifying key structure files:

1. Update the source file(s) (for example `packages.x86_64`, `profiledef.sh`, or files under `airootfs/`).
2. Run the relevant script(s) in `tests/` that validate your change area.
3. If boot behavior was modified, verify both `grub/` and `syslinux/` paths stay consistent.
4. Document intent in `docs/` whenever a change affects architecture, defaults, or contributor workflow.

## Customization

### Adding Packages
Edit `packages.x86_64` and add the package name on a new line.

### Changing Default Settings
Modify files in `airootfs/etc/`. For example, to change the default wallpaper, you might edit `airootfs/usr/share/wallpapers/`.

### Custom Scripts
Place your scripts in `airootfs/usr/local/bin/` and ensure they are executable. You can set permissions in `profiledef.sh`.

## Troubleshooting

### "Target not found" during build
This usually means a package listed in `packages.x86_64` doesn't exist in the enabled repositories. Check your spelling or if the package was removed from Arch.

### Build fails with permission errors
Ensure you are running `mkarchiso` with `sudo`.

### ISO doesn't boot
*   Check if Secure Boot is disabled in your BIOS (NeOS may not support Secure Boot out of the box yet).
*   Try a different USB port or drive.
*   Verify the ISO checksum.
