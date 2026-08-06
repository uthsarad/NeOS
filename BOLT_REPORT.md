# ⚡ Bolt Performance Report

## What was optimized
Refactored `tests/verify_iso_grub.sh` to eliminate repeated `grep -q` shell invocations during test execution.

## Before/after reasoning
**Before:** The test script used `grep -q "$STR" "$GRUB_FILE"` and `grep -q "$STR" "$PROFILE_FILE"` in loops to verify strings. This caused a fork/exec of the `grep` binary for every single string check in the required, forbidden, and profile arrays.
**After:** The scripts now load the file contents into memory once via native bash variables (`GRUB_CONTENT=$(<"$GRUB_FILE")` and `PROFILE_CONTENT=$(<"$PROFILE_FILE")`). We then use native bash string matching (`[[ "$CONTENT" == *"$STR"* ]]`) to perform the assertions. This eliminates the fork/exec overhead entirely, noticeably speeding up the test suite execution.

## Remaining performance risks
None introduced by this change. The memory usage to hold these configuration files is negligible.

## What was optimized
Refactored `profile/airootfs/usr/local/bin/neos-vm-graphics` to eliminate unnecessary subshell and string allocation overhead during virtualization detection.

## Before/after reasoning
**Before:** The script used `virt="$(systemd-detect-virt 2>/dev/null || echo none)"` followed by a string comparison. This required spawning a subshell, allocating memory for the output string, and then executing a test command.
**After:** The script now directly evaluates the exit code of `systemd-detect-virt -q 2>/dev/null`. This completely bypasses the subshell creation and string manipulation, reducing CPU overhead during login/graphics initialization.

## Remaining performance risks
None. This is a purely structural optimization of the check mechanism.

## Optimization: Eliminate subprocess overhead in neos-driver-manager
**What was optimized:** Replaced `sed` and `grep` subprocess calls inside a `while` loop with native bash string manipulation for checking kernel drivers.
**Before/after reasoning:** Previously, checking network drivers involved spawning `echo`, `sed`, and `grep` for every detected network interface, causing unnecessary fork/exec overhead. By extracting the relevant text block and searching for "Kernel driver in use" directly with bash parameter expansion (`${VAR#pattern}` and `${VAR%%pattern}`), the need for subprocesses is eliminated, reducing CPU overhead during hardware detection.
**Any remaining performance risks:** None. The replacement strictly handles string processing without external dependencies, resulting in faster and safer execution.

## ⚡ Bolt: Optimize verify_boot_gui grep checks
**What:** Replaced repeated `grep` subprocess calls in `tests/verify_boot_gui.sh` with native bash string matching.
**Why:** To eliminate fork/exec subprocess overhead during CI/validation checks on the boot gui script.
**Impact:** Reduces CPU overhead by caching file content and bypassing external process spawning for simple string checks.
**Measurement:** Running the tests via `bash tests/verify_boot_gui.sh` should confirm functionality remains intact and slightly faster.

## ⚡ Bolt: Optimize verify_discover_config grep checks
**What:** Replaced repeated `grep` subprocess calls in `tests/verify_discover_config.sh` with native bash string matching.
**Why:** To eliminate fork/exec subprocess overhead during CI/validation checks on the Discover configuration script.
**Impact:** Reduces CPU overhead by caching file content and bypassing external process spawning for simple string checks.
**Measurement:** Running the tests via `bash tests/verify_discover_config.sh` should confirm functionality remains intact and executes faster.

## Bolt Optimization: Eliminate subprocess grep overhead in verify_performance_config.sh
**What was optimized:** Replaced 13 redundant `grep` subprocess calls with a single read into a memory variable (e.g. `CONTENT=$(<"$FILE")`) and native bash regular expression matching `[[ "$CONTENT" =~ (^|$'\n')pattern ]]`.
**Before/after reasoning:** Repeated fork/exec operations in shell scripts are slow and inefficient. By caching the file contents and using built-in string/regex logic, the execution time decreases significantly.
**Remaining performance risks:** Other test scripts still rely on subprocess invocations for similar checks, which could be refactored similarly in the future.

## 2026-02-17 - NeOS Operations Hub Optimization
**Optimization:** Replaced standard subprocess invocations with `exec` in `neos-operations-hub` wrapper script.
**Reasoning:** The original script spawned applications (like `kdialog`, `xdg-open`, and `drkonqi`) as child processes. Since the script has no further logic after these applications are launched, leaving the parent bash shell alive consumes unnecessary memory and introduces fork/exec overhead. Using `exec` replaces the bash process directly, making the system more efficient.
**Risks:** Low. The `exec` command inherently terminates the script upon execution, which matches the previous logic where the script naturally ended.
