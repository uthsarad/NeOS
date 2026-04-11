# STRATEGIC_DIRECTIVE

PHASE 1 — Product Alignment Check
- What is the product trying to become?
NeOS aims to be a curated Arch-based desktop OS targeting predictable behavior, delivering a Windows-familiar KDE Plasma experience with low-friction onboarding and long-term stability.
- Are we building toward that?
Yes. Recent efforts have heavily fortified the foundation, adding deep audits, CI validations, robust automated snapshot update mechanisms, and essential installer (Calamares) refinements.
- Are we solving the highest leverage problem?
Currently, our test suite is extensive and functional, but some checks (like ShellCheck) are failing or degrading gracefully. We need to ensure error handling is robust across all scripts to prevent silent failures during operation or installation, solidifying the user experience and maintainability.

PHASE 2 — Technical Posture Review
- Is the system stable?
Yes, core validations (22/24) pass. The ISO builds correctly with profile checks succeeding. Hardening configurations (UFW, sysctl, systemd sandboxing) are in place.
- Is tech debt increasing?
Tech debt is low, but inconsistent error handling across operational scripts (e.g., missing traps) can cause unpredictable edge cases.
- Are we overbuilding?
Not currently. The focus has been on baseline reliability rather than excessive features.

PHASE 3 — Priority Selection
- Stabilization / hardening
Given the recent influx of security and structural validations, the highest priority is to stabilize the scripts running inside the live and installed environments. Implementing rigorous error handling (e.g., `trap` commands) in scripts like `neos-liveuser-setup` and `neos-installer-partition.sh` will ensure failures are logged explicitly rather than failing silently, aligning with "predictable operations."

PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `airootfs/usr/local/bin/neos-liveuser-setup`
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
- Maximum allowed surface area:
  - Modifications should be strictly limited to adding error traps (`set -euo pipefail` and `trap '...' ERR`) and ensuring robust logging in existing shell scripts.
- Constraints Architect must obey:
  - Do not alter the core logic or flow of the setup scripts.
  - Do not introduce new dependencies.
  - Ensure added traps log standard output securely and cleanly without causing subshell overhead issues.

PHASE 5 — Delegation Strategy
- Architect builds:
  - Implement standard Bash error handling traps (`trap 'logger -t "\$(basename "\$0")" "ERROR at line \$LINENO"' ERR`) across critical operational scripts.
- Bolt optimizes:
  - Review added trap implementations to verify they minimize subshell overhead and use native Bash constructs efficiently.
- Palette enhances:
  - Ensure the formatting of error messages emitted by these traps is clear, structured, and actionable for developers and administrators reading logs.
- Sentinel audits:
  - Verify that the trap implementations handle variable expansion safely, without introducing command injection vectors or inadvertently masking exit codes.
