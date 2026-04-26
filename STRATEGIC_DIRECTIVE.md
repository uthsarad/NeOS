# Strategic Directive

## Phase 1: Product Alignment Check
- **Goal:** NeOS is aiming to be a curated, predictable rolling-release Arch desktop with Windows-familiar UX.
- **Current State:** We are currently operating in Phase 4 (Hardware & Driver Reliability) and Phase 3 (Installer UX). The foundational live environment is operational.
- **Leverage:** The highest leverage problem is solidifying the recently added hardware detection and installer partitioning scripts to ensure predictable onboarding.

## Phase 2: Technical Posture Review
- **Stability:** The system is stable, with core verification tests passing.
- **Tech Debt:** Optimization and UX feedback mechanisms in bash scripts are pending and currently delegated to specialist agents.
- **Overbuilding:** We must avoid introducing complex App Sandboxing (Phase 5) until the core installation and driver assignment flows are robust.

## Phase 3: Priority Selection
**Selection:** Refinement of recent feature
We will focus on refining the hardware detection (`neos-driver-manager`) and the partitioning script (`neos-installer-partition.sh`).

## Phase 4: Controlled Scope Definition
- **Exact files impacted:**
  - `profile/airootfs/usr/local/bin/neos-driver-manager`
  - `profile/airootfs/usr/local/bin/neos-installer-partition.sh`
- **Maximum allowed surface area:** Modifications are strictly limited to these two scripts.
- **Constraints Architect must obey:** Focus strictly on functional implementation of feature refinements. Do not implement deep performance optimizations or comprehensive UX polish; rely on delegation to specialists.

## Phase 5: Delegation Strategy
- **Architect:** Refine baseline driver detection logic and basic partitioning script milestones. Add inline specialist delegation comments.
- **Bolt:** Optimize lspci parsing, subshell usage, and evaluate Btrfs async discard.
- **Palette:** Enhance visual progress feedback and log output formatting.
- **Sentinel:** Audit the detection scripts for injection vulnerabilities and secure error handling.
