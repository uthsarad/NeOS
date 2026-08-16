# Strategic Directive

## PHASE 1 — Product Alignment Check
The product aims to provide a stable, zero-learning-curve transition for Windows migrants, maintaining rock-solid reliability before introducing new capabilities. Recent audit reports (Deep Audit v2026.07.03) reveal high-priority technical debt and latent security regressions (e.g., dormant kiosk installer paths and weakened CI gates). Ignoring these to build new features would drift from our core goal of a polished, predictable end-user experience.

## PHASE 2 — Technical Posture Review
The system is currently unstable due to significant accumulating technical debt. High-severity issues identified in the Deep Audit remain unaddressed, blocking continuous integration and increasing long-term maintenance costs. The specialists currently have pending Phase 4 validation tasks that must be resolved before proceeding.

## PHASE 3 — Priority Selection
**No-build day (strategic pause).** We must stabilize the current state, address critical audit findings, and allow specialist agents to catch up on their validation duties.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** None (Strategic Pause).
- **Maximum allowed surface area:** 0 files.
- **Constraints Architect must obey:** Architect is strictly mandated to implement zero production code. The sole focus is acknowledging the pause.

## PHASE 5 — Delegation Strategy
- **Architect:** Write zero code. Acknowledge the strategic pause and pend new tasks for specialists.
- **Bolt:** Acknowledge the Phase 4 Validation pause in the respective manifest. No new performance audits.
- **Palette:** Acknowledge the Phase 4 Validation pause in the respective manifest. No new UX enhancements.
- **Sentinel:** Acknowledge the Phase 4 Validation pause in the respective manifest. No new security audits.
