# Changelog

All notable changes to this project will be documented in this file.

## [2026.06.23] - 2026-06-23

### Fixed
- **Critical**: ISO no longer exceeds the 2 GiB GitHub release limit, which was blocking automated releases since V158. Switched squashfs compression from `zstd -19` to `xz` with the x86 BCJ filter for a significantly better compression ratio (trades a slightly slower live-boot for fitting under the limit with comfortable margin).

### Changed
- Excluded additional datacenter/server-only NIC and HBA firmware from the live image (qed, bnx2x, bnx2, dpaa2, cavium, cnn55xx) — hardware never present on desktops/laptops — to reclaim space in `linux-firmware`.

## [2026.06] - 2026-06-22

### Fixed
- **Critical**: Users created by Calamares now get proper groups (wheel, video, audio, storage, power, network, lp, input) - previously empty
- **Critical**: NetworkManager, SDDM, Bluetooth, and CUPS services now enabled on installed system
- **Critical**: Autoupdate service no longer blocked by overly strict systemd sandboxing (ProtectSystem=full prevented pacman from writing to /usr)
- **Critical**: CI test failures now properly fail the build instead of being silently ignored
- Fixed unpackfs.conf exclude path inconsistencies
- Fixed command injection vulnerability in autoupdate notification system
- Fixed SUID core dump leak (fs.suid_dumpable 2 -> 0)
- Fixed deprecated SSH `ChallengeResponseAuthentication` directive
- Fixed placeholder os-release URLs pointing to neos.example
- Fixed test assertions for updated security values and file layout
- Fixed GRUB test expecting old menuentry names
- Removed alci_repo from installed system pacman.conf (only needed during build)
- Replaced `iptables` with `iptables-nft` to avoid conflicts with ufw

### Added
- Firefox browser (replaces Falkon as default)
- Full KDE Plasma 6 experience: systemsettings, kinfocenter, spectacle, gwenview, okular, kate, kcalc, bluedevil, plasma-systemmonitor
- Vulkan drivers: vulkan-radeon, vulkan-intel, vulkan-swrast
- KDE desktop integration: kwallet-pam, kde-gtk-config, breeze-gtk, xdg-desktop-portal-kde, ffmpegthumbs, kdegraphics-thumbnailers, kio-extras
- CJK font support (noto-fonts-cjk)
- System tools: fwupd, inxi, pacman-contrib, rsync, exfatprogs, alsa-utils, rtkit
- Man pages and bash-completion for better terminal experience
- SSH rate limiting (MaxAuthTries, ClientAliveInterval)
- GRUB accessibility boot option
- Syslinux accessibility boot option
- 6-slide installer slideshow showcasing stability, performance, security, hardware, and desktop features
- Kernel SysRq safe recovery subset (sync, remount-ro, reboot)

### Changed
- Squashfs compression switched from xz to zstd level 15 for significantly faster boot
- GRUB timeout reduced from 15s to 5s
- GRUB boot entries renamed for clarity (removed "Install" prefix)
- Boot parameters now include loglevel=3 and systemd.show_status=auto for cleaner boot
- Welcome app redesigned with professional dark UI and NeOS branding
- Installer slideshow expanded from 1 to 6 informative slides
- Default user shell set to zsh (matching live environment)
- Branding version updated to 2026.06
- Installed system pacman.conf now includes Color, VerbosePkgLists, ILoveCandy
- Locale and man page stripping removed from pacman.conf (was breaking non-English users)
- Root shell messages updated to reference GUI installer instead of archinstall
- Desktop setup script now configures default browser and user directories

### Removed
- Falkon browser (replaced by Firefox)
- Deprecated xf86-video-intel and xf86-video-fbdev/vesa drivers (mesa handles all modern hardware)
- Stale xf86-video-* legacy DDX drivers

## [Unreleased - Prior]

- Fixed documentation URLs to point to https://github.com/uthsarad/NeOS
- Initialized CHANGELOG.md following the 'Keep a Changelog' format
- Fixed `pacman.conf` build blocker (resolved missing repository error).
- Added ISO size validation in CI workflows.
- Updated documentation to clarify x86_64 as the primary supported architecture.
- Improved build verification script robustness against missing `pyyaml`.
- Initial project scaffolding.
