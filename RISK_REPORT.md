# Risk & Priority Report

## Current System Risks

**1. Critical Build Blocker (pacman.conf)**
- **Risk Level:** Critical (Active Failure)
- **Impact:** All ISO builds currently fail due to the `DatabaseRequired` signature check in the build environment's `pacman.conf`. The product cannot be distributed until this is resolved.
- **Mitigation Strategy:** Switch the root-level `pacman.conf` to `DatabaseOptional` while strictly enforcing `DatabaseRequired` in the target system's (`airootfs`) configuration. This is the immediate priority for the Architect.

**2. Missing ISO Size Validation in CI/CD**
- **Risk Level:** High
- **Impact:** The GitHub Releases API enforces a hard 2 GiB limit per asset. Without automated validation in the CI pipeline, the build may succeed but the automated release process will fail silently or abort during upload, leading to missing releases and broken delivery pipelines.
- **Mitigation Strategy:** Implement a strict size constraint check in `.github/workflows/build-iso.yml` immediately following the build phase.

**3. Incomplete Architecture Support & Documentation Mismatch**
- **Risk Level:** Medium
- **Impact:** The documentation promises a "Windows-familiar experience," but this is entirely reliant on the Calamares installer, ZRAM generators, and Snapper integrations that currently only exist in the `x86_64` configurations. `i686` and `aarch64` builds will result in broken or vastly degraded user experiences.
- **Mitigation Strategy:** Explicitly document the experimental nature of non-x86_64 architectures in `README.md` and `HANDBOOK.md`. (Deferred to future sprints).

**4. Fragile Dependency Handling in Core Services**
- **Risk Level:** Medium
- **Impact:** Critical scripts such as `neos-autoupdate.sh` rely on external dependencies (like `snapper`) but do not validate their presence before execution. If a user removes a dependency, the service fails silently, potentially leading to data loss (e.g., missing rollback snapshots).
- **Mitigation Strategy:** Implement pre-execution dependency validation in all core bash scripts. (Deferred to future sprints).

## Technical Debt

- **Missing Systemd Sandboxing:** Custom services currently lack security hardening directives (`User=`, `DynamicUser=`, `ProtectSystem=`).
- **Inconsistent Error Handling:** Several custom bash scripts lack strict execution constraints (`set -euo pipefail`) or logging mechanisms.
- **Stale Documentation URLs:** Documentation references legacy paths (e.g., `neos-project/neos`) rather than the active repository.

## Areas of Concern

The immediate concern is the stabilization of the build and release pipeline. All feature development or architectural improvements must be paused until the product can be reliably and consistently built, verified against size constraints, and distributed. The strategy prioritizes the "Critical" and "High" risks defined above.