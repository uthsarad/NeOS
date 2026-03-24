# NeOS Risk & Priority Report

## Current Risk Landscape

### 1. Silent Failure Risk in Autoupdates (High)
**Observation:** The `airootfs/usr/local/bin/neos-autoupdate.sh` script manages system updates and relies on `snapper` to create pre- and post-update Btrfs snapshots. However, the script does not verify that `snapper` is installed before attempting to use it.
**Impact:** If a user uninstalls `snapper` or if it fails to install correctly, the `neos-autoupdate.timer` will trigger the script, but the system update will proceed without generating a rollback snapshot. This introduces a significant risk of silent data loss or unrecoverable system states if an update breaks the system.
**Mitigation Priority:** High. The Architect must add a dependency check for `snapper` within `neos-autoupdate.sh` that logs a clear warning and gracefully exits (exit code `0`) if missing. This prevents the systemd unit from failing while ensuring no unsafe updates occur without snapshot protection.

### 2. Supply Chain Risk (Medium)
**Observation:** The `alci_repo` configured in the build environment `pacman.conf` has `SigLevel = Optional`.
**Impact:** While the installed system correctly requires signatures (`DatabaseRequired`), the ISO build process itself relies on an unsigned repository. If this repository is compromised, malicious packages could be injected during the build phase.
**Mitigation Priority:** Medium (Documented/Accepted for now). This is a known risk from previous Sentinel audits that requires upstream collaboration or the establishment of a signed internal mirror. It cannot be resolved in the current architectural scope without significant infrastructure investment.

### 3. Incomplete Architecture Support (High - Long Term)
**Observation:** The documentation (`README.md`, `HANDBOOK.md`) claims a Windows-familiar GUI experience, but currently, only the `x86_64` architecture delivers this full feature set (Calamares installer, snapshots, ZRAM). `i686` and `aarch64` are experimental and lack the GUI installer.
**Impact:** Users attempting to install on non-x86_64 hardware will encounter a confusing, terminal-only experience that contradicts the project's primary mission.
**Mitigation Priority:** High (Long-term roadmap). While documentation updates have clarified this limitation, the medium-term goal must address providing installation scripts or adapting Calamares for these experimental architectures if they are to be officially supported.

## Strategic Outlook
By prioritizing the immediate resolution of the `snapper` dependency check in `neos-autoupdate.sh`, the team hardens the core snapshot-based update mechanism that distinguishes NeOS from a standard Arch installation (Roadmap Phases 1 and 5). This defensive measure is necessary to guarantee system resilience before expanding the feature set or officially supporting new hardware architectures. Previous passes have successfully resolved critical build blockers (`pacman.conf`) and release constraints (ISO size validation), leaving this runtime stability issue as the highest leverage improvement for the current sprint.