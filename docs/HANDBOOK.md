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

This repository is an **Archiso Profile**. Here are the key files and directories:

*   **`profiledef.sh`**: Defines the ISO name, version, boot modes, and file permissions.
*   **`packages.x86_64`**: A list of all packages to be installed on the ISO. Add or remove package names here.
*   **`pacman.conf`**: The Pacman configuration used during the build. Defines repositories (Arch, Chaotic-AUR, NeOS custom repos).
*   **`airootfs/`**: The "Arch ISO Root File System". Files here are copied directly to the live system (and the installed system if configured).
    *   `airootfs/etc/`: Configuration files (e.g., systemd units, skel).
    *   `airootfs/usr/local/bin/`: Custom scripts like `neos-driver-manager`.
*   **`mkinitcpio.conf`**: Configuration for the initramfs (initial ramdisk) used by the live ISO.
*   **`.github/workflows/`**: CI/CD pipelines that automatically build the ISO on GitHub.

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
