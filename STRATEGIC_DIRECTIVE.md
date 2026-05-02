# Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a stable, curated Arch-based desktop with a Windows-familiar KDE Plasma 6 experience.
- **Are we building toward that?** Yes, by ensuring the core installation and update mechanisms are reliable and provide clear feedback.
- **Are we solving the highest leverage problem?** The highest leverage problem is stabilizing the core scripts (partitioning, driver management, autoupdating) and polishing the installer branding to ensure the live/install experience is seamless.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The system is stabilizing after foundational work.
- **Is tech debt increasing?** Minor tech debt exists in system script performance and error handling clarity.
- **Are we overbuilding?** No. The focus is strictly on refining what is already present.

## PHASE 3 — Priority Selection
- **Priority:** Stabilization / hardening
- **Rationale:** We must harden the installer scripts and update services against TOCTOU vulnerabilities, performance bottlenecks, and UX inconsistencies.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `profile/airootfs/usr/local/bin/neos-driver-manager`
  - `profile/airootfs/usr/local/bin/neos-autoupdate.sh`
  - `profile/airootfs/usr/local/bin/neos-installer-partition.sh`
  - `profile/airootfs/etc/calamares/branding/neos/branding.desc`
  - `profile/airootfs/etc/systemd/system/neos-autoupdate.service`
- **Maximum allowed surface area:** Confined strictly to the scripts and configuration files listed above.
- **Constraints Architect must obey:** Do not introduce new features. Implement required specialist task annotations and perform minimal functional hardening.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement the baseline functional corrections and insert delegation comments for specialists.
- **Bolt:** Optimize script execution paths using native bash variables over subshells and ensure performance tuning.
- **Palette:** Ensure accessibility improvements like text-based progress bars rendering properly, high contrast, and using the official NeOS blue (#0078D4) in branding configurations. Ensure CLI errors use structured formatting and bullet points.
- **Sentinel:** Audit for path hijacking, TOCTOU vulnerabilities, command injection via unescaped bash variables in traps, and ensure systemd services do not use `ProtectSystem=strict` where package managers run.
