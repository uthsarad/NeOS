# Risk Report: Build System & Documentation

**Date:** 2026-02-17
**Assessment:** Moderate Risk

## 1. Build Verification Fragility (High Impact, Medium Likelihood)
The current `tests/verify_build_profile.sh` script has a hidden dependency on the `pyyaml` Python library. This creates a brittle CI/CD pipeline where passing builds may fail purely due to environment differences in the test runner, rather than actual code defects.
**Mitigation:** Modify the verification script to degrade gracefully (skip check with warning) if dependencies are missing, or explicitly install dependencies in a virtual environment.

## 2. Documentation Drift (Medium Impact, High Likelihood)
The project documentation (`README.md`, `HANDBOOK.md`) currently implies broad support or fails to distinguish between the stable x86_64 architecture and experimental ports (i686, aarch64). This risks user confusion and increased support burden.
**Mitigation:** Explicitly document tier levels for supported architectures immediately.

## 3. Dependency Management (Low Impact, Low Likelihood)
The `neos-autoupdate.sh` script relies on `snapper` and `btrfs`. While checks exist, a failure in these dependencies during an update could leave the system in an inconsistent state if the rollback mechanism also fails (e.g., due to disk space).
**Mitigation:** Ensure `neos-autoupdate.sh` checks for sufficient free space before attempting snapshots.

## Recommendation
Prioritize the robustness of `verify_build_profile.sh` to unblock reliable CI feedback loops. Follow with immediate documentation updates to clarify product scope.
