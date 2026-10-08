# Bolt Optimization Report

## What was optimized
Optimized subprocess and pipeline overhead in `build.sh`:
1. Replaced `yes ""` infinite stream generation pipeline with standard input redirection `< /dev/null` for `mkarchiso`.
2. Replaced the `find | sort | head | cut` pipeline for ISO file discovery with native Bash array expansion and the `-nt` (newer than) operator.

## Before/after reasoning
Before:
- `yes "" | mkarchiso` forced a pipeline subshell, requiring `+o pipefail` juggling to handle `SIGPIPE` exit codes, and spawned an unnecessary external process (`yes`).
- Finding the newest ISO used `find`, `sort`, `head`, and `cut` via pipes, resulting in multiple subprocess forks.

After:
- `< /dev/null` provides an EOF directly to any prompt without spawning processes or subshells, cleanly removing the pipeline complexity.
- Native Bash iteration with the `-nt` comparison completely avoids subprocess forks when finding the newest ISO file, enhancing script execution speed and avoiding external dependencies for basic file operations.

## Any remaining performance risks
- The script still uses `curl` in a loop and calls `pacman-key`. These are external, but required for network operations and key management. The keyring check is already cached efficiently.
