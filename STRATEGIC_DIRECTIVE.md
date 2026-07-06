# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** Our foundational objective is to build a highly predictable, rolling-release Arch Linux-based OS featuring a polished, Windows-familiar user experience targeting seamless onboarding and stability.
- **Alignment:** We remain strictly aligned with our core product vision. However, we must ruthlessly prioritize robust infrastructure hardening and comprehensive QA validation to prevent critical regressions before allowing any new feature development or proceeding further down the Roadmap.
- **Leverage:** The absolute highest priority right now is ensuring that the strict systemd sandboxing recently introduced (`ProtectSystem=strict`, etc.) does not inadvertently degrade UX, mask crucial journal log outputs, or cause unexpected regressions in core live-user setup and autoupdate operations. Aggressively clearing our pending validation debt is absolutely essential to maintaining this stability, ensuring our architectural foundations remain structurally sound, and upholding our unwavering commitment to the end-user experience.

## Phase 2 — Technical Posture Review
- **Stability:** We have applied stringent strict sandboxing to mission-critical system services (`neos-autoupdate.service` and `neos-liveuser-setup.service`). The overall stability of these fundamental processes now requires comprehensive, immediate, and mathematically rigorous verification by our designated specialists to definitively guarantee we haven't inadvertently broken core live environment initialization or update functionality.
- **Tech Debt:** We are currently accumulating a highly concerning and entirely untenable level of validation debt. Specifically, two essential specialist tasks—Sentinel for granular security privilege auditing and Palette for verifying logging UX and error clarity—are still completely uncompleted (marked as "pending" in their respective manifests) for the newly sandboxed system services.
- **Overbuilding:** Authorizing any new Roadmap items, such as expanding Phase 2 or Phase 3 installer features, before completely verifying the core systemd services would constitute reckless overbuilding. It would carry unacceptable, entirely avoidable regression risks and severely complicate any future troubleshooting efforts in the field.

## Phase 3 — Priority Selection
**No-build day (strategic pause)**

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum allowed surface area:** 0 files.
- **Constraints:** The Architect is explicitly forbidden from making any file modifications whatsoever (`forbidden_files: ["**/*"]`). Our collective engineering bandwidth must be entirely and exclusively focused on eliminating the accumulated validation debt. Absolutely no new features, refactoring, or infrastructure code will be written today. The repository state must remain completely pristine and unaltered.

## Phase 5 — Delegation Strategy
- **Architect:** Immediately halt all implementation tasks. Do not write, test, or modify any production code until the validation debt is completely cleared. Maintain the strategic pause rigorously. Focus entirely on system comprehension and architectural review rather than code generation.
- **Bolt:** Sustain the current performance baseline perfectly. No new optimization tasks are authorized at this time. Wait for architectural stability to be definitively re-established.
- **Palette:** Prioritize and clear the pending validation task regarding logging UX for the restricted systemd services to ensure exceptionally clear error diagnostics and a flawless troubleshooting experience.
- **Sentinel:** Prioritize and clear the pending validation task regarding systemd privilege auditing for the restricted systemd services. Ensure strictly zero unnecessary privileges are granted and that `ReadWritePaths` are correctly, safely tailored for the required operations.
