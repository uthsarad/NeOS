# Changelog

All notable changes to this project will be documented in this file.

## [2026.07.03] - 2026-07-03

### Added
- **Deep repository & build audit** (`reports/v2026.07.03/deep-audit-report.md`): full audit of the archiso profile, build scripts, airootfs overlay, Calamares config, CI workflow, tests, and tooling, judged against the ArchWiki Archiso article and Ubuntu LiveCDCustomization image-hygiene practices. 3 High / 7 Medium / 6 Low findings with file:line evidence, an ArchWiki+Ubuntu compliance matrix, and a 14-item fix backlog. Headline findings: dormant kiosk installer path that could re-impose passwordless login on installed systems if re-enabled; CI gates weakened with `|| true`; `neos-secureboot-setup` never copied to installed systems; dead i686/aarch64 package lists enforced by the Rust profile audit.
- `tools/gen-build-conf.sh` and `tools/gen-manifests.sh`: single source of truth for the build pacman.conf and the Calamares netinstall manifests, now called by both `build.sh` and CI. **Fixes a High-severity bug found during remediation: CI never regenerated `neos-packages.txt`/`neos-overlay.txt`, so systems installed from CI-built ISOs silently missed every overlay file added after the last committed manifest** (including `neos-secureboot-setup`, the snapshot pacman hooks, and the Plymouth logo).
- `profile/airootfs/etc/mkinitcpio.d/linux-lts.preset` (ArchWiki pattern): builds only the archiso initramfs image, skipping the redundant fallback image (smaller ISO, faster build). Live-only — excluded from the installed-system overlay.
- CI releases now ship `SHA256SUMS` alongside the ISO.
- Regression test: `neos-liveuser-setup.service` must stay unsandboxed (sandboxing it silently breaks live autologin); the check ignores comments and fails if any `ProtectSystem`/`ProtectHome`/`PrivateTmp`/`NoNewPrivileges` directive reappears.

### Added
- **Offline install support**: `tools/gen-install-repo.sh` downloads every package from `neos-packages.txt` into a local pacman repo that `build.sh` embeds on the ISO at `/neos/pkg/` (outside the SquashFS, via xorriso). `neos-pacstrap` now installs hybrid: fresh packages from the network when online, from the on-ISO repo when offline — installation no longer requires internet.

### Changed (boot experience)
- **Plymouth splash redesigned** (supersedes the cat-only layout below): NeOS wordmark + tagline top-third, animated cat centred, pulsing dot indicator and status text beneath — Ubuntu-style polish, still no logo image and no KDE splash. Calamares slideshow (`show.qml`), SDDM theme, and welcome app refreshed to match; slideshow keeps keyboard-focus border and accessibility roles.
- **The cat IS the boot screen now**: removed the NeOS logo from the Plymouth splash — the animated cat alone, dead centre, transparent frames over the plain navy background. The unused theme `logo.png` was deleted (Calamares keeps its own branding logo).
- **KDE/Plasma login splash disabled**: `etc/skel/.config/ksplashrc` (`Engine=none`, `Theme=None`) ships to the live user and installed users, so the Plymouth cat is the only boot screen — no second splash after SDDM login. Guarded by `tests/verify_boot_gui.sh`.

### Fixed
- **Boot/installer logo rendered as a black box**: the NeOS badge (`logo.png` in the Plymouth theme and Calamares branding) shipped with an alpha channel but every pixel opaque — a black square with white corner remnants baked in, visible over the navy gradient on the boot splash and in the installer sidebar. Cut the circular badge out with an anti-aliased alpha mask (`tools/fix-branding-alpha.sh`, ImageMagick — reproducible, no Pillow needed).
- **Boot cat sat on a grey box**: the committed `cat-NN.png` frames predated `tools/gen-bootlogo-frames.py` and carried an opaque `#31384C` rectangle from an older pipeline, even though the source `loader-cat.gif` is fully transparent. Regenerated all 32 frames from the GIF (composite disposal, per-cel trim, 2× Lanczos, centred on a shared 328×328 transparent canvas — same layout rules as the Python generator).
- **Removed the dormant kiosk installer path** (`liveuser-setup.conf`, `neos-install-identity`): orphaned since the public-installer switch, it would have re-imposed a passwordless autologin identity on installed disks if ever re-wired. Also removed the orphaned `neos-installer-partition.sh` (its Btrfs subvolume scheme contradicted the active `mount.conf`) and the broken, unwired `neos-restore-module.qml` (used a `Process` QML type no import provides), plus their tests.
- **CI quality gates restored**: `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh` no longer run under `|| true` — both pass and can now fail the build. ISO-dependent tests remain in the build job where an ISO exists.
- **Overlay manifest hygiene**: live-only mechanics are now excluded from the installed-system overlay (`/root/*` including the build-time `customize_airootfs.sh` — which mkarchiso deletes from the ISO, so its manifest entry would have failed the Calamares rsync — plus `pacman-init.service`, `etc-pacman.d-gnupg.mount`, and `etc/mkinitcpio.d/`).
- Pacman post-snapshot hook now pairs with the newest *pre* snapshot specifically instead of the newest snapshot of any type (concurrent timeline/autoupdate snapshots could mis-link the pair).
- Duplicate liveuser creation removed from `neos-liveuser-setup`: the runtime branch drifted from the build-time `customize_airootfs.sh` (different shell path and groups); the script now fails loudly if the build-time user is missing.
- `gen-vm-appliance.sh` randomizes the VirtualBox NIC MAC (template shipped a fixed one — two NeOS VMs on one LAN segment collided).
- Stale comment in `profile/pacman.conf` claiming the installed system must switch to `DatabaseRequired` (the opposite is deliberate and enforced by the profile audit); publisher URL in `profiledef.sh` aligned with os-release.

