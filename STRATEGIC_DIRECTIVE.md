# Strategic Directive

## Objective
Finalize the "Active Hardening" phase by completing the implementation of systemd sandboxing.

## Scope
The focus is strictly on extending the systemd sandboxing directives (`ProtectSystem=strict`, `ProtectHome=yes`, `PrivateTmp=yes`, `NoNewPrivileges=yes`, `ProtectKernelTunables=yes`, `RestrictRealtime=yes`) to `neos-liveuser-setup.service` and `neos-autoupdate.service`. In addition, the testing script `tests/verify_service_hardening.sh` must be updated to validate these properties across all `.service` files in `profile/airootfs/etc/systemd/system/`.

## Rationale
The previous iteration initiated systemd sandboxing but left `neos-liveuser-setup.service` and `neos-autoupdate.service` with incomplete protection. Completing this item from the AUDIT_ACTION_PLAN.md is critical to establish a secure baseline before any new feature development resumes.
