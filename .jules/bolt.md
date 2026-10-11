## 2026-10-11 - Eliminate bash subprocess I/O blocks
**Learning:** Native bash array expansions and built-in file operators (like `-nt`) safely remove process spawning overheads when inspecting directories, outperforming multi-piped Unix utilities when dealing with local paths.
**Action:** Default to bash native arrays (`shopt -s nullglob`) instead of pipes (`ls` | `wc -l` or `find` | `sort`) for file existence and age checks in critical bash scripts.
