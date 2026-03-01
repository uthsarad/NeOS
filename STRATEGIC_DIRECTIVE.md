# Strategic Directive

**Date:** 2026-03-01
**Author:** Maestro (Strategic Engineering Director AI)
**Phase:** 5 (Tooling Reliability & Security Auditing)

## Phase 1: Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution targeting predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience. It prioritizes stability and clear UX over DIY flexibility.

**Are we building toward that?**
Mostly yes. The core infrastructure is solidifying. However, security debt from unsigned repositories continues to pose a supply chain risk, and pre-build CI testing is incomplete.

**Are we solving the highest leverage problem?**
The highest leverage problem now is ensuring the build process does not silently introduce supply chain vulnerabilities, while fixing known missing CI checks outlined in the Deep Audit.

## Phase 2: Technical Posture Review
**Is the system stable?**
Yes, but the build process has a known security gap (`alci_repo` using `SigLevel = Optional`).

**Is tech debt increasing?**
Yes, security debt is persisting. The `Deep Audit` flagged missing pre-build test runs in CI (e.g., `tests/verify_*.sh` are only run *after* the expensive build process or skipped entirely).

**Are we overbuilding?**
No. We are pivoting to hardening and CI refinement.

## Phase 3: Priority Selection
**Selected Priority:** Stabilization / hardening (Fixing CI test execution order and addressing the unsigned `alci_repo` vulnerability).

## Phase 4: Controlled Scope Definition (Architect)
Architect must focus on CI test execution and repository security.
- **Goal 1:** Update `.github/workflows/build-iso.yml` to run all `tests/verify_*.sh` scripts (except `verify_iso_smoketest.sh`, `verify_iso_grub.sh`, and `verify_iso_size.sh` which require a built ISO) *before* the `mkarchiso` build step. This matches the recommendation in `docs/DEEP_AUDIT.md`.
- **Goal 2:** Address the `alci_repo` unsigned package issue in `pacman.conf`. Since we don't have an internal mirror yet, we must either document a concrete path forward or enforce `SigLevel = Required` if the upstream supports it (Arch Linux standards). Let's attempt to enforce `SigLevel = Required DatabaseOptional` for `alci_repo` in `pacman.conf` to close the security gap, assuming upstream ALCI signs their packages.

- **Constraints:**
  - Do not modify the actual build logic (`mkarchiso` command).
  - Do not change the `DatabaseOptional` requirement for the root config, as builds still need it.

## Phase 5: Delegation Strategy
- **Architect:**
    1. Update `.github/workflows/build-iso.yml` to add a `test` job or step *before* `Build ISO` that executes the pre-build verification scripts.
    2. Modify `pacman.conf` to change `[alci_repo]` `SigLevel` to `Required DatabaseOptional`.
- **Bolt:** Ensure the new CI test step is efficient and runs quickly before the main build.
- **Palette:** (No UX changes required for this backend CI/Security task).
- **Sentinel:** Verify that the `alci_repo` signature enforcement mitigates the supply chain risk identified in the `SENTINEL_REPORT.md`.

## Phase 6: Execution Notes for AI Agents
1. Prioritize failing fast in CI. If a `verify_*.sh` script fails, the ISO should not be built.
2. Ensure the `test` step has necessary dependencies (like `python3-yaml` for `verify_build_profile.sh` if needed, though it gracefully degrades).