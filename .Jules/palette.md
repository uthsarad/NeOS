## 2024-03-27 - Actionable Admin Errors
**Learning:** System admin errors should be clear, informative, and provide actionable context, explaining both what went wrong and how to fix it.
**Action:** When writing system administrative scripts, always ensure errors suggest the required remediation steps rather than just failing silently or cryptically.

## 2024-03-30 - Enhanced Visual Hierarchy in CLI Errors
**Learning:** Using structural visual cues (like ASCII borders and spacing) in terminal output significantly reduces cognitive load during failure analysis by separating the error state from the actionable remediation steps.
**Action:** When creating CLI error messages, group related information using borders and clear indentation to guide the developer's eye to the root cause and the fix sequentially.
