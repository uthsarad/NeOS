# STRATEGIC_DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is aiming to be a curated, snapshot-based Arch Linux desktop distribution that delivers predictable behavior and a Windows-familiar KDE Plasma experience with low breakage.
- **Are we building toward that?** The deep audit revealed critical and high-priority build and runtime issues. Before we can build new features, we must secure the foundational pipeline and system stability.
- **Are we solving the highest leverage problem?** Yes. A lack of CI ISO size validation risks silent deployment failures due to GitHub's 2 GiB limit. Securing the automated release pipeline is our highest leverage action. (Note: The `pacman.conf` build blocker is confirmed resolved and is out of scope).

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The system itself has good foundations, but there are gaps in CI safety rails (ISO size) and core service sandboxing that leave the system vulnerable.
- **Is tech debt increasing?** Deploying and maintaining an unvalidated pipeline creates operational debt. Missing sandboxing for root-level services creates security debt.
- **Are we overbuilding?** No. Addressing these safety gaps is necessary for any future development to proceed safely and maintain a predictable release cadence.

## PHASE 3 — Priority Selection
- **Selected Priority:** Stabilization / hardening
- **Reasoning:** The missing ISO size validation in CI could lead to untracked deployment failures due to GitHub's 2 GiB limit. Hardening the build pipeline takes absolute precedence over new features.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `.github/workflows/build-iso.yml`
  - `tests/verify_iso_size.sh`
- **Maximum allowed surface area:** The Architect is restricted to a single coherent deliverable: adding the ISO size validation to the CI workflow (`.github/workflows/build-iso.yml`), and writing the associated verification test (`tests/verify_iso_size.sh`).
- **Constraints Architect must obey:** Implement only the explicit fixes for ISO size validation. Do not attempt to fix the `pacman.conf` database issue, as it is already resolved. Do not refactor unrelated workflow steps. Prevent feature creep. Ensure strict adherence to GitHub's 2 GiB limit.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implement ISO size validation (must be < 2 GiB) in `.github/workflows/build-iso.yml` and create the accompanying test script `tests/verify_iso_size.sh`.
- **Bolt optimizes:** Review the new `tests/verify_iso_size.sh` script to ensure it runs efficiently (e.g., using native bash substring matching or avoiding repeated subprocess calls).
- **Palette enhances:** Ensure any new error messages in `tests/verify_iso_size.sh` include a clear, actionable "💡 How to fix:" block to reduce developer cognitive load.
- **Sentinel audits:** Implement strict systemd service sandboxing (`ProtectSystem=strict`, `NoNewPrivileges=yes`, etc.) in all `.service` files under `airootfs/etc/systemd/system/`.