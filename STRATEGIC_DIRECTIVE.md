# Strategic Directive

## PHASE 1 — Product Alignment Check
- What is the product trying to become? NeOS aims to be a curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, the focus is on a familiar desktop paradigm, stability, and out-of-the-box usability.
- Are we solving the highest leverage problem? The beta release checklist in docs/AUDIT_ACTION_PLAN.md is complete. The next highest leverage problem is establishing the infrastructure for Phase 2: ISO Build and Branding.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the core system is stable and all beta release requirements have been met.
- Is tech debt increasing? Technical debt is low.
- Are we overbuilding? No, we are proceeding systematically through the roadmap.

## PHASE 3 — Priority Selection
- Selected Priority: Infrastructure improvement (Phase 2 initialization)
- Rationale: The beta release checklist is complete. We must now begin transitioning from Phase 1 (Repository Snapshot Infrastructure) to Phase 2 (ISO Build and Branding), focusing on repository topology and update gates.

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `docs/ROADMAP.md` (Update progress)
  - `ai/tasks/bolt.json`
  - `ai/tasks/palette.json`
  - `ai/tasks/sentinel.json`
- Maximum allowed surface area: Documentation updates and task generation for specialists to begin Phase 2.
- Constraints Architect must obey: Do not implement the repository infrastructure yet. Focus solely on updating task trackers and documentation to reflect the phase transition.

## PHASE 5 — Delegation Strategy
- Architect builds: Update `ai/tasks/*.json` to enqueue Phase 2 tasks for specialists.
- Bolt optimizes: Prepare to evaluate staging pipeline synchronization performance.
- Palette enhances: Prepare to review NeOS-curated repo branding and UX.
- Sentinel audits: Prepare to audit package signing and update gate security.
