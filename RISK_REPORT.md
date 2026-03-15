# Risk & Priority Report

## Current Risks

### 1. Security Risks
- **Privileged CI Execution:** Running pre-build tests in a container with `--privileged` can expose the host CI environment if tests contain malicious code or vulnerabilities. This risk is acceptable for early-stage validation but requires Sentinel review to ensure tests don't exploit this privilege.
- **Unvalidated Test Scripts:** If test scripts (e.g., `verify_mkinitcpio.sh`) lack robust error handling or timeout configurations, they could result in pipeline hangs, consuming CI minutes and blocking other pull requests. Using `timeout` with correct exit code propagation mitigates this.

### 2. Performance Risks
- **Subprocess Overhead in CI:** While bash scripts orchestrating tests are generally fast, excessive use of subprocesses (`awk`, `cut`, `find`) in critical paths can slightly slow down validation. Bolt's optimizations (native bash features) will keep test overhead minimal.
- **ISO Size Limitations:** If dependencies are not carefully managed, the ISO could easily exceed the 2 GiB GitHub Release limit. The CI checks are correctly in place, but developers must adhere to the provided remediation steps if limits are hit.

### 3. Complexity Risks
- **Testing Architecture Debt:** Integrating more pre-build tests without a clear structure increases the complexity of `.github/workflows/build-iso.yml`. The risk is mitigated by maintaining a clear distinction between pre-build tests and ISO-dependent tests.
- **Actionable Feedback:** As the testing suite grows, developer cognitive load increases if error messages are vague. Palette's requirement for clear, actionable remediation blocks ensures this complexity is manageable.

## Priorities for Next Iteration
1. **Consolidate Pre-Build CI:** Ensure the test job is stable, reports failures accurately without hanging, and does not mask underlying test errors.
2. **Standardize Test Output:** Ensure all test scripts output a standardized error format (the '💡 How to fix:' pattern).
3. **Repository Hygiene:** Complete basic housekeeping (like updating `.gitignore`) to keep the development environment clean and reproducible.