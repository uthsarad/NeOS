# BOLT_REPORT

## What was optimized
- Replaced multiple external `grep` subprocess calls with native bash string matching `[[ == *pattern* ]]` inside `tests/verify_iso_size.sh`.
- Modified the script to load `profiledef.sh` and `pacman.conf` into arrays using `mapfile` to eliminate cross-line matching bugs, and iterating through lines in bash memory instead of re-reading via `grep`.
- Replaced all POSIX single brackets `[ ]` with native bash double brackets `[[ ]]` for conditional evaluation.

## Before/after reasoning
- **Before:** The bash script relied on `grep` multiple times, particularly inside a `for` loop matching items in `pacman.conf`. Each call to `grep` spawns an external process (fork/exec overhead), slowing down the verification script significantly on every run. Furthermore, the `[` evaluation incurs pathname expansion and word splitting overhead.
- **After:** Native bash double bracket evaluation `[[ ]]` bypasses word splitting and is much faster. Using `mapfile` to read the files into arrays and checking with `[[ == *pattern* ]]` entirely eliminates the need for any external subprocess overhead, yielding a highly performant pure bash validation script.

## Any remaining performance risks
- Subprocesses such as `sed` or `echo` may still be used elsewhere in the pipeline.
- For extremely large files, using `mapfile` might result in high memory consumption, but since both `profiledef.sh` and `pacman.conf` are small configuration files, the memory overhead is entirely negligible and far outweighs the cost of repeatedly calling `grep`.
