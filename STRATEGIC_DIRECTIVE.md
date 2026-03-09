# Strategic Directive

## Phase 1 — Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution aiming for predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience.

**Are we building toward that?**
Yes, but the system is currently blocked from building ISOs due to a `pacman.conf` configuration error. A stable, automated build pipeline is the foundation of delivering snapshots.

**Are we solving the highest leverage problem?**
The highest leverage problem is the critical build blocker. Until ISO builds succeed, no other features or fixes matter. We must unblock the CI/CD pipeline immediately.

## Phase 2 — Technical Posture Review
**Is the system stable?**
No, it is currently failing to build ISOs due to `SigLevel = Required DatabaseRequired` in the root `pacman.conf`.

**Is tech debt increasing?**
Yes, failing builds hide other potential regressions.

**Are we overbuilding?**
No. We are addressing a critical, 5-minute fix identified in the `DEEP_AUDIT.md` to unblock development.

## Phase 3 — Priority Selection
**Selection:** Stabilization / hardening
**Justification:** Fixing a build-blocking issue is the definition of stabilization. It must be addressed before any new feature implementation.

## Phase 4 — Controlled Scope Definition
**Targeted Files:**
- `pacman.conf` (root level)

**Maximum Allowed Surface Area:**
Modifications are strictly limited to updating the global `SigLevel` in the root `pacman.conf` to `Required DatabaseOptional`. Official repositories (`[core]`, `[extra]`, `[multilib]`) must maintain their explicit overrides to `Required DatabaseRequired`.

**Constraints for Architect:**
- Change only the global `SigLevel` line in the root `pacman.conf`.
- Do not modify `airootfs/etc/pacman.conf` (the installed system's configuration).

## Phase 5 — Delegation Strategy
- **Architect:** Implement the `SigLevel = Required DatabaseOptional` fix in the root `pacman.conf` to unblock ISO builds.
- **Bolt:** No specific performance tasks required for a one-line config change, but maintain awareness of build times.
- **Palette:** No specific UX tasks required for this config change.
- **Sentinel:** Verify that the `DatabaseOptional` change in the root `pacman.conf` does not compromise the security of the installed system's `airootfs/etc/pacman.conf`.