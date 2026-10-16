## 2026-10-16 - Subprocess Optimization in Bash Scripts
**Learning:** Native bash array expansions and conditional operators (`-nt`) are significantly faster than pipelines relying on external tools (like `find | sort | head | cut`) for simple file system operations. Batching package signing operations also reduces overhead.
**Action:** When evaluating directory contents or comparing files in performance-sensitive scripts, always prefer native bash globbing (e.g., `shopt -s nullglob`) and arrays over spawning multiple subshells and subprocesses.
