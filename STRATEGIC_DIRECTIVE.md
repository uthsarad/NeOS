# NeOS Strategic Directive

## PHASE 1: Product Alignment Check
- **What is the product trying to become?** A stable, curated, rolling-release desktop OS for Windows switchers.
- **Are we building toward that?** We are laying the critical foundations (Phase 0/1/2). We cannot focus on UX polish (Phase 6) until the underlying build pipelines, system services, and update mechanisms are bulletproof.
- **Are we solving the highest leverage problem?** Yes. Recent audits uncovered fragile core services (`neos-autoupdate.sh`), missing execution flags in shell scripts, and un-sandboxed root services. Fixing these prevents silent runtime data loss and privilege escalation risks.

## PHASE 2: Technical Posture Review
- **Is the system stable?** The build pipeline has been significantly stabilized (ISO size checks, pacman signature fixes are in). However, the installed runtime environment is still fragile. Core scripts lack dependency validation (e.g., failing silently if `snapper` is removed) and robust error handling.
- **Is tech debt increasing?** Yes, slightly. The `tests/` directory contains scripts with inconsistent execution permissions (`chmod +x`), and multiple system services run as unrestricted root.
- **Are we overbuilding?** No. We are focusing strictly on hardening existing, implemented features rather than adding new ones.

## PHASE 3: Priority Selection
- **Selected Priority:** Stabilization / hardening.
We are executing a targeted hardening pass on runtime scripts and systemd services to ensure predictable behavior and enforce least-privilege boundaries before moving to Phase 4 (Hardware & Driver Reliability).

## PHASE 4: Controlled Scope Definition
- **Exact files likely impacted:**
  - `airootfs/usr/local/bin/neos-autoupdate.sh`
  - `airootfs/usr/local/bin/neos-liveuser-setup`
  - `airootfs/usr/local/bin/neos-installer-partition.sh`
  - `airootfs/etc/systemd/system/*.service`
  - `tests/*.sh`
- **Maximum allowed surface area:** Existing custom bash scripts in `airootfs/` and their corresponding systemd service files. Test scripts in `tests/`.
- **Constraints Architect must obey:** Do not introduce new features or new system services. Do not modify the ISO build pipeline or repository configuration. Focus entirely on script robustness (dependency checks, strict bash flags) and test suite consistency (executable permissions). Limit the deliverable strictly to this hardening scope.

## PHASE 5: Delegation Strategy
- **Architect builds:** Adds dependency validation (e.g., `snapper` existence check) to `neos-autoupdate.sh` and ensures it exits gracefully. Enforces strict bash error handling (`set -euo pipefail`) in all custom scripts (`neos-liveuser-setup`, `neos-installer-partition.sh`). Fixes executable permissions for all files in `tests/`.
- **Bolt optimizes:** Reviews `tests/verify_iso_size.sh` to replace repeated external subprocess calls (like `grep`) with native bash substring logic to eliminate fork/exec overhead.
- **Palette enhances:** Refines error output in `tests/verify_iso_size.sh` to ensure terminal messages are multi-line and feature a clear '💡 How to fix:' block with actionable, bulleted steps.
- **Sentinel audits:** Audits all systemd `.service` files under `airootfs/etc/systemd/system/` and implements strict sandboxing directives (`ProtectSystem=strict`, `NoNewPrivileges=yes`, `PrivateTmp=yes`) to limit privileges.
