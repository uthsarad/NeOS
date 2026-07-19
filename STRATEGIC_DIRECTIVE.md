# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to be a highly predictable, rolling-release Arch Linux-based desktop operating system delivering a refined, Windows-familiar user experience right out of the box. Our fundamental goal is to provide a seamless transition to a Linux environment, combining Arch's flexibility with workstation reliability.
- **Alignment:** The product continues to align with its core vision. The critical systemd sandboxing validation debt blocking our forward momentum has been fully resolved by our specialists. Both `neos-liveuser-setup.service` and `neos-autoupdate.service` have been audited, and their hardening profiles mathematically validated. We can now safely resume feature development and UX refinements without the risk of entrenched technical debt or silent update failures.
- **Leverage:** The highest leverage action is to resume our roadmap progression, specifically targeting Phase 6 (UX Polish and Windows Familiarity). With the foundational infrastructure secured, enhancing the desktop environment's discoverability and alignment with user expectations will directly impact initial user satisfaction and reduce friction during onboarding.

## Phase 2 — Technical Posture Review
- **Stability:** The system's base stability is confirmed. Aggressive security enhancements via strict systemd sandboxing (`ProtectSystem=strict`, `ProtectHome=yes`, `NoNewPrivileges=yes`) have been implemented and validated across core services. Testing confirms that `neos-liveuser-setup.service` correctly handles user creation without improper restrictions.
- **Tech Debt:** The previously critical validation debt has been cleared. Sentinel's privilege audit and Palette's logging clarity tasks were completed successfully. We now have a clean slate to build upon, with automated tests (`tests/verify_service_hardening.sh`) safeguarding the environment against future regressions.
- **Overbuilding:** The risk of overbuilding is mitigated by strictly controlled scopes. As we shift back to feature implementation, we will enforce incremental delivery, ensuring that each UX enhancement is isolated, verified, and aligns perfectly with the Windows-familiarity objective.

## Phase 3 — Priority Selection
- **Refinement of recent feature (Phase 6 UX Polish)**

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** Desktop configuration and styling elements, primarily within `profile/airootfs/etc/xdg/` and `profile/airootfs/usr/share/`.
- **Maximum allowed surface area:** GUI defaults, theme integration, shortcuts, and application launch configurations. Core system services, boot scripts, and kernel parameters are strictly out of scope.
- **Constraints:** The Architect must adhere strictly to the Phase 6 roadmap. Modifications must only target UX refinements, avoiding any structural changes to the core OS layer or package management. No new systemd services or fundamental system logic changes are permitted.

## Phase 5 — Delegation Strategy
- **Architect:** Resume implementation focused on Phase 6 UX Polish. Address the baseline initialization debt by implementing concrete Windows-familiar shortcuts, default themes, and application configurations within the designated UI configuration files.
- **Bolt:** Monitor desktop startup times and Plasma initialization overhead introduced by new UX defaults. Ensure configurations do not regress performance.
- **Palette:** Validate visual consistency, accessibility of new UI elements, and ensure new shortcuts match user expectations. Review all theme modifications for contrast and clarity.
- **Sentinel:** Audit new configuration files in `etc/xdg/` to ensure no unintended permissions or execution vectors are introduced via desktop entries or autostart scripts.
