# NeOS Strategic Directive

**Date:** 2026-03-30
**Run:** Maestro Initialization

## Phase 1 — Product Alignment Check

**What is the product trying to become?**
NeOS aims to be a curated, snapshot-based Arch Linux desktop distribution that provides a predictable, low-breakage, Windows-familiar KDE Plasma experience. It targets users seeking stability, seamless hardware enablement (especially Nvidia), and simple GUI-first management without terminal dependency.

**Are we building toward that?**
Yes. The current codebase already defines rigorous architectural goals, CI/CD validation, and base configuration templates. The project has laid out a phased roadmap, and we are currently working through ensuring robustness, security, and build stability before advancing to complex UX integrations.

**Are we solving the highest leverage problem?**
The most critical items that blocked the build or posed severe risks (e.g., `pacman.conf` DatabaseRequired, ISO size validation, missing dependencies in autoupdate) have been flagged or resolved. Our next highest leverage action is to improve the robustness and reliability of the build and testing infrastructure, specifically targeting unresolved issues from the deep audit.

## Phase 2 — Technical Posture Review

**Is the system stable?**
The build pipeline is functionally in place, but several medium-priority issues remain that affect testing reliability, package consistency, and runtime security sandboxing.

**Is tech debt increasing?**
Slightly. There are missing tests (e.g., ISO size constraint verification) and inconsistencies in package lists across architectures that make maintenance harder and reduce confidence in multi-architecture builds. Custom scripts have some trap and logging behaviors that need refinement to be entirely safe and performant.

**Are we overbuilding?**
No. We are sticking strictly to hardening the foundational pipeline and addressing specific findings from the recent DEEP_AUDIT.md report before adding new features.

## Phase 3 — Priority Selection

**Selection:** Refinement of recent feature & Stabilization / hardening.

**Justification:** The project is in a stabilization phase. To ensure the CI pipeline and validation scripts are robust, we must address the remaining medium-priority audit findings and refine the test infrastructure. Specifically, we will implement the missing test for ISO size constraints, ensure package lists are properly commented for consistency, and refine error handling in the `neos-liveuser-setup` script.

## Phase 4 — Controlled Scope Definition

**Exact files likely impacted:**
- `tests/verify_iso_size.sh` (new file)
- `packages.x86_64`
- `airootfs/usr/local/bin/neos-liveuser-setup`
- `airootfs/usr/local/bin/neos-installer-partition.sh`

**Maximum allowed surface area:**
- Creation of one new bash test script.
- Modification of package lists to add comments (no package additions/removals).
- Modification of trap statements in custom bash scripts to ensure safe and clear error logging.

**Constraints Architect must obey:**
- Do NOT implement any new runtime features or change package contents.
- Ensure all test scripts comply with the strict `set -euo pipefail` standard and handle errors gracefully.
- Do NOT modify the core build workflow (`build-iso.yml`) beyond what is necessary to run the new test if needed.
- Follow the exact specification from DEEP_AUDIT.md for the new ISO size test.

## Phase 5 — Delegation Strategy

**Architect (Implementation Lead):**
- Create the `tests/verify_iso_size.sh` script to validate compression settings and `NoExtract` configurations, ensuring it exits correctly and has `+x` permissions.
- Add structural comments to `packages.x86_64` to match the style of other architectures.

**Bolt (Performance Specialist):**
- Review the custom scripts (`neos-liveuser-setup`, `neos-installer-partition.sh`) to ensure the `trap` error logging mechanisms avoid excessive subshell overhead, relying natively on `$LINENO` and `$?`.

**Palette (UX & Accessibility Specialist):**
- Review the `trap` error messages in custom scripts to ensure they are visually structured, clear, actionable, and effectively guide administrators or developers when failures occur.

**Sentinel (Security Specialist):**
- Review the custom scripts to ensure `trap` commands do not mask exit codes, and that parameter expansion within traps (like `$BASH_COMMAND` or `$0`) is evaluated safely without command injection risks.