# 4. Use plasma-meta for KDE Plasma desktop

Date: 2026-02-17
Status: Accepted

## Context
We need to provide a complete, well-integrated, and consistently updated desktop environment.

## Decision
We will install the KDE Plasma desktop using the `plasma-meta` package rather than picking individual packages.

## Consequences
- Ensures all core KDE Plasma components are installed.
- Simplifies updates and reduces the risk of missing dependencies.
- May include some applications or utilities that some users might consider "bloat".
