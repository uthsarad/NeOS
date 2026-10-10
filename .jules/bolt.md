## 2026-10-10 - Optimize subprocess overhead with native Bash features
**Learning:** Checking for file existence or finding the newest file using subprocess pipelines like `ls`, `find | sort | head | cut` introduces measurable fork/exec overhead.
**Action:** Use native Bash arrays with `shopt -s nullglob` to check file existence, and iterate over array elements using the `-nt` file comparison operator to find the newest file without spawning external processes.
