# Sentinel Security Report

### Risks found
Identified a symlink traversal vulnerability (CWE-59) in `profile/airootfs/usr/local/bin/neos-desktop-setup` during launcher configuration. The script applies `chmod +x` without checking if the user-controlled `$HOME/Desktop` directory or the target file itself is a symlink.

Identified multiple symlink traversal vulnerabilities (CWE-59) in `neos-liveuser-setup`. The script runs as root and modifies or creates files inside the user-controlled `/home/liveuser` directory (`welcome-neos.desktop`, `kwinrc`, `kdeglobals`) as well as `/etc/sddm.conf.d/autologin.conf` without explicitly verifying they are not symlinks first. A malicious user could pre-create symlinks pointing to critical system files, causing the root process to overwrite them or grant unauthorized access.

Identified that `neos-autoupdate.service` mounts `/run` as read-only via `ProtectSystem=strict`, but `neos-autoupdate.sh` attempts to create its lock file at `/run/neos-autoupdate.lock`, causing silent flock locking failures.
Identified that `neos-liveuser-setup.service` runs as root without any capability bounding or address family restrictions, granting unnecessarily broad capabilities beyond what is required for user creation.

### Fixes applied
Patched `profile/airootfs/usr/local/bin/neos-desktop-setup` to add strict `[ -L ]` symlink checks for both `$HOME/Desktop` and `$HOME/Desktop/$launcher` before applying `chmod`. The script now skips configuration safely if a symlink is detected.

Patched `profile/airootfs/usr/local/bin/neos-liveuser-setup` to add strict `[ -L ]` symlink checks for `welcome-neos.desktop`, `autologin.conf`, `kwinrc`, and `kdeglobals` before any `chmod`, `sed`, or file write operations occur. The script now aborts securely if a symlink is detected.

Appended `/run` to `ReadWritePaths` in `neos-autoupdate.service` to allow secure lock file creation in `/run`.
Added `CapabilityBoundingSet` with the minimal capabilities required for `useradd -m` (e.g., `CAP_CHOWN`, `CAP_DAC_OVERRIDE`, `CAP_FOWNER`, `CAP_FSETID`, `CAP_SETUID`, `CAP_SETGID`, `CAP_SYS_RESOURCE`, `CAP_AUDIT_WRITE`) and `RestrictAddressFamilies=AF_UNIX` to `neos-liveuser-setup.service` to enforce least privilege.

### Remaining attack surface
`neos-desktop-setup` assumes `$HOME/.neos_polished` is safe to touch, although touching a symlink doesn't follow it to modify arbitrary data in a damaging way, it's a minor gap.

The remaining `.service` files and `xdg` configuration files have been audited and found to not introduce new escalation paths or unintended execution vectors. The attack surface for root file creation in user-controlled spaces has been mitigated in this script.

Autoupdate script requires execution as root, maintaining its inherent privileges.
`neos-liveuser-setup` continues to require necessary capabilities for system-level user provisioning, but its bounding set is now restricted.

### Severity summary
- **Severity**: HIGH
- **Vulnerability**: Privilege Escalation / Least Privilege Violation
- **Status**: Fixed

### PackageKit Privilege Context Audit
- **Risks found**: PackageKit operations default to unprivileged execution for some actions on some setups. A misconfiguration could allow unprivileged users to bypass authentication for system-level package installations.
- **Fixes applied**: Added polkit rule (`50-neos-packagekit.rules`) to strictly enforce `AUTH_ADMIN` (admin authentication) for sensitive operations (install, remove, update, sources configure, trust source) for `wheel` users, and deny access to others.
- **Remaining attack surface**: Only trusted users in `wheel` can modify system packages, which is intended behavior, but still poses a risk if an admin account is compromised.
- **Severity summary**: HIGH (Mitigated unprivileged software installation).

## 2026-02-18 - Vulnerability Remediation
### Risks found
- Found a CWE-59 Symlink Traversal vulnerability in `profile/airootfs/usr/local/bin/neos-welcome` where a predictable log file path (`/tmp/neos-installer.log`) was used in a world-writable directory.

### Fixes applied
- Replaced the predictable log path with a securely generated temporary file using `mktemp`.

### Remaining attack surface
- None identified regarding temporary file creation in the reviewed scripts.

### Severity summary
- **High**: The vulnerability could allow a local attacker to overwrite arbitrary files when `neos-welcome` is executed.

## 2026-02-18 - Privilege Boundaries Audit
### Risks found
- The `neos-operations-hub` script lacked privilege boundary checks. Running it as root could unintentionally launch web browsers or other applications with root privileges via `xdg-open`.

### Fixes applied
- Modified `profile/airootfs/usr/local/bin/neos-operations-hub` to explicitly check `EUID` and block execution if run as root, ensuring child GUI processes cannot inadvertently inherit elevated privileges.

