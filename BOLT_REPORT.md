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

- What was optimized: Verified and enforced the removal of the `[Install]` section from `neos-autoupdate.service`. The `Environment=LC_ALL=C` directive is already present in both `neos-autoupdate.service` and `neos-liveuser-setup.service`.
- Before/after reasoning: `neos-autoupdate.service` is controlled by `neos-autoupdate.timer`. Including an `[Install]` section with `WantedBy=multi-user.target` is an anti-pattern for timer-activated oneshot services. It causes the service to execute synchronously at boot, bypassing the timer's intended delay and blocking `multi-user.target`, leading to severe boot overhead. Removing it enforces that the service strictly runs asynchronously in the background as intended.
- Any remaining performance risks: The underlying bash scripts still invoke external binaries. Future iterations should profile the exact execution trace of `neos-autoupdate.sh` to ensure no blocking I/O operations occur on the critical path during background execution.

- What was optimized: Replaced the subshell and string evaluation `[ "$(systemd-detect-virt 2>/dev/null || echo none)" != "none" ]` with a lightweight direct exit-code evaluation `systemd-detect-virt -q 2>/dev/null` in `profile/airootfs/usr/local/bin/neos-liveuser-setup`.
- Before/after reasoning: `$(...)` spawns a subshell process, executes the command, captures the output, and then the outer `[` command performs a string comparison. `systemd-detect-virt -q` performs the same check but suppresses output and sets the exit code directly, eliminating the need for a subshell, output capture, and string comparison overhead.
- Any remaining performance risks: None. This is a pure optimization with no changes to application logic.

- What was optimized: Added Environment=LC_ALL=C to neos-driver-manager.service.
- Before/after reasoning: The service executes a bash script (neos-driver-manager) which performs extensive string manipulation (grep, awk, sed) on lspci outputs. Without LC_ALL=C, these tools use the default locale, adding significant overhead for locale-aware string parsing and sorting. Forcing the C locale eliminates this overhead and speeds up hardware detection during boot.
- Any remaining performance risks: The script still relies on subprocesses like awk and grep. Further optimizations could rewrite these parsing logic natively in bash, though it might reduce readability.
