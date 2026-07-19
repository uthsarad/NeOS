## 2024-07-19 - Systemd Sandboxing Constraints
**Vulnerability:** Incomplete sandboxing on critical systemd services (neos-autoupdate.service and neos-liveuser-setup.service).
**Learning:** Sandboxing for services that perform system-level account creation (`neos-liveuser-setup.service`) must be handled carefully, as directives like `ProtectSystem=strict` and `ProtectHome=yes` break essential functionality like user creation and live boot autologin.
**Prevention:** Always audit the specific functional requirements of a systemd service before applying blanket sandboxing directives.
