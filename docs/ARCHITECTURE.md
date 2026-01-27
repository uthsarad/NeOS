# NeOS Architecture

## Overview
NeOS (Next Evolution Operating System) is an Arch Linux–based desktop OS that delivers a curated KDE Plasma experience designed to be a drop-in replacement for Windows or other graphical OSes on x86-64 hardware. The system emphasizes a polished, low-friction user experience with predictable behavior and minimal breakage through staged, curated updates.

## Architecture Goals
- **Windows-familiar UX without sacrificing KDE idioms:** Clean defaults, modern Plasma features enabled, and minimal visual clutter.
- **Predictable rolling release:** Use upstream Arch repositories where appropriate, but gate desktop-critical updates through NeOS curation and testing.
- **Out-of-the-box hardware support:** Seamless handling of Nvidia GPUs, Wi-Fi firmware, and common laptop quirks.
- **No terminal dependency for daily use:** Provide first-class GUI tooling for updates, apps, and configuration.

## System Layers
### 1) Base Operating System (Arch Linux)
- **Kernel & core system:** Upstream Arch kernel, systemd, coreutils, and baseline Arch packages.
- **Package manager:** pacman for system-level package management.
- **Repository structure:**
  - **Arch official repos:** baseline system packages and non-desktop-critical updates.
  - **NeOS curated repos:** KDE Plasma, KDE Frameworks, Qt stack, graphics drivers, firmware, and other desktop-critical packages.

### 2) Desktop Environment (KDE Plasma)
- **Visual design:** KDE Neon–like defaults with a clean, modern theme and uncluttered layouts.
- **Feature flags:** Enable modern Plasma features by default (e.g., Wayland readiness, portal integration, per-app scaling, system tray hygiene).
- **Consistency:** Harmonize KDE apps (Dolphin, Konsole, System Settings) and third-party tools with a unified theme and iconography.

### 3) Core Applications (User-Removable)
- **Browser:** Brave
- **Media player:** VLC
- **Media viewer:** nomacs
- **Email client:** Thunderbird
- **Office:** LibreOffice

These applications are preinstalled but not tightly coupled; users can replace them without breaking the OS.

### 4) Installer and First-Boot Flow
- **Installer:** Calamares with NeOS branding and simplified flow.
- **UX:** Windows-like flow with sensible defaults and a clear advanced path for power users.
- **First boot:** A guided welcome flow for updates, driver checks, and optional account services.

### 5) Hardware Enablement
- **Nvidia GPUs:** Provide out-of-the-box detection and installation of proprietary drivers.
- **Wi-Fi firmware:** Curate firmware packages for common chipsets.
- **Laptop quirks:** Preload power management defaults and common compatibility tweaks.

### 6) Application Distribution & Updates
- **GUI app store:** KDE Discover as the primary UI, branded for NeOS.
- **Backend recommendation:** Prefer PackageKit for native KDE Discover integration on Arch, with NeOS-curated update channels. If pamac is used, scope it for additional AUR-style access but keep Discover as the default.
- **Update safety:** Staged updates with phased rollouts and rollback options for desktop-critical packages.

## UX Architecture Considerations
### Default Experience Principles
- **Clarity over configurability:** Offer the right defaults with optional advanced settings.
- **Minimal distractions:** Curate tray icons and services; hide developer tools by default.
- **Windows familiarity:** Familiar layout and shortcuts (e.g., a well-placed application launcher, taskbar behavior, file manager defaults).

### Branding & Theming
- **NeOS identity:** Consistent boot splash, login screen, wallpaper set, and app icons.
- **KDE theming:** Use KDE’s theming system to preserve upstream compatibility while ensuring a clean default.

## Maintenance & Operational Considerations
### Repository Strategy
- **Staging pipeline:**
  1. **Upstream Arch sync**
  2. **NeOS staging repo** (automated tests, QA validation)
  3. **NeOS stable repo**
- **Update gates:** KDE stack, Qt, and graphics drivers should move only after validation.

### Update Stability
- **Policy:** Favor a “predictable behavior” stability target rather than fixed versions.
- **Rollback planning:** Keep previous package versions available for critical components.

### Telemetry & Diagnostics (Optional)
- **Local diagnostics:** Offer optional error reporting to improve stability.
- **Privacy-forward:** Opt-in only, clear and transparent.

## Security Defaults and Sandboxing
- **Baseline security:** Use standard Arch kernel hardening and systemd defaults.
- **Sandboxing:** Prefer Flatpak for GUI apps when feasible; use portals for file access and permissions.
- **App confinement:** For proprietary components (e.g., browser), consider AppArmor profiles if practical.

## Maintenance Risks and Constraints
- **Arch volatility:** Upstream updates can break downstream KDE customization.
- **Driver churn:** Nvidia and proprietary components can introduce regressions.
- **Resource requirements:** Maintaining curated repos demands CI, QA, and a release cadence that can scale.

## Architecture Decisions (Initial Recommendations)
- **Default backend:** PackageKit + KDE Discover for the most consistent GUI experience.
- **Staged updates:** NeOS repos should always buffer KDE and driver updates before end-user rollout.
- **Windows-like UX:** Ship a curated Plasma layout with minimal post-install tweaks needed for typical users.

## Performance Strategy
- **Boot Time:** Target sub-15s boot time on SSDs. Minimize enabled-by-default systemd services.
- **Responsiveness:** Prioritize UI thread (KDE) responsiveness. Use `nice` / `ionice` priorities for background maintenance tasks.
- **Resource Usage:** Baseline idle RAM usage < 1GB.
- **Updates:** Delta updates where possible to minimize download size and time (though Arch is package-based, we can optimize repository metadata).
