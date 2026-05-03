

## 2024-03-27 - Command Injection Risk in Trap Error Handlers
**Vulnerability:** Bash scripts used the subshell `$(basename "$0")` within a dynamically evaluated error trap (`trap 'logger -t neos-$(basename "$0") ...' ERR`), allowing arbitrary command execution if an attacker manipulated the script filename (e.g., executing a hardlink named `$(id).sh`). Furthermore, successful execution of `logger` inadvertently masked the script's failing exit status.
**Learning:** Evaluating variables with unescaped shell commands inside dynamically evaluated strings (like traps) introduces severe injection points. Error traps also inherently run as the final statement, overriding the original command's failure status if not explicitly handled.
**Prevention:** Avoid subshells and prefer native string manipulation for variable substitution. Explicitly capture `$?` at the start of the trap and `exit $status` at the end to guarantee error preservation. Use `trap 'status=$?; logger -t "neos-${0##*/}" ...; exit $status' ERR`. Always sanitize test environments and wipe temporary files like `$(id).sh` or `test_*.sh` created during vulnerability validation before committing code.
## 2024-05-01 - Predictable Temporary File Path TOCTOU
**Vulnerability:** The installer partitioning script `neos-installer-partition.sh` wrote progress milestones to `/tmp/neos-partition-progress`. Since `/tmp` is a world-writable directory (sticky bit), an attacker could preemptively create a symlink at this path pointing to a sensitive file (e.g., `/etc/passwd`). When the script, running as root, attempts to write to the progress file, it would follow the symlink and overwrite the sensitive file.
**Learning:** Writing to predictable paths in world-writable directories introduces critical Time-of-Check to Time-of-Use (TOCTOU) symlink vulnerabilities, especially for scripts running with elevated privileges.
**Prevention:** Strictly avoid writing temporary progress or state files to predictable paths in world-writable directories like `/tmp`. Instead, write to secure mounts like `/run` (which is typically only accessible by root/system users for writing) or dynamically generate unique paths using `mktemp`.
## 2024-05-03 - Systemd Sandboxing Breaks Update Functionality
**Vulnerability:** Applying `ProtectSystem=strict` in systemd service units that run package managers (e.g., `pacman -Syu` in `neos-autoupdate.service`) breaks system updates by mounting `/usr` and `/var` as read-only. This results in a functional denial-of-service masquerading as security hardening.
**Learning:** Security sandboxing rules must be carefully aligned with the functional requirements of the service. Overly restrictive configurations on a service modifying the OS root will result in a functional denial-of-service.
**Prevention:** Carefully review systemd directives against the actual behavior of the script. Avoid applying `ProtectSystem=strict` to update utilities.
## 2024-05-03 - Terminal Control Injection via echo -e
**Vulnerability:** Outputting unsanitized variables directly using `echo -e "$VAR"` allows an attacker to inject ANSI escape codes or control characters if they control the variable contents. This can lead to terminal disruption or log spoofing.
**Learning:** Commands like `echo` or `echo -e` are unsafe for dynamic content.
**Prevention:** Always use `printf "%s\n" "$VAR"` to safely output variable contents containing arbitrary data.
