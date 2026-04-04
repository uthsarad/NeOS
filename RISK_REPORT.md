# Risk & Priority Report

## Current System Risks
1. **CI Pipeline Blind Spot (Medium Risk):** The `DEEP_AUDIT.md` highlighted that the YAML validation stage in `tests/verify_build_profile.sh` is currently skipped in CI because the `python-yaml` dependency is not installed in the runner environment. This allows malformed GitHub Actions workflow YAML files to pass CI silently, potentially breaking the pipeline on subsequent runs if a syntax error slips through to the `main` branch.
2. **Repository Consistency (Low Risk):** Minor, non-blocking items from the audit (e.g., adding structural comments to `packages.x86_64`) remain but do not threaten build integrity.

## Mitigations
- Addressing the CI blind spot by adding `python-yaml` to the `pacman` installation command in the `test` job of `.github/workflows/build-iso.yml`. This closes the validation gap.
- Future sprints can address minor organizational cleanup in package manifests.

## Priority
Address the medium-priority CI validation issue (adding PyYAML to the test runner) from the `AUDIT_ACTION_PLAN.md` while enforcing strict constraints against modifying the core verification script logic itself.