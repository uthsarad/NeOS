# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **Product Vision:** NeOS aims to be a curated, predictable rolling-release Arch-based desktop OS with a Windows-familiar KDE Plasma experience.
- **Current Alignment:** We are aligned. Recent efforts have stabilized the build profile, improved CI robustness, and addressed initial security/operational debt.
- **Highest Leverage Problem:** The deep audit (DEEP_AUDIT.md) identified missing user-facing documentation for troubleshooting. As we approach beta, users and contributors need a structured guide for common issues (build failures, boot issues, snapshot rollbacks).

## PHASE 2 — Technical Posture Review
- **System Stability:** High. Verification scripts confirm repository integrity and basic security defaults.
- **Tech Debt:** Decreasing. We have recently fixed documentation URLs and initialized a formal changelog.
- **Overbuilding Risk:** Low, provided we stick strictly to documentation enhancements without altering underlying script logic.

## PHASE 3 — Priority Selection
**Selected Priority:** Stabilization / hardening (specifically, operational hardening via Documentation).

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `docs/TROUBLESHOOTING.md` (New file)
  - `README.md` (Link update)
  - `docs/HANDBOOK.md` (Link update)
- **Maximum allowed surface area:** Creation of one markdown file and updating documentation links.
- **Constraints Architect must obey:**
  - Do NOT modify any executable code, configuration files, or CI workflows.
  - The troubleshooting guide must address the specific topics identified in the audit action plan (Build failures, Boot issues, Network problems, Snapshot rollback, Driver issues).
  - Limit the scope to exactly one coherent deliverable: the troubleshooting guide and its references.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement the `docs/TROUBLESHOOTING.md` file and add links to it from `README.md` and `docs/HANDBOOK.md`.
- **Bolt:** Ensure the troubleshooting guide does not introduce unnecessary repository bloat (e.g., large embedded media).
- **Palette:** Verify the Markdown structure, headings, and readability of the troubleshooting guide.
- **Sentinel:** Audit the troubleshooting guide to ensure no insecure workarounds or dangerous commands are recommended to users.
