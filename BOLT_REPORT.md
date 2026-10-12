# BOLT REPORT

## What was optimized
Replaced expensive subprocess pipelines (`ls -A` and `find | sort | head`) in `build.sh` with native Bash array operations (`shopt -s nullglob` and `-nt` file comparison) for file presence checking and finding the newest ISO file.

## Before/after reasoning
Before: Identifying if packages exist and finding the newest ISO spawned multiple external processes (`ls`, `find`, `sort`, `head`, `cut`), incurring significant fork/exec overhead.
After: Using native Bash arrays and built-in operators avoids these subprocesses completely, accelerating the build wrapper logic without changing the build's behavior.

## Any remaining performance risks
None identified in this section. The native Bash approach is highly optimized and scalable for the small number of files in these directories.
