# Strategic Directive

## Phase 8 Execution: Core Build Optimizations and Security Hardening

**Context:** The architecture is currently stabilized and in the "Long-Term Maintenance and Distribution" phase (Phase 8). The primary goal is predictable operations and sustainable maintenance without introducing feature creep. The system has completed multiple security audits and UX refinements.

**Directive:**
Architect is to coordinate Bolt's pending optimization task on `build.sh` targeting subprocess overhead in packaging and compression pipelines, and Sentinel's pending security audit on `neos-autoupdate.sh` to harden input sanitization and secure file handling.

**Constraints:**
- Do not introduce new features.
- Maintain strict backward compatibility with existing build logic.
- Target only `build.sh` and `profile/airootfs/usr/local/bin/neos-autoupdate.sh` as permitted by the scope boundary.
- Ensure Bolt and Sentinel act on real code improvements, fulfilling the zero-slop mandate.
- Palette remains on standby for UX adjustments.

**Delegation Strategy:**
- **Architect:** Coordinate modifications to `build.sh` and `neos-autoupdate.sh`.
- **Bolt:** Implement the pipeline optimization in `build.sh`.
- **Palette:** (Standby) No active implementation required.
- **Sentinel:** Audit `neos-autoupdate.sh` for input sanitization and secure temporary file handling.
