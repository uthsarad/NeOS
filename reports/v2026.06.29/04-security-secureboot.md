# v2026.06.29 — Security Gate: Secure Boot helper

**Reviewer:** Orchestrator (inline). The spawned @security agent hit the session
limit and returned no report, so the gate was performed inline instead of skipped.

**Scope:** `profile/airootfs/usr/local/bin/neos-secureboot-setup`, `docs/SECURE_BOOT.md`.

## Verdict: APPROVED (with one MEDIUM finding fixed in this commit)

## Findings
- **[MEDIUM — FIXED] Brick path when ESP not found.** Original flow signed
  bootloader binaries, but if `find_efi_files` found none it only `warn`ed and
  continued; `enroll_keys` then ran in Setup Mode, enrolling keys with an
  **unsigned bootloader** → unbootable once Secure Boot is enabled.
  *Fix:* added `SIGNED_EFI_COUNT`; enrollment now refuses unless at least one
  bootloader EFI was signed, printing manual-signing guidance instead.
- **[OK] Boot-order safety.** Keys created → binaries signed → enroll (Setup Mode
  only). Boot chain is signed before keys go live; common path cannot brick.
- **[OK] Microsoft vendor keys.** `sbctl enroll-keys -m` keeps option-ROM /
  dual-boot firmware functional.
- **[OK] Enrollment gating.** Enroll only when firmware is in Setup Mode;
  otherwise prints a manual guide. sbctl itself also refuses enroll with a PK
  present, so a mis-detection cannot force enrollment.
- **[OK] Privilege / injection.** Strict PATH, root (EUID) check, UEFI check,
  sanitized `SCRIPT_NAME`, trap sanitizes `BASH_COMMAND` to printable chars, no
  unsanitized input (no args), `find -print0`/`read -d ''` handle spaces.
- **[OK] Idempotent.** `keys_exist` guard; `sbctl sign -s` records in db (pacman
  hook re-signs on updates).
- **[OK] Docs.** `SECURE_BOOT.md` correctly states the live USB needs SB-off (no
  MS-signed shim shipped) and gives non-brick-prone guidance.

## Integration
Script is NOT wired into Calamares — user-initiated post-install, the correct
conservative choice for sbctl key enrollment.

Post-fix: `bash -n` + `shellcheck -S warning` clean; full test suite 32/32.
