# Bolt Performance Report

**Deliverable:** Pre-build CI Validation and Config Fixes
**Focus Area:** CI/CD Pipeline Optimization

## What Was Optimized
In `.github/workflows/build-iso.yml`, the method for discovering the generated ISO file was optimized.

**Before:**
```bash
ISO_FILE=$(find out -maxdepth 1 -name "*.iso" -type f | head -1)
```

**After:**
```bash
shopt -s nullglob
files=(out/*.iso)
ISO_FILE="${files[0]:-}"
```

## Before/After Reasoning
The original file discovery logic relied on piping the output of the `find` subprocess into `head`. This incurs unnecessary execution overhead from spawning multiple subprocesses. By using native bash globbing and arrays, the file discovery is handled entirely internally within the bash process, significantly reducing overhead in the CI runner environment. Since the `out/` directory usually contains only one ISO file, `files[0]` provides an O(1) file selection identical to `head -1`.

## Remaining Performance Risks
The use of `awk` for computing `ISO_SIZE_MB` and `MAX_SIZE_MB` still spawns external subprocesses for math formatting. While bash lacks native floating-point arithmetic to fully replace `awk`, these calls execute quickly enough that the CI bottleneck remains elsewhere (e.g. pacman installations). We kept `awk` because accuracy and readability are prioritized here over extreme micro-optimization of arithmetic.
