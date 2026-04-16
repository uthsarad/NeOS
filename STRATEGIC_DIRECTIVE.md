# Maestro Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a predictable, low-breakage, Windows-familiar Arch Linux desktop distribution that curates the user experience and update cycle.
- **Are we building toward that?** Yes. Recent critical fixes to the build pipeline and ISO size limits have stabilized the foundation. Now we must ensure the core design decisions are documented for future maintainability.
- **Are we solving the highest leverage problem?** Yes. The lack of Architecture Decision Records (ADRs) creates a knowledge gap for future contributors and risks deviating from the core brand ethos.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Yes, the core architecture and build pipelines are stable following recent emergency fixes.
- **Is tech debt increasing?** Yes, documentation debt is increasing. The 'why' behind major technical decisions (e.g., using `linux-lts`, Btrfs + snapper, Calamares) is not formally recorded.
- **Are we overbuilding?** No. Formalizing ADRs is a fundamental governance requirement, not an over-engineered feature.

## PHASE 3 — Priority Selection
Select ONE of:
- **Refinement of recent feature**

We will prioritize the refinement of documentation by implementing the Architecture Decision Records (ADRs) recommended in the AUDIT_ACTION_PLAN.md.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `docs/decisions/0001-core-architecture-decisions.md`, `README.md`
- **Maximum allowed surface area:** Creation of the new ADR directory and document, and a link addition to the README. No executable code or build pipelines may be modified.
- **Constraints Architect must obey:** Create a single, comprehensive ADR document consolidating the decisions for `linux-lts`, Btrfs + snapper, Calamares, plasma-meta, and 8 parallel downloads. Ensure the directory `docs/decisions/` is created.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Creates the `docs/decisions/` directory and writes `0001-core-architecture-decisions.md`, linking it in `README.md`.
- **Bolt optimizes:** Monitors the documentation addition to ensure no unnecessary heavy assets (like large architecture diagrams) are included that might bloat the repository.
- **Palette enhances:** Ensures the markdown structure of the new ADR is scannable, accessible, and uses clear heading hierarchies.
- **Sentinel audits:** Verifies no sensitive operational details or credentials are leaked in the newly created documentation.
