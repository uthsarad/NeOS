# STRATEGIC_DIRECTIVE

PHASE 1 — Product Alignment Check
- What is the product trying to become?
NeOS aims to be a curated Arch-based desktop OS targeting predictable behavior, delivering a Windows-familiar KDE Plasma experience with low-friction onboarding and long-term stability.
- Are we building toward that?
Yes. Recent efforts have fortified the foundation, adding deep audits, CI validations, robust automated snapshot update mechanisms, and essential installer (Calamares) refinements.
- Are we solving the highest leverage problem?
Currently, our test suite is extensive and functional. The autoupdate mechanism utilizes snapper for system rollback, ensuring reliability. However, we need to ensure that specialists review the `snapper` dependency check in `neos-autoupdate.sh` to prevent regressions in performance, UX, and security.

PHASE 2 — Technical Posture Review
- Is the system stable?
Yes, core validations (22/24) pass. The ISO builds correctly with profile checks succeeding. Hardening configurations (UFW, sysctl, systemd sandboxing) are in place.
- Is tech debt increasing?
Tech debt is low, but ensuring all critical paths are reviewed by specialists prevents future debt.
- Are we overbuilding?
Not currently. The focus has been on baseline reliability rather than excessive features.

PHASE 3 — Priority Selection
- Refinement of recent feature
Given the recent influx of security and structural validations, the highest priority is to ensure that the `snapper` dependency validation in `neos-autoupdate.sh` is reviewed by all specialists (Bolt, Palette, Sentinel) to guarantee optimal performance, clear error reporting, and secure execution.

PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
- Maximum allowed surface area:
  - Modifications should be strictly limited to adding specialist delegation comments to the `snapper` validation block.
- Constraints Architect must obey:
  - Do not alter the core logic or flow of the autoupdate script.
  - Do not introduce new dependencies.

PHASE 5 — Delegation Strategy
- Architect builds:
  - Add inline comments to `neos-autoupdate.sh` delegating specific reviews to Bolt, Palette, and Sentinel.
- Bolt optimizes:
  - Ensure the dependency validation for snapper relies on lightweight native bash capabilities to eliminate fork/exec overhead.
- Palette enhances:
  - Ensure the error message logged when snapper is missing is clear, informative, and provides actionable context.
- Sentinel audits:
  - Verify that the early exit upon missing snapper does not bypass the flock-based locking mechanisms or introduce TOCTOU race conditions.
