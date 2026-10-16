# Strategic Directive
Generated at 2026-10-16T23:33:30Z

## PHASE 1 - Product Alignment Check
- What is the product trying to become? A Windows-familiar, highly stable rolling-release OS based on Arch Linux.
- Are we building toward that? Yes, but current repo metadata points to a fork and documentation contains drift, confusing users.
- Are we solving the highest leverage problem? Yes, fixing support URLs and docs prevents user frustration and reduces tech debt.

## PHASE 2 - Technical Posture Review
- Is the system stable? Yes, the OS itself is stable as per recent audits.
- Is tech debt increasing? Documentation drift and broken URLs are a form of tech debt that needs immediate resolution.
- Are we overbuilding? No, we are stabilizing.

## PHASE 3 - Priority Selection
- Priority: Stabilization / hardening.
- Justification: Before releasing Beta, the shipped OS *must* point to the correct upstream repository for issues and support, and the documentation must match reality.

## PHASE 4 - Controlled Scope Definition
- Exact files likely impacted: `docs/README.md`, `CLAUDE.md`, `profile/airootfs/etc/os-release`, `profile/airootfs/etc/calamares/branding/neos/branding.desc`, `profile/profiledef.sh`, `docs/user-guide/HANDBOOK.md`, `docs/architecture/BOOTSTRAP.md`, `docs/TROUBLESHOOTING.md`.
- Maximum allowed surface area: Only update URLs, documentation paths, and markdown content. No code or script logic changes.
- Constraints Architect must obey: Adhere strictly to the requested documentation fixes in `reports/v2026.09.22/UPDATES_NEEDED.md` sections 3 and 4. Do not invent new features.

## PHASE 5 - Delegation Strategy
- Architect: Fix the repo URLs and resolve the documentation drift as specified.
- Bolt: Stand down (no performance work in this cycle).
- Palette: Stand down (no UX work in this cycle).
- Sentinel: Stand down (no security work in this cycle).
