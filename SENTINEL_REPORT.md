# Sentinel Report - Security Fixes and Audit Findings

## Overview
This report outlines the security findings and mitigations applied based on the latest task audit (`ai/tasks/sentinel.json`).

## Vulnerability Identified
**Vulnerability Type:** Time-of-Check to Time-of-Use (TOCTOU) Race Condition
**Severity:** MEDIUM
**Target:** `airootfs/usr/local/bin/neos-autoupdate.sh`

### Description
The script `neos-autoupdate.sh` correctly implemented symmetric checks against symlink attacks and utilized `umask 077` and `set -C` to securely create its lock and log files with restrictive permissions (`0600`). However, an unnecessary `chmod 600` command was executed immediately following the secure file creation.
This introduces a TOCTOU race condition: an attacker could theoretically replace the created file with a symlink to another file (such as a sensitive system file) in the brief window between the file's creation and the execution of `chmod`. The `chmod` would then follow the symlink and incorrectly modify the permissions of the targeted file.

### Mitigation Applied
Removed the redundant `chmod 600` commands for both the log and lock files. The file creation is already intrinsically secure due to `umask 077` and `set -C`, ensuring files are created with the correct restrictive permissions atomically without subsequent modification.

## Remaining Attack Surface
The `neos-autoupdate.sh` script executes with root privileges to interact with Btrfs snapshots and Pacman.
While the log/lock file creation is secure, ensuring the integrity of the target environment and configuration files loaded during execution remains critical.

## Secondary Audit Findings (from sentinel.json)
During the audit phase, the following verifications were also addressed:

1. **`tests/verify_mirrorlist_connectivity.sh`**: The extraction logic safely handles URLs using standard Bash capabilities and `awk` parsing, validated to not execute arbitrary code or introduce injection risks. Added regex validation in `awk` explicitly ensures only HTTP(S) links are parsed.
2. **`neos-liveuser-setup` and `neos-installer-partition.sh` (traps)**: Verified the `trap` error handlers securely encapsulate `$BASH_COMMAND` within double quotes inside single-quoted strings `trap '... "$BASH_COMMAND" ...'` preventing premature expansion and injection.
3. **Documentation (`CHANGELOG.md`, `README.md`, `docs/*`)**: Audited to ensure no credentials, secrets, or internal/sensitive network paths were leaked. All URLs point to public GitHub/ArchLinux endpoints.
4. **`tests/verify_shellcheck.sh`**: Confirmed the script safely degrades using `|| true` preventing a missing dependency from halting testing environments unexpectedly.
5. **`.github/workflows/build-iso.yml`**: Validated that `python-yaml` dependency check avoids execution risks. Handled properly via CI degradation without risky dynamic package manager installations.

## Severity Summary
- **Critical:** 0
- **High:** 0
- **Medium:** 1 (TOCTOU in log/lock creation - FIXED)
- **Low:** 0

## Sentinel Security Report - CI Pipeline Resource Exhaustion

### Risks Found
- **Vulnerability**: CI Pipeline Resource Exhaustion (DoS Risk).
- **Severity**: Medium.
- **Details**: The baseline connectivity check in `tests/verify_mirrorlist_connectivity.sh` lacked a strict bounding on the overall request time. While a connection timeout was present, an established but non-responsive connection could cause the `curl` process, and consequently the CI pipeline, to hang indefinitely.

### Fixes Applied
- Added `--max-time 2` and reduced the connection timeout to `--connect-timeout 1` for the `https://archlinux.org` check. This enforces a strict execution bound, ensuring the check fails gracefully instead of hanging.

### Remaining Attack Surface
- No immediate network-related hanging risks remain in this script. However, downstream background `curl` processes also depend on accurate timeouts, which have already been verified.

### Severity Summary
- **Medium** priority issue addressed. The mitigation improves the operational resilience of the pipeline against slow or non-responsive endpoints.

## Sentinel Security Report - Live User Sudoers Provisioning

### Risks Found
- **Vulnerability**: Insecure File Permissions.
- **Severity**: Low / Enhancement.
- **Details**: `airootfs/usr/local/bin/neos-liveuser-setup` created `/etc/sudoers.d/zz-live-wheel` directly using bash redirection (`>`). This created the file with the default environmental umask (e.g., `0644`), which is less secure than the standard `0440` required for sudoers configurations.

### Fixes Applied
- Appended a direct `chmod 0440 /etc/sudoers.d/zz-live-wheel` command after creation to strictly enforce the correct least-privilege permissions without suppressing native error handling.

### Remaining Attack Surface
- Minimal. The directory `/etc/sudoers.d/` is owned by root, preventing unauthorized symlink planting (mitigating TOCTOU).

### Severity Summary
- **Low** priority enhancement applied successfully to enforce `sudo` best practices.

## Sentinel Report - Error Handler Readability & Robustness Enhancement

### Risks Found
- **Low / Enhancement**: `airootfs/usr/local/bin/neos-liveuser-setup` utilized an inline string for its `ERR` trap which made the code dense and difficult to maintain. Furthermore, passing `$BASH_COMMAND` directly into the trap evaluation string, while technically safe in standard Bash due to late binding inside double quotes, is an anti-pattern. Best practices dictate avoiding the evaluation of dynamic variables inside trap definition strings to ensure maximum robustness across execution environments.

### Fixes Applied
- Extracted trap logic in `neos-liveuser-setup` into a dedicated, readable `_error_handler` function.
- Refactored `_error_handler` in both `neos-liveuser-setup` and `neos-installer-partition.sh` to capture `$BASH_COMMAND` safely within the handler's local scope natively, rather than passing it via the trap evaluation string.

### Remaining Attack Surface
- None regarding these specific handlers. Administrative scripts are now cleaner and follow robust trap best practices.

### Severity Summary
- Severity: LOW (Enhancement)
- Impact: Improved code readability, maintainability, and alignment with robust Bash scripting practices.

## Sentinel Security Report - Autoupdate Service DoS

### Risks Found
- **Vulnerability**: Functional Denial-of-Service (DoS) in System Updates.
- **Severity**: High.
- **Details**: The `neos-autoupdate.service` systemd unit contained `ProtectSystem=strict`. While this is a common sandboxing practice, applying it to a service responsible for running package managers (`pacman -Syu`) fundamentally breaks system updates by mounting `/usr` and `/var` as read-only. This results in a functional DoS masquerading as a security enhancement.

### Fixes Applied
- Removed `ProtectSystem=strict` from `airootfs/etc/systemd/system/neos-autoupdate.service` to restore the update functionality while maintaining other relevant sandboxing directives.

### Remaining Attack Surface
- The service inherently requires broad system access to perform updates, but other sandboxing measures like `NoNewPrivileges` and `PrivateTmp` remain active to limit unnecessary exposure.

### Severity Summary
- **High** priority issue addressed. The fix prevents the update mechanism from failing securely but non-functionally.
