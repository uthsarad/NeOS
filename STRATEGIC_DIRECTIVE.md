# Strategic Directive: Build Validation and Infrastructure Hardening

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is striving to be a curated Arch Linux distribution delivering predictable behavior, low breakage, and a stable, Windows-familiar KDE Plasma experience, avoiding the "do-it-yourself" complexity (MISSION.md, ROADMAP.md).
- **Are we building toward that?** Yes, but stability requires bulletproof infrastructure. Current missing CI constraints and runtime safety checks jeopardize this.
- **Are we solving the highest leverage problem?** Yes. Addressing silent release failures (ISO size) and silent data loss risks (missing snapshot dependencies) is critical before any new feature work can proceed.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Mostly, but the deep audit (docs/DEEP_AUDIT.md) revealed critical gaps: the CI pipeline lacks validation against GitHub's 2 GiB release asset limit, and core services (like `neos-autoupdate.sh`) lack dependency validation for tools like `snapper`.
- **Is tech debt increasing?** Yes, deploying scripts without robust error handling or sandboxed services accumulates operational debt.
- **Are we overbuilding?** No, the proposed mitigations are minimal and explicitly required for stable operations.

## PHASE 3 — Priority Selection
- **Selected Priority:** Stabilization / hardening
- **Reasoning:** The risk of producing an un-releasable ISO or experiencing silent data loss on updates is unacceptable. Hardening existing flows must precede new features.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `.github/workflows/build-iso.yml`
  - `tests/verify_iso_size.sh` (new)
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
  - `airootfs/etc/systemd/system/*.service`
- **Maximum allowed surface area:** Changes are strictly limited to adding CI size validation, creating the associated test, injecting dependency checks into the autoupdate script, and sandboxing existing systemd services. No new features, package additions, or UI changes are permitted.
- **Constraints Architect must obey:** Implement only the explicit fixes. Do not refactor unrelated logic in the target scripts. Do not attempt to fix the `pacman.conf` database issue, as it is already resolved.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implement ISO size validation in `.github/workflows/build-iso.yml`, create the `tests/verify_iso_size.sh` test script, and add explicit dependency checks (snapper, btrfs) to `airootfs/usr/local/bin/neos-autoupdate.sh`.
- **Bolt optimizes:** Review the new `tests/verify_iso_size.sh` script to ensure it runs efficiently (e.g., using native bash substring matching or avoiding repeated subprocess calls).
- **Palette enhances:** Ensure any new error messages in `tests/verify_iso_size.sh` include a clear, actionable "💡 How to fix:" block to reduce developer cognitive load.
- **Sentinel audits:** Implement strict systemd service sandboxing (`ProtectSystem=strict`, `NoNewPrivileges=yes`, etc.) in all `.service` files under `airootfs/etc/systemd/system/`.
