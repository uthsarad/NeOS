# Strategic Directive

## Phase 1 — Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution delivering Windows-level usability with Linux-level power. It bridges the gap between Arch flexibility and consumer reliability.

**Are we building toward that?**
Yes, but our current testing infrastructure and CI/CD pipelines require further refinement. While we have implemented ISO size validations, pre-build pre-commit checks, and basic system service hardening, we need to ensure test stability, error handling, and documentation keep pace. The "Windows-familiar experience" is heavily reliant on automated, predictable processes that do not block development or deployment unnecessarily.

**Are we solving the highest leverage problem?**
The highest leverage problem now is ensuring our testing infrastructure is robust, non-blocking where appropriate, and provides actionable feedback. Specifically, addressing Medium and Low priority audit items such as pre-build CI integration, test reliability (e.g., non-blocking UI/pre-build tests), and consistent execution flags (chmod) will stabilize the pipeline and reduce developer friction.

## Phase 2 — Technical Posture Review
**Is the system stable?**
Yes. The ISO builds successfully, size validation is active, and critical system services have been hardened.

**Is tech debt increasing?**
Yes, in our CI and testing workflows. We lack a comprehensive pre-build test suite execution in `.github/workflows/build-iso.yml`. Furthermore, some tests (like `verify_qml_enhancements.sh` and `verify_mkinitcpio.sh`) may hang or fail the pipeline if they are not explicitly designed to be non-blocking or wrapped with timeouts as defined by our memory rules. We also need to ensure consistent executable permissions on test scripts and proper gitignore rules for build artifacts.

**Are we overbuilding?**
No. We are addressing defined tech debt and audit action items to solidify the foundation before introducing new features.

## Phase 3 — Priority Selection
**Selection:** Stabilization / hardening

**Justification:** The system is functionally stable, but the CI/CD pipeline and testing infrastructure require hardening. Addressing Medium and Low priority audit items (Items 12, 13, and 16 from `DEEP_AUDIT.md`) and aligning with memory constraints (non-blocking pre-build tests, timeout wrappers, actionable error messages) will stabilize the development workflow and prevent CI failures.

## Phase 4 — Controlled Scope Definition
**Targeted Files:**
- `.github/workflows/build-iso.yml`
- `tests/verify_mkinitcpio.sh`
- `tests/verify_qml_enhancements.sh`
- `.gitignore`

**Maximum Allowed Surface Area:**
Modifications are strictly limited to updating the CI workflow for pre-build testing, applying timeout/non-blocking logic to specific test scripts, updating `.gitignore` for build artifacts, and ensuring consistent test script execution. No new features, system configuration changes, or architectural shifts are permitted.

**Constraints for Architect:**
- In `.github/workflows/build-iso.yml`, the `test` job must execute inside an `archlinux:latest` container with `--privileged` and `bash` as the default shell.
- Pre-build validation scripts must execute before the main ISO build step, explicitly excluding ISO-dependent scripts (`verify_iso_smoketest.sh`, `verify_iso_grub.sh`, `verify_iso_size.sh`).
- In `tests/verify_mkinitcpio.sh` and `tests/verify_qml_enhancements.sh`, implement a `timeout 60s` wrapper with a fallback (`|| true`) to ensure they are non-blocking. Ensure error messages provide a clear '💡 How to fix:' block with bulleted actionable remediation steps.
- Add missing common entries to `.gitignore` (`*.iso`, `*.log`, `.DS_Store`, `*~`, `pacman-build.conf`).

## Phase 5 — Delegation Strategy
- **Architect:** Implement the CI/CD pipeline improvements, update `.gitignore`, and apply non-blocking/timeout wrappers to the specified test scripts.
- **Bolt:** Review the test scripts to ensure native bash operations are preferred over subprocess-heavy pipelines where applicable, maintaining fast execution.
- **Palette:** Review the terminal error messages in the modified test scripts to ensure they are formatted as multi-line outputs with a clear '💡 How to fix:' block and actionable steps, minimizing developer cognitive load.
- **Sentinel:** Review the CI workflow changes to ensure the privileged execution of the `test` job does not introduce unintended security risks outside the intended scope of pre-build validation.
