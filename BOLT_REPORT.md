# Bolt Report

## What
Replaced the `$(basename "$0")` command substitution with native bash parameter expansion `${0##*/}` in the error logging trap of `neos-installer-partition.sh` and `neos-liveuser-setup`.

## Why
The command substitution `$(basename "$0")` spawns a subshell and executes the external `basename` binary every time an error occurs. While error paths are generally cold, using native parameter expansion avoids this unnecessary subprocess overhead, improving script efficiency and preventing potential delays during critical failure scenarios.

## Impact
Reduces subprocess overhead to exactly 0 when the trap fires, eliminating one fork/exec cycle per logged error.

## Remaining Risks
None identified related to this specific change. The parameter expansion correctly extracts the filename from the path.