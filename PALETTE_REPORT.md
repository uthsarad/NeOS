
## Improve log output clarity in core scripts and refine error handling messages for better troubleshooting UX.
**Learning:** Vague missing dependency errors without installation commands are not actionable and lead to poor developer UX.
**Action:** Replaced vague "Please install X" messages with explicit, copy-pasteable package manager installation commands (e.g., `sudo pacman -S X`) in `build.sh`.
