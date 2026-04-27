# Risk & Priority Report

## Current Risk Areas

### 1. Missing Dependency Validation (HIGH)
- **Risk:** The `neos-autoupdate.sh` script relies on `snapper` and a Btrfs filesystem. If these are missing, the update may proceed without fallback mechanisms, risking system stability.
- **Mitigation:** Implement early checks in the script to verify the presence of `snapper` and a Btrfs root filesystem.

### 2. Privilege Escalation Surface (MEDIUM)
- **Risk:** Core systemd services (`neos-autoupdate.service`, `neos-driver-manager.service`, `neos-liveuser-setup.service`) lack robust sandboxing, potentially allowing privilege escalation if exploited.
- **Mitigation:** Apply systemd sandboxing directives (`ProtectSystem=strict`, `NoNewPrivileges=yes`, `PrivateTmp=yes`, etc.) to these services where appropriate. **Note:** `ProtectSystem=strict` must not be used on `neos-autoupdate.service` to avoid breaking system updates.

### 3. Documentation Inconsistencies (MEDIUM)
- **Risk:** Missing architecture limitation warnings and outdated URLs in documentation can lead to user confusion and support burden.
- **Mitigation:** Update `README.md`, `docs/HANDBOOK.md`, and `CONTRIBUTING.md` with correct information.

## Prioritization Summary
1. Address immediate dependency gaps in autoupdate scripts.
2. Apply appropriate systemd hardening to core services without breaking functionality.
3. Resolve documentation inconsistencies.
