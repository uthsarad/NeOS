# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- What is the product trying to become? A predictable, Windows-familiar Arch Linux experience.
- Are we building toward that? Yes, the core architecture is stable and functional.
- Are we solving the highest leverage problem? The highest leverage right now is ensuring stability and resolving minor findings from specialists.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the core installer and boot process are stable.
- Is tech debt increasing? Minor technical debt identified by specialists (UX feedback, performance tweaks, security validation of new CI workflows).
- Are we overbuilding? We need to avoid overbuilding and verify the core functionality before introducing new mechanics.

## PHASE 3 — Priority Selection
- No-build day (strategic pause)

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted: None
- Maximum allowed surface area: 0 files
- Constraints Architect must obey: Do not write or modify production code. Run test suite to verify stability.

## PHASE 5 — Delegation Strategy
- Architect: Stop and execute tests to verify stability.
- Bolt: No action.
- Palette: No action.
- Sentinel: No action.
