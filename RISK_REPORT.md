# Priority & Risk Report

**Generated:** $(date +%Y-%m-%d)
**Target:** NeOS Repository
**Author:** Maestro (Strategic Engineering Director AI)

## Identified Risks from Deep Audit

The `DEEP_AUDIT.md` highlighted several areas of concern. Among the highest priority (after the successfully resolved build-blocking `pacman.conf` and ISO Size validations) is the lack of dependency validation for core services in the live system.

1. **Risk of Silent Runtime Failures (High Priority)**
   - **Context:** Scripts like `airootfs/usr/local/bin/neos-autoupdate.sh` execute automatically via systemd timers.
   - **Vulnerability:** They assume dependencies like `snapper` exist and that the root filesystem is Btrfs. If a user uninstalls `snapper` or the filesystem is not Btrfs, the script fails.
   - **Impact:** System updates and automated snapshot creation fail silently, creating a risk of data loss. The systemd unit crashes or reports confusing errors to the user, undermining the "predictable and reliable" product goal.
   - **Mitigation:** Introduce explicit dependency checks before execution. If dependencies are missing, the scripts must log an actionable message and exit gracefully (status 0) to avoid failing the timer.

2. **Incomplete Architecture Support (Medium-to-High Priority - Deferred)**
   - **Context:** The documentation claims a Windows-familiar experience, but this is only delivered on x86_64, confusing i686/aarch64 users.
   - **Status:** Deferred for a future cycle to maintain focus on the immediate fragility in the core service scripts (single coherent deliverable rule).

3. **Systemd Sandboxing (Medium Priority - Deferred)**
   - **Context:** Services currently run as root without basic systemd sandboxing directives (`ProtectSystem=strict`, etc.).
   - **Status:** Deferred for a future Sentinel-focused audit cycle.

## Justification for Priority Selection
We are addressing the dependency validation in `neos-autoupdate.sh` to prevent silent data loss and runtime failures. The goal of NeOS is stability. A system that crashes when an expected package is missing—without gracefully handling the edge case—fails the stability requirement. By implementing these checks natively without heavy subprocess overhead, we resolve an architectural flaw while maintaining performance.
