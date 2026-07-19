## Sentinel Report

### Risks found
- Incomplete sandboxing on `neos-autoupdate.service` (e.g., `ProtectHome=read-only` instead of `yes`, missing kernel/cgroup protection).
- Missing safe sandboxing directives on `neos-liveuser-setup.service`.

### Fixes applied
- Updated `neos-autoupdate.service` to use `ProtectHome=yes`, `ProtectKernelTunables=yes`, and `ProtectControlGroups=yes`.
- Added safe sandboxing directives (`ProtectKernelTunables=yes`, `ProtectControlGroups=yes`, `ProtectHostname=yes`, `RestrictRealtime=yes`, `LockPersonality=yes`) to `neos-liveuser-setup.service`.

### Remaining attack surface
- `neos-liveuser-setup.service` still runs with significant privileges (no `ProtectSystem`, `ProtectHome`, `PrivateTmp`, or `NoNewPrivileges`) due to functional requirements for system-level account creation.

### Severity summary
- Medium/Low priority enhancements applied to strengthen defense-in-depth through systemd sandboxing.
