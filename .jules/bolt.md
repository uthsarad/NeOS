## 2026-10-12 - Native Bash Optimization in build.sh
**Learning:** Shell script performance in package environments is heavily degraded by gratuitous fork/exec overhead from external tools (`ls`, `find`, `cut`).
**Action:** When searching for files, counting items, or finding the newest file, always default to native Bash array expansions (`shopt -s nullglob`) and built-in comparison operators (like `-nt`) to bypass process creation entirely.
