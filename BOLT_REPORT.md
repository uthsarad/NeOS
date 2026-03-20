# Bolt Performance Report

## Optimization Focus
Elimination of subprocess forks during CI script execution.

## What was optimized
In `.github/workflows/build-iso.yml`, specifically within the "Prepare Build Config" step, two subprocess calls were eliminated:
- `sed -i` calls used to replace paths within `pacman-build.conf`.

## Before/After Reasoning
### Before
- The CI step used multiple `sed -i` commands to modify a file in-place, causing multiple subprocess forks, which is measurable overhead in CI environments.

### After
- `sed` calls were replaced with reading the file into bash (`PACMAN_CONF_CONTENT=$(<"$GITHUB_WORKSPACE/pacman-build.conf")`) and using native bash string replacement (`${PACMAN_CONF_CONTENT//pattern/replacement}`), before writing back to the file. The original `grep` behavior was left intact as replacing it caused regressions in previous review.

These changes eliminate the need to spawn `sed` binaries, leading to a faster and more efficient execution inside the GitHub Actions runner.

## Remaining Performance Risks
The tests in `tests/` also invoke `timeout 60s bash "$script"`, which involves subprocesses, but they have already been optimized for internal parsing where possible. There are no remaining significant shell parsing bottlenecks in the modified area. No behavioral or functional changes were introduced by these micro-optimizations.