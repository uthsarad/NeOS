# Strategic Directive

## Phase 1: Product Alignment Check
**Alignment Goal:** NeOS strives to be a curated, predictable, and reliable KDE Plasma experience built on an Arch Linux foundation. Our target audience expects a stable OS that handles updates safely and intelligently.
**Current Status:** We are building toward this goal by focusing on reliable updates and a robust snapshot-based rollback system.
**Leverage:** The highest leverage problem at this exact moment is ensuring that our core system services—specifically the automated update and snapshot scripts—do not fail silently when underlying dependencies are altered.

## Phase 2: Technical Posture Review
**System Stability:** The underlying build and CI processes are becoming more stable (e.g., `pacman.conf` and ISO size validations have been addressed). However, the installed runtime system has a fragility: services lack rigorous dependency validation.
**Tech Debt:** We risk accumulating operational tech debt if our core scripts (e.g., `neos-autoupdate.sh`) execute without confirming that necessary prerequisites (like `snapper` or a Btrfs root) are actually available, leading to silent data loss or confusing failures.
**Overbuilding Check:** We are not overbuilding; adding basic defensive checks is a minimal, essential step for a production-ready OS.

## Phase 3: Priority Selection
**Selected Priority:** Stabilization / hardening.
**Focus:** Specifically, we must address Issue #4 from `DEEP_AUDIT.md`: "No Dependency Validation for Core Services." We need to enforce dependency checks for `snapper` and Btrfs detection in the `neos-autoupdate.sh` script to prevent silent runtime failures.

## Phase 4: Controlled Scope Definition
**Target File:** `airootfs/usr/local/bin/neos-autoupdate.sh`
**Maximum Allowed Surface Area:** Only the top of `neos-autoupdate.sh` (after the `set -euo pipefail` block and security checks).
**Constraints Architect Must Obey:**
- **Single Coherent Deliverable:** Only implement dependency validation in `neos-autoupdate.sh`. Do not touch any other scripts or services.
- **Graceful Exit:** If dependencies are missing, the script must log a clear error and exit gracefully (exit code 0) so it does not cause the associated systemd unit to fail.
- **Out of Scope:**
  - The `pacman.conf` build-blocking issue (already resolved).
  - The missing ISO Size Validation in CI/CD (already resolved).
  - The incomplete Architecture Support issue (explicitly out of scope for this run).
  - Adding systemd sandboxing (out of scope).

## Phase 5: Delegation Strategy
- **Architect (Implementation Lead):** Implement the dependency checks for `snapper` and a Btrfs root filesystem in `airootfs/usr/local/bin/neos-autoupdate.sh` per the constraints.
- **Bolt (Performance):** Ensure the dependency check for `snapper` uses native bash hashing (e.g., `hash snapper 2>/dev/null`) rather than subshells (like `$(command -v snapper)`) to eliminate unnecessary fork/clone syscall overhead.
- **Palette (UX & Accessibility):** Ensure that the error messages logged when dependencies are missing are clear, actionable, and formatted well for system administrators reading the logs.
- **Sentinel (Security):** Verify that the dependency validation logic relies on safe path resolution and does not introduce TOCTOU (Time-Of-Check to Time-Of-Use) or PATH hijacking vulnerabilities.
