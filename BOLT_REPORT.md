# ⚡ Bolt Performance Report

## What was optimized
Refactored `tests/verify_iso_grub.sh` to eliminate repeated `grep -q` shell invocations during test execution.

## Before/after reasoning
**Before:** The test script used `grep -q "$STR" "$GRUB_FILE"` and `grep -q "$STR" "$PROFILE_FILE"` in loops to verify strings. This caused a fork/exec of the `grep` binary for every single string check in the required, forbidden, and profile arrays.
**After:** The scripts now load the file contents into memory once via native bash variables (`GRUB_CONTENT=$(<"$GRUB_FILE")` and `PROFILE_CONTENT=$(<"$PROFILE_FILE")`). We then use native bash string matching (`[[ "$CONTENT" == *"$STR"* ]]`) to perform the assertions. This eliminates the fork/exec overhead entirely, noticeably speeding up the test suite execution.

## Remaining performance risks
None introduced by this change. The memory usage to hold these configuration files is negligible.
