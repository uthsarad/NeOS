# NeOS Risk & Priority Report

## Current Risk Assessment
The immediate technical blockers (unreachable mirrors, ISO size limits) have been mitigated, stabilizing the build pipeline. The most prominent current risk is "documentation debt" — the lack of formal records explaining the 'why' behind critical architectural choices.

### Impact
- **Severity:** Medium (hinders contributor onboarding and risks architectural drift over time).
- **Probability:** High (without documentation, institutional knowledge is lost rapidly).

## Mitigation Strategy
1. **Immediate Mitigation:** Create a consolidated Architecture Decision Record (ADR) to formally document the core foundation choices (e.g., `linux-lts`, Btrfs, Calamares).
2. **Short-Term Hardening:** Ensure the ADR directory is linked from the main README so it is easily discoverable by new developers.
3. **Long-Term Consideration:** Establish a policy that any future major architectural shifts must be preceded by a formal ADR.
