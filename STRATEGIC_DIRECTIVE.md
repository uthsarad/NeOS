# Strategic Directive: Phase 3 Installer & First-Boot Refinement

## PHASE 1 — Product Alignment Check
- **Product Vision:** A predictable, curated Arch Linux experience with a Windows-familiar GUI-first workflow.
- **Alignment:** Aligned. Following the recent stability verification, we are advancing Phase 3 (Installer and First-Boot UX).
- **Highest Leverage:** Hardening the transition from live ISO to an installed state ensures baseline reliability before adding higher-level UX polish.

## PHASE 2 — Technical Posture Review
- **Stability:** System is stable. Recent profile audit optimizations improved CI execution.
- **Tech Debt:** Custom shell scripts (`airootfs/usr/local/bin/neos-liveuser-setup`, `airootfs/usr/local/bin/neos-installer-partition.sh`) require structural refinement to prevent debt accumulation.
- **Overbuilding:** Controlled. We must restrict efforts to hardening existing flows rather than introducing new installer components.

## PHASE 3 — Priority Selection
- **Selection:** Refinement of recent feature

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:**
  - `airootfs/usr/local/bin/neos-liveuser-setup`
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
- **Surface Area:** Hardening and structural refinement of existing live-user setup and installer partitioning scripts.
- **Constraints:**
  - Do not introduce new dependencies.
  - Maintain Btrfs compatibility without unstable mount parsing.
  - Apply strict secure file creation practices (e.g., `umask 077`, no TOCTOU).

## PHASE 5 — Delegation Strategy
- **Architect:** Refine error handling and execution flow in target scripts.
- **Bolt:** Optimize script execution by eliminating redundant subshells and applying native bash capabilities.
- **Palette:** Enhance developer and admin UX through structured, actionable error logging in bash traps.
- **Sentinel:** Audit target scripts for command injection, quoting flaws, and TOCTOU vulnerabilities.
