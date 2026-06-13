## 2024-05-01 - Formatting Bash Script Outputs
**Learning:** Adding explicit ANSI color codes and layout structures (like separators and "How to fix:" sections) to bash script output significantly improves debuggability and user experience in CLI environments, especially during boot/installation phases.
**Action:** When updating shell scripts, look for critical errors and milestones and format them with colors (`\e[1m\e[31m` for errors, `\e[1m\e[36m` for info/milestones) and structured text (e.g., emojis and clear headings). Ensure `echo -e` or `printf` is used correctly to parse escape sequences.
## 2026-02-17 - GitHub Actions DX Formatting
**Learning:** Utilizing `::group::` and `::endgroup::` syntax in GitHub Actions CI logs significantly improves Developer Experience (DX) by collapsing verbose script output and security scans, making logs easier to navigate.
**Action:** When updating CI workflows, apply grouping to long-running or noisy steps, ensuring to capture and explicitly evaluate exit codes when using `set -e` to prevent masking failures.
