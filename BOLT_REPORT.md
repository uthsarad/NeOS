## What was optimized
The file existence checks and newest file lookups in `build.sh` were optimized by replacing external subprocesses (`ls` and `find | sort | head`) with native Bash array expansions and the `-nt` comparison operator.

## Before/after reasoning
Previously, checking if the offline package repo had files and finding the most recent ISO required spawning multiple subshells and external processes, which creates overhead. By using native Bash features (`shopt -s nullglob` and `-nt`), the script avoids this I/O and process-spawning cost entirely, executing significantly faster directly within the shell.

## Any remaining performance risks
No significant performance risks remain for these specific operations, as native Bash operations are O(N) relative to the number of files, which is minimal in these directories.
