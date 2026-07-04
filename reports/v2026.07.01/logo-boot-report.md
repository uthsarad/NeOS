# v2026.07.01 — NeOS Logo Integration + Windows-11 Boot Splash

STATUS: DONE (reconstructed post-hoc during the v2026.07.01 deep audit; the
original agent run completed the work but did not persist this report file).

## Source logo

- `NeOS Logo/Gemini_Generated_Image_cxxpsdcxxpsdcxxp.png` — 2816×1536 RGBA, no
  transparent padding. Circular "neo" blue-swirl badge on a dark navy textured
  background (corners ≈ `#111C2A`).
- Background removed via ImageMagick flood-fill from all four corners at 20%
  fuzz, producing a clean transparent-background badge. Source file left
  untouched.

## Assets created

| File | Size | Purpose |
|------|------|---------|
| `profile/airootfs/usr/share/plymouth/themes/neos/logo.png` | 293×300 RGBA | Plymouth boot-splash logo (transparent badge) |
| `profile/airootfs/etc/calamares/branding/neos/logo.png` | 250×256 RGBA | Calamares `productLogo` / `productIcon` slot |
| `profile/airootfs/etc/calamares/branding/neos/welcome.png` | 600×300 sRGB | Calamares `productWelcome` banner |

## Boot splash — Windows-11 layout

`profile/airootfs/usr/share/plymouth/themes/neos/neos.script` reworked:

- NeOS `logo.png` sprite: centered horizontally, bottom edge ~20px **above**
  vertical centre.
- Animated cat (`cat-00.png`..`cat-31.png`, 32 frames) acts as the loader:
  centered horizontally, top edge ~20px **below** vertical centre.
- LUKS password prompt: below the cat.
- Preserved: deep-navy gradient background, ~25fps refresh loop, Z-order
  (logo/cat Z=10, prompt Z=20).
- On 1080p: logo centre ≈ 34% from top, cat centre ≈ 70% — Windows-11
  proportions.

## Wiring verified (deep audit)

- `themes/default.plymouth → neos/neos.plymouth`, `plymouthd.conf` `Theme=neos`,
  `mkinitcpio.conf` HOOKS include `plymouth`. Splash renders at boot.
- `branding.desc` references (`logo.png`, `welcome.png`, `show.qml`) all resolve.

## Not touched

- Desktop wallpaper (separate asset).
- Calamares `stylesheet.qss` / module `.conf` files (owned by the
  cursor/installer workstream — see `cursor-installer-report.md`).
- Source logo file.
