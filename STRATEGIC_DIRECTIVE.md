# Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a stable, curated Arch-based desktop featuring a predictable, Windows-familiar KDE Plasma 6 experience.
- **Are we building toward that?** Yes, by ensuring the core installation scripts and system foundations are thoroughly secured against edge-case vulnerabilities.
- **Are we solving the highest leverage problem?** Yes, preemptively mitigating security risks such as option injection in administration scripts is a high-leverage hardening activity that protects system integrity.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Yes, the system builds successfully and all tests pass.
- **Is tech debt increasing?** No, but minor vulnerabilities like missing option terminators in shell scripts could be exploited if malicious or malformed inputs are provided.
- **Are we overbuilding?** No. We are focusing purely on securing existing logic without adding new features, thereby avoiding complexity creep.

## PHASE 3 — Priority Selection
- **Priority:** Stabilization / hardening
- **Rationale:** The system is functionally complete. The priority is to harden the existing scripts by ensuring all external command invocations involving variables use strict option termination to prevent option injection.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `profile/airootfs/usr/local/bin/neos-installer-partition.sh`
- **Maximum allowed surface area:** 1 file.
- **Constraints Architect must obey:** Do not introduce any new functional behavior or user-facing features. Focus exclusively on adding standard option termination (e.g., `--`) to commands receiving dynamic variables to prevent option injection.

## PHASE 5 — Delegation Strategy
- **Architect:** Apply option terminators to commands (like `lsblk`, `wipefs`, `parted`, etc.) in the partitioning script.
- **Bolt:** Ensure that the addition of option terminators does not introduce subshells or performance overhead.
- **Palette:** Monitor that terminal output clarity is not affected.
- **Sentinel:** Audit the script to confirm that all vulnerable commands have been correctly terminated and that input validation is complete.
