# Risk & Priority Report

**Date:** 2026-03-01
**Author:** Maestro

## Identified Risks

### 1. Supply Chain Attack via Unsigned Packages (High Severity)
- **Description:** The `pacman.conf` used during the ISO build process defines the `alci_repo` with `SigLevel = Optional`. If the mirror or network traffic is compromised, malicious packages could be injected into the live ISO.
- **Likelihood:** Medium
- **Impact:** High (Full compromise of the live environment, potentially cascading to installed systems).
- **Mitigation:** The build environment must enforce `SigLevel = Required DatabaseOptional` for `alci_repo`.

### 2. Failing CI Tests Masked by Late Execution (Medium Severity)
- **Description:** Several validation scripts (`tests/verify_*.sh`) in the `.github/workflows/build-iso.yml` are currently executed only *after* the computationally expensive and time-consuming `mkarchiso` build process. If a pre-build requirement is invalid, the build fails late, wasting CI minutes, or worse, the build succeeds but the validations fail.
- **Likelihood:** High (As contributors add or modify build parameters over time).
- **Impact:** Medium (Wasted CI resources, slower feedback loop).
- **Mitigation:** Add a pre-build CI step to run validations *before* building the ISO.

### 3. Architecture Fragmentation & User Confusion (Low Severity)
- **Description:** The project unofficially builds for `i686` and `aarch64` (evident via `bootstrap_packages.*` files), but `x86_64` is the only supported architecture.
- **Likelihood:** Medium (Users attempting to install on unsupported hardware).
- **Impact:** Low (Support burden and poor user experience).
- **Mitigation:** Continue ensuring documentation explicitly states these architectures are experimental.

## Next Steps
The immediate priority is to address **Risk 1** and **Risk 2** by hardening the CI configuration in `build-iso.yml` and modifying `pacman.conf` for the unsigned `alci_repo` vulnerability.