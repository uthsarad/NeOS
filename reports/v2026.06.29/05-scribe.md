# Scribe Report: v2026.06.29 Documentation

**Date:** 2026-06-29
**Version:** 2026.06.29
**Status:** DONE

## Summary

Documentation for v2026.06.29 release completed. All user-facing changes, GRUB theme fixes, and Ubuntu-parity capabilities documented and committed to permanent records.

---

## Files Updated

### 1. VERSION
- **Status:** ✅ Created
- **Content:** `2026.06.29`
- **Path:** `/home/nima/NeOS/VERSION`

### 2. CHANGELOG.md
- **Status:** ✅ Updated
- **Content:** Added v2026.06.29 section with:
  - Fixed: GRUB starfield theme selected-menu-entry visibility
  - Added: Firmware updates (fwupd), accessibility suite (orca, espeakup, brltty), flatpak, CJK fonts, NVIDIA dkms, Secure Boot helpers (sbctl, mokutil, efitools, neos-secureboot-setup), hardware/connectivity (thermald, modemmanager, networkmanager-openvpn, sane, sane-airscan)
  - Changed: ISO package discipline (live squashfs minimal, installed system network-pacstrapped)
- **Path:** `/home/nima/NeOS/CHANGELOG.md`
- **House style:** Maintained "Keep a Changelog" format with detailed prose explaining rationale and tradeoffs

### 3. README.md
- **Status:** ✅ Updated
- **Changes:**
  - Enhanced "Automated Hardware Optimization" to mention NVIDIA dkms, Intel thermal, wireless/modem support
  - Enhanced "Secure by Default" to mention Secure Boot helpers
- **Path:** `/home/nima/NeOS/README.md`

### 4. ADR 0006: Ubuntu Parity Capabilities
- **Status:** ✅ Created
- **Content:** Architecture Decision Record documenting:
  - Ubuntu 26.04 feature gap analysis
  - Two-tier package placement strategy (live squashfs minimal; installed system network-pacstrapped)
  - 2 GiB ISO constraint rationale
  - Conservative Secure Boot user-initiated choice (sbctl own-keys, not auto-wired to prevent brick risk)
  - Trade-offs and acceptance criteria
- **Path:** `/home/nima/NeOS/docs/decisions/0006-ubuntu-parity-capabilities.md`
- **Note:** Sequential numbering used; 0005-parallel-downloads.md already exists

---

## Release Verification

### Version Uniqueness
- Version 2026.06.29 is DATE-based and unique per NeOS release cadence (date format YYYY.MM.DD)
- Previous release was 2026.06.24; this version is 5 days later

### Changelog Completeness
- ✅ All three major change categories documented: Fixed, Added, Changed
- ✅ Detailed explanations of GRUB fix and rationale behind package placement
- ✅ ISO size constraint and accessibility support clearly explained
- ✅ Secure Boot user-initiated approach and reasoning documented

### Documentation Consistency
- ✅ CHANGELOG entries match requested change descriptions
- ✅ ADR explains strategic decisions behind package placement
- ✅ README reflects new capabilities without introducing new sections (maintained existing structure)
- ✅ Markdown well-formed; no broken internal paths

---

## Changelog Entry Details

### Fixed Section
- GRUB starfield theme: removed broken blob_*.png pixmap reference, set selected_item_color to #3465a4 (Arch blue), deleted orphan blob_w.png

### Added Section
- Firmware: fwupd
- Accessibility: orca, speech-dispatcher, espeak-ng, espeakup, brltty (live); neos-accessibility oneshot service
- App store: flatpak
- Fonts: noto-fonts-cjk (installed system)
- NVIDIA: nvidia-dkms
- Secure Boot: sbctl, mokutil, efitools, neos-secureboot-setup helper, docs/SECURE_BOOT.md
- Hardware: thermald, modemmanager, networkmanager-openvpn, sane, sane-airscan

### Changed Section
- ISO package placement discipline: live squashfs minimal (a11y speech stack only); everything else network-pacstrapped at install via neos-packages.txt

---

## ADR Context

The ADR documents the strategic decision to achieve Ubuntu feature parity while respecting the 2 GiB ISO hard limit:

- **Live image:** Only accessibility speech stack shipped (orca, espeakup, etc.) to enable live screen-reader support without bloating the ISO
- **Installed system:** fwupd, flatpak, nvidia-dkms, Secure Boot helpers, hardware/connectivity packages installed via pacstrap at installation time
- **Secure Boot approach:** User-initiated (sbctl own-keys, not auto-wired) to prevent UEFI firmware brick risk
- **Rationale:** Two-tier placement keeps ISO under 2 GiB while delivering feature parity to the installed workstation

---

## Status

✅ **DOCUMENTATION COMPLETE** — All files updated, version unique, changelog detailed, ADR recorded. Ready for release.
