# Risk & Priority Report

## Current System Risks
1. **Systemd Service Privilege Escalation (High Risk):** As identified in the `DEEP_AUDIT.md`, custom systemd services (`neos-autoupdate`, `neos-driver-manager`, `neos-liveuser-setup`) currently operate without strict sandboxing protections. If any underlying script is compromised or behaves unpredictably, it has broad access to the filesystem and system state, potentially compromising the host.

## Mitigations
- **Immediate Action:** The Architect is directed to implement `ProtectSystem=strict`, `ProtectHome=yes`, `PrivateTmp=yes`, `NoNewPrivileges=yes`, `ProtectKernelTunables=yes`, and `RestrictRealtime=yes` across all custom `.service` files located in `airootfs/etc/systemd/system/`.

## Priority
Address the High-Priority Systemd Sandboxing issue to stabilize the core architecture before pursuing further UX or Application enhancements in the roadmap. This is a purely stabilization/hardening run.