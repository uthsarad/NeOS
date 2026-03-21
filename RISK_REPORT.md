# NeOS Risk & Priority Report

## Current Risk Landscape

### 1. Runtime Reliability Risk (Medium)
**Observation:** Several core scripts deployed in the live and installed environments lack robust dependency checking and strict error handling boundaries.
**Impact:** If a user uninstalls a critical dependency (e.g., `snapper`), automated tasks like system updates (`neos-autoupdate.sh`) will fail silently or behave unpredictably, leading to potential data loss or unbootable states during rolling release updates.
**Mitigation Priority:** Immediate. Architect must add graceful dependency validation and enforce `set -euo pipefail` across all custom deployment scripts.

### 2. Privilege Escalation Risk (Medium)
**Observation:** Custom systemd service units installed to `airootfs/etc/systemd/system/` run as unrestricted root.
**Impact:** If any of the custom scripts invoked by these services (like driver managers or auto-updaters) are exploited via malicious input or unforeseen edge cases, the attacker gains full, un-sandboxed root access to the host.
**Mitigation Priority:** Immediate. Sentinel must enforce systemd sandboxing directives (`ProtectSystem=strict`, `NoNewPrivileges=yes`, `PrivateTmp=yes`) to enforce least-privilege principles.

### 3. Developer Experience Risk (Low)
**Observation:** Inconsistent file execution permissions in the test suite and suboptimal shell performance in validation scripts.
**Impact:** Increases cognitive load for new contributors navigating the CI pipeline and slows down local build validations.
**Mitigation Priority:** Low but actionable. Bolt and Palette will refine test script performance and error output readability.

## Strategic Outlook
By prioritizing this hardening pass, we address crucial technical debt identified in the Deep Audit. This stabilizes the foundational layers defined in Roadmap Phase 0-2, ensuring that as we transition focus toward hardware quirks and application UX (Phases 4-5), the underlying deployment mechanics are resilient and secure.
