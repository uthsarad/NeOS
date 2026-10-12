1. Modify `profile/airootfs/usr/local/bin/neos-autoupdate.sh`
   - Use `replace_with_git_merge_diff` to add `timeout 10s` to the `notify-send` command inside the `notify_users` function.
   - Verify the modification with `cat profile/airootfs/usr/local/bin/neos-autoupdate.sh`.
2. Generate `.jules/sentinel.md`
   - Create the directory `.jules` if it doesn't exist.
   - Use heredoc to record the critical security learning about mitigating Local DoS risks when executing user-level IPC commands from root scripts.
   - Verify creation with `cat .jules/sentinel.md`.
3. Generate `SENTINEL_REPORT.md`
   - Use heredoc to document the risks found, fixes applied, remaining attack surface, and severity summary using the required headers.
   - Verify creation with `cat SENTINEL_REPORT.md`.
4. Run comprehensive test suite
   - Execute `ruby tools/neos_tasks.rb test` to ensure no system-wide regressions were introduced.
5. Complete pre-commit steps
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
6. Submit the change
   - Use `submit` with branch name `testing`, title "Sentinel: [HIGH] Fix Local DoS via user DBus session", and a description outlining the vulnerability, impact, and fix.
