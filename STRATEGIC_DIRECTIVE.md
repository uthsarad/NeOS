# Strategic Directive

**Focus:** Stabilization and Hardening
**Objective:** Restore system update functionality by removing excessive sandboxing that causes denial-of-service.

**Directives for Architect:**
- Modify `airootfs/etc/systemd/system/neos-autoupdate.service`.
- Remove `ProtectSystem=strict` as it prevents `pacman -Syu` from writing to `/usr` and `/var`.
- Ensure the fix enables automatic updates to complete successfully.
- Do not modify core update logic in the bash scripts.
