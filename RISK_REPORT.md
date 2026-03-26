# RISK & PRIORITY REPORT

## System Drift and Product Goals
The system is largely on track toward the product goals of providing a predictable, Windows-familiar KDE Plasma experience through a snapshot-based rolling-release model. Recent efforts to stabilize the build process and correct configuration issues (like the ISO size limitations, build-blocking `pacman.conf`, and `snapper` dependency checks) demonstrate strong alignment. However, there are lingering observability risks in the custom infrastructure scripts that could hinder maintainability and issue resolution.

## Identified Risk Areas

### 1. Maintainability & Observability
- **Silent Script Failures:** Core infrastructure scripts like `neos-installer-partition.sh` and `neos-liveuser-setup` operate with `set -euo pipefail`. While this correctly halts execution on error, the failure is entirely silent. There is no trap to log the error to the system journal or standard error output, making it extremely difficult to diagnose setup or partition failures post-mortem.

### 2. Security & Runtime Stability
- **Unlogged Escalation Events:** If scripts running as root (like the liveuser setup) fail unexpectedly, the lack of an audit trail means administrators cannot distinguish between a benign misconfiguration and a potential security interruption.

### 3. Complexity Creep
- **Overbuilding Mitigations:** There is a risk that attempting to improve logging could lead to over-engineering (e.g., introducing complex custom logging functions or external dependencies). The mitigation must remain strictly a minimal, built-in bash `trap` combined with standard `logger`.

## Prioritized Action
1. **Harden Custom Scripts:** Implement a lightweight `trap` mechanism in `neos-installer-partition.sh` and `neos-liveuser-setup` that pipes fatal error line numbers and script contexts to the system journal via `logger` before exiting, drastically improving observability without adding external dependencies.
