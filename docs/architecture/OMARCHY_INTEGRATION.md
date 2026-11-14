# Omarchy Integration — What Remains

[← Documentation index](../README.md)

Between 2026-09-24 and 2026-10-01 (`d12ce33`, `92b9d29`, `823c3d0`) the project
imported a large part of [Omarchy](https://github.com/basecamp/omarchy) and its ISO
tooling, rebranded to NeOS by find-and-replace. NeOS is a **KDE Plasma** distribution
installed by **Calamares**, and most of the import had no way to run on it. After review
(2026.10.02) and the polish pass (2026.10.03) the image keeps only what works on NeOS.

## Kept

| Area | Where | Notes |
| :-- | :-- | :-- |
| Hardware and VM services | `hv_*`, `vmware-vmblock-fuse`, `pcscd.socket`, `systemd-timesyncd`, `systemd-resolved`, `systemd-userdbd.socket`, `iwd` (NetworkManager's Wi-Fi backend) | Ordinary services that complement NeOS's own set. |
| Bluetooth audio | `etc/skel/.config/wireplumber/…/bluetooth-a2dp-autoconnect.conf` | Auto-connects A2DP headsets. |
| zsh baseline | `grml-zsh-config` package | Provides `/etc/skel/.zshrc`. |
| Part of the package set | `profile/packages.x86_64` | Firmware, file-system and hardware tools. The rescue-ISO and dormant-installer packages were trimmed in 2026.10.03. |

## Removed

| What | Why | Removed in |
| :-- | :-- | :-- |
| Root tty1 autologin, `sshd`, `systemd-networkd` (+ wait-online), `cloud-init`, `livecd-talk`/`livecd-alsa-unmuter`/`choose-mirror` units | Conflicted with NeOS's live session, or called binaries that do not exist | 2026.10.02 |
| Duplicate `omarchy/` skel trees, overlay files also owned by packages | Rename leftovers; the latter broke the ISO build | 2026.10.02 |
| 16 web-app/TUI launchers and their 39 icons, 15 configs for applications that are not installed, Omarchy branding/hook samples, Nautilus extensions, personal git/tmux configs | Every launcher's command was missing, and the configs cluttered every new home directory | 2026.10.03 |
| Omarchy defaults tree (`usr/share/neos/neos/`), the archinstall-based installer (`usr/share/neos-iso/`, `neos-iso-install`, `neos-install-dashboard`, `neos-cidata-load`, `neos-iso-cleanup-disk`, `neos-install-diagnose-media`), `usr/bin/neos-debug*`, `neos-upload-log`, `profile/packages_omarchy.x86_64` | Nothing launched them, and they needed a `linux-neos` kernel and Limine that NeOS does not ship. Calamares is the installer (ADR 0003). | 2026.10.03 |

## Restoring for a Hyprland edition

Everything removed is in git history. `git show 426b65e:<path>` (the last commit before
the 2026.10.03 removals) prints any file, and `git checkout 426b65e -- <path>` brings it
back. A Hyprland edition would also need Hyprland and the Omarchy tool set in the package
lists, the defaults tree at `/usr/share/neos/` (not `/usr/share/neos/neos/`), and the
`neos-*` helper binaries its configs call. If `neos-iso-install` were ever to replace
Calamares, that needs an ADR first. When restoring the installer, restore the
2026.10.02 credential fix with it (`tests/verify_installer_secrets.sh` at `426b65e`).
