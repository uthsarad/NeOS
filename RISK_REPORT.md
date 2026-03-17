# Risk & Priority Report
**Date:** 2026-02-17
**From:** Maestro

## 1. Executive Summary
The NeOS repository currently has strong architectural foundations but is experiencing a critical failure in its core delivery mechanism (the ISO build pipeline). A 'No-build day' has been declared for new features until this pipeline is unblocked and stabilized.

## 2. Identified Risks

### 🔴 Critical Risk: Build-Blocking `pacman.conf` Configuration
- **Description:** The root `pacman.conf` currently specifies `SigLevel = Required DatabaseRequired`. This causes the Archiso build process to fail with "missing required signature" errors, completely blocking the generation of new ISOs.
- **Impact:** Halts all QA testing, snapshot promotion, and release processes.
- **Mitigation:** The Architect is directed to modify the root `pacman.conf` to use `DatabaseOptional` for build compatibility. Sentinel will verify this does not affect the installed system's security.

### 🟠 High Priority Risk: Missing ISO Size Validation in CI/CD
- **Description:** The `.github/workflows/build-iso.yml` workflow lacks a validation step to ensure the generated ISO remains under GitHub Releases' hard limit of 2 GiB (2147483648 bytes).
- **Impact:** If an oversized ISO is built, the CI pipeline will succeed, but the upload to GitHub Releases will fail silently, leaving users unable to download the distribution.
- **Mitigation:** The Architect is directed to add an explicit size validation step in the CI workflow, utilizing native bash arithmetic to calculate and display exact byte values and readable formats, failing the job immediately if the limit is breached.

### 🟡 Medium Priority Risk: Architecture Drift and Incomplete Features
- **Description:** Multi-architecture support (i686, aarch64) is inconsistent. Features like Calamares, ZRAM, and Snapper are only fully supported on x86_64.
- **Impact:** User confusion and potential runtime failures if expectations are not managed or code diverges significantly.
- **Mitigation:** Deferred for this sprint. These issues must be addressed through documentation updates and feature parity reviews in subsequent cycles, once the core x86_64 build is stabilized.

## 3. Priority Action Plan
1. **Immediate (Today):** Execute the Architect scope to fix `pacman.conf` and implement CI size constraints.
2. **Next Steps (Future Sprints):** Address medium-priority risks, refine documentation, and resume feature development under strict CI stability gates.
