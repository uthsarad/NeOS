# RISK & PRIORITY REPORT

## System Drift and Product Goals
The system is largely on track toward the product goals of providing a predictable, Windows-familiar KDE Plasma experience through a snapshot-based rolling-release model. Recent efforts to stabilize the build process and correct configuration issues demonstrate strong alignment. However, there are lingering risks related to external dependencies that could hinder maintainability and user experience.

## Identified Risk Areas

### 1. Maintainability & Observability
- **Unvalidated External Dependencies:** Core infrastructure relies on a mirrorlist (`airootfs/etc/pacman.d/neos-mirrorlist`) containing over 1000 entries. There is currently no CI verification that the primary (top) mirrors are actually reachable. If these primary worldwide mirrors go offline or become unreachable, CI builds could silently fail or become exceptionally slow as they fallback. Furthermore, end users would experience a broken or sluggish installation and update process.

### 2. Complexity Creep
- **Overbuilding Mitigations:** There is a risk that attempting to validate mirrors could lead to over-engineering (e.g., pinging all 1000+ mirrors or introducing complex parallel testing tools). The mitigation must remain strictly a minimal bash test checking only the top few entries using standard tools like `curl`.

## Prioritized Action
1. **Harden Build Dependencies:** Implement a lightweight test script (`tests/verify_mirrorlist_connectivity.sh`) that reads the mirrorlist and performs a fast connectivity check on the top 5 servers, ensuring fundamental network requirements are met before allowing the release pipeline to proceed.
