# STRATEGIC DIRECTIVE: Documentation URL Remediation

## Phase 1: Product Alignment
NeOS requires accurate documentation to support users and developers. Broken links and incorrect repository references degrade the user experience and create confusion regarding where to find the source code, open issues, or contribute. Fixing these URLs aligns with the goal of providing a polished, predictable end-user experience.

## Phase 2: Technical Posture
The system build and core functionalities are stable, with the most critical build-blocking issues resolved. However, the documentation contains technical debt in the form of outdated or hypothetical URLs (`https://github.com/neos-project/neos` and "NeOS curated repos"). This technical debt must be addressed before the beta release.

## Phase 3: Priority Selection
Selected Priority: **Refinement of recent feature (Documentation)**. Hardening the documentation by ensuring all links are valid and accurately reflect the current project state is the next highest priority item in the `AUDIT_ACTION_PLAN.md` that can be addressed via code changes.

## Phase 4: Controlled Scope
- **Impacted Files:** `docs/HANDBOOK.md`, `CONTRIBUTING.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`
- **Allowed Action:** Find and replace `https://github.com/neos-project/neos` with `https://github.com/uthsarad/NeOS`. Remove or correct references to "NeOS curated repos" as they do not exist.
- **Constraints:** Do not modify any logic or system configurations. Only update markdown files.

## Phase 5: Delegation Strategy
- **Architect:** Execute the find-and-replace for the specified URLs and references across the designated files.
- **Bolt:** No performance optimization required.
- **Palette:** Ensure formatting of updated links remains clean and accessible.
- **Sentinel:** Verify no malicious or untrusted external URLs are introduced during the update.
