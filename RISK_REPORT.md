# NeOS Risk & Priority Report

## Current Risk Assessment
The most immediate risk to the NeOS project is the fragility of the build pipeline due to external dependencies. Specifically, a single offline or unreachable mirror (`https://ftpmirror.infania.net/mirror/archlinux/`) causes the `verify_mirrorlist_connectivity.sh` check to fail, completely blocking the generation of new ISO artifacts.

### Impact
- **Severity:** High (blocks all builds and CI progression)
- **Probability:** High (mirrors frequently experience downtime or deprecation)

## Mitigation Strategy
1. **Immediate Mitigation:** Remove the explicitly failing mirror from the default `neos-mirrorlist` to restore a green build state.
2. **Short-Term Hardening:** Ensure the connectivity test has strict timeout bounds (handled by Bolt) to prevent pipeline hangs, and provide actionable error output (handled by Palette).
3. **Long-Term Consideration:** Implement a more robust mirror ranking and fallback system during the ISO build process to tolerate individual mirror failures without requiring manual intervention in the configuration files.
