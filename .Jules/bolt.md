## 2024-06-20 - Baseline Initialization
**Learning:** Initialized performance baseline in a zero-modification scenario. No architecture-specific bottlenecks identified yet.
**Action:** Proceed with identifying and measuring active performance bottlenecks in future iterations.
## 2026-02-17 - Avoid Subshell Overhead for PWD
**Learning:** Using `$(pwd)` in bash scripts introduces subshell overhead, which can be inefficient, especially in loops or frequently called functions. The native environment variable `$PWD` provides the exact same information with zero overhead.
**Action:** Always prefer the built-in `$PWD` environment variable over executing `$(pwd)` in bash scripts for improved performance.

## 2026-02-17 - Shell Script Subprocess Overhead
**Learning:** Repeated `grep` checks on the same file in shell scripts cause unnecessary fork/exec subprocess overhead.
**Action:** Load the file into a variable once (`CONTENT=$(<"$FILE")`) and use native Bash string matching (`[[ "$CONTENT" == *"pattern"* ]]`) instead of repeated `grep -q` calls to eliminate overhead.
## 2026-02-18 - Systemd Timer vs Service Boot Overhead
**Learning:** Having an `[Install]` section with `WantedBy=multi-user.target` on a oneshot service that is *also* managed by a systemd timer creates severe boot overhead. It causes the service to be synchronously executed at boot, completely bypassing the timer's intended `OnBootSec` delay. Furthermore, setting `Environment=LC_ALL=C` in bash-heavy oneshot services significantly eliminates locale parsing overhead during command execution.
**Action:** Always verify that services controlled by `.timer` units do not inadvertently contain `[Install]` sections. Utilize `LC_ALL=C` for lightweight bash services where locale-aware sorting or output formatting is unnecessary.
