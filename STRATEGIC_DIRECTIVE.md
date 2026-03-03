# STRATEGIC DIRECTIVE ✒️

**Date:** 2026-03-03
**Phase:** 1 - Stabilization & Build Reliability
**Primary Focus:** System Hardening and Service Sandboxing

## 1. Product Alignment Check
The NeOS mission prioritizes a stable, predictable rolling release model and a reliable staging pipeline. With the build pipeline now unblocked and ISO artifact sizes properly constrained, our next highest leverage problem is runtime system stability and security. Currently, several core services and background scripts run with unsandboxed root privileges and lack necessary system dependencies before execution. This misalignment with our reliability goals exposes the system to unnecessary risk and silent failures.

## 2. Technical Posture Review
The system is currently stable enough to produce artifacts, but our technical debt in systemd service definitions is high. Crucial custom services like `neos-driver-manager.service` are running as root without any systemd privilege restrictions (e.g., `ProtectSystem`, `PrivateTmp`). Furthermore, our automated update scripts (`neos-autoupdate.sh`) lack basic validation to ensure the root filesystem is Btrfs, risking silent execution failures if dependencies are removed post-install. We are not overbuilding; we are missing fundamental guardrails.

## 3. Priority Selection
**Selection: Stabilization / hardening**

We will continue the strategic pause on new feature development. The focus shifts entirely to hardening the existing infrastructure. Implementing proper systemd sandboxing and dependency checks will significantly reduce the attack surface and prevent critical runtime failures.

## 4. Controlled Scope Definition
The Architect is tasked with a highly constrained deliverable: **Service Hardening and Runtime Validation**.

### Exact Files Impacted:
- `airootfs/etc/systemd/system/neos-driver-manager.service`
- `airootfs/usr/local/bin/neos-autoupdate.sh`

### Maximum Allowed Surface Area:
- Creation of `neos-driver-manager.service` to apply `ProtectSystem=full`, `ProtectHome=yes`, `PrivateTmp=yes`, and `NoNewPrivileges=yes`.
- Addition of a Btrfs filesystem check in `neos-autoupdate.sh` to ensure `snapper` operates correctly.

### Constraints Architect Must Obey:
- **STRICT PROHIBITION:** Do NOT modify other systemd services or scripts outside the specified scope.
- Ensure the Btrfs check in `neos-autoupdate.sh` exits gracefully (exit 0) if the filesystem is not Btrfs, as documented in the audit.
- Do not introduce new dependencies; utilize existing tools (e.g., `findmnt`).

## 5. Delegation Strategy
- **Architect:** Implement the systemd sandboxing rules and the Btrfs filesystem check.
- **Bolt (Performance):** Ensure the Btrfs check (`findmnt`) is executed efficiently without introducing noticeable delays to the update process.
- **Palette (UX):** Ensure any warning messages regarding the disabled snapshots (due to non-Btrfs filesystems) are clear and actionable if surfaced to the user.
- **Sentinel (Security):** Audit the newly applied systemd directives to verify they effectively sandbox the driver manager without breaking its core functionality (PCI access).
