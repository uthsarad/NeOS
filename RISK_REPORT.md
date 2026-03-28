# RISK & PRIORITY REPORT

## System Drift and Product Goals
The system is largely on track toward the product goals of providing a predictable, Windows-familiar KDE Plasma experience through a snapshot-based rolling-release model. Recent efforts to stabilize the build process (`pacman.conf` DatabaseRequired issue) and correct configuration issues demonstrate strong alignment. However, there are lingering risks related to deployment operations that could hinder maintainability and user accessibility.

## Identified Risk Areas

### 1. Maintainability & Operations
- **Missing ISO Size Validation in CI/CD (High Priority):** As identified in the `DEEP_AUDIT.md`, the CI pipeline lacks enforcement of GitHub Releases' hard 2 GiB per-asset limit. Currently, if an ISO exceeds 2 GiB (e.g., due to an unoptimized package addition), the build succeeds but the release publishing step fails silently. This prevents users from downloading the distribution and creates operational confusion.
- **Incomplete Architecture Support:** Documentation discrepancies exist between x86_64, i686, and aarch64 features, risking user confusion.
- **No Dependency Validation for Core Services:** Critical services like `neos-autoupdate.sh` lack upfront checks for dependencies like `snapper` or Btrfs.

### 2. Complexity Creep
- **Overbuilding Mitigations:** There is a risk that attempting to validate the ISO size could lead to complex CI artifact manipulation. The mitigation must remain strictly a minimal bash check within the existing workflow using native tools (e.g., `stat`).

## Prioritized Action
1. **Harden Deployment Pipeline:** Implement an explicit ISO size validation step in `.github/workflows/build-iso.yml` that strictly blocks release creation if the final ISO exceeds the 2 GiB limit, failing the workflow with an actionable error.
