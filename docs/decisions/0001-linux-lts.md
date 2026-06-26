# 1. Use linux-lts instead of linux-zen

Date: 2026-02-17
Status: Accepted

## Context
NeOS aims for high stability and reliability. We need a default kernel that minimizes the risk of breaking updates and regressions.

## Decision
We will use the `linux-lts` package as the default kernel for NeOS, rather than the `linux` or `linux-zen` kernels.

## Consequences
- Better stability and longer support cycles.
- Slightly older hardware support compared to the mainline kernel.
- Missed performance optimizations present in `linux-zen`.
