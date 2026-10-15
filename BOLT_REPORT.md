# Bolt Optimization Report

## What was optimized
Batched multiple `pacman-key` operations in `build.sh` into a single subprocess call.

## Before/after reasoning
Before, the script invoked `pacman-key --recv-key` and `pacman-key --lsign-key` sequentially for each missing key. This caused unnecessary subprocess and network overhead by hitting the keyserver multiple times. After the optimization, missing keys are collected into a bash array and passed as a batch to `--recv-keys` and `--lsign-keys`, hitting the network only once and reducing subprocess invocations.

## Any remaining performance risks
None identified for this specific code block. Network latency to keyservers is unavoidable but is now minimized by batching.
