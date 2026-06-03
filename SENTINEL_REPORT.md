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

## Risks found
- Command injection vulnerability in `neos-autoupdate.sh` via unsanitized variables (`$title`, `$icon`, `$urgency`) passed to `su -c` in the `notify_users` function.

## Fixes applied
- Sanitized `$title`, `$icon`, and `$urgency` by stripping single quotes (`${VAR//\'/}`) before they are evaluated within the nested `su -c` string.

## Remaining attack surface
- None identified related to this fix.

## Severity summary
- High severity. Allowed potential command injection and privilege escalation to logged-in users.

## Risks found
- Missing automated security scanning in the CI pipeline to proactively detect vulnerabilities and misconfigurations.

## Fixes applied
- Added Trivy and ShellCheck scanning to `.github/workflows/build-iso.yml` before the ISO build step.

## Remaining attack surface
- None identified related to this fix.

## Severity summary
- Security enhancement. Improves defense in depth.

## Risks found
- Error masking vulnerability in script error trap handlers. Using trap '_error_handler $? $LINENO' ERR evaluates the trap action successfully, inadvertently masking the original failing error code.

## Fixes applied
- Modified the error trap in profile/airootfs/usr/local/bin/neos-installer-partition.sh and profile/airootfs/usr/local/bin/neos-liveuser-setup to explicitly capture and return the original error code.

## Remaining attack surface
- None identified related to this fix.

## Severity summary
- High severity. Allowed failed operations during installation or setup to appear successful and proceed, leading to potential inconsistent or vulnerable system states.

## Sentinel Security Report

### Risks Found
- **DOS via Unthrottled Retries:** The retry mechanism in the mirrorlist connectivity test lacked throttling, potentially causing unnecessary rapid requests (DOS risk) against failing mirrors.
- **Option Injection:** The `curl` command was missing POSIX option terminators (`--`) before variable inputs, technically allowing option injection if input validation were bypassed.

### Fixes Applied
- Added `sleep 1` before retry logic in `tests/verify_mirrorlist_connectivity.sh` to enforce a brief cooldown and prevent aggressive server hammering.
- Enforced `--` in all `curl` commands in `tests/verify_mirrorlist_connectivity.sh` to neutralize potential option injection vectors.

### Remaining Attack Surface
- Minimal. The mirrorlist inputs are strictly regex-validated by `awk` before reaching curl.

### Severity Summary
- **Severity:** LOW (Defense-in-depth / Enhancement)
