# Bolt Report

- What was optimized: Baseline initialization (zero-modification scenario). No production files were modified.
- Before/after reasoning: Established initial baseline for future optimizations.
- Any remaining performance risks: None currently identified.

- What was optimized: Replaced `$(pwd)` with `$PWD` in `build.sh`.
- Before/after reasoning: `$(pwd)` spawns a subshell process to retrieve the current working directory, adding minor overhead. `$PWD` is a native shell variable that already contains the path, requiring zero subprocess execution. This minimizes subshell overhead.
- Any remaining performance risks: Minor optimization; other external commands like `sed` and `grep` are still invoked and might cause similar small delays, but these are necessary for the build process logic.

- What was optimized: Replaced repeated `grep -q` calls with native bash string matching in `tests/verify_service_hardening.sh`.
- Before/after reasoning: Repeated `grep -q` calls spawn multiple fork/exec subprocesses, adding overhead. Loading the file content into a variable once and using native bash matching (`[[ "$CONTENT" == *"pattern"* ]]`) eliminates this overhead.
- Any remaining performance risks: The file being read must be reasonably small, which holds true for systemd service files.

- What was optimized: Removed `[Install]` section from `neos-autoupdate.service` and added `Environment=LC_ALL=C` to both `neos-autoupdate.service` and `neos-liveuser-setup.service`.
- Before/after reasoning: `neos-autoupdate.service` is controlled by `neos-autoupdate.timer`. Including an `[Install]` section with `WantedBy=multi-user.target` causes it to execute immediately at boot, nullifying the timer's `OnBootSec` delay and blocking `multi-user.target`. Removing it enforces that it strictly runs in the background. Adding `LC_ALL=C` skips expensive locale parsing for underlying bash scripts.
- Any remaining performance risks: The underlying scripts might invoke heavy binaries independently. Future iterations should profile the exact execution trace of `neos-liveuser-setup` to ensure no blocking operations occur on the critical path.
