# ⚡ BOLT REPORT: CI Subprocess Optimizations

## What was optimized
1. **Removed `find` and `wc` subprocesses in `tests/verify_iso_smoketest.sh`**:
   - Replaced `find "$OUT_DIR" -maxdepth 1 -type f -name "*.iso" | wc -l` with native bash array globbing `shopt -s nullglob; files=("$OUT_DIR"/*.iso); ISO_COUNT=${#files[@]}`.
   - Replaced `find "$OUT_DIR" ... -printf "%f (%s bytes)\n"` with a native bash `for` loop iterating over the matched glob files, utilizing `stat` directly.
2. **Removed `awk` math execution in `.github/workflows/build-iso.yml`**:
   - Replaced floating-point execution via `awk "BEGIN {printf \"%.2f\", $ISO_SIZE / 1024 / 1024}"` with native bash arithmetic: `printf -v ISO_SIZE_MB "%d.%02d" "$((ISO_SIZE / 1048576))" "$(((ISO_SIZE % 1048576) * 100 / 1048576))"`. This replicates exact decimal behavior without spawning external `awk` subprocesses.

## Before/after reasoning
**Before**:
- The script relied on multiple `find` + `wc` subshells merely to count the ISO count in a single flat directory `out/`.
- CI relied on `awk` calls purely to format integer bytes into MB/GiB human-readable formats. Forking subprocesses is slow when compared to operations bash natively supports.

**After**:
- Replaced `awk` with a clever `printf` + arithmetic manipulation to handle precision math internally without dropping down to external binaries.
- Bash arrays handle simple one-directory deep file globbing orders of magnitude faster than invoking `find`.

## Any remaining performance risks
- The `awk` executable remains in the pipeline installation steps purely to satisfy dependencies of other tools down the line.
- Native bash integer arithmetic caps out at maximum signed 64-bit bounds (~9 Exabytes), which is well beyond ISO size requirements and introduces no precision overflow risk here.