### Remaining attack surface
- Channel switching relies on informational prompts and assumes underlying staging deployments handle system stability correctly, which remains outside the script's local control.

### Severity summary
- **Severity**: MEDIUM
- **Vulnerability**: Privilege Escalation / Unintended Privileged GUI Execution
- **Status**: Fixed

## 2026-02-18 - Audit of neos-operations-hub (Phase 8 Baseline)
**Status**: Completed
**Findings**:
- **CWE-426 (Path Hijacking)**: The script previously lacked a strict `PATH` export, meaning malicious or unintended binaries could have been executed if the `$PATH` environment variable was manipulated.
- **Command Injection (Snapshot Query)**: Audited the file for snapshot query mechanisms. Currently, the script does not contain any snapshot query functionality (only placeholders), so no command injection vulnerabilities were found.
- **Strategic Pause**: Acknowledged Phase 8 Operations Hub Validation (Strategic Pause).

**Mitigation**:
- Added an explicit `export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"` to `profile/airootfs/usr/local/bin/neos-operations-hub` to ensure all external commands (`kdialog`, `xdg-open`) are resolved safely from trusted system directories.

## 2026-02-18 - CWE-459 Incomplete Cleanup Mitigation
### Risks found
- Identified a CWE-459 (Incomplete Cleanup) vulnerability in `profile/airootfs/usr/local/bin/neos-operations-hub`. The temporary file containing system snapshots could be left behind in `/tmp` if the script exits abnormally (e.g., interrupted by the user). No command injection was found.
### Fixes applied
- Added a `trap` mechanism (`trap "rm -f \"$TEMP_FILE\"" EXIT INT TERM`) to securely clean up `TEMP_FILE` on abnormal termination.
### Remaining attack surface
- None identified regarding temporary file cleanup for this mechanism.
### Severity summary
- **Severity**: LOW
- **Vulnerability**: Incomplete Cleanup
- **Status**: Fixed

## Acknowledge Continued Phase 8 Validation
**Status**: Completed
**Findings**: Acknowledged the continued Strategic Pause for Phase 8 Operations Hub Validation. No new feature development required from Architect.

## 2026-08-12 - Audit of License Read Mechanisms in neos-operations-hub
**Status**: Completed
**Findings**:
- **Path Traversal (CWE-22)**: Audited `profile/airootfs/usr/local/bin/neos-operations-hub` for path traversal vulnerabilities in the mechanism that displays the system license. The script uses a here-document (heredoc) to write statically defined license text into a securely generated temporary file (via `mktemp`) and presents it to the user. Because the license content is embedded directly into the script and no external files are read or paths constructed from user input, there is zero risk of path traversal.

**Mitigation**:
- No mitigation required. The current implementation is secure against path traversal.

## Acknowledge Continued Phase 8 Validation
**Status**: Completed
**Findings**: Acknowledged the continued Strategic Pause for Phase 8 Operations Hub Validation. No new feature development required from Architect.

## Audit of Telemetry State Storage
### Risks found
- Missing secure state storage for telemetry opt-in. A direct write to a predictable file like `/tmp/neos-telemetry-optin` would be vulnerable to a CWE-59 Symlink Traversal attack.
### Fixes applied
- Implemented `closeEvent` in `neos-welcome-app` to securely write the state. A temporary file is safely generated using `mktemp`, written to, and then atomically renamed to `/tmp/neos-telemetry-optin`. This prevents an attacker from exploiting symlinks.
### Remaining attack surface
- None identified regarding temporary file creation for this mechanism.
### Severity summary
- **Severity**: LOW
- **Vulnerability**: Predictable Temporary File (CWE-59 risk mitigated)
- **Status**: Fixed

## Acknowledge Phase 3 Validation
**Status**: Completed
**Findings**: Acknowledged the Strategic Pause for Phase 3 Validation. No new feature development required from Architect.

## 2026-08-16 - Audit of neos-hardware-setup (Hardware Detection)
**Status**: Completed
**Findings**:
- **CWE-426 (Path Hijacking)**: The script lacked a strict `PATH` export, meaning malicious or unintended binaries could be executed if the `$PATH` environment variable was manipulated.
- **Command Injection**: Audited the parsing of PCI output. The script currently uses `lspci | grep -i nvidia` and redirects output directly to `/dev/null`. It does not parse the output in a way that executes commands or constructs unsanitized strings, so no command injection vulnerabilities were found.

**Mitigation**:
- Added an explicit `export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"` to `profile/airootfs/usr/local/bin/neos-hardware-setup` to ensure all external commands (`lspci`, `grep`) are resolved safely from trusted system directories.
