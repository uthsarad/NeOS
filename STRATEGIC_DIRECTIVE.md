# Strategic Directive

**Date:** 2026-03-01
**Author:** Maestro (Strategic Engineering Director AI)
**Phase:** 5 (Tooling Reliability & Rust Adoption)

## Phase 1: Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution targeting predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience. It prioritizes stability and clear UX over DIY flexibility.

**Are we building toward that?**
Yes. Core ISO profile hardening and validation have improved. The next reliability gain is in pre-build/profile verification so breakage is caught before full ISO creation or release.

**Are we solving the highest leverage problem?**
The highest leverage problem now is reducing configuration drift and fragile validation logic in build-critical manifests (`profiledef.sh`).

## Phase 2: Technical Posture Review
**Is the system stable?**
Build stability is improving, but several checks in `tests/verify_build_profile.sh` are still string-parsing heavy (e.g., using `grep` and `sed` to extract values from bash arrays/variables). This increases maintenance cost and missed edge cases.

**Is tech debt increasing?**
Yes, slightly. Validation logic is fragmented and brittle across multiple scripts with inconsistent error handling.

**Are we overbuilding?**
No. The right move is focused hardening of validation tooling—not feature expansion.

## Phase 3: Priority Selection
**Selected Priority:** Infrastructure improvement (Tooling hardening with modest Rust integration).

## Phase 4: Controlled Scope Definition (Architect)
Architect must focus *only* on build/profile validation reliability and tooling consistency.
- **Goal:** Keep Rust adoption around **3-5%** of project code by concentrating Rust in validation CLIs and preserving shell wrappers for workflow compatibility.
- **Constraints:**
  - Do not rewrite installer/UI flows in Rust.
  - Do not change desktop UX or release branding.
  - Prefer incremental replacement of brittle parsing checks with typed Rust validation. Specifically, migrate `profiledef.sh` parsing logic from `tests/verify_build_profile.sh` to `tools/neos-profile-audit/src/main.rs`.

## Phase 5: Delegation Strategy
- **Architect:** Expand `tools/neos-profile-audit` to parse and validate `profiledef.sh` properties (like `pacman_conf` and `bootmodes`). Update `tests/verify_build_profile.sh` to remove the brittle `grep`/`sed` checks that the Rust tool now handles.
- **Bolt:** Ensure the new Rust regex parsing is performant and doesn't significantly slow down the CI validation steps.
- **Palette:** Ensure the Rust CLI outputs user-friendly error messages when a `profiledef.sh` validation fails (e.g., clear indications of what is missing or malformed).
- **Sentinel:** Ensure the parsed configurations reflect the intended security posture, even when parsed by a new tool.

## Phase 6: Execution Notes for AI Agents
1. Treat `tools/neos-profile-audit` as the primary typed validator for build profile integrity.
2. Keep entry points simple (`tests/verify_*.sh`) so existing CI jobs remain stable.
3. When adding new validation rules, pair them with clear failure messages and include them in CI.
4. Track Rust footprint pragmatically: target ~3-5% by LOC, focused on tooling and reliability hotspots.