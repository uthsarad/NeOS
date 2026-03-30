# Bolt Performance Report

## What was optimized
1. **Removed Subprocess Overhead**: The parsing of the `neos-mirrorlist` file was optimized. Previously, it utilized an external `awk` process inside a subshell `$(awk ...)`, which then piped `echo` output into a `while read` loop, spawning another subshell. This has been replaced with a native Bash `while read -r` loop combined with native regex string matching (`[[ ... =~ ... ]]`) and parameter expansion to sanitize the matched URLs.
2. **Added Connection Timeout**: The `curl` connectivity check was modified to include `--connect-timeout 5` alongside the existing `--max-time 10` configuration.

## Before/After Reasoning
- **Before**: Using `awk` and subshells caused unnecessary fork and execute overhead (spawning new processes) inside a bash script, which degraded performance, especially during CI execution. The missing `--connect-timeout` inside the `curl` command meant if a server was entirely unreachable and silently dropping packets, the CI would hang for up to the full `--max-time` (10s) duration for each offline mirror.
- **After**: The native bash extraction eliminates external process invocation completely and streamlines the file reading. By adding a 5-second connection timeout, `curl` will now fail fast during the TCP handshake phase if the server is unreachable, while retaining the 10-second `--max-time` allowance for slow but alive servers.

## Remaining Performance Risks
- **Sequential Network Requests**: The connectivity checks currently run synchronously (one at a time). If all top 5 mirrors are slow or unreachable, it could still take 25 to 50 seconds to complete. This could be optimized further using parallel execution (e.g., `xargs -P` or bash background jobs `&`), though it might increase script complexity. For now, sequential testing is retained for simplicity and logging clarity.
## Reduced Timeouts & Optimized Regex
1. **Removed Redundant Parameter Expansion**: Simplified the bash regex match to extract the URL without trailing spaces directly (`([^[:space:]]+)`), eliminating the need for a separate, complex parameter expansion step (`BASE_URL="${BASE_URL%"${BASE_URL##*[![:space:]]}"}"`) and speeding up the loop.
2. **Aggressive Timeout Limits**: Reduced `curl` connection timeout from 5 seconds to 2 seconds, and max timeout from 10 seconds to 3 seconds. This severely limits the maximum wait time per offline mirror, significantly preventing the CI pipeline from hanging if network connectivity issues arise.
