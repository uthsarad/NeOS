# Strategic Directive

## Phase 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, snapshot-based Arch Linux desktop distribution that delivers a Windows-familiar KDE Plasma experience while prioritizing predictable behavior and low breakage.
- **Are we building toward that?** Yes. However, our CI/CD pipeline and automated testing lack completeness, risking stability. A robust pre-build test suite is necessary to ensure developers get fast, actionable feedback.
- **Are we solving the highest leverage problem?** Yes. Addressing stability in the build pipeline directly reduces tech debt and ensures that our primary architectural foundation remains stable as we approach beta.

## Phase 2 — Technical Posture Review
- **Is the system stable?** Functionally yes, but the automated CI infrastructure lacks a comprehensive pre-build test validation step, creating a blind spot. Test scripts have inconsistent execution permissions.
- **Is tech debt increasing?** Minor tech debt exists due to incomplete CI pipeline stages, hanging test risks, and unmanaged artifacts in `.gitignore`.
- **Are we overbuilding?** No, prioritizing test stability and pipeline integration is foundational hardening, not feature creep.

## Phase 3 — Priority Selection
- **Selection:** Stabilization / hardening

## Phase 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `.github/workflows/build-iso.yml`
  - `tests/verify_mkinitcpio.sh`
  - `tests/verify_qml_enhancements.sh`
  - `.gitignore`
- **Maximum allowed surface area:**
  Only the specified workflow file, test scripts, and `.gitignore`. No code, configuration, or architectural shifts are permitted.
- **Constraints Architect must obey:**
  - In `.github/workflows/build-iso.yml`, the `test` job must execute inside an `archlinux:latest` container with `--privileged` and `bash` as the default shell.
  - Pre-build validation scripts must execute before the main ISO build step, explicitly excluding ISO-dependent scripts (`verify_iso_smoketest.sh`, `verify_iso_grub.sh`, `verify_iso_size.sh`).
  - In `tests/verify_mkinitcpio.sh` and `tests/verify_qml_enhancements.sh`, implement a `timeout 60s` wrapper with a fallback (`|| true`) to ensure they are non-blocking. Ensure error messages provide a clear '💡 How to fix:' block with bulleted actionable remediation steps.
  - Add missing common entries to `.gitignore` (`*.iso`, `*.log`, `.DS_Store`, `*~`, `pacman-build.conf`).
  - Explicit statement: No test execution is needed as a distinct plan step before the formal pre-commit verification step, because we are strictly modifying CI definitions and tests themselves, and there are no appropriate test execution environments available locally.
  - All test validation scripts in the `tests/` directory must be explicitly marked as executable (`chmod +x`).

## Phase 5 — Delegation Strategy
- **Architect builds:** Implement the CI workflow improvements for pre-build testing, update `.gitignore`, apply `timeout 60s` wrappers to test scripts, and fix execution permissions (`chmod +x`). No test execution is needed before pre-commit verification.
- **Bolt optimizes:** Review the modified CI/CD workflows and tests to ensure native bash globbing/arithmetic is used over subprocess-heavy pipelines (e.g., using `${GITHUB_SHA:0:7}`, or `shopt -s nullglob` for array globbing).
- **Palette enhances:** Review test script terminal output to ensure dense strings are structured into multi-line '💡 How to fix:' blocks with bulleted actionable remediation steps to reduce developer cognitive load.
- **Sentinel audits:** Review the CI workflow changes to ensure `--privileged` container execution is scoped strictly to pre-build validation without risking host environment escape. Validate the test scripts (`verify_security_config.sh`) for existence checks before grep assertions.