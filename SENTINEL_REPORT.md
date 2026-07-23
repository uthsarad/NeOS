# Sentinel Security Report

### Risks found
Identified multiple symlink traversal vulnerabilities (CWE-59) in `neos-liveuser-setup`. The script runs as root and modifies or creates files inside the user-controlled `/home/liveuser` directory (`welcome-neos.desktop`, `kwinrc`, `kdeglobals`) as well as `/etc/sddm.conf.d/autologin.conf` without explicitly verifying they are not symlinks first. A malicious user could pre-create symlinks pointing to critical system files, causing the root process to overwrite them or grant unauthorized access.

Identified that `neos-autoupdate.service` mounts `/run` as read-only via `ProtectSystem=strict`, but `neos-autoupdate.sh` attempts to create its lock file at `/run/neos-autoupdate.lock`, causing silent flock locking failures.
Identified that `neos-liveuser-setup.service` runs as root without any capability bounding or address family restrictions, granting unnecessarily broad capabilities beyond what is required for user creation.

### Fixes applied
Patched `profile/airootfs/usr/local/bin/neos-liveuser-setup` to add strict `[ -L ]` symlink checks for `welcome-neos.desktop`, `autologin.conf`, `kwinrc`, and `kdeglobals` before any `chmod`, `sed`, or file write operations occur. The script now aborts securely if a symlink is detected.

Appended `/run` to `ReadWritePaths` in `neos-autoupdate.service` to allow secure lock file creation in `/run`.
Added `CapabilityBoundingSet` with the minimal capabilities required for `useradd -m` (e.g., `CAP_CHOWN`, `CAP_DAC_OVERRIDE`, `CAP_FOWNER`, `CAP_FSETID`, `CAP_SETUID`, `CAP_SETGID`, `CAP_SYS_RESOURCE`, `CAP_AUDIT_WRITE`) and `RestrictAddressFamilies=AF_UNIX` to `neos-liveuser-setup.service` to enforce least privilege.

### Remaining attack surface
The remaining `.service` files and `xdg` configuration files have been audited and found to not introduce new escalation paths or unintended execution vectors. The attack surface for root file creation in user-controlled spaces has been mitigated in this script.

Autoupdate script requires execution as root, maintaining its inherent privileges.
`neos-liveuser-setup` continues to require necessary capabilities for system-level user provisioning, but its bounding set is now restricted.

### Severity summary
- **Severity**: HIGH
- **Vulnerability**: Privilege Escalation / Least Privilege Violation
- **Status**: Fixed
