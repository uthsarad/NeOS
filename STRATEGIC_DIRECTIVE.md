# Strategic Directive

**Date:** 2026-02-18
**Author:** Maestro (Strategic Engineering Director AI)
**Phase:** 3 (Installer UX) & 4 (Hardware Reliability)

## Phase 1: Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution targeting predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience. It prioritizes stability and clear UX over DIY flexibility.

**Are we building toward that?**
Yes. Recent fixes in verification, boot configurations, and documentation (as seen in `ARCHITECT_REPORT.md` and related commits) have solidified the base ISO build process. The core Plasma experience is mostly staged, but edge-case reliability (especially during installation and post-install updates) requires attention.

**Are we solving the highest leverage problem?**
The highest leverage problem right now is ensuring that a user who successfully builds the ISO and boots it can install the OS *securely* and that the system can *reliably update* itself post-install without bricking due to space or dependency failures.

## Phase 2: Technical Posture Review
**Is the system stable?**
The build process is stabilizing. However, runtime stability relies heavily on the `neos-autoupdate.sh` script and the initial Calamares configuration.
**Is tech debt increasing?**
Yes, slightly. The `alci_repo` in `pacman.conf` uses `SigLevel = Optional`, which is a recognized security debt (noted by Sentinel).
**Are we overbuilding?**
No, but we must be careful not to expand scope before the core install/update loop is bulletproof.

## Phase 3: Priority Selection
**Selected Priority:** Stabilization / hardening (Specifically: Security & Reliability of the Update/Install Process).

## Phase 4: Controlled Scope Definition (Architect)
Architect must focus *only* on hardening the update script and securing the package configuration.
- **Goal:** Address the open medium-severity risks identified by Sentinel and Risk reports, specifically the unsigned repository risk and update script robustness.
- **Constraints:** Do not introduce new features. Do not modify the desktop environment layout.

## Phase 5: Delegation Strategy
- **Architect:** Implement strict space checks in `neos-autoupdate.sh` and enforce stricter repository signing rules where possible.
- **Bolt:** Ensure that the added checks in the update script do not block the UI thread or cause significant delays during startup.
- **Palette:** Ensure any error states from failed updates (e.g., due to low disk space) are communicated cleanly to the user (if a UI hook exists), or at least logged legibly.
- **Sentinel:** Audit the newly implemented space checks and any changes to `pacman.conf` for bypass vulnerabilities.
