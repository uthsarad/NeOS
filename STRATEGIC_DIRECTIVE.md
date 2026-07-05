# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** Our foundational objective is to build a highly predictable, rolling-release Arch Linux-based OS featuring a polished, Windows-familiar user experience targeting seamless onboarding and stability.
- **Alignment:** We remain strictly aligned with our product vision. However, we must prioritize robust infrastructure hardening and comprehensive QA validation to prevent regressions before developing any new features or proceeding further down the Roadmap.
- **Leverage:** The most critical priority right now is ensuring that the strict systemd sandboxing recently introduced does not degrade UX, mask crucial log outputs, or cause unexpected regressions in live-user setup and autoupdate operations. Clearing our pending validation debt is absolutely essential to maintaining this stability, ensuring our architectural foundations remain sound, and upholding our commitment to the user experience.

## Phase 2 — Technical Posture Review
- **Stability:** We have applied stringent strict sandboxing (e.g., `ProtectSystem=strict`, `ProtectHome=yes`) to critical system services (`neos-autoupdate.service` and `neos-liveuser-setup.service`). The overall stability of these fundamental processes now requires comprehensive, immediate, and rigorous verification by our specialists to definitively guarantee we haven't inadvertently broken core live environment or update functionality.
- **Tech Debt:** We are currently accumulating a highly concerning and untenable level of validation debt. Specifically, two essential specialist tasks—Sentinel for granular security privilege auditing and Palette for verifying logging UX and clarity—are still completely uncompleted (marked as "pending" in their respective manifests) for the newly sandboxed services.
- **Overbuilding:** Starting any new Roadmap items, such as expanding Phase 2 or Phase 3 installer features, before completely verifying the core systemd services would be considered reckless overbuilding. It would carry unacceptable, entirely avoidable regression risks and severely complicate any future troubleshooting efforts.

## Phase 3 — Priority Selection
**No-build day (strategic pause)**

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum allowed surface area:** 0 files.
- **Constraints:** The Architect is explicitly forbidden from making any file modifications whatsoever (`forbidden_files: ["**/*"]`). Our collective engineering effort must be entirely and exclusively focused on eliminating the accumulated validation debt. Absolutely no new features, refactoring, or infrastructure code will be written today. The repository state must remain completely pristine.

## Phase 5 — Delegation Strategy
- **Architect:** Immediately halt all implementation tasks. Do not write or modify any production code until the validation debt is completely cleared. Maintain the strategic pause rigorously. Focus on system comprehension rather than code generation.
- **Bolt:** Sustain the current performance baseline. No new optimization tasks are authorized at this time. Wait for architectural stability to be re-established.
- **Palette:** Prioritize and clear the pending validation task regarding logging UX for the restricted systemd services to ensure exceptionally clear error diagnostics and a flawless troubleshooting experience.
- **Sentinel:** Prioritize and clear the pending validation task regarding systemd privilege auditing for the restricted systemd services. Ensure strictly zero unnecessary privileges are granted and that `ReadWritePaths` are correctly tailored.