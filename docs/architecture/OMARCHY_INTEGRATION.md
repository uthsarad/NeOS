# Omarchy Integration — What Is Wired and What Is Dormant

[← Documentation index](../README.md)

Between 2026-09-24 and 2026-10-01 (`d12ce33`, `92b9d29`, `823c3d0`) the project
imported a large part of [Omarchy](https://github.com/basecamp/omarchy) and its ISO
tooling. The import was rebranded to NeOS mechanically (`omarchy` → `neos` by
find-and-replace, which is why some paths read `neos/neos`). NeOS is still a **KDE
Plasma** distribution installed by **Calamares**. This page records which imported
parts take effect on the live ISO and on installed systems, and which are shipped but
inert, so that nobody reads dormant files as working features.

Status as of 2026.10.02 (`reports/v2026.10.02/02-review-report.md`).

## Active

| Area | Where | Effect |
| :-- | :-- | :-- |
| Live package set | `profile/packages.x86_64` | The Arch `releng` package set (rescue tools, file systems, firmware, `archinstall`, `gum`, `python-textual`, …) is installed on the live ISO **and**, through `tools/gen-manifests.sh`, on installed systems. |
| Skeleton configs | `profile/airootfs/etc/skel/.config/` | Configs for terminals (alacritty, foot, ghostty, kitty), tmux, btop, git, starship, fcitx5, wireplumber (Bluetooth A2DP auto-connect) and more are copied into every new user's home. A config only matters once its application is installed: most of these programs are **not** in the package list. |
| Web-app launchers and icons | `etc/skel/.local/share/applications/`, `usr/share/icons/hicolor/` | Menu entries for web apps (WhatsApp, YouTube, Zoom, …) and their icons. |
| zsh baseline | `etc/skel/.zshrc` | grml's skeleton `.zshrc` (works with the shipped `grml-zsh-config`). |
| Branding | palette, Calamares SVG/QSS, SDDM, Plymouth, wallpaper | Accent colour `#38bdf8` and the starfield wallpaper (`tools/gen-wallpaper.py`). |
| Live services kept | `hv_*`, `vmware-vmblock-fuse`, `pcscd.socket`, `systemd-timesyncd`, `systemd-resolved`, `systemd-userdbd.socket`, `iwd` (NetworkManager's Wi-Fi backend) | Ordinary releng services that do not conflict with NeOS. |

## Removed in 2026.10.02 (conflicted with NeOS)

Root autologin on tty1, `sshd`, `systemd-networkd` with its socket and wait-online,
`cloud-init` (it claims the same `cidata` volume label as `neos-autoinstall`), and the
`livecd-talk` / `livecd-alsa-unmuter` / `choose-mirror` units, whose binaries do not
exist on NeOS. `tests/verify_live_services.sh` keeps them out. The rationale for each
is in the 2026.10.02 CHANGELOG entry.

## Dormant (shipped, nothing uses it)

| Area | Where | Why it is inert |
| :-- | :-- | :-- |
| Omarchy defaults tree | `profile/airootfs/usr/share/neos/neos/` (≈1.7 MB) | Every consumer expects `/usr/share/neos/default/…`; the rename left it one level deeper. Moving it up is **not** a fix on its own: its bash chain sets `EDITOR=neos-launch-editor` and `BROWSER=neos-launch-browser` (not shipped) and pages `man` through `bat` (not installed). `/etc/skel/.bashrc` therefore loads it only when it resolves at the expected path. |
| Hyprland session configs | `etc/skel/.config/hypr/`, `hyprland-preview-share-picker/` | Hyprland is not in the package list. |
| Chromium flags/extensions | `etc/skel/.config/chromium*` | Chromium is not installed, and the extension paths point at the dormant tree. |
| archinstall-based installer | `usr/share/neos-iso/`, `usr/local/bin/neos-iso-install`, `neos-install-dashboard`, `neos-cidata-load`, `neos-iso-cleanup-disk`, `neos-install-diagnose-media`, `usr/bin/neos-debug*` | Nothing launches it; Calamares is the installer (ADR 0003). Its defaults are rename artefacts of packages NeOS does not ship (`linux-neos` kernel, Limine boot). Its credential handling was nevertheless fixed and is tested (`tests/verify_installer_secrets.sh`), because it runs as root against user passphrases if anyone does start it. |
| Omarchy package list | `profile/packages_omarchy.x86_64` | mkarchiso only reads `packages.x86_64`. |

## Decision needed

Two coherent ways forward:

1. **Hyprland edition:** add Hyprland and the Omarchy tool set to the package lists,
   move the defaults tree to `/usr/share/neos/`, ship the `neos-*` helper binaries it
   calls, and decide whether `neos-iso-install` replaces or complements Calamares
   (that one needs an ADR).
2. **Plasma only:** delete the dormant rows above (and the unused skel configs), which
   shrinks the overlay that every install copies.

Until one of those happens, treat the dormant rows as unsupported.
