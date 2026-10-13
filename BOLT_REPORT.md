## What was optimized
Subprocess invocations (`ls`, `find`, `sort`, `head`, `cut`) used to locate package cache files and the latest ISO image were replaced with native Bash arrays and file comparison operators (`-nt`).

## Before/after reasoning
Before: Identifying files relied on forking multiple external processes and piping them together, which introduces significant overhead, especially when checking for simple file existence or comparing file modification times in a script executed repeatedly or in performance-sensitive pipelines.
After: Using native Bash arrays with `shopt -s nullglob` and the `-nt` operator allows file discovery and comparison directly within the shell memory, removing the need to spawn subprocesses and dramatically speeding up execution time for these operations.

## Any remaining performance risks
The file listing within Bash is robust for typical ISO directory contents, though extremely large directories might increase memory usage within the shell process. For the specific use cases (ISO directory and local package cache), this is heavily mitigated by the modest file counts.
