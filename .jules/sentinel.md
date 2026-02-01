# Sentinel's Journal 🛡️

This journal records security enforcement, permission structures, and integrity checks for the NeOS project.

## 2024-05-22 - Repository Security & Permissions
**Decision:** Enforce strict signature verification and filesystem permissions.
**Action:** Configured `SigLevel = Required DatabaseRequired` in `pacman.conf` to prevent tampering. Explicitly set permissions for sensitive paths (e.g., `/etc/shadow` 400, `/root` 750) in `profiledef.sh` via the `file_permissions` array.
