# NeOS Architecture Analysis

## 1. Introduction
NeOS is an Arch Linux-based operating system designed to provide a polished, stable, and user-friendly experience for desktop users, particularly those transitioning from Windows. The core philosophy blends the flexibility and performance of Arch Linux with a curated, "KDE Neon-like" desktop experience.

## 2. Base System
*   **Core**: Arch Linux.
*   **Kernel**: `linux` (standard Arch kernel) for broad hardware support, with `linux-lts` available as a fallback option in the bootloader.
*   **Init System**: systemd (standard Arch).
*   **Filesystem**: Btrfs (recommended default) for snapshots and rollback capabilities, or EXT4 for simplicity.
*   **Bootloader**: GRUB or systemd-boot (GRUB recommended for dual-boot compatibility).

## 3. Desktop Environment
*   **Environment**: KDE Plasma 6.
*   **Philosophy**: "KDE Neon-like".
    *   **Clean Defaults**: Minimal desktop icons, taskbar optimized for workflow similar to Windows 10/11.
    *   **Modern Features**: Wayland session enabled by default (falling back to X11 for NVIDIA if necessary, though Plasma 6 + NVIDIA 555+ is viable on Wayland).
    *   **Visuals**: Custom NeOS branding (splash screen, wallpaper, login theme). Reduce visual clutter in system tray and menus.

## 4. Release & Stability Model
*   **Type**: Curated Rolling Release.
*   **Structure**:
    1.  **Upstream Arch Repos**: Used for the vast majority of packages (CLI tools, libraries, non-critical apps).
    2.  **NeOS Core Repo**: A prioritized repository layered on top of Arch.
        *   **Content**: KDE Plasma packages, Qt frameworks, critical drivers (NVIDIA), and NeOS-specific tools.
        *   **Staging**: Packages in this repo are held back for brief testing (2-5 days) to ensure update stability before being pushed to users.
*   **Goal**: Mitigate "Arch breakage" while keeping the system up-to-date.

## 5. Software Ecosystem
### Package Management
*   **Backend**: `pacman` (CLI) and libalpm.
*   **Frontend (GUI)**: KDE Discover.
*   **Abstraction Layer**: `PackageKit` (or `pamac` daemon if tighter Arch integration is preferred, but Discover is the requirement). *Recommendation: Use PackageKit-Qt for native Discover integration.*
*   **App Store**: KDE Discover, branded for NeOS. Pre-configured with Flathub (Flatpak) backend enabled for sandboxed applications.

### Default Applications
*   **Web Browser**: Brave.
*   **Media Player**: VLC.
*   **Media Viewer**: nomacs.
*   **Email Client**: Thunderbird.
*   **Office Suite**: LibreOffice.
*   **Philosophy**: User-removable, no vendor lock-in.

## 6. Installer & First-Boot
*   **Installer**: Calamares.
    *   **Flow**: "Next, Next, Finish" style.
    *   **Partitioning**: Automatic by default, with clear "Replace Windows" or "Dual Boot" options.
    *   **Driver Setup**: Integrated hardware detection logic (similar to `mhwd`) to auto-install NVIDIA drivers during install.
*   **First-Boot Experience**:
    *   **Welcome App**: A custom "NeOS Welcome" utility.
        *   Quick settings (Dark/Light mode).
        *   Update check.
        *   One-click install for common extra apps (Spotify, Discord, Steam).

## 7. Hardware & Driver Support
*   **GPU**:
    *   **AMD/Intel**: Mesa drivers out of the box.
    *   **NVIDIA**: Auto-detection during boot/install. Proprietary drivers installed by default for performance.
*   **Firmware**: `linux-firmware` included fully.
*   **Printers/Scanners**: `cups` and `sane` pre-enabled.

## 8. UX Considerations
*   **Windows Familiarity**:
    *   **Start Menu**: Kickoff or a more traditional list-style menu (like "Alternatives" -> "Application Menu").
    *   **Interaction**: Default to **Double-click** to open files (matches Windows behavior, unlike standard KDE Single-click).
    *   **Shortcuts**: Ensure standard shortcuts (Ctrl+C/V, Super+E for file manager) work as expected.

## 9. Maintenance Considerations
*   **Repository Maintenance**: Requires infrastructure to mirror/snapshot Arch repos or a process to build/host the NeOS Core repo.
*   **Testing**: Automated openQA tests recommended for the "Curated" aspect.
