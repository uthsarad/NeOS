## 2026-10-13 - Eliminate Subprocess Overhead with Native Bash
**Learning:** Shell pipelines invoking `ls`, `find`, `sort`, and `head` for simple file discovery or date comparisons introduce unnecessary process-forking overhead in bash scripts. Bash's native array expansion and file comparison operators (`-nt`) are much faster.
**Action:** Use `shopt -s nullglob` combined with array assignments (e.g., `files=(*)`) and the `-nt` (newer than) operator to iterate through files within the shell instead of resorting to external tools for finding files and checking their existence or timestamps.
