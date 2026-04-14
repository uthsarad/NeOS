# RISK REPORT

## 1. Silent Failures due to Missing Dependencies
- **Risk Level:** High
- **Description:** As identified in `docs/AUDIT_ACTION_PLAN.md`, if `snapper` is removed or the root filesystem is not Btrfs, the autoupdate script may fail silently or cause undefined behavior.
- **Mitigation:** Implement dependency validation in `airootfs/usr/local/bin/neos-autoupdate.sh`.

## 2. ISO Size Constraints
- **Risk Level:** Low
- **Description:** The ISO build process has a hard limit of 2 GiB for GitHub Releases.
- **Mitigation:** Continuous monitoring to ensure updates do not unnecessarily inflate the ISO size.
