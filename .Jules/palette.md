## 2024-05-01 - Formatting Bash Script Outputs
**Learning:** Adding explicit ANSI color codes and layout structures (like separators and "How to fix:" sections) to bash script output significantly improves debuggability and user experience in CLI environments, especially during boot/installation phases.
**Action:** When updating shell scripts, look for critical errors and milestones and format them with colors (`\e[1m\e[31m` for errors, `\e[1m\e[36m` for info/milestones) and structured text (e.g., emojis and clear headings). Ensure `echo -e` or `printf` is used correctly to parse escape sequences.
## 2026-02-17 - GitHub Actions CI Log Organization
**Learning:** Using `::group::[Title]` and `::endgroup::` in GitHub Actions workflows alongside emojis drastically improves the Developer Experience (DX) and UX by making logs scannable, collapsible, and less overwhelming during verbose builds.
**Action:** When updating CI workflows, wrap verbose shell script loops, security scans, and test runs within `::group::` to preserve readable output while avoiding log clutter.
