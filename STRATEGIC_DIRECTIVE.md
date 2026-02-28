# Strategic Directive

**Date:** 2026-02-28
**Author:** Maestro (Strategic Engineering Director AI)
**Phase:** 5 (Tooling Reliability & Rust Adoption)

## Phase 1: Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution targeting predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience. It prioritizes stability and clear UX over DIY flexibility.

**Are we building toward that?**
Yes. Core ISO profile hardening and validation have improved. The next reliability gain is in pre-build/profile verification so breakage is caught before full ISO creation or release.

**Are we solving the highest leverage problem?**
The highest leverage problem now is reducing configuration drift and fragile validation logic in build-critical manifests (`packages.*`, mirrorlists, and profile files).

## Phase 2: Technical Posture Review
**Is the system stable?**
Build stability is improving, but several checks are still string-parsing heavy and distributed across shell scripts. This increases maintenance cost and missed edge cases.

**Is tech debt increasing?**
Potentially. Validation logic is fragmented across multiple scripts with inconsistent error handling.

**Are we overbuilding?**
No. The right move is focused hardening of validation tooling—not feature expansion.

## Phase 3: Priority Selection
**Selected Priority:** Tooling hardening with modest Rust integration.

## Phase 4: Controlled Scope Definition (Architect)
Architect must focus *only* on build/profile validation reliability and tooling consistency.
- **Goal:** Keep Rust adoption around **3-5%** of project code by concentrating Rust in validation CLIs and preserving shell wrappers for workflow compatibility.
- **Constraints:**
  - Do not rewrite installer/UI flows in Rust.
  - Do not change desktop UX or release branding.
  - Prefer incremental replacement of brittle parsing checks with typed Rust validation.

## Phase 5: Delegation Strategy
- **Architect:** Expand and maintain Rust-based profile validation for required files, package manifest quality, mirrorlist integrity, and architecture expectations.
- **Bolt:** Ensure validation additions remain fast enough for CI and local contributor workflows.
- **Palette:** Keep user-facing errors concise and actionable when validation fails.
- **Sentinel:** Audit validation coverage for bypass paths and verify that security-sensitive files remain in required checks.

## Phase 6: Execution Notes for AI Agents
1. Treat `tools/neos-profile-audit` as the primary typed validator for build profile integrity.
2. Keep entry points simple (`tests/verify_*.sh`) so existing CI jobs remain stable.
3. When adding new validation rules, pair them with clear failure messages and include them in CI.
4. Track Rust footprint pragmatically: target ~3-5% by LOC, focused on tooling and reliability hotspots.
