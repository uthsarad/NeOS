# Strategic Directive: Phase 8 - Snapshot Rollback UX (Baseline)

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to provide a predictable, snapshot-gated Arch Linux desktop with a refined KDE Plasma 6 experience, optimized for stability and Windows familiarity.
- **Alignment Status:** We are operating within Phase 8 (Long-Term Maintenance). A critical best-practice requirement from the architecture docs is a GUI-friendly rollback path for Btrfs snapshots.
- **Leverage:** The highest leverage problem is introducing visibility into system snapshots. The Strategic Pause is lifted, as all Phase 8 baseline validations are complete.

## Phase 2 — Technical Posture Review
- **Stability Posture:** The system is stable. Sentinel and Palette have successfully audited and remediated the `neos-operations-hub` baseline.
- **Tech Debt:** Low. We must ensure we do not introduce complex or risky Btrfs operations immediately.
- **Overbuilding Risk:** High if we attempt a full automated rollback system. We must favor incremental delivery.

## Phase 3 — Priority Selection
- New feature implementation (Incremental: Snapshot Rollback UX read-only baseline)

## Phase 4 — Controlled Scope Definition
- **Exact files likely impacted:** `profile/airootfs/usr/local/bin/neos-operations-hub`
- **Maximum allowed surface area:** 1 file.
- **Constraints Architect must obey:** Add a 5th option to `neos-operations-hub` for "System Snapshot & Rollback". The implementation must be the smallest viable interpretation: a GUI-first (`kdialog`) informational stub or read-only list that advises the user on snapshot status, without executing actual system modification or rollback commands yet.

## Phase 5 — Delegation Strategy
- **Architect:** Implement the read-only or informational stub for snapshot management in `neos-operations-hub`.
- **Bolt:** Profile the newly added snapshot queries for subprocess overhead.
- **Palette:** Ensure the new snapshot dialogs are accessible to screen readers.
- **Sentinel:** Audit the snapshot query mechanisms for command injection or unintended information disclosure.
