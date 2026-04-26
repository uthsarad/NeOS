# Risk & Priority Report

## Current Posture
- **Stability:** Critical risk. System updates are broken due to systemd sandboxing.
- **Tech Debt:** Low.
- **Overbuilding:** High in security hardening. Excessive sandboxing in `neos-autoupdate.service` mounts `/usr` and `/var` as read-only, breaking pacman.

## Key Risks Identified
- Functional denial-of-service on system updates due to `ProtectSystem=strict` in `neos-autoupdate.service`.

## Mitigation Strategy
- Roll back `ProtectSystem=strict` in the update service.
- Prioritize functional operations over excessive security lockdowns in package managers.
