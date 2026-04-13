# Sentinel Report

## 🚨 Risks Found
- **Vulnerability:** Exit Code Masking in `ERR` trap handlers.
- **Location:** `airootfs/usr/local/bin/neos-liveuser-setup` and `airootfs/usr/local/bin/neos-installer-partition.sh`.
- **Description:** The `ERR` traps in these critical setup scripts execute `echo` and `logger` to record failures before explicitly calling `exit $err`. Under `set -e` conditions, if the `logger` command fails (e.g., if `systemd-journald` is unavailable or crashes), the script immediately aborts with the `logger`'s non-zero exit code (such as `127` or `1`). This completely masks the original `$err` code of the command that initially failed, potentially causing misinterpretation of the failure by calling automation or systemd.

## 🔧 Fixes Applied
- Appended `|| true` to the `echo` and `logger` commands inside the `ERR` traps in both files.
- This ensures that logging operations degrade gracefully without prematurely terminating the trap, guaranteeing that the final `exit $err` command is always reached and the true failure code is correctly returned.

## 🛡️ Remaining Attack Surface
- Systemd sandboxing directives (`ProtectSystem=strict`) on critical setup scripts (`neos-liveuser-setup.service` and `neos-autoupdate.service`) currently cause functional regressions because they prevent necessary file writes (e.g., to `/etc/sudoers.d/` and system updates). While strict sandboxing limits attack surface, resolving these regressions safely may require adjusting sandboxing policies or file paths in a future update to balance security and functionality.
- The `airootfs/etc/sudoers.d/zz-live-wheel` file created dynamically during live-user setup uses the default umask (resulting in `0644` permissions) rather than the restricted `0440` required for strict `sudo` security, though `sudo` may still parse it depending on the environment.

## 📊 Severity Summary
- **Severity:** Medium
- **Impact:** Misleading diagnostics and potential pipeline/systemd control flow issues due to masked error codes.
