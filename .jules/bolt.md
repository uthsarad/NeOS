## 2026-10-15 - pacman-key batching
**Learning:** Sequential pacman-key calls for multiple keys cause significant subprocess and network overhead.
**Action:** Batch multiple keys into single --recv-keys and --lsign-keys calls when provisioning keyrings.
