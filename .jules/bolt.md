## 2026-02-18 - Plymouth Boot Splash Redundant Invalidations
**Learning:** In Plymouth boot splash scripts (`.script`), the `SetRefreshFunction` callback executes at a high frequency (e.g., 50Hz). Unconditionally calling `SetImage()` inside this callback causes redundant texture invalidations and increases CPU overhead in software rendering, which is an anti-pattern for this architecture.
**Action:** Always conditionally execute sprite updates in Plymouth using a state tracker (e.g., `if (frame != last_frame)`) so it only runs when the calculated frame changes.
## 2026-07-25 - Shell Script Subprocess Overhead
**Learning:** Repeated `grep` checks on the same file in shell scripts cause unnecessary fork/exec subprocess overhead, even for simple configuration validation scripts like `tests/verify_security_config.sh`.
**Action:** Load the file into a variable once (`CONTENT=$(<"$FILE")`) and use native Bash string matching (`[[ "$CONTENT" == *"pattern"* ]]` or `=~` for regex) instead of repeated `grep -q` calls to eliminate overhead.

## 2026-07-30 - Subshell Overhead in Virtualization Checks
**Learning:** Using `virt="$(systemd-detect-virt 2>/dev/null || echo none)"` in shell scripts introduces unnecessary subshell and string allocation overhead.
**Action:** When checking for virtualization, use the `-q` flag and directly evaluate the exit code (e.g., `if systemd-detect-virt -q 2>/dev/null; then`) rather than capturing the output.