### Changed
- **Releases now tag from the `VERSION` file** (`v<VERSION>-b<run>`) instead of the bare CI run number, and the release body carries the matching CHANGELOG section.
- Dropped the never-built i686/aarch64 package lists (Arch dropped i686 in 2017; no aarch64 port exists — `profiledef.sh` builds x86_64 only). `tools/neos-profile-audit` and tests now audit only the shipped architecture.
- `build.sh` warns that the local build mutates the host keyring (use a container for hermetic builds, as CI does).

## [2026.07.02] - 2026-07-02

### Fixed
- **Off-center / wobbling boot cat**: The source GIF anchors the cat in the top-left of its canvas, so the generated frames kept it pinned up-left of center and it jittered as each frame's content size changed. Re-trimmed all 32 `cat-NN.png` frames to their visible pixels and re-centered them on a uniform 320×320 transparent canvas, so the loader cat now sits perfectly centered and stable. Updated `tools/gen-bootlogo-frames.py` to crop-and-center frames on regeneration.

### Changed
- **Faster, Windows-11-style boot**: Eliminated the visible boot-menu wait so the machine drops straight into the animated splash. GRUB now uses `timeout=0` with `timeout_style=hidden` (menu still reachable by holding ESC/SHIFT/F8); the syslinux/BIOS path drops from a 1s to a 0.5s `TIMEOUT` (any keypress still halts the countdown via `MENU IMMEDIATE`). Boot internals were already tuned for speed (squashfs `zstd -22` for smallest size at codec-constant decompress speed, Plymouth `ShowDelay=0` for instant splash), so no rebuild-time regression.

## [2026.07.01] - 2026-07-01

### Fixed
- **Stuck mouse cursor in live session**: The live ISO autologged into the Wayland Plasma session (`Session=plasma`), contradicting the project's X11-everywhere decision. On GPUs that cannot get hardware GL (marginal/hybrid GPUs, NVIDIA/nouveau, non-3D VMs), KWin-Wayland composites via llvmpipe and stops servicing input, freezing the cursor. Switched live autologin to the X11 session (`Session=plasmax11`) in `sddm.conf.d/autologin.conf`.
- **Calamares welcome page missing info buttons**: `welcome.conf` had all `show*Url=false` and `branding.desc` carried no URL strings, so no Support / Known-Issues / Release-Notes links rendered. Enabled the buttons and populated the URLs from os-release.
- **Dead installer instance**: Removed an orphaned `liveuser` shellprocess instance left in `settings.conf` after the earlier public-installer switch.

### Added
- **NeOS logo branding**: Integrated the official NeOS "neo" badge. Added a transparent-background `logo.png` to the Plymouth theme and refreshed the Calamares `logo.png` / `welcome.png` branding assets from the source artwork.

### Changed
- **Windows-11-style boot splash**: Reworked the Plymouth `neos.script` layout so the NeOS logo sits centered just above the vertical middle with the animated cat acting as a spinner below it (LUKS prompt below the cat). Previously the cat sat dead-center with no logo.
- Bumped branding version string to 2026.07.

## [2026.06.29] - 2026-06-29

### Fixed
- **GRUB theme**: Starfield theme's selected-menu-entry highlight was broken. The theme referenced a `blob_*.png` 9-slice pixmap set, but only `blob_w.png` was shipped; additionally, `selected_item_color` was set to `#000` (same as normal items), rendering the selected entry near-invisible. Fixed by removing the broken pixmap reference, setting `selected_item_color` to `#3465a4` (Arch blue) for clear visual feedback, and deleting the orphaned `blob_w.png` file. Boot menu selection is now clearly visible.

