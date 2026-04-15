# Maestro Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a predictable, low-breakage, Windows-familiar Arch Linux desktop distribution that curates the user experience and update cycle.
- **Are we building toward that?** Yes, by ensuring a reliable installation and build pipeline. However, fragile external dependencies currently block ISO builds and validation.
- **Are we solving the highest leverage problem?** Yes. Without a passing CI and a reliable mirror list, the system cannot be built, tested, or distributed reliably.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The core architecture is solid and passes most automated verification checks. However, the build pipeline is completely blocked by a failing network connectivity test.
- **Is tech debt increasing?** Relying on an unmaintained or unreachable mirror (`https://ftpmirror.infania.net/mirror/archlinux/`) introduces operational debt and fragility to our release process.
- **Are we overbuilding?** No. Addressing a failing mirror is a critical, minimal fix required for basic functionality.

## PHASE 3 — Priority Selection
Select ONE of:
- **Stabilization / hardening**

We must pause new feature development to address the immediate CI blockage caused by external dependency failure. A reliable build is a prerequisite for all other work.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `airootfs/etc/pacman.d/neos-mirrorlist`
- **Maximum allowed surface area:** Modifications are strictly limited to removing the unreachable mirror. No new mirrors should be added, and no other configuration files should be altered.
- **Constraints Architect must obey:** Remove the line containing `https://ftpmirror.infania.net/mirror/archlinux/` from the mirrorlist. Do not attempt to re-rank or add alternative mirrors to keep the change minimal and focused. Do not alter any other pacman configuration files.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements the targeted removal of the offline mirror to unblock the CI pipeline and restore build stability.
- **Bolt optimizes:** Ensures the mirror connectivity test avoids excessive timeouts to prevent pipeline hangs during future mirror failures.
- **Palette enhances:** Improves error messaging during connectivity failures to be clearer and more actionable for developers.
- **Sentinel audits:** Verifies that mirrorlist parsing remains secure against command injection and only processes valid URLs.
