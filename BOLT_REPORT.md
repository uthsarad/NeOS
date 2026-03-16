# Bolt Performance Report

## What was optimized
Optimized the validation test scripts `tests/verify_qml_enhancements.sh` and `tests/verify_mkinitcpio.sh` by removing subprocess fork/exec overhead resulting from repeated use of external binaries like `grep` and `sed`.

- In `tests/verify_qml_enhancements.sh`, the file contents are now read once into a bash variable (`QML_CONTENT=$(<"$QML_FILE")`), and 15 repeated `grep -q` calls were replaced with native bash substring matching (parameter expansion `[[ "$QML_CONTENT" == *"pattern"* ]]`).
- In `tests/verify_mkinitcpio.sh`, the file parsing previously used a `grep` process to find the `HOOKS` array and a `sed` process to extract the multi-line `MODULES` array. This was replaced with a single native bash `while read -r line` stream-parsing loop that extracts both configurations directly in memory.

## Before/after reasoning
**Before:** The validation scripts relied heavily on spawning external processes for simple string matching and extraction. In CI/CD pipelines and restricted execution environments, spinning up dozens of subprocesses (`grep`/`sed`) causes unnecessary latency, compounding execution time especially when these tests are run repeatedly.
**After:** Using pure, native bash primitives—such as reading files directly into variables, employing parameter expansion for globbing/matching, and using native read streams—eliminates process forking overhead. This reduces overall execution time, lowers memory/CPU spikes during CI tasks, and makes the test scripts significantly more efficient.

## Remaining performance risks
While subprocess overhead for these string extractions has been eliminated, the remaining risk is that reading extremely large files into bash variables (`$(<"$FILE")`) could consume excessive memory. However, for these specific configuration files (`show.qml` and `mkinitcpio.conf`), the sizes are well within the kilobyte range, so the memory usage is entirely negligible compared to the execution time saved by skipping process forks.
