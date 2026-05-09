# Maestro Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** A curated, snapshot-based Arch Linux desktop distribution offering Windows-level usability with Linux-level power.
- **Are we building toward that?** Yes, by ensuring stability and reliable rollback mechanisms through snapshots.
- **Are we solving the highest leverage problem?** Yes. Without validating snapshot dependencies (like `snapper` and a Btrfs root), the autoupdate mechanism can fail silently, violating our stability and predictability goals.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Test suite shows the base profile is stable, but we have identified critical gaps in our automated update scripts.
- **Is tech debt increasing?** The `DEEP_AUDIT.md` highlighted missing validations in `neos-autoupdate.sh` which represent a reliability risk.
- **Are we overbuilding?** No. Adding required dependency checks is fundamental hardening, not overbuilding.

## PHASE 3 — Priority Selection
- **Priority:** Stabilization / hardening.
- **Rationale:** The `AUDIT_ACTION_PLAN.md` requires adding dependency validation to `neos-autoupdate.sh` to prevent silent failures if dependencies like `snapper` are missing or if the root filesystem is not Btrfs.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `profile/airootfs/usr/local/bin/neos-autoupdate.sh`
- **Maximum allowed surface area:** 1 file.
- **Constraints Architect must obey:** Implement the dependency checks as specified in the audit plan. Ensure no regressions in existing logic.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement dependency validation in `neos-autoupdate.sh` (check for `snapper` and Btrfs root) and exit gracefully with a logged warning if prerequisites are missing.
- **Bolt:** Ensure the dependency validation uses fast, native bash checks where possible and avoids unnecessary subshells.
- **Palette:** Verify that the error/warning messages logged via `logger` are clear and adhere to the project's terminology.
- **Sentinel:** Audit the validations to ensure they do not introduce TOCTOU vulnerabilities, path hijack risks, or command injection.
