# RISK & PRIORITY REPORT 🛡️

**Date:** 2026-03-03
**Author:** Maestro (Strategic Engineering Director)

## 1. System Health & Drift Assessment
- **Product Drift:** Low. The team is strictly focusing on infrastructure and system hardening, aligning perfectly with the goal of creating a reliable rolling release.
- **Tech Debt:** Moderate. While build issues are resolved, several foundational security and dependency checks identified in the initial deep audit remain unaddressed.
- **System Stability:** **DEGRADED**. Essential automated maintenance scripts and background hardware services run with unconstrained privileges or missing prerequisites.

## 2. Identified Risks

### High Risk: Unsandboxed Root Services
- **Description:** `neos-driver-manager.service` runs as root and accesses hardware devices but entirely lacks systemd security directives (`ProtectSystem`, `PrivateTmp`, `NoNewPrivileges`).
- **Impact:** Any vulnerability in the python-based driver manager could lead to full system compromise. If compromised, it has write access to sensitive filesystem locations.
- **Mitigation:** Enforce stringent sandboxing within the service definition to heavily restrict what paths the process can modify.

### Medium Risk: Missing Runtime Dependency Validations
- **Description:** `neos-autoupdate.sh` heavily relies on `snapper` and requires a Btrfs filesystem to create pre/post update snapshots, but fails to verify the filesystem type before execution.
- **Impact:** If a user configures a system without Btrfs, the script will silently fail during updates, or generate noisy errors, potentially skipping vital security updates altogether.
- **Mitigation:** Implement a lightweight `findmnt` check to exit the snapshot logic gracefully if Btrfs is not detected.

### Monitored Risk: CI Pipeline
- **Description:** Following the recent size limit constraints and `pacman.conf` adjustments, the build pipeline is stable.
- **Mitigation:** Continue to monitor artifact generation times and sizes. Any failures in test validation must fail the workflow instantly.

## 3. Immediate Priorities
1. **System Hardening:** Implement systemd service sandboxing for the driver manager.
2. **Runtime Resilience:** Add filesystem dependency checks to the autoupdater.
3. **Strategic Pause:** Strict moratorium on UI/UX tweaks or new packages until core security debt is paid down.
