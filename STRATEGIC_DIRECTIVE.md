# Strategic Directive

## Phase 1: Product Alignment Check
- **Goal:** NeOS aims to be a curated, predictable rolling-release Arch desktop with Windows-familiar UX.
- **Current State:** The foundational snapshot infrastructure and ISO build pipeline are operational. Immediate blocking issues like `pacman.conf` and CI ISO validation are resolved.
- **Leverage:** The highest leverage problem is completing the remaining high-priority audit items to ensure reliable system hardening and accurate documentation without breaking existing functionality.

## Phase 2: Technical Posture Review
- **Stability:** The build pipeline is unblocked and functional.
- **Tech Debt:** High-priority documentation gaps regarding architecture limitations and missing dependency validations in the autoupdate script remain.
- **Overbuilding:** We must strictly adhere to resolving immediate audit findings and hardening existing services before introducing new features like App Sandboxing (Phase 5).

## Phase 3: Priority Selection
**Selection:** Stabilization / hardening
We will focus on documenting architecture limitations, adding dependency validation to the autoupdate script, fixing documentation URLs, adding section comments to packages.x86_64, and implementing systemd sandboxing.

## Phase 4: Controlled Scope Definition
- **Exact files impacted:**
  - `README.md`
  - `docs/HANDBOOK.md`
  - `CONTRIBUTING.md`
  - `profile/packages.x86_64`
  - `profile/airootfs/usr/local/bin/neos-autoupdate.sh`
  - `profile/airootfs/etc/systemd/system/neos-autoupdate.service`
  - `profile/airootfs/etc/systemd/system/neos-driver-manager.service`
  - `profile/airootfs/etc/systemd/system/neos-liveuser-setup.service`
- **Maximum allowed surface area:** Modifications are strictly limited to these files to resolve the remaining High/Medium priority audit findings.
- **Constraints Architect must obey:** Focus strictly on functional implementation of the fixes. Do not implement deep performance optimizations or comprehensive UX polish; rely on delegation to specialists. Ensure security configurations do not break existing functionality (e.g., do not use `ProtectSystem=strict` on `neos-autoupdate.service`).

## Phase 5: Delegation Strategy
- **Architect:** Implement the remaining fixes outlined in `docs/AUDIT_ACTION_PLAN.md` for High and Medium Priority items.
- **Bolt:** Optimize CI validation scripts and evaluate the performance impact of new sandboxing directives.
- **Palette:** Ensure error messages and documentation updates are clear, actionable, and formatted correctly.
- **Sentinel:** Audit the new systemd sandboxing rules to ensure no new vulnerabilities are introduced and that they are applied correctly without breaking services.
