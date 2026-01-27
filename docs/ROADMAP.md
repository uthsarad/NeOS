# NeOS Development Roadmap

## Phase 1: Foundation & Build System (Months 1-3)
**Objective**: Establish a reproducible build pipeline and a bootable ISO.

1.  **Repository Infrastructure**:
    *   Set up a `neos-core` repository.
    *   Fork/Configure `archiso` profiles for NeOS.
    *   Automate package building (CI/CD) for NeOS-specific packages (themes, settings).
2.  **Base ISO Creation**:
    *   Create a custom `archiso` profile.
    *   Include `kde-applications`, `plasma-meta`, and default apps (Brave, VLC, etc.).
    *   **Goal**: A bootable live ISO that boots to a vanilla-ish KDE Plasma desktop.
3.  **Theming & Branding**:
    *   Create `neos-artwork` package (wallpapers, logos).
    *   Create `neos-settings` package (modifies `/etc/xdg/` configs for KDE defaults).
    *   Implement "Double-click to open" global setting via config overlay.

## Phase 2: Installer & Hardware Support (Months 3-5)
**Objective**: A user-friendly installation process and solid driver support.

1.  **Calamares Configuration**:
    *   Customize `calamares` branding and slideshow.
    *   Configure `packages` module to remove live-session only packages.
    *   Configure `partition` module for Btrfs defaults (with subvolume layout: `@`, `@home`, `@log`, `@cache`).
2.  **Driver Automation**:
    *   Implement `mhwd` (Manjaro Hardware Detection) logic or custom Python scripts in Calamares to detect NVIDIA GPUs.
    *   Ensure proprietary NVIDIA drivers are installed if detected.
3.  **App Store Integration**:
    *   Configure KDE Discover with `packagekit` backend.
    *   Enable Flathub repository by default in flatpak configuration.

## Phase 3: Curated Rolling Release & Refinement (Months 5-7)
**Objective**: Implementing the update strategy and polishing UX.

1.  **Update Strategy Implementation**:
    *   Set up the staging/testing repository structure.
    *   Script the synchronization process from Arch upstream to NeOS repos.
2.  **First-Boot Experience**:
    *   Develop `neos-welcome` (Python/Qt or QML).
    *   Features: Update check, Driver check, "Install Steam/Discord" buttons.
3.  **Security Hardening**:
    *   Enable Firewall (`ufw`) by default.
    *   Configure AppArmor profiles where applicable.

## Phase 4: Beta & Community Testing (Months 7+)
**Objective**: Public testing and bug fixing.

1.  **Public Beta Release**:
    *   Host ISO on a reliable CDN.
    *   Open bug tracker (GitHub/GitLab Issues).
2.  **Documentation**:
    *   Wiki for users (Installation guide, NVIDIA troubleshooting).

---

## Best Practices: Bridging Windows & Linux
To make NeOS familiar to Windows users while remaining idiomatic to KDE:

1.  **Terminology**: Use "Settings" instead of "System Settings", "App Store" instead of "Discover" (in menu entries).
2.  **Layout**: Bottom panel with start menu on left, task list in middle/left, tray on right.
3.  **Shortcuts**:
    *   `Super` (Windows Key) opens Start Menu.
    *   `Super + E` opens File Manager (Dolphin).
    *   `Super + D` minimizes windows (Show Desktop).
    *   `Ctrl + Shift + Esc` opens System Monitor.
4.  **File Associations**: Ensure Media Player (VLC) and Image Viewer (nomacs) are default, not an "Open With" prompt.

## Risks & Pitfalls (Arch-Based)

1.  **Upstream Breakage**: Arch updates can break partial upgrades.
    *   *Mitigation*: NeOS must serve *all* packages from its own snapshot or ensure `neos-core` is compatible with the latest Arch `core`/`extra`. Mixing a frozen repo with a rolling repo is dangerous (partial upgrade issues).
    *   **Recommendation**: Maintain a full snapshot of Arch repos that is updated daily/weekly after testing. This is storage intensive but safest for stability.
2.  **AUR Reliance**: Users will want AUR packages.
    *   *Mitigation*: Do not support AUR officially to avoid support burden. Pre-installing an AUR helper (like `yay`) is controversial but user-friendly. Recommend `pamac-aur` or similar if GUI access is needed, but warn users of risks.
3.  **NVIDIA Drivers**: Kernel updates often break NVIDIA drivers if not synced.
    *   *Mitigation*: Use `dkms` variants of drivers (e.g., `nvidia-dkms`) so they rebuild automatically on kernel updates.
4.  **Resource Drain**: "Manjaro-like" bloat.
    *   *Mitigation*: Keep background services to a minimum. Avoid running multiple update notifiers.
