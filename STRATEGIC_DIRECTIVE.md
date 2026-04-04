# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **Product Vision:** NeOS is a curated, predictable rolling-release Arch-based desktop OS targeting a Windows-familiar KDE Plasma experience.
- **Current Alignment:** Strong alignment. Recent runs stabilized repository security defaults, documentation, CI workflows, and autoupdate snapshot dependencies.
- **Highest Leverage Problem:** The `DEEP_AUDIT.md` action plan identified a gap in CI validation robustness (Item 3 in Audit: "Optional dependency warning in build-profile test"). Specifically, the CI pipeline and `tests/verify_build_profile.sh` rely on `PyYAML` to detect malformed GitHub Actions workflows. Its absence causes the workflow validation to be skipped, creating a blind spot where syntax errors could break automation.

## PHASE 2 — Technical Posture Review
- **System Stability:** Stable. The build pipeline and core services enforce strict security boundaries and native script logic.
- **Tech Debt:** Low. We verified items 1-10 in the `AUDIT_ACTION_PLAN.md` are either fully resolved, documented, or architecturally locked out from arbitrary modification. The remaining tech debt resides in test suite environmental dependencies.
- **Overbuilding Risk:** Low. The fix requires adding a single package dependency to the CI test runner environment, keeping system logic untouched.

## PHASE 3 — Priority Selection
**Selected Priority:** Infrastructure improvement (specifically, adding PyYAML to the CI audit environment for rigorous YAML validation).

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `.github/workflows/build-iso.yml`
- **Maximum allowed surface area:**
  - Modification of the `pacman -Sy` dependency installation command in the `test` job of the `.github/workflows/build-iso.yml` workflow.
- **Constraints Architect must obey:**
  - Do NOT modify any executable code in the `airootfs/` directory or bash logic in the `tests/` directory.
  - Limit the scope exactly to adding the `python-yaml` (or equivalent) package to the CI runner environment.
  - Implement the smallest correct version to resolve the missing dependency warning.

## PHASE 5 — Delegation Strategy
- **Architect:** Add `python-yaml` to the pacman installation step within the `test` job of `.github/workflows/build-iso.yml`.
- **Bolt:** Ensure the dependency addition does not significantly slow down the CI `test` job startup.
- **Palette:** Ensure any resulting YAML validation errors surfaced in CI logs remain clear and actionable.
- **Sentinel:** Verify the package installation does not alter the `--privileged` execution boundaries or introduce supply chain risks to the test environment.
