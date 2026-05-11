# BOLT REPORT

- **What was optimized:** Removed `tr` inside subshells and replaced them with native Bash parameter expansion `//[^...]/` in `neos-installer-partition.sh`.
- **Before/after reasoning:** The previous use of `tr` spawned a subshell (`$()`), invoked an external process (`tr`), and potentially `printf` as a command instead of builtin. This caused a slight fork/exec overhead especially in traps like `ERR` which must be extremely lightweight. By converting these to native bash parameter expansions, we avoid both subshells and external binary execution.
- **Any remaining performance risks:** Trap handlers and sanitization now operate using purely internal bash processing.

## ⚡ Bolt: Native Bash Evaluation
- **What was optimized:** Replaced POSIX `[ ... ]` conditional tests with native Bash `[[ ... ]]` in `neos-autoupdate.sh`.
- **Before/after reasoning:** POSIX single brackets invoke the `test` command, which is prone to word splitting and pathname expansion overhead. Double brackets are a shell keyword, completely bypassing this parsing behavior and evaluating conditions natively.
- **Any remaining performance risks:** Minimal. The script is now free of unnecessary POSIX expansion latency.
## ⚡ Bolt: Native Bash Evaluation
- **What was optimized:** Replaced multiple `grep -q` calls against `/proc/modules` with a single native read `PROC_MODULES="$(</proc/modules)"` and a native bash regex matching function `is_loaded` in `neos-driver-manager`.
- **Before/after reasoning:** `grep -q` calls in loops and sequential conditions spawned multiple subshells and invoked external processes, leading to measurable fork/exec overhead. By reading the file into memory once and using native Bash matching, we eliminate this overhead completely.
- **Any remaining performance risks:** Minimal. File size of `/proc/modules` is small enough to hold in memory easily.
