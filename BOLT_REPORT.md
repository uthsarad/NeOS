# BOLT REPORT

- **What was optimized:** Removed `tr` inside subshells and replaced them with native Bash parameter expansion `//[^...]/` in `neos-installer-partition.sh`.
- **Before/after reasoning:** The previous use of `tr` spawned a subshell (`$()`), invoked an external process (`tr`), and potentially `printf` as a command instead of builtin. This caused a slight fork/exec overhead especially in traps like `ERR` which must be extremely lightweight. By converting these to native bash parameter expansions, we avoid both subshells and external binary execution.
- **Any remaining performance risks:** Trap handlers and sanitization now operate using purely internal bash processing.
