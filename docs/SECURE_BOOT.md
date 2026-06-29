# Secure Boot on NeOS

## Overview

NeOS uses the **sbctl own-keys model** to enable Secure Boot on the *installed*
system.  You generate your own UEFI key set (PK / KEK / db), enroll them into
the firmware, and sign your GRUB EFI binary and kernel with those keys.  The
firmware then verifies the entire boot chain cryptographically before handing
control to GRUB.

---

## Why the live USB requires Secure Boot to be OFF

NeOS's live USB (the installer ISO) boots without Secure Boot for two reasons:

1. **No Microsoft-signed shim is shipped.**  Obtaining a shim signed by
   Microsoft's UEFI CA requires Canonical / Red Hat style code-signing
   agreements.  Shipping an *unsigned* shim provides no security benefit and
   just breaks boot.

2. **The squashfs live environment is not signed.**  Even if the EFI stub were
   signed, GRUB would need to verify every binary it loads (kernel, initramfs,
   modules) — a non-trivial integration effort that is out of scope for the
   installer medium.

**To install NeOS, disable Secure Boot in your firmware settings first.**
After installation you can re-enable it using the steps in this document.

---

## Enabling Secure Boot on the installed system

### Prerequisites

The following packages are installed by NeOS out of the box:

| Package   | Purpose                                    |
|-----------|--------------------------------------------|
| `sbctl`   | Own-key management and signing database    |
| `efitools`| Low-level EFI variable utilities           |
| `mokutil` | MOK enrollment helper (alternative path)   |

### Step 1 — Check the current state

```
sbctl status
```

Sample output before setup:

```
Installed:    ✗ sbctl is not installed  (or: ✓ installed)
Setup Mode:   ✓ Enabled               ← good, firmware is ready for enrollment
Secure Boot:  ✗ Disabled
Vendor Keys:  none
```

If **Setup Mode** shows **Disabled**, see the *Firmware not in Setup Mode*
section below before continuing.

### Step 2 — Run the NeOS Secure Boot setup script

Log in to the installed system as root (or use `sudo -i`) and run:

```
neos-secureboot-setup
```

The script will:

1. **Create keys** — generates PK, KEK, and db keys under
   `/usr/share/secureboot/keys/` using `sbctl create-keys`.  Idempotent: skips
   if keys already exist.

2. **Sign binaries** — signs the GRUB EFI binary
   (`/boot/EFI/GRUB/grubx64.efi` and the fallback `BOOTX64.EFI`) plus
   `/boot/vmlinuz-linux-lts` using `sbctl sign -s`.  The `-s` flag records
   each path in sbctl's signing database so pacman hooks automatically re-sign
   on future GRUB or kernel updates — no manual action required after the
   initial setup.

3. **Enroll keys** (if firmware is in Setup Mode) — runs
   `sbctl enroll-keys -m`.  The `-m` flag adds Microsoft's UEFI CA alongside
   your personal keys so firmware-signed option-ROM drivers and dual-boot with
   Windows continue to work.

4. **Print guidance** (if firmware is NOT in Setup Mode) — explains how to
   clear keys via the firmware UI and re-run the script.

### Step 3 — Enable Secure Boot

Reboot, enter firmware settings, and enable Secure Boot.  On the next boot:

```
sbctl status
```

Expected output:

```
Installed:    ✓ sbctl is installed
Setup Mode:   ✗ Disabled
Secure Boot:  ✓ Enabled
Vendor Keys:  microsoft+custom
```

---

## Firmware not in Setup Mode

If `sbctl status` shows `Setup Mode: Disabled`, the firmware already has a
Platform Key set (likely from the OEM) and will reject direct key enrollment.

### Option A — Clear keys via firmware UI (recommended)

1. Reboot into firmware settings (F2 / DEL / F12 depending on your board).
2. Navigate to **Security → Secure Boot**.
3. Select **"Delete all Secure Boot variables"**, **"Clear keys"**, or
   **"Reset to Setup Mode"** (exact label varies by vendor).
4. Save and exit.  The system will POST with Setup Mode active.
5. Boot NeOS and run `neos-secureboot-setup` again.

### Option B — mokutil (shim-based enrollment)

`mokutil` manages the **Machine Owner Key (MOK)** database used by shim.  NeOS
does **not** ship a signed shim by default, so this option only applies if you
have separately installed and configured `shim-signed`.

If you have shim in your boot chain:

```
mokutil --import /usr/share/secureboot/keys/db/db.pem
```

Set a one-time password when prompted.  Reboot; the MOK enrollment menu will
appear before GRUB.  Confirm enrollment, enter the password, and continue
booting.

---

## Automatic re-signing on updates

sbctl ships a pacman hook (`/usr/share/libalpm/hooks/zz-sbctl.hook`) that runs
`sbctl sign-all` after every kernel, GRUB, or microcode update.  Because
`neos-secureboot-setup` registers paths with `sbctl sign -s`, all enrolled
paths are re-signed automatically — the boot chain stays valid across updates
without manual intervention.

Verify registered paths at any time:

```
sbctl list-files
```

---

## fwupd interaction

`fwupd` (pre-installed on NeOS) can update UEFI firmware and peripheral
firmware via the Linux Vendor Firmware Service (LVFS).  When Secure Boot is
active there is one important consideration:

- fwupd's EFI helper binary (`/usr/lib/fwupd/efi/fwupdx64.efi`) is signed by
  the fwupd project's own key, which is **not** in your personal db.
- If fwupd needs to update UEFI firmware it will fail signature verification.

**Resolution:** Sign fwupd's EFI helper with your own key:

```
sbctl sign -s /usr/lib/fwupd/efi/fwupdx64.efi
```

Add this command after any `fwupd` package update, or register a pacman hook
in `/etc/pacman.d/hooks/` to automate it.  An example hook:

```ini
# /etc/pacman.d/hooks/99-sign-fwupd-efi.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = fwupd

[Action]
Description = Sign fwupd EFI binary for Secure Boot
When = PostTransaction
Exec = /usr/bin/sbctl sign -s /usr/lib/fwupd/efi/fwupdx64.efi
```

---

## Security considerations

| Concern | Mitigation |
|---------|------------|
| Key storage | PK/KEK/db private keys live at `/usr/share/secureboot/keys/` (root-owned, mode 700 per directory). Back them up to an offline medium. |
| Microsoft vendor keys | `sbctl enroll-keys -m` includes MS UEFI CA. This is the same trust anchor shipped by every major distro. Omit `-m` only if you have a fully closed hardware platform with no MS-signed option ROMs. |
| Re-signing on updates | sbctl's pacman hook handles this automatically for all registered files. |
| Live USB | Keep Secure Boot disabled when booting the NeOS installer USB, or boot it from a trusted path you control separately. |

---

## Quick reference

```bash
# Check status
sbctl status

# Run full setup (idempotent)
neos-secureboot-setup

# List signed files
sbctl list-files

# Manually sign an additional binary
sbctl sign -s /path/to/binary.efi

# Re-sign all registered files (run after manual key import / migration)
sbctl sign-all

# Verify a signed binary
sbctl verify /boot/EFI/GRUB/grubx64.efi
```
