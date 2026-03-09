# Risk & Priority Report

## Current System Risk
**Medium**. While functional, the system's testing pipeline lacks automated execution, leaving room for regressions to slip into the main branch unseen. Specific test scripts, such as `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh`, do not currently implement timeout wrappers. This is a significant risk as these tests could hang indefinitely during automated CI execution if they encounter unexpected states, thereby blocking the entire deployment pipeline.

## Tech Debt Assessment
The repository suffers from technical debt in its CI/CD and testing infrastructure:
1. **No Automated Testing in CI:** The `.github/workflows/build-iso.yml` workflow lacks a comprehensive pre-build validation step. Tests should execute before the ISO build to catch failures early, but currently, they are either missing or not correctly sequenced.
2. **Missing Timeout Wrappers:** Pre-build CI tests like `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh` are designed to be non-blocking. However, they lack the necessary `timeout 60s` wrapper and `|| true` fallback, increasing the risk of pipeline hangs.
3. **Incomplete .gitignore:** The `.gitignore` file is missing common entries (e.g., `*.iso`, `*.log`, `.DS_Store`, `*~`, `pacman-build.conf`), leading to potential repository pollution with build artifacts.
4. **Suboptimal Error Messaging:** Error messages in test scripts often lack clear, actionable remediation steps. They need to be formatted as multi-line outputs incorporating a clear '💡 How to fix:' block with bulleted instructions.

## Why This Step is the Highest Leverage
As we move toward a stable release, ensuring the reliability and speed of the CI/CD pipeline is paramount. Unreliable tests or hanging pipelines will significantly hamper development velocity. By introducing a pre-build validation step in an `archlinux:latest` container (with `--privileged` and `bash`), we can catch configuration and dependency errors before initiating the resource-intensive ISO build process. Implementing timeout wrappers on specific tests ensures the pipeline remains non-blocking even if edge-case failures occur. Furthermore, improving the UX of terminal errors directly reduces developer cognitive load and troubleshooting time. This aligns squarely with the "Stabilization / hardening" priority.