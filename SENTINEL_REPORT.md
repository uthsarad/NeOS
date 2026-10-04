# Sentinel Report

## Risks Found
- **MITM Risk:** GPG keys were being fetched over unencrypted HTTP (default behavior without protocol prefix), exposing the connection to Man-in-the-Middle (MITM) attacks where attackers could intercept and modify key data.
- **Missing Global Umask:** `neos-autoupdate.sh` lacked a global restrictive `umask`, potentially allowing permissive file creation if temporary files were not explicitly managed with isolated `umask` configurations.

## Fixes Applied
- Prefixed keyserver domains with `hkps://` in `build.sh` to enforce TLS encryption during network transit.
- Added `umask 077` at the top of `neos-autoupdate.sh` to enforce restrictive defaults for the entire script's lifecycle.
- Removed redundant localized `umask 077` calls within subshells for `$LOG_FILE` and `$LOCK_FILE` creation.

## Remaining Attack Surface
- Systemd timer configurations should still be reviewed to ensure the script itself is executed within a well-sandboxed environment.
- Any future helper scripts invoked by `neos-autoupdate.sh` must explicitly manage their own `umask` or inherit the restrictive environment.

## Severity Summary
- **Severity:** Medium
- The risk is mitigated globally, removing isolated TOCTOU windows during temporary file and lock creations.

### Audit neos-autoupdate.sh for input sanitization and secure temporary file handling.
**Vulnerability:** Weak protocol configurations for `curl` during system build could permit protocol downgrade attacks (e.g., from HTTPS to HTTP or FTP) or malicious redirects, leading to potential supply chain or SSRF vulnerabilities.
**Learning:** External network calls fetching critical assets like package keyrings must proactively restrict allowed protocols and enforce modern TLS standards.
**Prevention:** Always append `--proto '=https' --tlsv1.2` to `curl` configurations when fetching sensitive assets to eliminate downgrade risks.

## Audit neos-autoupdate.sh for input sanitization and secure temporary file handling.
**Vulnerability:** Redundant `chown`/`chmod` commands executed on newly created files in predictable locations created Time-of-Check to Time-of-Use (TOCTOU) windows where symlink redirection could occur. Input parameters from external binaries (`loginctl`, `snapper`) were passed into subsequent subprocess execution environments (`sudo`, subshell interpolations) without explicit input sanitization boundaries, exposing potential argument/command injection vulnerabilities if the external dependencies returned malformed or crafted outputs.
**Learning:** Enforcing restrictive `umask 077` makes sequential file-mode adjustments superfluous and actively dangerous due to symlink traversal by default coreutils implementations. Subprocess boundaries require strict environment variable scoping (`env`) and explicit option terminators (`--`) to prevent input-driven flag injection.
**Prevention:** Remove redundant permission operations when safe defaults are active. Implement whitelist character filtering on all outputs derived from external state prior to subsequent reuse. Use `--` uniformly in execution wrappers like `sudo`.

## Sentinel: Ensure pkexec execution of neos-autoupdate.sh cannot be bypassed or injected.
**Vulnerability:** The `pkexec` invocations in `neos-operations-hub` for `snapper rollback` and `neos-autoupdate.sh` did not explicitly disable the internal polkit agent, potentially allowing local attackers to bypass standard graphical authentication prompts by injecting CLI polkit agents. Additionally, `dbus-send` dynamically parsed DBUS_REF parameters from `kdialog` without validation, exposing command injection vectors if the output contained crafted strings with spaces or semicolons.
**Learning:** `pkexec` must always be restricted in GUI scripts to prevent command-line agent hijacking. Complex strings parsed from graphical components must be strictly regex-validated before being interpolated into unquoted execution paths like `dbus-send`.
**Prevention:** Always append `--disable-internal-agent` when invoking `pkexec` from UI wrappers. Use strict regex pattern matching (`grep -Eq` or `[[ =~ ]]`) and explicit quotes when decomposing external strings for DBUS commands.

## Audit the use of pkexec and input validation in the new Operations Hub update and rollback flows to ensure they cannot be bypassed or injected.
- Replaced external grep/awk parsing with native Bash regex to prevent injection in DBUS_REF variables.
