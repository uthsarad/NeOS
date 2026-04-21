# Strategic Directive: Phase 3 Installer Partitioning Implementation

## PHASE 1 — Product Alignment Check
- **Product Vision:** A predictable, curated Arch Linux experience with a Windows-familiar GUI-first workflow.
- **Alignment:** Aligned. With foundational scripts refined, we must build the core partitioning capability to enable installation.
- **Highest Leverage:** Implementing safe, robust Btrfs partitioning logic is the most critical blocker for the Phase 3 Installer UX.

## PHASE 2 — Technical Posture Review
- **Stability:** System is stable.
- **Tech Debt:** Existing shell scripts are clean. We must prevent complexity creep in the new partitioning script.
- **Overbuilding:** Controlled. We will focus purely on baseline Btrfs subvolume layout and explicit device targeting. No complex multi-disk or RAID setups yet.

## PHASE 3 — Priority Selection
- **Selection:** New feature implementation (Partitioning Logic)

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:**
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
- **Surface Area:** Implement the core functions to format a targeted disk with Btrfs, create required subvolumes (`@`, `@home`, `@var`, `@snapshots`), and handle UEFI boot partition setup.
- **Constraints:**
  - Must implement explicit device safety checks (e.g., verifying target is a block device, not mounted).
  - Keep operations minimal and idempotent where possible.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement the core partitioning and formatting logic.
- **Bolt:** Optimize disk I/O operations and parallelize where safe.
- **Palette:** Provide clear terminal output indicating progress and milestones during partitioning.
- **Sentinel:** Audit the script for destructive operation safety, ensuring `rm -rf` or `wipefs` are strictly bounded.
