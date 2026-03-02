# STRATEGIC DIRECTIVE ✒️

**Date:** 2026-03-02
**Phase:** 1 - Stabilization & Build Reliability
**Primary Focus:** Unblocking ISO Delivery & CI Validation

## 1. Product Alignment Check
The NeOS mission prioritizes a stable, predictable rolling release model and a reliable staging pipeline. Currently, our core delivery mechanism—the ISO build process—is critically blocked by a configuration error identified in the `DEEP_AUDIT.md` report. A broken build prevents any downstream validation, QA, or feature delivery, representing a fundamental misalignment with our reliability goals.

## 2. Technical Posture Review
While recent efforts to migrate configuration validation to robust Rust tooling (`neos-profile-audit`) have improved stability and security, the underlying build environment configuration remains compromised. Specifically, the root `pacman.conf` requires database signatures that do not exist during the build stage. Furthermore, the CI pipeline lacks automated safeguards against bloated ISO artifacts, risking deployment failures to GitHub Releases (2 GiB limit).

## 3. Priority Selection
**Selection: Stabilization / hardening**

We are taking a strategic pause on new feature development (such as Calamares installer UX or desktop environment tweaks). The absolute highest leverage action is restoring the integrity of the CI/CD pipeline and preventing future regressions in release artifact size.

## 4. Controlled Scope Definition
The Architect is tasked with a single, highly constrained deliverable: **ISO Build Infrastructure Stabilization**.

### Exact Files Impacted:
- `pacman.conf` (Root directory only)
- `.github/workflows/build-iso.yml`

### Maximum Allowed Surface Area:
- Modification of the `SigLevel` configuration in the root `pacman.conf` file.
- Addition of an ISO size verification step within the existing GitHub Actions workflow.

### Constraints Architect Must Obey:
- **STRICT PROHIBITION:** Do NOT modify `airootfs/etc/pacman.conf`. The installed system must retain strict `DatabaseRequired` security.
- The ISO size limit must be set precisely to 2 GiB (2 * 1024 * 1024 * 1024 bytes).
- Do not introduce new third-party actions to the GitHub workflow for the size check; use standard POSIX utilities (e.g., `stat`).

## 5. Delegation Strategy
- **Architect:** Implement the `pacman.conf` fix and the GitHub Actions YAML size check.
- **Bolt (Performance):** Ensure the CI size check utilizes lightweight, built-in system tools (`stat`) rather than spinning up heavy containers or complex scripts.
- **Palette (UX):** Guarantee that if the CI size check fails, the terminal output is highly actionable for developers (displaying current size, limit, and human-readable formats).
- **Sentinel (Security):** Audit the pipeline to verify that relaxing the root `pacman.conf` signature requirements does not inadvertently compromise the target system's package manager (`airootfs/etc/pacman.conf`).
