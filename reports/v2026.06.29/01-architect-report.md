# v2026.06.29 — Architecture Brief: Ubuntu-parity capabilities

**Type:** Feature (multi-capability). **Routing:** Smart Routing + security gate (Secure Boot).
**Driver:** Gap analysis vs Ubuntu 26.04 Desktop ISO (`/home/nima/Ubuntu Desktop/...`). NeOS is Arch-based; adopt the *capabilities*, not Ubuntu packages.

## Confirmed gaps (evidence: Ubuntu DE manifest, NeOS `neos-packages.txt`)
- No firmware updates (Ubuntu: fwupd).
- Accessibility boot entry (`accessibility=on` in grub.cfg + syslinux) is a **dead promise** — no a11y packages installed (Ubuntu: orca, speech-dispatcher, espeak-ng, brltty).
- No app-store backend — Discover ships but no flatpak (Ubuntu: snapd/gnome-software).
- No CJK fonts → tofu (Ubuntu: fonts-noto-cjk).
- No NVIDIA proprietary path — driver-manager only *suggests* it, package absent.
- No Secure Boot at all (Ubuntu: signed shim + grub + mokutil + fwupd-signed).
- Medium: thermald, modemmanager, NM VPN plugins, sane/scanners.

## Decisions / constraints (FROZEN — agents must obey)
1. **File ownership partition (no collisions):**
   - **Builder-1** owns ALL package-list edits: `profile/airootfs/etc/calamares/neos-packages.txt`, `profile/packages.x86_64`, and any new files under `profile/airootfs/usr/local/bin/` + `profile/airootfs/etc/systemd/system/` for a11y/service enablement. This includes the Secure Boot *packages* (sbctl, mokutil, efitools).
   - **Builder-2** owns the Secure Boot *boot-chain*: `build.sh`, GRUB/EFI wiring, a new enrollment helper script, and a new doc under `docs/`. **Builder-2 must NOT edit any package list** — Builder-1 adds sbctl/mokutil/efitools.
   - **Scribe** owns docs only: `VERSION`, `CHANGELOG.md`, `README.md`, `docs/decisions/`.
   - **Tester** owns `tests/` (new verify scripts only).
2. **Secure Boot scope (conservative, achievable on Arch):** Enable SB for the **installed system** via `sbctl` (own-keys model) + ship `mokutil`. Do **NOT** attempt to re-sign the live ISO boot with Microsoft-trusted shim (needs shim-signed/MS keys — out of scope). Document that the live USB still requires SB-off or user key enrollment; the installed system gets `sbctl` key creation + signing guidance/automation.
3. **A11y wiring:** make the existing `accessibility=on` boot entry real — install `espeakup` (console screen reader) + `orca` (GUI) + `speech-dispatcher` + `espeak-ng` + `brltty`; enable `espeakup` when `accessibility=on` is on the kernel cmdline (live), and ship orca-friendly defaults.
4. **Versioning:** date scheme `2026.06.29` (matches CHANGELOG/profiledef), not semver. Scribe creates `VERSION` = `2026.06.29`.
5. **No git push.** Do not commit unless the orchestrator says so.

## Package additions (Builder-1, exact)
HIGH: `fwupd`, `flatpak`, `noto-fonts-cjk`, `orca`, `speech-dispatcher`, `espeak-ng`, `espeakup`, `brltty`, `nvidia-dkms`.
SB: `sbctl`, `mokutil`, `efitools`.
MEDIUM: `thermald`, `modemmanager`, `networkmanager-openvpn`, `sane`, `sane-airscan`.
Services to enable (multi-user/appropriate target): `thermald`, `ModemManager`. fwupd is socket/D-Bus activated (no manual enable). Verify each package exists in Arch/chaotic repos; nvidia-dkms pairs with existing `linux-lts-headers`+`dkms`.

## Out of scope this run
ISO live-boot shim signing; snapd; apport/whoopsie; release-upgrader; gnome-initial-setup.
