# Strategic Directive

**Focus:** Feature Completion and Distribution
**Objective:** Finalize the NeOS Desktop experience and ensure reliable distribution via GitHub Releases.

**Directives for Architect:**
- **ACTIVE DEVELOPMENT**: The "Strategic Pause" is concluded. All specialists are cleared for active modifications to core scripts.
- **Maintain Size**: Keep the x86_64 ISO under 2GB to ensure GitHub Release compatibility.
- **Installer Polish**: Ensure the Calamares installer experience is seamless and matches the "Windows-familiar" design goals.
- **Audit Compliance**: All new features must still be verified by Bolt (Performance), Palette (UX), and Sentinel (Security).

**Current Priorities:**
1. Monitor CI for successful ISO builds and Releases.
2. Refine `neos-driver-manager` logic for GPU detection.
3. Enhance `neos-installer-partition.sh` with more informative progress bars.
