# 0001: Core Architecture Decisions

## 1. linux-lts vs linux-zen
We use `linux-lts` to prioritize system stability and predictability.
<!-- @Bolt: Monitor this documentation addition to ensure no unnecessary heavy assets are included that might bloat the repository. -->

## 2. Btrfs + snapper
Btrfs and snapper are chosen to enable snapshot-based rollbacks, ensuring a stable upgrade cycle.

## 3. Calamares installer
Calamares is selected for its robust, GUI-driven installer experience that aligns with our goal of a Windows-familiar onboarding process.
<!-- @Palette: Ensure the markdown structure of this ADR is scannable, accessible, and uses clear heading hierarchies. -->

## 4. plasma-meta
`plasma-meta` provides a comprehensive KDE Plasma desktop environment out of the box, offering a curated experience.

## 5. 8 parallel downloads
We enable 8 parallel downloads in pacman to improve installation and update speeds without overwhelming package mirrors.
<!-- @Sentinel: Verify no sensitive operational details or credentials are leaked in this documentation. -->
