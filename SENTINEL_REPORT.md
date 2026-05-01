# Sentinel Security Report

## Risks Found
- Potential path hijacking vulnerabilities in system scripts (`neos-driver-manager`, `neos-installer-partition.sh`) due to implicit path resolution.
- Potential log injection or command manipulation in `neos-installer-partition.sh` if `$0` is spoofed and injected into the `logger -t` parameter.

## Fixes Applied
- Enforced a strict and secure `PATH` at the beginning of `neos-driver-manager` and `neos-installer-partition.sh`.
- Added input sanitization for `$SCRIPT_NAME` in `neos-installer-partition.sh` to strip non-alphanumeric characters, ensuring safe parameter expansion in `logger`.

## Remaining Attack Surface
- System logging still trusts local commands, but is mitigated by tag sanitization.

## Severity Summary
- Path Hijacking: Medium
- Log Injection: Low

## Security Issue: Log Spoofing / Injection in Partitioning Script
**Risk Classification:** Low
**Finding:** The `neos-installer-partition.sh` script previously sanitized the script name by stripping dots (`.`), which caused the logged script name to be altered (e.g., `neos-installer-partitionsh`). Also, `BASH_COMMAND` was logged without sanitization, presenting a risk of log spoofing or injection from newlines or control characters.
**Fix:** Modified the `tr` command for the script name sanitization to allow dots (`tr -cd 'a-zA-Z0-9_.-'`). Added sanitization for `BASH_COMMAND` (`tr -cd '[:print:]'`) before assigning it to the `cmd` variable to strip control characters and newlines.
**Remaining Attack Surface:** The script relies on `/proc/mounts` and basic `lsblk` checks which are prone to TOCTOU. These should be strengthened in future updates.

## Security Issue: Predictable Temporary File Path TOCTOU in Partitioning Script
**Risk Classification:** High
**Finding:** The `neos-installer-partition.sh` script wrote progress milestones to a predictable path `/tmp/neos-partition-progress`. This exposed the system to a Time-of-Check to Time-of-Use (TOCTOU) symlink vulnerability where a local attacker could pre-create a symlink to overwrite arbitrary system files when the script runs as root.
**Fix:** Replaced the predictable `/tmp` path with `/run/neos-partition-progress`. `/run` is typically mounted as a tmpfs and requires root privileges to write to the base directory, mitigating the symlink attack vector.
**Remaining Attack Surface:** The script still relies on basic `/proc/mounts` and `lsblk` checks which are inherently prone to other minor TOCTOU race conditions during device operations.
