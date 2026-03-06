# RISK & PRIORITY REPORT 🛡️

**Date:** 2026-03-03
**Author:** Maestro (Strategic Engineering Director)

## 1. System Health & Drift Assessment
- **Product Drift:** Low. The team is currently addressing foundational build stability before attempting any new features or UI enhancements, perfectly aligning with Phase 1 of the roadmap.
- **Tech Debt:** High (Build Configuration). The current build environment configuration (`pacman.conf`) is incorrectly structured and prevents automated verification from succeeding. Additionally, critical deployment guardrails (ISO size validation) are completely absent.
- **System Stability:** Blocked (Build-Time) / **DEGRADED (CI Pipeline)**. The system is fundamentally unable to produce a verified ISO due to signature validation failures, preventing any reliable artifact generation.

## 2. Identified Risks

### CRITICAL Risk: Build-Blocking Signature Requirement
- **Description:** The root-level `pacman.conf` used during the build process enforces `SigLevel = Required DatabaseRequired`. This conflicts directly with the inclusion of the unsigned `alci_repo`, resulting in persistent \"missing required signature\" errors that completely halt the ISO build process.
- **Impact:** Complete failure of continuous integration and release artifact generation.
- **Mitigation:** The Architect must adjust the global `SigLevel` in the root `pacman.conf` to `Required DatabaseOptional`. Sentinel must ensure that official repositories (`[core]`, `[extra]`, `[multilib]`) are explicitly configured with `DatabaseRequired` to prevent broad relaxation of security during the build. The target system (`airootfs/etc/pacman.conf`) must retain strict security configurations.

### HIGH Risk: Missing CI Deployment Guardrails
- **Description:** The current `.github/workflows/build-iso.yml` lacks any step to validate the size of the final ISO. GitHub Releases enforces a strict 2 GiB per-asset upload limit.
- **Impact:** Without size validation, an ISO that inadvertently exceeds the limit will build successfully but fail silently during the release publishing phase, preventing users from accessing the updated distribution.
- **Mitigation:** The Architect must implement an explicit ISO size validation step in the CI workflow that fails the build if the size reaches or exceeds exactly 2 GiB (`2 * 1024 * 1024 * 1024` bytes).

### Monitored Risk: Unsigned `alci_repo` Exposure
- **Description:** Relying on the unsigned `alci_repo` (`SigLevel = Optional`) introduces a vulnerability to MITM attacks, tampered packages, and tampered databases during the ISO generation phase.
- **Mitigation:** This is an accepted risk at this stage to utilize the Calamares installer via `arch-linux-calamares-installer.github.io`. The long-term architectural goal should be to self-host and sign these packages within a NeOS-controlled staging repository.

## 3. Immediate Priorities
1. **Unblock ISO Build:** Modify the root `pacman.conf` to resolve the `DatabaseRequired` conflict with `alci_repo`, unblocking the automated testing and build pipeline.
2. **Implement Size Guardrails:** Add a pre-deployment step to the CI workflow to strictly enforce the 2 GiB GitHub Release asset limit.
3. **Strategic Pause:** No new UI, feature, or infrastructure enhancements until the core ISO build pipeline is verified as stable and capable of producing release artifacts.