# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, rolling-release Arch Linux distribution targeting a predictable, Windows-familiar KDE Plasma experience through snapshot-based updates and QA validation (Phase 0-2).
- **Are we building toward that?** Yes. We are focusing on ensuring the core update and snapshot mechanisms function robustly without catastrophic silent failures, which is critical for a rolling-release model's reliability.
- **Are we solving the highest leverage problem?** Yes. `DEEP_AUDIT.md` highlighted the risk of silent runtime failures in core services due to missing dependency validation, specifically `snapper` in the `neos-autoupdate.sh` script.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The build pipeline is stable, but runtime operations face risks. `airootfs/usr/local/bin/neos-autoupdate.sh` relies on `snapper` for system snapshots during updates, but fails to verify its existence before execution.
- **Is tech debt increasing?** The lack of dependency checking is technical debt that risks silent data loss if `snapper` is removed or fails to install.
- **Are we overbuilding?** No. Adding a simple, graceful exit check for a critical dependency is a minimal, defensive hardening measure, not a new feature.

## PHASE 3 — Priority Selection
- **Selected Priority:** Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
- **Maximum allowed surface area:** The Implementation Lead (Architect) must strictly address the missing `snapper` dependency validation in `neos-autoupdate.sh` as identified in the `DEEP_AUDIT.md`. No new features, UI adjustments, or architecture changes are permitted.
- **Constraints Architect must obey:**
  - The script must check for the `snapper` command before proceeding with update and snapshot operations.
  - If `snapper` is missing, the script must log a clear warning and exit gracefully (exit code 0) to prevent the systemd unit from entering a failed state, while ensuring no update occurs without snapshot protection.
  - Do NOT alter other functional logic in the script or repository.
  - Out-of-scope issues from past audit reports (like the pacman.conf build blocker, ISO size validation, systemd sandboxing, Rust profile audit path traversal, TOCTOU in autoupdate, and the sudoers vulnerability) have already been resolved in the current codebase state and must not be touched or re-implemented.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements the `snapper` dependency check in `neos-autoupdate.sh` with a graceful exit.
- **Bolt optimizes:** Ensures the dependency validation for `snapper` relies on native or lightweight bash capabilities (e.g., `command -v`) rather than heavier external subprocesses to eliminate fork/exec overhead.
- **Palette enhances:** Ensures the error message logged when `snapper` is missing is clear, informative, and provides actionable context for an administrator reviewing the system logs.
- **Sentinel audits:** Verifies that the early exit upon missing `snapper` does not bypass the existing flock-based locking mechanisms, leaving the lock file in an inconsistent state, and does not introduce TOCTOU race conditions.
