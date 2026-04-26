# Strategic Directive

**Focus:** Production Stability and Feature Finalization
**Objective:** Maintain high-fidelity desktop experience while ensuring reliable automated delivery.

**Directives for Automated Workflows:**
- **Active Development Phase**: The Strategic Pause is formally concluded. All automated agents are authorized to perform core modifications within the `profile/` directory.
- **Resource Management**: Maintain a strict ISO size threshold of 2GB for all x86_64 builds.
- **Security Compliance**: Ensure all modifications are audited by security (Sentinel) and performance (Bolt) agents before integration.

**Current Priorities:**
1. Monitor GitHub Actions for consistent release artifact generation.
2. Refine GPU detection logic in `neos-driver-manager`.
3. Optimize partitioning feedback for improved user experience.
