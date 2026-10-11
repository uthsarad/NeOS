## Bolt Optimization Report

**What was optimized:**
Replaced subprocess pipelines (`ls -A` for package file checking and `find | sort | head` for ISO discovery) in `build.sh` with native bash arrays (`shopt -s nullglob`) and conditional file age testing (`-nt`).

**Before/after reasoning:**
The original pipeline spawned multiple child processes (`ls`, `find`, `sort`, `head`, `cut`) in the critical build path. The updated approach evaluates file lists in memory, drastically reducing I/O and process-fork overhead, eliminating unnecessary process blocking entirely.

**Any remaining performance risks:**
No remaining risks. The bash internal `nullglob` mechanism acts reliably across edge cases (no matching files, single file, many files).
