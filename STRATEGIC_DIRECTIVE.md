# Strategic Directive: Phase 7 App Store UX and Discover Integration

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to provide a predictable, snapshot-gated Arch Linux desktop with a refined KDE Plasma 6 experience, optimized for stability and Windows familiarity.
- **Alignment Status:** The underlying architecture remains highly stable following the mitigation of critical CWE-59 symlink traversal vulnerabilities in `neos-desktop-setup` and `neos-liveuser-setup`. System alignment is now restored as Palette has cleared the Phase 6 UX and observability validation debt. The next logical progression in our roadmap is Phase 7: App Store and Package Management UX.
- **Leverage:** Establishing a reliable, GUI-first software management experience via KDE Discover is the highest leverage action to satisfy the "Windows Switchers" target audience who expect a familiar app store paradigm without terminal usage.

## Phase 2 — Technical Posture Review
- **Stability Posture:** The foundation is exceptionally robust. Sentinel has securely patched user-controlled directories by enforcing `[ -L ]` checks before applying `chmod`, `sed`, or file writes in `neos-liveuser-setup`, and restricted `neos-liveuser-setup.service` via `CapabilityBoundingSet`. Bolt successfully optimized virtualization detection (`neos-vm-graphics`) by evaluating `systemd-detect-virt -q` directly, bypassing subshell overhead.
- **Tech Debt:** Feature implementation debt and validation debt are effectively zero. We are clear to proceed with new feature implementation.
- **Overbuilding Risk:** Minimal, provided we restrict the initial Phase 7 rollout to foundational KDE Discover capabilities, avoiding the introduction of complex custom package management backends.

## Phase 3 — Priority Selection
- New feature implementation (Phase 7: App Store and Package Management UX)

## Phase 4 — Controlled Scope Definition
- **Exact files likely impacted:** `profile/packages.x86_64`, `profile/airootfs/etc/xdg/` (new configuration files).
- **Maximum allowed surface area:** XDG configuration directories for KDE Discover and package manifests.
- **Constraints Architect must obey:** Focus strictly on configuring Discover defaults (e.g., ensuring standard flatpak integration). Do not modify systemd unit configurations, Calamares provisioning logic, or core bash installer scripts.

## Phase 5 — Delegation Strategy
- **Architect:** Implement Discover default configuration.
- **Bolt:** Monitor Discover startup performance and ensure no blocking subprocesses are introduced.
- **Palette:** Enhance the Discover UI/UX accessibility, ensuring update notifications align with Phase 6 Breeze Dark visual identity.
- **Sentinel:** Audit PackageKit privilege contexts and ensure unprivileged users cannot bypass authentication for system-level package installations.
