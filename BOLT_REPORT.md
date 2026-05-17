# Bolt Report

## What was optimized
- Eliminated an unnecessary `grep -q "\S"` subprocess fork in `neos-installer-partition.sh` during the active mount check.

## Before/after reasoning
- **Before:** The active mount check used a pipeline `lsblk ... | grep -q "\S"`. This required launching `lsblk` and piping to a separate `grep` process, which introduces unnecessary subprocess overhead in bash scripts.
- **After:** The script captures the output of `lsblk` directly and uses native bash regex matching `[[ "$MOUNTPOINTS" =~ [^[:space:]] ]]`. This natively evaluates the check and saves a subshell spawn without breaking existing functionality.

## Any remaining performance risks
- The script continues to use `udevadm settle` and `sleep`, which are inherently blocking but necessary to wait for disk enumeration. The regex matching mitigates minor overhead but does not change the I/O-bound nature of partitioning operations.
