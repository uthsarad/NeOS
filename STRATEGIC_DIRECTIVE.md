# STRATEGIC DIRECTIVE ✒️

**Date:** 2026-03-03
**Phase:** 1 - Stabilization & Build Reliability
**Primary Focus:** Pre-build Validation Infrastructure

## 1. Product Alignment Check
The NeOS mission prioritizes a stable, predictable rolling release model and a reliable staging pipeline. We are drifting from our product goals due to missing validation steps in our CI/CD pipeline. Specifically, the ISO size must be strictly limited to avoid deployment failures, and critical configuration issues, such as the `pacman.conf` signature level bug, are blocking builds. Our highest leverage problem is creating a robust pre-build testing environment.

## 2. Technical Posture Review
The system is unstable at build time. Technical debt is increasing because we are relying on manual fixes for build configuration bugs instead of automated pre-build tests. We are not overbuilding; we are under-testing.

## 3. Priority Selection
**Selection: Infrastructure improvement**

We will implement a pre-build validation suite in the CI pipeline to catch configuration and size issues before initiating the costly and time-consuming `mkarchiso` build process.

## 4. Controlled Scope Definition
The Architect is tasked with a highly constrained deliverable: **Pre-build CI Validation and Config Fixes**.

### Exact Files Impacted:
- `pacman.conf`
- `.github/workflows/build-iso.yml`

### Maximum Allowed Surface Area:
- Fix the `pacman.conf` build blocker by updating the signature level.
- Add a new `test` job to `.github/workflows/build-iso.yml` that executes all pre-build verification scripts (`tests/verify_*.sh`) except those that explicitly require a built ISO.
- Enforce the GitHub release artifact size limit within the workflow.

### Constraints Architect Must Obey:
- **STRICT PROHIBITION:** Do NOT modify any files inside the `airootfs/` directory or `profiledef.sh`.
- The `test` job in the workflow must run *before* the `build` job.
- Only fix the top-level `pacman.conf` used for building, not the installed system's configuration.

## 5. Delegation Strategy
- **Architect:** Implement the pre-build test job in the CI workflow and fix the `pacman.conf` build bug.
- **Bolt (Performance):** Ensure the new CI test job runs efficiently and uses native bash globbing for file discovery instead of slow subprocess pipelines.
- **Palette (UX):** Ensure any CI failure messages regarding size constraints are human-readable (MiB) and provide actionable remediation steps.
- **Sentinel (Security):** Ensure any workflow modifications correctly handle permissions, particularly regarding the `workflows: write` permission for auto-merge bots.
