# Strategic Directive

## PHASE 1: Product Alignment Check
- What is the product trying to become? NeOS is a curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, currently prioritizing long-term maintainability over feature creep.
- Are we solving the highest leverage problem? Yes, ensuring system stability.

## PHASE 2: Technical Posture Review
- Is the system stable? Yes, the system is fundamentally stable, verified by testing.
- Is tech debt increasing? No.
- Are we overbuilding? No.

## PHASE 3: Priority Selection
- No-build day (strategic pause)

## PHASE 4: Controlled Scope Definition
- Exact files likely impacted: None (zero-modification scenario).
- Maximum allowed surface area: None.
- Constraints Architect must obey: Do not write production code. Do not perform administrative modifications on tracker files. Ensure a clean working tree.

## PHASE 5: Delegation Strategy
- Architect: Restore clean working tree, run all tests, and call `done`.
- Bolt: Review only, no file modifications.
- Palette: Review only, no file modifications.
- Sentinel: Review only, no file modifications.
