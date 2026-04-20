# Strategic Directive: Phase 3 Installer & First-Boot Refinement (Execution Phase)

## PHASE 1 — Product Alignment Check
- **Product Vision:** A predictable, curated Arch Linux experience with a Windows-familiar GUI-first workflow.
- **Alignment:** Aligned. The strategic pause and stability verifications have concluded. We are now advancing to the active implementation of Phase 3 (Installer and First-Boot UX).
- **Highest Leverage:** Hardening the core execution logic and error handling in the installer and live-user setup scripts ensures reliability before introducing complex Calamares configurations.

## PHASE 2 — Technical Posture Review
- **Stability:** System is stable. The strategic pause confirmed no regressions exist and baseline checks pass.
- **Tech Debt:** Custom shell scripts (`airootfs/usr/local/bin/neos-liveuser-setup`, `airootfs/usr/local/bin/neos-installer-partition.sh`) require immediate structural refinement to prevent debt accumulation as complexity grows.
- **Overbuilding:** Controlled. The execution scope is strictly limited to structural improvements, error handling, and secure file creation within existing scripts.

## PHASE 3 — Priority Selection
- **Selection:** Refinement of recent feature (Active Implementation)

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:**
  - `airootfs/usr/local/bin/neos-liveuser-setup`
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
- **Surface Area:** Hardening and structural refinement of existing live-user setup and installer partitioning scripts.
- **Constraints:**
  - Do not introduce new dependencies.
  - Ensure trap commands securely handle variable expansion without introducing command injection or masking exit codes.
  - Apply strict secure file creation practices (e.g., `umask 077`, no TOCTOU).

## PHASE 5 — Delegation Strategy
- **Architect:** Implement robust error handling, refine execution flow, and ensure secure file creation in target scripts.
- **Bolt:** Optimize script execution by eliminating redundant subshells and applying native bash capabilities.
- **Palette:** Enhance developer and admin UX through structured, actionable error logging in bash traps.
- **Sentinel:** Audit implemented changes for command injection, quoting flaws, and TOCTOU vulnerabilities.
