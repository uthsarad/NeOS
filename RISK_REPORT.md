# Risk & Priority Report

**Date:** 2026-03-01
**Author:** Maestro

## Identified Risks

### 1. Build Verification Brittleness (Medium Severity)
- **Description:** Several pre-build validation checks in `tests/verify_build_profile.sh` rely on fragile `grep`, `sed`, and bash string manipulation (e.g., parsing `bootmodes=` from `profiledef.sh`). If the formatting of `profiledef.sh` changes slightly (e.g., adding line breaks or varying quotes), these checks may pass falsely or fail spuriously, leading to broken ISO builds down the line.
- **Likelihood:** High (As contributors add or modify build parameters over time).
- **Impact:** Medium (Build failures in CI or local environments, increasing contributor friction).
- **Mitigation:** Incrementally migrate complex configuration parsing into the typed `neos-profile-audit` Rust tool, which can safely parse bash-like variable assignments and enforce constraints (like validating specific bootmodes) before the expensive `mkarchiso` step runs.

### 2. Supply Chain Attack via Unsigned Packages (Medium Severity)
- **Description:** The `pacman.conf` used during the ISO build process defines the `alci_repo` with `SigLevel = Optional`. If the mirror or network traffic is compromised, malicious packages could be injected into the live ISO.
- **Likelihood:** Low
- **Impact:** High (Full compromise of the live environment, potentially cascading to installed systems).
- **Mitigation:** The installed system (`airootfs/etc/pacman.conf`) successfully uses strict signature checking (`DatabaseRequired`). However, the build environment must either securely mirror these packages or implement a signing process.

### 3. Architecture Fragmentation & User Confusion (Low Severity)
- **Description:** The project unofficially builds for `i686` and `aarch64` (evident via `bootstrap_packages.*` files), but `x86_64` is the only supported architecture.
- **Likelihood:** Medium (Users attempting to install on unsupported hardware).
- **Impact:** Low (Support burden and poor user experience).
- **Mitigation:** Continue ensuring documentation explicitly states these architectures are experimental.

## Next Steps
The immediate priority is to address **Risk 1** by migrating the `profiledef.sh` parsing logic out of shell scripts and into the `neos-profile-audit` Rust tool. This provides a robust, typed validation layer that fails fast and gives clearer error messages during the build phase.