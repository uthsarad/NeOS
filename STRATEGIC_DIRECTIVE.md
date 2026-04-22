# Strategic Directive
**Date:** 2026-04-01
**Phase:** Core Infrastructure & Baseline Usability

## Product Alignment Check
The product is NeOS, a curated, snapshot-based Arch Linux desktop distribution targeting Windows switchers with a KDE Plasma 6 focus. We are currently ensuring the baseline architecture is solid, secure, and performant before advancing to UX polish.

## Technical Posture Review
The baseline system is stable with core configuration, security, and partitioning logic implemented. The deep audit (docs/DEEP_AUDIT.md) surfaced some infrastructure issues, mainly around CI tests.

## Priority Selection
**Stabilization / hardening** - Specifically fixing CI tests that fail due to missing dependencies/network assumptions, and hardening the CI pipeline structure. The codebase itself is in a good spot for a no-build day for Architects.

## Controlled Scope Definition
*   Target: Tests (`tests/`) and CI pipelines (`.github/workflows/`)
*   Constraints: Do not modify core production code (`airootfs/`). Limit changes to fixing the verification scripts to be robust in CI environments.

## Delegation Strategy
*   **Architect:** No-build day (Strategic Pause). Wait for CI/Test stabilization.
*   **Bolt:** Ensure CI test loops are optimized.
*   **Palette:** Ensure test errors are actionable.
*   **Sentinel:** Audit CI execution privileges and dependencies.
