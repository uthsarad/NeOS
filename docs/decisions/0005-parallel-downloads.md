# 5. Enable 8 parallel downloads in pacman

Date: 2026-02-17
Status: Accepted

## Context
We want to minimize the time it takes to download packages during system updates and installation.

## Decision
We will configure pacman to use 8 parallel downloads (`ParallelDownloads = 8`).

## Consequences
- Significantly speeds up package fetching.
- May cause issues on slow or unstable network connections.
- Increases concurrent load on mirrors.
