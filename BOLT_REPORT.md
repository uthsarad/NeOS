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
