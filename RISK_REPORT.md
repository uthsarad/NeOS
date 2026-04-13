# RISK_REPORT

## Current System Risks

### 1. Architecture Parity Confusion
- **Risk Level:** Medium
- **Description:** Users may attempt to install NeOS on i686 or aarch64 architectures expecting the full suite of features (Calamares, Snapper rollbacks, ZRAM), which are currently only supported on x86_64. This can lead to a poor user experience, failed installations, and increased support burden.
- **Mitigation:** Update `README.md` and `docs/HANDBOOK.md` to explicitly document the supported architectures and feature availability per architecture.

### 2. ISO Size Constraints
- **Risk Level:** Low
- **Description:** The ISO build process has a hard limit of 2 GiB for GitHub Releases. The size limit validation is currently correctly implemented and enforces this constraint.
- **Mitigation:** Continuous monitoring. Bolt must ensure new features or assets do not unnecessarily inflate the ISO size.

### 3. Missing ShellCheck CI Checks
- **Risk Level:** Low
- **Description:** The `verify_shellcheck.sh` test currently gracefully degrades if ShellCheck is not installed.
- **Mitigation:** Add ShellCheck installation to the CI workflow in the future to ensure scripts are always validated.

### 4. CI Test Environment Dependencies
- **Risk Level:** Low
- **Description:** Tests like `verify_mirrorlist_connectivity.sh` rely on external network access.
- **Mitigation:** The workflow already limits timeouts gracefully to prevent pipeline hangs.
