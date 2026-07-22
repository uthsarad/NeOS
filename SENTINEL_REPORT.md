# Sentinel Security Report

### Risks found
Identified multiple symlink traversal vulnerabilities (CWE-59) in `neos-liveuser-setup`. The script runs as root and modifies or creates files inside the user-controlled `/home/liveuser` directory (`welcome-neos.desktop`, `kwinrc`, `kdeglobals`) as well as `/etc/sddm.conf.d/autologin.conf` without explicitly verifying they are not symlinks first. A malicious user could pre-create symlinks pointing to critical system files, causing the root process to overwrite them or grant unauthorized access.

### Fixes applied
Patched `profile/airootfs/usr/local/bin/neos-liveuser-setup` to add strict `[ -L ]` symlink checks for `welcome-neos.desktop`, `autologin.conf`, `kwinrc`, and `kdeglobals` before any `chmod`, `sed`, or file write operations occur. The script now aborts securely if a symlink is detected.

### Remaining attack surface
The remaining `.service` files and `xdg` configuration files have been audited and found to not introduce new escalation paths or unintended execution vectors. The attack surface for root file creation in user-controlled spaces has been mitigated in this script.

### Severity summary
- **Severity**: CRITICAL
- **Vulnerability**: Symlink Traversal (CWE-59)
- **Status**: Fixed
