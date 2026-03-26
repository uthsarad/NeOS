# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, rolling-release Arch Linux distribution targeting a predictable, Windows-familiar KDE Plasma experience through snapshot-based updates and QA validation (Phase 0-2).
- **Are we building toward that?** Yes. We are focusing on ensuring the reliability and observability of core infrastructure scripts, which is critical for system administration and user trust in a curated OS.
- **Are we solving the highest leverage problem?** Yes. The `DEEP_AUDIT.md` highlighted the risk of "Incomplete Error Handling in Custom Scripts". Custom scripts like `neos-installer-partition.sh` and `neos-liveuser-setup` currently lack centralized error logging, meaning if they fail silently, debugging becomes exceedingly difficult for both developers and users, violating the "predictable behavior" mandate.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The build pipeline is stable, but runtime scripts are fragile due to poor observability. While they use `set -euo pipefail`, any failure simply drops execution without leaving a trail in the system journal.
- **Is tech debt increasing?** Yes, deploying custom scripts without structured logging creates operational debt.
- **Are we overbuilding?** No. Adding a simple `trap` for `logger` is a native, minimal enhancement that provides high value without new dependencies or complex logic.

## PHASE 3 — Priority Selection
- **Selected Priority:** Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
  - `airootfs/usr/local/bin/neos-liveuser-setup`
- **Maximum allowed surface area:** The Implementation Lead (Architect) must strictly address the missing error logging in the two specified scripts. No new features, logic changes, or UI adjustments are permitted.
- **Constraints Architect must obey:**
  - The script must use `trap` with the `logger` utility to send an ERROR message to the system journal if the script fails unexpectedly.
  - The error message should include the script name and the line number of the failure (e.g., `trap 'logger -t neos-$(basename "$0") "ERROR: Script failed at line $LINENO"' ERR`).
  - Do NOT alter other functional logic in the scripts or repository.
  - Out-of-scope issues from past audit reports (like the pacman.conf build blocker, ISO size validation, systemd sandboxing, Rust profile audit path traversal, TOCTOU in autoupdate, and the sudoers vulnerability) have already been resolved in the current codebase state and must not be touched or re-implemented.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements the `trap` error logging in the specified custom bash scripts.
- **Bolt optimizes:** Ensures the logging mechanism avoids excessive subshell overhead where possible, relying on native variables like `$LINENO`.
- **Palette enhances:** Ensures the format of the logged error message is clear, searchable in the journal, and accurately represents a critical script failure.
- **Sentinel audits:** Verifies that the `trap` command does not inadvertently mask exit codes or introduce arbitrary command execution risks if `$0` is manipulated.