### Added
- **Firmware updates**: `fwupd` installed system-wide for hardware firmware management.
- **Accessibility suite**: Added `orca`, `speech-dispatcher`, `espeak-ng`, `espeakup`, and `brltty` to the live image (speech stack only; kept minimal for ISO size). Added `neos-accessibility` oneshot systemd service that detects the `accessibility=on` kernel cmdline parameter and starts espeakup, enabling screen-reader support in the live session. The prior `accessibility=on` boot entry was a dead promise (no packages shipped); this release delivers functional accessibility.
- **Flatpak support**: `flatpak` installed system-wide, providing a working backend for the already-shipped Discover app store.
- **CJK fonts**: `noto-fonts-cjk` added to the installed system (not the live image, to respect the 2 GiB ISO size constraint).
- **NVIDIA support**: `nvidia-dkms` added to the installed system, pairing with existing `dkms` and `linux-lts-headers` for seamless NVIDIA GPU driver compilation during post-install.
- **Secure Boot helpers**: Added `sbctl`, `mokutil`, and `efitools` to the installed system, plus `neos-secureboot-setup` user-initiated helper script using sbctl's own-keys model (post-install, not auto-wired to avoid brick risk). Documented in new `docs/SECURE_BOOT.md`. Live USB still requires Secure Boot to be disabled (no MS-signed shim shipped).
- **Hardware and connectivity**: Added `thermald` (Intel thermal management), `modemmanager` (WWAN support), `networkmanager-openvpn` (VPN UI in NetworkManager), `sane` and `sane-airscan` (scanner support). `thermald` and `modemmanager` are enabled on the installed system via Calamares services-systemd module.

### Changed
- ISO package discipline: Only the minimal a11y speech stack was added to the live squashfs (`profile/packages.x86_64`); all other new capabilities (fwupd, flatpak, CJK fonts, nvidia-dkms, Secure Boot helpers, etc.) are installed network-pacstrapped at installation time from `neos-packages.txt`, keeping the ISO under the 2 GiB GitHub release limit with comfortable margin.

## [2026.06.24] - 2026-06-24

### Fixed
- **Critical**: Live ISO no longer hangs at "Terminate Plymouth Boot Screen". The image shipped only the Wayland Plasma session (`plasma-desktop`) with no X11 session installed at all, and autologged straight into Wayland. On GPUs/VMs where the Wayland session cannot start (notably NVIDIA/nouveau), autologin failed silently and boot stalled at the Plymouth handoff. Now ship `plasma-x11-session` + `xorg-server`, force SDDM onto X11 (`DisplayServer=x11`), and autologin into the `plasmax11` session — the portable path a live installer needs. Wayland remains selectable from SDDM where supported.
- The installed system now also defaults to the X11 Plasma session, so a machine whose GPU could not start Wayland in the live environment does not hit the same hang after installation.

## [2026.06.23] - 2026-06-23

### Fixed
- **Critical**: Calamares now starts. The `alci-calamares` package (last built Feb 2025) links the removed `libyaml-cpp.so.0.8` and fails on current Arch (yaml-cpp 0.9) with exit 127. Replaced it with `calamares-garuda` from the Garuda repo — an actively-rebuilt Calamares that tracks current Arch libraries, provides `calamares`, and pulls no `qt6-webengine` (no ISO size impact). NeOS continues to supply its own `/etc/calamares` settings, modules, and branding.
- **Critical**: "Install NeOS" no longer fails silently. On the live Wayland session the launcher hardcoded `DISPLAY=:0` (often wrong under XWayland), did not pass `XAUTHORITY`, and discarded all errors — so clicking Install showed only a "Starting…" popup and then nothing. The launcher now uses the session's real `DISPLAY`/`XAUTHORITY`, verifies Calamares is present, and surfaces any startup failure via a dialog instead of failing silently. (This is what exposed the `libyaml-cpp` error above.)

- **Critical**: ISO no longer exceeds the 2 GiB GitHub release limit, which was blocking automated releases since V158. Switched squashfs compression from `zstd -19` to `xz` with the x86 BCJ filter for a significantly better compression ratio (trades a slightly slower live-boot for fitting under the limit with comfortable margin).
- Btrfs installs now create a snapper-compatible subvolume layout (`@`, `@home`, `@cache`, `@log`, `@.snapshots`). Previously no subvolumes were created, so snapshot/rollback of the root filesystem could not work despite being a headline feature. Added `modules/mount.conf`.
- `users.conf` now actually grants the `network` and `lp` groups (the prior CHANGELOG claimed these but they were missing).

### Added
- Build-time installer verification (`tests/verify_iso_calamares_libs.sh`): after the airootfs is built the build chroots in and confirms every Calamares shared library resolves and `calamares --version` runs. This gates the build, so a broken installer (e.g. a soname break) fails CI instead of being released.
- Smoke test now exercises the UEFI/OVMF boot path in addition to BIOS, uses more RAM, and fails on kernel panic / emergency-mode / root-mount errors.

### Changed
- Calamares is now sourced from the Garuda repo (`[garuda]`) instead of `alci_repo`. See the build `pacman.conf`.
- Excluded additional datacenter/server-only NIC and HBA firmware from the live image (qed, bnx2x, bnx2, dpaa2, cavium, cnn55xx) — hardware never present on desktops/laptops — to reclaim space in `linux-firmware`.
- Post-install cleanup removes the dangling `neos-liveuser-setup.service` symlink and uninstalls the now-orphaned Calamares package from the installed system.

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
