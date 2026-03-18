# Risk & Priority Report
**Date:** 2024-05-18
**From:** Maestro

## 1. Executive Summary
The NeOS repository has sound architectural foundations but is facing critical failures in its core delivery mechanism (the ISO build pipeline). A strategic pause on new features is declared until this pipeline is unblocked, stabilized, and secured.

## 2. Identified Risks

### 🔴 Critical Risk: Build-Blocking `pacman.conf` Configuration
- **Description:** The root `pacman.conf` specifies `SigLevel = Required DatabaseRequired`. The build environment uses an unsigned repository (`alci_repo`), causing the Archiso build process to fail with "missing required signature" errors, blocking ISO generation entirely.
- **Impact:** Halts all QA testing, snapshot promotion, and release processes.
- **Mitigation:** The Architect is directed to modify the root `pacman.conf` to use `DatabaseOptional` for build compatibility. Sentinel will verify this does not affect the installed system's security.

### 🟠 High Priority Risk: Missing ISO Size Validation in CI/CD
- **Description:** The `.github/workflows/build-iso.yml` workflow lacks a reliable validation step to ensure the generated ISO remains under GitHub Releases' strict 2 GiB limit.
- **Impact:** If an oversized ISO is built, the CI pipeline will succeed, but the upload to GitHub Releases will fail silently, leaving users unable to download the distribution.
- **Mitigation:** The Architect is directed to add an explicit size validation step in the CI workflow, utilizing native bash arithmetic to calculate and display exact byte values and readable formats, failing the job immediately if the limit is breached.

### 🟡 Medium Priority Risk: Unsigned Repositories in the Build Environment
- **Description:** Using an unsigned repository (`alci_repo`) in the build environment introduces supply chain risks, as a compromised repository or transport could result in malicious packages being injected into the ISO.
- **Impact:** Potential compromise of the built ISO.
- **Mitigation:** This is an accepted risk for the current sprint to unblock the build pipeline, but it must be addressed in future sprints through local mirroring, signing, or upstream collaboration.

## 3. Priority Action Plan
1. **Immediate (Today):** Execute the Architect scope to fix `pacman.conf` and implement CI size constraints.
2. **Next Steps (Future Sprints):** Address the unsigned repository risk, refine documentation, and resume feature development under strict CI stability gates.