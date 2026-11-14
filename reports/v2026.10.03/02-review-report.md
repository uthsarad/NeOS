# NeOS 2026.10.03 — Review Against the Polish Plan

Plan: [`00-polish-plan.md`](00-polish-plan.md). Renders: [`screenshots/`](screenshots/).

```
STATUS: APPROVED
- 7 of 7 planned items done; 3 more defects found while rendering the UI and fixed (stuck slideshow, empty welcome cards, AI-watermarked banners)
- all 56 tests/verify_*.sh pass locally; every new or extended gate was shown to fail on the pre-change tree
- not verifiable here: the Plymouth splash (no Plymouth runtime) and a full ISO build; both are covered on the next image
report: reports/v2026.10.03/02-review-report.md
```

## What changed, by surface

| Surface | Before | After | Evidence |
| :-- | :-- | :-- | :-- |
| Boot menu (BIOS/UEFI) | "NeOS (LTS Kernel)", two different accessibility labels, no exits on UEFI, cathedral background (BIOS) | "Start NeOS", "NeOS (Screen Reader)" in both menus, UEFI Firmware Settings / Reboot / Power Off, night-sky background | `verify_grub_config`, `verify_iso_grub`, `verify_syslinux_config` |
| Boot splash | Cartoon cat | Website logo, three pulsing dots in the logo's blue, disk-unlock prompt | `verify_boot_gui.sh`; [mock-up](screenshots/boot-splash-mockup.png) |
| Welcome app | Empty feature cards, buttons overflowing the window, white-on-sky primary button, placebo telemetry checkbox | Rebuilt layout, dark text on the accent, focus on the primary action, no fake control | [before](screenshots/welcome-installed-before.png) / [after, installed](screenshots/welcome-installed-after.png) / [after, live](screenshots/welcome-live-after.png); `verify_ui_render.sh` |
| Installer | Slideshow stuck on slide 1, emoji icons, white text on accent buttons, AI-watermarked welcome banner, logs uploaded to a public pastebin over HTTP | All six slides advance, monochrome glyphs, readable buttons, website logo banner, logs stay local | [slideshow](screenshots/installer-slideshow.png); `verify_ui_render.sh` (slides must differ), `verify_palette_consistency.sh` |
| Login screen | White "Log In" on sky blue, 👤 emoji, preview in the retired magenta palette | Dark "Log In", drawn silhouette, preview is a real render | [render](screenshots/login-screen.png); `verify_ui_render.sh` |
| Logo | 250×256 "N" badge in the old blue; the `neos-logo` icon named by `os-release` did not exist | The website's mark (`uthsarad/NeOSweb` `favicon.svg`) as the single source, rendered at 16–512 px plus a scalable SVG | `verify_airootfs_structure.sh` (LOGO icon exists, SVG matches source) |
| App menu | 16 dead launchers (Basecamp, HEY, X, WhatsApp, Docker, Zoom, …) | Only NeOS's own entries, all resolving | `verify_desktop_entries.sh` |
| New home directory | Configs for 15 uninstalled apps, Omarchy samples, Nautilus extensions, personal git/tmux setup | NeOS autostart/ksplash and the Bluetooth A2DP rule | `verify_desktop_entries.sh` (skel ownership) |
| Installed packages | Rescue-ISO toolset, the archinstall stack, ~25 developer toolchains | 39 packages removed; lean developer core (`base-devel`, `python-pip`, `nodejs`, `npm`) | `verify_package_hygiene.sh`; installed list 637 → 577 entries |
| Overlay copied onto every install | 476 files (dormant Omarchy runtime, launchers, icons, cat frames) | 89 files | `neos-overlay.txt` |

## Decisions taken with the maintainer (2026-10-03)
- Boot splash: logo with a progress indicator instead of the cat.
- Dormant Omarchy runtime: removed (own commit `573372a`; restore steps in
  `docs/architecture/OMARCHY_INTEGRATION.md`).
- Developer toolchains: lean core.
- Logo: use the website's icon (requested mid-pass, after the first generated badge).

## Found while rendering (not in the plan)
- **Installer slideshow stuck on slide 1** for the whole install: an in-place mutation of a
  QML `var` array never notified bindings. Fixed, and the render gate now fails if the slides'
  content does not differ.
- **Welcome app cards rendered empty and its buttons overflowed**: a stylesheet cascade and
  fixed widths. Only visible when the window is actually drawn.
- **AI-generated swirl clip-art with an image generator's watermark** was still the installer
  welcome banner and the README's "installer" screenshot. Both are replaced; the README's
  screenshots are now real renders.

## Not verifiable in this environment
- **Plymouth splash:** no Plymouth runtime here. The script sticks to documented script-language
  features, and the mock-up shows the intended layout. Check on the next image: boot, and if
  possible an encrypted install for the unlock prompt.
- **ISO build:** no `mkarchiso` or `pacman` here. Package removals were checked against every
  reference in the overlay, tools and tests; the CI build job is the proof.

## Open follow-up (not done)
- **Palette alignment with the website.** The website uses Tokyo Night (`#7aa2f7` blue,
  `#bb9af7` purple on `#1a1b26`); the image's UI accent is sky blue `#38bdf8`. The logo and
  boot splash now follow the website, the rest of the UI does not. Moving the UI palette to
  the website's would be one change in `tools/palette.json` plus the files
  `verify_palette_consistency.sh` lists. Worth deciding before a public release.
