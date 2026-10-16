## What was optimized
1. **Keyring Import Batching**: Consolidated multiple `pacman-key` calls into a single batched operation using bash arrays.
2. **Subprocess Elimination**: Replaced the `ls -A` subprocess for package counting and the `find | sort | head | cut` pipeline for ISO discovery with native Bash globbing and array evaluations.

## Before/after reasoning
* **Keyring Import**: Previously, importing missing keys spawned separate `pacman-key --recv-key` and `--lsign-key` processes per key, adding unnecessary overhead and keyserver hits. Batching them reduces latency and improves build resilience.
* **Subprocess Elimination**: Spawning subprocesses like `ls`, `find`, `sort`, `head`, and `cut` for simple file checks is computationally expensive in bash loops. Native Bash features (`shopt -s nullglob`, array lengths, and `-nt` comparison) achieve the same result faster and without context switching.

## Any remaining performance risks
* Keyring download over the network remains a potential bottleneck if mirrors are slow.
* ISO building and squashfs compression continue to consume significant CPU and time.
