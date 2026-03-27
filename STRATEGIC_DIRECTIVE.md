# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, rolling-release Arch Linux distribution targeting a predictable, Windows-familiar KDE Plasma experience through snapshot-based updates and QA validation (Phase 0-2).
- **Are we building toward that?** Yes. We are focusing on ensuring the reliability and predictability of core infrastructure.
- **Are we solving the highest leverage problem?** Yes. The `DEEP_AUDIT.md` highlighted the risk of "No Validation of Mirrorlist Connectivity". The mirrorlist contains over 1000 entries, but there is no CI verification that the primary mirrors are actually reachable. This risks silent or slow build failures in CI and broken download experiences for end users.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The build pipeline is stable and core validation tests exist, but external dependencies (mirrors) represent a weak link.
- **Is tech debt increasing?** Deploying an untested, unvalidated mirrorlist creates operational debt.
- **Are we overbuilding?** No. A simple bash script to test the top worldwide mirrors using native tools (like `curl` or `wget`) is a minimal, high-leverage improvement.

## PHASE 3 — Priority Selection
- **Selected Priority:** Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `tests/verify_mirrorlist_connectivity.sh` (new file)
- **Maximum allowed surface area:** The Implementation Lead (Architect) must strictly create a single new test script to validate mirrorlist connectivity. No new features, logic changes, or UI adjustments are permitted.
- **Constraints Architect must obey:**
  - The script must parse `airootfs/etc/pacman.d/neos-mirrorlist` and extract at least the top 5 `Server = ` entries.
  - The script must use `curl` or `wget` to verify that these top mirrors are reachable (e.g., checking the root URL or fetching a small file/header).
  - The script must be marked executable (`chmod +x`).
  - Do NOT alter other functional logic in the scripts or repository.
  - Out-of-scope issues from past audit reports (like the pacman.conf build blocker, ISO size validation, systemd sandboxing, Rust profile audit path traversal, TOCTOU in autoupdate, sudoers vulnerability, and incomplete error handling) have already been resolved in the current codebase state and must not be touched or re-implemented.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements `tests/verify_mirrorlist_connectivity.sh` to validate the top mirrors.
- **Bolt optimizes:** Ensures the connectivity check avoids excessive timeouts or fork/exec overhead (e.g., by limiting the connection timeout of the `curl` or `wget` command).
- **Palette enhances:** Ensures the format of the test output is clear, readable, and includes actionable '💡 How to fix:' instructions if mirrors are unreachable.
- **Sentinel audits:** Verifies that the parsing of the mirrorlist does not introduce command injection risks (e.g., safely reading the file line-by-line without executing its contents).
