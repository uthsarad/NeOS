## 2026-10-14 - Subprocess Overhead in File Lookups
**Learning:** Relying on external commands like `ls` for file existence or pipelines like `find | sort | head` for determining the newest file introduces significant subprocess overhead inside hot paths or loops.
**Action:** Use native Bash arrays with `shopt -s nullglob` to safely evaluate file existence via array length `(( ${#array[@]} > 0 ))`, and utilize the `-nt` comparison operator to find the newest file purely in Bash.
