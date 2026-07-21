## 2024-07-19 - Systemd Sandboxing Constraints
**Vulnerability:** Incomplete sandboxing on critical systemd services (neos-autoupdate.service and neos-liveuser-setup.service).
**Learning:** Sandboxing for services that perform system-level account creation (`neos-liveuser-setup.service`) must be handled carefully, as directives like `ProtectSystem=strict` and `ProtectHome=yes` break essential functionality like user creation and live boot autologin.
**Prevention:** Always audit the specific functional requirements of a systemd service before applying blanket sandboxing directives.

## 2026-02-18 - Prevent sub-directory symlink traversal in root scripts
**Vulnerability:** Symlink traversal (CWE-59) in root-owned `neos-liveuser-setup` writing to user-controlled subdirectories (`.config`, `Desktop`).
**Learning:** Checking the parent directory (`$LIVE_USER_HOME`) for symlinks is insufficient if the script later creates and writes to subdirectories that an attacker could pre-create as symlinks.
**Prevention:** Always explicitly check the specific target directories for symlinks (e.g., `if [[ -L "$DIR" ]]; then exit 1; fi`) immediately prior to creation or writing.
