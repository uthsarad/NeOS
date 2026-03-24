# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, rolling-release Arch Linux distribution targeting a predictable, Windows-familiar KDE Plasma experience through snapshot-based updates and QA validation (Phase 0-2).
- **Are we building toward that?** Yes. We are ensuring the core update and snapshot mechanisms, critical for a rolling-release model's reliability, function without catastrophic silent failures.
- **Are we solving the highest leverage problem?** Yes. The `DEEP_AUDIT.md` highlighted critical and high issues. Previous passes resolved the build-blocking `pacman.conf` and CI ISO size limitations. The next highest leverage issue is the risk of silent runtime failures in core services due to missing dependency validation, specifically `snapper` in the `neos-autoupdate.sh` script.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The build pipeline is now stable, but runtime operations face risks. Specifically, `airootfs/usr/local/bin/neos-autoupdate.sh` relies on `snapper` for system snapshots during updates, but fails to verify its existence before execution.
- **Is tech debt increasing?** The lack of dependency checking is a technical debt that risks silent data loss if an end-user removes `snapper` or if it fails to install.
- **Are we overbuilding?** No. Adding a simple, graceful exit check for a critical dependency is a minimal, defensive hardening measure, not a new feature.

## PHASE 3 — Priority Selection
**Selected Priority:** Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
- **Maximum allowed surface area:** The Architect must strictly address the missing `snapper` dependency validation in `neos-autoupdate.sh` as identified in the `DEEP_AUDIT.md`. No new features, UI adjustments, or architecture changes are permitted.
- **Constraints Architect must obey:**
  - The script must check for `snapper` before proceeding with update and snapshot operations.
  - If `snapper` is missing, the script must log the error and exit gracefully with code `0` to prevent failing the systemd timer/unit while avoiding silent data loss.
  - Out-of-scope issues from past audit reports (like the `pacman.conf` build blocker, ISO size validation, systemd sandboxing, Rust profile audit path traversal, TOCTOU in autoupdate, and the sudoers vulnerability) have already been resolved in the current codebase state and must not be touched or re-implemented.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements the `snapper` dependency check in `neos-autoupdate.sh` with a graceful exit.
- **Bolt optimizes:** Ensures the dependency check avoids unnecessary external subprocess overhead where possible, relying on built-in bash commands (like `command -v`).
- **Palette enhances:** Ensures any logged messages regarding the missing dependency are clear and actionable for system administrators reviewing the logs.
- **Sentinel audits:** Verifies that the check does not introduce race conditions or bypass existing security locking mechanisms.