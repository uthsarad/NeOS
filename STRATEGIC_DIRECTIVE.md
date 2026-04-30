# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- What is the product trying to become? NeOS is becoming a curated rolling-release, Arch-based desktop OS with predictable behavior, Windows-familiar UX, and automated hardware optimization.
- Are we building toward that? Yes, the baseline ISO build, hardware detection, and installer scripts are functional.
- Are we solving the highest leverage problem? The core foundation is stable. The highest leverage problem now is refining the recent feature implementations to ensure performance, clear UX during installation, and security without over-engineering.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the automated build pipeline and basic partitioning are operational.
- Is tech debt increasing? Minor UX/performance debt was incurred to achieve functional baseline (e.g., multiple subprocess calls in hardware detection, missing progress UI in partitioning).
- Are we overbuilding? No. We have focused on minimal working components.

## PHASE 3 — Priority Selection
- Refinement of recent feature

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `profile/airootfs/usr/local/bin/neos-driver-manager`
  - `profile/airootfs/usr/local/bin/neos-installer-partition.sh`
  - `profile/airootfs/etc/calamares/branding/neos/branding.desc`
- Maximum allowed surface area: 3 files
- Constraints Architect must obey:
  - Optimize the hardware detection without breaking existing functionality.
  - Apply NeOS blue (`#0078D4`) to Calamares branding.
  - Implement simple text-based progress bars using standard ASCII characters (`#`, `.`).
  - Do not introduce new features outside this scope. Ensure tests pass.

## PHASE 5 — Delegation Strategy
- Architect builds: Implement the refinement of driver manager and installer partition UX.
- Bolt optimizes: Measure and validate the lspci caching logic in the driver manager.
- Palette enhances: Ensure text-based progress indicators and terminal formatting follow UX standards.
- Sentinel audits: Verify that any changes to script execution or log variables do not introduce injection vectors.
