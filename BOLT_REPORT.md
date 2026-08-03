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
