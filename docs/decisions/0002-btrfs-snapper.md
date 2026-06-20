# 2. Btrfs and Snapper for default filesystem

Date: 2026-02-17
Status: Accepted

## Context
We want to provide robust recovery mechanisms and seamless system rollbacks for our users.

## Decision
We will default to the Btrfs filesystem for the root partition and pre-configure Snapper for automated snapshots.

## Consequences
- Fast and space-efficient snapshots.
- Requires proper maintenance to avoid filling up the disk.
- Excludes some features only available in ZFS or ext4.
