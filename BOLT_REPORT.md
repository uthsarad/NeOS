# Bolt Optimization Report

## Optimization: Efficient Kernel Module Probing

### What was optimized
- Replaced the heavy `lsmod | grep` pipeline for checking NVIDIA modules with a direct file read (`grep -q "^nvidia " /proc/modules 2>/dev/null`).
- Introduced a lightweight `load_modules` bash function in `neos-driver-manager` to safely verify if modules are already loaded via `/proc/modules` before invoking the external `modprobe` binary.
- Updated module loading for Intel/AMD GPUs, Network cards (Broadcom, Realtek, Intel), and Virtualization Guest drivers to use the new `load_modules` function.

### Before/After Reasoning
- **Before:** The script frequently spawned `modprobe` subprocesses for various hardware detection cases. Even if a module was already loaded, `modprobe` incurs subprocess initialization and I/O overhead. Additionally, checking module presence using `lsmod | grep` spawned at least two subprocesses and a pipe.
- **After:** By checking `/proc/modules` directly using a single native `grep` command per module, we avoid spawning unnecessary `modprobe` processes when modules are already present. This reduces CPU cycles and overall execution time, especially during early boot hardware detection.

### Remaining Performance Risks
- The `lspci` command output parsing is already optimized, but the command itself is an external process. Caching its output correctly mitigates repeated execution, but it still contributes to boot time.
- The `load_modules` function still uses external `grep`. A pure bash implementation could theoretically avoid even the `grep` subprocess, but parsing `/proc/modules` natively in bash might be slower than a single `grep` call depending on the number of loaded modules. For now, the current optimization strikes a good balance between readability and performance.
