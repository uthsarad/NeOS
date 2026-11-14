# NeOS — Polish Plan (2026.10.03): a clean, professional image

**Goal (from the maintainer, 2026-10-03):** batch improvements on `testing` so a single
image review shows a clean, professional system rather than a hobbyist one. Builds on
2026.10.02 (`reports/v2026.10.02/`). Everything here is visible to a user on the live ISO
or an installed system, or ships on every install.

**Method:** walked every user-visible surface in the overlay (app menu, autostart, the new
user's home, boot menus, installer, welcome app, login screen, palette) and checked each
claim and launcher against what the image actually ships.

## Q1. Broken app-menu entries and dead home-directory clutter — high
- All 16 launchers in `etc/skel/.local/share/applications/` call binaries the image does
  not ship (`neos-launch-webapp`, `neos-webapp-handler-*`, `xdg-terminal-exec`, `dua`,
  `foot`, `imv`, `mpv`). Every user's menu shows 16 dead icons (Basecamp, HEY, X, Docker…).
- `etc/skel/.config/` carries configs for 15 applications that are not installed
  (alacritty, chromium, foot, ghostty, herdr, hypr, hyprland-preview-share-picker, imv,
  kitty, lazygit (an empty file), obsidian, opencode, starship, xournalpp, fcitx5). It also
  has Omarchy branding and hook samples under `~/.config/neos/` and
  `~/.local/state/neos/`, plus three `Hidden=true` autostart stubs for absent apps.
- **Change:** remove all of it, plus the 39 web-app icons only those launchers used. Keep
  what serves installed software (tmux, git, wireplumber Bluetooth, NeOS's own
  autostart/ksplash). New test: every shipped `.desktop` `Exec`/`TryExec` resolves to the
  overlay or a listed package.

## Q2. Dormant Omarchy runtime — medium (separate, revertable commit)
`usr/share/neos/neos/` (1.7 MB), the archinstall-based installer (`usr/share/neos-iso/`,
`neos-iso-install`, `neos-install-dashboard`, `neos-cidata-load`, `neos-iso-cleanup-disk`,
`neos-install-diagnose-media`, `usr/bin/neos-debug*`, `neos-upload-log`) and
`profile/packages_omarchy.x86_64`. Nothing launches them, they cannot work on NeOS
(`linux-neos` kernel, Limine), and the overlay copies them onto every install.
**Change:** remove from the image. Git history keeps them (restore from `426b65e`), and
`docs/architecture/OMARCHY_INTEGRATION.md` says so.

## Q3. Package bloat on installed systems — medium
The Omarchy merge added the Arch rescue-ISO toolset, and `gen-manifests.sh` copies the
whole live list onto every install. **Change:** drop what serves nothing on a desktop or is
only there for Q2: `archinstall`, `gum`, the textual/pydantic Python stack, `clonezilla`,
`drbl`, `partclone`, `partimage`, `fsarchiver`, `darkhttpd`, `livecd-sounds`, `irssi`,
`lynx`, `mc`, `wvdial`, `wvstreams`, `pptpclient`, `xl2tpd`, `vpnc`, `openconnect`, `stoken`,
`oath-toolkit`, `linux-atm`, `ndisc6`, `nmap`, `tcpdump`, `refind`, `edk2-shell`,
`memtest86+`, `memtest86+-efi` (no boot entry references the last four) and `dmraid`
(deprecated). Rescue basics stay: `testdisk`, `ddrescue`, `gptfdisk`, `smartmontools`,
`nvme-cli`, the file-system tools, and the PXE support packages. A test keeps them out.

## Q4. Brand palette: one coherent accent, readable text — high
- The accent moved to `#38bdf8`, but three files define three different hover/pressed
  pairs (palette `#3D82E0`/`#17569F`, SDDM `#22d3ee`/`#0284c7`, QSS `#22d3ee`). The
  installer slideshow, SDDM and `os-release` still use the old `#1F6FD6` (as `rgba(0.122,
  0.435, 0.839)` / `31;111;214`). The welcome app's accent rule is a gradient across all
  three hues.
- White text on `#38bdf8` has 2.1:1 contrast (WCAG AA needs 4.5:1). It is used on the
  installer's default button, current sidebar step, selected tab and menu item, and on the
  welcome app's primary button and the SDDM "Log In" button.
- **Change:** accent `#38bdf8`, hover `#7dd3fc`, pressed `#0ea5e9`, and a new `onAccent`
  `#0A0E1A` for text on accent fills (9.0 / 11.6 / 7.0 : 1). Every consumer is updated, and
  the stale tints are replaced. `verify_palette_consistency.sh` gains checks for the stale
  values and for light text on accent fills.

## Q5. Installer — medium
- `branding.desc` uploads install logs to `termbin.com` over plain HTTP, to a public
  pastebin. **Change:** remove the upload server. The log stays at
  `/var/log/installation.log` (documented in TROUBLESHOOTING).
- The slideshow icons are emoji (⚡🛡💻🚀), which render as colour-emoji clip-art.
  **Change:** monochrome glyphs in the accent colour.

## Q6. Boot menus — low
GRUB (UEFI) has no Reboot / Power Off / UEFI Firmware Settings entries; Syslinux (BIOS)
has the equivalents. The accessibility entry is labelled differently in the two menus.
**Change:** add the entries and use the same labels in both.

## Q7. Boot splash — high (maintainer decision, 2026-10-03)
The Plymouth splash is an animated cartoon cat (29 frames from `tools/loader-cat.gif`).
**Change:** the NeOS logo with three pulsing accent dots and a clean disk-unlock prompt.

## Decisions taken with the maintainer (2026-10-03)
Boot splash: logo and progress indicator. Omarchy runtime: remove. Developer
toolchains: keep a lean core (`base-devel`, `python-pip`, `nodejs`, `npm`).

## Release
`VERSION` → `2026.10.03`, a CHANGELOG section, and a review report against this plan.
