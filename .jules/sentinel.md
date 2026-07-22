## 2024-07-19 - Systemd Sandboxing Constraints
**Vulnerability:** Incomplete sandboxing on critical systemd services (neos-autoupdate.service and neos-liveuser-setup.service).
**Learning:** Sandboxing for services that perform system-level account creation (`neos-liveuser-setup.service`) must be handled carefully, as directives like `ProtectSystem=strict` and `ProtectHome=yes` break essential functionality like user creation and live boot autologin.
**Prevention:** Always audit the specific functional requirements of a systemd service before applying blanket sandboxing directives.

## 2026-02-18 - Prevent sub-directory symlink traversal in root scripts
**Vulnerability:** Symlink traversal (CWE-59) in root-owned `neos-liveuser-setup` writing to user-controlled subdirectories (`.config`, `Desktop`).
**Learning:** Checking the parent directory (`$LIVE_USER_HOME`) for symlinks is insufficient if the script later creates and writes to subdirectories that an attacker could pre-create as symlinks.
**Prevention:** Always explicitly check the specific target directories for symlinks (e.g., `if [[ -L "$DIR" ]]; then exit 1; fi`) immediately prior to creation or writing.
## 2026-02-18 - Symlink Traversal in Root Scripts
**Vulnerability:** Found symlink traversal vulnerabilities in `neos-liveuser-setup` where root modified files in a user-controlled directory without checking if they were symlinks.
**Learning:** Checking only the parent directory (`.config` or `Desktop`) for symlinks is insufficient if the target files themselves (`kwinrc`, `welcome-neos.desktop`) are not also checked before modification or creation by a privileged process.
**Prevention:** Always verify both the parent directory and the specific target file are not symlinks (`[ -L ]`) immediately before executing file writes or permission changes on paths that are user-accessible.
