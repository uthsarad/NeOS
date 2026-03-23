# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated, rolling-release Arch Linux distribution targeting a predictable, Windows-familiar KDE Plasma experience through snapshot-based updates and QA validation (Phase 0-2).
- **Are we building toward that?** The immediate blocker to this vision is a failing CI pipeline preventing ISO builds and a lack of architecture-level robustness for snapshot operations.
- **Are we solving the highest leverage problem?** Yes. Without a functional, validated ISO build and release pipeline (Roadmap Phase 1/2), no feature delivery or hardware reliability work (Phases 3-5) can proceed.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** No. The root `pacman.conf` has a build-blocking configuration (`DatabaseRequired`) causing `verify_build_profile.sh` to fail and preventing ISO generation. Furthermore, critical system services (`neos-autoupdate.sh`) lack robust dependency checking (e.g., `snapper` validation), risking silent failures during the core snapshot update process.
- **Is tech debt increasing?** Yes. While recent hardening passes improved security sandboxing and test scripts, the core build failure identified in the Deep Audit remains unresolved. Furthermore, the lack of CI-level ISO size validation risks silent release failures due to GitHub's 2 GiB limit.
- **Are we overbuilding?** No. Addressing these critical blockers and foundational resilience issues is strictly necessary for Phase 1/2 completion.

## PHASE 3 — Priority Selection
**Selected Priority:** Stabilization / hardening

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `pacman.conf`
  - `.github/workflows/build-iso.yml`
  - `tests/verify_build_profile.sh` (or any newly added tests)
- **Maximum allowed surface area:** The Architect must strictly address the build-blocking `pacman.conf` issue identified in the Deep Audit and implement the missing ISO size validation in the CI pipeline. No new features, UI adjustments, or architecture changes are permitted.
- **Constraints Architect must obey:**
  - The `pacman.conf` change must only apply to the build environment, not the installed system.
  - The ISO size validation step must enforce a strict 2 GiB limit.
  - Out-of-scope issues from past audit reports (like systemd sandboxing, Rust profile audit path traversal, TOCTOU in autoupdate, and the sudoers vulnerability) have already been resolved in the current codebase state and must not be touched or re-implemented.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Resolves the `pacman.conf` build blocker and implements ISO size validation in the CI pipeline.
- **Bolt optimizes:** Optimizes CI workflows or newly added bash tests for performance (e.g., minimizing fork/exec overhead).
- **Palette enhances:** Ensures error messages from new CI validation steps are clear, multi-line, and actionable for developers.
- **Sentinel audits:** Verifies that relaxing `pacman.conf` during the build does not compromise the security posture of the final installed system.