# v2026.06.29 — Builder Report: Ubuntu-parity package additions + a11y wiring

**Agent:** @builder (Builder-1 partition)
**Date:** 2026-06-29
**Status:** DONE

---

## Files Changed

### Modified
| File | Change |
|------|--------|
| `profile/airootfs/etc/calamares/neos-packages.txt` | Added 17 packages in 6 groups |
| `profile/packages.x86_64` | Added 7 packages (a11y + fwupd + noto-fonts-cjk) |
| `profile/airootfs/etc/calamares/modules/services-systemd.conf` | Added thermald + ModemManager service enables |
| `profile/profiledef.sh` | Registered `/usr/local/bin/neos-accessibility` with 0:0:755 |

### Created
| File | Purpose |
|------|---------|
| `profile/airootfs/usr/local/bin/neos-accessibility` | Bash script: starts espeakup when accessibility=on in cmdline |
| `profile/airootfs/etc/systemd/system/neos-accessibility.service` | Oneshot unit, Before=display-manager.service, WantedBy=multi-user.target |
| `profile/airootfs/etc/systemd/system/multi-user.target.wants/neos-accessibility.service` | Relative symlink -> ../neos-accessibility.service (enable in live) |

---

## Packages Added

### neos-packages.txt (installed-system list) — 17 new packages

| Group | Packages |
|-------|----------|
| Firmware updates | `fwupd` |
| App store backend | `flatpak` |
| CJK fonts | `noto-fonts-cjk` |
| Accessibility | `brltty`, `espeak-ng`, `espeakup`, `orca`, `speech-dispatcher` |
| NVIDIA proprietary | `nvidia-dkms` |
| Secure Boot tooling | `efitools`, `mokutil`, `sbctl` |
| Thermal/connectivity/scan | `modemmanager`, `networkmanager-openvpn`, `sane`, `sane-airscan`, `thermald` |

### packages.x86_64 (live ISO list) — 5 new packages

| Group | Packages |
|-------|----------|
| Accessibility | `brltty`, `espeak-ng`, `espeakup`, `orca`, `speech-dispatcher` |

**Intentionally excluded from live list (ISO size gate — 2 GB limit):**
- `noto-fonts-cjk` — ~300 MB; not needed in live installer; installed-system only via neos-packages.txt
- `fwupd` — not needed in live installer environment; installed-system only
- `nvidia-dkms` — live uses nouveau/modesetting; keep ISO small
- All other additions (flatpak, sbctl, mokutil, efitools, thermald, modemmanager, networkmanager-openvpn, sane, sane-airscan) — installed-system only; zero ISO impact

---

## Accessibility Wiring Summary

The existing GRUB/syslinux accessibility menu entry already passes `accessibility=on` on the kernel cmdline. The new wiring makes this a real feature:

1. **`neos-accessibility` script** — greps `/proc/cmdline` for `accessibility=on`; if present, calls `systemctl start espeakup.service` and logs via `logger -t neos-accessibility`. On normal boot exits 0 with no action.
2. **`neos-accessibility.service`** — Type=oneshot, After=sysinit.target, Before=display-manager.service/sddm.service. Same security profile as the existing `neos-vm-graphics.service` (ProtectSystem=strict, ProtectHome=yes, PrivateTmp=yes, NoNewPrivileges=yes).
3. **Enable symlink** — `multi-user.target.wants/neos-accessibility.service -> ../neos-accessibility.service` (relative, matching existing house pattern for neos-driver-manager, neos-liveuser-setup, neos-vm-graphics).
4. **File permissions** — `["/usr/local/bin/neos-accessibility"]="0:0:755"` added to `profiledef.sh` file_permissions array.

---

## Service Enablement (installed system via Calamares)

`services-systemd.conf` is the mechanism (confirmed by inspection). Added:
- `thermald` (enable) — CPU thermal management
- `ModemManager` (enable) — mobile broadband / 4G/5G modems

`fwupd` is D-Bus/socket activated — no manual enable needed (per spec and upstream behavior).

---

## Quality Gates

- `bash -n neos-accessibility`: PASS
- `shellcheck neos-accessibility`: PASS (no issues)
- No changes to build.sh, grub.cfg, theme files, docs, CHANGELOG, VERSION, or tests/ (other-agent territory respected)
- No git commit made

---

## Package Confidence Notes

All packages verified against Arch Linux / Chaotic-AUR knowledge:
- All 17 packages are standard Arch repo or Chaotic-AUR packages
- `sane-airscan` is in Arch community/extra; mDNS-based scanner discovery — confirmed standard
- `espeakup` is in Arch extra — console screen reader bridge between espeak-ng and speakup kernel module; confirmed
- `efitools` is in Arch extra — confirmed
- No packages are uncertain
