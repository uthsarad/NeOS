# STRATEGIC DIRECTIVE: NeOS

## PHASE 1 — Product Alignment Check
- **Product Goal:** NeOS aims to be a curated Arch Linux distribution providing Windows-level usability, targeted at Windows switchers, stability seekers, and power users.
- **Current State Alignment:** The recent audit (DEEP_AUDIT.md) indicates strong baseline engineering hygiene. The ISO build fix (ISO_BUILD_FIX.md) and numerous verification test passes confirm solid foundational stability (Phase 0/1/2).
- **Highest Leverage Problem:** While core systems and build pipelines are stable, all specialist tasks (Bolt, Palette, Sentinel) are completed or purely tracking-based. There are no critical unhandled issues or active feature developments required at this exact moment according to the tracker and docs. A strategic pause is warranted to ensure no feature creep or unnecessary disruption occurs.

## PHASE 2 — Technical Posture Review
- **System Stability:** High. The verification test suite demonstrates 22/24 passes, with 2 environment-dependent skips/failures. The ISO build is verified fixed.
- **Tech Debt:** Low. Hardening is in place, pacman profiles are optimized, and cleanup hooks are tested.
- **Overbuilding Risk:** High if we proceed with unprompted feature work.

## PHASE 3 — Priority Selection
- **Selection:** No-build day (strategic pause)

## PHASE 4 — Controlled Scope Definition
- **Exact files impacted:** `STRATEGIC_DIRECTIVE.md`, `ARCHITECT_SCOPE.json`, `SPECIALIST_GUIDANCE.json`, `RISK_REPORT.md`.
- **Maximum allowed surface area:** Governance and strategic reporting files only.
- **Constraints Architect must obey:** Execute a zero-modification scenario for production source code. Do not implement new features, do not alter configuration. Follow strict instructions for a strategic pause.

## PHASE 5 — Delegation Strategy
- **Architect:** Consume this directive. Ensure working tree is clean, run tests, and use the `done` tool directly. Do not implement code changes. Do not modify administrative tracking logs (e.g., ARCHITECT_REPORT.md).
- **Bolt:** No tasks.
- **Palette:** No tasks.
- **Sentinel:** No tasks.
