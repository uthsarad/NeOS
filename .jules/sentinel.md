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

## 2026-02-18 - Symlink Traversal via Parent Directory in Autostart Scripts (CWE-59)
**Vulnerability:** Found symlink traversal vulnerabilities in `neos-desktop-setup` when making desktop launchers executable. The script ran `chmod +x` without checking if the user-controlled `Desktop` directory or the launcher file itself was a symlink.
**Learning:** Checking only the target file or neglecting symlink checks entirely in user-space setup scripts allows attackers to manipulate file permissions (e.g., via CWE-59) if they can control the parent directory.
**Prevention:** Always check both the parent directory and the target file for symlinks (`[[ -L "$DIR" ]] || [[ -L "$FILE" ]]`) before changing permissions in user-writable paths.

## 2026-02-18 - Enforce Admin Authentication for PackageKit
**Vulnerability:** Default polkit policies or absent custom rules may allow unprivileged users to perform system-wide package modifications via PackageKit (e.g., through Discover).
**Learning:** It's critical to strictly enforce `AUTH_ADMIN` for any system-level package manipulation to prevent unauthorized software installation and potential privilege escalation by standard users.
**Prevention:** Always explicitly define polkit rules for `org.freedesktop.packagekit.*` actions in customized Linux distributions to enforce strict authentication boundaries.

## 2026-02-18 - Predictable Temp File in Installer Launcher (CWE-59)
**Vulnerability:** Found a symlink traversal vulnerability (CWE-59) in `neos-welcome` caused by logging to a predictable file path (`/tmp/neos-installer.log`) in a world-writable directory.
**Learning:** Using predictable paths in world-writable directories like `/tmp` allows local attackers to pre-create symlinks pointing to sensitive files, which are then inadvertently overwritten by the script.
**Prevention:** Always use `mktemp` to securely generate temporary file names when writing to shared or world-writable directories.
