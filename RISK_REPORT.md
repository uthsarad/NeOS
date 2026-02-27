# Risk & Priority Report

**Date:** 2026-02-18
**Author:** Maestro

## Identified Risks

### 1. Supply Chain Attack via Unsigned Packages (Medium Severity)
- **Description:** The `pacman.conf` used during the ISO build process defines the `alci_repo` with `SigLevel = Optional`. If the mirror or network traffic is compromised, malicious packages could be injected into the live ISO.
- **Likelihood:** Low
- **Impact:** High (Full compromise of the live environment, potentially cascading to installed systems).
- **Mitigation:** The installed system (`airootfs/etc/pacman.conf`) uses strict signature checking. However, the build environment must either securely mirror these packages or implement a signing process.

### 2. Update Brittleness due to Disk Space (Medium Severity)
- **Description:** `neos-autoupdate.sh` executes system updates and takes Btrfs snapshots without verifying available disk space. If a snapshot or update fills the disk mid-process, the system could be left in an unbootable state with broken rollbacks.
- **Likelihood:** Medium (Especially on smaller partitions or after extended use).
- **Impact:** High (System failure requiring manual intervention).
- **Mitigation:** Add pre-flight disk space checks (e.g., minimum 10% free space) to `neos-autoupdate.sh` before initializing updates.

### 3. Architecture Fragmentation & User Confusion (Low Severity)
- **Description:** The project unofficially builds for `i686` and `aarch64` (evident via `bootstrap_packages.*` files), but `x86_64` is the only supported architecture.
- **Likelihood:** Medium (Users attempting to install on unsupported hardware).
- **Impact:** Low (Support burden and poor user experience).
- **Mitigation:** Continue ensuring documentation explicitly states these architectures are experimental, and consider warning users during the Calamares install phase if non-x86_64 architecture is detected.

## Next Steps
The immediate priority is to address **Risk 2** by hardening the autoupdate script with disk space checks, and to begin exploring solutions for **Risk 1** without breaking the current ISO build pipeline.