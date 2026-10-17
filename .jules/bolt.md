## 2026-10-17 - Batched pacman-key imports
**Learning:** pacman-key has strict and surprising flag structures for batched operations: you can batch fetch multiple keys using the `--recv-keys` flag, but for signing, you must use the singular `--lsign-key` flag. Using `--lsign-keys` causes the strict option parser to reject the command and fail the build. Additionally, the `--keyserver` flag must precede the action flag.
**Action:** Always verify pacman-key flag pluralization when batching operations in scripts.
