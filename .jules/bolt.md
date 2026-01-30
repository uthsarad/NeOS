## 2024-05-22 - Initial Scan
**Learning:** Repo is a scaffold with no source code. Performance optimizations must currently be architectural.
**Action:** Focus on documenting performance limits and goals to prevent future bottlenecks.

## 2024-05-24 - Documentation Performance
**Learning:** In the absence of code, "Performance" translates to "Developer Efficiency". Improving documentation navigability (TOC) and actionability (copy-paste commands) significantly reduces verification time.
**Action:** When optimizing docs, prioritize actionable verification steps over theoretical targets.

## 2026-01-29 - ISO Filesystem Optimization
**Learning:** Switching `airootfs` to EROFS with LZ4HC compression offers a measurable boot time improvement over SquashFS/Zstd for read-only ISOs, aligning with the "Cold Boot" budget.
**Action:** Default to EROFS for all future high-performance ISO profiles in this project.

## 2024-05-24 - Tooling Dependency for Validation
**Learning:** Attempted to optimize EROFS compression level but lacked `mkfs.erofs` to validate syntax/options.
**Action:** When working in limited environments, prioritize optimizations that can be validated with available tools or standard config parsers (like pacman.conf) over those requiring specific binary tools.
