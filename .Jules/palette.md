## 2026-02-17 - Baseline Initialization
**Learning:** During the "Strategic Pause" baseline initialization, an Architect scope explicitly forbidding file modifications mandates a strictly zero-modification execution. In this unique scenario, skipping PR creation entirely is the correct procedure, prioritizing test validation and strict task completion logging over baseline reporting.
**Action:** When a strict Strategic Pause is enforced by `ARCHITECT_SCOPE.json`, explicitly skip PRs (`request_code_review`), run codebase tests, complete the `pre_commit_instructions` tool, and call `done` directly to formally close the execution loop without violating the zero-modification constraint.
## 2026-02-17 - UX Log Formatting
**Learning:** Raw terminal error outputs without structured cues fail to guide users quickly, even when actionable data like the exit code and file line are logged.
**Action:** Always wrap crucial script errors in high-contrast visual blocks with bulleted, easily scannable sections to improve the diagnostic UX.

## 2024-07-20 - Custom Login Screen Keyboard Accessibility
**Learning:** Custom QML login screens don't get automatic tab-navigation and focus states for non-native components like `Rectangle` buttons. Users who rely on keyboard navigation can get stuck if manual `KeyNavigation` and `activeFocusOnTab` properties aren't explicitly mapped, leading to an inaccessible login flow.
**Action:** Always test tab flow explicitly on custom QML components and explicitly bind `activeFocusOnTab`, `Keys.onReturnPressed`, and focus-visible border styles to interactive elements that aren't native UI controls.
