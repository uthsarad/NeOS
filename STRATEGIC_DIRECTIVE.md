# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** Our primary goal is to build a highly predictable, rolling-release Arch Linux-based OS featuring a polished, Windows-familiar user experience.
- **Alignment:** We remain strictly aligned with our product vision. However, we must prioritize robust infrastructure hardening to prevent regressions before developing any new features.
- **Leverage:** The most critical priority right now is ensuring that the strict systemd sandboxing recently introduced does not degrade UX or cause regressions in live-user setup and autoupdate operations. Clearing our pending validation debt is essential to maintaining this stability.

## Phase 2 — Technical Posture Review
- **Stability:** We have applied strict sandboxing to critical system services. The overall stability now requires comprehensive, immediate verification by our specialists.
- **Tech Debt:** We are accumulating significant validation debt. Specifically, two essential specialist tasks—Sentinel for security auditing and Palette for logging UX—are still uncompleted for the newly sandboxed services.
- **Overbuilding:** Starting any Phase 1 Roadmap items before completely verifying the core systemd services would be considered overbuilding and would carry unacceptable regression risks.

## Phase 3 — Priority Selection
**No-build day (strategic pause)**

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum allowed surface area:** 0 files.
- **Constraints:** The Architect is explicitly forbidden from making any file modifications (`forbidden_files: ["**/*"]`). Our collective effort must be entirely focused on eliminating the accumulated validation debt.

## Phase 5 — Delegation Strategy
- **Architect:** Immediately halt all implementation tasks. Do not write or modify any production code until the validation debt is completely cleared.
- **Bolt:** Sustain the current performance baseline. No new optimization tasks are authorized at this time.
- **Palette:** Prioritize and clear the pending validation task regarding logging UX for the restricted systemd services.
- **Sentinel:** Prioritize and clear the pending validation task regarding systemd privilege auditing for the restricted systemd services.
