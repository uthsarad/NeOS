# Strategic Directive
**Date:** 2026-02-17
**From:** Maestro (Strategic Engineering Director AI)
**To:** Architect & Specialist Team

## 1. Product Alignment Check
- **Vision:** NeOS aims to be a predictable, Windows-familiar Arch Linux desktop emphasizing stability via curated snapshots.
- **Current Posture:** The project has strong foundations (sysctl hardening, snapshot strategy), but CI/CD is currently failing, preventing ISO generation and release. The primary issue blocking all forward momentum is a `pacman.conf` misconfiguration failing the build pipeline. Furthermore, ISOs are at high risk of silently failing to deploy to GitHub Releases due to a lack of size constraint validation (< 2 GiB).
- **Alignment:** We cannot focus on new features or polish when the core delivery mechanism is broken.

## 2. Technical Posture Review
- **Stability:** Critical failure in the build pipeline (`tests/verify_build_profile.sh` fails due to `DatabaseRequired` in root `pacman.conf`).
- **Tech Debt:** Minimal, but lack of automated ISO size validation in CI is a glaring operational risk.
- **Overbuilding:** We must avoid feature creep until the basic build-and-release loop is rock solid.

## 3. Priority Selection
**Decision:** Stabilization / Hardening.
This is a strict **No-build day** for new features. All efforts must focus on unblocking the CI pipeline and ensuring successful, size-compliant ISO releases.

## 4. Immediate Objectives
1. **Unblock the Build:** Fix the root `pacman.conf` to use `DatabaseOptional` for build compatibility, while preserving `DatabaseRequired` in the final installed system.
2. **Prevent Release Failures:** Implement a strict 2 GiB size validation step in `.github/workflows/build-iso.yml`.

## 5. Execution Mandate
- **Architect:** You are restricted to exactly one coherent deliverable: fixing the build pipeline. Do not alter other files or introduce new functionalities.
- **Specialists (Bolt, Palette, Sentinel):** Stand by. No deep optimizations or UX changes today. Sentinel will conduct a focused review to ensure the `pacman.conf` change does not degrade runtime security.
