# Strategic Directive

## PHASE 1 - Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a stable, curated Arch Linux distribution delivering Windows-level usability.
- **Are we building toward that?** We are making progress, but several foundational open items remain from recent audits that must be resolved to ensure complete system integrity.
- **Are we solving the highest leverage problem?** Yes. Addressing the remaining issues documented in `reports/v2026.09.22/UPDATES_NEEDED.md` (e.g., UFW rules, repo trust testing) ensures stability and accurate representation of the system architecture before introducing new features.

## PHASE 2 - Technical Posture Review
- **Is the system stable?** Yes, verification tests pass, but the remaining open issues represent unaddressed technical debt.
- **Is tech debt increasing?** Yes, slightly, due to the lingering unresolved items from the 2026.09.22 audit.
- **Are we overbuilding?** No.

## PHASE 3 - Priority Selection
- **Selection:** Stabilization / hardening
- **Reasoning:** We must close the remaining open items from the previous audit (UFW rules, repo trust testing, unused bootstrap file, version sync) to establish a clean baseline for future work.

## PHASE 4 - Controlled Scope Definition
- **Exact files likely impacted:** `profile/airootfs/etc/ufw/ufw.conf`, `profile/bootstrap_packages.x86_64`, `CLAUDE.md`.
- **Maximum allowed surface area:** UFW rule configuration, test additions for repo trust, documentation cleanup for unused files, and fixing CLAUDE.md references.
- **Constraints Architect must obey:** Do not introduce new features. Strictly adhere to the project's no-emoji rule. Address only the explicit unaddressed items listed in the `reports/v2026.09.22/UPDATES_NEEDED.md` report (Items M6, M7, M9, M10, O4, and 2.2).

## PHASE 5 - Delegation Strategy
- **Architect:** Address the unresolved audit items: UFW rule configuration (Item M6), unused `bootstrap_packages.x86_64` documentation (Item M9), version synchronization (Item M10), unattended Calamares install testing (Item O4), and fix the `CLAUDE.md` file references (Item 2.2).
- **Bolt:** Strategic pause. Focus on system stability. No performance optimizations required.
- **Palette:** Strategic pause. No UX/accessibility tasks for this cycle.
- **Sentinel:** Audit the updated UFW rules and installed-system repo trust tests (Item M7).
