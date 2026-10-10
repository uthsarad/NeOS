# BOLT REPORT

## What was optimized
Eliminated subprocess overhead in `build.sh` during the packaging and ISO patching phase. Replaced external pipelines like `ls -A` in a command substitution and `find | sort | head | cut` with native Bash array globbing and the `-nt` (newer than) file comparison operator.

## Before/after reasoning
Previously, verifying the existence of `.pkg.tar.zst` files and locating the most recent ISO required multiple external subprocesses (find, sort, head, cut, ls). By switching to native Bash features, we eliminate fork/exec overhead, avoid potential text-truncation bugs from pipelines, and make the build script faster and more robust.

## Any remaining performance risks
The build still heavily relies on `mkarchiso` and downloading packages over the network, which are the primary bottlenecks. No remaining pure bash performance issues identified in this section.
