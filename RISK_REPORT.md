# NeOS Risk & Priority Report

## Current Risk Landscape

### 1. Build Failure Risk (Critical)
**Observation:** The `pacman.conf` file currently forces `DatabaseRequired`, which prevents the ISO build from succeeding due to unsigned repository dependencies (`alci_repo`). This active failure in the CI pipeline is a complete blocker for any further feature validation or distribution.
**Impact:** No ISO images can be produced. Developers and users cannot test or consume the current state of NeOS.
**Mitigation Priority:** Immediate. The Architect must relax the build-time `pacman.conf` to use `DatabaseOptional` for the global `SigLevel`, allowing the build to proceed. The test `tests/verify_build_profile.sh` must be updated to reflect this necessary build environment configuration.

### 2. Release Failure Risk (High)
**Observation:** There is no CI-level enforcement of the ISO size limit (2 GiB) required by the GitHub Releases API.
**Impact:** The CI pipeline may successfully build an ISO, but the deployment step will fail silently or explicitly during the release creation, preventing users from downloading the distribution.
**Mitigation Priority:** High. The Architect must implement an explicit size validation step in `.github/workflows/build-iso.yml` that strictly enforces the 2 GiB limit before the release is attempted.

### 3. Supply Chain Risk (Medium)
**Observation:** The `alci_repo` configured in `pacman.conf` has `SigLevel = Optional`. This remains an unmitigated supply chain risk, as malicious packages could be injected during the build phase.
**Impact:** While the installed system correctly requires signatures (`DatabaseRequired`), the build process itself is vulnerable.
**Mitigation Priority:** Medium (Documented/Accepted for now). This is a known risk from the `SENTINEL_REPORT.md` that requires upstream collaboration or a signed internal mirror. It cannot be resolved in this sprint without significant infrastructure changes.

## Strategic Outlook
By prioritizing the immediate resolution of the build-blocking `pacman.conf` issue and implementing CI-level ISO size validation, the team restores the fundamental capability to build and release NeOS (Roadmap Phases 1 and 2). This hardening pass is strictly necessary before pursuing the more complex application UX and hardware reliability goals defined in Phases 4-5. The team has already successfully mitigated several previous critical and high-priority risks, including the persistent live environment autologin, systemd sandboxing deficiencies, and script concurrency issues.