# STRATEGIC_DIRECTIVE.md
**Date:** 2024-05-18
**From:** Maestro (Strategic Engineering Director AI)

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a stable, curated, snapshot-based Arch Linux distribution targeting Windows switchers with a polished KDE Plasma experience.
- **Are we building toward that?** The foundational architecture and roadmap exist, but current CI/CD pipelines are failing, preventing the delivery of the core OS image.
- **Are we solving the highest leverage problem?** Yes. A distribution cannot be tested, polished, or released if the ISO build process is broken. Unblocking the pipeline is the highest priority.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** No. The core ISO build is blocked due to strict package signature requirements in the build environment's `pacman.conf`, and there is a risk of generating ISOs that exceed GitHub Release limits.
- **Is tech debt increasing?** The lack of automated size validation in the CI pipeline represents operational tech debt that needs immediate remediation.
- **Are we overbuilding?** We must pause all new feature development and UX polish until the fundamental build-and-release loop is reliable.

## PHASE 3 — Priority Selection
**Decision:** Stabilization / hardening
This is a strategic pause on new feature development. The exclusive focus is on unblocking the ISO build pipeline and enforcing release constraints.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `pacman.conf`, `.github/workflows/build-iso.yml`
- **Maximum allowed surface area:** Changes are strictly limited to the build environment's `pacman.conf` and the CI build workflow.
- **Constraints Architect must obey:**
    - Do not write production feature code.
    - Limit changes strictly to unblocking the build pipeline.
    - Ensure the installed system's security posture is not degraded by build-time workarounds.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement the `pacman.conf` fix and add the exact ISO size validation logic to the CI workflow.
- **Bolt:** Deferred. No performance optimizations required for this deliverable.
- **Palette:** Deferred. No UX/UI enhancements required for this deliverable.
- **Sentinel:** Audit the `pacman.conf` changes to ensure the relaxed build-time signature checks do not inadvertently compromise the target system's package manager configuration (`airootfs/etc/pacman.conf`).
