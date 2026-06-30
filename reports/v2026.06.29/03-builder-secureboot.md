# v2026.06.29 — Builder Report: Secure Boot (Builder-2)

**Agent:** @builder (Builder-2, Secure Boot boot-chain scope)
**Status:** DONE
**Quality gates:** bash -n PASS, shellcheck PASS

---

## Files Created

### `profile/airootfs/usr/local/bin/neos-secureboot-setup`
Post-install helper script implementing the sbctl own-keys Secure Boot workflow.
Not called by Calamares; user-initiated only.

Key design decisions:
- `set -euo pipefail`, strict PATH, matching error-handler/header house style from `neos-autoupdate.sh` and `build.sh`
- `check_root` / `check_uefi` / `check_sbctl` guard functions run before any state change
- **Setup Mode detection** via `sbctl status | grep -i "setup mode" | grep -qi "enabled"` — zero dependencies beyond sbctl itself
- **Key creation is idempotent**: guards on existence of `/usr/share/secureboot/keys/PK/PK.key` before calling `sbctl create-keys`
- **Signing is idempotent**: `sbctl sign -s <path>` registers paths in sbctl's database; re-running is safe and paths survive kernel/GRUB updates via sbctl's pacman hook
- **EFI binary discovery** searches `/boot/EFI`, `/boot/efi/EFI`, `/efi/EFI` — handles all Calamares ESP mount conventions without hardcoding
- Signs: `grubx64.efi`, `BOOTX64.EFI` (fallback; Calamares sets `installEFIFallback: true`), `vmlinuz-linux-lts`, `initramfs-linux-lts-fallback.img`
- If firmware IS in Setup Mode: `sbctl enroll-keys -m` (Microsoft vendor certs included for option-ROM / dual-boot compat)
- If firmware is NOT in Setup Mode: signs everything, prints clear two-option guidance (firmware UI / mokutil), exits 0 — **never fails the install**

### `docs/SECURE_BOOT.md`
User-facing documentation covering:
- Why the live USB needs Secure Boot off (no MS-signed shim shipped)
- Full walkthrough of `neos-secureboot-setup` for the installed system
- Setup Mode requirement and how to enter it
- Option A (firmware UI) and Option B (mokutil with shim-signed) enrollment paths
- fwupd EFI helper signing and example pacman hook
- Security considerations table and quick-reference command list

---

## Files NOT Modified (intentional)

| File | Reason |
|------|--------|
| `build.sh` | Not needed. `neos-secureboot-setup` lives under `profile/airootfs/usr/local/bin/` which archiso bundles automatically into the squashfs. The overlay manifest (`neos-overlay.txt`) is generated at build time by scanning `airootfs/` — the new script is not in the exclusion list so it is included in the installed system without any build.sh edit. |
| `profile/profiledef.sh` | Owned by Builder-1. Cannot edit. |
| `profile/packages.x86_64` | Owned by Builder-1. |
| `profile/airootfs/etc/calamares/neos-packages.txt` | Owned by Builder-1. |
| `profile/grub/grub.cfg` | No GRUB changes required for post-install SB setup. |
| `profile/airootfs/etc/calamares/settings.conf` | Script is NOT wired into Calamares exec sequence (see Integration Decision). |

---

## Integration Decision — Why NOT auto-wired into Calamares

Key enrollment via `sbctl enroll-keys` writes the Platform Key into UEFI firmware variables. If the firmware is not in Setup Mode, this call fails. If a partially-written PK is committed mid-install the system may be unbootable. Calamares runs as a single exec sequence without per-step rollback, so any failure mid-sequence can leave the disk in an inconsistent state.

The safe boundary is: Calamares installs the OS and GRUB normally; the user boots the installed system; then runs `neos-secureboot-setup` at their own discretion after reading the documentation. This matches the Arch Wiki recommendation for sbctl and is the same approach used by EndeavourOS and Garuda Linux.

If a future opt-in Calamares hook is desired, it should be a `shellprocess` module with a condition that skips enrollment entirely (sign only), placed after the `bootloader` step. No such hook is added here because the risk/benefit ratio favours the manual path.

---

## Action Required by Orchestrator / Builder-1

**profiledef.sh file_permissions entry to add:**

```bash
["/usr/local/bin/neos-secureboot-setup"]="0:0:755"
```

This must be added to the `file_permissions` array in `profile/profiledef.sh` by Builder-1 (who owns that file). Without this entry, archiso's squashfs packing will include the file but may not set the executable bit, causing a "Permission denied" error when the user runs it on the live system or installed system (if copied before chmod).

---

## Quality Gates

- [x] `bash -n profile/airootfs/usr/local/bin/neos-secureboot-setup` — PASS
- [x] `shellcheck profile/airootfs/usr/local/bin/neos-secureboot-setup` — PASS (zero warnings)
- [x] No package list files modified
- [x] No profiledef.sh modified
- [x] No Calamares settings.conf modified
- [x] No GRUB theme files modified
- [x] No git commit or push

---

## Ready for @validator

- [x] All changes complete
- [x] Script syntax clean (bash -n + shellcheck)
- [x] Documentation written
- [x] build.sh untouched (confirmed unnecessary)
- [x] profiledef.sh delegation note recorded above
