# NeOS Architecture

## Overview
NeOS (Next Evolution Operating System) is a curated, snapshot-based Arch Linux desktop distribution targeting x86-64 hardware. It delivers a KDE Plasma 6 desktop designed to be a drop-in replacement for Windows or other graphical OSes. NeOS prioritizes predictable behavior, low breakage, and a Windows-familiar experience over Arch purity.

NeOS is not a thin Arch wrapper. It owns the stability model, update coordination, and end-user experience.

## Architectural Spine (Essentials)
- **Kernel:** Arch `linux` with optional `linux-lts` fallback.
- **Init:** systemd.
- **Filesystem:** Btrfs by default; snapshots are a stability feature, not an advanced option.
- **Bootloader:** GRUB for Windows-friendly dual boot.
- **Desktop:** KDE Plasma 6, Wayland-first with X11 fallback where required (notably Nvidia).

## System Layers
### 1) Base System (Arch Linux)
- **Core stack:** Arch kernel, systemd, coreutils, and baseline Arch packages.
- **Package manager:** pacman remains canonical.
- **Ownership:** NeOS controls the repositories users consume; stability is a NeOS responsibility.

### 2) Desktop Layer (KDE Plasma 6)
- **Experience goal:** KDE Neon–like polish without Ubuntu/KDE Neon infrastructure.
- **Defaults:** Clean layout, reduced visual noise, modern Plasma features enabled.
- **Branding:** `neos-artwork` and `neos-settings` provide consistent theming and system defaults.
- **Session policy:** Wayland-first with X11 fallback where required (notably Nvidia).

### 3) Curation Layer (NeOS Value)
- **Snapshot-based rolling release:** NeOS snapshots upstream Arch repositories, tests them as a coherent set, and promotes the snapshot to stable.
- **No mixed feeds:** Do not combine frozen NeOS packages with live Arch core/extra; stability requires coherent snapshots.
- **Update gates:** KDE/Qt, graphics drivers, and firmware updates are staged, tested, and only then promoted.

## Installer & First-Boot Experience
- **Installer:** Calamares with NeOS branding.
- **Flow:** Windows-like, low-friction steps with explicit Replace Windows / Dual Boot paths.
- **Storage defaults:** Automatic partitioning with Btrfs subvolumes configured for snapshots.
- **First boot:** Guided flow to complete updates, driver checks, firmware enablement, and opt-in diagnostics.

## Hardware Enablement
- **Nvidia GPUs:** First-class requirement. Automatic detection and proprietary driver installation (including `nvidia-dkms`) are mandatory for a Windows replacement.
- **Wi-Fi firmware:** Curated coverage for common chipsets (Intel, Realtek, Broadcom).
- **Laptop quirks:** Power management defaults and known-quirk presets for common OEM hardware.

## Application Distribution & Updates
- **Primary app store:** KDE Discover, branded for NeOS.
- **Backend:** PackageKit with libalpm backend for Discover integration.
- **Flatpak:** Enabled by default with Flathub for GUI apps and sandboxing.
- **AUR stance:** AUR is unsupported by default; advanced users may opt in at their own risk.

## Security Defaults and Sandboxing
- **Baseline security:** Standard Arch kernel hardening and systemd defaults.
- **Sandboxing:** Flatpak-first for GUI apps, with KDE portals configured by default.
- **Optional confinement:** AppArmor profiles for high-risk components where practical.

## UX Principles (Windows-Familiar, KDE-Idiomatic)
- **Clarity over configurability:** sensible defaults first, advanced options second.
- **Minimal distractions:** curated tray and background services.
- **Familiarity:** Windows-like layout, file manager defaults, and shortcut choices.

## Maintenance & Operational Model
- **Snapshot cadence:** defined and documented; snapshots are promoted only after testing.
- **Rollback planning:** prior packages are retained; Btrfs snapshots provide user-facing rollback paths.
- **Ownership:** NeOS accepts responsibility for update regressions and driver breakage.

## Risks and Mitigations
- **Upstream volatility:** mitigated by snapshot testing and staged rollouts.
- **Driver regressions:** mitigated by Nvidia-first validation and DKMS coverage.
- **Resource demands:** sustained CI/QA investment is required to maintain trust.
