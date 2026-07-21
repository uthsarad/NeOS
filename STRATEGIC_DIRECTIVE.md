# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to provide a predictable, snapshot-gated Arch Linux desktop with a refined KDE Plasma 6 experience, optimized for stability and Windows familiarity.
- **Alignment Status:** We remain misaligned between feature velocity and validation. The introduction of Phase 6 configuration files (`profile/airootfs/etc/xdg/*`) and Phase 5 systemd strict sandboxing in `profile/airootfs/etc/systemd/system/*.service` has generated significant technical debt in validation.
- **Leverage:** The highest leverage action is to maintain the implementation freeze. Allowing Architect to proceed with new features before specialists audit the specific systemd `ReadWritePaths` directives and KDE configuration execution paths introduces unacceptable regressions in the ISO build process and runtime environment.

## Phase 2 — Technical Posture Review
- **Stability Posture:** The baseline stability is currently unverified. The application of `ProtectSystem=strict` and `ProtectHome=yes` without comprehensive Sentinel auditing of the `ReadWritePaths` directories (`/usr`, `/boot`, `/etc`, `/var`) for `neos-autoupdate.service` could break core system updates.
- **Tech Debt:** Specialist validation debt is still actively blocking progress. Bolt, Palette, and Sentinel have incomplete pending tasks specifically targeting `profile/airootfs/etc/systemd/system/*.service` and `profile/airootfs/etc/xdg/*`.
- **Overbuilding Risk:** Any new implementation by Architect would compound the risk of masking underlying configuration issues within the existing unvalidated service definitions and KDE shortcut configurations.

## Phase 3 — Priority Selection
- No-build day (strategic pause)

## Phase 4 — Controlled Scope Definition
- **Exact files likely impacted:** None.
- **Maximum allowed surface area:** Zero modifications to the codebase are permitted for implementation personas.
- **Constraints Architect must obey:** The Architect is completely frozen. No production code, configuration files, ISO build scripts, or tests may be altered. This absolute freeze remains in effect until Sentinel, Palette, and Bolt explicitly mark their assigned tasks in `ai/tasks/*.json` as completed.

## Phase 5 — Delegation Strategy
- **Architect:** Stand down. No implementation tasks are authorized.
- **Bolt:** Focus strictly on UI performance profiling. Measure Plasma initialization latency introduced by `profile/airootfs/etc/xdg/*` configurations. Ensure these files do not degrade ISO boot performance.
- **Palette:** Complete the pending log clarity validation for `neos-autoupdate.service` and `neos-liveuser-setup.service` to ensure permission denials are visible. Validate the accessibility, contrast, and UX consistency of the Windows-familiar shortcuts (`Meta+E`, `Meta+D`) in `profile/airootfs/etc/xdg/*`.
- **Sentinel:** Execute the pending security audits immediately. Verify that `ReadWritePaths` in `profile/airootfs/etc/systemd/system/*.service` strictly limit write access to required directories only. Audit `profile/airootfs/etc/xdg/*` for any privilege escalation vectors or arbitrary command execution risks.
