# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- What is the product trying to become?
NeOS aims to be a curated Arch-based desktop OS targeting predictable behavior, delivering a Windows-familiar KDE Plasma experience.
- Are we building toward that?
Yes, core foundations are verified, but the `docs/AUDIT_ACTION_PLAN.md` outlines further stabilization is required.
- Are we solving the highest leverage problem?
Yes. Based on recent audits, ensuring long-term maintenance and addressing silent failures through dependency validation is the highest leverage next step.

## PHASE 2 — Technical Posture Review
- Is the system stable?
Yes, the core verification tests are passing, but missing dependency validations present silent failure risks.
- Is tech debt increasing?
No.
- Are we overbuilding?
No.

## PHASE 3 — Priority Selection
- Priority: Stabilization / hardening
- Focus: "Add Dependency Validation" as identified in `docs/AUDIT_ACTION_PLAN.md` (High Priority).

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
- Maximum allowed surface area:
  - Add explicit command validations for `snapper` and Btrfs filesystem checks to `neos-autoupdate.sh`.
- Constraints Architect must obey:
  - Limit modifications strictly to `airootfs/usr/local/bin/neos-autoupdate.sh`.
  - Ensure the script fails safely if dependencies are missing.

## PHASE 5 — Delegation Strategy
- Architect: Implement the dependency validation in `neos-autoupdate.sh`.
- Bolt: Monitor subshell overhead in the new validations.
- Palette: Ensure error messages sent to the logger are clear and actionable.
- Sentinel: Verify the checks do not introduce command injection risks.
