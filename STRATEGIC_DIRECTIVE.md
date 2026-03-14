# STRATEGIC DIRECTIVE ✒️

## Context
The NeOS repository structure is maturing, but recent automated deep audits have highlighted a critical gap in the CI/CD pipeline. Specifically, the `.github/workflows/build-iso.yml` workflow lacks a cohesive, automated pre-build testing phase that enforces the test suite. Furthermore, when tests are integrated, some tests designed to be non-blocking (like `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh`) do not currently have safety wrappers (`timeout`, `|| true`), risking indefinite hangs in the automated deployment pipeline. Additionally, the `.gitignore` needs missing artifact entries to prevent repo pollution.

## Objective
Implement immediate stabilization and test hardening of the CI/CD pipeline. The goal is to enforce the test suite inside the CI environment *before* the resource-intensive ISO build, without introducing build-blocking regressions from tests that are meant to be informational or non-critical.

## Priorities
- **Stabilization / hardening**: This is the top priority. We must solidify the build and test validation pipeline before introducing any new features.
- **Incremental Delivery**: The Architect will focus solely on the CI/CD workflow, test script wrappers, and the gitignore file.

## Phase 1 — Product Alignment Check
- **What is the product trying to become?** A curated, predictable Arch Linux desktop distribution.
- **Are we building toward that?** Yes, by ensuring the CI/CD pipeline validates changes effectively, we protect predictability and stability.
- **Are we solving the highest leverage problem?** Yes. An unvalidated build pipeline allows regressions. Hanging pipelines block all forward progress. Fixing these is the highest leverage action.

## Phase 2 — Technical Posture Review
- **Is the system stable?** The core ISO builds work, but the automated safety nets (tests) are either not running automatically in CI or risk hanging the CI pipeline.
- **Is tech debt increasing?** Yes, the lack of automated test enforcement and missing `.gitignore` entries constitute tech debt that slows down development.
- **Are we overbuilding?** No. The Architect is strictly scoped to pipeline stabilization.

## Phase 3 — Priority Selection
- **Priority**: Stabilization / hardening.
- **Focus**: CI/CD Pipeline Stabilization and Test Hardening.

## Phase 4 — Controlled Scope Definition
- **Scope**: Modifying `.github/workflows/build-iso.yml` to include a pre-build test job, updating `tests/verify_mkinitcpio.sh` and `tests/verify_qml_enhancements.sh` with timeout wrappers and better error messages, and updating `.gitignore` with standard artifact ignores.
- **Constraints**: No application code or architectural shifts. The Architect must strictly adhere to the `ARCHITECT_SCOPE.json`.

## Phase 5 — Delegation Strategy
- **Architect**: Implements the changes defined in the Scope.
- **Bolt**: Ensures performance by optimizing the CI workflow and bash test scripts to use native operations where possible instead of subprocess-heavy pipelines.
- **Palette**: Improves the terminal UX of the modified test scripts by formatting error messages into clear, actionable, bulleted '💡 How to fix:' blocks.
- **Sentinel**: Audits the privileged execution container setup (`archlinux:latest` with `--privileged`) within the newly defined pre-build CI test job to verify no unintended security risks are introduced.