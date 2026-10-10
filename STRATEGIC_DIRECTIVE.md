# Strategic Directive

## PHASE 1 - Product Alignment Check
- What is the product trying to become? A curated Arch Linux distribution delivering Windows-level usability with Linux-level power, targeting Windows switchers, stability seekers, and power users.
- Are we building toward that? Yes, but recent additions like the Omarchy runtime have introduced dormant bloat. We need to maintain stability and a clean UX.
- Are we solving the highest leverage problem? Fixing the documentation drift and removing unresolved open engineering items (as noted in the 2026.09.22 report) is high leverage to align the repo reality with the shipped product.

## PHASE 2 - Technical Posture Review
- Is the system stable? Yes, but we have technical debt in documentation and unverified CI gates (e.g. O3/H3, H4 from the 2026.09.18 audit).
- Is tech debt increasing? Yes, documentation drift is apparent (e.g., HANDBOOK paths, BOOTSTRAP paths, Calamares duplicate module fixed but needs verification of no reintroduction).
- Are we overbuilding? The Omarchy runtime (removed in 2026.10.03 polish plan) was an example of overbuilding.

## PHASE 3 - Priority Selection
- Priority selected: **Refinement of recent feature / Stabilization**. Specifically, addressing the outstanding documentation drift and engineering items from the 2026.09.22 `UPDATES_NEEDED.md` report.

## PHASE 4 - Controlled Scope Definition
- Exact files likely impacted: `docs/user-guide/HANDBOOK.md`, `docs/architecture/BOOTSTRAP.md`, `docs/TROUBLESHOOTING.md`, `docs/README.md`, `CLAUDE.md`.
- Maximum allowed surface area: Documentation updates only. No code or configuration changes.
- Constraints Architect must obey: Only fix paths, links, and text claims as explicitly identified in section 4 of `reports/v2026.09.22/UPDATES_NEEDED.md`.

## PHASE 5 - Delegation Strategy
- What Architect builds: Fix the documentation drift in HANDBOOK, BOOTSTRAP, TROUBLESHOOTING, and README.md.
- What Bolt optimizes: No performance tasks this cycle.
- What Palette enhances: No UX enhancements this cycle.
- What Sentinel audits: No security audits this cycle.
