# Bolt's Journal ⚡

This journal records critical performance learnings, architectural bottlenecks, and optimization insights for the NeOS project.

## 2024-05-22 - Switch to EROFS for Live ISO
**Learning:** Default SquashFS compression in Archiso provides good compression but slower random read access compared to EROFS (Enhanced Read-Only File System). For a live desktop environment like NeOS, read latency directly impacts application launch times and overall responsiveness.
**Action:** Enabled `airootfs_image_type="erofs"` in `profiledef.sh`. This requires `erofs-utils` (already present) and a 5.4+ kernel. Future ISO builds should be monitored for build time vs. runtime performance trade-offs, but runtime speed is the priority.
