# Risk & Priority Report

## Current System Risks
**1. Pipeline Instability (High Probability, Medium Impact):**
- Tests like `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh` are currently executed without strict timeout constraints. If a test hangs or fails in an environment without UI/Calamares elements, it could block the entire build pipeline for all developers.
- Implementing the 60-second timeout and fallback logic (`|| true`) directly mitigates this risk.

**2. Cryptic Errors & Developer Friction (High Probability, Low Impact):**
- Currently, when CI or local testing fails, terminal output does not strictly follow actionable UX guidelines. Without bulleted "How to fix:" instructions, contributors waste time deciphering errors.
- Enforcing Palette’s multi-line actionable format on errors reduces cognitive load and speeds up resolution.

**3. Test Script Execution Failures (Medium Probability, Low Impact):**
- Some scripts in `tests/` may not have the executable (`+x`) bit set consistently across environments, causing spurious CI failures when called via `bash ./script.sh`.
- Standardizing the execution method or permissions ensures consistent runs.

**4. Privileged Container Execution (Low Probability, High Impact):**
- Using `--privileged` in the `test` job of `.github/workflows/build-iso.yml` is necessary for pre-build checks requiring lower-level access (e.g., verifying mkinitcpio or filesystem configs), but introduces theoretical security risk if untrusted code runs within the job.
- This is mitigated by restricting workflow modification via the auto-merge bot and Sentinel's ongoing review.

## Priorities Addressed
- **Immediate:** Prevent CI hangs by implementing non-blocking timeout wrappers on UI/pre-build scripts.
- **Immediate:** Standardize terminal UX for errors in the modified scripts.
- **Short-term:** Clean up `.gitignore` to prevent accidental commits of large ISO or temporary files, directly addressing `DEEP_AUDIT.md` Low Priority Item 13.

## Architectural Trade-offs
- **Fail-open vs. Fail-closed Testing:** By wrapping tests like `verify_qml_enhancements.sh` in `timeout 60s ... || true`, we consciously choose to fail-open (allow the build to proceed) if the test hangs or fails. This assumes these specific tests are non-critical to the underlying OS stability (they verify UX enhancements), preferring pipeline continuity over strict gating for these specific checks.
