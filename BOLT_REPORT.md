# Bolt Performance Report

## What was optimized
Batched multiple `pacman-key` key retrieval and signing commands into single subprocess executions in `build.sh`.

## Before/after reasoning
**Before**: `build.sh` invoked `pacman-key --recv-key` and `pacman-key --lsign-key` for each missing GPG key sequentially. This meant up to 6 separate subprocess invocations, each with its own GPG homedir initialization, and 3 distinct HTTPS requests to the keyserver.
**After**: Added missing keys to a bash array and passed them all to a single `pacman-key --recv-keys` and a single `pacman-key --lsign-key` invocation. This cuts GPG overhead from 6 invocations to 2 and keyserver network requests from 3 to 1.

## Any remaining performance risks
We are still invoking `pacman-key --list-keys` upfront. This has been cached to `$CURRENT_KEYS`, but parsing that huge string could be optimized in the future or we could ignore upfront parsing and rely entirely on `pacman-key --recv-keys` caching if `pacman-key` is smart enough. For now, the current caching works effectively.
