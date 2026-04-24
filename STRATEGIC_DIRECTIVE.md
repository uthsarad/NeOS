# Strategic Directive

**Focus:** Stabilization and Hardening of Installation Scripts
**Objective:** Improve error handling and system resilience in core installation paths prior to further feature development.
**Directives for Architect:**
- Prioritize hardening of `airootfs/usr/local/bin/neos-liveuser-setup` and `airootfs/usr/local/bin/neos-installer-partition.sh`.
- Do not introduce new features or architectural changes.
- Ensure all error conditions are trapped and gracefully handled without masking exit codes.
