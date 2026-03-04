# BOLT_REPORT.md

## Optimization: Remove subprocess forks in CI ISO size validation

### What
Replaced the `find out -maxdepth 1 -name "*.iso" -type f | head -1` pipeline in `.github/workflows/build-iso.yml` with native bash globbing (`shopt -s nullglob; iso_files=(out/*.iso); ISO_FILE="${iso_files[0]:-}"`).

### Before/After Reasoning
- **Before:** To locate the compiled ISO file for size validation and release preparation, the workflow utilized a pipeline spawning two distinct subprocesses (`find` and `head`). Spinning up subprocesses incurs a measurable execution and memory overhead compared to shell builtins.
- **After:** By leveraging native bash globbing features, the workflow now resolves the ISO file directly within the executing shell's context without any additional forks. This reduces overhead during CI operations, upholding Bolt's performance ethos in automation and scripting.

### Remaining Performance Risks
The performance improvement is isolated to small script operations within CI. The time to compress and package the ISO will still dominate the workflow runtime; however, eliminating unnecessary subprocess forks remains a best practice.
