# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to provide a predictable, snapshot-gated Arch Linux desktop with a refined KDE Plasma 6 experience, optimized for stability and Windows familiarity.
- **Alignment:** We are experiencing a misalignment between our implementation pace and our validation processes. The specialist task manifests (`ai/tasks/*.json`) indicate significant unresolved validation debt regarding systemd service hardening and UX configuration security.
- **Leverage:** The highest leverage action right now is to halt new feature implementation and enforce a strategic pause. Proceeding with further UX or system modifications without resolving pending security audits on `profile/airootfs/etc/systemd/system/*.service` exposes the system to potential regression vectors.

## Phase 2 — Technical Posture Review
- **Stability:** Current baseline stability is unverified for the recent hardening changes. The systemd strict sandboxing implementations in `neos-autoupdate.service` and `neos-liveuser-setup.service` remain unaudited by Sentinel.
- **Tech Debt:** Specialist validation debt is actively accumulating. Bolt, Palette, and Sentinel all have pending tasks. Specifically, the audit of `ReadWritePaths` and sandboxing directives in `profile/airootfs/etc/systemd/system/*.service` is incomplete, and UX consistency of Phase 6 changes in `profile/airootfs/etc/xdg/*` is unverified.
- **Overbuilding:** Continuing to build Phase 6 features while Phase 5 security and logging mechanisms lack validation directly violates our "protect long-term maintainability over speed" principle.

## Phase 3 — Priority Selection
- No-build day (strategic pause)

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum allowed surface area:** Zero modifications to the codebase are permitted for implementation personas.
- **Constraints:** The Architect is completely frozen. No production code, configuration files, or build scripts may be altered. This freeze remains in effect until all pending specialist tasks are marked as completed.

## Phase 5 — Delegation Strategy
- **Architect:** Stand down. No implementation tasks are authorized.
- **Bolt:** Focus entirely on your pending UI performance evaluation tasks. Monitor Plasma startup overhead introduced by new `profile/airootfs/etc/xdg/*` configurations.
- **Palette:** Clear your pending validation tasks. Ensure journal logging clarity for restricted systemd services in `profile/airootfs/etc/systemd/system/*.service` and validate Phase 6 UX accessibility in `profile/airootfs/etc/xdg/*`.
- **Sentinel:** Prioritize the pending systemd sandboxing audit for `neos-autoupdate.service` and `neos-liveuser-setup.service` in `profile/airootfs/etc/systemd/system/*.service`, ensuring strict minimum `ReadWritePaths`, and audit desktop configuration files in `profile/airootfs/etc/xdg/*` for privilege escalation vectors.
