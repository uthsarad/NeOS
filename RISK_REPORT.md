# Risk & Priority Report

## Date: 2026-02-17

### 1. Current Risk Posture

The deep audit (`docs/DEEP_AUDIT.md`) and action plan (`docs/AUDIT_ACTION_PLAN.md`) have identified several risks. The most critical release-blocking issues (pacman config and ISO size limits) have been addressed previously. The remaining high-priority risks we are targeting in this sprint are:

-   **Silent Autoupdate Failures**: The `neos-autoupdate.sh` script currently lacks sufficient dependency validation (specifically for `snapper`). If `snapper` is removed or missing, the script will silently fail to create system snapshots, putting users at risk of data loss or an inability to rollback if an update breaks the system.
-   **User Confusion regarding Architecture Limitations**: The documentation (`README.md` and `docs/HANDBOOK.md`) currently lists `i686` and `aarch64` as experimental, but fails to explicitly state that they lack the Calamares GUI installer, snapshots, and ZRAM support. This can lead to frustration and wasted time for community members attempting to test these platforms.

### 2. Mitigation Strategy

The work delegated to the Architect in this sprint directly addresses these risks:

-   **Adding Dependency Validation**: By explicitly checking for `snapper` in `neos-autoupdate.sh` and exiting gracefully with a clear log message, we eliminate the silent failure mode. If the dependency is missing, the system will not proceed with an update that cannot be safely rolled back.
-   **Clarifying Documentation**: By updating `README.md` and `docs/HANDBOOK.md` to explicitly list the missing features for `i686` and `aarch64`, we set clear expectations for the community.

### 3. Execution Risks

-   **Overbuilding**: There is a risk that the Architect may attempt to refactor the entire `neos-autoupdate.sh` script or introduce complex new features. To mitigate this, the `ARCHITECT_SCOPE.json` explicitly restricts the scope to the narrowest possible interpretation of adding the missing check.
-   **Performance Overhead**: Adding checks to a script run frequently (like an auto-updater) can introduce overhead. To mitigate this, Bolt is instructed to ensure the checks are efficient and use native bash features.
-   **Security Vulnerabilities**: Bash scripts are prone to command injection. Sentinel is instructed to review the new code for any security implications.

### 4. Long-Term Maintenance

This sprint prioritizes stabilization over new feature development. By implementing these safeguards, we ensure the system behaves predictably in edge cases and that documentation accurately reflects the system's capabilities.