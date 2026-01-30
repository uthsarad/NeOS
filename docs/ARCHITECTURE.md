# NeOS Architecture

[← Back to Documentation Index](../README.md#documentation)

## Table of Contents
- [Overview](#overview)
- [Architecture Goals](#architecture-goals)
- [System Layers](#system-layers)
- [UX Architecture Considerations](#ux-architecture-considerations)
- [Maintenance & Operational Considerations](#maintenance--operational-considerations)
- [Security Defaults and Sandboxing](#security-defaults-and-sandboxing)
- [Best-Practice Recommendations](#best-practice-recommendations-windows-familiarity--kde-idioms)
- [Risks and Pitfalls](#risks-and-pitfalls-arch-based-distribution)
- [Architecture Decisions](#architecture-decisions-initial-recommendations)
- [Performance Strategy](#performance-strategy)

## Overview
NeOS (Next Evolution Operating System) is an Arch Linux–based desktop OS targeting x86-64 hardware with a KDE Plasma desktop curated to be a drop-in replacement for Windows or other graphical OSes. The architecture prioritizes a polished, predictable end-user experience while preserving Arch’s rolling-release benefits through staged, curated updates.

## Architecture Goals
- **Windows-familiar UX without sacrificing KDE idioms:** Clean defaults, modern Plasma features enabled, minimal visual clutter.
- **Predictable rolling release:** Use upstream Arch repositories where possible while gating desktop-critical updates through NeOS staging.
- **Out-of-the-box hardware support:** Seamless handling of Nvidia GPUs, Wi-Fi firmware, and common laptop quirks.
- **No terminal dependency for daily use:** First-class GUI tooling for updates, apps, and configuration.
- **Maintainable operations:** Clear repository boundaries, automated validation, and rollback-ready packages.

## System Layers
### 1) Base Operating System (Arch Linux)
- **Kernel & core system:** Upstream Arch kernel with optional `linux-lts` fallback, systemd, coreutils, and baseline Arch packages.
- **Package manager:** pacman for system-level package management.
- **Repository structure:**
  - **Arch official repos:** baseline system packages and non-desktop-critical updates.
  - **NeOS curated repos:** KDE Plasma, KDE Frameworks, Qt stack, graphics drivers, firmware, and desktop-critical utilities.
  - **NeOS staging repo:** pre-release validation channel for gated updates.

### 2) Desktop Environment (KDE Plasma)
- **Visual design:** KDE Neon–like defaults (clean layout, modern theme, minimal clutter).
- **Feature defaults:** Wayland readiness, portal integration, per-app scaling, and tray hygiene.
- **KDE app cohesion:** Dolphin, Konsole, System Settings, and Discover are themed consistently for a single-system feel.

### 3) Core Applications (User-Removable)
- **Browser:** Brave
- **Media player:** VLC
- **Media viewer:** nomacs
- **Email client:** Thunderbird
- **Office:** LibreOffice

These applications are preinstalled but user-removable; NeOS does not claim redistribution ownership beyond upstream licenses.

### 4) Installer and First-Boot Flow
- **Installer:** Calamares with NeOS branding and a streamlined path for typical users.
- **Flow:** Windows-like steps with sensible defaults and optional advanced mode for storage and customization.
- **First boot:** A guided welcome flow for updates, driver checks, firmware enablement, and optional telemetry opt-in.

### 5) Hardware Enablement
- **Nvidia GPUs:** Automatic detection and installation of proprietary drivers, with fallbacks for open drivers if required.
- **Wi-Fi firmware:** Curated firmware packages for common chipsets (Intel, Realtek, Broadcom).
- **Laptop quirks:** Default power management profiles and compatibility tweaks for common OEM hardware.
- **Virtual machine startup:** Preload common virtualization drivers (virtio, Hyper-V, VMware, VirtualBox) via `modules-load.d` to ensure reliable boot and networking in VM environments.

### 6) Application Distribution & Updates
- **GUI app store:** KDE Discover as the primary UI, branded for NeOS.
- **Backend recommendation:** Use PackageKit with libalpm backend for best Discover integration on Arch. Offer pamac only as an optional, advanced add-on if AUR access is a goal.
- **Update safety:** Staged updates with automated smoke tests and manual QA for KDE/Qt/driver changes.

## UX Architecture Considerations
### Default Experience Principles
- **Clarity over configurability:** Provide the right defaults with opt-in advanced settings.
- **Minimal distractions:** Curate tray icons and background services; hide developer tools by default.
- **Windows familiarity:** Familiar layout and shortcuts (launcher position, taskbar behavior, file manager defaults).

### Branding & Theming
- **NeOS identity:** Consistent boot splash, login screen, wallpaper set, and app icons.
- **KDE theming:** Use KDE’s theming system to preserve upstream compatibility while shipping cohesive defaults.

## Maintenance & Operational Considerations
### Repository Strategy
- **Snapshot-based rolling model:** NeOS snapshots upstream Arch repos, tests them as a coherent set, and releases a validated snapshot rather than mixing frozen NeOS packages with live Arch feeds.
- **No mixed feeds:** Avoid combining a frozen NeOS stack with live Arch core/extra; stability requires coherent snapshots.
- **Staging pipeline:**
  1. **Upstream Arch sync**
  2. **NeOS staging repo** (automated tests and QA)
  3. **NeOS stable repo**
- **Update gates:** KDE stack, Qt, and graphics drivers promote only after validation.

### Update Stability
- **Policy:** Target predictable behavior rather than fixed versions.
- **Rollback planning:** Keep prior packages for critical components and document downgrade procedures.

### Telemetry & Diagnostics (Optional)
- **Local diagnostics:** Offer opt-in error reporting to improve stability.
- **Privacy-forward:** Clear disclosure and explicit opt-in controls.

## Security Defaults and Sandboxing
- **Baseline security:** Standard Arch kernel hardening and systemd defaults.
- **Sandboxing:** Prefer Flatpak for GUI apps where appropriate; ensure KDE portals are configured by default.
- **App confinement:** Consider AppArmor profiles for proprietary components (e.g., browsers) when feasible.

## Best-Practice Recommendations (Windows Familiarity + KDE Idioms)
- **Single app store:** Keep Discover as the primary software hub.
- **Minimal tray noise:** Curate startup services and notifications.
- **Familiar shortcuts:** Provide Windows-like keybindings with KDE equivalents documented.
- **File manager defaults:** Configure Dolphin for a clean, no-surprise layout.

## Risks and Pitfalls (Arch-Based Distribution)
- **Upstream volatility:** Arch updates can break downstream KDE customizations.
- **Driver churn:** Nvidia and firmware updates can introduce regressions.
- **Resource demands:** Staged updates require CI, QA, and repository management capacity.
- **User expectations:** Rolling release can conflict with set-and-forget expectations.

## Architecture Decisions (Initial Recommendations)
- **Default backend:** PackageKit + KDE Discover for the most consistent GUI experience.
- **Staged updates:** NeOS repos buffer KDE and driver updates before end-user rollout.
- **Windows-like UX:** Ship a curated Plasma layout with minimal post-install tweaks.

## Performance Strategy
- **Boot time:** Target sub-15s boot on SSDs; minimize enabled-by-default services.
- **Responsiveness:** Prioritize KDE UI thread responsiveness; use `nice`/`ionice` for background tasks.
- **Resource usage:** Baseline idle RAM usage < 1 GB on typical hardware.
- **Updates:** Optimize repository metadata and compression to reduce download size and time.
