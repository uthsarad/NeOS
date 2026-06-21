## 2024-06-20 - Baseline Initialization
**Learning:** Initialized performance baseline in a zero-modification scenario. No architecture-specific bottlenecks identified yet.
**Action:** Proceed with identifying and measuring active performance bottlenecks in future iterations.
## 2026-02-17 - Avoid Subshell Overhead for PWD
**Learning:** Using `$(pwd)` in bash scripts introduces subshell overhead, which can be inefficient, especially in loops or frequently called functions. The native environment variable `$PWD` provides the exact same information with zero overhead.
**Action:** Always prefer the built-in `$PWD` environment variable over executing `$(pwd)` in bash scripts for improved performance.
