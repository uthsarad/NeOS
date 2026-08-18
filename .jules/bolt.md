## 2026-02-18 - Plymouth Boot Splash Redundant Invalidations
**Learning:** In Plymouth boot splash scripts (`.script`), the `SetRefreshFunction` callback executes at a high frequency (e.g., 50Hz). Unconditionally calling `SetImage()` inside this callback causes redundant texture invalidations and increases CPU overhead in software rendering, which is an anti-pattern for this architecture.
**Action:** Always conditionally execute sprite updates in Plymouth using a state tracker (e.g., `if (frame != last_frame)`) so it only runs when the calculated frame changes.
## 2026-07-25 - Shell Script Subprocess Overhead
**Learning:** Repeated `grep` checks on the same file in shell scripts cause unnecessary fork/exec subprocess overhead, even for simple configuration validation scripts like `tests/verify_security_config.sh`.
**Action:** Load the file into a variable once (`CONTENT=$(<"$FILE")`) and use native Bash string matching (`[[ "$CONTENT" == *"pattern"* ]]` or `=~` for regex) instead of repeated `grep -q` calls to eliminate overhead.

## 2026-07-30 - Subshell Overhead in Virtualization Checks
**Learning:** Using `virt="$(systemd-detect-virt 2>/dev/null || echo none)"` in shell scripts introduces unnecessary subshell and string allocation overhead.
**Action:** When checking for virtualization, use the `-q` flag and directly evaluate the exit code (e.g., `if systemd-detect-virt -q 2>/dev/null; then`) rather than capturing the output.

## 2026-08-01 - Subprocess Overhead in Loop Hardware Detection
**Learning:** Using text processing pipelines like `echo "$VAR" | sed ... | grep ...` inside shell loops (e.g., when iterating over network devices from `lspci`) introduces significant fork/exec subprocess overhead.
**Action:** When extracting blocks of text and matching specific patterns in shell loops, rely on native bash parameter expansion (e.g., string slicing and glob matching like `[[ "$BLOCK" == *"pattern"* ]]`) instead of external binaries.

## 2025-05-24 - Subprocess overhead in CI checks
**Learning:** Using repeated `grep -q` calls in bash test scripts introduces unnecessary subshell and fork/exec overhead when verifying multiple packages or strings in the same file.
**Action:** Cache the file content into a bash variable and use native string matching (`[[ "$CONTENT" == *"$pkg"* ]]`) to eliminate subprocess spawns.

## 2024-08-04 - Native Bash Multiline Regex Matching
**Learning:** When evaluating native bash regex matches `[[ "$VAR" =~ regex ]]` against multiline strings cached from a file, standard start-of-line anchors `^` do not match line beginnings across the string. The variable is treated as one large string.
**Action:** Use the `(^|$'\n')` regex construct in Bash to properly match the beginning of lines within multiline string variables.

## 2024-08-04 - Native Bash Regex Bug with Multiline Variables
**Learning:** When using native bash regex `[[ "$CONTENT" =~ pattern ]]` against multiline strings, the `.*` pattern matches across newlines, making it greedy across the entire file. This can lead to false positives if the regex spans across different unrelated lines (e.g., `vm.swappiness.*=.*100` could match `vm.swappiness = 10\nother = 100`).
**Action:** When matching specific lines in a multiline bash string variable, replace `.*` with `[^\n]*` to constrain the match to a single line.

## 2026-02-17 - Subprocess Overhead in Bash Scripts
**Learning:** In bash scripts that act as simple launchers or wrappers, using standard invocation (e.g. `kdialog ...`) spawns a child process and leaves the parent bash shell lingering in memory, causing unnecessary fork/exec overhead.
**Action:** Use `exec` (e.g. `exec kdialog ...`) to replace the current bash process with the target application, eliminating the parent process overhead and saving memory.

## 2026-02-18 - Missing Bottlenecks in Stubs
**Learning:** Attempting to optimize subprocess overhead for tools (like snapper) in stubbed UI scripts (like neos-operations-hub) is a premature optimization trap if the underlying functionality hasn't been implemented yet.
**Action:** Verify the actual presence of the executing command before attempting to optimize its subprocess overhead. Always use `exec` for terminal `kdialog` invocations.
## 2026-08-05 - Shell Script Line Counting Subprocess Overhead
**Learning:** Using `$(wc -l < file)` in bash scripts introduces unnecessary fork/exec overhead for simple line counting.
**Action:** When needing to count lines of a temporary file, use native bash array counting via `mapfile -t lines < file` and `${#lines[@]}` instead.

## UI File I/O Optimization Trap
**Learning:** Attempting to optimize temporary file I/O overhead for GUI components like `kdialog --textbox` is often a premature optimization trap if the temporary directory (`/tmp`) is mounted as a `tmpfs` (RAM).
**Action:** Verify if the target file system is RAM-backed before attempting to eliminate temporary file creation for UI data passing.
