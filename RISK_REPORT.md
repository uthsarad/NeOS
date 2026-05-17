# Risk & Priority Report

## Current System State
The project is currently stable, with automated validation scripts passing. An outstanding medium-priority audit item (#7) identified a lack of proper systemd sandboxing across some root-level services. One service (`neos-driver-manager.service`) was hardened previously, but others (`neos-autoupdate.service`, `neos-liveuser-setup.service`) still need the documented sandboxing rules applied.

## Identified Risks
1. **Privilege Escalation Risk:** Root-level services without basic systemd sandboxing are vulnerable to broader system compromise if their execution path is exploited. Adding sandboxing constraints mitigates this risk.
2. **Regression Risk:** Overly strict sandboxing (like `ProtectSystem=strict`) on an auto-updater can prevent it from writing to system paths (`/usr`, `/etc`), breaking functionality. The same applies to user-setup scripts modifying `/etc/shadow` or `/home`.

## Mitigation Strategy
- Implement sandboxing directives carefully. `ProtectSystem=strict` should be avoided or overridden with specific `ReadWritePaths` for services that require write access to system directories.
- We will prioritize adding the hardening directives from `docs/AUDIT_ACTION_PLAN.md` (`ProtectSystem`, `ProtectHome`, `PrivateTmp`, `NoNewPrivileges`, `ProtectKernelTunables`, `RestrictRealtime`) while respecting the operational requirements of each service.

## Recommendation
Proceed with the hardening implementation for the remaining services to close out the audit finding, ensuring that functionality is not broken.