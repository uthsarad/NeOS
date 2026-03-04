# RISK & PRIORITY REPORT 🛡️

**Date:** 2026-03-03
**Author:** Maestro (Strategic Engineering Director)

## 1. System Health & Drift Assessment
- **Product Drift:** Low. We are focusing entirely on infrastructure stability rather than chasing new features.
- **Tech Debt:** High (specifically CI/CD). The build pipeline lacks pre-build testing, relying instead on manual discovery of configuration issues after full builds.
- **System Stability:** Stable (Runtime) / **DEGRADED (Build Time)**. `pacman.conf` misconfigurations are actively blocking builds.

## 2. Identified Risks

### High Risk: Broken CI Validation / Uncaught Errors
- **Description:** The root `pacman.conf` uses `DatabaseRequired`, which breaks ISO builds entirely because of unsigned upstream databases (e.g., `alci_repo`). Simultaneously, the CI pipeline lacks pre-build test validation and does not cleanly separate tests that require an ISO vs those that test configuration.
- **Impact:** Failed or broken deployments that block the entire team from merging functional code.
- **Mitigation:** Add a `test` job to run `.sh` validations *before* the build step, and adjust `pacman.conf` globally to `DatabaseOptional` while maintaining `DatabaseRequired` specifically for official repos.

### Medium Risk: ISO Size Limit Violations
- **Description:** While size limits are checked *after* the ISO builds, failing them wastes considerable compute time and prevents GitHub release generation.
- **Impact:** Bloated releases and CI job failures.
- **Mitigation:** Implement fast metadata checks (like `stat -c%s`) to proactively fail the build if the 2 GiB limit is exceeded and ensure these checks use native bash features to reduce overhead.

### Monitored Risk: Workflow Permissions
- **Description:** Automatically creating tags/releases from a workflow demands careful management of `workflows: write` and `contents: write` permissions.
- **Mitigation:** Ensure that any `approve-and-merge` logic in related workflows includes the correct permissions to prevent GraphQL API rejections without granting excessive access.

## 3. Immediate Priorities
1. **Fix `pacman.conf` Build Blocker:** Revert global signature requirement to `DatabaseOptional`.
2. **Implement CI Pre-validation:** Add the `test` job to `build-iso.yml` to run the `verify_*.sh` suite early.
3. **Strategic Pause:** Strict moratorium on any UI or functional changes until the build pipeline correctly tests our artifacts.
