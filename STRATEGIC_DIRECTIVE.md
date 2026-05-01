# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- What is the product trying to become? NeOS is a curated, Arch-based desktop OS targeting predictable behavior through staged updates and QA validation.
- Are we building toward that? Yes, the core system updates and rollback protections via Btrfs snapshots are implemented.
- Are we solving the highest leverage problem? The highest leverage problem now is ensuring the update mechanism is stable, secure, and performs well without breaking itself through overzealous hardening.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the baseline installer and driver manager are operational.
- Is tech debt increasing? Potential debt exists in overly aggressive systemd sandboxing that might break core system updates.
- Are we overbuilding? We need to balance security hardening with functional system update requirements.

## PHASE 3 — Priority Selection
- Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `profile/airootfs/usr/local/bin/neos-autoupdate.sh`
  - `profile/airootfs/etc/systemd/system/neos-autoupdate.service`
- Maximum allowed surface area: 2 files
- Constraints Architect must obey:
  - Do NOT apply `ProtectSystem=strict` to `neos-autoupdate.service` as it mounts `/usr` and `/var` read-only, breaking package manager updates.
  - Optimize the dependency checks and disk space calculations in `neos-autoupdate.sh` using native bash capabilities.
  - Do not introduce new mechanics; only refine the existing update process.

## PHASE 5 — Delegation Strategy
- Architect builds: Refine `neos-autoupdate.sh` and `neos-autoupdate.service` according to constraints.
- Bolt optimizes: Ensure dependency validations and disk space checks use lightweight native bash math to eliminate fork/exec overhead.
- Palette enhances: Review update error notification formatting to ensure messages to the user are clear and actionable.
- Sentinel audits: Verify systemd sandboxing to ensure it limits privileges without breaking the update functionality (e.g., verifying `ProtectSystem=strict` is NOT used).
