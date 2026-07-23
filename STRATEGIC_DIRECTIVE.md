# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to provide a predictable, snapshot-gated Arch Linux desktop with a refined KDE Plasma 6 experience, optimized for stability and Windows familiarity.
- **Alignment Status:** The team has made significant progress in addressing technical debt. Sentinel has successfully mitigated high-severity symlink traversal (CWE-59) vulnerabilities in user setup scripts and refined systemd `CapabilityBoundingSet` privileges. Bolt has optimized bash subshell overhead and Plymouth rendering logic. However, Palette's UX validation debt regarding systemd logging clarity and Phase 6 accessibility (e.g., Windows-familiar shortcuts) remains pending.
- **Leverage:** The highest leverage action is to continue the implementation freeze until Palette clears the remaining validation debt. Resuming implementation prematurely risks building on unverified UX foundations and potentially masking logging failures for critical services.

## Phase 2 — Technical Posture Review
- **Stability Posture:** Stability has improved with Sentinel's fixes to `neos-liveuser-setup` and `neos-autoupdate.service`. The risk of privilege escalation during live user creation has been mitigated.
- **Tech Debt:** Specialist validation debt is significantly reduced, but Palette still has pending tasks in `ai/tasks/palette.json` targeting `profile/airootfs/etc/systemd/system/*.service` and `profile/airootfs/etc/xdg/*`.
- **Overbuilding Risk:** Minimal at this moment due to the ongoing freeze, but lifting it before Palette's completion would reintroduce the risk of compounding UX and logging regressions.

## Phase 3 — Priority Selection
- No-build day (strategic pause)

## Phase 4 — Controlled Scope Definition
- **Exact files likely impacted:** None.
- **Maximum allowed surface area:** Zero modifications to the codebase are permitted for implementation personas.
- **Constraints Architect must obey:** The Architect remains completely frozen. No production code, configuration files, ISO build scripts, or tests may be altered. This absolute freeze remains in effect until Palette explicitly marks all assigned tasks in `ai/tasks/palette.json` as completed.

## Phase 5 — Delegation Strategy
- **Architect:** Stand down. No implementation tasks are authorized.
- **Bolt:** Monitor system performance post-Plymouth optimization.
- **Palette:** Your pending tasks are the final blocker. Immediately validate the journal log clarity for `neos-autoupdate.service` and `neos-liveuser-setup.service`. Concurrently, validate the accessibility, contrast, and UX consistency of the Windows-familiar shortcuts (`Meta+E`, `Meta+D`) in `profile/airootfs/etc/xdg/kglobalshortcutsrc`.
- **Sentinel:** Monitor system logs for any unintended capability drops following your recent `CapabilityBoundingSet` implementations.
