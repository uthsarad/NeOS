# STRATEGIC DIRECTIVE: Documentation Alignment & Technical Debt

## Phase 1: Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a stable, curated Arch Linux distribution with Windows-level usability.
- **Are we building toward that?** Yes, by ensuring our contributor and user documentation is accurate. Broken or incorrect repository links undermine trust and create friction for new users or contributors.
- **Are we solving the highest leverage problem?** Resolving documentation technical debt (specifically the incorrect `neos-project/neos` URLs) is a low-effort, high-leverage task that immediately improves onboarding and aligns with the AUDIT_ACTION_PLAN.

## Phase 2: Technical Posture Review
- **Is the system stable?** Yes, recent commits have hardened security in the live environment (`neos-liveuser-setup`).
- **Is tech debt increasing?** The `AUDIT_ACTION_PLAN.md` explicitly lists incorrect URLs in `HANDBOOK.md` and `CONTRIBUTING.md` as an outstanding HIGH priority item.
- **Are we overbuilding?** No. This focuses strictly on resolving existing debt rather than introducing new features.

## Phase 3: Priority Selection
**Selection:** Refinement of recent feature / Technical Debt Reduction.
We will address the "Fix documentation URLs" task from the Deep Audit.

## Phase 4: Controlled Scope Definition
- **Exact files likely impacted:** `docs/HANDBOOK.md`, `CONTRIBUTING.md`, `docs/AUDIT_ACTION_PLAN.md`
- **Maximum allowed surface area:** String replacements for the repository URL and updating the checklist status.
- **Constraints Architect must obey:** Do not modify any source code, CI/CD pipelines, or configuration files. Only perform the URL corrections and mark the checklist item as complete.

## Phase 5: Delegation Strategy
- **Architect:** Perform the URL string replacements (`https://github.com/neos-project/neos` -> `https://github.com/uthsarad/NeOS`) in `HANDBOOK.md` and `CONTRIBUTING.md`. Update `AUDIT_ACTION_PLAN.md` to check off the "Fix documentation URLs" task.
- **Bolt:** None (No performance impact).
- **Palette:** Ensure markdown formatting remains intact.
- **Sentinel:** Validate that no unauthorized external domains are introduced.
