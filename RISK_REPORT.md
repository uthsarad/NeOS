# Risk & Priority Report

## Current Risk Assessment
The system remains in the "Active Hardening" phase. Core services like `neos-liveuser-setup.service` and `neos-autoupdate.service` lack complete systemd sandboxing directives (e.g., missing `ProtectSystem=strict`, `NoNewPrivileges=yes`, and `ProtectHome=yes`).

**Identified Risks:**
1. **Incomplete Sandboxing:** Unhardened services could be leveraged to gain unauthorized system access or modify protected filesystem areas.
2. **Test Coverage Gap:** The current `verify_service_hardening.sh` only tests `neos-driver-manager.service`, creating a false sense of security for other services.

## Priority Selection
**Stabilization / Hardening**

The immediate priority is to finalize the implementation of systemd sandboxing for all services and update our verification tests to cover all `.service` files.

## Actionable Mitigation
- Architect must strictly limit scope to implementing sandboxing in `.service` files and updating the corresponding verification test.
- Sentinel must review the test changes to ensure proper security assertions are being made.
