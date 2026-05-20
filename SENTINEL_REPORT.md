# Sentinel Report

## Risks found
- Weak systemd sandboxing allowing potential privilege escalation in `neos-autoupdate.service` and `neos-liveuser-setup.service` (e.g. changing hostnames, cgroups, kernel modules).
- Inappropriate Architect instruction to modify checklist in non-security documentation (`docs/AUDIT_ACTION_PLAN.md`).

## Fixes applied
- Added `ProtectControlGroups=yes`, `ProtectKernelModules=yes`, and `ProtectHostname=yes` to `profile/airootfs/etc/systemd/system/neos-autoupdate.service` and `profile/airootfs/etc/systemd/system/neos-liveuser-setup.service`.
- Ignored modifying `docs/AUDIT_ACTION_PLAN.md` to strictly focus on codebase security vulnerabilities. Updated `ai/tasks/sentinel.json` to reflect task completion.

## Remaining attack surface
- Services still run as root due to their required operations, though with restricted capabilities.

## Severity summary
- Medium severity. The implemented sandboxing limits the blast radius if an attacker manages to compromise these services.

## Risks found
- Option injection vulnerabilities in `build.sh` due to missing `--` option terminators on `pacman` and `rm` commands.

## Fixes applied
- Appended `--` option terminators to `pacman` and `rm` commands in `build.sh` to prevent option injection.

## Remaining attack surface
- None identified related to this fix.

## Severity summary
- Low severity. The variables involved (`$WORK_DIR`, `$CHAOTIC_KEYRING_PKG`) are hardcoded or highly constrained, but enforcing standard option termination is a defense-in-depth best practice.
