# Risk & Priority Report

## Current System Risk
**Low**. The most critical build-blocking issues (like `DatabaseRequired` in `pacman.conf`) and ISO size CI limits have been resolved, and core root-privileged scripts (`neos-autoupdate.sh`) already incorporate dependency and filesystem validation. The primary risk now lies in expectation management and user experience during the beta release.

## Tech Debt Assessment
The repository suffers from documentation drift and inconsistent code structuring in package manifests:
1. **Incomplete Architecture Support:** `README.md` and `HANDBOOK.md` suggest universal support, but `i686` and `aarch64` are experimental and lack the Calamares GUI installer, snapshots, and ZRAM. This is a massive expectation mismatch for a "Windows-familiar" distribution.
2. **Broken Documentation Links:** Critical onboarding documents (`HANDBOOK.md`, `CONTRIBUTING.md`) point to the non-existent `neos-project/neos` organization rather than `uthsarad/NeOS`.
3. **Inconsistent Package Manifests:** `packages.x86_64` (the primary target) lacks the helpful categorical comments (`# Base System`, `# Desktop Environment`) present in other architecture manifests, increasing maintenance overhead.

## Why This Step is the Highest Leverage
As we approach the first public beta, unaddressed documentation issues will lead to a flood of support requests from users attempting to run the GUI installer on `aarch64` or accessing dead GitHub links. By explicitly documenting architecture limitations and fixing URLs, we mitigate support volume (a defined success metric in `ROADMAP.md`). By adding categorical comments to `packages.x86_64`, we reduce the cognitive load for developers reviewing ISO bloat (a critical CI constraint). This aligns with the "Refinement of recent feature" and "Stabilization" priorities from the deep audit.
