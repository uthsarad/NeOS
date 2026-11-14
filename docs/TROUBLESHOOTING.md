# NeOS Troubleshooting Summary

For the complete end-user recovery and diagnostics guide, see **[docs/user-guide/TROUBLESHOOTING.md](user-guide/TROUBLESHOOTING.md)**.

## Build Failures
- Ensure `archiso`, `squashfs-tools`, and `xorriso` are installed on the Arch build host.
- Check the build `pacman.conf` (generated into `pacman-build.conf` by `tools/gen-build-conf.sh`) for signature settings. The shipped profile uses `SigLevel = Required DatabaseOptional`.
- Review `mkarchiso` output for missing dependencies or profile validation errors (`cargo run --manifest-path tools/neos-profile-audit/Cargo.toml -- --root profile`).

## Boot & Rescue Issues
- Run `neos-doctor` (or `neos-doctor --json`) to inspect graphical session, DRM driver, and service status.
- If `/etc/fstab` or Btrfs subvolume mounting fails, select rescue/emergency mode in GRUB (`systemd.unit=rescue.target`); `SYSTEMD_SULOGIN_FORCE=1` is pre-configured so a recovery shell opens even though the `root` password is locked by default.
- Ensure the appropriate CPU microcode (`intel-ucode` or `amd-ucode`) and `linux-lts` initramfs are present under `/boot`.

## Network Problems
- Verify that `NetworkManager` is active (`systemctl status NetworkManager`).
- Check for missing hardware firmware (`linux-firmware`) or run `neos-driver-manager` to identify Broadcom/Realtek DKMS drivers.

## Snapshot Rollback
- **Important:** Do **not** run `snapper rollback <id>` on NeOS. Because `/etc/fstab` and GRUB mount the root subvolume explicitly (`subvol=/@`), changing the Btrfs default subvolume has no effect.
- Instead, open **NeOS Operations Hub** → **System Snapshot & Rollback**, or run:
  ```bash
  neos-rollback --list
  sudo neos-rollback <snapshot-id>
  ```
  and reboot. If the running OS cannot boot normally, pick a read-only snapshot from the **GRUB → Arch Linux snapshots** menu (`grub-btrfs`) and run `sudo neos-rollback <snapshot-id>` from there.

## Driver Issues
- Run `neos-driver-manager` to inspect active kernel drivers for GPU and network controllers.
- On VMs or GPUs without Wayland support, `neos-session-select` automatically selects the Xfce (X11) session; override in `/etc/neos/session.conf` if needed.
