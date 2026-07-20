## 2024-07-19 - Systemd Sandboxing Constraints
**Vulnerability:** Incomplete sandboxing on critical systemd services (neos-autoupdate.service and neos-liveuser-setup.service).
**Learning:** Sandboxing for services that perform system-level account creation (`neos-liveuser-setup.service`) must be handled carefully, as directives like `ProtectSystem=strict` and `ProtectHome=yes` break essential functionality like user creation and live boot autologin.
**Prevention:** Always audit the specific functional requirements of a systemd service before applying blanket sandboxing directives.
## 2026-02-18 - Symlink Traversal in Live Environment Setup
**Vulnerability:** Symlink traversal (CWE-59) vulnerabilities in `neos-liveuser-setup` where subdirectories (`.config`, `Desktop`) and configuration files were created without checking if they were symlinks.
**Learning:** Even root-level setup scripts running early in the boot process can be vulnerable to symlink attacks if they operate on paths within user-controlled directories like `/home`.
**Prevention:** Always use `[[ -L ]]` to verify paths are not symlinks before operating on them, and precede file writes with `rm -f` to break potential symlink chains when creating new files.
